import { LightningElement, api, track } from "lwc";
import TOP_MENTOR_LOGO from "@salesforce/resourceUrl/topBadge";
import TOP_VALUE_LOGO from "@salesforce/resourceUrl/topValue";
import TOP_CAREER_LOGO from "@salesforce/resourceUrl/topCareer";
import SALES_LEADER_LOGO from "@salesforce/resourceUrl/salesLeader";
import LINKEDIN_LOGO from "@salesforce/resourceUrl/linkedIn";

import bestCareerMatchLabel from "@salesforce/label/c.badge_Best_career_match";
import bestValueAndInterestsMatchLabel from "@salesforce/label/c.badge_Best_value_and_interests_match";
import overallBestMatchLabel from "@salesforce/label/c.badge_Overall_best_match";
import salesLeaderLabel from "@salesforce/label/c.badge_Sales_leader";

export default class MentorBadges extends LightningElement {
  linkedInLogo = LINKEDIN_LOGO;
  salesLeaderLogo = SALES_LEADER_LOGO;
  topMentorLogo = TOP_MENTOR_LOGO;
  topValueLogo = TOP_VALUE_LOGO;
  topCareerLogo = TOP_CAREER_LOGO;

  @api linkedinUsername;
  @api showLeaderBadge;
  @api showTopBadge;
  @api showValueBadge;
  @api showCareerBadge;
  @api profile = false;

  @track helpText;

  labels = {
    bestCareerMatchLabel,
    bestValueAndInterestsMatchLabel,
    overallBestMatchLabel,
    salesLeaderLabel,
  };

  showHelpText(event) {
    //console.log(event.currentTarget.name);
    if (!this.profile) {
      this.helpText = event.currentTarget.name;
    }
  }

  hideHelpText() {
    this.helpText = undefined;
  }

  get linkedInLink() {
    //return "https://www.linkedin.com/in/" + this.linkedinUsername;
    return this.linkedinUsername;
  }

  get showSalesLeaderHelpText() {
    return this.helpText === "salesLeader";
  }

  get showTopBadgeHelpText() {
    return this.helpText === "topMentor";
  }

  get showTopValueHelpText() {
    return this.helpText === "topValue";
  }

  get showTopCareerHelpText() {
    return this.helpText === "topCareer";
  }
}