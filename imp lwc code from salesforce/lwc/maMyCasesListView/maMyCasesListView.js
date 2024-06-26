import { LightningElement, wire, track, api } from 'lwc';
import CaseRetrieveErrorLabel from '@salesforce/label/c.MA_MyCases_LoadError';
import CasesNotAvailableLabel from '@salesforce/label/c.MA_MyCases_Not_Present';
import CaseStatusOpen from '@salesforce/label/c.MA_Open_Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCaseList from '@salesforce/apex/MA_MyCasesController.getCaseWrapperList';

export default class MaMyCasesListView extends LightningElement {
    label = {
        CaseRetrieveErrorLabel,
        CasesNotAvailableLabel,
        CaseStatusOpen
    };

    @api closedStatusSet;

    parameters = {};

    /** New Methods added to allow query parameter added to url ?caseid=xxxxxxxxxxxxx
     * Will get the query parameter from the url and set the parameters array
     */
    connectedCallback() {
        this.parameters = this.getQueryParameters();
    }

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);
        if(search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }
        return params;
    }
    selectedcasewrapper;
    @track caseswrapper;
    @track shownocases;
    @track error;
    @track isLoading;
    @track firstCaseId;
    
    @track localcasestatuschangeid;
    @api 
    get casestatuschangeid(){
        return this.localcasestatuschangeid;
    }
    set casestatuschangeid(value){
        this.localcasestatuschangeid = value;
        this.handleCaseStatusChange();
    }

    @track localcasestatuschangeupdatedstatus;
    @api 
    get casestatuschangeupdatedstatus(){
        return this.localcasestatuschangeupdatedstatus;
    }
    set casestatuschangeupdatedstatus(value){
        this.localcasestatuschangeupdatedstatus = value;
        this.handleCaseStatusChange();
    }

    constructor(){
        super();
        this.isLoading = true;
        this.getCaseDetails(false);
    }

    handleCaseStatusChange(){
        if(this.localcasestatuschangeupdatedstatus && this.localcasestatuschangeid){
            this.updatelistitemstatus();
        }
    }

    updatelistitemstatus(){
        this.caseswrapper.forEach(item => {
            if (item.caseId === this.localcasestatuschangeid) {
                item.Status = this.localcasestatuschangeupdatedstatus;
                this.isLoading = true;
                this.getCaseDetails(true);
            }
        });     
    }

    handleSelect(event) {
        const caseId = event.detail;
        this.toggleListItems('selected', caseId);

        this.selectedcasewrapper = this.caseswrapper.find(maCase => {
            return maCase.caseId === caseId;
        });
        this.dispatchCaseSelectEvent(caseId);
    }

    handleMouseover(event) {
        this.toggleListItems('mouseIsOver', event.target.dataset.id);
    }

    handleMouseout(event) {
        event.target.mouseIsOver = false;
    }

    toggleListItems(property, caseId) {
        this.template.querySelectorAll('c-ma-case-list-item').forEach(item => {
            item[property] = (item.macasewrapper.caseId === caseId);
        });
    }

    showErrorToast() {   
        var message = (this.caseswrapper == undefined) ? this.label.CasesNotAvailableLabel : this.label.CaseRetrieveErrorLabel;   
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    getCaseDetails(isStatusChanged) {
        getCaseList().then(result =>{
            this.caseswrapper = result;
            this.error = undefined;
            this.isLoading = false;
            var caseIdinList = this.isCaseIdInList(this.caseswrapper,this.parameters.caseid);

            if(this.caseswrapper.length > 0) {
                this.sortOpenClosedCases(this.caseswrapper);
                // Check to see if we were provided a caseid in URL Parameter and case Id is in queried list of cases
                let caseid = (this.parameters.caseid != undefined && caseIdinList) ? this.parameters.caseid : 
                             isStatusChanged ? this.localcasestatuschangeid : this.caseswrapper[0].caseId;

                this.firstCaseId = caseid;
                this.toggleListItems('selected', caseid);
                this.dispatchCaseSelectEvent(caseid);
                
                if(isStatusChanged) {
                    //fire an event saying status change is completed 
                    this.dispatchEvent(new CustomEvent('casestatuseventhandled'));
                }
            }
            
            if(this.caseswrapper.length == 0) {
                this.shownocases = true;
            }
        }).catch(error => {
            this.error = error;
            this.caseswrapper = undefined
            this.isLoading = false;
            this.showErrorToast();
        })
    }

    dispatchCaseSelectEvent(caseid) {
        const selectEvent = new CustomEvent('caseselect', {detail: caseid});
        this.dispatchEvent(selectEvent);
    }

    isCaseIdInList(caseRecords,caseid){
        let caseIds=[];
        for(let i = 0; i < caseRecords.length; i++) {
            caseIds.push(caseRecords[i].caseId);
        }
        return caseIds.includes(caseid);
    }

    sortOpenClosedCases(caseWrapperList) {
        caseWrapperList.sort((caseWrapperA, caseWrapperB) => {
            let isSameStatus = (caseWrapperA.Status.toLowerCase() === caseWrapperB.Status.toLowerCase());
            let isStatusOpen = (caseWrapperA.Status.toLowerCase() === this.label.CaseStatusOpen.toLowerCase());
            let isRecentlyUpdated = (new Date(caseWrapperA.lastModifiedDate) > new Date(caseWrapperB.lastModifiedDate));
            return isSameStatus ? (isRecentlyUpdated ? -1 : 1) : isStatusOpen ? -1 : 1;
        });
    }
}