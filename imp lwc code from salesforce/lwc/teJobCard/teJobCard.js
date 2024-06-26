import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TeJobCard extends NavigationMixin(LightningElement) {
    @api jobData;
    @api contact;
    @api skills;
    skillsList = [];
    matchedSkills = [];
    unmatchedSkills = [];
    

    connectedCallback(){
        this.setSkillsList();
    }
    navigateToWDPosting(){
        window.open(this.jobData.job.Internal_Posting_URL__c)
    }

    navigateToPosting(){
        const uriParams = {
            jobId: this.jobData.job.Reference_ID__c,
            jobSfId: this.jobData.job.Id,
            isSaved: this.jobData.isSaved,
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

    setSkillsList(){
        if(this.jobData){
            let skillString = this.jobData.job.skills__c;
            let skillList = skillString.split(",");
            this.skillsList = skillList;
        }
    }

    get totalSkills(){
        console.log(this.skillsList.length)
        if(this.skillsList){
            return this.skillsList.length;
        }else{
            return 0;
        }
    }

}