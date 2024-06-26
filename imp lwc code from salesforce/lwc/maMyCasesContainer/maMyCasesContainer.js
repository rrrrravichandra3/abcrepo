import { LightningElement, api , track} from 'lwc';
import CaseClosedStatus from '@salesforce/label/c.MA_Closed_Status_for_Case_Detail';

export default class MaMyCasesContainer extends LightningElement {

    get closedStatusSet() {
        if(this._closedStatusSet === undefined) {
            this._closedStatusSet = new Set(CaseClosedStatus.toLowerCase().split(";"));
        }
        return this._closedStatusSet;
    }

    selectedcaseid;
    statuschangecaseid;
    statuschangecasestatus;
    
    @api closedCaseStatus;
    @track caseStatus;

    isValidClosedStatus(caseStatus) {
        return this.closedStatusSet.has(caseStatus.toLowerCase());
    }

    handlecaseselect(event){
        const caseId = event.detail;
        this.selectedcaseid = caseId;
    }

    handlecaseclose(event){ 
        this.statuschangecaseid = event.detail.id;
        this.statuschangecasestatus = event.detail.status;
        this.closedCaseStatus = this.isValidClosedStatus(this.statuschangecasestatus);
    }

    resetcasestatuschangevariables(event){
        this.statuschangecaseid = undefined;
        this.statuschangecasestatus = undefined;
    }
    
    handlecasereopen(event){
        this.statuschangecaseid = event.detail.id;
        this.statuschangecasestatus = event.detail.status;
        this.closedCaseStatus = this.isValidClosedStatus(this.statuschangecasestatus);
    }

    handlecasestatus(event){
        this.statuschangecaseid = event.detail.id;
        this.caseStatus = event.detail.status;
        this.closedCaseStatus = this.isValidClosedStatus(this.caseStatus);
    }

    handleCaseComment(event) {
        this.statuschangecaseid = event.detail.id;
        this.statuschangecasestatus = event.detail.status;
        this.closedCaseStatus = this.isValidClosedStatus(this.statuschangecasestatus);
    }
}