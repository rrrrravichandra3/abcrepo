import { LightningElement, track, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MODE_FIELD from "@salesforce/schema/User.Mentoring_Mode__c";
import MENTEE_LOCATION_FIELD from '@salesforce/schema/User.Mentee_Location_Preference__c';
import MENTOR_LOCATION_FIELD from '@salesforce/schema/User.Mentor_Location_Preference__c'
import MENTEE_TYPE_FIELD from '@salesforce/schema/User.Mentee_Type_Preference__c';
import MENTOR_TYPE_FIELD from '@salesforce/schema/User.Mentor_Type_Preference__c';
import Id from "@salesforce/user/Id";

import typeOfMentoringLabel from "@salesforce/label/c.location_Type_of_Mentoring";
import lookingForAMenteeInLabel from "@salesforce/label/c.location_Looking_for_a_mentee_in";
import lookingForAMentorInLabel from "@salesforce/label/c.location_Looking_for_a_mentor_in";
import mentorLabel from "@salesforce/label/c.mentor";
import menteeLabel from "@salesforce/label/c.mentee";

export default class locationPreferences extends LightningElement {
  userId = Id;
  menteeLocationPreferenceField = MENTEE_LOCATION_FIELD;
  mentorLocationPreferenceField = MENTOR_LOCATION_FIELD;
  menteeTypeField = MENTEE_TYPE_FIELD;
  mentorTypeField = MENTOR_TYPE_FIELD;

  @track user;
  @track loading;

  labels = {
    typeOfMentoringLabel,
    lookingForAMenteeInLabel,
    lookingForAMentorInLabel
  };

  connectedCallback() {
    this.loading = true;
  }

  get capitalMentorLabel() {
    return mentorLabel.toUpperCase();
  }

  get capitalMenteeLabel() {
    return menteeLabel.toUpperCase();
  }

  // Load User Record
  @wire(getRecord, {
    recordId: "$userId",
    fields: [MODE_FIELD]
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.showNotification(
        "Oops",
        `Error loading User Details ${error.body.message}`,
        "error"
      );
      //eslint-disable-next-line
      console.error(error);
      this.loading = false;
    } else if (data) {
      this.user = data;
      this.loading = false;
    }
  }

  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(evt);
  }

  get activeTab() {
    return getFieldValue(this.user, MODE_FIELD) === "Mentee" ? "tab2" : "tab1";
  }
}