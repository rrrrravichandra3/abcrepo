import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CHANGES_IN_PROGRESS from '@salesforce/label/c.MA_Event_Status_Sending_Invites';
import executeEventInviteSender from '@salesforce/apex/MA_SendInvitesController.executeEventInviteSender';

export default class MaCommunityEventSendInvites extends LightningElement {

    @api recordId;
    showSpinner = true;

    @api invoke() {
        executeEventInviteSender({eventId: this.recordId}).then((result) => {
            eval("$A.get('e.force:refreshView').fire();");
            this.showSendingInvitesMessage();
            this.dispatchEvent(new CloseActionScreenEvent());
        }).catch((error) => {
            this.showErroMessage(error);
        });
    }

    showSendingInvitesMessage() {
        this.showSpinner = false;
        const title = CHANGES_IN_PROGRESS;
        const message = "The changes are being published in a batch. The status will be updated upon job completion."
        this.dispatchEvent(new ShowToastEvent({"title" : title, "message" : message, "variant" : "success"}));
    }

    showErroMessage(error) {
        this.showSpinner = false;
        const batchExecutionError = 'Error while executing Event Invite Sender batch!';
        let errorMessage = Array.isArray(error.body) ? error.body.map(e => e.message).join(', ') : 
                           (typeof error.body.message === 'string') ? error.body.message : batchExecutionError;
        this.dispatchEvent(new ShowToastEvent({"title" : "Error", "message" : errorMessage, "variant" : "error"}));
    }
}