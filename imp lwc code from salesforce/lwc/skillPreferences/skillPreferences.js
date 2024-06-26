import { LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MODE_FIELD from "@salesforce/schema/User.Mentoring_Mode__c";
import SKILLS_FIELD from '@salesforce/schema/User.Skills__c';
import SKILLS_IMPROVE_FIELD from '@salesforce/schema/User.Skills_to_Improve__c';
import Id from "@salesforce/user/Id";

import professionalSkillsLabel	from "@salesforce/label/c.preference_Professional_Skills";
import mySkillsLabel	from "@salesforce/label/c.preference_My_Skills";
import skillsIWantToImproveLabel	from "@salesforce/label/c.preference_Skills_I_want_to_improve";
import menteeLabel from "@salesforce/label/c.mentee";
import mentorLabel from "@salesforce/label/c.mentor";

export default class skillPreferences extends LightningElement {
  userId = Id;
  skillsField = SKILLS_FIELD;
  skillsImproveField = SKILLS_IMPROVE_FIELD;

  @track user;
  @track loading;

  labels = {
    professionalSkillsLabel,
    mySkillsLabel,
    skillsIWantToImproveLabel
  };

  connectedCallback() {
    this.loading = true;
  }

  get mentorAllCapsLabel(){
    return mentorLabel.toUpperCase();
  }

  get menteeAllCapsLabel(){
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