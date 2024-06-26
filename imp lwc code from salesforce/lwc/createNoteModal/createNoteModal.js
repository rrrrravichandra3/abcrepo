import { LightningElement, api } from "lwc";

export default class CreateNodeModal extends LightningElement {
  handleConfirm(event) {
    let content = this.template.querySelector("lightning-textarea").value;
    //leaving this as JSON to accomodate future enhancements
    let note = {
      content: content
    };

    const createNoteEvent = new CustomEvent("createnoteandclose", { detail: note });
    this.dispatchEvent(createNoteEvent);
    event.target.disabled = true;
  }

  handleCancel() {
    const closeModalEvent = new CustomEvent("closemodal");
    this.dispatchEvent(closeModalEvent);
  }
}