/**
 * W-12578110
 * LWC quick action, displays Tabs to add Rules & Audit Flags based on the Rule Criteria Configuration.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         11/03/2023      Chakshu Malhotra        W-12578110 - Fetches MA_DS_AddRulesCriteriaWrapper from Apex Controller and process Rules / Audit Flags. 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { loadStyle } from 'lightning/platformResourceLoader';
import { reduceErrors } from 'c/maErrorHandlingUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { addRulesCriteriaConstants, addRulesCriteriaLabels } from 'c/madsUtils';

import madsAddRulesCriteriaCSS from '@salesforce/resourceUrl/madsAddRulesCriteriaCSS';

import processRules from '@salesforce/apex/MA_DS_AddRulesCriteria.processRules';
import getRulesWrapper from '@salesforce/apex/MA_DS_AddRulesCriteria.getRulesWrapper';
import { RefreshEvent } from "lightning/refresh";

export default class MadsAddRulesCriteria extends LightningElement {
    
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        if(this._recordId !== value) {
            this._recordId = value;
            this.fetchRulesWrapper();
        }
    }
    
    @api
    get objectApiName() {
        return this._objectApiName;
    }
    set objectApiName(value) {
        if(this._objectApiName !== value) {
            this._objectApiName = value;
            this.fetchRulesWrapper();
        }
    }

    showSpinner;
    fetchedRulesWrapper;

    disabledSaveButton;
    hasRulesOrAuditFlags;

    displayAuditFlags;
    displayRulesCriteria;

    rulesWrapper;
    objectOptions;
    maxSampleSize;
    errorResponse;

    label = addRulesCriteriaLabels;
    constants = addRulesCriteriaConstants;

    constructor() {
        super();
        this.rulesWrapper = {};
        this.maxSampleSize = 0;
        this.showSpinner = true;
        this.errorResponse = false;
        this.displayAuditFlags = false;
        this.disabledSaveButton = true;
        this.fetchedRulesWrapper = false;
        this.displayRulesCriteria = false;
        this.hasRulesOrAuditFlags = false;
    }

    get illustrativeMsg() {
        if(this._illustrativeMsg === undefined) {
            this._illustrativeMsg = this.label.loadingRulesMsg;
        }
        return this._illustrativeMsg;
    }set illustrativeMsg(value) {
        this._illustrativeMsg = value;
    }

    // Field Type to List of Allowed Operators
    get operatorsMap() {
        if(this._operatorsMap === undefined) {
            this._operatorsMap = new Map();
        }
        return this._operatorsMap;
    }

    // sObjectName to List of Sorted Fields (label & value)
    get rulesFieldMap() {
        if(this._rulesFieldMap === undefined) {
            this._rulesFieldMap = new Map();
        }
        return this._rulesFieldMap;
    }

    // sObjectName to List of Sorted Fields (label & value)
    get auditFieldMap() {
        if(this._auditFieldMap === undefined) {
            this._auditFieldMap = new Map();
        }
        return this._auditFieldMap;
    }

    // sObjectName + fieldKey to FieldWrapper
    get rulesFieldWrapperMap() {
        if(this._rulesFieldWrapperMap === undefined) {
            this._rulesFieldWrapperMap = new Map();
        }
        return this._rulesFieldWrapperMap;
    }

    // sObjectName + fieldKey to FieldWrapper
    get auditFieldWrapperMap() {
        if(this._auditFieldWrapperMap === undefined) {
            this._auditFieldWrapperMap = new Map();
        }
        return this._auditFieldWrapperMap;
    }

    get rulesWrapperMap() {
        if(this._rulesWrapperMap === undefined) {
            this._rulesWrapperMap = new Map();
        }
        return this._rulesWrapperMap;
    }

    get rulesCriteriaMap() {
        if(this.rulesWrapperMap && this._rulesCriteriaMap === undefined) {
            this._rulesCriteriaMap = this.rulesWrapperMap.get(this.constants.RULES_CRITERIA_JSON_KEY);
        }
        return this._rulesCriteriaMap;
    }

    get auditFlagsMap() {
        console.log('this.rulesWrapperMap',this.rulesWrapperMap);
        console.log('this.constants.AUDIT_FLAGS_JSON_KEY',this.constants.AUDIT_FLAGS_JSON_KEY);
        if(this.rulesWrapperMap && this._auditFlagsMap === undefined) {
            this._auditFlagsMap = this.rulesWrapperMap.get(this.constants.AUDIT_FLAGS_JSON_KEY);
        }
        console.log('this._auditFlagsMap',this._auditFlagsMap);
        return this._auditFlagsMap;
    }

    get logicValidityMap() {
        if(this._logicValidityMap === undefined) {
            this._logicValidityMap = new Map();
        }
        return this._logicValidityMap;
    }

    /**
     * recordId & objectApiName are undefined in connectedCallback (for Screen Actions).
     * Added this function to be called from the setter of both recordId & objectApiName properties.
     * fetchedRulesWrapper property will prevent from invoking the apex logic multiple times.
     */
    fetchRulesWrapper() {
        if(!this.fetchedRulesWrapper && this.recordId && this.objectApiName) {
            this.fetchedRulesWrapper = true;
            Promise.all([
                loadStyle(this, madsAddRulesCriteriaCSS),
                this.getRulesWrapper()
            ]).then(() => {
                this.showSpinner = false;
            });
        }
    }

    async getRulesWrapper() {
        try {
            let responseWrapper = await getRulesWrapper({recordId: this.recordId, sObjectType: this.objectApiName});

            if(responseWrapper.isError) {
                this.showErrorMessage(responseWrapper.errorMessage);
            }else if(responseWrapper.rulesWrapper) {
                this.initAddRulesUI(responseWrapper.rulesWrapper);
            }
        }catch(error) {
            this.handleAuraHandledException(error);
        }
    }

    initAddRulesUI(rulesWrapper) {
        this.initIllustrativeMsg(rulesWrapper);

        if(this.hasRulesOrAuditFlags) {
            this.initObjectOptions(rulesWrapper);
            this.initFieldMaps(rulesWrapper);
            this.initOperatorsMap(rulesWrapper);
            this.initRulesWrapper(rulesWrapper);
            this.initRulesWrapperMap(rulesWrapper);
            this.maxSampleSize = rulesWrapper.maxSampleSize;
            this.initTabs(rulesWrapper); // this has to be the last statement (after everything else is initialized)
        }
    }

    initIllustrativeMsg(rulesWrapper) {
        this.hasRulesOrAuditFlags = (rulesWrapper.displayAuditFlags || rulesWrapper.displayRulesCriteria);
        this.illustrativeMsg = this.hasRulesOrAuditFlags ? this.illustrativeMsg : rulesWrapper.noRulesDisplayMessage;
    }

    initObjectOptions(rulesWrapper) {
        this.objectOptions = Object.keys(rulesWrapper.sObjectMap)
        .map((sObjectKey) => ({"label": rulesWrapper.sObjectMap[sObjectKey], "value": sObjectKey}))
        .sort((sObjA, sObjB) => {
            const parentSObjectKey = rulesWrapper.parentSObject.toLowerCase();
            return (parentSObjectKey === sObjA.value.toLowerCase()) ? -1 : (parentSObjectKey === sObjB.value.toLowerCase()) ? 1 : 0;
        })
    }

    initFieldMaps(rulesWrapper) {
        this.initFieldMap(this.auditFieldMap, this.auditFieldWrapperMap, rulesWrapper.auditFlagsFieldMap);
        this.initFieldMap(this.rulesFieldMap, this.rulesFieldWrapperMap, rulesWrapper.rulesCriteriaFieldMap);
    }

    initFieldMap(fieldMap, fieldWrapperMap, rulesWrapperFieldMap) {
        for(const [sObjectKey, rulesFieldWrapperMap] of Object.entries(rulesWrapperFieldMap)) {

            let fields = Object.keys(rulesFieldWrapperMap).map((fieldKey) => {
                fieldWrapperMap.set(sObjectKey + fieldKey, rulesFieldWrapperMap[fieldKey]);
                return {"label": rulesFieldWrapperMap[fieldKey].label, "value": rulesFieldWrapperMap[fieldKey].value};
            }).sort((fieldA, fieldB) => {
                const fieldALabel = fieldA.label.toLowerCase();
                const fieldBLabel = fieldB.label.toLowerCase();
                return (fieldALabel < fieldBLabel) ? -1 : (fieldALabel > fieldBLabel) ? 1 : 0;
            });

            fieldMap.set(sObjectKey, fields);
        }
    }

    initOperatorsMap(rulesWrapper) {
        for(const [fieldType, allowedOperators] of Object.entries(rulesWrapper.allowedOperatorsMap)) {
            let operators = allowedOperators.map((allowedOperator) => ({"label": allowedOperator, "value": allowedOperator}));
            this.operatorsMap.set(fieldType, operators);
        }
    }

    initRulesWrapper(rulesWrapper) {
        this.rulesWrapper[this.constants.PARENT_SOBJECT] = rulesWrapper.parentSObject;
        this.rulesWrapper[this.constants.CHILD_REL_MAP] = rulesWrapper.childRelationshipMap;
    }

    initRulesWrapperMap(rulesWrapper) {
        if(rulesWrapper.displayAuditFlags) {
            this.setAuditFlagsJSON(rulesWrapper);
        }
        if(rulesWrapper.displayRulesCriteria) {
            this.setRulesCriteriaJSON(rulesWrapper);
        }
    }

    setAuditFlagsJSON(rulesWrapper) {
        const undefinedJSON = (rulesWrapper.auditFlagsJSON === undefined || rulesWrapper.auditFlagsJSON == null);
        this.rulesWrapper[this.constants.AUDIT_FLAGS_JSON_KEY] = undefinedJSON ? null : rulesWrapper.auditFlagsJSON;
        const auditFlagsJsonMap = undefinedJSON ? new Map() : this.convertAuditFlagsJSONToMap(rulesWrapper.auditFlagsJSON);
        this.rulesWrapperMap.set(this.constants.AUDIT_FLAGS_JSON_KEY, auditFlagsJsonMap);
    }

    convertAuditFlagsJSONToMap(auditFlagsJSON) {
        let auditFlagsJsonMap = new Map();
        for(const [sObjectKey, auditFLagFieldWrapperMap] of Object.entries(auditFlagsJSON)) {
            auditFlagsJsonMap.set(sObjectKey, new Map(Object.entries(auditFLagFieldWrapperMap)));
        }
        return auditFlagsJsonMap;
    }

    setRulesCriteriaJSON(rulesWrapper) {
        const undefinedJSON = (rulesWrapper.rulesCriteriaJSON === undefined || rulesWrapper.rulesCriteriaJSON == null);
        this.rulesWrapper[this.constants.RULES_CRITERIA_JSON_KEY] = undefinedJSON ? null : rulesWrapper.rulesCriteriaJSON;
        const rulesCriteriaJsonMap = undefinedJSON ? this.initRulesCriteriaJSON() : this.convertRulesCriteriaJSONToMap(rulesWrapper.rulesCriteriaJSON);
        this.rulesWrapperMap.set(this.constants.RULES_CRITERIA_JSON_KEY, rulesCriteriaJsonMap);
    }

    initRulesCriteriaJSON() {
        let rulesCriteriaJsonMap = new Map();
        rulesCriteriaJsonMap.set(this.constants.FIELD_ROW_MAP, new Map());
        rulesCriteriaJsonMap.set(this.constants.RULE_LOGIC_MAP, new Map());
        rulesCriteriaJsonMap.set(this.constants.FIELD_VALUE_MAP, new Map());
        rulesCriteriaJsonMap.set(this.constants.CUSTOM_LOGIC_MAP, new Map());
        rulesCriteriaJsonMap.set(this.constants.FIELD_OPERATOR_MAP, new Map());
        return rulesCriteriaJsonMap;
    }

    convertRulesCriteriaJSONToMap(rulesCriteriaJSON) {
        let rulesCriteriaJsonMap = new Map();
        for(const [ruleCriteriaWrapperKey, ruleCriteriaWrapperMap] of Object.entries(rulesCriteriaJSON)) {
            rulesCriteriaJsonMap.set(ruleCriteriaWrapperKey, new Map(Object.entries(ruleCriteriaWrapperMap)));
        }
        return rulesCriteriaJsonMap;
    }

    initTabs(rulesWrapper) {
        console.log('init tab',rulesWrapper);
        this.displayAuditFlags = rulesWrapper.displayAuditFlags;
        this.displayRulesCriteria = rulesWrapper.displayRulesCriteria;
        this.disabledSaveButton = !this.hasRulesOrAuditFlags;
    }

    showErrorMessage(errorMessage) {
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({"title": "Error", "message": errorMessage, "variant": "error", "mode": "sticky"}));
    }

    handleAuraHandledException(error) {
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({"title": "Error", "message": reduceErrors(error), "variant": "error", "mode": "sticky"}));
    }

    handleCancel(event) {
        event.preventDefault();
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave(event) {
        event.preventDefault();
        this.showSpinner = true;

        this.updateAuditFlagsJSON();
        this.updateRulesCriteriaJSON();

        if(this.logicValidityMap.size > 0) {
            this.reportCustomLogicValidity();
        }else {
            this.processRulesWrapper();
        }
    }

    updateAuditFlagsJSON() {
        if(this.displayAuditFlags) {
            const auditFlagsTab = this.template.querySelector("c-mads-audit-flags-tab");
            this.rulesWrapper[this.constants.AUDIT_FLAGS_JSON_KEY] = this.getAuditFlagsJSON(auditFlagsTab);
        }
    }

    getAuditFlagsJSON(auditFlagsTab) {
        console.log('@@@auditFlagsTab',auditFlagsTab);
        console.log('@@@auditFlagsTab',auditFlagsTab.getAuditFlagsJSON());
        console.log('@@@auditFlagsTab',this.rulesWrapper[this.constants.AUDIT_FLAGS_JSON_KEY]);
        const auditFlagsJSON = auditFlagsTab ? auditFlagsTab.getAuditFlagsJSON() : this.rulesWrapper[this.constants.AUDIT_FLAGS_JSON_KEY];  
        
        return (auditFlagsJSON === undefined) ? null : auditFlagsJSON;
    }

    updateRulesCriteriaJSON() {
        if(this.displayRulesCriteria) {
            const rulesCriteriaTab = this.template.querySelector("c-mads-rules-criteria-tab");
            this.rulesWrapper[this.constants.RULES_CRITERIA_JSON_KEY] = this.getRulesCriteriaJSON(rulesCriteriaTab);
            this.setCustomLogicValidity(rulesCriteriaTab, this.rulesWrapper[this.constants.RULES_CRITERIA_JSON_KEY]);
        }
    }

    getRulesCriteriaJSON(rulesCriteriaTab) {
        const rulesCriteriaJSON = rulesCriteriaTab ? rulesCriteriaTab.getRulesCriteriaJSON() : this.rulesWrapper[this.constants.RULES_CRITERIA_JSON_KEY];
        return (rulesCriteriaJSON === undefined) ? null : rulesCriteriaJSON;
    }

    setCustomLogicValidity(rulesCriteriaTab, rulesCriteriaJSON) {
        if(rulesCriteriaTab != undefined && rulesCriteriaJSON != null) {
            for(const [sObjectKey, customLogic] of Object.entries(rulesCriteriaJSON[this.constants.CUSTOM_LOGIC_MAP])) {
                if(customLogic) {
                    let customLogicValidity = rulesCriteriaTab.getCustomLogicValidityFor(sObjectKey);

                    if(customLogicValidity == "") {
                        this.logicValidityMap.delete(sObjectKey);
                        rulesCriteriaTab.clearCustomLogicValidityFor(sObjectKey);
                        rulesCriteriaJSON[this.constants.RULE_LOGIC_MAP][sObjectKey] = rulesCriteriaTab.getCustomLogicFor(sObjectKey);
                    }else {
                        this.logicValidityMap.set(sObjectKey, customLogicValidity);
                    }
                }else if(this.logicValidityMap.has(sObjectKey)) {
                    this.logicValidityMap.delete(sObjectKey);
                }
            }
        }
    }

    reportCustomLogicValidity() {
        this.showSpinner = false;

        const rulesCriteriaTab = this.template.querySelector("c-mads-rules-criteria-tab");
        this.template.querySelector("lightning-tabset").activeTabValue = this.label.rulesCriteriaTab;

        this.logicValidityMap.forEach((customLogicValidity, sObjectKey) => {
            rulesCriteriaTab.reportCustomLogicValidityFor(sObjectKey, customLogicValidity);
        });
    }

    processRulesWrapper() {
        // console.log("rulesWrapper : " + JSON.stringify(this.rulesWrapper)); // use this only for debugging
        processRules({recordId: this.recordId, 
                      sObjectType: this.objectApiName, 
                      rulesWrapper: this.rulesWrapper})
        .then((responseWrapper) => {
            this.errorResponse = responseWrapper.isError;

            if(responseWrapper.isError) {
                this.showErrorMessage(responseWrapper.errorMessage);
            }else {
                this.showRulesProcessingSuccessMessage();
            }
        }).catch((error) => {
            this.errorResponse = true;
            this.handleAuraHandledException(error);
        }).finally(() => {
            this.showSpinner = false;
            if(!this.errorResponse) {
                this.refreshViewAndCloseAction();
            }
        });
    }

    showRulesProcessingSuccessMessage() {
        let successToastMessage = this.label.processRulesSuccessMessage;
        this.dispatchEvent(new ShowToastEvent({"title" : "Success!", "message" : successToastMessage, "variant" : "success"}));
    }

    refreshViewAndCloseAction() {
        this.dispatchEvent(new RefreshEvent());
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    disconnectedCallback() {
        let customCssElement = document.querySelector("link[rel=stylesheet][href*='madsAddRulesCriteriaCSS']");
        customCssElement?.parentNode?.removeChild(customCssElement);
    }
}