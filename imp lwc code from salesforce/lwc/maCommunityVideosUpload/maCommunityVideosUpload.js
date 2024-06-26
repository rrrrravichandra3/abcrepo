import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordDetails from '@salesforce/apex/MA_CommunityVideoUpload.getRecordDetails';
import updateContentVersion from '@salesforce/apex/MA_CommunityVideoUpload.updateData';
import deleteContentVersion from '@salesforce/apex/MA_CommunityVideoUpload.deleteFile';
import updateContentDocumentLink from '@salesforce/apex/MA_CommunityVideoUpload.updateContentDocumentLink';
import { reduceErrors } from 'c/maErrorHandlingUtility';


export default class MaCommunityVideosUpload extends LightningElement {
    @api recordId;
    @track contentVersions = [];
    isError = false;
    contentVersionsBackup = [];
    previewVideo = false;
    parentRecordId = '';
    showSpinner = true;
    videoLink = '';
    acceptedFormats = ['.WEBM','.MPG','.MP2','.MPEG','.MPE','.MPV','.OGG','.MP4','.M4P','.M4V','.AVI','.WMV','.MOV','.QT','.FLV','.SWF','.AVCHD'];

    saveElement(event){
        const index = event.currentTarget.dataset.index
        
        this.updateDataServer(index);    
    }

    updateDataServer(index){
        if(this. validateData(index)){
            return;
        }
        this.contentVersions[index].IsEdit = false
        this.showSpinner = true;
        updateContentVersion({objContentVersion : this.contentVersionsBackup[index]})
        .then(data => {
            this.contentVersions[index].Title = this.contentVersionsBackup[index].Title
            this.contentVersions[index].Description = this.contentVersionsBackup[index].Description
            this.showSpinner = false;
        }).catch(error => this.showError(error));
    }

    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
       
        this.getInitData();
        this.enableFileForCommunity(uploadedFiles[0].documentId);
    }

    enableFileForCommunity(documentId){
        updateContentDocumentLink({contentDocumentId: documentId}).then(data => {})
        .catch(error => this.showError(error));
    }

    validateData(index){
        let hasError = false;
        const description   = this.template.querySelector("[data-textarea='"+index+"']");
        const title         = this.template.querySelector("[data-title='"+index+"']");
        
        /*
        if(!description.value){
            description.setCustomValidity('Please enter description');
            description.reportValidity();
            hasError = true;
        }else 
        */
        if(description.value && description.value.length > 1000){
            description.setCustomValidity('Description should be less than 1000 characters');
            description.reportValidity();
            hasError = true;
        }else{
            description.setCustomValidity('');
            description.reportValidity();
        }

        if(!title.value){
            title.setCustomValidity('Please enter Title');
            title.reportValidity();
            hasError = true;
        }else if(title.value.length > 1000){
            title.setCustomValidity('Title should be less than 255 characters');
            title.reportValidity();
            hasError = true;
        }else{
            title.setCustomValidity('');
            title.reportValidity();
        }

        return hasError;
    }

    disableEdit(event){
        const index = event.currentTarget.dataset.index
        this.contentVersions[index].Title = this.contentVersions[index].Title
        this.contentVersions[index].Description = this.contentVersions[index].Description
        this.contentVersions[index].IsEdit = false;
    }

    enableItemEdit(event){
        this.contentVersions[event.currentTarget.dataset.index].IsEdit = true;
    }

    enableVideoModal(event){
        const index = event.currentTarget.dataset.index
        const FileExtension = this.contentVersions[index].FileExtension;
        this.previewVideo = true
        this.videoLink = '/sfc/servlet.shepherd/version/download/'+ this.contentVersions[index].Id
    }

    deleteVideo(event){
        const index = event.currentTarget.dataset.index
        this.showSpinner = true;
        deleteContentVersion({contentDocumentId : this.contentVersionsBackup[index].ContentDocumentId})
        .then(data => {
            this.showToast('Success', 'Success', 'File Deleted Successfully!') 
            this.getInitData();
        }).catch(error => this.showError(error));
    }

    closeModal(){
        this.previewVideo = false
    }

    connectedCallback(){
        this.getInitData();
    }

    getInitData(){
        this.showSpinner = true;
        getRecordDetails({recordId:this.recordId})
        .then(data =>{
            
            this.parentRecordId = Object.keys(data)[0];
            this.contentVersions = data[this.parentRecordId].map(element => ({...element, ContentSize : this.bytesToSize(element.ContentSize), IsEdit : false}) );
            this.contentVersionsBackup = JSON.parse(JSON.stringify(data[this.parentRecordId]))
            this.showSpinner = false;
            let activeSectionNames = [];
            if(this.contentVersions[0]){
                activeSectionNames.push(this.contentVersions[0].Id)
                const accordion = this.template.querySelector('.videoAccordion');
                setTimeout(() =>{ accordion.activeSectionName = activeSectionNames}, 2000);
            }
            
        }).catch(error => {
            this.showError(error)
            this.isError = true;
        });
    }

    bytesToSize(bytes) {
        var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        if (bytes == 0) return '0 Byte';
        var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
        return parseFloat(bytes / Math.pow(1024, i)).toFixed(2) + ' ' + sizes[i];
     }

    mapValuesToList(event){
        const value = event.target.value;
        const index = event.currentTarget.dataset.index
        const field = event.currentTarget.dataset.field
        this.contentVersionsBackup[index][field] = value
    }

    removeReceiptImage() {
        this.fileName = '';
        this.fileContent = '';
    }

    showToast(title, variant, message) {
        
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }

    showError(error){
        console.log(error)
        this.showToast('Error', 'error',  reduceErrors(error));
        this.removeReceiptImage();
        this.showSpinner = false;
        
    }
}