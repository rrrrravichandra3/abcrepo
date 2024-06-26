import { LightningElement, api } from 'lwc';
import { fireCustomEvent } from "c/iDP_Utils";
import LightningConfirm from 'lightning/confirm';
export default class IDP_Actions extends LightningElement {

    @api body = "Find a leader as Mentor";
    @api status;
    @api action;
    @api isEditable = false;
    @api isReadOnly = false;
    @api ismanager;

//================================================== PAYLOAD GETTERS ==================================================
    get options() {
        return [
            { label: 'Not Started', value: 'Not Started' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Complete', value: 'Complete' },
            { label: 'Archived - FY24', value: 'Archived - FY24' },
            
        ];
    }

//================================================== LIFE CYCLE HOOKS ==================================================
    connectedCallback() {
        this.body = this.action.Action;
        this.status = this.action.Status;
        this.isReadOnly = !this.isEditable;
    }

//================================================== LOGIC METHODS ==================================================
    // Method to handle changes to an Action 
    handleChange(event) {
        let obj = new Object();
        obj.Action = this.action.Action;
        obj.Status = this.action.Status;
        obj.recordId = this.action.recordId;
        obj.completionDate = this.action.completionDate;
        obj.Comments = this.action.Comments;
        if (event.target.name == 'actName') {
            obj.Action = event.target.value;
        }
        else if (event.target.name == 'progress') {
            obj.Status = event.target.value;
        }
        else if (event.target.name == 'completionDate') {
            obj.completionDate = event.target.value;
        }
        else if (event.target.name == 'comments') {
            obj.Comments = event.target.value;
        }
        this.action = obj; 

        let paramData = { action: this.action };
        fireCustomEvent(this,'changeaction',paramData);
    }

    // Method to handle Action deletion 
    async onActionDelete() {
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to delete this Action?',
            variant: 'header',
            theme: 'offline',
            label: 'Delete Action',
        });
        if (result === true) {
            let paramData = { action: this.action };
            fireCustomEvent(this, 'deleteaction', paramData);
        }
    }
}