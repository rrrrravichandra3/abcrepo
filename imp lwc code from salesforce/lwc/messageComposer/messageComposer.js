import { LightningElement, track, api } from "lwc";
import yourMessageLabel from "@salesforce/label/c.message_your_message";

export default class MessageComposer extends LightningElement {
  @track message;
 @api heading;
  @api inputLabel;
  @api buttonLabel;

  labels = {yourMessageLabel};

  inputChangeHandler(event) {
    //this[event.target.name] = event.target.value;
    this.message = event.target.value;
    this.dispatchEvent(new CustomEvent("message", { detail: this.message }));
  }

  cancelClicked() {
    this.dispatchEvent(new CustomEvent("cancel"));
  }

  sendRequestClicked() {
    this.dispatchEvent(new CustomEvent("submit", { detail: this.message }));
  }

}