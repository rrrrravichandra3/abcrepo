import { LightningElement, api, wire, track} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import relatedAcquisitionRecordsHeader from '@salesforce/label/c.MA_RelatedAcquisitionRecordsHeader';
import noRelatedAcquisitionRecords from '@salesforce/label/c.MA_NoRelatedAcquisitionRecords';
import OBJECT_API_Name from '@salesforce/schema/MA_My_Info_Updates__c.Object_API_Name__c';
import OBJECT_RECORD_ID from '@salesforce/schema/MA_My_Info_Updates__c.Record_Id__c';
import getRelatedAcquisitionRecords from '@salesforce/apex/MA_RelatedAcquisitionRecordsController.getAcquisitionWrapperList';

const fields = [OBJECT_API_Name, OBJECT_RECORD_ID];
const errorMessage = 'Somethig went wrong. Please contact system administrator'; 
export default class MaMyCasesListView extends LightningElement {
    label = {
        relatedAcquisitionRecordsHeader,
        noRelatedAcquisitionRecords
    };

    @track acquisitionWrapper;
    @api recordId;
    myInfoUpdate;
    objectName;
    objectId;

    @wire(getRecord, { recordId: '$recordId', fields })
    MA_My_Info_Updates__c({ error, data }) {
        if (error) {
            this.showErrorToast();
        } else if (data) {
            this.isLoading = true;
            this.myInfoUpdate = data;
            this.objectName = this.myInfoUpdate.fields.Object_API_Name__c.value;
            this.objectId = this.myInfoUpdate.fields.Record_Id__c.value;
            this.getRelatedAcquisitionRecordDetails();
        }
    }

    showErrorToast() {   
        if(this.acquisitionWrapper == undefined){
            errorMessage = this.label.noRelatedAcquisitionRecords;   
        }
            const evt = new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
    }

    getRelatedAcquisitionRecordDetails(){
        getRelatedAcquisitionRecords({acquisitionObjectId : this.objectId, objectName : this.objectName})
                .then(result =>{

                    this.acquisitionWrapper = result;
                    this.error = undefined;
                    this.isLoading = false;
                    
                    if(this.acquisitionWrapper.length == 0){
                        this.showNoRecords = true;
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.acquisitionWrapper = undefined
                    this.isLoading = false;
                    this.showErrorToast();
                })
        }        
}