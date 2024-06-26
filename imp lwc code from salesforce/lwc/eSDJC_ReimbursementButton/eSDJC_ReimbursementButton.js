import { LightningElement,api } from 'lwc';
import queryResult from "@salesforce/apex/ESDJC_Reimbursement_Integrations_Service.processClaimsForSingleClaim";
export default class ESDJC_ReimbursementButton extends LightningElement {
    @api recordId;

    handleClick(event) {
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