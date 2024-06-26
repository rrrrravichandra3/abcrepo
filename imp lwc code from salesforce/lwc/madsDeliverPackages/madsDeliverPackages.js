/**
 * W-13465459
 * LWC headless quick action, to Deliver Packages for all the eligible / selected / individual Package Distribution(s) related to the Acquisition Company record.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         26/05/2023      Chakshu Malhotra        W-13465459 - Adds logic to initiate processing of Package Delivery by invoking Apex Controller. 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

import { reduceErrors } from 'c/maErrorHandlingUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import deliverPackages from '@salesforce/apex/MA_DS_DeliverPackages.deliverPackages';
import { RefreshEvent } from "lightning/refresh";

export default class MadsDeliverPackages extends LightningElement {
    @api recordId;
    showSpinner = true;

    @api invoke() {
        this.deliverPackages();
    }

    async deliverPackages() {
        try {
            let responseWrapper = await deliverPackages({recordId: this.recordId});

            if(responseWrapper.isError) {
                this.showErrorMessage(responseWrapper.errorMessage);
            }else if(responseWrapper.statusMessage) {
                this.showSuccessMessage(responseWrapper.statusMessage);
            }
        }catch(error) {
            this.showAuraHandledException(error);
        }finally {
            this.showSpinner = false;
            this.refreshViewAndCloseAction();
        }
    }

    showSuccessMessage(statusMessage) {
        this.dispatchEvent(new ShowToastEvent({"title" : "Success!", "message" : statusMessage, "variant" : "success"}));
    }

    showErrorMessage(errorMessage) {
        this.dispatchEvent(new ShowToastEvent({"title": "Error", "message": errorMessage, "variant": "error", "mode": "sticky"}));
    }

    showAuraHandledException(error) {
        this.dispatchEvent(new ShowToastEvent({"title": "Error", "message": reduceErrors(error), "variant": "error", "mode": "sticky"}));
    }

    refreshViewAndCloseAction() {
        this.dispatchEvent(new RefreshEvent());
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}