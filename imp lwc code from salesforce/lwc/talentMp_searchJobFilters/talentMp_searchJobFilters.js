import { LightningElement,wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import SEARCH_FILTERS_UPDATED_CHANNEL from '@salesforce/messageChannel/Job_Seach_Filters_Update__c';
import getFilterValues from '@salesforce/apex/talentMP_SearchJobService.getFilterValues';

export default class TalentMp_searchJobFilters extends LightningElement {
    @wire(MessageContext)
    messageContext;
    searchKeyword;
    jobFamilyGroups = [];
    countries = [];
    selectedJobFamilyGroup = '';
    selectedCountry = '';

    @wire(getFilterValues)
    wiredFilterValues({ error, data }) {
        if (data) {
            this.jobFamilyGroups = [
                { label: 'All', value: '' },
                ...data.jobFamilyGroups.map(item => ({ label: item, value: item }))
            ];

            this.countries = [
                { label: 'All', value: '' },
                ...data.countryValues.map(item => ({ label: item, value: item }))
            ];
        } else if (error) {
            // Handle any errors
        }
    }

    handleKeywordChange(event){
        this.searchKeyword = event.target.value;
    }

    handleJobFamilyGroupChange(event) {
        this.selectedJobFamilyGroup = event.detail.value;
    }

    handleCountryChange(event) {
        this.selectedCountry = event.detail.value;
    }

    handleJobSearchFilters(event){
        const payload = {
            searchKeyword: this.searchKeyword
        };
        
        if (this.selectedJobFamilyGroup) {
            payload.jobFamilyGroup = this.selectedJobFamilyGroup;
        }
        if (this.selectedCountry) {
            payload.country = this.selectedCountry;
        }
        publish(this.messageContext, SEARCH_FILTERS_UPDATED_CHANNEL, payload);
    }
}