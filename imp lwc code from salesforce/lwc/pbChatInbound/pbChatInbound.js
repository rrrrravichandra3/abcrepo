import { LightningElement, api } from 'lwc';

export default class PbChatInbound extends LightningElement {
    @api commentBody;
    @api createdBy;
    @api createdDate;

    firstName = 'Salesforce Interal';
    timestamp;
   
    connectedCallback() {
        if(this.createdDate){
            this.timestamp = new Date(this.createdDate).toLocaleTimeString([], {
                hour: '2-digit',
                minute: '2-digit'
            });
        }
    }
}