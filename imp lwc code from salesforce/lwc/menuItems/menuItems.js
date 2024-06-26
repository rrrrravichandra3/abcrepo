import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

import myMentorsLabel from "@salesforce/label/c.menu_My_Mentors";
import myMenteesLabel from "@salesforce/label/c.menu_My_Mentees";
import myMessagesLabel from "@salesforce/label/c.menu_My_Messages";
import pilotFeedbackLabel from "@salesforce/label/c.menu_Pilot_Feedback";

const menteeMenuItems = [
  {
    label: myMentorsLabel,
    icon: "mentor",
    redirectUrl: "home"
  },
  {
    label: myMessagesLabel,
    icon: "notes",
    redirectUrl: "my-messages"
  }
];

// {
//   label: "Feedback",
//   icon: "thumbs-up",
//   redirectUrl: "feedback"
// }

const mentorMenuItems = [
  {
    label: myMenteesLabel,
    icon: "mentor",
    redirectUrl: "my-mentees"
  },
  {
    label: myMessagesLabel,
    icon: "notes",
    redirectUrl: "my-messages"
  }
];
export default class MenuItems extends NavigationMixin(LightningElement) {
  @api // Switch menu items based on mode
  get mode() {
    return this._mode;
  }
  set mode(value) {
    this._mode = value;
    this.menuItems = value === "mentor" ? mentorMenuItems : menteeMenuItems;
  }

  @track menuItems;

  labels = {
    pilotFeedbackLabel
  }

  menuItemClickedHandler(event) {
    // Navigate to a URL
    this[NavigationMixin.Navigate]({
      // Pass in pageReference
      type: "standard__namedPage",
      attributes: {
        pageName: event.target.name
      }
    });
  }

  goToMyCases() {
    // Navigate to the Contact object's Recent list view.
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Case",
        actionName: "list"
      },
      state: {
        // 'filterName' is a property on the page 'state'
        // and identifies the target list view.
        // It may also be an 18 character list view id.
        filterName: "00B2o000009YzHPEA0" // or by 18 char "00BT0000002TONQMA4"
      }
    });
  }
}