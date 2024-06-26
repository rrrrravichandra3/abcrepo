/**
 * W-13484430 & W-13576017
 * LWC headless quick action, to Recall Packages related to the Package Distribution.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/06/2023      Chakshu Malhotra        W-13484430 & W-13576017 - Adds logic to initiate the Mass Recall process by invoking Apex Controller. 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

import { recallPackagesLabels } from 'c/madsUtils';
import { reduceErrors } from 'c/maErrorHandlingUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import LightningConfirm from 'lightning/confirm';
import recallPackages from '@salesforce/apex/MA_DS_RecallPackages.recallPackages';
import { RefreshEvent } from "lightning/refresh";

export default class MadsRecallPackages extends LightningElement {
    @api recordId;
    showSpinner = true;
    label = recallPackagesLabels;

    @api invoke() {
        this.confirmRecallPackages().then((confirmed) => {
            if(confirmed) {
                this.recallPackages();
            }else {
                this.showSpinner = false;
            }
        });
    }

    async confirmRecallPackages() {
        return await LightningConfirm.open({
            "variant": "header",
            "theme": "warning",
            "label": this.label.massRecallDialogLabel,
            "message": this.label.massRecallDialogMessage
        });
    }

    async recallPackages() {
        try {
            let responseWrapper = await recallPackages({recordId: this.recordId});

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