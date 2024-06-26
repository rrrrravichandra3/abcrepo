import { LightningElement, api, wire, track } from "lwc";
import { getRecord, getFieldValue, createRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";

import MENTOR_NAME_FIELD from "@salesforce/schema/Mentoring_Match__c.Mentor__r.Name";
import MENTOR_EMAIL_FIELD from "@salesforce/schema/Mentoring_Match__c.Mentor__r.Email";
import MENTEE_NAME_FIELD from "@salesforce/schema/Mentoring_Match__c.Mentee__r.Name";
import MENTEE_EMAIL_FIELD from "@salesforce/schema/Mentoring_Match__c.Mentee__r.Email";
import MEETING_OBJECT from "@salesforce/schema/Meeting__c";
import MEETING_MENTOR_MATCH_FIELD from "@salesforce/schema/Meeting__c.Mentoring_Match__c";
import MEETING_TITLE_FIELD from "@salesforce/schema/Meeting__c.Meeting_Title__c";
import MEETING_STARTTIME_FIELD from "@salesforce/schema/Meeting__c.Meeting_Date_Time__c";

import BACKGROUND from "@salesforce/contentAssetUrl/Find_Your_Match_Desktop_bg";

import getMeetings from "@salesforce/apex/MainMentoringController.retrieveMeetingsFromMentoringMatch";

import trackerLabel from "@salesforce/label/c.tracker"; 
import scheduleMeetingLabel from "@salesforce/label/c.tracker_schedule_meeting";
import seeExampleInDiscussionLabel from "@salesforce/label/c.tracker_see_example_in_discussion";

export default class MatchTracker extends LightningElement {
  @api recordId;
  @api mode;

  @track match;
  @track meetings;
  wiredMeetings;

  backgroundUrl = BACKGROUND;

  labels = {
    trackerLabel,
    scheduleMeetingLabel,
    seeExampleInDiscussionLabel,
  };

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [MENTOR_NAME_FIELD, MENTOR_EMAIL_FIELD, MENTEE_NAME_FIELD, MENTEE_EMAIL_FIELD],
  })
  wiredMentorMatchRecord({ data, error }) {
    if (error) {
      // eslint-disable-next-line
      console.error(error);
    } else if (data) {
      //console.log(data);
      this.match = data;
      //console.log(getFieldValue(this.match, MENTOR_NAME_FIELD));
    }
  }

  @wire(getMeetings, {
    matchId: "$recordId",
  })
  wiredGetMeetings(value) {
    this.wiredMeetings = value;
    const { data, error } = value;
    if (error) {
      // eslint-disable-next-line
      console.error(error);
    } else if (data) {
      //console.log("getMeetings: ", data);
      this.meetings = data;
    }
  }

  scheduleMeeting = () => {
    console.log("scheduleMeeting");

    const fields = {};
    fields[MEETING_TITLE_FIELD.fieldApiName] = "Sample Meeting";
    let nowDateTime = new Date().toISOString();
    fields[MEETING_STARTTIME_FIELD.fieldApiName] = nowDateTime;
    fields[MEETING_MENTOR_MATCH_FIELD.fieldApiName] = this.recordId;
    const recordInput = { apiName: MEETING_OBJECT.objectApiName, fields };
    createRecord(recordInput)
      .then(() => {
        refreshApex(this.wiredMeetings);
        window.open(this.meetingUrl);
      })
      .catch((error) => {
        console.log("error: ", error);
      });
  };

  get bannerStyles() {
    return "background-image: url(" + this.backgroundUrl + ");";
  }

  get meetingNumber() {
    return this.meetings ? this.meetings.length : "0";
  }

  get meetingText() {
    if (this.meetings) {
      return this.meetings.length == 1 ? "Meeting" : "Meetings";
    }
    return "Meetings";
  }

  get meetingUrl() {
    let guestEmail;
    if (this.mode == "Mentee") {
      guestEmail = this.match ? getFieldValue(this.match, MENTOR_EMAIL_FIELD) : undefined;
    } else if (this.mode == "Mentor") {
      guestEmail = this.match ? getFieldValue(this.match, MENTEE_EMAIL_FIELD) : undefined;
    }
    let startDate = new Date();
    startDate.setHours(startDate.getHours() + 1, 0, 0, 0);
    startDate = startDate.toISOString().replace(/-|:|\.\d\d\d/g, "");
    let endDate = new Date();
    endDate.setHours(endDate.getHours() + 2, 0, 0, 0);
    endDate = endDate.toISOString().replace(/-|:|\.\d\d\d/g, "");
    let menteeName = this.match ? getFieldValue(this.match, MENTEE_NAME_FIELD) : undefined;
    let mentorName = this.match ? getFieldValue(this.match, MENTOR_NAME_FIELD) : undefined;
    let url = `https://www.google.com/calendar/render?action=TEMPLATE&text=Mentoring+Meeting+%7C+${menteeName}+%26+${mentorName}&details=Use+this+event+to+get+to+know+each+other&dates=${startDate}/${endDate}&add=${guestEmail}`;
    return url;
  }
}