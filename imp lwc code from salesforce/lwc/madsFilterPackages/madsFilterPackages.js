/**
 * W-12456764
 * Creates Combobox to displays list of available Master Packages to copy from.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         10/02/2023      Chakshu Malhotra        W-12456764 - Adds combobox with available Master Packages and dispatches event on selection of Master Package.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api } from 'lwc';
import masterPackagesStr from '@salesforce/label/c.MA_DS_Master_Packages';

export default class MadsFilterPackages extends LightningElement {

    @api masterPackagesMap;

    masterPackageOptions;
    selectedMasterPackage;

    label = {
        masterPackagesStr
    };

    connectedCallback() {
        this.masterPackageOptions = Array.from(this.masterPackagesMap.values());
        this.selectedMasterPackage = this.masterPackageOptions[0].value;
    }

    changeHandler(event) {
        event.preventDefault();
        this.selectedMasterPackage = event.detail.value;
        this.dispatchEvent(new CustomEvent("changed", {detail: this.selectedMasterPackage}));
    }
}