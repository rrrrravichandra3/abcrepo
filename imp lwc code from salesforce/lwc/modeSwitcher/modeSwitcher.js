import { LightningElement, api } from "lwc";
import MENTEE_CHARACTER from "@salesforce/resourceUrl/menteeCharacter";
import MENTOR_CHARACTER from "@salesforce/resourceUrl/mentorCharacter";

import mentorModeLabel from "@salesforce/label/c.mode_mentor";
import menteeModeLabel from "@salesforce/label/c.mode_mentee";

export default class modeSwitcher extends LightningElement {
  menteeCharacterUrl = MENTEE_CHARACTER;
  mentorCharacterUrl = MENTOR_CHARACTER;

  labels = {
    mentorModeLabel,
    menteeModeLabel
  };

  @api mode;

  selectHandler(event) {
    if (event.detail.selected) {
      this.dispatchEvent(
        new CustomEvent("modechange", { detail: event.detail.id })
      );
    }
  }

  get menteeSelected() {
    return this.mode === "Mentee";
  }

  get mentorSelected() {
    return this.mode === "Mentor";
  }
}