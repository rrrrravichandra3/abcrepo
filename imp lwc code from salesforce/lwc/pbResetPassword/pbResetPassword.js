import { LightningElement } from 'lwc';
import preboardingResources from '@salesforce/resourceUrl/preboardingResources';
import resetPwd from '@salesforce/apex/PBLoginPOC.resetPwd';

export default class PbResetPassword extends LightningElement {
    _sfLogo = preboardingResources + '/preboardingResources/sflogo2.png';
    _bg1 = preboardingResources + '/preboardingResources/mountainbackground.png';
    _bg2 = preboardingResources + '/preboardingResources/astrobag.png';
    _bg3 = preboardingResources + '/preboardingResources/bg3.png';
    _bg4 = preboardingResources + '/preboardingResources/bg4.png';
    _bg5 = preboardingResources + '/preboardingResources/bg5.png';
    _success=false;
    handleReset(event) {
        let input = this.template.querySelector('input');
        resetPwd({ username:input.value })
        .then(result => {
            console.log(result);
            this._success = true;
            this.showToast('Success! Check your Email for link',true);

        })
        .catch(error => {
            console.log(error);
            this.showToast('Error while trying to reset password',false);
        });
    }

    showToast(msg,iserror) {
        this.template.querySelector('c-pb-toast-message').showToast(msg,iserror); //show toast
    }
  

}