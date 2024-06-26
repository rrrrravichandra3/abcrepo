/**
 * @description       : This LWC is a container for the Comments column for the
 *                      "My Tickets" page for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 11-01-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/

import { LightningElement, api, wire } from 'lwc';
import getCaseComments from '@salesforce/apex/PbCasesController.getCaseComments';
import UserId from "@salesforce/user/Id"; // get current user's id

// Import message service features required for subscribing and the message channel
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/Record_Selected_Channel__c';
import REFRESH_CHANNEL from '@salesforce/messageChannel/Refresh_Channel__c';

export default class PbCaseComments extends LightningElement {
    userId = UserId;
    @api selectedRecord;
    @api selectedRecordId;
    record;
    recordId; // Case recordId
    isClosed;
    commentsList;

    subscription = null;
    subscription_refresh = null;
    @api inputPlaceholder;
    @api addAttachmentsLabel;
    @api fileTypes;

    @wire(MessageContext)
    messageContext;


    /**
    * @description Standard lifecycle hook to start scroll
    *               bar at the bottom on load for comments
    * @param  none
    */
    renderedCallback() {
        const scrollArea = this.template.querySelector('[data-scroll-area]')
        scrollArea.scrollTop = scrollArea.scrollHeight;
    }

    /**
    * @description Standard lifecycle hook to subscribe to
    *               the Lightning message service & set the fields
    *               from the parent LWC
    * @param  none
    */
    connectedCallback() {
        if(this.selectedRecord) {
            this.record = this.selectedRecord;
            this.recordId = this.selectedRecordId;
            this.isClosed = this.selectedRecord.IsClosed;
            this.getCaseCommentsList(this.recordId);
        }
        this.subscribeToMessageChannel();
    }

    /**
    * @description Encapsulate logic for Lightning message service subscribe
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
        if (!this.subscription_refresh) {
            this.subscription_refresh = subscribe(
                this.messageContext,
                REFRESH_CHANNEL,
                (message) => this.handleRefresh(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /**
    * @description Handler for message received by component when user clicks
    *               on a different case
    * @param  message
    */
    handleData(message) {
        if(message.data) {
            this.record = message.data.record;
            this.recordId = this.record.Id;
            this.isClosed = this.record.IsClosed;
            this.getCaseCommentsList(this.recordId);
        }
    }

    /**
    * @description Handler for refreshing data when new comment
    *               is added
    * @param  message
    */
    handleRefresh(message) {
        if(message.recordId) {
            this.recordId = message.recordId;
            this.getCaseCommentsList(this.recordId);
        }
    }
    
    /**
    * @description Standard lifecycle hook to unsubscribe to
    *               the Lightning message service
    * @param  none
    */
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;

        unsubscribe(this.subscription_refresh);
        this.subscription_refresh = null;
    }

    /**
    * @description call Apex method 'PbCasesController.getCaseComments' to 
    *               get list of CaseComments related to the current Case record
    * @param  recordId
    */
    getCaseCommentsList(recId) {
        //Call Apex
        getCaseComments({ recordId: recId })
        .then(resp => {
            this.commentsList = JSON.parse(JSON.stringify(resp));
            this.commentsList.forEach(comment => this.setCommentType(comment));
        }).catch(error => {
            console.log(JSON.stringify(error));
        });
    }

    /**
    * @description method to determine if a CaseComment
    *               is inbound or outbound - determines
    *               how it's displayed on UI
    * @param  comment
    */
    setCommentType(comment) {
        if(comment.CreatedById === this.userId) {
            //comment is from current user (prehire)
            comment.inbound = false;
            comment.outbound = true;
        } else {
            // comment is from agent
            comment.inbound = true;
            comment.outbound = false;
        }
    }
    
}