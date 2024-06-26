import { LightningElement, api, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MODE_FIELD from "@salesforce/schema/User.Mentoring_Mode__c";
import ID_FIELD from "@salesforce/schema/User.Id";
import Id from "@salesforce/user/Id";

import searchMentorsLabel from '@salesforce/label/c.search_mentors';
import myMentorsLabel from "@salesforce/label/c.menu_My_Mentors";
import myMessagesLabel	from "@salesforce/label/c.menu_My_Messages";
import showMoreLabel from "@salesforce/label/c.Show_More";
import myMenteesLabel from "@salesforce/label/c.menu_My_Mentees";

export default class CsMobileNavBar extends LightningElement {
  userId = Id;

  @api myMenteesURL;
  @api myMentorsURL;
  @api searchMentorsURL;
  @api meetingsURL;
  @api showMoreURL;

  @track isMentee;

  labels = { 
    searchMentorsLabel,
    myMentorsLabel,
    myMessagesLabel,
    showMoreLabel,
    myMenteesLabel
  };

  // Load User Record
  @wire(getRecord, {
    recordId: "$userId",
    fields: [ID_FIELD, MODE_FIELD],
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.showNotification("Oops", `Error loading User Details ${error.body.message}`, "error");
      //eslint-disable-next-line
      console.error(error);
    } else if (data) {
      this.user = data;
      this.isMentee = data.fields[MODE_FIELD.fieldApiName].value === "Mentee";
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

  get isMobile() {
    return screen.width <= 768;
  }
}