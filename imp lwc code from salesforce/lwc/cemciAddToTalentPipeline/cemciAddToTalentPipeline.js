import { LightningElement, wire, api } from "lwc";
import lookupSearch from "@salesforce/apex/CEMCI_CandidateSearchController.lookupSearch";
import CreateTalentPipelineCandidates from "@salesforce/apex/CEMCI_CandidateSearchController.createTalentPipelineCandidates";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CemciAddToTalentPipeline extends LightningElement {
  isMultiEntryEnabled = false;
  talentPipelineCandidateObjectAPIName = "Talent_Pipeline_Candidate__c";
  selectedTalentPipelineId = [];
  errors = [];
  @api recordId;

  renderedCallback() {
    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        this.dispatchEvent(new CloseActionScreenEvent());
      }
    });
  }

  handleLookupSearch(event) {
    const lookupElement = event.target;
    lookupSearch(event.detail)
      .then((results) => {
        lookupElement.setSearchResults(results);
      })
      .catch((error) => {
        this.fireToastEvent("Lookup Error", "An error occured while searching with the lookup field.", "error");
        this.errors = [error];
      });
  }

  handleLookupSelectionChange(event) {
    this.checkForErrors(event);
  }

  checkForErrors(event) {
    this.errors = [];
    const selection = this.template.querySelector("c-cemci-lookup").getSelection();
    this.selectedTalentPipelineId = selection;
  }

  addToTalentPipeline() {
    if (this.selectedTalentPipelineId.length === 0) {
      this.fireToastEvent("Error!", "Please select a Talent Pipeline", "error");
      return;
    }

    let talentPipelineId;

    this.template.querySelector("c-cemci-lookup").showSpinner();
    talentPipelineId = this.selectedTalentPipelineId[0].id;

    let talentPipelineCandidates = [];

    let talentPipelineCandidate = {};
    talentPipelineCandidate.sobjectType = this.talentPipelineCandidateObjectAPIName;
    talentPipelineCandidate.Contact__c = this.recordId;
    talentPipelineCandidate.Talent_Pipeline__c = talentPipelineId;
    talentPipelineCandidates.push(talentPipelineCandidate);

    CreateTalentPipelineCandidates({
      tpCandidates: talentPipelineCandidates,
      tpId: talentPipelineId
    })
      .then((result) => {
        if (result.includes("new candidates were added to Talent Pipeline!")) {
          this.fireToastEvent("Success!", "Contact was added to a Talent Pipeline", "success");
          this.selectedTalentPipelineId = [];
        } else {
          this.fireToastEvent("Error!", result, "error");
        }
      })
      .catch((error) => {
        this.fireToastEvent("Error!", "Something went wrong. Please try again.", "error");
      });
    this.template.querySelector("c-cemci-lookup").hideSpinner();
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  fireToastEvent(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }

  hideTalentPipelineModal() {
    this.selectedTalentPipelineId = [];
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}