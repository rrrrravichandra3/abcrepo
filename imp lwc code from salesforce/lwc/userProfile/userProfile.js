import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import NAME_FIELD from "@salesforce/schema/User.Name";
import IMAGE_FIELD from "@salesforce/schema/User.MediumPhotoUrl";
import TITLE_FIELD from "@salesforce/schema/User.Title";
import ABOUT_ME_FIELD from "@salesforce/schema/User.AboutMe";
import CITY_FIELD from "@salesforce/schema/User.City";
import HIRE_FIELD from "@salesforce/schema/User.Hire_Date__c";
import GROUPS_FIELD from "@salesforce/schema/User.Equality_Group_Member__c";
import SKILLS_FIELD from "@salesforce/schema/User.Skills__c";
import SKILLS_TO_IMPROVE_FIELD from "@salesforce/schema/User.Skills__c";
import INTEREST_FIELD from "@salesforce/schema/User.Interests__c";
import AVAILABLE_FIELD from "@salesforce/schema/User.Available__c";
import BANNER_BACKGROUND from "@salesforce/resourceUrl/bannerBackground";
import CUSTOM_BIO_FIELD from "@salesforce/schema/User.User_Bio__c";
import Id from "@salesforce/user/Id";

import weThinkThisUSerMightBeAGreatMatchButLabel from "@salesforce/label/c.profile_We_think_this_user_might_be_a_great_match_but_they_ve_not_signed";
import youWontBeAbleToSendThemARequestLabel from "@salesforce/label/c.profile_You_won_t_be_able_to_send_them_a_request";
import apologiesForAnyInconvenienceCausedLabel from "@salesforce/label/c.profile_Apologies_for_any_inconvenience_caused";
import overviewLabel from "@salesforce/label/c.profile_overview";
import detailsLabel from "@salesforce/label/c.profile_details";
import mentorfinderBioLabel from "@salesforce/label/c.profile_mentorfinder_bio";
import org62BioLabel from "@salesforce/label/c.profile_org62_bio";
import looksLikeThisUserDoesntHaveABioLabel from "@salesforce/label/c.profile_Looks_like_this_user_doesn_t_have_a_bio";
import matchScoreLabel from "@salesforce/label/c.profile_Match_Score";

export default class UserProfile extends NavigationMixin(LightningElement) {
  userId = Id;
  bannerBackgroundUrl = BANNER_BACKGROUND;

  @api recordId = "0052o000008tAo5AAE";
  @api user;

  @track activeTab = "overview";
  @track currentUser;

  labels = {
    weThinkThisUSerMightBeAGreatMatchButLabel,
    youWontBeAbleToSendThemARequestLabel,
    apologiesForAnyInconvenienceCausedLabel,
    overviewLabel,
    detailsLabel,
    mentorfinderBioLabel,
    org62BioLabel,
    looksLikeThisUserDoesntHaveABioLabel,
    matchScoreLabel,
  };

  @wire(CurrentPageReference) pageRef;

  @wire(getRecord, {
    recordId: "$pageRef.state.userId",
    fields: [AVAILABLE_FIELD, NAME_FIELD, IMAGE_FIELD, TITLE_FIELD, ABOUT_ME_FIELD, CUSTOM_BIO_FIELD, CITY_FIELD, HIRE_FIELD, GROUPS_FIELD, SKILLS_FIELD, INTEREST_FIELD],
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.showErrorMessage(error);
    } else if (data) {
      this.user = data;
    }
  }

  @wire(getRecord, {
    recordId: "$userId",
    fields: [NAME_FIELD, SKILLS_TO_IMPROVE_FIELD, INTEREST_FIELD],
  })
  wiredCurrentUser({ error, data }) {
    if (error) {
      this.showErrorMessage(error);
    } else if (data) {
      this.currentUser = data;
    }
  }

  changeTabHandler(event) {
    this.activeTab = event.target.dataset.tab;
  }

  editProfileHandler() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.user.id,
        objectApiName: "User",
        actionName: "view",
      },
    });
  }

  showErrorMessage(error) {
    //eslint-disable-next-line
    console.error(error);
    let message = "Unknown error";
    if (Array.isArray(error.body)) {
      message = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      message = error.body.message;
    }
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error loading user",
        message,
        variant: "error",
      })
    );
  }

  backHandler() {
    window.history.back();
  }

  get bannerBackground() {
    return `background-image: url(${this.bannerBackgroundUrl})`;

    /*const photoUrl = getFieldValue(this.user, IMAGE_FIELD);

    return photoUrl && photoUrl !== "/profilephoto/005/M"
      ? `background-image: url(${photoUrl})`
      : `background-image: url(${this.bannerBackgroundUrl})`;*/
  }

  get bannerClasses() {
    return "banner-container";

    /*const photoUrl = getFieldValue(this.user, IMAGE_FIELD);
    return photoUrl && photoUrl !== "/profilephoto/005/M"
      ? "banner-container blur"
      : "banner-container"*/
  }

  get imageBackground() {
    const photoUrl = getFieldValue(this.user, IMAGE_FIELD);
    return photoUrl ? `background-image: url(${photoUrl})` : `background-image: url('/profilephoto/005/M')`;
  }

  get badgeColor() {
    if (this.pageRef.state.score < 70) {
      return `background-color: #FF9F43`;
    } else if (this.pageRef.state.score < 80) {
      return `background-color: #A3CB38`;
    }
    return `background-color: #3FB500`;
  }

  get matchingSkills() {
    const skills = getFieldValue(this.user, SKILLS_FIELD);
    const improveSkills = getFieldValue(this.currentUser, SKILLS_TO_IMPROVE_FIELD);
    const userInterests = getFieldValue(this.user, INTEREST_FIELD);
    const currentUserInterests = getFieldValue(this.currentUser, INTEREST_FIELD);
    const skillsInterests = [];
    if (skills && improveSkills) {
      skillsInterests.push(...skills.split(";").filter((skill) => improveSkills.split(";").includes(skill)));
    }
    if (userInterests && currentUserInterests) {
      skillsInterests.push(...userInterests.split(";").filter((interest) => currentUserInterests.split(";").includes(interest)));
    }
    return skillsInterests.length > 0 ? skillsInterests : undefined;
  }

  get name() {
    return getFieldValue(this.user, NAME_FIELD);
  }

  get title() {
    return getFieldValue(this.user, TITLE_FIELD);
  }

  get about() {
    return getFieldValue(this.user, ABOUT_ME_FIELD);
  }

  get customBio() {
    return getFieldValue(this.user, CUSTOM_BIO_FIELD);
  }

  get noBio() {
    return !this.about && !this.customBio;
  }

  get showRequestButtons() {
    return this.pageRef.state.showRequestButtons;
  }

  get score() {
    return this.pageRef.state.score;
  }

  get availableAsMentor() {
    return getFieldValue(this.user, AVAILABLE_FIELD);
  }

  get showEditButton() {
    if (this.user) {
      return this.user.id === this.userId;
    }
    return false;
  }

  get showScore() {
    // return this.pageRef.state.score;
    return false;
  }

  get overviewClasses() {
    return this.activeTab === "overview" ? "slds-tabs_default__item slds-is-active slds-size_1-of-2 gray" : "slds-tabs_default__item slds-size_1-of-2 gray";
  }

  get aboutMeClasses() {
    return this.activeTab === "aboutMe" ? "slds-tabs_default__item slds-is-active slds-size_1-of-2 gray" : "slds-tabs_default__item slds-size_1-of-2 gray";
  }

  get showOverview() {
    return this.activeTab === "overview";
  }

  get showAboutMe() {
    return this.activeTab === "aboutMe";
  }

  get isMobile() {
    return screen.width <= 768;
  }
}