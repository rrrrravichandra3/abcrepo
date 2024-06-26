/**
 * W-12578110
 * Shows UI to add Audit Flags based on the selection of Object, Field, Operator & Value provided.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         11/03/2023      Chakshu Malhotra        W-12578110 - Adds & interacts with UI to provide Audit Flags based on the selection of Object, Field, Operator & Value provided.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire, track } from 'lwc';
import { auditFlagsTabConstants, auditFLagsTabLabels } from 'c/madsUtils';

export default class MadsAuditFlagsTab extends LightningElement {
    @api objectOptions;

    @api fieldMap; // sObjectName to List of Sorted Fields (label & value)
    @api auditFlagsMap; // contains "rulesFlagsJSON"
    @api maxSampleSize; // Maximum number of flags to be set on audit field
    @api fieldWrapperMap; // sObjectName + fieldKey to FieldWrapper

    @track selectedAuditFlags = []; // Object containing "objectLabel", "objectKey" & List of "audit flags"
    @track selectedFieldWrapper; // FieldWrapper type

    showSpinner;
    
    fieldOptions;
    selectedField;
    selectedObject;
    selectedSampleSize;

    editMode;
    lastSelectedAuditFlag;

    label = auditFLagsTabLabels;
    constants = auditFlagsTabConstants;

    constructor() {
        super();
        this.editMode = false;
        this.showSpinner = false;
    }

    get isValidAuditFlagsMap() {
        return (this.auditFlagsMap && this.auditFlagsMap.size > 0);
    }

    get auditButtonLabel() {
        return this.editMode ? "Update" : "Add";
    }

    get sampleSizeOptions() {
        if(this._sampleSizeOptions === undefined) {
            this._sampleSizeOptions = Array.from({"length": this.maxSampleSize}, (value, index) => index + 1);
            this._sampleSizeOptions = this._sampleSizeOptions.map((sampleSize) => ({"label": `${sampleSize}`, "value": `${sampleSize}`}));
        }
        return this._sampleSizeOptions;
    }

    connectedCallback() {
        this.setObjectCombobox();
        this.setSelectedAuditFlags();
    }

    setObjectCombobox() {
        this.selectedObject = this.objectOptions[0].value;
        this.setFieldCombobox();
    }

    setFieldCombobox() {
        this.fieldOptions = this.fieldMap.get(this.selectedObject);
        this.selectedField = this.fieldOptions[0].value;
        this.setSampleSizeCombobox();
    }

    setSampleSizeCombobox() {
        this.selectedFieldWrapper = this.fieldWrapperMap.get(this.selectedObject + this.selectedField);
        this.selectedSampleSize = this.sampleSizeOptions[0].value;
    }

    setSelectedAuditFlags() {
        this.objectOptions.forEach((objectOption) => {
            let selectedAuditFlag = this.initSelectedAuditFlag(objectOption);
            let hasAuditFlagsForObject = this.hasAuditFlagsForObject(objectOption.value);
            selectedAuditFlag[this.constants.RULES] = hasAuditFlagsForObject ? this.initAuditFlags(objectOption.value) : [];
            this.selectedAuditFlags.push(selectedAuditFlag);
        });
    }

    initSelectedAuditFlag(objectOption) {
        let selectedRule = {};
        selectedRule[this.constants.OBJECT_KEY] = objectOption.value;
        selectedRule[this.constants.OBJECT_LABEL] = objectOption.label;
        return selectedRule;
    }

    hasAuditFlagsForObject(objectKey) {
        return (this.isValidAuditFlagsMap && this.auditFlagsMap.has(objectKey));
    }

    initAuditFlags(objectKey) {
        let auditFlags = [];
        this.auditFlagsMap.get(objectKey).forEach((fieldWrapper, fieldKey) => {
            auditFlags.push(this.initAuditFlag(objectKey, fieldKey, fieldWrapper));
        });
        return auditFlags;
    }

    initAuditFlag(objectKey, fieldKey, fieldWrapper) {
        const auditFlag = {};
        const fieldWrapperMapKey = objectKey + fieldKey;
        auditFlag[this.constants.SAMPLE_SIZE] = fieldWrapper.sampleSize;
        auditFlag[this.constants.FIELD_KEY] = this.fieldWrapperMap.get(fieldWrapperMapKey).value;
        auditFlag[this.constants.FIELD_LABEL] = this.fieldWrapperMap.get(fieldWrapperMapKey).label;
        return auditFlag;
    }

    objectChangeHandler(event) {
        event.preventDefault();
        this.showSpinner = true;

        setTimeout(() => {
            this.selectedObject = event.detail.value;
            this.setFieldCombobox();
            this.showSpinner = false;
        }, 0);
    }

    fieldChangeHandler(event) {
        event.preventDefault();
        this.showSpinner = true;

        setTimeout(() => {
            this.selectedField = event.detail.value;
            this.setSampleSizeCombobox();
            this.showSpinner = false;
        }, 0);
    }

    sampleSizeChangeHandler(event) {
        event.preventDefault();
        this.selectedSampleSize = event.detail.value;
    }

    handleAuditButtonClick(event) {
        event.preventDefault();
        this.handleAddOrUpdateAuditFlag();

        if(this.editMode) {
            this.cleanUpEditMode();
        }else {
            this.setFieldCombobox();
        }
    }

    handleAddOrUpdateAuditFlag() {
        this.updateSelectedFieldWrapper();
        this.updateAuditFlag();
        this.updateAuditFlagsMap();    
        //this.logFlags(); // only for debugging    
    }

    updateSelectedFieldWrapper() {
        this.selectedFieldWrapper.sampleSize = parseInt(this.selectedSampleSize);
    }

    updateAuditFlag() {
        let selectedAuditFlag = this.getSelectedObjectAuditFlags(this.selectedObject);
        const auditFlagIndex = this.getAuditFlagIndex(selectedAuditFlag, this.selectedField);
        let auditFlag = this.getAuditFlag(auditFlagIndex, selectedAuditFlag, this.selectedFieldWrapper, parseInt(this.selectedSampleSize));

        if(auditFlagIndex === -1) {
            selectedAuditFlag[this.constants.RULES].push(auditFlag);
        }
    }

    getSelectedObjectAuditFlags(objectKey) {
        return this.selectedAuditFlags.find(selectedObjectAuditFlag => selectedObjectAuditFlag[this.constants.OBJECT_KEY] === objectKey);
    }

    getAuditFlagIndex(selectedAuditFlag, fieldKey) {
        return this.editMode ? (this.lastSelectedAuditFlag.ruleNum - 1) : 
               selectedAuditFlag[this.constants.RULES].findIndex(auditFlag => auditFlag[this.constants.FIELD_KEY] === fieldKey);
    }

    getAuditFlag(auditFlagIndex, selectedAuditFlag, selectedFieldWrapper, selectedSampleSize) {
        let auditFlag = (auditFlagIndex === -1) ? {} : selectedAuditFlag[this.constants.RULES][auditFlagIndex];
        auditFlag[this.constants.SAMPLE_SIZE] = selectedSampleSize;
        auditFlag[this.constants.FIELD_KEY] = selectedFieldWrapper.value;
        auditFlag[this.constants.FIELD_LABEL] = selectedFieldWrapper.label;
        return auditFlag;
    }

    updateAuditFlagsMap() {
        this.auditFlagsMap = (this.auditFlagsMap === undefined) ? new Map() : this.auditFlagsMap;
        let fieldWrapperMap = this.auditFlagsMap.get(this.selectedObject) || new Map();

        if(this.editMode && this.selectedField != this.lastSelectedAuditFlag[this.constants.FIELD_KEY]) {
            fieldWrapperMap.delete(this.lastSelectedAuditFlag[this.constants.FIELD_KEY]);
        }

        let fieldWrapperObj = this.getFieldWrapper(fieldWrapperMap);
        fieldWrapperMap.set(this.selectedField, fieldWrapperObj);
        this.auditFlagsMap.set(this.selectedObject, fieldWrapperMap);
    }

    getFieldWrapper(fieldWrapperMap) {
        let fieldWrapperObj = fieldWrapperMap.get(this.selectedField) || {};
        fieldWrapperObj[this.constants.TYPE] = this.selectedFieldWrapper.type;
        fieldWrapperObj[this.constants.SAMPLE_SIZE] = parseInt(this.selectedSampleSize);
        return fieldWrapperObj;
    }

    handleRemoveAuditFlag(event) {
        event.stopPropagation();
        const auditFlagIndex = event.detail.ruleNum - 1;
        const fieldKey = event.detail[this.constants.FIELD_KEY];
        const objectKey = event.detail[this.constants.OBJECT_KEY];

        let selectedAuditFlag = this.getSelectedObjectAuditFlags(objectKey);
        this.removeAuditFlag(selectedAuditFlag, auditFlagIndex);
        this.removeFromAuditFlagsMap(objectKey, fieldKey);
        this.updateFieldWrapperMap(objectKey, fieldKey);
        this.clearEditModeIfNeeded(objectKey, fieldKey);
        // this.logFlags(); // only for debugging
    }

    removeAuditFlag(selectedAuditFlag, auditFlagIndex) {
        selectedAuditFlag[this.constants.RULES].splice(auditFlagIndex, 1);
    }

    removeFromAuditFlagsMap(objectKey, fieldKey) {
        this.auditFlagsMap.get(objectKey).delete(fieldKey);
    }

    updateFieldWrapperMap(objectKey, fieldKey) {
        let fieldWrapper = this.fieldWrapperMap.get(objectKey + fieldKey);
        fieldWrapper.sampleSize = 0;
    }

    handleEditAuditFlag(event) {
        event.preventDefault();
        this.showSpinner = true;
        this.editMode = true;
        this.clearLastSelectedAuditFlag();
        this.displaySelectedAuditFlagDetails(event.detail);
        this.toggleObjectCombobox(true);
        this.showSpinner = false;
        // this.logFlags(); // only for debugging
    }

    clearLastSelectedAuditFlag() {
        if(this.lastSelectedAuditFlag != undefined && this.lastSelectedAuditFlag != "") {
            const selectedAuditFlagCmp = this.template.querySelector("[data-id=" + this.lastSelectedAuditFlag.objectKey + "]");
            selectedAuditFlagCmp?.clearRuleSelection(this.lastSelectedAuditFlag.fieldKey);
        }
    }

    displaySelectedAuditFlagDetails(selectedAuditFlag) {
        this.lastSelectedAuditFlag = selectedAuditFlag;
        this.displaySelectedAuditFlagObject(selectedAuditFlag);
        this.displaySelectedAuditFlagField(selectedAuditFlag);
        this.displaySelectedAuditFlagSampleSize(selectedAuditFlag);
    }

    displaySelectedAuditFlagObject(selectedAuditFlag) {
        this.selectedObject = selectedAuditFlag.objectKey;
        this.fieldOptions = this.fieldMap.get(this.selectedObject);
    }

    displaySelectedAuditFlagField(selectedAuditFlag) {
        this.selectedField = selectedAuditFlag.fieldKey;
        this.selectedFieldWrapper = this.fieldWrapperMap.get(this.selectedObject + this.selectedField);
    }

    displaySelectedAuditFlagSampleSize(selectedAuditFlag) {
        this.selectedSampleSize = `${this.auditFlagsMap.get(selectedAuditFlag.objectKey).get(selectedAuditFlag.fieldKey).sampleSize}`;
    }

    toggleObjectCombobox(disabled) {
        this.template.querySelector("[data-id='flagsObjCombobox']").disabled = disabled;
    }

    handleClearEditMode(event) {
        event.preventDefault();
        this.cleanUpEditMode();
    }

    cleanUpEditMode() {
        this.editMode = false;
        this.lastSelectedAuditFlag = undefined;
        this.setFieldCombobox();
        this.toggleObjectCombobox(false);
    }

    clearEditModeIfNeeded(objectKey, fieldKey) {
        if(this.lastSelectedAuditFlag != undefined && this.lastSelectedAuditFlag != "" && this.matchFound(objectKey, fieldKey, this.lastSelectedAuditFlag)) {
            this.cleanUpEditMode();
        }
    }

    matchFound(objectKey, fieldKey, lastSelectedAuditFlag) {
        return (objectKey === lastSelectedAuditFlag.objectKey && fieldKey === lastSelectedAuditFlag.fieldKey);
    }
    
    @api
    getAuditFlagsJSON() {
        const auditFlagsMapSize = this.auditFlagsMap.size;
        return (auditFlagsMapSize > 0) ? this.convertAuditFlagsMapToJSON() : undefined;
    }

    convertAuditFlagsMapToJSON() {
        let auditFlagsJSON = {};
        this.auditFlagsMap.forEach((auditFlagsFieldMap, objectKey) => {
            auditFlagsJSON[objectKey] = Object.fromEntries([...auditFlagsFieldMap]);
        });
        return auditFlagsJSON;
    }

    // only added for debugging
    logFlags() {
        console.log("selectedAuditFlags : " + JSON.stringify(this.selectedAuditFlags));
        this.auditFlagsMap.forEach((valMap, key) => {
            console.log(key + " => " + JSON.stringify(Object.fromEntries([...valMap])));
        });
    }
}