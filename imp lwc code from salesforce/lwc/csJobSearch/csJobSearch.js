import { LightningElement } from 'lwc';
import getOpenJobs from '@salesforce/apex/cs_JobService.getOpenJobs';

export default class CsJobSearch extends LightningElement {
openJobs = [];
savedJobs;
openJobMap = new Map();

    connectedCallback() {
        getOpenJobs().then(result => {
            console.log(result);
            this.openJobs = result;
            this.openJobs.forEach((obj) => {
                this.openJobMap.set(obj.Id, obj);
            });
        }).catch(error => {
            console.log(error);
        });
       
        const value = localStorage.getItem('savedJobs');
        this.savedJobs = value;
        console.log('saved Job: ' + this.savedJobs);
        console.log(this.openJobMap);

    }

    handlebookMark(event){
        let jobId = event.target.id;
        console.log(jobId);
        let splitId = jobId.split('-')[0];
        console.log(splitId);
        let job = this.openJobMap.get(splitId);
        localStorage.setItem('savedJobs', JSON.stringify(job));
    }

    addToSavedJobs(event){
        console.log(event);
    }

}