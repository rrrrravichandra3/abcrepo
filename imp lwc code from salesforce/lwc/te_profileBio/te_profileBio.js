import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';

export default class Te_profileBio extends LightningElement {
    @track isEditing = false;
    @track showSpinner = false;
    @api recordId; // Contact record ID passed to the component
    profileValue;

    @wire(getRecord, { recordId: '$recordId', fields: ['Contact.te_Profile__c'] })
    wiredRecord({ data, error }) {
        if (data) {
            // Extract the field value from the record
            this.profileValue = data.fields.te_Profile__c.value;
        } else if (error) {
            // Handle error
            console.error('Error loading record: ', error);
        }
    }

    handleEditClick() {
        this.isEditing = true;
    }

    handleCancelClick() {
        this.isEditing = false;
    }

    // Handle changes in the textarea
    handleChange(event) {
        this.profileValue = event.target.value;
    }

    handleSave() {
        // Update record using updateRecord
        this.showSpinner = true;
        const fields = {};
        fields['Id'] = this.recordId;
        fields['te_Profile__c'] = this.profileValue;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                // Reset to view mode after successful update
                this.isEditing = false;
                this.showSpinner = false;
            })
            .catch(error => {
                // Handle error
                this.showSpinner = false;
                console.error('Error updating record: ', error);
            });
    }
    
}