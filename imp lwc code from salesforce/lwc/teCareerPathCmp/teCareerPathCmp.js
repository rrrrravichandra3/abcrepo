import { LightningElement,api, track } from 'lwc';
import getJobRecommendations from '@salesforce/apex/te_EinsteinRecommendationsService.getJobRecommendations';
import getRelocationJobRecommendations from '@salesforce/apex/te_EinsteinRecommendationsService.getRelocationJobRecommendations';

import getContactJdVector from '@salesforce/apex/te_EinsteinRecommendationsService.getContactJdVector';
import { NavigationMixin } from 'lightning/navigation';



export default class Te_CareerPathCmp extends NavigationMixin(LightningElement) {
    @api contact;
    @api preferences;
    @api skills;
    @track recommendedJobs;
    @track recommendedJobsFullEmbded;
    @track relocationJobs;
    @track contactJobVectorObj;
    
    connectedCallback(){
            this.getContactJdVectorFromConnectAPI();
            
    }

    getContactJdVectorFromConnectAPI(){
        getContactJdVector({contactId: this.contact.Id,fullEmbedding:false}).then(result => {
            console.log(result);
            this.contactJobVectorObj = result;
            this.getJobRecs();
            this.getJobRecsFullEmbedd();
            this.getRelocationJobs();
        }).catch(error => {
                console.log(error);
        });
    }

    getContactJdVectorFromConnectAPIFullEmbedd(){
        getContactJdVector({contactId: this.contact.Id,fullEmbedding: true}).then(result => {
            console.log(result);
            this.contactJobVectorObj = result;
            this.getJobRecs();
            this.getRelocationJobs();
        }).catch(error => {
                console.log(error);
        });
    }
    getJobRecs(){
        if (this.contact){
        getJobRecommendations({contactId: this.contact.Id,contactJobVector:this.contactJobVectorObj,fullEmbedding:false}).then(result => {
                let jobs = result;
                //jobs = this.sortByMatchScore(jobs);
                jobs = this.sortByJobFamily(jobs);
                this.recommendedJobs = jobs;
            }).catch(error => {
                console.log(error);
            });
        }
    }
    getJobRecsFullEmbedd(){
        if (this.contact){
        getJobRecommendations({contactId: this.contact.Id,contactJobVector:this.contactJobVectorObj,fullEmbedding:true}).then(result => {
                let jobs = result;
                //jobs = this.sortByMatchScore(jobs);
                jobs = this.sortByJobFamily(jobs);
                this.recommendedJobsFullEmbded = jobs;
            }).catch(error => {
                console.log(error);
            });
        }
    }
        
    getRelocationJobs(){
        if (this.contact){
            getRelocationJobRecommendations({contactId: this.contact.Id,contactJobVector:this.contactJobVectorObj}).then(result => {
                let jobs = result;
                jobs = this.sortByJobFamily(jobs);
                this.relocationJobs = jobs;
            }).catch(error => {
                console.log(error);
            });
        }
    }

    @api
    reRunJobRecommendations(){
        this.recommendedJobs = [];
        this.relocationJobs = [];
        this.getContactJdVectorFromConnectAPI();
    }

    navigateToJobPage(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'searchJobs__c'
            }
        });
    }

    sortByMatchScore(jobs){
        jobs.sort((a, b) => {
            if (a.job.match_score__c > b.job.match_score__c) {
              return -1;
            }else{
                return 1;
            }
        });
        return jobs;
    }

    sortByJobFamily(jobs){
        jobs.sort((a, b) => {
            if (a.job.Job_Family_Group__c === this.contact.Segment__c && b.job.Job_Family_Group__c !== this.contact.Segment__c) {
                return -1; // 'Example Text' comes first
            } else if (a.job.Job_Family_Group__c !== this.contact.Segment__c && b.job.Job_Family_Group__c === this.contact.Segment__c ) {
                return 1; // 'Example Text' comes second
            } else {
                // For both items being 'Example Text' or non-'Example Text', sort by the 'value' property
                if (a.job.match_score__c > b.job.match_score__c) {
                    return -1;
                  }else{
                      return 1;
                  }
            }
        });
        return jobs;
    }
}