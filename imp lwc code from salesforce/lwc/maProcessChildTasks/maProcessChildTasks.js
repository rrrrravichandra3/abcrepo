import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CHANGES_IN_PROGRESS from '@salesforce/label/c.MA_Task_Changes_In_Progress';
import executeCompanyTaskEnroller from '@salesforce/apex/MA_ProcessChildTasksController.executeCompanyTaskEnroller';

export default class MaProcessChildTasks extends LightningElement {
    @api recordId;
    showSpinner = true;

    @api invoke() {
        executeCompanyTaskEnroller({taskId: this.recordId}).then((result) => {
            eval("$A.get('e.force:refreshView').fire();");
            this.showChangesInProgressMessage();
            this.dispatchEvent(new CloseActionScreenEvent());
        }).catch((error) => {
            this.showErroMessage(error);
        });
    }

    showChangesInProgressMessage() {
        this.showSpinner = false;
        const title = CHANGES_IN_PROGRESS;
        const message = "The changes are being published in a batch. The status will be updated upon job completion."
        this.dispatchEvent(new ShowToastEvent({"title" : title, "message" : message, "variant" : "success"}));
    }

    showErroMessage(error) {
        this.showSpinner = false;
        const batchExecutionError = 'Error while executing Task Enroller batch!';
        let errorMessage = Array.isArray(error.body) ? error.body.map(e => e.message).join(', ') : 
                           (typeof error.body.message === 'string') ? error.body.message : batchExecutionError;
        this.dispatchEvent(new ShowToastEvent({"title" : "Error", "message" : errorMessage, "variant" : "error"}));
    }
}