import { LightningElement,api, track } from 'lwc';
import getRecommendations from '@salesforce/apex/te_EinsteinRecommendationsService.getRecommendations'


export default class Te_CareerPathCmp extends LightningElement {
    @api contact;
    @api skillsList = ['Salesforce Development', 'Salesforce Administration', 'Agile Transformation', 'Process & Solution Design', 'Integration Design', 'Mentorship', 'Apex', 'LWC', 'Visualforce']
    @api skillsMissingList = ['AI','Einstein','Mulesoft','Scrum Master'];
    @track recommendedJobs = []
    
    connectedCallback(){
        getRecommendations({
                skillList: this.skillsList.toString,
                location: "California",
                jobGrade: 6
            }).then(result => {
            console.log(result.jobs);

        }).catch(error => {
            console.log(error);
        });
    }

    get JobOne(){     
        if(this.recommendedJobs.length > 0)   
            return this.recommendedJobs[0];
        else
            return null;
    }

    get JobTwo(){
        if(this.recommendedJobs.length > 0)
            return this.recommendedJobs[1];
        else
            return null;
    }

    get JobThree(){
        if(this.recommendedJobs.length > 0)
            return this.recommendedJobs[2];
        else
            return null;
    }
}