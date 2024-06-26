import { LightningElement,api } from 'lwc';

export default class TaskProgressDetail extends LightningElement {
    @api totalTasks;
    @api tasksCompleted;
    _tasksRemaining;

    handleClick(event) {
        this.dispatchEvent(new CustomEvent('continuetask'));
    }

    connectedCallback() {
       this._tasksRemaining = this.totalTasks-this.tasksCompleted;
    }
}