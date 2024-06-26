import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import retrieveMentorsFromOrg from "@salesforce/apex/MainMentoringController.retrieveMentorsFromOrg";
import retrieveMenteesFromOrg from "@salesforce/apex/MainMentoringController.retrieveMenteesFromOrg";

import pendingLabel from "@salesforce/label/c.mentors_pending";
import currentLabel from "@salesforce/label/c.mentors_current";
import pastLabel from "@salesforce/label/c.mentors_past";
import youHaveNoPendingRequestsLabel from "@salesforce/label/c.mentors_You_have_no_pending_requests";
import youDontHaveAnyCurrentMenteesLabel from "@salesforce/label/c.mentors_You_don_t_have_any_current_mentees";
import youDontHaveAnyCurrentMentorsLabel from "@salesforce/label/c.mentors_You_don_t_have_any_current_mentors_Go_to_Find_Mentors_to_find_one";
import youDontHaveAnyPastMenteesLabel from "@salesforce/label/c.mentors_You_don_t_have_any_past_mentees";
import youDontHaveAnyPastMentorsLabel from "@salesforce/label/c.mentors_You_don_t_have_any_past_mentors";

export default class MyMentors extends NavigationMixin(LightningElement) {
  @api mode = "mentee";

  @track loading = false;
  @track activeTab = "current";

  // Mentors / Mentees
  @track current;
  @track past;
  @track pending;

  labels = {
    pendingLabel,
    currentLabel,
    pastLabel,
    youHaveNoPendingRequestsLabel,
  };

  connectedCallback() {
    this.loadData();
  }

  @wire(CurrentPageReference)
  pageRef;

  loadData() {
    if (this.mode === "mentee") {
      this.loadMentors();
    } else {
      this.loadMentees();
    }
    if (this.pageRef.state?.tab) {
      this.activeTab = this.pageRef.state?.tab;
    }
  }

  // Fetches all current, past and pending mentors from the org
  async loadMentors() {
    this.loading = true;
    try {
      const mentors = await retrieveMentorsFromOrg({
        status: "Accepted",
      });
      const pastMentors = await retrieveMentorsFromOrg({
        status: "Completed",
      });
      const pendingRequests = await retrieveMentorsFromOrg({
        status: "Requested",
      });
      this.current = mentors;
      this.past = pastMentors;
      this.pending = pendingRequests;
      this.loading = false;
    } catch (error) {
      this.showErrorMessage(error);
      this.loading = false;
    }
  }

  // Fetches all current, past and pending mentees from the org
  async loadMentees() {
    this.loading = true;
    try {
      const mentors = await retrieveMenteesFromOrg({
        status: "Accepted",
      });
      const pastMentors = await retrieveMenteesFromOrg({
        status: "Completed",
      });
      const pendingRequests = await retrieveMenteesFromOrg({
        status: "Requested",
      });
      this.current = mentors;
      this.past = pastMentors;
      this.pending = pendingRequests;
      this.loading = false;
    } catch (error) {
      this.showErrorMessage(error);
      this.loading = false;
    }
  }

  showErrorMessage(error) {
    // eslint-disable-next-line no-console
    console.error(error);
    let message = "Unknown error";
    if (Array.isArray(error.body)) {
      message = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      message = error.body.message;
    } else {
      message = error;
    }
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error loading mentors",
        message,
        variant: "error",
      })
    );
  }

  toggleFilters() {
    this.showFilters = !this.showFilters;
  }

  updateFilters(event) {
    this.filterCategories = event.detail;
  }

  userSelectedHandler(event) {
    // View a custom object record.
    if (event.detail.match.Status__c == "Accepted") {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: event.detail.match.Id,
          actionName: "view",
        },
      });
    } else {
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: event.detail.user.Id,
          actionName: "view",
        },
      });
    }
  }

  filterChangedHandler(event) {
    this.filterCategories = event.detail;
  }

  changeTabHandler(event) {
    if(event.which == 1 || event.which == 13 || event.which == 32){
    this.activeTab = event.target.dataset.tab;
    }
  }

  // GETTERS
  get noCurrentMentors() {
    if (!this.current) {
      return true;
    }
    if (!this.current.length > 0) {
      return true;
    }
    return false;
  }

  get noPastMentors() {
    if (!this.past) {
      return true;
    }
    if (!this.past.length > 0) {
      return true;
    }
    return false;
  }

  get noRequests() {
    if (!this.pending) {
      return true;
    }
    if (!this.pending.length > 0) {
      return true;
    }
    return false;
  }

  get pageHeading() {
    return this.mode === "mentor" ? "My Mentees" : "My Mentors";
  }

  get currentMissingMessage() {
    return this.mode === "mentor" ? youDontHaveAnyCurrentMenteesLabel : youDontHaveAnyCurrentMentorsLabel;
  }

  get pastMissingMessage() {
    return this.mode === "mentor" ? youDontHaveAnyPastMenteesLabel : youDontHaveAnyPastMentorsLabel;
  }

  get containerClasses() {
    if (this.showFilters || this.showUser) {
      return "slds-is-relative no-scroll container";
    }
    return "slds-is-relative container";
  }

  get showApprovalButtons() {
    // only show approval buttons if logged in as mentor
    return this.mode === "mentor";
  }

  get showPendingButtons() {
    return this.mode === "mentee";
  }

  get currentClasses() {
    return this.activeTab === "current" ? "slds-tabs_default__item slds-is-active slds-size_1-of-3" : "slds-tabs_default__item slds-size_1-of-3";
  }

  get pastClasses() {
    return this.activeTab === "past" ? "slds-tabs_default__item slds-is-active slds-size_1-of-3" : "slds-tabs_default__item slds-size_1-of-3";
  }

  get pendingClasses() {
    return this.activeTab === "pending" ? "slds-tabs_default__item slds-is-active slds-size_1-of-3" : "slds-tabs_default__item slds-size_1-of-3";
  }

  get currentDesktopClasses() {
    return this.activeTab === "current" ? "slds-tabs_default__item slds-is-active" : "slds-tabs_default__item";
  }

  get pastDesktopClasses() {
    return this.activeTab === "past" ? "slds-tabs_default__item slds-is-active" : "slds-tabs_default__item";
  }

  get pendingDesktopClasses() {
    return this.activeTab === "pending" ? "slds-tabs_default__item slds-is-active" : "slds-tabs_default__item";
  }

  get showCurrent() {
    return this.activeTab === "current";
  }

  get showPast() {
    return this.activeTab === "past";
  }

  get showPending() {
    return this.activeTab === "pending";
  }

  get showRedDot() {
    if (!this.pending) {
      return false;
    }
    if (!this.pending.length > 0) {
      return false;
    }
    return this.mode === "mentor";
  }

  get totalPending() {
    if (!this.pending) {
      return 0;
    }
    return this.pending.length;
  }

  get isMobile() {
    return screen.width <= 768;
  }
}