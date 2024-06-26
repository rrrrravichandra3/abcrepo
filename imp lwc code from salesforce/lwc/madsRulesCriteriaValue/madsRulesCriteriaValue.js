/**
 * W-12578110
 * Shows UI to show Value component based on the type of the Field selected in the Combobox.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         13/03/2023      Chakshu Malhotra        W-12578110 - Adds & interacts with UI to show Value component based on the type of the Field selected in the Combobox.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire, track } from 'lwc';
import { rulesCriteriaValueConstants, rulesCriteriaValueLabels } from 'c/madsUtils';

export default class MadsRulesCriteriaValue extends LightningElement {
    @api operator;
    @api fieldWrapper;

    badInputMessage;
    selectedOptions;
    hasError;
    editMode;

    label = rulesCriteriaValueLabels;
    constants = rulesCriteriaValueConstants;

    constructor() {
        super();
        this.editMode = false;
        this.hasError = false;
        this.selectedOptions = [];
    }

    get fieldValue() {
        if(this._fieldValue === undefined) {
            this._fieldValue = this.constants.BLANK_LABEL;
        }
        return this._fieldValue;
    }set fieldValue(value) {
        this._fieldValue = value;
    }

    get isTextType() {
        if(this.fieldWrapper) {
            this._isTextType = (this.fieldWrapper.type === "STRING" || this.fieldWrapper.type === "TEXTAREA" || 
                                this.fieldWrapper.type === "REFERENCE" || this.fieldWrapper.type === "EMAIL" || 
                                this.fieldWrapper.type === "PHONE" || this.fieldWrapper.type === "URL");
        }
        return this._isTextType;
    }

    get isURLType() {
        if(this.fieldWrapper) {
            this._isURLType = (this.fieldWrapper.type === "URL");
        }
        return this._isURLType;
    }

    get isEmailType() {
        if(this.fieldWrapper) {
            this._isEmailType = (this.fieldWrapper.type === "EMAIL");
        }
        return this._isEmailType;
    }

    get isNumberType() {
        if(this.fieldWrapper) {
            this._isNumberType = (this.fieldWrapper.type === "DOUBLE" || this.fieldWrapper.type === "CURRENCY" || 
                                  this.fieldWrapper.type === "PERCENT");
        }
        return this._isNumberType;
    }

    get isDateType() {
        if(this.fieldWrapper) {
            this._isDateType = (this.fieldWrapper.type === "DATE");
        }
        return this._isDateType;
    }

    get isDatetimeType() {
        if(this.fieldWrapper) {
            this._isDatetimeType = (this.fieldWrapper.type === "DATETIME");
        }
        return this._isDatetimeType;
    }

    get isBooleanType() {
        if(this.fieldWrapper) {
            this._isBooleanType = (this.fieldWrapper.type === "BOOLEAN");
        }
        return this._isBooleanType;
    }

    get isPicklistType() {
        if(this.fieldWrapper) {
            this._isPicklistType = (this.fieldWrapper.type === "PICKLIST");
        }
        return this._isPicklistType;
    }

    get picklistOptions() {
        if(this.isPicklistType) {
            this._picklistOptions = Object.keys(this.fieldWrapper.picklistOptions).map((picklistOption) => ({
                "label": this.fieldWrapper.picklistOptions[picklistOption], "value": picklistOption
            }));
        }
        return this._picklistOptions;
    }set picklistOptions(value) {
        this._picklistOptions = value;
    }

    get isEqualsOrNotEquals() {
        if(this.operator) {
            this._isEqualsOrNotEquals = (this.operator === this.label.equalsOperator || this.operator === this.label.doesNotEqualOperator);
        }
        return this._isEqualsOrNotEquals;
    }

    @api
    resetFieldValue(handledOperatorChange) {
        this.fieldValue = "";
        this.hasError = false;
        this.editMode = false;
        const inputCmp = this.template.querySelector("[data-id='inputType']");

        if(this.isBooleanType) {
            this.setBooleanButtons();
        }else if(this.isPicklistType) {
            this.resetInputType(inputCmp);
            this.selectedOptions = handledOperatorChange ? this.selectedOptions : this.clearPicklistSelection();
        }else {
            this.resetInputType(inputCmp);
            inputCmp.value = handledOperatorChange ? inputCmp.value : "";
        }
    }

    setBooleanButtons() {
        this.template.querySelector("[data-id='trueBtn']").variant = "neutral";
        this.template.querySelector("[data-id='falseBtn']").variant = "brand";
    }

    resetInputType(inputCmp) {
        inputCmp.blur();
        inputCmp.className = inputCmp.className.replace(this.constants.ERROR_INPUT_CLASS, "");
    }

    clearPicklistSelection() {
        this.template.querySelector("c-mads-multiselect-combobox").clearSelection();
        return [];
    }

    handleTrueBtnClick(event) {
        event.preventDefault();
        this.toggleVariants(event.target, true);
    }

    handleFalseBtnClick(event) {
        event.preventDefault();
        this.toggleVariants(event.target, false);
    }

    toggleVariants(currentBtn, isTrueBtn) {
        const otherBtn = this.template.querySelector(isTrueBtn ? "[data-id='falseBtn']" : "[data-id='trueBtn']");
        otherBtn.variant = (otherBtn.variant === "brand") ? "neutral" : otherBtn.variant;
        currentBtn.variant = (currentBtn.variant === "neutral") ? "brand" : currentBtn.variant;
    }

    handleOptionSelection(event) {
        this.selectedOptions = event.detail;
    }

    @api
    getFieldValidity() {
        this.fieldValue = "";
        let fieldValidity = "";
        const inputCmp = this.template.querySelector("[data-id='inputType']");

        if(this.isBooleanType) {
            this.setBooleanFieldValue();
        }else if(this.isPicklistType) {
            fieldValidity = this.getPicklistValidity(inputCmp);
        }else {
            fieldValidity = this.getInputTypeValidity(inputCmp);
        }

        this.hasError = (fieldValidity != "");
        return fieldValidity;
    }

    setBooleanFieldValue() {
        const trueBtn = this.template.querySelector("[data-id='trueBtn']");
        this.fieldValue = (trueBtn.variant === "brand") ? this.label.booleanTrue : this.label.booleanFalse;
    }

    getPicklistValidity(inputCmp) {
        this.fieldValue = this.selectedOptions.map(selectedOption => selectedOption.value).join(",");
        const fieldValidity = (this.fieldValue != "") ? "" : this.label.picklistValidity;
        this.setErrorInputStyleIfInvalid(inputCmp, fieldValidity);
        return fieldValidity
    }

    getInputTypeValidity(inputCmp) {
        this.fieldValue = inputCmp.value?.replace(/\s+/g, " ")?.trim() || "";
        inputCmp.value = this.fieldValue;
        
        let fieldValidity = this.getMissingValueValidity(inputCmp);
        fieldValidity = (fieldValidity === "") ? this.getEmailValidity() : fieldValidity;
        
        this.setErrorInputStyleIfInvalid(inputCmp, fieldValidity);
        return fieldValidity;
    }

    getMissingValueValidity(inputCmp) {
        return (this.isEqualsOrNotEquals || this.getTrimmedFieldValue(inputCmp) != "") ? "" : this.label.missingValueValidity;
    }

    getTrimmedFieldValue(inputCmp) {
        this.fieldValue = this.fieldValue.split(",").map(fieldValStr => fieldValStr.trim()).filter(fieldValStr => fieldValStr != "").join();
        inputCmp.value = this.fieldValue;
        return this.fieldValue;
    }

    getEmailValidity() {
        let emailValidity = "";
        if(this.isEmailType && this.isEqualsOrNotEquals && this.fieldValue != "") {
            emailValidity = this.isValidEmail(this.fieldValue) ? "" : this.label.emailValidity;
        }
        return emailValidity;
    }

    isValidEmail(emailAddress) {
        const emailRegex = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return emailRegex.test(emailAddress.toLowerCase());
    }

    setErrorInputStyleIfInvalid(inputCmp, fieldValidity) {
        const cssClass = inputCmp.className.replace(this.constants.ERROR_INPUT_CLASS, "");
        inputCmp.className = (fieldValidity === "") ? cssClass : (cssClass + this.constants.ERROR_INPUT_CLASS);
    }

    @api
    getFieldValue() {
        return this.fieldValue;
    }

    @api
    setFieldValue(operator, fieldValue, fieldWrapper) {
        this.editMode = true;
        this.operator = operator;
        this.fieldValue = fieldValue;
        this.fieldWrapper = fieldWrapper;
    }

    renderFieldValues() {
        if(this.isBooleanType) {
            this.setBooleanButtonSelection();
        }else if(this.isPicklistType) {
            this.setSelectedPicklistOptions();
        }else {
            this.setSelectedInputTypeValue();
        }
    }

    setBooleanButtonSelection() {
        const fieldValueTrue = (this.fieldValue.toLowerCase() === "true");
        this.template.querySelector("[data-id='trueBtn']").variant = fieldValueTrue ? "brand" : "neutral";
        this.template.querySelector("[data-id='falseBtn']").variant = fieldValueTrue ? "neutral" : "brand";
    }

    setSelectedPicklistOptions() {
        const selectedOptionValues = this.fieldValue.split(",");
        this.selectedOptions = selectedOptionValues.map((selectedOption) => ({"label": selectedOption, "value": selectedOption, "selected": true}));
        this.template.querySelector("c-mads-multiselect-combobox").setCurrentOptionSelection(selectedOptionValues);
    }

    setSelectedInputTypeValue() {
        const inputCmp = this.template.querySelector("[data-id='inputType']");
        inputCmp.value = this.fieldValue;
    }

    renderedCallback() {
        this.template.addEventListener("click", (event) => {
            if(this.editMode) {
                event.stopPropagation();
            }
        });
        if(this.editMode) {
            this.renderFieldValues();
        }
    }
}