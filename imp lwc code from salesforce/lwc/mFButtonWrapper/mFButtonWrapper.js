import { LightningElement, api } from 'lwc';

export default class MFButtonWrapper extends LightningElement {
    @api
    message;
    @api primarybuttonlabel = '';
    @api secondarybuttonlabel = '';
    @api primbuttondisabled = false;
    //@api 
    handlePrimaryAction() {
        console.log('Are you sending?'+this.message)
        this.dispatchEvent(
            new CustomEvent("primaryevent", {
                bubbles: true, 
                composed: true,
                detail: {
                    message: this.message
                }
            })
        );
    }

    handleSecondaryAction() {
        console.log('Are you sending1?')
        this.dispatchEvent(
            new CustomEvent("secondaryevent", {
                bubbles: true, 
                composed: true,
                detail: {
                    message: this.secondarybuttonlabel
                }
            })
        );
    }
}