import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import getlstEmailTemplateOptions from '@salesforce/apex/IA_RetriggerEmailToCandidate.getListEmailTempalte';
import sendEmails from '@salesforce/apex/IA_RetriggerEmailToCandidate.sendEmails';
import isProgramAdmin from '@salesforce/apex/IA_RetriggerEmailToCandidate.isProgramAdmin';
import LightningConfirm from 'lightning/confirm';
export default class IA_ReTriggerEmailToCandidate extends LightningElement {
    @track ids;
    @track templateOptions;
    @api selectedTemplate;
    @api isProgramAdmin;
    @api hasError = false;
    @api errorMessage;
    @track btnDisabled=true;
    @api isProcessing;
    @api recordCount = 0;
    @track documetntURL='https://confluence.internal.salesforce.com/display/BTEES/Retrigger+Insiders+Invitations';

    connectedCallback() {
        isProgramAdmin({})
        .then(data => {
            this.isProgramAdmin = data;
            if(!this.isProgramAdmin){
                this.hasError = true;
                this.errorMessage = 'Insufficient Priviliges';
            }
        })
        .catch(error => {
            console.log('error' + error.body.message);
            this.hasError =true;
            this.errorMessage=error.body.message;
        }); 
    }

    selectEmailTemplateHandler(event){
        this.selectedTemplate = event.target.value;
        this.buttonCheckMethod();
        this.compareIds(this.ids);
    }
    emailAddressHandler(event){
        this.ids = event.target.value;
        this.hasError =false;
        if(this.ids.length >=15){
            this.recordCount=0;
            if(this.compareIds()){
                this.recordCount = this.recordJobAppCount();
                if(this.recordCount > 50){
                    this.hasError =true;
                    this.errorMessage='Please, enter maximum 50 record ids.';
                }
                else{
                    getlstEmailTemplateOptions({
                        recordids : this.ids
                    })
                    .then(data => {
                        this.templateOptions = data;     
                    })
                    .catch(error => {
                        console.log('error' + error.body.message);
                        this.hasError =true;
                        this.errorMessage=error.body.message;
                    }); 
                }
            }
            else{
                console.log('Record ids not matched');
                this.hasError =true;
                this.errorMessage='One or more given Ids are not related to WD Job Application';
            }
        }
    }

    async sendEMailsToCandidate(){
        this.hasError =false;
        if(this.recordJobAppCount() > 50){
            this.hasError =true;
            this.errorMessage ='Please, enter maximum 50 record ids.';
        }
        else{
            const result = await LightningConfirm.open({ 
                message: 'Please, confirm \'OK\' to send email invitations', 
                theme: 'warning', 
                label: 'Please Confirm', 
                variant: 'header', 
                defaultValue: '', 
            });
            if(result == true){
                this.isProcessing=true;
                sendEmails({
                    recordIds : this.ids,
                    emailTemplate : this.selectedTemplate
                })
                .then(data => {
                    if(data){
                        this.isProcessing = false;
                        this.showNotification();
                    }
                })
                .catch(error => {
                    this.isProcessing = false;
                    console.log('error' + error.body.message);
                    this.hasError =true;
                    this.errorMessage=error.body.message;
                });
            }
        }
        
    }

    buttonCheckMethod(){
        if(this.selectedTemplate!='' && this.ids!='' && this.selectedTemplate!=undefined){
            this.btnDisabled=false;
        }
        else{
            this.btnDisabled=true;
        }
    }

    showNotification() {
        this.dispatchEvent(
            new ShowToastEvent({
                      title: 'Email to Candidate',
                      message: 'Successfully Sent Invitation to Candidate',
                      variant: 'Success',
                      mode: 'dismissable'
                  })
         );
    }

    recordJobAppCount(){
        var rec = this.ids.split(';');
        var reccount=0;
        for(var i=0; i<rec.length;i++){
            if(rec[i].trim() !== ''){
                reccount = reccount+1;
            }
        }
        return reccount;
    }
    compareIds(){
        var re = this.ids.split(';');
        let startValue= re[0].substring(0,3).trim();
        for(var i=0; i<re.length;i++){
            let recid=re[i].trim();
            if(recid.substring(0,3) !== '' && recid.substring(0,3) !== startValue){
                return false;
            }
        }
        return true;
    }
}