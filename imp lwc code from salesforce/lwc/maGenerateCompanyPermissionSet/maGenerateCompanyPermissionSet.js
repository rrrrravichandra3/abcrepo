import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SETTING_UP_PERMISSION_SETS from '@salesforce/label/c.MA_Setting_Up_Permission_Sets';
import PERMISSION_SET_COMPLETION_MESSAGE from '@salesforce/label/c.MA_Permission_Set_Completion';
import setupContentSharingPermissions from '@salesforce/apex/MA_GenerateCompanyPermissionSet.setupContentSharingPermissions';

export default class MaGenerateCompanyPermissionSet extends LightningElement {
    @api recordId;
    showSpinner = true;

    @api invoke() {
        setupContentSharingPermissions({companyId: this.recordId}).then((result) => {
            eval("$A.get('e.force:refreshView').fire();");
            this.showCreatingPermissionsMessage();
            this.dispatchEvent(new CloseActionScreenEvent());
        }).catch((error) => {
            this.showErroMessage(error);
        });
    }

    showCreatingPermissionsMessage() {
        this.showSpinner = false;
        const title = SETTING_UP_PERMISSION_SETS;
        const message = PERMISSION_SET_COMPLETION_MESSAGE;
        this.dispatchEvent(new ShowToastEvent({"title" : title, "message" : message, "variant" : "success"}));
    }

    showErroMessage(error) {
        this.showSpinner = false;
        const unknownError = 'Unknown error';
        let errorMessage = Array.isArray(error.body) ? error.body.map(e => e.message).join(', ') : 
                           (typeof error.body.message === 'string') ? error.body.message : unknownError;
        this.dispatchEvent(new ShowToastEvent({"title" : "Error", "message" : errorMessage, "variant" : "error"}));
    }
}