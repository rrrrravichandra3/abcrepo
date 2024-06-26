import { LightningElement, api, track } from 'lwc';
import getTasks from "@salesforce/apex/BT_TaskListController.getTasks";

export default class Bt_TaskList extends LightningElement {
    @api devMode = false;
    @track tasks;
    @track error;

    async connectedCallback() {
        await getTasks()
        .then((result) => {
            this.tasks = result;
        })
        .catch((error) => {
            console.log(error);
            this.error = error;
        });
    }
}