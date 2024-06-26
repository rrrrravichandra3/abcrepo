import {LightningElement, track, wire, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getMyTeamDetails from '@salesforce/apex/MA_EmployeeCompensastionCtrl.getMyTeamDetails';
import MA_EmployeeCmpDetailHeader from '@salesforce/label/c.MA_EmployeeCmpDetailHeader';

export default class MaEmployeeCompensationDetails extends LightningElement {
    @track teamList = [];
    @track teamListBackup = [];
    @track acqContactFieldSet = [];
    @track acqCompensationFieldSet = [];

    @api contactFieldSetNameInpt ;
    @api compensastionFieldSetNameInpt;

    showSpinner = true;
    hasRendered = false;
    label = {MA_EmployeeCmpDetailHeader}

    @wire(getMyTeamDetails, {acqContactFieldSet: '$contactFieldSetNameInpt', acqCompensationFieldSet: '$compensastionFieldSetNameInpt'}) 
    wiredTeamDetails({error, data}) {
        if(data) {
            this.showSpinner = false;
            const teamDetails = JSON.parse(data);
            this.teamList = teamDetails.myTeamList;

            if(this.teamList) {
                this.acqContactFieldSet = teamDetails.acqContactFields;
                this.acqCompensationFieldSet = teamDetails.acqCompensationFields;
                this.teamList.map(teamMember => {
                    let acqCompensation = teamMember.Acquisition_Compensation__r;
                    if(acqCompensation && acqCompensation.totalSize === 1) {
                        teamMember.Acquisition_Compensation__r = acqCompensation.records[0];
                    }
                });
                this.teamListBackup = JSON.parse(JSON.stringify(this.teamList)); // deep cloning & backing up original teamList
            }
            
        }else if(error) {
            this.showErroMessage(error);
        }
    }

    showErroMessage(error) {
        this.showSpinner = false;
        const unknownError = 'Unknown error';
        let errorMessage = Array.isArray(error.body) ? error.body.map(e => e.message).join(', ') : 
                           (typeof error.body.message === 'string') ? error.body.message : unknownError;
        this.dispatchEvent(new ShowToastEvent({"title" : "Error", "message" : errorMessage, "variant" : "error"}));
    }

    handleToggleSection(event) {}

    handleSearchEmployees(event) {
        let filterTeamList = (searchKey) => {
            return this.teamListBackup.filter(teamMember => {
                return teamMember.Name.toLowerCase().includes(searchKey);
            });
        }
        let searchKey = event.target.value.toLowerCase();
        this.teamList = (searchKey.length > 3) ? filterTeamList(searchKey) : this.teamListBackup;
    }

    renderedCallback(){
        if(!this.hasRendered){
            this.hasRendered = true;
            const style = document.createElement('style');
            style.innerText = `.teamDetailsAccordian .slds-accordion__summary-content {font-family: 'Salesforce Sans';font-weight: bold;font-size: 1.1em;text-transform: capitalize;}`;
            this.template.querySelector('.cssDiv').appendChild(style);
        }
    }
}