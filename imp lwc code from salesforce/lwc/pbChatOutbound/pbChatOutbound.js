import { LightningElement, api } from 'lwc';

export default class PbChatOutbound extends LightningElement {
    @api commentBody;
    @api createdBy
    @api createdDate;

    firstName;
    lastName;
    firstInitial;
    lastInitial;
    timestamp;

    connectedCallback() {
        if(this.createdBy) {
            let name = this.createdBy.split(' ');
            this.firstName = name[0];
            this.lastName = name[1];
            this.firstInitial = this.firstName.charAt(0).toUpperCase();
            this.lastInitial = this.lastName.charAt(0).toUpperCase();
        }

        if(this.createdDate){
            this.timestamp = new Date(this.createdDate).toLocaleTimeString([], {
                hour: '2-digit',
                minute: '2-digit'
            });
        }
       
    }
}