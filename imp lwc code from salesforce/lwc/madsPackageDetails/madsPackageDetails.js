/**
 * W-12456764
 * Creates two-column Detail section for the selected Package in the combobox.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         11/02/2023      Chakshu Malhotra        W-12456764 - Adds section to display name, description, available number of templates adn other detials of the selected Package.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api } from 'lwc';

import packageNameStr from '@salesforce/label/c.MA_DS_Package_Name';
import isPackageCopiedStr from '@salesforce/label/c.MA_DS_Package_Copied';
import derivedTemplatesStr from '@salesforce/label/c.MA_DS_Derived_Templates';
import availableTemplatesStr from '@salesforce/label/c.MA_DS_Available_Templates';
import packageDescriptionStr from '@salesforce/label/c.MA_DS_Package_Description';
import derivedPackageDistributionsStr from '@salesforce/label/c.MA_DS_Derived_Package_Distributions';

export default class MadsPackageDetails extends LightningElement {

    @api packageName;
    @api packageDescription;
    @api derivedTemplatesCount;
    @api availableTemplatesCount;
    @api derivedDistributionsCount;

    @api
    get isPackageCopied() {
        return this._isPackageCopied;
    }
    set isPackageCopied(packageCopied) {
        this._isPackageCopied = (packageCopied == true) ? 'Yes' : 'No';
    }

    label = {
        packageNameStr,
        isPackageCopiedStr,
        derivedTemplatesStr,
        availableTemplatesStr,
        packageDescriptionStr,
        derivedPackageDistributionsStr
    };
}