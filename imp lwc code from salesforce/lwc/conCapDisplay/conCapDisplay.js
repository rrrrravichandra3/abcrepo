import { LightningElement, api, track, wire } from "lwc";
import getSObjectType from "@salesforce/apex/IndividualUtilities.getSObjectType";
import getIndividualId from "@salesforce/apex/IndividualUtilities.getIndividualId";
import getIndividualConsent from "@salesforce/apex/ConsentCaptureService.getIndividualConsent";

export default class ConCapDisplay extends LightningElement {
  //Data
  @api recordId;
  @api individualId = {};
  @track sObjectType;
  @track relatedCPTCRecords = {};

  //State
  @track loading = true;

  connectedCallback() {
    this.getIndividualId();
    this.getIndividualConsent();
  }

  getIndividualId() {
    getIndividualId({ recordId: this.recordId })
      .then((data) => {
        this.individualId = data;
        this.bubbleIndividualId(data);
      })
      .catch((error) => {
        this.error = error;
      });
  }

  getIndividualConsent() {
    getIndividualConsent({ recordId: this.recordId })
      .then((data) => {
        this.relatedCPTCRecords = data;
        this.endLoading();
      })
      .catch((error) => {
        this.error = error;
        this.endLoading();
      });
  }

  @wire(getSObjectType, { recordId: "$recordId" })
  getSObjectType(result) {
    if (result.error) {
      this.error = result.error;
    } else if (result.data) {
      this.sObjectType = result.data;

      this.bubbleSObjectType(result.data);
    }
  }

  get hydratedConsentRecords() {
    return this.relatedCPTCRecords.length >= 1;
  }

  endLoading() {
    this.loading = false;
  }

  bubbleIndividualId(value) {
    const sendIndividualId = new CustomEvent("individualset", {
      detail: { value }
    });
    // Fire the custom event
    this.dispatchEvent(sendIndividualId);
  }

  bubbleSObjectType(value) {
    const sendSObjectType = new CustomEvent("sobjectset", {
      detail: { value }
    });
    // Fire the custom event
    this.dispatchEvent(sendSObjectType);
  }
}