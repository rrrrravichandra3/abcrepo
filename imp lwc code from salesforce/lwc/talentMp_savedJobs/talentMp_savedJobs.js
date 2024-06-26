import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getSavedJobs from '@salesforce/apex/talentMP_SearchJobService.getSavedJobs'
import getEmployeeContactData from '@salesforce/apex/te_GrowthAppService.getEmployeeContactData'

export default class TalentMp_savedJobs extends LightningElement {
    contactId;
    savedJobs;
    isContactLoaded = false;
    contact;


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if(currentPageReference){
           this.contactId = currentPageReference.state?.cid;
        }
     }
    

    connectedCallback() {
        getSavedJobs({contactId: this.contactId})
        .then((result) => {
          this.savedJobs = result;
        })
        .catch((error) => {
          console.log(error);
        });

        getEmployeeContactData()
        .then((result) => {
          this.contact = result.contact;
          this.isContactLoaded = true;
        })
        .catch((error) => {
          console.log(error);
        });
    }
}