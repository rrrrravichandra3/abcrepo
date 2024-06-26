import { LightningElement, track, api } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import FEEDBACK_OBJECT from "@salesforce/schema/Feedback__c";
import USEFUL_FIELD from "@salesforce/schema/Feedback__c.Did_you_find_the_mentoring_useful__c";
import HAPPY_FIELD from "@salesforce/schema/Feedback__c.Are_you_happy_with_your_mentor_match__c";
import LIKES_FIELD from "@salesforce/schema/Feedback__c.What_did_you_like__c";
import DISLIKES_FIELD from "@salesforce/schema/Feedback__c.What_didn_t_you_like__c";
import MATCH_FIELD from "@salesforce/schema/Feedback__c.Mentoring_Match__c";
import MODE_FIELD from "@salesforce/schema/Feedback__c.Mentor_Mentee__c";

import submitLabel	from "@salesforce/label/c.bug_feedback_modal_submit";
import didYouFindMentoringExperienceUsefulLabel	from "@salesforce/label/c.feedback_Did_you_find_the_mentoring_experience_useful";
import areYouHappyWithYourMatchLabel	from "@salesforce/label/c.feedback_Are_you_happy_with_your_match";
import whatDidYouLikeLabel	from "@salesforce/label/c.feedback_What_Did_You_Like";
import whatDidntYouLikeLabel	from "@salesforce/label/c.feedback_What_Didn_t_You_Like";
import noLabel from "@salesforce/label/c.no";
import yesLabel from "@salesforce/label/c.yes";
import nextLabel from "@salesforce/label/c.Next";
import shareYourThoughtsDontHoldBackLabel from "@salesforce/label/c.feedback_Share_your_thoughts_Don_t_hold_back";
import thankYouLabel	from "@salesforce/label/c.feedback_Thank_you";
import yourFeedbackWasRecordLabel	from "@salesforce/label/c.feedback_Your_feedback_was_recorded";

export default class FeedbackFlow extends LightningElement {
  disclaimer =
    "This feedback is only used to improve our matching algorithm and will not be shared with the mentor/mentee.";

  @track step = "useful";

  @api relatedRecordId;
  @api mode;

  @track useful;
  @track happy;
  @track likes;
  @track dislikes;

  @track loading = false;
  @api innerLabel;
  @api pressed;
  labels = {
    submitLabel,
    didYouFindMentoringExperienceUsefulLabel,
    areYouHappyWithYourMatchLabel,
    whatDidYouLikeLabel,
    whatDidntYouLikeLabel,
    nextLabel,
    shareYourThoughtsDontHoldBackLabel
  };

  get capitalYesLabel() {
    return yesLabel.toUpperCase();
  }

  get capitalNoLabel() {
    return noLabel.toUpperCase();
  }

  cancelClicked() {
    this.dispatchEvent(new CustomEvent("cancel"));
  }

  buttonClickedHandler(event) {
    const buttonClicked = event.target.dataset.id;
    const value = event.target.dataset.answer;
    const nextStep = event.target.dataset.next;
    this[buttonClicked] = value;
    this.step = nextStep;
  }

  nextClicked(event) {
    const nextStep = event.target.dataset.next;
    this.step = nextStep;
  }

  inputChangeHandler(event) {
    this[event.target.name] = event.target.value;
  }

  submitClicked() {
    this.loading = true;
    // create feedback
    const fields = {};
    fields[USEFUL_FIELD.fieldApiName] = this.useful;
    fields[HAPPY_FIELD.fieldApiName] = this.happy;
    fields[LIKES_FIELD.fieldApiName] = this.likes;
    fields[DISLIKES_FIELD.fieldApiName] = this.dislikes;
    fields[MATCH_FIELD.fieldApiName] = this.relatedRecordId;
    fields[MODE_FIELD.fieldApiName] =
      this.mode === "mentee" ? "Mentee" : "Mentor";
    const recordInput = { apiName: FEEDBACK_OBJECT.objectApiName, fields };
    createRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: thankYouLabel,
            message: yourFeedbackWasRecordLabel,
            variant: "success"
          })
        );
        this.loading = false;
        this.dispatchEvent(new CustomEvent("cancel"));
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error submitting feedback",
            message: error.body.message,
            variant: "error"
          })
        );
        this.loading = false;
      });
  }

  // GETTERS
  get showUseful() {
    return this.step === "useful";
  }

  get showHappy() {
    return this.step === "happy";
  }

  get showLikes() {
    return this.step === "likes";
  }

  get showDislikes() {
    return this.step === "dislikes";
  }

  @api
  get ariaLabel() {
      return this.innerLabel;
  }

  set ariaLabel(newValue) {
      this.innerLabel = newValue;
  }

  

  @api
  get ariaPressed() {
      return this.pressed;
  }

  set ariaPressed(newValue) {
      this.pressed = newValue;
  }
}