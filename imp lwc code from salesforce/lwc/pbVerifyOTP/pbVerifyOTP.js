import { LightningElement } from 'lwc';
import inokeLogin from '@salesforce/apex/PBLoginPOC.inokeLogin';
import preboardingResources from '@salesforce/resourceUrl/preboardingResources';

export default class PbVerifyOTP extends LightningElement {
    _sfLogo = preboardingResources + '/preboardingResources/sflogo2.png';
    _bg1 = preboardingResources + '/preboardingResources/mountainbackground.png';
    _bg2 = preboardingResources + '/preboardingResources/astrobag.png';
    _bg3 = preboardingResources + '/preboardingResources/bg3.png';
    _bg4 = preboardingResources + '/preboardingResources/bg4.png';
    _bg5 = preboardingResources + '/preboardingResources/bg5.png';

    handleLogin(event) {
        let inputs = this.template.querySelectorAll('input');
        inokeLogin({ username:inputs[0].value , pwd: inputs[1].value })
        .then(result => {
            console.log(result);
            window.open(result,"_self")
        })
        .catch(error => {
            console.log(error)
        });
    }
}