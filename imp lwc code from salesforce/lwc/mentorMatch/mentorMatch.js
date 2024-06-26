import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { refreshApex } from "@salesforce/apex";
import { NavigationMixin } from "lightning/navigation";
import getProgramAndStages from "@salesforce/apex/MainMentoringController.retrieveProgramStagesFromMentoringMatch";
import getSurveyLinks from "@salesforce/apex/MainMentoringController.retrieveSurveyLinks";

import MENTORING_MATCH_OBJECT from "@salesforce/schema/Mentoring_Match__c";
import MENTOR_ID_FIELD from "@salesforce/schema/Mentoring_Match__c.Mentor__c";
import MENTOR_NAME_FIELD from "@salesforce/schema/Mentoring_Match__c.Mentor__r.Name";
import MENTEE_ID_FIELD from "@salesforce/schema/Mentoring_Match__c.Mentee__c";
import MENTEE_NAME_FIELD from "@salesforce/schema/Mentoring_Match__c.Mentee__r.Name";

import COMPLETED_FIELD from "@salesforce/schema/Program_Stage__c.Completed__c";

//import TEMPLATE SURVEY_OBJECT from "@salesforce/schema/Template_Survey__c";

import MENTEE_LINK_FIELD from "@salesforce/schema/Template_Survey__c.Mentee_Survey_Link__c";
import MENTOR_LINK_FIELD from "@salesforce/schema/Template_Survey__c.Mentor_Survey_Link__c";

import ID from "@salesforce/user/Id";

import mentorLabel from "@salesforce/label/c.mentor";
import menteeLabel from "@salesforce/label/c.mentee";
import yourJourneyLabel from "@salesforce/label/c.match_your_journey";
import markCompletedLabel from "@salesforce/label/c.match_mark_completed";
import stageCompletedLabel from "@salesforce/label/c.match_stage_completed";
import stageWasMarkedCompletedLabel from "@salesforce/label/c.match_Stage_was_marked_as_completed";
import mentoringMatchLabel from "@salesforce/label/c.match_Mentoring_Match";
import templateSurveyLabel from "@salesforce/label/c.match_survey";

export default class MentorMatch extends NavigationMixin(LightningElement) {
  @api recordId;

  @track match;
  @track user;
  @track program;

  wiredProgStages;

  loading = false;
  userId = ID;
  mode = "Mentee";
  activeProgramStageId;

  description;
  linksDescription;
  links = [];
  sessionsDescription;
  sessions = [];
  showMarkCompletedButton = false;
  showOnLastStage = false;

  labels = {
    yourJourneyLabel,
    markCompletedLabel,
    templateSurveyLabel,
  };

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [MENTOR_ID_FIELD, MENTOR_NAME_FIELD, MENTEE_ID_FIELD, MENTEE_NAME_FIELD],
  })
  wiredMentorMatchRecord({ data, error }) {
    if (error) {
      // eslint-disable-next-line
      console.error(error);
    } else if (data) {
      //console.log(data);
      this.match = data;
      //Used to determine the view based on the logged in users relationship to the match
      if (this.userId == getFieldValue(this.match, MENTOR_ID_FIELD)) {
        this.mode = "Mentor";
      } else {
        this.mode = "Mentee";
      }
      //console.log(getFieldValue(this.match, MENTOR_NAME_FIELD));
    }
  }

  @wire(getProgramAndStages, {
    matchId: "$recordId",
  })
  wiredProgramStages(value) {
    this.wiredProgStages = value;
    const { data, error } = value;
    if (error) {
      // eslint-disable-next-line
      console.error(error);
    } else if (data) {
      //console.log("getProgramAndStages: ", data);
      this.program = data;
      //console.log("this.lowestUncompletedStageId", this.lowestUncompletedStageId);
      this.changeStage(this.lowestUncompletedStageId);
    }
  }

  @wire(getSurveyLinks)
  wiredSurveyLinks(value) {
    const { data, error } = value;
    if (error) {
      // eslint-disable-next-line
      console.error(error);
    } else if (data) {
      //console.log("getProgramAndStages: ", data);
      this.theSurveyLinks = data;
      console.log("this.theSurveyLinks", this.theSurveyLinks);
    }
  }
  programStageClicked = (event) => {
    let eventDetail = event.detail;
    //console.log("programStageClicked: ", eventDetail.selected);
    if (eventDetail.selected != null) {
      this.changeStage(eventDetail.selected);
    }
  };

  changeStage = (stageId) => {
    //console.log("changeStage");

    this.description = "";
    this.linksDescription = "";
    this.links = [];
    this.sessionsDescription = "";
    this.sessions = [];
    this.showMarkCompletedButton = false;
    this.showOnLastStage = false;

    this.activeProgramStageId = stageId;
    let programTemp = JSON.parse(JSON.stringify(this.program));

    //Used to set the first option as active on load
    for (let i = 0; i < programTemp.programStages.length; i++) {
      if (programTemp.programStages[i].programStage.Id == stageId) {
        //Show complete survey button on last stage
        if (i + 1 == programTemp.programStages.length) {
          this.showOnLastStage = true;
        }

        programTemp.programStages[i].programStage.Active = true;
        if (!programTemp.programStages[i].programStage.Completed__c) {
          this.showMarkCompletedButton = true;
        }
        if (this.mode == "Mentee") {
          this.description = programTemp.programStages[i].programTemplateStage.Mentee_Description__c;
          this.linksDescription = programTemp.programStages[i].programTemplateStage.Mentee_Links_Description__c;
          for (let x = 0; x < programTemp.programStages[i].programTemplateStage?.Program_Template_Stage_Links__r?.length; x++) {
            if (programTemp.programStages[i].programTemplateStage.Program_Template_Stage_Links__r[x].Visibility__c.indexOf("Mentee") > -1) {
              let newLink = JSON.parse(JSON.stringify(programTemp.programStages[i].programTemplateStage.Program_Template_Stage_Links__r[x]));
              this.links.push(newLink);
            }
          }
          this.sessionsDescription = programTemp.programStages[i].programTemplateStage.Mentee_Sessions_Description__c;
          for (let y = 0; y < programTemp.programStages[i].programTemplateStage?.Program_Template_Stage_Sessions__r?.length; y++) {
            if (programTemp.programStages[i].programTemplateStage.Program_Template_Stage_Sessions__r[y].Visibility__c.indexOf("Mentee") > -1) {
              let newSession = JSON.parse(JSON.stringify(programTemp.programStages[i].programTemplateStage.Program_Template_Stage_Sessions__r[y]));
              this.sessions.push(newSession);
            }
          }
        } else {
          this.description = programTemp.programStages[i].programTemplateStage.Mentor_Description__c;
          this.linksDescription = programTemp.programStages[i].programTemplateStage.Mentor_Links_Description__c;
          for (let x = 0; x < programTemp.programStages[i].programTemplateStage?.Program_Template_Stage_Links__r?.length; x++) {
            if (programTemp.programStages[i].programTemplateStage.Program_Template_Stage_Links__r[x].Visibility__c.indexOf("Mentor") > -1) {
              let newLink = JSON.parse(JSON.stringify(programTemp.programStages[i].programTemplateStage.Program_Template_Stage_Links__r[x]));
              this.links.push(newLink);
            }
          }
          this.sessionsDescription = programTemp.programStages[i].programTemplateStage.Mentor_Sessions_Description__c;
          for (let y = 0; y < programTemp.programStages[i].programTemplateStage?.Program_Template_Stage_Sessions__r?.length; y++) {
            if (programTemp.programStages[i].programTemplateStage.Program_Template_Stage_Sessions__r[y].Visibility__c.indexOf("Mentor") > -1) {
              let newSession = JSON.parse(JSON.stringify(programTemp.programStages[i].programTemplateStage.Program_Template_Stage_Sessions__r[y]));
              this.sessions.push(newSession);
            }
          }
        }
      } else {
        programTemp.programStages[i].programStage.Active = false;
      }
    }
    //console.log("programTemp: ", programTemp);
    this.program = programTemp;
  };

  markCompletedButtonClick = () => {
    console.log("markCompletedButtonClick");

    try {
      const fields = {};
      fields.Id = this.activeProgramStageId;
      fields[COMPLETED_FIELD.fieldApiName] = true;
      const recordInput = {
        fields,
      };
      updateRecord(recordInput)
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: stageCompletedLabel,
              message: stageWasMarkedCompletedLabel,
              variant: "success",
            })
          );
          return refreshApex(this.wiredProgStages);
        })
        .catch((error) => {
          console.log("error: ", error);
        });
      //return refreshApex(this.wiredProgStages);
    } catch (error) {
      //eslint-disable-next-line
      console.error(error);
    }
  };

  goToSurveyButtonClick = () => {
    console.log("mentorgoToSurveyButtonClick");
    if (this.mode == "Mentee") {
      //alert('mentee:'+this.theSurveyLinks[MENTEE_LINK_FIELD.fieldApiName]);
      window.open(this.theSurveyLinks[MENTEE_LINK_FIELD.fieldApiName], "_blank").focus();
    } else if (this.mode == "Mentor") {
      alert('mode:'+this.theSurveyLinks[MENTEE_LINK_FIELD.fieldApiName]);
      window.open(this.theSurveyLinks[MENTOR_LINK_FIELD.fieldApiName], "_blank").focus();
    }
  };

  goToProfile = () => {
    console.log("goToProfile");
    let userId;
    if (this.mode == "Mentee") {
      userId = getFieldValue(this.match, MENTOR_ID_FIELD);
    } else if (this.mode == "Mentor") {
      userId = getFieldValue(this.match, MENTEE_ID_FIELD);
    }
    // this[NavigationMixin.Navigate]({
    //   type: "comm__namedPage",
    //   attributes: {
    //     pageName: "mentoring-profile",
    //   },
    //   state: {
    //     showRequestButtons: false,
    //     userId: userId,
    //   },
    // });
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: userId,
        objectApiName: "User",
        actionName: "view",
      },
    });
  };

  get lowestUncompletedStageId() {
    for (let i = 0; i < this.program?.programStages.length; i++) {
      if (!this.program?.programStages[i]?.programStage?.Completed__c) {
        return this.program?.programStages[i]?.programStage?.Id;
      }
    }
    return this.program?.programStages[0]?.programStage?.Id;
  }

  get pageHeading() {
    if (this.mode == "Mentee") {
      return getFieldValue(this.match, MENTOR_NAME_FIELD) != null ? mentorLabel + ": " + getFieldValue(this.match, MENTOR_NAME_FIELD) : mentoringMatchLabel;
    } else if (this.mode == "Mentor") {
      return getFieldValue(this.match, MENTEE_NAME_FIELD) != null ? menteeLabel + ": " + getFieldValue(this.match, MENTEE_NAME_FIELD) : mentoringMatchLabel;
    }
  }

  get containerClasses() {
    if (this.isMobile) {
      return "slds-is-relative container";
    }
    return "slds-is-relative container";
  }

  get isMobile() {
    return screen.width <= 768;
  }
}