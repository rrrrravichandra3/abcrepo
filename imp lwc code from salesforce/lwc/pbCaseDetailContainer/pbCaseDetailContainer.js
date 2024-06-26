/**
 * @description       : This LWC is a custom Case record detail page 
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 11-01-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api, wire } from 'lwc';
import UserId from "@salesforce/user/Id"; // get current user's id
import getCases from '@salesforce/apex/PbCasesController.getCases';

// Import message service features required for subscribing to the message channel
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import REFRESH_CHANNEL from '@salesforce/messageChannel/Refresh_Channel__c';

export default class PbCaseDetailContainer extends LightningElement {
    userId = UserId;
    enabledFeatures = ["button","badge","grid"];

    subscription = null;

    // Labels for headers
    @api title;
    @api column1Header;
    @api column2Header;
    @api column3Header;

    // Labels for Case Items - first column
    @api ticketLabel;
    @api createdLabel;
    @api modifiedLabel;
    @api openStatusText;
    @api closedStatusText;

    // Label for Case Comments - second column
    @api inputPlaceholder;
    @api addAttachmentsLabel;
    @api fileTypes;
    @api agentName;
    @api attachmentErrorMessage;
    @api successMessage;
    @api errorMessage;

    // Labels for Case Detail - third Column
    @api ticketNumLabel;
    @api createdDateLabel;
    @api lastModifiedLabel;
    @api subjectLabel;
    @api statusLabel;
    @api ownerLabel;
    @api attachmentsLabel;
    @api descriptionLabel;
    @api openCaseLabel;
    @api closeCaseLabel;

    selectedRecord;
    selectedRecordId;
    records;
    error;

    /**
    * @description wire the MessageContext
    * @param  none
    */
    @wire(MessageContext)
    messageContext;

    /**
    * @description subscribe to the message channel and
    *               set the values from the selected Case record
    * @param  none
    */
    connectedCallback() {
        this.subscribeToMessageChannel();
        this.getCaseList();
    }
    
    /**
    * @description call Apex to get list of Cases
    *               with any related Files
    * @param  none
    */
    getCaseList(recId) {
        // apex call to get list of Cases
        getCases()
        .then(resp => {
            this.records = resp;
            if(recId) {
                // Set the selectedRecord as the recordId passed
                this.selectedRecord = this.records.find((record) => record.Id === recId);
                this.selectedRecordId = recId;

                console.log("refresh selectedRecord:", this.selectedRecord);
                const childComponent = this.template.querySelector('c-pb-case-record-detail');
                if (childComponent) {
                    childComponent.updateReactiveProperty(this.selectedRecord);
                }
            } else {
                // Highlight the 1st record if no recordId is passed in
                this.selectedRecord = this.records[0];
                this.selectedRecordId = this.records[0].Id;
            }
        }).catch(error => {
            console.log(JSON.stringify(error));
        });
    }


    /**
    * @description Subscribe to the Lightning message service channel
    *               called Record_Selected_Channel__c
    * @param  none
    */
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                REFRESH_CHANNEL,
                (message) => this.handleData(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /**
    * @description Handler for message received by component
    * @param  message
    */
    handleData(message) {
        // Refresh comments
        if(message.recordId){
            // Refresh data
            this.getCaseList(message.recordId);
        }
    }

    /**
    * @description unsubscribe to the message channel
    * @param  none
    */
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }


}