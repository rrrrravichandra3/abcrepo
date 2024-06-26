import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CandidateCard extends NavigationMixin(LightningElement) {
  @api contact;
  @api selectedCandidates;
  @api appliedCandidates;
  @api reviewedCandidates;
  silverBadge;
  URMBagde;
  URGBagde;
  badgeFont = "badgeTextFont";
  badgeHighlight = "slds-badge_inverse ";
  appliedBadge = " slds-theme_success ";
  articleClass = "slds-card cardSize curvedBorder";
  selected = false;
  applied;
  currentCompanyName;
  genderDataAvailable;
  isShowLookupModal = false;
  MRSJobRecordPageURL;

  connectedCallback() {
    this.silverBadge = this.contact.Silver_Medalist__c ? this.badgeHighlight.concat(this.badgeFont) : this.badgeFont;
    this.URMBagde = this.contact.URM__c ? this.badgeHighlight.concat(this.badgeFont) : this.badgeFont;
    this.URGBagde = this.contact.URG__c ? this.badgeHighlight.concat(this.badgeFont) : this.badgeFont;
    this.appliedBadge = this.appliedBadge.concat(this.badgeFont);
    this.selected = this.isSelected();
    this.applied = this.hasApplied();
    this.currentCompanyName = this.getCurrentCompanyName();
    this.genderDataAvailable = this.contact.MRS_App__r && this.contact.MRS_App__r.Gender__c ? true : false;
    this.MRSJobRecordPageURL =
      this.contact.MRS_App__r && this.contact.MRS_App__r.Job__c ? "/" + this.contact.MRS_App__r.Job__c : "";
  }

  renderedCallback() {
    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        if (this.isShowLookupModal) this.hideTextResume();
      }
    });
  }

  selectCandidate() {
    this.selected = true;
    this.dispatchEvent(
      new CustomEvent("addcandidate", {
        detail: this.contact
      })
    );
  }

  deSelectCandidate(event) {
    this.selected = false;
    this.dispatchEvent(
      new CustomEvent("removecandidate", {
        detail: this.contact
      })
    );
  }

  isSelected() {
    return this.selectedCandidates.has(this.contact.Id);
  }

  openRecord(event) {
    let recId = this.contact.Id;

    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: recId,
        actionName: "view"
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  }

  openLinkedInProfile() {
    window.open(this.contact.LinkedIn_Profile_URL__c, "_blank");
  }

  fireToastEvent(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }

  hasApplied() {
    //check if this id is in the array of applied contact IDs
    return this.appliedCandidates.includes(this.contact.Id);
  }

  getCurrentCompanyName() {
    if (this.contact.Account !== undefined) {
      return this.contact.Account.Name;
    }
  }

  showTextResume() {
    this.isShowLookupModal = true;
  }

  hideTextResume() {
    this.isShowLookupModal = false;
  }
}