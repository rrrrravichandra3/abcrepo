import { LightningElement,api } from 'lwc';

export default class TaskProgressComp extends LightningElement {
    @api totalTasks;
    @api tasksCompleted;

    continueTask(event) {
        this.dispatchEvent(new CustomEvent('continuetask'));
    }
}