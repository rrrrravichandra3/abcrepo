/**
 * @description       :
 * @author            : Venkata Akash Patti (akashpatti)
 * @group             :
 * @last modified on  : 06-28-2022
 * @last modified by  : Urvish Shah (ushah)
 **/

import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import createChatterPost from "@salesforce/apex/CEMCI_ManageCandidatePool.createChatterPost";
import removeCandidateFromPool from "@salesforce/apex/CEMCI_ManageCandidatePool.removeCandidateFromPool";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class DragAndDropCard extends NavigationMixin(LightningElement) {
  @api stage;
  @api record;
  displayNoteModal = false;

  get isSameStage() {
    return this.stage === this.record.stage;
  }

  get isSourceCandidate() {
    return this.stage == "Sourced Candidate";
  }

  itemDragStart() {
    const event = new CustomEvent("itemdrag", {
      detail: this.record
    });
    this.dispatchEvent(event);
  }

  openRecord(event) {
    let recId = event.target.dataset.id;
    console.log(event);
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: recId,
        actionName: "view"
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  }

  openLinkedInProfile(event) {
    let url = event.target.dataset.id;
    window.open(url, "_blank");
  }

  openNoteModal() {
    this.displayNoteModal = true;
  }

  createNoteAndClose(event) {
    createChatterPost({
      content: event.detail.content,
      parentId: this.record.candidateId
    })
      .then((result) => {
        this.closeModal();
        this.showToast("Success", "Notes Posted to chatter on the Contact!", "success");
      })
      .catch((error) => {
        console.log("In error:: " + JSON.stringify(error));
        this.closeModal();
        this.showToast("Error!", "Error while saving notes!", "error");
      });
  }

  removeFromPool(event) {
    removeCandidateFromPool({
      id: this.record.id
    })
      .then((result) => {
        const event = new CustomEvent("removefrompool", {
          detail: this.record.id
        });
        this.dispatchEvent(event);
      })
      .catch((error) => {
        console.log("In error:: " + JSON.stringify(error));
        this.showToast("Error!", "Error while removing candidate from pool", "error");
      });
  }

  closeModal() {
    this.displayNoteModal = false;
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
}