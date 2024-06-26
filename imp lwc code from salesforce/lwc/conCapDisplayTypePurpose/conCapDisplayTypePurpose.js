import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class ConCapDisplayTypePurpose extends NavigationMixin(LightningElement) {
  @api item;

  // get the icon name based on the state of the component
  get iconState() {
    return this.item.consentIcon === "Opt In"
      ? "utility:check"
      : this.item.consentIcon === "Opt Out" || this.item.consentIcon === "Prohibited"
      ? "utility:close"
      : "utility:warning";
  }

  // get the title of the icon variant based on the state of the component
  get iconStateVariant() {
    return this.item.consentIcon === "Opt In"
      ? "success"
      : this.item.consentIcon === "Opt Out" || this.item.consentIcon === "Prohibited"
      ? "error"
      : "warning";
  }

  // get the title of the icon based on the state of the component
  get iconStateTitle() {
    return this.item.consentIcon === "Opt In" ? "Valid" : "Unsubscribed/Expired";
  }

  // get the alternative text of the icon to based on the state of the component
  get iconStateAlternativeText() {
    return this.item.consentIcon === "Opt In" ? "Valid" : "Unsubscribed/Expired";
  }

  // get the alternative text of the icon to based on the state of the component
  get activeStyle() {
    return this.item.consentIcon === "Opt In" ? "" : "background-color:#f4f6f9;border-bottom: 2px solid red";
  }

  viewRecord() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.item.consentId != null ? this.item.consentId : this.item.dataUsePurposeId,
        objectApiName: "contactPointTypeConsent",
        actionName: "view"
      }
    });
  }
}