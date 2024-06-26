/**
 * W-12578110
 * Shows UI to add Rules based on the selection of Object, Field, Operator & Value provided.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         11/03/2023      Chakshu Malhotra        W-12578110 - Adds & interacts with UI to provide Rules based on the selection of Object, Field, Operator & Value provided.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire, track } from 'lwc';
import { rulesCriteriaTabConstants, rulesCriteriaTabLabels } from 'c/madsUtils';

export default class MadsRulesCriteriaTab extends LightningElement {
    @api objectOptions;

    @api fieldMap; // sObjectName to List of Sorted Fields (label & value)
    @api operatorsMap; // Field Type to List of Allowed Operators
    @api fieldWrapperMap; // sObjectName + fieldKey to FieldWrapper
    @api rulesCriteriaMap; // contains "rulesCriteriaJSON"

    @track selectedRules = []; // Object containing "objectLabel", "objectKey" & List of "rules"
    @track selectedFieldWrapper; // FieldWrapper type
    
    showSpinner;
    
    fieldOptions;
    operatorOptions;

    selectedField;
    selectedValue;
    selectedObject;
    selectedOperator;

    errorMessage;
    
    editMode;
    lastSelectedRule;

    label = rulesCriteriaTabLabels;
    constants = rulesCriteriaTabConstants;

    constructor() {
        super();
        this.editMode = false;
        this.errorMessage = "";
        this.showSpinner = false;
    }

    get isValidRulesCriteriaMap() {
        return (this.rulesCriteriaMap && this.rulesCriteriaMap.size > 0);
    }

    get ruleButtonLabel() {
        return this.editMode ? "Update" : "Add";
    }

    get buttonClassList() {
        return (this.selectedFieldWrapper && this.selectedFieldWrapper.type === "DATETIME") ? 
        (this.constants.BUTTON_CLASS + this.constants.BUTTON_MARGIN) : this.constants.BUTTON_CLASS;
    }

    connectedCallback() {
        this.setObjectCombobox();
        this.setSelectedRules();
      /*  console.log('this.rulesFieldMap***  '+JSON.stringify(this.mapToObject(this.fieldMap)));
        console.log('this.rulesFieldWrapperMap***  '+JSON.stringify(this.mapToObject(this.fieldWrapperMap)));
        console.log('operatorsMap** '+JSON.stringify(this.mapToObject(this.operatorsMap)));
        console.log('rulesCriteriaMap** ' + JSON.stringify(this.mapToObject(this.rulesCriteriaMap)));*/
    }

   mapToObject(map) {
        const obj = {};
        map.forEach((value, key) => {
            obj[key] = value;
        });
        return obj;
    }

    setObjectCombobox() {
        this.selectedObject = this.objectOptions[0].value;
        this.setFieldCombobox();
    }

    setFieldCombobox() {
        this.fieldOptions = this.fieldMap.get(this.selectedObject);
        this.selectedField = this.fieldOptions[0].value;
        this.setOperatorCombobox();
    }

    setOperatorCombobox() {
        this.selectedFieldWrapper = this.fieldWrapperMap.get(this.selectedObject + this.selectedField);
        this.operatorOptions = this.operatorsMap.get(this.selectedFieldWrapper.type);
        this.selectedOperator = this.operatorOptions[0].value;
    }

    setSelectedRules() {
        this.objectOptions.forEach((objectOption) => {
            let selectedRule = this.initSelectedRule(objectOption);
            let hasRulesForObject = this.hasRulesForObject(objectOption.value);
            selectedRule[this.constants.RULES] = hasRulesForObject ? this.initRulesCriteria(objectOption.value) : [];
            selectedRule[this.constants.RULE_LOGIC] = hasRulesForObject ? this.initRuleLogic(objectOption.value) : [];
            selectedRule[this.constants.CUSTOM_LOGIC] = hasRulesForObject ? this.initCustomLogic(objectOption.value) : false;
            this.selectedRules.push(selectedRule);
        });
        console.log('set SelectedRules***'+JSON.stringify(this.selectedRules));
    }

    initSelectedRule(objectOption) {
        let selectedRule = {};
        selectedRule[this.constants.OBJECT_KEY] = objectOption.value;
        selectedRule[this.constants.OBJECT_LABEL] = objectOption.label;
        return selectedRule;
    }

    hasRulesForObject(objectKey) {
        return (this.isValidRulesCriteriaMap && this.rulesCriteriaMap.get(this.constants.FIELD_ROW_MAP).has(objectKey));
    }

    initRulesCriteria(objectKey) {
        let rulesCriteria = [];        
        this.rulesCriteriaMap.get(this.constants.FIELD_ROW_MAP).get(objectKey).forEach((fieldWrapper, ruleIndex) => {
            let ruleNum = ruleIndex + 1;
            let concatenatedKey = objectKey + fieldWrapper.value + ruleNum;
            rulesCriteria.push(this.initRuleCriteria(fieldWrapper, concatenatedKey));
        });
        return rulesCriteria;
    }

    initRuleCriteria(fieldWrapper, concatenatedKey) {
        let ruleCriteria = {};
        ruleCriteria[this.constants.FIELD_KEY] = fieldWrapper.value;
        ruleCriteria[this.constants.FIELD_LABEL] = fieldWrapper.label;
        ruleCriteria[this.constants.FIELD_VAL] = this.rulesCriteriaMap.get(this.constants.FIELD_VALUE_MAP).get(concatenatedKey);
        ruleCriteria[this.constants.OPERATOR_KEY] = this.rulesCriteriaMap.get(this.constants.FIELD_OPERATOR_MAP).get(concatenatedKey);
        return ruleCriteria;
    }

    initRuleLogic(objectKey) {
        return this.rulesCriteriaMap.get(this.constants.RULE_LOGIC_MAP).get(objectKey);
    }

    initCustomLogic(objectKey) {
        return this.rulesCriteriaMap.get(this.constants.CUSTOM_LOGIC_MAP).get(objectKey);
    }

    objectChangeHandler(event) {
        event.preventDefault();
        this.showSpinner = true;
        console.log('objectChangeHandler**** '+JSON.stringify(event.detail));
        setTimeout(() => {
            this.selectedObject = event.detail.value;
            this.setFieldCombobox();
            this.resetFieldValue(false);
            this.showSpinner = false;
        }, 0);
    }

    fieldChangeHandler(event) {
        event.preventDefault();
        this.showSpinner = true;
        console.log('fieldChangeHandler**** '+JSON.stringify(event.detail));
        setTimeout(() => {
            this.selectedField = event.detail.value;
            this.setOperatorCombobox();
            this.resetFieldValue(false);
            this.showSpinner = false;
        }, 0);
    }

    operatorChangeHandler(event) {
        event.preventDefault();
        console.log('operatorChangeHandler**** '+JSON.stringify(event.detail));
        this.selectedOperator = event.detail.value;
        this.resetFieldValue(true);
    }

    resetFieldValue(handledOperatorChange) {
        this.errorMessage = "";
        this.template.querySelector("c-mads-rules-criteria-value").resetFieldValue(handledOperatorChange);
    }

    handleRuleButtonClick(event) {
        event.preventDefault();
        const valueCmp = this.template.querySelector("c-mads-rules-criteria-value");
       // console.log('valueCmp** '+this.template.innerHTML);
        const fieldValidity = valueCmp.getFieldValidity();
        console.log('fieldValidity** '+fieldValidity);
        this.errorMessage = fieldValidity;

        if(this.errorMessage === "") {
            this.selectedValue = valueCmp.getFieldValue();
            console.log('selectedValue** '+this.selectedValue);
            this.handleAddOrUpdateRule();
        }else {
            event.stopPropagation();
        }
    }

    handleAddOrUpdateRule() {
        this.addOrUpdateRuleCriteria();
        this.updateRulesCriteriaMap();

        if(this.editMode) {
            this.cleanUpEditMode();
        }else {
            this.setFieldCombobox();
            this.resetFieldValue(false);
        }
        // this.logRules(); // only for debugging
    }

    addOrUpdateRuleCriteria() {
        let selectedRule = this.getSelectedObjectRules(this.selectedObject);
        let ruleCriteria = this.getRuleCriteria(selectedRule, this.selectedFieldWrapper, this.selectedOperator, this.selectedValue);
        console.log('ruleCriteria** '+JSON.stringify(ruleCriteria));
        if(!this.editMode) {
            selectedRule[this.constants.RULES].push(ruleCriteria);
        }
        if(!selectedRule.customLogic) {
            selectedRule[this.constants.RULE_LOGIC] = this.getRuleLogic(selectedRule[this.constants.RULES]);
        }
    }

    getSelectedObjectRules(objectKey) {
        return this.selectedRules.find(selectedRule => selectedRule[this.constants.OBJECT_KEY] === objectKey);
    }

    getRuleCriteria(selectedRule, selectedFieldWrapper, selectedOperator, selectedValue) {
        let ruleCriteria = this.editMode ? selectedRule[this.constants.RULES][this.lastSelectedRule.ruleNum - 1] : {};
        ruleCriteria[this.constants.FIELD_VAL] = selectedValue;
        ruleCriteria[this.constants.OPERATOR_KEY] = selectedOperator;
        ruleCriteria[this.constants.FIELD_KEY] = selectedFieldWrapper.value;
        ruleCriteria[this.constants.FIELD_LABEL] = selectedFieldWrapper.label;
        return ruleCriteria;
    }

    getRuleLogic(rules) {
        return rules.map((rule, ruleIndex) => ruleIndex + 1).join(" AND ").split(" ");
    }

    updateRulesCriteriaMap() {
        let selectedRule = this.getSelectedObjectRules(this.selectedObject);
        const ruleNum = this.editMode ? this.lastSelectedRule.ruleNum : selectedRule[this.constants.RULES].length;
        this.updateRuleLogicMap(this.rulesCriteriaMap, this.selectedObject, selectedRule);
        this.updateCustomLogicMap(this.rulesCriteriaMap, this.selectedObject, selectedRule);
        this.updateFieldRowMap(this.rulesCriteriaMap, this.selectedObject, this.selectedFieldWrapper);
    }

    updateRuleLogicMap(rulesCriteriaMap, objectKey, selectedRule) {
        let ruleLogicMap = rulesCriteriaMap.get(this.constants.RULE_LOGIC_MAP);
        ruleLogicMap.set(objectKey, selectedRule[this.constants.RULE_LOGIC]);
    }

    updateCustomLogicMap(rulesCriteriaMap, objectKey, selectedRule) {
        let customLogicMap = rulesCriteriaMap.get(this.constants.CUSTOM_LOGIC_MAP);
        customLogicMap.set(objectKey, selectedRule[this.constants.CUSTOM_LOGIC]);
    }

    updateFieldRowMap(rulesCriteriaMap, objectKey, fieldWrapper) {
        let fieldRowMap = rulesCriteriaMap.get(this.constants.FIELD_ROW_MAP);
        let fieldWrapperList = fieldRowMap.get(objectKey) || [];
        let fieldWrapperObj = this.getFieldWrapperObj(fieldWrapperList, fieldWrapper);
        
        if(!this.editMode) {
            fieldWrapperList.push(fieldWrapperObj);
        }
        fieldRowMap.set(objectKey, fieldWrapperList);
    }

    getFieldWrapperObj(fieldWrapperList, fieldWrapper) {
        let fieldWrapperObj = this.editMode ? fieldWrapperList[this.lastSelectedRule.ruleNum - 1] : {};
        fieldWrapperObj["type"] = fieldWrapper.type;
        fieldWrapperObj["name"] = fieldWrapper.name;
        fieldWrapperObj["label"] = fieldWrapper.label;
        fieldWrapperObj["value"] = fieldWrapper.value;
        return fieldWrapperObj;
    }

    handleRemoveRule(event) {
        event.stopPropagation();
        console.log('handleRemoveRule** '+ JSON.stringify(event.detail));
        const ruleNum = event.detail.ruleNum;
        const fieldKey = event.detail[this.constants.FIELD_KEY];
        const objectKey = event.detail[this.constants.OBJECT_KEY];
        const concatenatedKey = objectKey + fieldKey + ruleNum;

        let selectedRule = this.getSelectedObjectRules(objectKey);
        this.removeRuleCriteria(ruleNum, selectedRule);
        this.removeFromRuleCriteriaMap(this.rulesCriteriaMap, objectKey, concatenatedKey, ruleNum, selectedRule);
        this.clearEditModeIfNeeded(concatenatedKey);
        // this.logRules(); // only for debugging
    }

    removeRuleCriteria(ruleNum, selectedRule) {
        selectedRule[this.constants.RULES].splice(ruleNum - 1, 1);

        if(selectedRule[this.constants.RULES].length === 0) {
            selectedRule.customLogic = false;
            selectedRule[this.constants.RULE_LOGIC] = [];
        }else if(!selectedRule.customLogic) {
            selectedRule[this.constants.RULE_LOGIC] = this.getRuleLogic(selectedRule[this.constants.RULES]);
        }
    }

    removeFromRuleCriteriaMap(rulesCriteriaMap, objectKey, concatenatedKey, ruleNum, selectedRule) {
        if(!selectedRule.customLogic) {
            this.updateRuleLogicMap(rulesCriteriaMap, objectKey, selectedRule);
            this.updateCustomLogicMap(rulesCriteriaMap, objectKey, selectedRule);
        }
        this.removeFromFieldRowMap(rulesCriteriaMap, objectKey, ruleNum);
    }

    removeFromFieldRowMap(rulesCriteriaMap, objectKey, ruleNum) {
        let fieldWrapperList = rulesCriteriaMap.get(this.constants.FIELD_ROW_MAP).get(objectKey);
        fieldWrapperList.splice(ruleNum - 1, 1);
    }

    handleCustomLogic(event) {
        event.stopPropagation();
        console.log('event.detail** '+ JSON.stringify(event.detail));
        const objectKey = event.detail[this.constants.OBJECT_KEY];
        const customLogic = event.detail[this.constants.CUSTOM_LOGIC];

        let selectedRule = this.getSelectedObjectRules(objectKey);

        selectedRule[this.constants.CUSTOM_LOGIC] = customLogic;
        this.updateCustomLogicMap(this.rulesCriteriaMap, objectKey, selectedRule);

        if(!customLogic) {
            selectedRule[this.constants.RULE_LOGIC] = this.getRuleLogic(selectedRule[this.constants.RULES]);
            this.updateRuleLogicMap(this.rulesCriteriaMap, objectKey, selectedRule);
        }
        // this.logRules(); // only for debugging
    }

    handleEditRule(event) {
        event.preventDefault();
        this.showSpinner = true;
        this.editMode = true;
        this.clearLastSelectedRule();
       // console.log('**** '+JSON.stringify(event.detail));
        this.displaySelectedRuleDetails(event.detail);        
        this.toggleObjectCombobox(true);
        this.showSpinner = false;
        // this.logRules(); // only for debugging
    }

    clearLastSelectedRule() {
        if(this.lastSelectedRule != undefined && this.lastSelectedRule != "") {
            const selectedRulesCmp = this.template.querySelector("[data-id=" + this.lastSelectedRule.objectKey + "]");
            selectedRulesCmp?.clearRuleSelection(this.lastSelectedRule.fieldKey);
        }
    }

    displaySelectedRuleDetails(selectedRule) {
        this.lastSelectedRule = selectedRule;
        this.displaySelectedRuleObject(selectedRule);
        this.displaySelectedRuleField(selectedRule);
        this.displaySelectedRuleOperator(selectedRule);
        this.displaySelectedRuleValue(selectedRule);
    }

    displaySelectedRuleObject(selectedRule) {
        this.selectedObject = selectedRule.objectKey;
        this.fieldOptions = this.fieldMap.get(this.selectedObject);
    }

    displaySelectedRuleField(selectedRule) {
        this.selectedField = selectedRule.fieldKey;
        this.selectedFieldWrapper = this.fieldWrapperMap.get(this.selectedObject + this.selectedField);
        this.operatorOptions = this.operatorsMap.get(this.selectedFieldWrapper.type);
    }

    displaySelectedRuleOperator(selectedRule) {
        const selectedObjectRule = this.getSelectedObjectRules(selectedRule.objectKey);
        console.log('selectedObjectRule** '+JSON.stringify(selectedObjectRule));
        this.selectedOperator = selectedObjectRule[this.constants.RULES][selectedRule.ruleNum - 1][this.constants.OPERATOR_KEY];
    }

    displaySelectedRuleValue(selectedRule) {
        const selectedObjectRule = this.getSelectedObjectRules(selectedRule.objectKey);
        this.selectedValue = selectedObjectRule[this.constants.RULES][selectedRule.ruleNum - 1][this.constants.FIELD_VAL];
        const ruleValueCmp = this.template.querySelector("c-mads-rules-criteria-value");
        ruleValueCmp.setFieldValue(this.selectedOperator, this.selectedValue, this.selectedFieldWrapper);
    }

    toggleObjectCombobox(disabled) {
        this.template.querySelector("[data-id='rulesObjCombobox']").disabled = disabled;
    }

    handleClearEditMode(event) {
        event.preventDefault();
        this.cleanUpEditMode();
    }

    cleanUpEditMode() {
        this.editMode = false;
        this.lastSelectedRule = undefined;
        this.setFieldCombobox();
        this.resetFieldValue(false);
        this.toggleObjectCombobox(false);
    }

    clearEditModeIfNeeded(concatenatedKey) {
        if(this.lastSelectedRule != undefined && this.lastSelectedRule != "" && this.matchFound(concatenatedKey, this.lastSelectedRule)) {
            this.cleanUpEditMode();
        }
    }

    matchFound(concatenatedKey, lastSelectedRule) {
        const ruleConcatenatedKey = lastSelectedRule.objectKey + lastSelectedRule.fieldKey + lastSelectedRule.ruleNum;
        return (concatenatedKey === ruleConcatenatedKey);
    }

    @api
    getRulesCriteriaJSON() {
        this.updateOperatorAndFieldValueMap();        
        const fieldValueMapSize = this.rulesCriteriaMap.get(this.constants.FIELD_VALUE_MAP).size;
        return (fieldValueMapSize > 0) ? this.convertRulesCriteriaMapToJSON() : undefined;
    }

    updateOperatorAndFieldValueMap() {
        let fieldValueMap = new Map();
        let fieldOperatorMap = new Map();

        this.selectedRules.forEach((selectedObjectRule) => {
            const objectKey = selectedObjectRule[this.constants.OBJECT_KEY];
            selectedObjectRule[this.constants.RULES].forEach((rule, ruleIndex) => {
                const concatenatedId = objectKey + rule[this.constants.FIELD_KEY] + (ruleIndex + 1);
                fieldValueMap.set(concatenatedId, rule[this.constants.FIELD_VAL]);
                fieldOperatorMap.set(concatenatedId, rule[this.constants.OPERATOR_KEY]);
            });
        });

        this.rulesCriteriaMap.set(this.constants.FIELD_VALUE_MAP, fieldValueMap);
        this.rulesCriteriaMap.set(this.constants.FIELD_OPERATOR_MAP, fieldOperatorMap);
    }

    convertRulesCriteriaMapToJSON() {
        let rulesCriteriaJSON = {};
        this.rulesCriteriaMap.forEach((ruleCriteriaWrapperMap, ruleCriteriaWrapperKey) => {
            rulesCriteriaJSON[ruleCriteriaWrapperKey] = Object.fromEntries([...ruleCriteriaWrapperMap]);
        });
        return rulesCriteriaJSON;
    }

    @api
    getCustomLogicValidityFor(objectKey) {
        const selectedRulesCmp = this.template.querySelector("[data-id=" + objectKey + "]");
        return (selectedRulesCmp === undefined) ? "" : selectedRulesCmp?.getCustomRuleLogicValidity();
    }

    @api
    clearCustomLogicValidityFor(objectKey) {
        const selectedRulesCmp = this.template.querySelector("[data-id=" + objectKey + "]");
        return (selectedRulesCmp === undefined) ? [] : selectedRulesCmp?.clearCustomLogicValidity();
    }

    @api
    getCustomLogicFor(objectKey) {
        const selectedRulesCmp = this.template.querySelector("[data-id=" + objectKey + "]");
        return (selectedRulesCmp === undefined) ? [] : selectedRulesCmp?.getCustomRuleLogic();
    }

    @api
    reportCustomLogicValidityFor(objectKey, customLogicValidity) {
        this.template.querySelector("[data-id=" + objectKey + "]")?.reportCustomRuleLogicValidity(customLogicValidity);
    }

    // only added for debugging
    logRules() {
        console.log("selectedRules : " + JSON.stringify(this.selectedRules));
        this.rulesCriteriaMap.forEach((valMap, key) => {
            console.log(key + " => " + JSON.stringify(Object.fromEntries([...valMap])));
        });
    }
}