import { LightningElement, api } from "lwc";

export default class QFooter extends LightningElement {
  @api isAbsolute;

  get positionAbsolute() {
    if (this.isAbsolute) {
      return "container-div slds-is-absolute";
    }
    return "container-div";
  }
}