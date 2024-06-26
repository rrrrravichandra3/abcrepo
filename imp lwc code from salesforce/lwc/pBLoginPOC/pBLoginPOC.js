import { LightningElement, api, track, wire } from 'lwc';
import communityPath from '@salesforce/community/basePath';
import inokeLogin from '@salesforce/apex/PBLoginPOC.inokeLogin';
export default class PBLoginPOC extends LightningElement {

    
    handleLogin(){
        
        inokeLogin()
        .then(result => {
            console.log(result);
            window.open(result,"_self")
        })
        .catch(error => {
            console.log(error)
        });
    }
}