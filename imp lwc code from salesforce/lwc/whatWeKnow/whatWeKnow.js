import { LightningElement, api } from "lwc";
import EINSTEIN_POINTING from "@salesforce/resourceUrl/einsteinLocation";

import about_This_is_what from "@salesforce/label/c.about_This_is_what";
import about_we_know_about_you from "@salesforce/label/c.about_we_know_about_you";
import about_We_know_you_are_based_in from "@salesforce/label/c.about_We_know_you_are_based_in";
import about_In_order_to_find_a_better_match_refine_your_preferences from "@salesforce/label/c.about_In_order_to_find_a_better_match_refine_your_preferences";
import about_Not_Now from "@salesforce/label/c.about_Not_Now";
import about_Complete_Profile from "@salesforce/label/c.about_Complete_Profile";

export default class WhatWeKnow extends LightningElement {
  @api city;
  @api country;

  einsteinImageUrl = EINSTEIN_POINTING;

  labels = {
    about_This_is_what,
    about_we_know_about_you,
    about_We_know_you_are_based_in,
    about_In_order_to_find_a_better_match_refine_your_preferences,
    about_Not_Now,
    about_Complete_Profile
  };

  completeClicked() {
    this.dispatchEvent(new CustomEvent("complete"));
  }

  dismissedClicked() {
    this.dispatchEvent(new CustomEvent("dismiss"));
  }

  get isMobile() {
    return screen.width <= 768;
  }

  get classes() {
    return this.isMobile
      ? "slds-border_top slds-p-around_large slds-text-align_center slds-m-horizontal_xx-large"
      : "slds-p-around_large slds-text-align_center slds-m-horizontal_xx-large";
  }

  get einsteinBackground() {
    return `background-image: url(${this.einsteinImageUrl})`;
  }
}