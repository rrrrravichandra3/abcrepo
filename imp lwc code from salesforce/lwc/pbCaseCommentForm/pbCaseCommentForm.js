import { LightningElement, api, wire } from 'lwc';
import createCaseComments from '@salesforce/apex/PbCasesController.createCaseComment';

// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import REFRESH_CHANNEL from '@salesforce/messageChannel/Refresh_Channel__c';

export default class PbCaseCommentForm extends LightningElement {
    @api recordId; // Case recordId
    @api inputPlaceholder;
    @api addAttachmentsLabel;
    @api fileTypes;

    loaded = true;
    error;
    showAttachments = false;
    fileData;

    /**
    * @description event listener for click of button
    *               or enter key and handles the creation
    *               of new CaseComment
    * @param  evt
    */
    handleNewComment(evt) {
        const isEnterKey = evt.keyCode === 13;
        const isClicked = evt.type === "click";
        let commentText;
        if (isEnterKey) {
            commentText = evt.target.value;
            console.log("commentText: ", commentText);
            if(commentText !== '') {
                this.loaded = false;
                this.createComment(commentText);
            }
        } else if (isClicked){
            commentText = this.template.querySelector('.commentInput').value;
            console.log("commentText: ", commentText);
            if(commentText !== '') {
                this.loaded = false;
                this.createComment(commentText);
            }
        }

    }

    /**
    * @description call Apex to create a new CaseComment
    *               related to the current Case record
    * @param  commentText
    */
    createComment(commentText){
        // apex call to get list of Cases
        createCaseComments({ recordId : this.recordId, commentBody: commentText })
        .then(resp => {
            // Show Sucess Message
            console.log("CaseComment was created!", resp);
            this.loaded = true;
            this.publishRefresh(); // Send message to parent LWC to refresh data
        }).catch(error => {
            console.log(error);
            this.loaded = true;
        });
    }

    /**
    * @description wire the MessageContext
    * @param  none
    */
    @wire(MessageContext)
    messageContext;

    /**
    * @description publish record to the Lightning message service
    * @param  none
    */
    publishRefresh(){
        // Publish the selected Case record using Lightning Message Service
        const payload = {
            recordId: this.recordId
        };
        publish(this.messageContext, REFRESH_CHANNEL, payload);
    }
    
}