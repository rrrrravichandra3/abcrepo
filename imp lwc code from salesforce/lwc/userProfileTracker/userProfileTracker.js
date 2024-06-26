import { LightningElement, api, wire, track } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import MODE_FIELD from "@salesforce/schema/User.Mentoring_Mode__c";
import NAME_FIELD from "@salesforce/schema/User.Name";
import IMAGE_FIELD from "@salesforce/schema/User.MediumPhotoUrl";
import TITLE_FIELD from "@salesforce/schema/User.Title";
import ABOUT_ME_FIELD from "@salesforce/schema/User.AboutMe";
import CITY_FIELD from "@salesforce/schema/User.City";
import HIRE_FIELD from "@salesforce/schema/User.Hire_Date__c";
import GROUPS_FIELD from "@salesforce/schema/User.Equality_Group_Member__c";
import SKILLS_FIELD from "@salesforce/schema/User.Skills__c";
import INTEREST_FIELD from "@salesforce/schema/User.Interests__c";
import AVAILABLE_FIELD from "@salesforce/schema/User.Available__c";
import CUSTOM_BIO_FIELD from "@salesforce/schema/User.User_Bio__c";

import BACKGROUND from "@salesforce/contentAssetUrl/Find_Your_Match_Desktop_bg";

import countMentors from "@salesforce/apex/MainMentoringController.countMentors";
import Id from "@salesforce/user/Id";

import mentorsLabel from "@salesforce/label/c.mentors";
import mentorLabel from "@salesforce/label/c.mentor";
import menteesLabel from "@salesforce/label/c.mentees";
import menteeLabel from "@salesforce/label/c.mentee";

export default class UserProfileTracker extends LightningElement {
  @api recordId;
  userId = Id;

  score = "0";
  user;

  menteeCount;
  mentorCount;
  wiredMeetings;

  backgroundUrl = BACKGROUND;

  @wire(getRecord, {
    recordId: "$pageRef.state.userId",
    fields: [
      MODE_FIELD,
      AVAILABLE_FIELD,
      NAME_FIELD,
      IMAGE_FIELD,
      TITLE_FIELD,
      ABOUT_ME_FIELD,
      CUSTOM_BIO_FIELD,
      CITY_FIELD,
      HIRE_FIELD,
      GROUPS_FIELD,
      SKILLS_FIELD,
      INTEREST_FIELD,
    ],
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.showErrorMessage(error);
    } else if (data) {
      this.user = data;
    }
  }


  @wire(countMentors, {recordId: "$recordId"} )
  wiredApexMethod({ error, data }) {
    if (error) {
      let message = "Unknown error";
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
    } else if (data) {
      this.mentorCount = data[0];
      this.menteeCount = data[1];
    }
  }

  get mode() {
    return getFieldValue(this.user, MODE_FIELD);
  }

  get bannerStyles() {
    return "background-image: url(" + this.backgroundUrl + ");";
  }

  get showOptions() {
    return this.userId === this.recordId || this.userId.slice(0, -3) === this.recordId;
  }

  get showRequestButtons() {
      console.log("RB");
      return  !this.showOptions && this.mode !== "Both" ? true : false;
  }

  get mentorLabel() {
    if (this.mentorCount === 1) {
      return mentorLabel;
    }
    return mentorsLabel;
  }

  get menteeLabel() {
    if (this.menteeCount === 1) {
      return menteeLabel;
    }
    return menteesLabel;
  }
}