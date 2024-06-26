import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import BACKGROUND from "@salesforce/resourceUrl/matchBackground";

import itsAMatchLabel from "@salesforce/label/c.match_its_a_match";
import seeUsersProfileLabel from "@salesforce/label/c.match_see_users_profile";
import setUpFirstMeetingLabel from "@salesforce/label/c.match_set_up_first_meeting";
import prepareForYourFirstMeetingLabel from "@salesforce/label/c.match_Prepare_for_your_first_meeting_Complete_the_Mentorship_Trail";

export default class MatchModal extends LightningElement {
  @api user;

  modalBackgroundUrl = BACKGROUND;

  labels = {
    itsAMatchLabel,
    seeUsersProfileLabel,
    setUpFirstMeetingLabel,
    prepareForYourFirstMeetingLabel
  };

  showProfileClickedHandler() {
    this.dispatchEvent(new CustomEvent("showprofile"));
  }

  setUpMeetingClickedHandler() {
    this.dispatchEvent(new CustomEvent("schedule"));
  }

  guideClickedHandler() {
    this.dispatchEvent(
      new ShowToastEvent({
        message: "The Trail is coming soon!",
        variant: "warning"
      })
    );
  }

  closeClickedHandler() {
    this.dispatchEvent(new CustomEvent("close"));
  }

  get backgroundImage() {
    return `background-image: url(${this.modalBackgroundUrl})`;
  }
}