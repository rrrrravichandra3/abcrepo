import { LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class iDP_Utils extends LightningElement {

    //================================================== UTIL METHODS ==================================================
    // Method to set Toast
    static setToast(cmp, errorTitle, errorMessage, toastVariant, mode) {
        cmp.dispatchEvent(
            new ShowToastEvent({
                title: errorTitle,
                message: errorMessage,
                "messageData": [
                    {
                        url: 'https://concierge.it.salesforce.com/articles/en_US/Supportforce_Article/IDP-Troubleshooting',
                        label: 'Concierge Ticket'
                    }
                ],
                variant: toastVariant,
                mode: mode
            })
        );
    }

    // Method to fire custom event
    static fireCustomEvent(cmp, eventName,paramData){
        let ev = new CustomEvent(eventName,
            { detail: paramData, bubbles: true }
        );
        cmp.dispatchEvent(ev);
    }

}