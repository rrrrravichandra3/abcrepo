/**
 * @description       :
 * @author            : Venkata Akash Patti (akashpatti)
 * @group             :
 * @last modified on  : 06-14-2022
 * @last modified by  : Venkata Akash Patti (akashpatti)
 **/

import { LightningElement, api } from "lwc";
import hasAccess from "@salesforce/apex/CEMCI_ManageCandidatePool.hasAccess";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LaunchManageCandidatePool extends LightningElement {
  @api recordId;

  @api invoke() {
    this.hasAccessManageCandidatePool();
  }

  hasAccessManageCandidatePool() {
    hasAccess({ jobRecId: this.recordId })
      .then((result) => {
        this.navigateToManageCandidatePool(result);
        return result;
      })
      .catch((error) => {
        console.log("In error:: " + JSON.stringify(error));
      });
  }

  navigateToManageCandidatePool(hasAccess) {
    if (hasAccess) {
      window.location.replace("/lightning/n/manage_candidate_pool_tab?c__recordId=" + this.recordId);
    } else {
      this.fireToastEvent(
        "Error!",
        "You cannot manage this requistion as you are not the hiring manager nor have CEMCI permission sets",
        "error"
      );
    }
  }

  fireToastEvent(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }
}