import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import DISMISSED_FIELD from '@salesforce/schema/User.Name';
import Id from "@salesforce/user/Id";
import concierge_logo from "@salesforce/resourceUrl/Concierge_Logo";
import AboutLabel from "@salesforce/label/c.bug_feedback_about";
import DismissLabel from "@salesforce/label/c.bug_feedback_dismiss";
import CancelLabel from "@salesforce/label/c.bug_feedback_modal_cancel";
import SubmitLabel from "@salesforce/label/c.bug_feedback_modal_submit";
import ModalTitleLabel from "@salesforce/label/c.bug_feedback_modal_title";

export default class BugReport extends NavigationMixin(LightningElement) {
  @track showModal;
  @track showTooltip = true;
  @track user;
  userId = Id;
  Concierge_Logo = concierge_logo;
  label = {
    AboutLabel,
    DismissLabel,
    CancelLabel,
    SubmitLabel,
    ModalTitleLabel,
  };

  @wire(getRecord, {
    recordId: "$userId",
    fields: [DISMISSED_FIELD],
  })
  wiredRecord({ data, error }) {
    if (error) {
      // eslint-disable-next-line
      console.error(error);
    } else if (data) {
      //console.log(data);
      this.user = data;
      //console.log(getFieldValue(this.user, DISMISSED_FIELD));
      if (getFieldValue(this.user, DISMISSED_FIELD)) {
        this.showTooltip = false;
      }
    }
  }

  @api global;

  toggleBugModal(event) {
    // this.showModal = !this.showModal;
    if(event.which == 1 || event.which == 13 || event.which == 32){
      window.open("https://concierge.it.salesforce.com/articles/en_US/How_To/MentorFinder-App", "_blank").focus();
    }
  }

  dismissTooltip() {
    this.showTooltip = false;
    //updateRecord
    try {
      const fields = {};
      fields.Id = this.userId;
      fields[DISMISSED_FIELD.fieldApiName] = true;
      const recordInput = {
        fields,
      };
      updateRecord(recordInput);
    } catch (error) {
      //eslint-disable-next-line
      console.error(error);
    }
  }

  handleSuccess(event) {
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.detail.id,
        actionName: "view",
      },
    }).then((url) => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Thank you!",
          message: "Your case was created. See it {0}.",
          variant: "success",
          messageData: [
            {
              url,
              label: "here",
            },
          ],
        })
      );
    });
    this.toggleBugModal();
  }

  showlabel(event){
    this.showTooltip=true;
  }

  handleError(event) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Oops. Something went wrong!",
        message: event.detail,
        variant: "error",
      })
    );
  }
}