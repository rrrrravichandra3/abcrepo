import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import deleteFile from '@salesforce/apex/MA_MyCasesController.deleteFile';
import getCaseAttachment from '@salesforce/apex/MA_MyCasesController.getFiles';
import closeCase from '@salesforce/apex/MA_MyCasesController.closeCase';
import reOpenCase from '@salesforce/apex/MA_MyCasesController.reOpenCase';
import CASENUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import CASESUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import FilesUploadSuccessMsg from '@salesforce/label/c.MA_File_Upload_Success_Message';
import CaseAlreadyClosedMsg from '@salesforce/label/c.MA_Case_Already_Closed_Message';
import CaseClosedSuccessMsg from '@salesforce/label/c.MA_Case_Closed_Successsful_Message';
import CaseReOpenSuccessMsg from '@salesforce/label/c.MA_Case_Reopen_Successsful_Message';
import CaseClosedLabel from '@salesforce/label/c.MA_CaseClose_Label';
import CaseReOpenLabel from '@salesforce/label/c.MA_CaseReOpen_Label';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import StatusOpen from '@salesforce/label/c.MA_Open_Status';
import StatusClosed from '@salesforce/label/c.MA_Closed_Status';

export default class MaMyCasesDetail extends LightningElement {

    label = {
        FilesUploadSuccessMsg,
        CaseAlreadyClosedMsg,
        CaseClosedSuccessMsg,
        CaseReOpenSuccessMsg,
        CaseClosedLabel,
        CaseReOpenLabel,
        StatusOpen,
        StatusClosed
    };

    @api closedStatusSet;

    isValidClosedStatus(caseStatus) {
        return this.closedStatusSet.has(caseStatus.toLowerCase());
    }

    @track localSelectedCaseId;
    @track caseStatus;
    @track existingAllFiles = [];
    @track attachmentURL;
    @track caseNumber;
    @track caseSubject;
    @track status;
    @track description;
    @track ownerName;
    @track createdDate;
    @api isLoaded = false;
    @api recordId;
    @api caseButtonLabel;
    @track count;
    @track closedcase;
    timeZone = TIME_ZONE;
    
    casebuttonLabel = "Close Case";

    @api
    get selectedcaseid() {
        return this.localSelectedCaseId;
    }
    set selectedcaseid(value) {
        this.setAttribute('selectedcaseid', value);
        this.localSelectedCaseId = value;
        this.getAttachmentsFromServer();
    }

    @api 
    get updatedCaseStatus() {
        return this.caseStatus;
    }
    set updatedCaseStatus(value) {
        if(value) {
            this.status = value;
            this.caseStatus = value;
        }
    }

    connectedCallback() {
        this.isLoaded = !this.isLoaded;
    }

    @wire(getRecord, { recordId: '$localSelectedCaseId', fields: [CASENUMBER_FIELD, CASESUBJECT_FIELD, STATUS_FIELD, DESCRIPTION_FIELD, 'Case.Owner.Name', 'Case.CreatedDate'] })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.showToast('Error loading case', message , 'error');
        } else if (data) {
            this.isLoaded = false;
            this.case = data;
            
            let isValidClosedStatus = this.isValidClosedStatus(this.case.fields.Status.value);
            this.closedcase = isValidClosedStatus;
            this.status = isValidClosedStatus ? this.label.StatusClosed : this.label.StatusOpen;

            this.caseNumber = this.case.fields.CaseNumber.value;
            this.caseSubject = this.case.fields.Subject.value;
            this.description = this.case.fields.Description.value;
            this.ownerName = this.case.fields.Owner.displayValue;
            this.createdDate = this.getFormattedDate( this.case.fields.CreatedDate.value);
            this.casebuttonLabel = this.closedcase ? this.label.CaseReOpenLabel : this.label.CaseClosedLabel;
            this.sendcaseStatusDetail();            
        }
    }

    getAttachmentsFromServer() {
        if (this.localSelectedCaseId) {
            getCaseAttachment({ caseId: this.localSelectedCaseId }).then(result => {
                this.existingAllFiles = result;
                this.count = (this.existingAllFiles != null) ? this.existingAllFiles.length : 0;                                                   
            }).catch(error => {
                this.showToast('Error loading attachments', error , 'error');
            })
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg', '.doc', '.docx', '.pptx', '.odt', '.xls', '.xlsx', '.odp'];
    }

    handleUploadFinished(event) {
        const lstUploadedFiles = event.detail.files;
        this.getAttachmentsFromServer();
        this.showToast('Success', this.label.FilesUploadSuccessMsg, 'success');
    }

    downloadAttachment(event) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        this.attachmentURL = baseURL+"/sfsites/c/sfc/servlet.shepherd/version/download/" + event.currentTarget.dataset.id;
    }

    handleCloseClick(event) {
        if (this.localSelectedCaseId && !this.isValidClosedStatus(this.status)) {
            this.isLoaded = !this.isLoaded;
            closeCase({ caseId: this.localSelectedCaseId })
                .then(result => {
                    this.handleSuccess();
                    this.caseStatus = result.Status;
                    this.status = result.Status;
                    this.closedcase = true;
                    this.casebuttonLabel = this.label.CaseReOpenLabel;
                    this.sendCloseCaseDetails();
                    this.sendcaseStatusDetail();
                })
                .catch(error => {
                    var errorMsg = 'Unknown error';
                    if (error.body) {
                        errorMsg = error.body.message;
                    }
                    this.showToast('Error', errorMsg, 'error');
                })
        } else {
            this.showToast('Warning',this.label.CaseAlreadyClosedMsg, 'warning');
        }
    }

   handleReOpenClick(event) {
        if (this.localSelectedCaseId && this.isValidClosedStatus(this.status)) {
            this.isLoaded = !this.isLoaded;
            reOpenCase({ caseId: this.localSelectedCaseId }).then(result => {
                this.caseStatus = result.Status;
                this.handlereOpenSuccess();
                this.status = result.Status;
                this.sendReOpenCaseDetails();
                this.closedcase = false;
                this.casebuttonLabel = this.label.CaseClosedLabel;
            }).catch(error => {
                var errorMsg = 'Unknown error';
                if (error.body) {
                    errorMsg = error.body.message;
                }
                this.showToast('Error', errorMsg, 'error');
            })
        }
    }

    handleCaseClick(event){
        if(this.closedcase) {
            this.handleReOpenClick(event);
        }else {
            this.handleCloseClick(event);
        }
    }
    sendCloseCaseDetails() {
        var caseClosedDetails = {status:this.status, id:this.localSelectedCaseId};
        const closeEvent = new CustomEvent('close', {
            detail: caseClosedDetails
        });
        this.dispatchEvent(closeEvent);
    }

    sendReOpenCaseDetails() {
        var casereOpenDetails = {status:this.status, id:this.localSelectedCaseId};
        const openEvent = new CustomEvent('reopen', {
            detail: casereOpenDetails
        });
        this.dispatchEvent(openEvent);
    }

    sendcaseStatusDetail() {
        var caseDetails = {status:this.status, id:this.localSelectedCaseId};
        const openEvent = new CustomEvent('casestatuschange', {
            detail: caseDetails
        });
        this.dispatchEvent(openEvent);
    }

    handleSuccess() {
        this.isLoaded = false;
        this.showToast('Success',this.label.CaseClosedSuccessMsg, 'success');
    }
    handlereOpenSuccess() {
        this.isLoaded = false;
        this.showToast('Success',this.label.CaseReOpenSuccessMsg, 'success');
    }

    handleDelete(event){
        let deleteId = event.target.dataset.recordid;
        
        deleteFile({recordId: deleteId}).then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Attachment deleted successfully',
                variant: 'success'
            }));

            for(let opp in this.existingAllFiles) {
                if(this.existingAllFiles[opp].Id == deleteId) {
                    this.existingAllFiles.splice(opp, 1);
                    break;
                }
            }

            this.getAttachmentsFromServer();   
        }).catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
    }

    showToast(title, message, variant) {
        let mode = (variant === 'success') ? 'dismissible' : 'sticky';
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
     
    //W-11122431 Change Date Format for Case CreatedDate
    getFormattedDate(value) {
        var dateWithTimeZone = new Date(value).toLocaleString("en-US", {timeZone: this.timeZone})
        let date = new Date(dateWithTimeZone);

        const day = date.toLocaleString('default', { day: '2-digit' });
        const month = date.toLocaleString('default', { month: 'short' });
        const year = date.toLocaleString('default', { year: 'numeric' });
        return day + '-' + month + '-' + year;
     }
}