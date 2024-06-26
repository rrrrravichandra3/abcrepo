import { LightningElement, track, wire } from "lwc";
import getContactStages from "@salesforce/apex/CEMCI_CandidateCardController.getContactStages";
import findContacts from "@salesforce/apex/CEMCI_CandidateCardController.findContacts";
import getCountries from "@salesforce/apex/CEMCI_CandidateCardController.getContactCountryPicklistValues";
import createCandidatePoolRecords from "@salesforce/apex/CEMCI_CandidateCardController.createCandidatePoolRecords";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from "lightning/navigation";
import CandidateCardHelptext from "@salesforce/label/c.CandidateCardHelpText";
import CandidateMatchStatus from "@salesforce/label/c.CandidateMatchStatus";
import hasAccess from "@salesforce/apex/CEMCI_ManageCandidatePool.hasAccess";

export default class CandidateFinder extends NavigationMixin(LightningElement) {
  contactResults;
  contactResultsMap = new Map();
  contactStages;
  searchText;
  countries;
  visibleContacts;
  selectedContactStages = [];
  selectedCountries = [];
  searchFilters = "";
  reqRecordId;
  spinner = false;
  selectedCandidates = [];
  selectedCandidatesMap = new Map();
  firstLoad = true;
  candMatchsObjectAPIName = "Candidate_Match__c";
  label = { CandidateCardHelptext, CandidateMatchStatus };
  appliedContacts = [];
  reviewedCandidates = [];
  selectedTags = [];

  connectedCallback() {
    getContactStages()
      .then((result) => {
        //if there are more things to be loaded on page load, we can load a
        //wrapper from apex and store in js in different variables
        let options = [];
        if (result) {
          result.forEach((r) => {
            options.push({ label: r, value: r });
          });
        }
        this.contactStages = options;
      })
      .catch((error) => {
        this.fireToastEvent("Error!", error.body.message, "error");
      });

    getCountries()
      .then((result) => {
        //if there are more things to be loaded on page load, we can load a
        //wrapper from apex and store in js in different variables
        let options = [];
        if (result) {
          result.forEach((r) => {
            let values = r.split("-", 2);
            options.push({ label: values[1], value: values[0] });
          });
        }
        this.countries = options;
      })
      .catch((error) => {
        this.fireToastEvent("Error!", error.body.message, "error");
      });
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.urlStateParameters = currentPageReference.state;
      this.reqRecordId = this.urlStateParameters.c__recordId;
    }
  }

  backtoJobReq() {
    window.location.replace("/lightning/r/WDR_Job__c/" + this.reqRecordId + "/view");
  }

  handleKeyUp(event) {
    if (event.key === "Enter") this.search();
  }

  search() {
    this.firstLoad = false;
    let parameters = this.prepareApexParams();
    parameters = JSON.stringify(parameters);
    this.showSpinner();
    findContacts({
      soslSearchText: this.searchText,
      searchFilters: parameters,
      jobRecId: this.reqRecordId
    })
      .then((result) => {
        if (result.contacts === undefined || result.contacts.length === 0) {
          this.contactResults = undefined;
        } else {
          this.contactResults = result.contacts;
          this.appliedContacts = result.appliedContactIds;
          this.reviewedCandidates = result.reviewedCandidates;
          this.contactResults.forEach((obj) => {
            this.contactResultsMap.set(obj.Id, obj);
          });
        }
        this.hideSpinner();
      })
      .catch((error) => {
        //handle error
        this.hideSpinner();
        if (error && error.body) {
          this.fireToastEvent("Error!", error.body.message, "error");
        }
      });
  }

  showSpinner() {
    this.spinner = true;
  }

  hideSpinner() {
    this.spinner = false;
  }

  navigateToCandidatePool() {
    this.hasAccessManageCandidatePool();
  }

  hasAccessManageCandidatePool() {
    hasAccess({ jobRecId: this.reqRecordId })
      .then((result) => {
        this.navigateToManageCandidatePool(result);
        return result;
      })
      .catch((error) => {});
  }

  navigateToManageCandidatePool(hasAccess) {
    if (hasAccess) {
      window.location.replace("/lightning/n/manage_candidate_pool_tab?c__recordId=" + this.reqRecordId);
    } else {
      this.fireToastEvent(
        "Error!",
        "You cannot manage this requistion as you are not the hiring manager nor have CEMCI permission sets",
        "error"
      );
    }
  }

  addToCandidatePool() {
    if (this.selectedCandidatesMap.size === 0) {
      this.fireToastEvent("", "No records were selected to add to candidate pool", "info");
      return;
    }

    let candMatches = [];
    let selectedCandidates = [...this.selectedCandidatesMap.keys()];
    for (let i = 0; i < selectedCandidates.length; i++) {
      let candMatch = {};
      candMatch.sobjectType = this.candMatchsObjectAPIName;
      candMatch.WD_Job_Requisition__c = this.reqRecordId;
      candMatch.Candidate__c = selectedCandidates[i];
      candMatch.Status__c = CandidateMatchStatus;
      candMatches.push(candMatch);
    }

    createCandidatePoolRecords({
      candRecords: candMatches
    })
      .then((result) => {
        this.resetContactData();
        this.fireToastEvent("Success!", "Selected Candidates were succesfully to add to candidate pool", "success");
      })
      .catch((error) => {});
  }

  resetContactData() {
    let arr = [...this.selectedCandidatesMap.keys()];
    arr.forEach((item) => {
      this.contactResultsMap.delete(item);
    });
    this.selectedCandidatesMap = new Map();
    this.contactResults = Array.from(this.contactResultsMap.values());
  }

  handleSearchTextChange(event) {
    this.searchText = event.target.value;
  }

  handleMultiSelectStages(event) {
    this.selectedContactStages = event.detail;
  }

  handleMultiSelectCountries(event) {
    this.selectedCountries = event.detail;
  }

  handleTags(event) {
    this.selectedTags = event.detail;
  }

  prepareApexParams() {
    let inputParam = {};
    var inputElements = this.template.querySelectorAll("lightning-input");

    inputElements.forEach((inputElement) => {
      if (inputElement.value !== undefined && inputElement.value !== "") {
        inputParam[inputElement.name] = inputElement.value.trim();
      } else if (inputElement.name === "onlyAppliedContacts") {
        inputParam[inputElement.name] = inputElement.checked;
      } else if (inputElement.name === "boomerang") {
        inputParam[inputElement.name] = inputElement.checked;
      }
    }, this);
    if (this.selectedCountries.length > 0) {
      inputParam["countries"] = this.selectedCountries;
    }
    if (this.selectedContactStages.length > 0) {
      inputParam["contactStages"] = this.selectedContactStages;
    }
    if (this.selectedTags.selRecords && this.selectedTags.selRecords.length > 0) {
      let tags = [];
      this.selectedTags.selRecords.forEach((value) => {
        tags.push(value.recName);
      });
      inputParam["tags"] = tags;
    }
    return inputParam;
  }

  clearFilters() {
    let inputElements = this.template.querySelectorAll("lightning-input");
    inputElements.forEach((inputElement) => {
      inputElement.value = "";
      if (inputElement.checked) {
        inputElement.checked = false;
      }
    }, this);
    let multiSelectElements = this.template.querySelectorAll("c-multi-select-combo-box");
    multiSelectElements.forEach((inputElement) => {
      inputElement.clearSelectedValues();
    }, this);
    this.searchText = "";
  }

  fireToastEvent(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }

  updateContactHandler(event) {
    this.visibleContacts = [...event.detail.records];
  }

  addCandidateToSelected(event) {
    this.selectedCandidatesMap.set(event.detail.Id, event.detail);
  }

  removeCandidateFromSelected(event) {
    this.selectedCandidatesMap.delete(event.detail.Id);
  }

  addToReviewedList(event) {
    this.reviewedCandidates.push(event.detail);
  }

  removeFromReviewedList(event) {
    const index = this.reviewedCandidates.indexOf(event.detail);
    if (index > -1) {
      // only splice array when item is found
      this.reviewedCandidates.splice(index, 1); // 2nd parameter means remove one item only
    }
  }
}