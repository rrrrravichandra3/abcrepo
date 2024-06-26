import { LightningElement, track, wire, api } from "lwc";
import findContacts from "@salesforce/apex/CEMCI_CandidateSearchController.findContacts";
import getFilterValuesOnPageLoad from "@salesforce/apex/CEMCI_CandidateSearchController.getFilterValuesOnPageLoad";
import CreateCampaignMembers from "@salesforce/apex/CEMCI_CandidateSearchController.createCampaignMembers";
import CreateTalentPipelineCandidates from "@salesforce/apex/CEMCI_CandidateSearchController.createTalentPipelineCandidates";
import lookupSearch from "@salesforce/apex/CEMCI_CandidateSearchController.lookupSearch";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from "lightning/navigation";
import CandidateCardHelptext from "@salesforce/label/c.CandidateCardHelpText";
import CandidateMatchStatus from "@salesforce/label/c.CandidateMatchStatus";
import MaximumResultsReached from "@salesforce/label/c.Maximum_Results_Reached";
import TP_Name from "@salesforce/schema/Talent_Pipeline__c.Name";
import TP_Region from "@salesforce/schema/Talent_Pipeline__c.Region__c";
import TP_jobFamilyGroup from "@salesforce/schema/Talent_Pipeline__c.Job_Family_Group__c";
import TP_jobFamily from "@salesforce/schema/Talent_Pipeline__c.Job_Family__c";
import TP_isForActiveJobReq from "@salesforce/schema/Talent_Pipeline__c.Is_for_Active_Job_Req__c";
import TP_headCount from "@salesforce/schema/Talent_Pipeline__c.Ideal_Hired_Target_Headcount__c";
import TP_isActive from "@salesforce/schema/Talent_Pipeline__c.Active__c";
import TP_GeoHub from "@salesforce/schema/Talent_Pipeline__c.Geo_Hub__c";
import TP_JobProfile from "@salesforce/schema/Talent_Pipeline__c.Job_Profile__c";
import TP_Industry from "@salesforce/schema/Talent_Pipeline__c.Industry__c";
import { getRecord } from "lightning/uiRecordApi";

export default class CandidateFinder extends NavigationMixin(LightningElement) {
  contactResults = [];
  contactResultsListView = [];
  contactResultsMap = new Map();
  contactStages;
  searchText;
  countries;
  candidateSourceValues;
  candidateDegreeValues;
  candidateFieldOfStudyValues;
  visibleContacts;
  selectedContactStages = [];
  selectedCountries = [];
  selectedCandidateSources = [];
  selectedCandidateDegrees = [];
  selectedCandidateFieldOfStudy = [];
  searchFilters = "";
  spinner = false;
  selectedCandidates = [];
  selectedCandidatesMap = new Map();
  firstLoad = true;
  listView = false;
  selectedRows = [];
  campaignMemberObjectAPIName = "CampaignMember";
  talentPipelineCandidateObjectAPIName = "Talent_Pipeline_Candidate__c";
  label = { CandidateCardHelptext, CandidateMatchStatus, MaximumResultsReached };
  appliedContacts = [];
  reviewedCandidates = [];
  selectedTags = [];
  isMultiEntry = false;
  isMultiEntryAccount = true;
  isMultiEntryTalentPipeline = false;
  errors = [];
  @track isShowLookupModal = false;
  @track isShowTalentPipelineModal = false;
  @track isShowNewTalentPipelineModal = false;
  selectedCampaignId = [];
  country;
  state;
  zipCode;
  selectedAccountIds = [];
  rowLimit = 0;
  rowOffSet = 0;
  defaultRowLimit = 0;
  @api lessThanLimitReturned = false;
  @api maxNumberOfRecords;
  helpLink;
  resultExhausted = false;
  selectedTalentPipelineId = [];
  newCreatedTalentPipelineId;
  fields = [
    TP_Name,
    TP_Region,
    TP_jobFamilyGroup,
    TP_jobFamily,
    TP_isForActiveJobReq,
    TP_headCount,
    TP_isActive,
    TP_GeoHub,
    TP_JobProfile,
    TP_Industry
  ];
  talentPipelineRecId;
  talentPipelineRec;
  newPipelineSuccessMessage;
  distance = 1;
  isShowResumeModal = false;
  contactResume;
  timer;
  candidateSearchFromPipeline = false;
  resolutionMedium = false;
  resolutionHigh = false;
  dataTableSizeClass;
  @track sortBy;
  @track sortDirection;
  columns = [
    {
      label: "Resume",
      type: "button-icon",
      typeAttributes: {
        name: "View Resume",
        title: "View Resume",
        iconName: "utility:description",
        disabled: { fieldName: "textResumeIsDisabled" },
        value: "view",
        iconPosition: "left"
      }
    },
    {
      label: "LinkedIn",
      type: "button-icon",
      typeAttributes: {
        name: "View LinkedIn",
        title: "View LinkedIn",
        iconName: "utility:profile",
        disabled: { fieldName: "LinkedInIsDisabled" },
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
    { label: "Email", fieldName: "Email", type: "email", sortable: true },
    { label: "Phone", fieldName: "Phone", type: "phone" },
    {
      label: "MRS Application",
      fieldName: "JobURL",
      type: "url",
      sortable: true,
      typeAttributes: { label: { fieldName: "MRSApplication" }, target: "_blank" }
    },
    //{ label: 'MRS Application', type: "text", fieldName : 'MRSApplication'},
    { label: "Candidate Stage", fieldName: "Stage", sortable: true },
    { label: "Job Title", fieldName: "Title", sortable: true },
    { label: "Current Company", fieldName: "Company", type: "text", sortable: true },
    { label: "Candidate Source", fieldName: "Source", sortable: true },
    { label: "URM", type: "boolean", fieldName: "URM", sortable: true },
    { label: "URG", type: "boolean", fieldName: "URG", sortable: true },
    { label: "Silver Medalist", type: "boolean", fieldName: "SM", sortable: true }
  ];

  renderedCallback() {
    this.pageLayoutChanged();
    window.addEventListener("keydown", (event) => {
      if (event.key === "Escape") {
        if (this.isShowLookupModal) this.hideLookupSearchModal();
        if (this.isShowTalentPipelineModal) this.hideTalentPipelineModal();
        if (this.isShowResumeModal) this.hideTextResume();
      }
    });
  }

  connectedCallback() {
    this.pageLayoutChanged();
    getFilterValuesOnPageLoad()
      .then((result) => {
        this.newPipelineSuccessMessage = result.cemciSearchSettings.New_Pipeline_Success__c;
        this.defaultRowLimit = result.cemciSearchSettings.Search_Query_Limit__c;
        this.helpLink = result.cemciSearchSettings.Help_Link__c;
        this.maxNumberOfRecords = 2000 + this.defaultRowLimit;
        let options = [];
        if (result) {
          result.contactStageValues.forEach((r) => {
            options.push({ label: r, value: r });
          });
          this.contactStages = options;
          options = [];

          result.contactCountryValues.forEach((r) => {
            let values = r.split("-", 2);
            options.push({ label: values[1], value: values[0] });
          });
          this.countries = options;
          options = [];

          result.candidateSourceValues.forEach((r) => {
            let values = r.split("/API/", 2);
            options.push({ label: values[1], value: values[0] });
          });
          this.candidateSourceValues = options;
          options = [];

          result.candidateDegreeValues.forEach((r) => {
            let values = r.split("/API/", 2);
            options.push({ label: values[1], value: values[0] });
          });
          this.candidateDegreeValues = options;
          options = [];

          result.candidateFieldOfStudyValues.forEach((r) => {
            let values = r.split("/API/", 2);
            options.push({ label: values[1], value: values[0] });
          });
          this.candidateFieldOfStudyValues = options;
        }
      })
      .catch((error) => {
        this.fireToastEvent("Error!", error.body.message, "error");
      });
  }

  pageLayoutChanged() {
    if (window.innerWidth < 1700) {
      this.resolutionMedium = true;
      this.dataTableSizeClass = "dataTableMedSize";
    } else if (window.innerWidth >= 1700 && window.innerWidth < 2500) {
      this.resolutionHigh = true;
      this.dataTableSizeClass = "dataTableLargeSize";
    }
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.urlStateParameters = currentPageReference.state;
      this.talentPipelineRecId = this.urlStateParameters.c__recordId;
      if (this.urlStateParameters.c__source && this.urlStateParameters.c__source == "talentPipeline") {
        this.candidateSearchFromPipeline = true;
      }
    }
  }

  doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortBy = this.sortBy === "ContactURL" ? "Name" : this.sortBy === "JobURL" ? "MRSApplication" : this.sortBy;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
    this.sortBy = event.detail.fieldName;
  }

  sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.contactResultsListView));
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
    this.contactResultsListView = parseData;
  }

  @wire(getRecord, { recordId: "$talentPipelineRecId", fields: [TP_Name] })
  talentPipeline({ error, data }) {
    if (data) {
      this.talentPipelineRec = data;
    } else if (error) {
      if (Array.isArray(error.body)) {
        message = error.body.map((e) => e.message).join(", ");
      } else if (typeof error.body.message === "string") {
        message = error.body.message;
      }
    }
  }

  get getElementSize() {
    return this.helpLink ? 4 : 5;
  }

  handleKeyUp(event) {
    if (event.key === "Enter") this.handleSearch();
  }

  backtoTalentPipeline() {
    window.location.replace("/lightning/r/Talent_Pipeline__c/" + this.talentPipelineRecId + "/view");
  }

  handleSearch() {
    this.rowLimit = this.defaultRowLimit;
    this.rowOffSet = 0;
    this.contactResults = [];
    this.contactResultsMap = new Map();
    this.contactResultsListView = [];
    this.search();
  }

  search() {
    this.firstLoad = false;
    let parameters = this.prepareApexParams();
    parameters = JSON.stringify(parameters);
    this.showSpinner();
    findContacts({
      soslSearchText: this.searchText,
      searchFilters: parameters,
      limitSize: this.rowLimit,
      offset: this.rowOffSet,
      talentPipelineId: this.talentPipelineRecId
    })
      .then((result) => {
        if (result.contacts === undefined || result.contacts.length === 0) {
        } else {
          if (result.contacts.length < this.rowLimit) {
            this.lessThanLimitReturned = true;
          } else {
            this.lessThanLimitReturned = false;
          }

          let updatedContactsListView = [
            ...this.contactResultsListView,
            ...this.generateDataForListView([...result.contacts])
          ];
          this.contactResultsListView = updatedContactsListView;
          let updatedContacts = [...this.contactResults, ...result.contacts];
          this.contactResults = updatedContacts;
          this.appliedContacts = result.appliedContactIds;
          this.reviewedCandidates = result.reviewedCandidates;
          this.contactResults.forEach((obj) => {
            this.contactResultsMap.set(obj.Id, obj);
          });
          this.template.querySelector("c-pagination").setData(this.contactResults);
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

  generateDataForListView(contacts) {
    let listViewContacts = contacts.map(
      (contact) =>
        new Object({
          Id: contact.Id,
          Name: contact.Name,
          Stage: contact.Candidate_Stage__c,
          ContactURL: "/" + contact.Id,
          Email: contact.Email,
          Phone: contact.Phone,
          Title: contact.Title,
          Company: contact.Account ? contact.Account.Name : "",
          Source: contact.WD_Candidate_Source__c,
          textResumeIsDisabled: contact.Text_Resume__c == null ? true : false,
          TextResume: contact.Text_Resume__c,
          LinkedInURL: contact.IsValid_LinkedIn_URL__c ? contact.LinkedIn_Profile_URL__c : "",
          LinkedInIsDisabled: contact.IsValid_LinkedIn_URL__c ? false : true,
          URM: contact.URM__c ? true : false,
          URG: contact.URG__c ? true : false,
          SM: contact.Silver_Medalist__c ? true : false,
          JobURL: contact.MRS_App__r && contact.MRS_App__r.Job__c ? "/" + contact.MRS_App__r.Job__c : "",
          MRSApplication:
            contact.MRS_App__r && contact.MRS_App__r.Job__r && contact.MRS_App__r.Application_Date__c
              ? contact.MRS_App__r.Job__r.Name + ", Date Applied - " + contact.MRS_App__r.Application_Date__c
              : contact.MRS_App__r && contact.MRS_App__r.Job__r
              ? contact.MRS_App__r.Job__r.Name
              : ""
        })
    );
    return listViewContacts;
  }

  callRowAction(event) {
    const recId = event.detail.row.Id;
    const actionName = event.detail.action.name;
    let candidates = this.contactResultsListView;
    if (actionName === "View Resume") {
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
    if (actionName === "View LinkedIn") {
      for (let i = 0; i < candidates.length; i++) {
        if (candidates[i].Id === recId && candidates[i].LinkedInURL) {
          window.open(candidates[i].LinkedInURL, "_blank");
        }
      }
    }
  }

  handleRowSelect(event) {
    this.selectedRows = [];
    this.selectedCandidatesMap = new Map();
    let selectedRowsFromListView = event.detail.selectedRows;
    if (!selectedRowsFromListView.length) {
      this.selectedCandidatesMap = new Map();
    } else {
      for (let i = 0; i < selectedRowsFromListView.length; i++) {
        this.selectedRows.push(selectedRowsFromListView[i].Id);
        this.selectedCandidatesMap.set(selectedRowsFromListView[i].Id, selectedRowsFromListView[i].Email);
      }
    }
  }

  hideTextResume() {
    this.isShowResumeModal = false;
    this.contactResume = "";
  }

  showSpinner() {
    this.spinner = true;
  }

  hideSpinner() {
    this.spinner = false;
  }

  addToCampaign() {
    if (this.selectedCampaignId.length === 0) {
      this.fireToastEvent("Error!", "Please select a Campaign", "error");
      return;
    }

    if (this.selectedCandidatesMap.size === 0) {
      this.fireToastEvent("", "No records were selected to add to Campaign", "info");
      return;
    }
    this.template.querySelector("c-cemci-lookup").showSpinner();
    this.showSpinner();
    let selectedCampaign = this.selectedCampaignId[0].id;

    let campaignMembers = [];
    let selectedCandidates = [...this.selectedCandidatesMap.keys()];
    for (let i = 0; i < selectedCandidates.length; i++) {
      let campaignMember = {};
      campaignMember.sobjectType = this.campaignMemberObjectAPIName;
      campaignMember.ContactId = selectedCandidates[i];
      campaignMember.CampaignId = selectedCampaign;
      campaignMembers.push(campaignMember);
    }

    CreateCampaignMembers({
      campaignMembers: campaignMembers,
      campaignId: selectedCampaign
    })
      .then((result) => {
        this.resetContactData();
        if (result.includes("new campaign members were added to campaign!")) {
          this.fireToastEvent("Success!", "Campaign members were added to a campaign", "success");
          this.selectedCampaignId = [];
        } else {
          this.fireToastEvent("Error!", result, "error");
        }
        this.isShowLookupModal = false;
      })
      .catch((error) => {
        if(error.body && error.body.message){
          this.fireToastEvent("Error!",error.body.message , "error");
        }
        else{
          this.fireToastEvent("Error!", "Something went wrong. Please try again.", "error");
        }
        this.isShowLookupModal = false;
      });
    this.template.querySelector("c-cemci-lookup").hideSpinner();
    this.hideSpinner();
  }

  addToTalentPipeline() {
    if (
      this.selectedTalentPipelineId.length === 0 &&
      this.newCreatedTalentPipelineId === undefined &&
      this.talentPipelineRecId === undefined
    ) {
      this.fireToastEvent("Error!", "Please select a Talent Pipeline", "error");
      return;
    }

    if (this.selectedCandidatesMap.size === 0) {
      this.fireToastEvent("", "No records were selected to add to Talent Pipeline", "info");
      return;
    }

    let talentPipelineId;
    if (this.talentPipelineRecId !== undefined) {
      this.showSpinner();
      talentPipelineId = this.talentPipelineRecId;
    } else if (this.newCreatedTalentPipelineId !== undefined) {
      this.template.querySelector("c-cemci-lookup").showSpinner();
      talentPipelineId = this.newCreatedTalentPipelineId;
    } else {
      this.template.querySelector("c-cemci-lookup").showSpinner();
      talentPipelineId = this.selectedTalentPipelineId[0].id;
      this.talentPipelineRecId = talentPipelineId;
    }

    let talentPipelineCandidates = [];
    let selectedCandidates = [...this.selectedCandidatesMap.keys()];
    for (let i = 0; i < selectedCandidates.length; i++) {
      let talentPipelineCandidate = {};
      talentPipelineCandidate.sobjectType = this.talentPipelineCandidateObjectAPIName;
      talentPipelineCandidate.Contact__c = selectedCandidates[i];
      talentPipelineCandidate.Talent_Pipeline__c = talentPipelineId;
      talentPipelineCandidates.push(talentPipelineCandidate);
    }

    CreateTalentPipelineCandidates({
      tpCandidates: talentPipelineCandidates,
      tpId: talentPipelineId
    })
      .then((result) => {
        this.resetContactData();
        if (result.includes("new candidates were added to Talent Pipeline!")) {
          this.fireToastEvent(
            "Success!",
            "Candidates were added to a Talent Pipeline : " + this.talentPipelineRec.fields.Name.value,
            "success"
          );
          this.newCreatedTalentPipelineId = undefined;
          this.selectedTalentPipelineId = [];
          this.talentPipelineRecId = this.candidateSearchFromPipeline ? this.talentPipelineRecId : undefined;
          //this.talentPipelineRecId = undefined;
        } else {
          this.fireToastEvent("Error!", result, "error");
        }
        this.isShowTalentPipelineModal = false;
      })
      .catch((error) => {
        if(error.body && error.body.message){
          this.fireToastEvent("Error!",error.body.message , "error");
        }
        else{
          this.fireToastEvent("Error!", "Something went wrong. Please try again.", "error");
        }
        this.isShowTalentPipelineModal = false;
      });
    this.template.querySelector("c-cemci-lookup").hideSpinner();
    this.hideSpinner();
  }

  resetContactData() {
    let arr = [...this.selectedCandidatesMap.keys()];
    arr.forEach((item) => {
      this.contactResultsMap.delete(item);
    });
    this.selectedCandidatesMap = new Map();
    this.contactResults = Array.from(this.contactResultsMap.values());
    this.contactResultsListView = [...this.generateDataForListView([...this.contactResults])];
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

  handleMultiSelectCandidateSources(event) {
    this.selectedCandidateSources = event.detail;
  }

  handleMultiSelectCandidateDegrees(event) {
    this.selectedCandidateDegrees = event.detail;
  }

  handleMultiSelectCandidateFieldOfStudy(event) {
    this.selectedCandidateFieldOfStudy = event.detail;
  }

  handleTags(event) {
    this.selectedTags = event.detail;
  }

  clearLocation() {
    var addressElement = this.template.querySelector("lightning-input-address");
    addressElement.street = "";
    addressElement.city = "";
    addressElement.province = "";
    addressElement.postalCode = "";
    addressElement.country = "";
  }

  prepareApexParams() {
    let inputParam = {};
    var inputElements = this.template.querySelectorAll("lightning-input");
    var addressElement = this.template.querySelector("lightning-input-address");
    var addressString = "";
    if (addressElement.city || addressElement.province || addressElement.postalCode || addressElement.country) {
      addressString =
        addressElement.street +
        ", " +
        addressElement.city +
        ", " +
        addressElement.province +
        ", " +
        addressElement.postalCode +
        " " +
        addressElement.country;
    }
    if (addressString) {
      inputParam[addressElement.name] = addressString;
    }
    if (addressElement.city) {
      inputParam["city"] = addressElement.city;
    }
    if (addressElement.province) {
      inputParam["province"] = addressElement.province;
    }
    if (addressElement.postalCode) {
      inputParam["postalCode"] = addressElement.postalCode;
    }
    if (addressElement.country) {
      inputParam["country"] = addressElement.country;
    }

    inputElements.forEach((inputElement) => {
      if (inputElement.value !== undefined && inputElement.value !== "") {
        inputParam[inputElement.name] = inputElement.value.trim();
      } else if (inputElement.name === "boomerang") {
        inputParam[inputElement.name] = inputElement.checked;
      }
    }, this);
    if (this.selectedAccountIds.length > 0) {
      inputParam["currentEmployer"] = this.selectedAccountIds;
    }
    if (this.selectedContactStages.length > 0) {
      inputParam["contactStages"] = this.selectedContactStages;
    }
    if (this.selectedCandidateSources.length > 0) {
      inputParam["candidateSourceValues"] = this.selectedCandidateSources;
    }
    if (this.selectedCandidateDegrees.length > 0) {
      inputParam["candidateDegreeValues"] = this.selectedCandidateDegrees;
    }
    if (this.selectedCandidateFieldOfStudy.length > 0) {
      inputParam["candidateFieldOfStudyValues"] = this.selectedCandidateFieldOfStudy;
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

    let multiSelectElements = this.template.querySelectorAll("c-cemci-multi-select-combo-box");
    multiSelectElements.forEach((inputElement) => {
      inputElement.clearSelectedValues();
    }, this);
    this.searchText = "";
    this.template.querySelector("c-cemci-tag-container").clearTagsFilterSelectedValues();
    this.template.querySelector("c-cemci-lookup").clearCurrentEmployerSelection();
    this.clearLocation();
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

  handleMaximumResultsReached(event) {
    this.resultExhausted = event.detail.maximumResults;
  }

  addCandidateToSelected(event) {
    this.selectedCandidatesMap.set(event.detail.Id, event.detail);
    this.selectedRows.push(event.detail.Id);
  }

  removeCandidateFromSelected(event) {
    this.selectedCandidatesMap.delete(event.detail.Id);
    if (this.selectedRows.indexOf(event.detail.Id) !== -1) {
      this.selectedRows.splice(this.selectedRows.indexOf(event.detail.Id));
    }
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
  handleLookupSearch(event) {
    const lookupElement = event.target;
    lookupSearch(event.detail)
      .then((results) => {
        lookupElement.setSearchResults(results);
      })
      .catch((error) => {
        this.fireToastEvent("Lookup Error", "An error occured while searching with the lookup field.", "error");
        // eslint-disable-next-line no-console
        console.error("Lookup error", JSON.stringify(error));
        this.errors = [error];
      });
  }

  handleLookupSelectionChange(event) {
    this.checkForErrors(event);
  }

  checkForErrors(event) {
    this.errors = [];
    const selection = this.template.querySelector("c-cemci-lookup").getSelection();
    if (event.detail.objectName === "Campaign") {
      this.selectedCampaignId = selection;
    }
    if (event.detail.objectName === "Account") {
      this.selectedAccountIds = selection.map((acc) => acc.id);
    }
    if (event.detail.objectName === "TalentPipeline") {
      this.selectedTalentPipelineId = selection;
    }
  }

  showLookupSearchModal() {
    if (this.selectedCandidatesMap.size === 0) {
      this.fireToastEvent("", "No records were selected to add to Campaign", "info");
      return;
    } else {
      this.isShowLookupModal = true;
    }
  }

  showTalentPipelineModal() {
    if (this.talentPipelineRecId !== undefined && this.selectedCandidatesMap.size !== 0) {
      this.addToTalentPipeline();
    } else {
      if (this.selectedCandidatesMap.size === 0) {
        this.fireToastEvent("", "No records were selected to add to pipeline", "info");
        return;
      } else {
        this.isShowTalentPipelineModal = true;
      }
    }
  }

  handleNewRecordClick(event) {
    this.isShowNewTalentPipelineModal = true;
  }

  handleNewTPSuccess(event) {
    this.isShowNewTalentPipelineModal = false;
    this.newCreatedTalentPipelineId = event.detail.id;
    this.addToTalentPipeline();
  }

  closeNewTalentPipelineModal() {
    this.isShowNewTalentPipelineModal = false;
  }

  hideLookupSearchModal() {
    this.isShowLookupModal = false;
    this.selectedCampaignId = [];
  }

  hideTalentPipelineModal() {
    this.isShowTalentPipelineModal = false;
    this.selectedTalentPipelineId = [];
  }

  loadMoreDataOnScroll() {
    if (this.contactResultsListView.length >= this.defaultRowLimit) {
      window.clearTimeout(this.timer);
      // event.target.isLoading = true;
      // this.loadMoreStatus = 'Loading';
      this.timer = setTimeout(() => {
        this.loadMoreData();
      }, 500);
    }
  }

  loadMoreData() {
    this.rowOffSet = this.rowOffSet + this.rowLimit;
    if (this.rowOffSet < 2000 + this.rowLimit) {
      this.search();
    } else {
      this.fireToastEvent("", "Maximum Number of Records that can be returned", "info");
    }
  }

  handleHelpLink() {
    const config = {
      type: "standard__webPage",
      attributes: {
        url: this.helpLink
      }
    };
    this[NavigationMixin.Navigate](config);
  }

  handleListViewToggle(event) {
    this.listView = event.target.checked;
  }
}