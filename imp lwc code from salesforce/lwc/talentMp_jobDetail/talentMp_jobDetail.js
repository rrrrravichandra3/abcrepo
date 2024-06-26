import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getJobDetails from '@salesforce/apex/talentMP_SearchJobService.getJobDetails'
import getEmployeeContactData from '@salesforce/apex/te_GrowthAppService.getEmployeeContactData'
import createSavedJobRecord from '@salesforce/apex/talentMP_SearchJobService.createSavedJobRecord';
import deleteSavedJobRecord from '@salesforce/apex/talentMP_SearchJobService.deleteSavedJobRecord';

export default class TalentMp_jobDetail extends LightningElement {
    jobId;
    jobSfId;
    jobRelatedData;
    contact;
    jobskills = [];
    employeeskills = [];
    isContactLoaded = false;
    @track buttonLabel = 'Save';
    isSaved;
    @track error = null;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if(currentPageReference){
           this.jobId = currentPageReference.state?.jobId;
           this.jobSfId = currentPageReference.state?.jobSfId;
           this.isSaved = currentPageReference.state?.isSaved;
           if(this.isSaved === 'true'){
            this.buttonLabel = 'Unsave';
           }
        }
     }
    

    connectedCallback() {
        getEmployeeContactData()
        .then((result) => {
          this.contact = result.contact;
          this.employeeskills = result.skillList.map(skill => skill.Skill__r.Name);
          this.isContactLoaded = true;
        })
        .catch((error) => {
          console.log(error);
        });
        if (this.jobId) {
            this.getJobDetails();
        }
    }

    getJobDetails() {
       getJobDetails({jobId: this.jobId})  
        .then(result => {
            this.transformJobDetails(result);
        }).catch(error => {
            console.log(error);
        });
    }

    transformJobDetails(jobDetail){ 
        let skillList = jobDetail.skills__c.replaceAll('"','');
        skillList = skillList.replaceAll('[','');
        skillList = skillList.replaceAll(']','');
        console.log(skillList);

        this.jobRelatedData = {
                referenceId : jobDetail.Reference_ID__c,
                jobFamilyFroup : jobDetail.Job_Family_Group__c,
                locations : jobDetail.All_Locations__c.split("\n\n"),
                ...(skillList ? { skills: skillList.split(", ").map(skill => ({
                    Id: skill,
                    Skill__r: {
                        Name: skill
                    }
                }))} : {}),
                description : jobDetail.Job_Description__c,
                title : jobDetail.Job_Title__c,
                workdayURL : jobDetail.Internal_Posting_URL__c
            };
        }

    redirectToWorkday(){
        let workdayURL = this.jobRelatedData?.workdayURL;
        window.open(workdayURL,'_blank');
    }

    saveJobForLater(){
        if(this.isSaved === 'true'){
            deleteSavedJobRecord({contactId:this.contact.Id, jobId:this.jobSfId})
            .then(result => {
                this.error = null;
                this.buttonLabel = 'Save';
            })
            .catch(error => {
                this.error = error.body.message;
            });
        }
        else{
            createSavedJobRecord({contactId:this.contact.Id, jobId:this.jobSfId})
                .then(result => {
                    this.error = null;
                    this.buttonLabel = 'Unsave';
                })
                .catch(error => {
                    this.error = error.body.message;
                });
        }
    }

    @api 
    get jobSkillsExist(){
        return this.jobRelatedData.skills && this.jobRelatedData.skills.length > 0;
    }
}