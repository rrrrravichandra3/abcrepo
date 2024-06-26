import { LightningElement,api,track } from 'lwc';

export default class TaskProgress extends LightningElement {
    @api totalTasks;
    @api tasksCompleted;
    @track _taskPercentage;

    calculateTaskPercentage(a,b) {
        return parseFloat(a/b)*100;
    }

    get taskPercentage() {
        this._taskPercentage = parseInt(this.calculateTaskPercentage(this.tasksCompleted,this.totalTasks));
        return this._taskPercentage/100;
    }

    get progressvalue() {
        return "M 1 0 A 1 1 0 " + (this.taskPercentage > 0.5 ? 1 : 0) + " 1 "+ Math.cos(2 * Math.PI * this.taskPercentage) + " "+ Math.sin(2 * Math.PI * this.taskPercentage) +" L 0 0"; 
    }



}