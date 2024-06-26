/**
 * W-12578110
 * Shows Items (selected / unselected) within the multi-select combobox for Picklist type field.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         14/03/2023      Chakshu Malhotra        W-12578110 - Adds & interacts with UI to show Items (selected / unselected) within the multi-select combobox for Picklist type field.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { api, LightningElement } from 'lwc';

export default class MadsMultiselectComboboxItem extends LightningElement {
    @api item;

    get itemClass() {
        return `slds-listbox__item ${this.item.selected ? 'slds-is-selected' : ''}`;
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('change', {detail: {"item": this.item, "selected": !this.item.selected}}));
    }
}