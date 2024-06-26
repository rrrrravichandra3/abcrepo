/**
 * @description       : This LWC is a custom component to display Case record details 
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-26-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api, wire } from 'lwc';

// Import message service features required for subscribing to the message channel
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/Record_Selected_Channel__c';

export default class PbCaseRecordDetail extends LightningElement {
    subscription = null;
    record;
    @api selectedRecord;

    // Labels for Case Detail - third Column
    @api ticketNumLabel;
    @api createdDateLabel;
    @api lastModifiedLabel;
    @api subjectLabel;
    @api statusLabel;
    @api openStatusText;
    @api closedStatusText;
    @api ownerLabel;
    @api attachmentsLabel;
    @api descriptionLabel;
    @api openCaseLabel;
    @api closeCaseLabel;

    recordId;
    subject;
    caseNumber;
    dateCreated;
    lastModified;
    status;
    isClosed;
    description;
    files = [];

    /**
    * @description subscribe to the message channel and
    *               set the values from the selected Case record
    * @param  none
    */
    connectedCallback() {
        this.subscribeToMessageChannel();

        if(this.selectedRecord) {
            this.record = JSON.parse(JSON.stringify(this.selectedRecord));
            this.recordId = this.selectedRecord.Id;
            this.caseNumber = this.selectedRecord.CaseNumber;
            this.subject = this.selectedRecord.Subject;
            this.dateCreated = this.selectedRecord.CreatedDate;
            this.lastModified = this.selectedRecord.LastModifiedDate;
            this.status = this.selectedRecord.Status;
            this.isClosed = this.selectedRecord.IsClosed;
            this.description = this.selectedRecord.Description;

            if(this.selectedRecord.ContentDocumentLinks) {
                this.files = JSON.parse(JSON.stringify(this.selectedRecord.ContentDocumentLinks));
                this.files.forEach(file => this.updateFileProperties(file));

            }
        }
    }

    /**
    * @description wire the MessageContext
    * @param  none
    */
    @wire(MessageContext)
    messageContext;

    /**
    * @description Subscribe to the Lightning message service channel
    *               called Record_Selected_Channel__c
    * @param  none
    */
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                RECORD_SELECTED_CHANNEL,
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
        if(message.data) {
            this.record = message.data.record;
            this.recordId = this.record.Id;
            this.caseNumber = this.record.CaseNumber;
            this.subject = this.record.Subject;
            this.dateCreated = this.record.CreatedDate;
            this.lastModified = this.record.LastModifiedDate;
            this.status = this.record.Status;
            this.isClosed = this.record.IsClosed;
            this.description = this.record.Description;

            if(this.record.ContentDocumentLinks) {
                this.files = JSON.parse(JSON.stringify(this.record.ContentDocumentLinks));
                this.files.forEach(file => this.updateFileProperties(file));
            }
        }
    }
 
    /**
    * @description unsubscribe to the message channel
    * @param  none
    */
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /**
    * @description unsubscribe to the message channel
    * @param  none
    */
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    /**
    * @description method that adds a downloadable file url and label
    *               to each file for a given Case record
    * @param  file
    */
    updateFileProperties(file) {
        let fileDownloadUrl = '/sfc/servlet.shepherd/document/download/' + file.ContentDocumentId + '?operationContext=S1';
        file.label = file.ContentDocument.Title + '.' + file.ContentDocument.FileExtension;
        file.downloadUrl = fileDownloadUrl;
    }


}