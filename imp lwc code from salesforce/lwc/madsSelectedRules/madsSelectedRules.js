/**
 * W-12578110
 * Creates UI to show Selected Rules / Audit Flags within a scrollable box component.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         15/03/2023      Chakshu Malhotra        W-12578110 - Adds & interacts with UI to show Selected Rules / Audit Flags within a scrollable box component.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire, track } from 'lwc';
import { selectedRulesConstants, selectedRulesLabels, validateRuleLogic, getRuleLogicArray } from 'c/madsUtils'

export default class MadsSelectedRules extends LightningElement {
    @api objectKey;
    @api customLogic = false;
    @api rulesCriteria = false;

    @api get rules() {
        return this._rules.map((rule, index) => ({...rule, "ruleNum": `${index + 1}.`}));
    }set rules(value) {
        this._rules = value;
    }

    @api get ruleLogic() {
        return this._ruleLogic.join(" ");
    }set ruleLogic(value) {
        this._ruleLogic = value;
    }

    customRuleLogic;
    selectedRuleFieldKey;
    addRuleLogicClicked = false;

    labels = selectedRulesLabels;
    constants = selectedRulesConstants;

    get ruleItemClassList() {
        return this.constants.RULE_COMMON_CLASSES + (this.customLogic ? this.constants.RULE_WITH_CUSTOM_LOGIC_CLASS : this.constants.RULE_WITH_NO_CUSTOM_LOGIC_CLASS);
    }

    get displayAddRuleLogic() {
        return (this.rulesCriteria && this.rules && this.rules.length > 0);
    }

    connectedCallback() {
        this.customRuleLogic = this.customLogic ? this.ruleLogic : this.customRuleLogic;
    }

    renderedCallback() {
        if(this.addRuleLogicClicked) {
            this.template.querySelector("[data-id='ruleLogic']").scrollIntoView({"behavior": "smooth", "block": "end"});
            this.addRuleLogicClicked = false;
        }
    }

    handleAddRuleLogic(event) {
        event.preventDefault();
        this.customLogic = true;
        this.addRuleLogicClicked = true;
        this.customRuleLogic = this.ruleLogic;
        this.dispatchCustomLogicEvent();
    }

    dispatchCustomLogicEvent() {
        const eventDetail = {"objectKey": this.objectKey, "customLogic": this.customLogic};
        this.dispatchEvent(new CustomEvent("customlogic", {"detail": eventDetail, "bubbles": true, "composed": true}));
    }

    handleRemoveRuleLogic(event) {
        event.preventDefault();
        this.customLogic = false;
        this.clearCustomLogicValidity();
        this.dispatchCustomLogicEvent(this.customLogic);
    }

    @api
    clearRuleSelection(lastSelectedRuleField) {
        if(lastSelectedRuleField != undefined && lastSelectedRuleField != "") {
            const selectedRuleTile = this.template.querySelector("[data-id=" + lastSelectedRuleField + "]");
            selectedRuleTile?.clearRuleSelection();
        }
    }

    @api
    getCustomRuleLogicValidity() {
        this.customRuleLogic = this.template.querySelector("[data-id='ruleLogic']").value;
        return validateRuleLogic(this.customRuleLogic, this.rules.length);
    }

    @api
    clearCustomLogicValidity() {
        const customRuleLogicCmp = this.template.querySelector("[data-id='ruleLogic']");
        customRuleLogicCmp.setCustomValidity("");
        customRuleLogicCmp.reportValidity();
    }

    @api
    getCustomRuleLogic() {
        return getRuleLogicArray(this.customRuleLogic);
    }

    @api
    reportCustomRuleLogicValidity(customLogicValidity) {
        const customRuleLogicCmp = this.template.querySelector("[data-id='ruleLogic']");
        customRuleLogicCmp.setCustomValidity(customLogicValidity);
        customRuleLogicCmp.reportValidity();
        this.scrollToBottomCmp();
    }

    scrollToBottomCmp() {
        this.template.querySelector("[data-id='scrollToBottomCmp']").scrollIntoView({"behavior": "smooth", "block": "end"});
    }
}