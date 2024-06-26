import { LightningElement } from 'lwc';
import getRedirectURL from "@salesforce/apex/PB_CommLoginRedirectService.getRedirectURL";
export default class PbLoginFormV2 extends LightningElement {
    connectedCallback() {
        getRedirectURL()
        .then((result) => {
            location.href = result;
          })
        .catch(() => {
            console.log('Internal Server Error');
        });
    }
}