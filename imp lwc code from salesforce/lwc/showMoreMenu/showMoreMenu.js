import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import ID_FIELD from "@salesforce/schema/User.Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import PHOTO_FIELD from "@salesforce/schema/User.MediumPhotoUrl";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import AVAILABLE_FIELD from "@salesforce/schema/User.Available__c";
import MODE_FIELD from "@salesforce/schema/User.Mentoring_Mode__c";
import Id from "@salesforce/user/Id";

import loggedInAsLabel from "@salesforce/label/c.menu_Logged_in_as";

export default class ShowMoreMenu extends NavigationMixin(LightningElement) {
  userId = Id;

  @track loading = false;
  @track user;
  @track showProfile = false;

  @track mode = "mentor";

  labels = {loggedInAsLabel};

  connectedCallback() {
    this.loading = true;
  }

  // Load User Record
  @wire(getRecord, {
    recordId: "$userId",
    fields: [ID_FIELD, NAME_FIELD, PHOTO_FIELD, EMAIL_FIELD, AVAILABLE_FIELD, MODE_FIELD, CAREER_FIELD, WELLNESS_FIELD],
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.showNotification("Oops", `Error loading User Details ${error.body.message}`, "error");
      this.loading = false;
    } else if (data) {
      this.user = data;
      this.mode = this.user.fields[MODE_FIELD.fieldApiName].value === "Mentor" ? "mentor" : "mentee";
      this.loading = false;
    }
  }

  async switchHandler(event) {
    this.loading = true;
    try {
      const fields = {};
      const newMode = event.detail;
      fields.Id = this.userId;
      fields[MODE_FIELD.fieldApiName] = newMode;
      const recordInput = { fields };
      await updateRecord(recordInput);
      this.loading = false;
      this.showNotification(undefined, `Switched to ${newMode} Mode`);
    } catch (error) {
      this.loading = false;
      this.showNotification("Oops", error.body.message, "error");
    }
  }

  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant,
    });
    this.dispatchEvent(evt);
  }

  toggleProfile() {
    this.showProfile = !this.showProfile;
  }

  viewUserProfile() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.userId,
        objectApiName: "User",
        actionName: "view",
      },
    });
  }

  // GETTERS
  get switchLabel() {
    if (this.user) {
      const alternativeMode = this.user.fields[MODE_FIELD.fieldApiName].value === "Mentor" ? "Mentee" : "Mentor";
      return `Switch to ${alternativeMode} Mode`;
    }
    return null;
  }

  get mentoringMode() {
    return getFieldValue(this.user, MODE_FIELD);
  }

  get containerClasses() {
    if (this.showProfile) {
      return "slds-is-relative no-scroll";
    }

    return "slds-is-relative";
  }
}