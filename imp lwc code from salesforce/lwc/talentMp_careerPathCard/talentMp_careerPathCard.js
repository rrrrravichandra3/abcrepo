import { api,track } from 'lwc';
import LightningModal from 'lightning/modal';

import getJobGroup from '@salesforce/apex/talentMP_CareerPathing.getJobGroup';

import getJobFamily from '@salesforce/apex/talentMP_CareerPathing.getJobFamily';

import getJobProfile from '@salesforce/apex/talentMP_CareerPathing.getJobProfile';

export default class TalentMp_careerPathCard extends LightningModal {

    @api jobProfileGroup=[];

    @api jobFamilyGroup=[];

    @api jobGroup=[];

    @track jobFamilyValue = '';

    @track jobProfileValue = '';

    @track jobGroupValue = '';

    handleOkay() {
        this.close(this.jobProfileValue);
    }

    handleJobGroupChange(event){
        this.jobGroupValue = event.detail.value;
        this.jobFamilyGroup = [];
        this.jobProfileGroup =[];
        this.jobFamilyValue = '';
        this.jobProfileValue = '';

        getJobFamily({jobGroupId:this.jobGroupValue}).then((result) => {
            for(let res of result){
                this.jobFamilyGroup= [...this.jobFamilyGroup,{'label':res.Name,'value':res.Id}];
            }

        }).catch((error) => {
            console.log(error);
        });

    }

    handleJobProfileChange(event){
        this.jobProfileValue = event.detail.value;
        
    }

    handleJobFamilyChange(event){
        this.jobFamilyValue = event.detail.value;
        this.jobProfileGroup =[];
        this.jobProfileValue = '';

        getJobProfile({jobFamilyId:this.jobFamilyValue}).then((result) => {
            for(let res of result){
                this.jobProfileGroup= [...this.jobProfileGroup,{'label':res.Name,'value':res.Id}];
            }

        }).catch((error) => {
            console.log(error);
        });

    }

    connectedCallback(){

        getJobGroup().then((result) => {
            for(let res of result){
                this.jobGroup= [...this.jobGroup,{'label':res.Name,'value':res.Id}];
            }

        }).catch((error) => {
            console.log(error);
        });
    }

}