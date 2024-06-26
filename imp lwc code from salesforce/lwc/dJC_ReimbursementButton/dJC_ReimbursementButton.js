import { LightningElement, api } from 'lwc';
import processClaimsForSingleClaim from "@salesforce/apex/ESDJC_Reimbursement_Integrations_Service.processClaimsForSingleClaim";
export default class eSDJC_ReimbursementButton extends LightningElement {
    @api recordId;
    @api async invoke() {
        console.log('check the recordid',this.recordId);
        processClaimsForSingleClaim({ claimid: this.recordId})
        .then((result) => {
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.contacts = undefined;
        });
        }  

       
        
    

}