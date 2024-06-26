/**
 * W-12578130
 * LWC headless quick action, to Deliver Manager Summaries for all the eligible Package Distributions related to the Acquisition Company record.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         20/04/2023      Chakshu Malhotra        W-12578130 - Adds logic to initiate processing of Manager Summary Delivery by invoking Apex Controller. 
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

import { reduceErrors } from 'c/maErrorHandlingUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import deliverSummaries from '@salesforce/apex/MA_DS_DeliverManagerSummaries.deliverManagerSummaries';
import { RefreshEvent } from "lightning/refresh";

export default class MadsDeliverManagerSummaries extends LightningElement {
    @api recordId;
    showSpinner = true;

    @api invoke() {
        this.deliverManagerSummaries();
    }

    async deliverManagerSummaries() {
        try {
            let responseWrapper = await deliverSummaries({recordId: this.recordId});

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