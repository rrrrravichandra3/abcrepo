/**
 * Created by kmoseley on 5/6/22.
 */

import { LightningElement, api } from "lwc";

export default class LaunchCandidateFinder extends LightningElement {
  @api recordId;
  @api objectApiName;

  @api invoke() {
    if (this.objectApiName === "Talent_Pipeline__c") {
      window.location.replace("/lightning/n/Candidate_Search?c__recordId=" + this.recordId);
    }
    if (this.objectApiName === "WDR_Job__c") {
      window.location.replace("/lightning/n/Candidate_Finder_Tab?c__recordId=" + this.recordId);
    }
  }
}