import { LightningElement, track, api,wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import SEARCH_FILTERS_UPDATED_CHANNEL from '@salesforce/messageChannel/Job_Seach_Filters_Update__c';
import getJobs from '@salesforce/apex/talentMP_SearchJobService.getJobs'
import getEmployeeContactData from '@salesforce/apex/te_GrowthAppService.getEmployeeContactData'
import { NavigationMixin } from 'lightning/navigation';

export default class TalentMp_searchJobsList extends NavigationMixin(LightningElement) {
    @track searchJobList;
    totalCount;
    @wire(MessageContext)
    messageContext;
    @api contact;
    
    connectedCallback(){
        this.subscribeToMessageChannel();
        this.performSyncOperations()
        .catch(error => {
            console.error('An error occurred:', error);
        });
    }

    async performSyncOperations() {
        try {
            await this.getEmployeeContactData();
            await this.getJobs(1);
        } catch (error) {
            throw error;
        }
    }

    async getEmployeeContactData(){
        return new Promise((resolve, reject) => {
        getEmployeeContactData()
            .then((result) => {
                this.contact = result.contact;
                resolve(result);
            })
            .catch((error) => {
                console.log(error);
                reject(error);
            });
        });
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
          this.messageContext,
          SEARCH_FILTERS_UPDATED_CHANNEL,
          (filterValues) => this.getJobs(1,filterValues)
        );
      }

    async getJobs(pageNumber,filterValues){
        return new Promise((resolve, reject) => {
        getJobs({pageNumber: pageNumber,filterValues: JSON.stringify(filterValues), contactId: this.contact.Id})  
        .then(result => {
            this.searchJobList = result.jobList;
            this.totalCount = result.totalCount;
            resolve(result);
        }).catch(error => {
            console.log(error);
            reject(error);
        });
    });
    }

    handleChildCallingToGetJobs(event){
        this.getJobs(event.detail.pageNumber,event.detail.filterValues);
    }

    get isReadyForPagination(){
        return this.totalCount > 0 && this.totalCount != undefined ? true : false;
    }

    redirectToSavedJobs() {
        // Define the pageReference object to specify the page to navigate to
        const uriParams = {
            cid: this.contact.Id
        };
    
        const uriParamsString = Object.entries(uriParams)
        .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
        .join('&');

        const pageReference = {
            type: 'standard__webPage',
                attributes: {
                    url: '/savedJobs?' + uriParamsString
            }
        };

        // Navigate to the specified Community page
        this[NavigationMixin.Navigate](pageReference);
    }
}