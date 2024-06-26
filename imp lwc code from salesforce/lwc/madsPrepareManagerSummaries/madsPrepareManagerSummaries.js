/**
 * W-12578116
 * LWC headless quick action, to Prepare Manager Summaries for all the eligible / selected / individual Package Distribution(s) related to the Acquisition Company record.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         25/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to initiate processing of Manager Summaries Prep by invoking Apex Controller. 
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

import { reduceErrors } from 'c/maErrorHandlingUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import prepareSummaries from '@salesforce/apex/MA_DS_PrepareManagerSummaries.prepareManagerSummaries';
import { RefreshEvent } from "lightning/refresh";

export default class MadsPrepareManagerSummaries extends LightningElement {
    @api recordId;
    showSpinner = true;

    @api invoke() {
        this.prepareManagerSummaries();
    }

    async prepareManagerSummaries() {
        try {
            let responseWrapper = await prepareSummaries({recordId: this.recordId});

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