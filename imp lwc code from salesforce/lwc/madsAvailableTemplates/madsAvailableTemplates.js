/**
 * W-12456764
 * Creates custom table data to display rows of available Master Templates to copy from. Also displays templates that are already copied.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         13/02/2023      Chakshu Malhotra        W-12456764 - Adds Table Header & Rows to display Templates data. Dispatches events on selection of single, multiple or all rows.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, track } from 'lwc';
import templateNameHeader from '@salesforce/label/c.MA_DS_Header_Template_Name';
import documentTypeHeader from '@salesforce/label/c.MA_DS_Header_Document_Type';
import mergeCapableHeader from '@salesforce/label/c.MA_DS_Header_Merge_Capable';
import templateCopiedHeader from '@salesforce/label/c.MA_DS_Header_Template_Copied';

export default class MadsAvailableTemplates extends LightningElement {

    @api disabledAllRows;
    @track availableTemplates;

    totalSelectedTemplates;

    @api
    get availableTemplatesMap() {
        return this._availableTemplatesMap;
    }
    set availableTemplatesMap(_availableTemplatesMap) {
        if(_availableTemplatesMap) {
            this._availableTemplatesMap = _availableTemplatesMap;
            this.availableTemplates = Array.from(_availableTemplatesMap.values());
        }
    }

    constructor() {
        super();
        this.disabledAllRows = false;
        this.availableTemplates = [];
        this.columnHeadersLabels = [templateNameHeader, documentTypeHeader, mergeCapableHeader, templateCopiedHeader];
    }

    get columnHeaders() {
        if(this._columnHeaders === undefined) {
            this._columnHeaders = [];
            this.columnHeadersLabels.forEach((columnHeaderLabel, columnHeaderLabelIndex) => {
                let headerStyleClass = "col-" + (columnHeaderLabelIndex + 2) + "-style";
                this._columnHeaders.push({"headerLabel": columnHeaderLabel, "headerStyleClass":headerStyleClass});
            });
        }
        return this._columnHeaders;
    }

    handleSelectAllChange(event) {
        event.preventDefault();
        let allRowsSelected = event.target.checked;

        this.availableTemplates.forEach((availableTemplate) => {
            if(!availableTemplate.disabled) {
                availableTemplate.selected = allRowsSelected;
                this.totalSelectedTemplates += (availableTemplate.selected ? 1 : -1);
                this.template.querySelector(`[data-id="${availableTemplate.concatenatedId}"]`).checked = allRowsSelected;
            }
        });

        this.dispatchEvent(new CustomEvent("allrowselect", {detail: {"allRowsSelected": allRowsSelected}}));
    }

    handleSelectChange(event) {
        event.preventDefault();
        let rowSelected = event.target.checked;
        this.totalSelectedTemplates += (rowSelected ? 1 : -1);
        this.renderSelectAllRowsSelection();
        this.dispatchEvent(new CustomEvent("rowselect", {detail: {"concatenatedId": event.target.dataset.id, "rowSelected": rowSelected}}));
    }

    renderedCallback() {
        this.totalSelectedTemplates = 0;

        this.availableTemplates.forEach((availableTemplate) => {
            let selectTemplateElement = this.template.querySelector(`[data-id="${availableTemplate.concatenatedId}"]`);
            selectTemplateElement.checked = availableTemplate.selected;
            selectTemplateElement.disabled = availableTemplate.disabled;

            if(availableTemplate.selected) {
                this.totalSelectedTemplates++;
            }
        });

        this.renderSelectAllRowsSelection();
    }

    renderSelectAllRowsSelection() {
        let selectAllRowsElement = this.template.querySelector("lightning-input[data-name=select-all]");
        selectAllRowsElement.disabled = this.disabledAllRows;
        selectAllRowsElement.checked = this.disabledAllRows || (this.availableTemplates.length === this.totalSelectedTemplates);
    }

    disconnectedCallback() {
        this.availableTemplates = [];
    }
}