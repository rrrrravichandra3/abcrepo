/**
 * W-12578110
 * Creates multi-select combobox for selection of multiple options of Picklist type field.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         14/03/2023      Chakshu Malhotra        W-12578110 - Adds & interacts with multi-select combobox for selection of multiple options of Picklist type field.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { api, LightningElement, track } from 'lwc';
import { multiselectComboboxConstants } from 'c/madsUtils';

export default class MadsMultiselectCombobox extends LightningElement {
    @api disabled = false;
    @api label = '';
    @api name;
    @api options = [];
    @api placeholder = 'Select an Option';
    @api readOnly = false;
    @api required = false;
    @api singleSelect = false;
    @api showPills = false;
    @api hasError = false;

    @track currentOptions = [];

    selectedItems = [];
    selectedOptions = [];
    isInitialized = false;
    isLoaded = false;
    isVisible = false;
    isDisabled = false;

    constants = multiselectComboboxConstants;

    get inputClassList() {
        return this.hasError ? (this.constants.INPUT_CLASS + this.constants.ERROR_BORDER_CLASS) : this.constants.INPUT_CLASS;
    }

    connectedCallback() {
        this.isDisabled = this.disabled || this.readOnly;
        this.hasPillsEnabled = this.showPills && !this.singleSelect;
    }

    renderedCallback() {
        if(!this.isInitialized) {
            this.template.querySelector('.multi-select-combobox__input').addEventListener('click', (event) => {
                this.handleClick(event.target);
                event.stopPropagation();
            });
            this.template.addEventListener('click', (event) => {
                event.stopPropagation();
            });
            document.addEventListener('click', () => {
                this.close();
            });
            this.isInitialized = true;
            this.setSelection();
        }
    }

    handleChange(event) {
        this.change(event);
    }

    handleRemove(event) {
        this.selectedOptions.splice(event.detail.index, 1);
        this.change(event);
    }

    handleClick() {
        // initialize picklist options on first click to make them editable
        if(this.isLoaded === false) {
            this.currentOptions = JSON.parse(JSON.stringify(this.options));
            this.isLoaded = true;
        }

        if(this.template.querySelector('.slds-is-open')) {
            this.close();
        }else {
            this.template.querySelectorAll('.multi-select-combobox__dropdown').forEach((node) => {
                node.classList.add('slds-is-open');
            });
        }
    }

    change(event) {
        // remove previous selection for single select picklist
        if(this.singleSelect) {
            this.currentOptions.forEach((item) => (item.selected = false));
        }

        // set selected items
        this.currentOptions.filter((item) => item.value === event.detail.item.value).forEach((item) => (item.selected = event.detail.selected));
        
        this.setSelection();
        const selection = this.getSelectedItems();
        this.dispatchEvent(new CustomEvent('change', {detail: this.singleSelect ? selection[0] : selection}));
        
        // for single select picklist close dropdown after selection is made
        if(this.singleSelect) {
            this.close();
        }
    }

    close() {
        this.template.querySelectorAll('.multi-select-combobox__dropdown').forEach((node) => {
            node.classList.remove('slds-is-open');
        });
        this.dispatchEvent(new CustomEvent('close'));
    }

    setSelection() {
        const selectedItems = this.getSelectedItems();
        let selection = '';
        if(selectedItems.length < 1) {
            selection = this.placeholder;
            this.selectedOptions = [];
        }else if(selectedItems.length > 1) {
            selection = `${selectedItems.length} Options Selected`;
            this.selectedOptions = this.getSelectedItems();
        }else {
            selection = selectedItems.map((selected) => selected.label).join(', ');
            this.selectedOptions = this.getSelectedItems();
        }

        this.selectedItems = selection;
        this.isVisible = this.selectedOptions && this.selectedOptions.length > 0;
    }

    getSelectedItems() {
        return this.currentOptions.filter((item) => item.selected);
    }

    @api
    clearSelection() {
        this.currentOptions.forEach((currentOption) => {
            currentOption.selected = false;
        });
        this.setSelection();
        this.close();
    }

    @api
    setCurrentOptionSelection(selectedOptions) {
        const selectedOptionSet = new Set(selectedOptions);
        this.currentOptions = JSON.parse(JSON.stringify(this.options));

        this.currentOptions.forEach((currentOption) => {
            currentOption.selected = selectedOptionSet.has(currentOption.value);
        });
        
        this.setSelection();
        this.isLoaded = true;
    }
}