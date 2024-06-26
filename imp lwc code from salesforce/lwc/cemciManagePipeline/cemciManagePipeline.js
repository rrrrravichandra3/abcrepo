import { api, track, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPipelineCandidates from "@salesforce/apex/CEMCI_ManagePipelineController.getPipelineCandidates";
import deletePipelineCandidates from "@salesforce/apex/CEMCI_ManagePipelineController.deletePipelineCandidates";
import lookupSearch from "@salesforce/apex/CEMCI_ManagePipelineController.lookupSearch";
import CreateCampaignMembers from "@salesforce/apex/CEMCI_CandidateSearchController.createCampaignMembers";

export default class CemciManagePipeline extends LightningElement {
  @api recordId;
  @track candidates = [];
  @track selectedRows = [];
  @track isShowTalentCommunityModal = false;
  @track isShowRemoveModal = false;
  @track isShowResumeModal = false;
  contactResume;

  isMultiEntry = false;
  errors = [];
  campaignMemberObjectAPIName = "CampaignMember";
  selectedCampaignId = [];

  columns = [
    {
      label: "Resume",
      type: "button-icon",
      typeAttributes: {
        name: "View",
        title: "View",
        iconName: "utility:description",
        disabled: { fieldName: "textResumeIsDisabled" },
        value: "view",
        iconPosition: "left"
      }
    },
    {
      label: "Name",
      fieldName: "ContactURL",
      type: "url",
      sortable: true,
      typeAttributes: { label: { fieldName: "Name" }, target: "_blank" }
    },
    { label: "Title", fieldName: "Title", sortable: true },
    { label: "Email", fieldName: "Email", type: "email", sortable: true },
    { label: "Phone", fieldName: "Phone", type: "phone" },
    {
      label: "MRS Application",
      fieldName: "MRSApplicationJobURL",
      type: "url",
      sortable: true,
      typeAttributes: { label: { fieldName: "MRSApplication" }, target: "_blank" }
    },
    { label: "Contact Owner", fieldName: "ContactOwner", sortable: true },
    { label: "Added Date", fieldName: "AddedDate", type: "date", sortable: true },
    { label: "Added By", fieldName: "AddedBy", sortable: true }
  ];

  renderedCallback() {
    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        if (this.isShowResumeModal) this.hideTextResume();
        if (this.isShowTalentCommunityModal) this.hideTalentCommunityModalBox();
      }
    });
  }

  connectedCallback() {
    this.getData();
  }

  doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortBy =
      this.sortBy === "ContactURL" ? "Name" : this.sortBy === "MRSApplicationJobURL" ? "MRSApplication" : this.sortBy;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
    this.sortBy = event.detail.fieldName;
  }

  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.candidates));
    // Return the value stored in the field
    let keyValue = (a) => {
      return a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === "asc" ? 1 : -1;
    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ""; // handling null values
      y = keyValue(y) ? keyValue(y) : "";
      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });
    this.candidates = parseData;
  }

  getData() {
    getPipelineCandidates({ pipelineId: this.recordId })
      .then((result) => {
        if (result) {
          console.log(result);
          let temp = [];
          temp.push(...result);
          this.candidates = temp;
        }
      })
      .catch((error) => {
        console.log(error);
        this.fireToastEvent("Error!", error.body.message, "error");
      });
  }

  handleRowSelect(event) {
    this.selectedRows = event.detail.selectedRows;
    // Display that fieldName of the selected rows
  }

  handleSearch() {
    window.location.replace("/lightning/n/Candidate_Search?c__recordId=" + this.recordId + "&c__source=talentPipeline");
  }

  handleShowTCModal() {
    if (this.selectedRows.length === 0) {
      this.fireToastEvent("", "No records were selected to add to Talent Community", "info");
      return;
    } else {
      this.isShowTalentCommunityModal = true;
    }
  }

  hideTalentCommunityModalBox() {
    this.isShowTalentCommunityModal = false;
  }

  handleShowDelete() {
    if (this.selectedRows.length === 0) {
      this.fireToastEvent("", "No records were selected to add to remove", "info");
      return;
    } else {
      this.isShowRemoveModal = true;
    }
  }

  hideModalRemoveBox() {
    this.isShowRemoveModal = false;
  }

  hideTextResume() {
    this.isShowResumeModal = false;
    this.contactResume = "";
  }

  clearSeletedRows() {
    this.template.querySelector("lightning-datatable").selectedRows = [];
    this.selectedRows = [];
  }

  handleDelete() {
    let pipelineCandidates = [];
    for (let i = 0; i < this.selectedRows.length; i++) {
      let pipelineCandidate = {};
      pipelineCandidate.sobjectType = "Talent_Pipeline_Candidate__c";
      pipelineCandidate.Id = this.selectedRows[i].Id;
      pipelineCandidates.push(pipelineCandidate);
    }

    deletePipelineCandidates({ selectedRecords: pipelineCandidates })
      .then(() => {
        console.log("records deleted");
        this.clearSeletedRows();
        this.hideModalRemoveBox();
        this.getData();
      })
      .catch((error) => {
        this.fireToastEvent("Error!", error.body.message, "error");
      });
  }

  handleLookupSelectionChange(event) {
    this.checkForErrors();
  }

  checkForErrors() {
    this.errors = [];
    const selection = this.template.querySelector("c-cemci-lookup").getSelection();
    this.selectedCampaignId = selection;
    // Custom validation rule
    if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
      this.errors.push({ message: `You may only select up to ${this.maxSelectionSize} items.` });
    }
    // Enforcing required field
    if (selection.length === 0) {
      this.errors.push({ message: "Please make a selection." });
    }
  }

  handleLookupSearch(event) {
    const lookupElement = event.target;
    lookupSearch(event.detail)
      .then((results) => {
        lookupElement.setSearchResults(results);
        console.log(results);
      })
      .catch((error) => {
        this.fireToastEvent("Lookup Error", "An error occured while searching with the lookup field.", "error");
        // eslint-disable-next-line no-console
        console.error("Lookup error", JSON.stringify(error));
        this.errors = [error];
      });
  }

  addToCampaign() {
    if (this.selectedCampaignId.length === 0) {
      this.fireToastEvent("Error!", "Please select a Campaign", "error");
      return;
    }

    if (this.selectedRows.length === 0) {
      this.fireToastEvent("", "No records were selected to add to Campaign", "info");
      return;
    }
    this.template.querySelector("c-cemci-lookup").showSpinner();
    let selectedCampaign = this.selectedCampaignId[0].id;

    let campaignMembers = [];
    let selectedCandidates = this.selectedRows;
    for (let i = 0; i < selectedCandidates.length; i++) {
      let campaignMember = {};
      campaignMember.sobjectType = this.campaignMemberObjectAPIName;
      campaignMember.ContactId = selectedCandidates[i].ContactId;
      campaignMember.CampaignId = selectedCampaign;
      campaignMembers.push(campaignMember);
    }

    CreateCampaignMembers({
      campaignMembers: campaignMembers,
      campaignId: selectedCampaign
    })
      .then((result) => {
        if (result.includes("new campaign members were added to campaign!")) {
          this.fireToastEvent("Success!", "Candidates were added to the Campaign", "success");
          this.selectedCampaignId = [];
          this.clearSeletedRows();
        } else {
          this.fireToastEvent("Error!", result, "error");
        }
        this.isShowTalentCommunityModal = false;
      })
      .catch((error) => {
        this.fireToastEvent("Error!", "Something went wrong. Please try again.", "error");
        this.isShowTalentCommunityModal = false;
      });
    this.template.querySelector("c-cemci-lookup").showSpinner();
  }

  fireToastEvent(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }

  callRowAction(event) {
    const recId = event.detail.row.Id;
    const actionName = event.detail.action.name;
    let candidates = this.candidates;
    if (actionName === "View") {
      for (let i = 0; i < candidates.length; i++) {
        if (candidates[i].Id === recId && candidates[i].TextResume) {
          this.contactResume = candidates[i].TextResume;
          this.isShowResumeModal = true;
        }
      }
      if (this.contactResume === undefined || this.contactResume === "") {
        this.fireToastEvent("", "No text resume for this contact", "info");
      }
    }
  }

  handleKeyDown(event) {
    console.log("pressed" + JSON.stringify(event));
    // if(event.code == 'Escape') {
    //   this.isShowResumeModal = false;
    //   event.preventDefault();
    //   event.stopImmediatePropagation();
    // }
  }
}