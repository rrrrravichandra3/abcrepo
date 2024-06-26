import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { updateRecord, createRecord } from "lightning/uiRecordApi";

import STATUS_FIELD from "@salesforce/schema/Mentoring_Match__c.Status__c";

import MEETING_OBJECT from "@salesforce/schema/Meeting__c";
import MEETING_MENTOR_MATCH_FIELD from "@salesforce/schema/Meeting__c.Mentoring_Match__c";
import MEETING_TITLE_FIELD from "@salesforce/schema/Meeting__c.Meeting_Title__c";
import MEETING_STARTTIME_FIELD from "@salesforce/schema/Meeting__c.Meeting_Date_Time__c";

import scheduleMeetingLabel from "@salesforce/label/c.mentor_schedule_meeting";
import giveFeedbackLabel from "@salesforce/label/c.mentor_give_feedback";
import endMentoringLabel from "@salesforce/label/c.mentor_end_mentoring";

export default class CardMenuButtons extends NavigationMixin(LightningElement) {
  @api mode = "mentee";
  @api match;
  @api loading = false;

  @track showSubMenu = false;
  @track showFeedback = false;

  labels = {
    scheduleMeetingLabel,
    giveFeedbackLabel,
    endMentoringLabel,
  };

  toggleSubMenu() {
    this.showSubMenu = !this.showSubMenu;
  }

  toggleFeedback() {
    this.showFeedback = !this.showFeedback;
  }

  toggleFeedbackKeyPress(event) {
    if(event.keyCode == 13 || event.keyCode == 32){
      this.toggleFeedback();
    }
  }

  moreClickedHandler() {
    this.toggleSubMenu();
  }

  async completeJourney() {
    const fields = {};
    fields[STATUS_FIELD.fieldApiName] = "Completed";
    fields.Id = this.match.Id;
    const recordInput = { fields };
    try {
      await updateRecord(recordInput);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Journey ended",
          variant: "success",
        })
      );
      this.dispatchEvent(new CustomEvent("updated"));
    } catch (error) {
      // eslint-disable-next-line
      console.error(error);
      this.showNotification("Oops something went wrong", error.body.message, "error");
    }
  }

  completeJourneyKeyPress(event) {
    if(event.keyCode == 13 || event.keyCode == 32){
      this.completeJourney();
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

  scheduleMeeting = () => {
    console.log("scheduleMeeting");

    const fields = {};
    fields[MEETING_TITLE_FIELD.fieldApiName] = "Sample Meeting";
    let nowDateTime = new Date().toISOString();
    fields[MEETING_STARTTIME_FIELD.fieldApiName] = nowDateTime;
    fields[MEETING_MENTOR_MATCH_FIELD.fieldApiName] = this.match.Id;
    const recordInput = { apiName: MEETING_OBJECT.objectApiName, fields };
    createRecord(recordInput)
      .then(() => {
        window.open(this.meetingUrl);
      })
      .catch((error) => {
        console.log("error: ", error);
      });
  };

  // GETTERS
  get meetingUrl() {
    let guestEmail = this.guestEmail;
    let startDate = new Date();
    startDate.setHours(startDate.getHours() + 1, 0, 0, 0);
    startDate = startDate.toISOString().replace(/-|:|\.\d\d\d/g, "");
    let endDate = new Date();
    endDate.setHours(endDate.getHours() + 2, 0, 0, 0);
    endDate = endDate.toISOString().replace(/-|:|\.\d\d\d/g, "");
    let menteeName = this.match.Mentee__r.Name;
    let mentorName = this.match.Mentor__r.Name;
    let url = `https://www.google.com/calendar/render?action=TEMPLATE&text=Mentoring+Meeting+%7C+${menteeName}+%26+${mentorName}&details=Use+this+event+to+get+to+know+each+other&dates=${startDate}/${endDate}&add=${guestEmail}`;
    return url;
  }

  get guestEmail() {
    if (this.match.Mentee__r.Email) {
      return this.match.Mentee__r.Email;
    }
    return this.match.Mentor__r.Email;
  }

  get isMobile() {
    return screen.width <= 768;
  }
}