/**
 * @description       :
 * @author            : Venkata Akash Patti (akashpatti)
 * @group             :
 * @last modified on  : 07-08-2022
 * @last modified by  : Urvish Shah (ushah)
 **/

import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getMatchingCandidatesForJobReq from "@salesforce/apex/CEMCI_ManageCandidatePool.getMatchingCandidatesForJobReq";
import updateCandidateStatus from "@salesforce/apex/CEMCI_ManageCandidatePool.updateCandidateStatus";
import sendEmail from "@salesforce/apex/CEMCI_EmailNotificationService.sendEmail";
import { CurrentPageReference } from "lightning/navigation";
import getListofStages from "@salesforce/apex/CEMCI_ManageCandidatePool.getListofStages";
export default class DragAndDropLwc extends LightningElement {
  pickVals = [];
  records = [];
  recordId;
  showLoader;
  jobReqName;
  country;
  candidatesPresent = false;
  candidateStatusChangedFrom;
  candidateStatusChangedTo;
  candidateShiftData = [];
  @track listOfUpdatedStatus = [];

  connectedCallback() {
    this.getListofStages();
    this.getListofCandidates();
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.urlStateParameters = currentPageReference.state;
      this.recordId = this.urlStateParameters.c__recordId;
    }
  }

  refreshTable(e) {
    this.records = [];
    this.showLoader = true;
    this.getListofCandidates();
  }

  getListofStages() {
    getListofStages()
      .then((result) => {
        if (result) {
          this.pickVals = result;
        }
      })
      .catch((error) => {
        this.fireToastEvent("Error!", error.body.message, "error");
      });
  }

  getListofCandidates() {
    getMatchingCandidatesForJobReq({
      jobReqId: this.urlStateParameters.c__recordId
    })
      .then((result) => {
        this.candidatesPresent = result && result.length > 0 ? true : false;
        if (this.candidatesPresent) {
          (this.jobReqName = result[0].WD_Job_Requisition__r.Name),
            (this.country = result[0].WD_Job_Requisition__r.Country__c),
            (this.records = result.map((val) => ({
              name: val.Candidate__r.Name,
              email: val.Candidate__r.Email,
              recentCompany: val.Candidate__r.Account.Name,
              stage: val.Status__c,
              linkedinURL: val.Candidate__r.IsValid_LinkedIn_URL__c,
              id: val.Id,
              source: val.Candidate__r.Original_Lead_Source__c,
              title: val.Candidate__r.Title,
              candidateId: val.Candidate__c
            })));
          this.showLoader = false;
        }
      })
      .catch((error) => {
        this.showLoader = false;
        this.fireToastEvent("Error!", error.body.message, "error");
      });
  }

  get calcWidth() {
    let len = this.pickVals.length;
    return `width: 24.8%`;
  }

  handleListItemDrag(event) {
    this.recordId = event.detail.id;
    this.candidateStatusChangedFrom = event.detail.stage;
  }

  handleRemoveFromPool(event) {
    this.showToast("The Candidate Has been removed from pool", "Success");
    this.refreshTable();
  }

  handleItemDrop(event) {
    this.candidateStatusChangedTo = event.detail;
    this.prepareNotificationData();
    // this.records = this.records.map(item=>{
    //     return item.id === this.recordId ? {...item, stage:stage}:{...item}
    // }
    let duplicate = this.records.filter((val) => val.id === this.recordId);
    if ((duplicate.length == 0 || duplicate[0].stage !== event.detail) && event.detail != "") {
      updateCandidateStatus({
        candidateId: this.recordId,
        newStatus: event.detail
      }).then(() => {
        this.getListofCandidates();
        this.showToast("Stage updated Successfully", "Success");
      });
    }
  }

  prepareNotificationData() {
    let candidateIndex = this.candidateShiftData.findIndex((data) => data.candidateId === this.recordId);
    if (candidateIndex === -1) {
      this.candidateShiftData.push({
        candidateId: this.recordId,
        statusChangedFrom: this.candidateStatusChangedFrom,
        statusChangedTo: this.candidateStatusChangedTo
      });
    } else {
      this.candidateShiftData[candidateIndex].statusChangedTo = this.candidateStatusChangedTo;
    }
    this.candidateShiftData = this.candidateShiftData.filter((data) => data.statusChangedFrom !== data.statusChangedTo);
    this.listOfUpdatedStatus = this.candidateShiftData.map(function (obj) {
      return obj.statusChangedTo;
    });
    this.listOfUpdatedStatus = [...new Set(this.listOfUpdatedStatus)];
  }

  notify() {
    if (this.listOfUpdatedStatus.length !== 0) {
      sendEmail({
        jobReqId: this.urlStateParameters.c__recordId,
        candidatePoolUpdatedStatuses: this.listOfUpdatedStatus
      })
        .then((result) => {
          if (result) {
            this.candidateShiftData = [];
            this.listOfUpdatedStatus = [];
            this.showToast("Email Notification Sent", "Success");
          } else {
            this.showToast("Something went wrong", "Error");
          }
        })
        .catch((error) => {
          this.showToast(error.body.message, "Error");
        });
    }
  }

  get disableNotifyButton() {
    return !(
      this.listOfUpdatedStatus &&
      this.listOfUpdatedStatus.length &&
      JSON.stringify(this.listOfUpdatedStatus) !== JSON.stringify(["Sourced Candidate"])
    );
  }

  backtoJobReq() {
    window.location.replace("/lightning/r/WDR_Job__c/" + this.urlStateParameters.c__recordId + "/view");
  }

  backtoSearch() {
    window.location.replace("/lightning/n/Candidate_Finder_Tab?c__recordId=" + this.urlStateParameters.c__recordId);
  }

  showToast(message, status) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: status,
        message: message,
        variant: status
      })
    );
  }
}