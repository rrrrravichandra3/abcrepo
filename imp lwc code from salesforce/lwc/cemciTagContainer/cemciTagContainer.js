import { LightningElement, track, api } from "lwc";
import getResults from "@salesforce/apex/CEMCI_TopicsController.getResults";
import createTag from "@salesforce/apex/CEMCI_TopicsController.createTag";
import getTagsforRecord from "@salesforce/apex/CEMCI_TopicsController.getTagsforRecord";
import deleteTag from "@salesforce/apex/CEMCI_TopicsController.deleteTag";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CemciTagContainer extends LightningElement {
  @api objectApiName;
  @api recordId;
  @api dontAddTag = false;

  @api selectedValue;
  @api selectedValues = [];
  @api label;
  @api disabled = false;
  @api multiSelect = false;
  @track value;
  @track values = [];
  @track optionData;
  @track searchString;
  @track noResultMessage;
  @track showDropdown = false;

  @api Label;
  @track searchRecords = [];
  @track selectedRecords = [];
  @api required = false;
  @api iconName = "action:new_account";
  @api LoadingText = false;
  @track txtclassname = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  @track messageFlag = false;

  connectedCallback() {
    getTagsforRecord({ recordId: this.recordId, objectAPIName: this.objectApiName })
      .then((result) => {
        //if there are more things to be loaded on page load, we can load a
        //wrapper from apex and store in js in different variables
        let options = [];
        if (result) {
          result.forEach((r) => {
            options.push({ recId: r.Topic__c, recName: r.Topic__r.Name });
          });
        }
        this.selectedRecords = options;
      })
      .catch((error) => {
        this.showToast(
          "Something went wrong loading tags for this " +
            this.objectApiName +
            ". Please contact System Administrator (" +
            error.body.message +
            ")",
          "error"
        );
      });
  }

  searchField(event) {
    var currentText = event.target.value;
    var selectRecId = [];
    for (let i = 0; i < this.selectedRecords.length; i++) {
      selectRecId.push(this.selectedRecords[i].recId);
    }
    this.LoadingText = true;
    getResults({ value: currentText, selectedRecId: selectRecId })
      .then((result) => {
        this.searchRecords = result;
        this.LoadingText = false;

        this.txtclassname =
          result.length > 0
            ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open"
            : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
        if (currentText.length > 0 && result.length == 0) {
          this.messageFlag = true;
        } else {
          this.messageFlag = false;
        }

        if (this.selectRecordId != null && this.selectRecordId.length > 0) {
          this.iconFlag = false;
          this.clearIconFlag = true;
        } else {
          this.iconFlag = true;
          this.clearIconFlag = false;
        }
      })
      .catch((error) => {
        this.showToast(
          "Something went wrong with the search. Please contact System Administrator (" + error.body.message + ")",
          "error"
        );
      });
  }

  setSelectedRecord(event) {
    var recId = event.currentTarget.dataset.id;
    var selectName = event.currentTarget.dataset.name;
    let newsObject = { recId: recId, recName: selectName };
    if (!this.dontAddTag) {
      createTag({
        recordId: this.recordId,
        topicId: newsObject.recId,
        sObjectType: this.sObjectType
      })
        .then((result) => {
          this.selectedRecords.push(newsObject);
          let selRecords = this.selectedRecords;
          this.template.querySelectorAll("lightning-input").forEach((each) => {
            each.value = "";
          });
          const selectedEvent = new CustomEvent("selected", { detail: { selRecords } });
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
        })
        .catch((error) => {
          //handle error
          if (error && error.body) {
            this.showToast(
                error.body.message,
              "error"
            );
          }
        });
    } else {
      this.selectedRecords.push(newsObject);
      let selRecords = this.selectedRecords;
      this.template.querySelectorAll("lightning-input").forEach((each) => {
        each.value = "";
      });
      const selectedEvent = new CustomEvent("selected", { detail: { selRecords } });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    }
    this.txtclassname = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
  }

  removeRecord(event) {
    let selectRecId = [];
    let topicId = event.detail.name;
    if (!this.dontAddTag) {
      deleteTag({
        recordId: this.recordId,
        topicId: topicId
      })
        .then((result) => {
          for (let i = 0; i < this.selectedRecords.length; i++) {
            if (event.detail.name !== this.selectedRecords[i].recId) selectRecId.push(this.selectedRecords[i]);
          }

          this.selectedRecords = [...selectRecId];
          let selRecords = this.selectedRecords;
          const selectedEvent = new CustomEvent("selected", { detail: { selRecords } });
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
        })
        .catch((error) => {
          //handle error
          if (error && error.body) {
            this.showToast(
              "Tag could not be deleted for this record. Please contact System Administrator (" +
                error.body.message +
                ")",
              "error"
            );
          }
        });
    } else {
      for (let i = 0; i < this.selectedRecords.length; i++) {
        if (event.detail.name !== this.selectedRecords[i].recId) selectRecId.push(this.selectedRecords[i]);
      }
      this.selectedRecords = [...selectRecId];
      let selRecords = this.selectedRecords;
      const selectedEvent = new CustomEvent("selected", { detail: { selRecords } });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    }
  }

  @api
  clearTagsFilterSelectedValues() {
    this.selectedRecords = [];
  }

  showToast(message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: variant,
        message: message,
        variant: variant
      })
    );
  }
}