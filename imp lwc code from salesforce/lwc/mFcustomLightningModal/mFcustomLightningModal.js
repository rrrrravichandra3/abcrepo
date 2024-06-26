import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
export default class MFcustomLightningModal extends LightningModal {
    @api cancelLabel = "";
  @api saveLabel = "";
  @api hideFooter = false;
  @api saveDisabled = false;
  @api footerCentered = false;
  @api inputLabel = '';
  @api heading = '';
  @api buttonLabel = '';
  @track message =  '';
  @api showMessageComposer = false;
  @api showDismissModal = false;
  @api dismissalReason= '';
    @api reasonvalues;
  
  /*labels = {
    writeSomethingAboutYourselfLabel,
    mentorRequestLabel,
    sendRequestLabel
  }*/

  get filterModalActive() {
    return this.filterModal && this.filtersChanged;
  }

  get buttonClass(){
    return this.footerCentered ? 'slds-align_absolute-center' : '';
  }

  cancelClickedHandler() {
    //this.dispatchEvent(new CustomEvent("cancel"));
    this.close();
  }

  saveClickedHandler() {
    this.dispatchEvent(new CustomEvent("primaryevent"));
  }

  closeClickedHandler() {
    this.dispatchEvent(new CustomEvent("close"));
  }

  cancelClickedHandler(){
    this.close('cancel');
  }
 /* saveClickedHandler(){
    this.close('save');
  }*/

  submitClickedhandler() {    
    this.close('primaryevent');
  }

  handleMessage(event){   
    this.message = event.detail;
  }

  showDismissModal() {
    this.close(this.message);
}

handleReasonChange(event){
  this.dispatchEvent(
      new CustomEvent("reasonchange", {
          bubbles: true, 
          composed: true,
          detail: event.detail
      })
  );
    }

  handleDismissalInformationChange(event){
    this.dispatchEvent(
        new CustomEvent("informationchange", {
            bubbles: true, 
            composed: true,
            detail: event.detail
        })
    );
}
}