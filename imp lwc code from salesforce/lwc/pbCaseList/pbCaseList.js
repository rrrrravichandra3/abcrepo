/**
 * @description       : This LWC is a custom component to display a list of Cases
 *                      for the preboarding Experience Cloud Site
 * @author            : mdehaan@salesforce.com
 * @group             : Project Phoenix EC Team
 * @last modified on  : 10-26-2023
 * @last modified by  : mdehaan@salesforce.com
 * 
**/ 
import { LightningElement, api , wire} from 'lwc';

// Import message service features required for publishing and the message channel
import { publish, MessageContext } from 'lightning/messageService';
import RECORD_SELECTED_CHANNEL from '@salesforce/messageChannel/Record_Selected_Channel__c';

export default class PbCaseList extends LightningElement {
    @api records;
    @api selectedRecordId;
    highlightedRecId;

    // Labels for Case Items - first column
    @api ticketLabel;
    @api createdLabel;
    @api modifiedLabel;
    @api openStatusText;
    @api closedStatusText;

    @wire(MessageContext)
    messageContext;

    /**
    * @description utilize renderedCallback to highlight the 
    *               first Case card in the list in blue
    * @param  
    */
    renderedCallback() {
        // highlight the first record in the list
        if(this.selectedRecordId) {
            this.highlightedRecId = this.selectedRecordId;

            let liSelected = this.template.querySelector('li.selected')
            if(liSelected){
                liSelected.classList.remove('selected');
            }

            this.template.querySelector('li[data-id="' + this.highlightedRecId + '"]').classList.add('selected');
        }
    }

    /**
    * @description event handler to listen for onclick event of
    *               a Case card in Column 1
    * @param  event
    */
    handleClick(event) {
        // de-select the previously selected item
        if(this.highlightedRecId) {
            this.template.querySelector('li[data-id="' + this.highlightedRecId + '"]').classList.remove('selected');
        }

        // select the new item
        this.highlightedRecId = event.currentTarget.dataset.id;
        this.template.querySelector('li[data-id="' + this.highlightedRecId + '"]').classList.add('selected');

        // Publish the case record that is selected
        const record = this.records.find(({ Id }) => Id === this.highlightedRecId);
        this.publishSelectedRecord(record);
    }

    /**
    * @description publish record to the Lightning message service
    * @param  caseRecord
    */
    publishSelectedRecord(caseRecord){
        // Publish the selected Case record using Lightning Message Service
        const payload = { 
            data: {
                record: caseRecord
            }
        };
        publish(this.messageContext, RECORD_SELECTED_CHANNEL, payload);
    }
}