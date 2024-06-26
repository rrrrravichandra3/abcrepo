import { LightningElement,api } from 'lwc';

export default class PbHomeMain extends LightningElement {

    @api totalTasks;
    @api tasksCompleted;
    @api provCase;

    continueTask(event) {
        this.dispatchEvent(new CustomEvent('continuetask'));
    }
}