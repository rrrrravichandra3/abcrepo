import { LightningElement, api, track } from 'lwc';
import INSIDERS_LOGO from '@salesforce/resourceUrl/insidersApp';
import isAppointmentBooked from '@salesforce/apex/IA_ServiceResources.hasNoExistingAppointment';
import Id from '@salesforce/user/Id';
import isGhostModeOn from '@salesforce/apex/IA_ServiceResources.isGhostModeOn';

export default class ia_VolunteerDetail extends LightningElement {
    userId = Id;
    @track error;
    @track isNotBooked = false;
    isGhosted = false;
    @api serviceResource;
    serviceResourceArray = [];
    @api serviceResourceId;
    insidersAppLogoUrl = INSIDERS_LOGO;
    alertMessage = 'You have already booked an Insiders Meeting. If you need to reschedule please refer to your confirmation email.';

    connectedCallback() {
        isAppointmentBooked({ recId: this.userId })
            .then(result => {
                this.isNotBooked = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    get serviceResourceFields() {
        const checkList = [ 'Profile_Picture__c', 'Id', 'Top_3_Interests_ERGs__c', 'Name', 'About_this_Insider__c'];
        const keys = Object.keys(this.serviceResource);
        
        const arr = keys.filter(key => !(checkList.indexOf(key) > -1) );
        this.serviceResourceArray = arr.map(val => ({ ...this.serviceResource[val] }) );
        this.getGhostModeStatus();
        return this.serviceResourceArray;
    }

    connectButtonClick() {
        if (!this.isNotBooked) {
            alert(this.alertMessage);
        } else if (this.isNotBooked) {
            const detail = {
                show: false,
                Id: this.serviceResourceId
            }
            const custPassEvent = new CustomEvent('serviceresourceconnectclick', { detail });
            this.dispatchEvent(custPassEvent);
        }
    }

    getGhostModeStatus() {
        isGhostModeOn({ recId: this.serviceResourceId })
            .then((result) => {
                this.isGhosted = result;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    handleClickBack() {
        const goBackEvent = new CustomEvent('goback');
        this.dispatchEvent(goBackEvent);
    }

    get profilePictureAlt() {
        return "Photo of " + this.serviceResource.Name.value;
    }
}