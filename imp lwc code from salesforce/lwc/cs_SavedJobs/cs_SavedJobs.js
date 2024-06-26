import { LightningElement } from 'lwc';

export default class Cs_SavedJobs extends LightningElement {
    savedJobs = [];
    
    connectedCallback() {
        let value = JSON.parse(localStorage.getItem('savedJobs'));
        console.log(value);
        this.savedJobs.push(value);
        console.log(this.savedJobs);
    }
}