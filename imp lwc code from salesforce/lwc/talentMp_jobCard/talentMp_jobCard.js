import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createSavedJobRecord from '@salesforce/apex/talentMP_SearchJobService.createSavedJobRecord';
import deleteSavedJobRecord from '@salesforce/apex/talentMP_SearchJobService.deleteSavedJobRecord';

export default class TalentMp_jobCard extends NavigationMixin(LightningElement) {
    @api contact;
    @track iconVariant = 'bare';
    @track searchedjobsResults = [];
    @track error = null;


    @api 
    set searchedjobs(value) {
        this.updateSearchedJobsResults(value);
    }

    get searchedjobs() {
        return this.searchedjobs;
    };

    updateSearchedJobsResults(searchedjobs) {
        this.searchedjobsResults = searchedjobs ? searchedjobs.map(job => {
            if (job.isSaved === true) {
                return { ...job, style: '--slds-c-icon-color-foreground-default: #0176D3', isSaved: true};
            } else {
                return { ...job};
            }
        }) : [];
        
    }

    redirectToJobDetails(event){
        const uriParams = {
            jobId: event.currentTarget.dataset.id,
            jobSfId: event.currentTarget.dataset.sfid,
            isSaved: event.currentTarget.dataset.saved,
        };
    
        const uriParamsString = Object.entries(uriParams)
        .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
        .join('&');

        this[NavigationMixin.GenerateUrl]({
        type: 'standard__webPage',
        attributes: {
            url: '/jobs?' + uriParamsString
        }
        }).then(url => {
            window.open(url, '_blank');
        });
    }

    saveJobForLater(event){
        const contactId = this.contact.Id; 
        const jobId = event.currentTarget.dataset.sfid;
        if(event.currentTarget.dataset.saved === "true"){
            deleteSavedJobRecord({contactId, jobId})
            .then(result => {
                this.error = null;
                this.searchedjobsResults = this.searchedjobsResults.map(job => {
                    if (job.sfId === jobId) {
                        return { ...job, style: '--slds-c-icon-color-foreground-default: #5a5c61', isSaved: false};
                    } else {
                        return { ...job};
                    }
                });
            })
            .catch(error => {
                this.error = error.body.message;
            });
        }
        else{
            createSavedJobRecord({contactId, jobId })
            .then(result => {
                this.error = null;
                this.searchedjobsResults = this.searchedjobsResults.map(job => {
                    if (job.sfId === jobId) {
                        return { ...job, style: '--slds-c-icon-color-foreground-default: #0176D3', isSaved: true};
                    } else {
                        return { ...job};
                    }
                });
            })
            .catch(error => {
                this.error = error.body.message;
            });
        }
    }

    handleSaveForLaterMouseover(event){
        const jobId = event.currentTarget.dataset.sfid;

        this.searchedjobsResults = this.searchedjobsResults.map(job => {
            if (job.sfId === jobId) {
                return { ...job, style: '--slds-c-icon-color-foreground-default: #0176D3'};
            } else {
                return { ...job};
            }
        });
    }

    handleSaveForLaterMouseout(event){
        const jobId = event.currentTarget.dataset.sfid;

        this.searchedjobsResults = this.searchedjobsResults.map(job => {
            if (job.sfId === jobId && !job.isSaved) {
                return { ...job, style: '--slds-c-icon-color-foreground-default: #5a5c61'};
            } else {
                return { ...job};
            }
        });
    }
}