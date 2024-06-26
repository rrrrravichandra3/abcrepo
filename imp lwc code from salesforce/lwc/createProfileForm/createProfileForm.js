import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { updateRecord, getRecord } from "lightning/uiRecordApi";
import { getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import USER_OBJECT from "@salesforce/schema/User";
//import MENTEE_TYPE_FIELD from "@salesforce/schema/User.Mentee_Type_Preference__c";
import MEMTORING_MODE from "@salesforce/schema/User.Mentoring_Mode__c";
import MENTOR_TYPE_FIELD from "@salesforce/schema/User.Mentor_Type_Preference__c";
// import MENTEE_LOCATION_FIELD from "@salesforce/schema/User.Mentee_Location_Preference__c";
// import MENTOR_LOCATION_FIELD from "@salesforce/schema/User.Mentor_Location_Preference__c";
import INTERESTS_FIELD from "@salesforce/schema/User.Interests__c";
import LINKEDIN_FIELD from "@salesforce/schema/User.LinkedIn_Profile__c";
import MENTORING_LANGUAGE_FIELD from "@salesforce/schema/User.Mentoring_Language__c";
import GREAT_COMPETENCIES_FIELD from "@salesforce/schema/User.Great_Competencies__c";
import GREAT_COMPETENCIES_IMPROVE_FIELD from "@salesforce/schema/User.Great_Competencies_to_Improve__c";
import EXPERIENCES_FIELD from "@salesforce/schema/User.Experiences__c";
import EXPERIENCES_IMPROVE_FIELD from "@salesforce/schema/User.Experiences_to_Improve__c";

import FUNCTIONAL_COMPETENCIES_FIELD from "@salesforce/schema/User.Functional_Competencies__c";
import FUNCTIONAL_COMPETENCIES_IMPROVE_FIELD from "@salesforce/schema/User.Functional_Competencies_to_Improve__c";
import USER_BIO_FIELD from "@salesforce/schema/User.User_Bio__c";
//import SKILLS_IMPROVE_FIELD from "@salesforce/schema/User.Skills_to_Improve__c";
//import LEARN_FIELD from '@salesforce/schema/User.Things_To_Learn__c';
import COMPLETED_MENTEE_FLOW_FIELD from "@salesforce/schema/User.Completed_Mentee_Onboarding_Flow__c";
import COMPLETED_MENTOR_FLOW_FIELD from "@salesforce/schema/User.Completed_Mentor_Onboarding_Flow__c";

import getRolesAndCompetencies from "@salesforce/apex/MainMentoringController.retrieveRolesAndCompetencies";

import Id from "@salesforce/user/Id";

import competenciesMentorFramingLabel from "@salesforce/label/c.create_profile_competencies_mentor_framing";
import competenciesMenteeFramingLabel from "@salesforce/label/c.create_profile_competencies_mentee_framing";

import whichCompetenciesDoYouWishToImproveLabel from "@salesforce/label/c.create_profile_Which_competencies_do_you_wish_to_improve";
import howWouldYouLikeToBeSupportedLabel from "@salesforce/label/c.create_profile_How_would_you_like_to_be_supported";
import mentorFunctionalCompetenciesFramingLabel from "@salesforce/label/c.create_profile_mentor_functional_competencies_framing";
import whichFunctionalCompetenciesSpecificallyDoYouWishToImproveLabel from "@salesforce/label/c.create_profile_Which_functional_competencies_specifically_do_you_wish_to_improve";
import howCanYouSupportOthersLabel from "@salesforce/label/c.create_profile_How_can_you_support_others";
import menteeFunctionalCompetenciesFramingLabel from "@salesforce/label/c.create_profile_mentee_functional_competencies_framing";
import whatCompetenciesAreYouAbleToShareLabel from "@salesforce/label/c.create_profile_What_competencies_are_you_able_to_share";
import whichFunctionalCompetenciesSpecificallyAreYouAbleToShareLabel from "@salesforce/label/c.create_profile_Which_functional_competencies_specifically_are_you_able_to_share";
import whatTypeOfMentoringDoYouPreferLabel from "@salesforce/label/c.create_profile_What_type_of_mentoring_do_you_prefer";
import whatLanguagesDoYouPreferLabel from "@salesforce/label/c.create_profile_What_language_s_do_you_prefer";
import tellUsAboutYourselfLabel from "@salesforce/label/c.create_profile_Tell_Us_About_Yourself";
import thisDisplaysOnYouProfileAndHelpsPeopleLabel from "@salesforce/label/c.create_profile_This_displays_on_your_profile_and_helps_people";
import whatBestDescribesYouLabel from "@salesforce/label/c.create_profile_What_best_describes_you";
import whatIsYourLinkedInUsername from "@salesforce/label/c.create_profile_What_is_your_linkedin_username";
import whatIsYourLinkedInProfile from "@salesforce/label/c.create_profile_What_is_your_LinkedIn_Profile";
import whichEqualityGroupsDoYouSupportLabel from "@salesforce/label/c.create_profile_Which_Equality_Groups_do_you_support";
//import backLabel from "@salesforce/label/c.Back";
//import nextLabel from "@salesforce/label/c.Next";
//import finishLabel from "@salesforce/label/c.Finish";
import singleSelectComboboxLabel from "@salesforce/label/c.Single_Select_Combobox";
import close from "@salesforce/label/c.close";
import save from "@salesforce/label/c.save";
import Family from "@salesforce/schema/Product2.Family";
import PleaseSelectExperiencesLabel from "@salesforce/label/c.Please_Select_Experiences_Label";
import PleaseselectgreatcompetenciesLabel from "@salesforce/label/c.Please_select_great_competencies_Label";
import PleaseselectfunctionalcompetenciesLabel from "@salesforce/label/c.Please_select_functional_competencies_Label";
import PleaseselectyourpreferenceLabel from "@salesforce/label/c.Please_select_your_preference_Label";
import PleaseselectpreferredlanguageLabel from "@salesforce/label/c.Please_select_preferred_language_Label";
//import PleaseselectanoptionLabel from "@salesforce/label/c.Please_select_an_option_Label";
import BioLabel from "@salesforce/label/c.Bio_Label";
import LinkedinProfileLable from "@salesforce/label/c.Linkedin_Profile_Lable";
import MyPersonalityLable from "@salesforce/label/c.My_Personality_Lable";

export default class CreateProfileForm extends NavigationMixin(
  LightningElement
) {
  userId = Id;
  picklistFieldValues;
  roleCompetencyValues;
  @track recordData;
  @track showExperiencesToImproveError = false;
  @track showGreatCompetenciesToImproveError = false;
  @track showFunctionalCompetenciesToImproveError = false;
  @track showHowCanYouSupportOthersError = false;
  @track showWhatGreatCompetenciesAreYouAbleToShareError = false;
  @track showWhatFunctionalCompetenciesAreYouAbleToShareError = false;
  @track showWhatTypeOfMentoringDoYouPreferError = false;
  @track showWhatLanguagesDoYouPreferError = false;
  @track showBestDescribedError = false;
  @api mode;
  @api showDropdown = false;

  labels = {
    competenciesMentorFramingLabel,
    competenciesMenteeFramingLabel,
    whichCompetenciesDoYouWishToImproveLabel,
    howWouldYouLikeToBeSupportedLabel,
    mentorFunctionalCompetenciesFramingLabel,
    whichFunctionalCompetenciesSpecificallyDoYouWishToImproveLabel,
    howCanYouSupportOthersLabel,
    whatCompetenciesAreYouAbleToShareLabel,
    menteeFunctionalCompetenciesFramingLabel,
    whichFunctionalCompetenciesSpecificallyAreYouAbleToShareLabel,
    whatTypeOfMentoringDoYouPreferLabel,
    whatLanguagesDoYouPreferLabel,
    tellUsAboutYourselfLabel,
    thisDisplaysOnYouProfileAndHelpsPeopleLabel,
    whatBestDescribesYouLabel,
    whatIsYourLinkedInProfile,
    whichEqualityGroupsDoYouSupportLabel,
   // backLabel,
   // nextLabel,
   // finishLabel,
    singleSelectComboboxLabel,
    close,
    save,
    PleaseSelectExperiencesLabel,
    PleaseselectgreatcompetenciesLabel,
    PleaseselectfunctionalcompetenciesLabel,
    PleaseselectyourpreferenceLabel,
    PleaseselectpreferredlanguageLabel,
    BioLabel,
    LinkedinProfileLable,
    MyPersonalityLable

  };

  @wire(CurrentPageReference)
  pageRef;

  @wire(getRecord, {
    recordId: "$userId",
    fields: [
      GREAT_COMPETENCIES_IMPROVE_FIELD,
      GREAT_COMPETENCIES_FIELD,
      EXPERIENCES_IMPROVE_FIELD,
      EXPERIENCES_FIELD,
      FUNCTIONAL_COMPETENCIES_FIELD,
      FUNCTIONAL_COMPETENCIES_IMPROVE_FIELD,
      INTERESTS_FIELD,
      LINKEDIN_FIELD,
      USER_BIO_FIELD,
      MEMTORING_MODE,
      MENTOR_TYPE_FIELD,
      MENTORING_LANGUAGE_FIELD
    ]
  })
  wiredRecord({ data, error }) {
    if (error) {
      // eslint-disable-next-line
      console.error(error);
    } else if (data) {
      this.recordData = data;
    }
  }

  @wire(getPicklistValuesByRecordType, {
    recordTypeId: "012000000000000AAA", // default record type id
    objectApiName: USER_OBJECT
  })
  wiredPicklistValues({ error, data }) {
    if (error) {
      // eslint-disable-next-line
      console.error("picklistError: ", error);
    } else if (data) {
      console.log("picklist", data);
      this.picklistFieldValues = data.picklistFieldValues;
    }
  }

  @wire(getRolesAndCompetencies)
  wiredApexMethod({ error, data }) {
    if (error) {
      console.error("Error: ", error);
      this.loading = false;
      this.showUnsupportedBanner = true;
    } else if (data) {
      console.log("fieldSettings: ", this.fieldSettings);
      console.log("data: ", data);
      let tempFilterData=[];
      for(let i=0; i<data.length; i++){
        tempFilterData.push(...data[i].values);
      }
      this.roleCompetencyValues = tempFilterData.map(function (child) {
        let tempPicklistValue = {
          name: child.label,
          label: child.label,
          value: child.value,
          id: child.value,
          key: child.value,
          tree: false,
          searchDisplay: true,
          children:[],
        };          
        return tempPicklistValue;
      });
      // this.roleCompetencyValues = data.map(({ Id, Name, Functional_Competencies__c }) => {
      //   let value = {
      //     Id,
      //     Name,
      //     children: Functional_Competencies__c.split(";").map((comp) => {
      //       return { label: comp, value: comp, key: Id + "-" + comp };
      //     }),
      //   };
      //   return value;
      // });
    }
  }

  skipFlow() {
    // if (this.mode === "Mentee") {
    this.dispatchEvent(new CustomEvent("close"));
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {}
    });
    // } else {
    //   this[NavigationMixin.Navigate]({
    //     type: "standard__namedPage",
    //     attributes: {
    //       pageName: "my-mentees",
    //     },
    //   });
    // }
  }

  get showCombo() {
    return this.picklistFieldValues &&
      this.recordData &&
      this.roleCompetencyValues
      ? true
      : false;
  }

  get fieldSettings() {
    return {
      // Mentee Competencies and Experiences
      greatCompetenciesImproveField: {
        field: GREAT_COMPETENCIES_IMPROVE_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[
              GREAT_COMPETENCIES_IMPROVE_FIELD.fieldApiName
            ].values
          : [],
        value: this.recordData
          ? this.recordData.fields[
              GREAT_COMPETENCIES_IMPROVE_FIELD.fieldApiName
            ].value?.split(";")
          : []
      },
      experienceImproveField: {
        field: EXPERIENCES_IMPROVE_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[EXPERIENCES_IMPROVE_FIELD.fieldApiName]
              .values
          : [],
        value: this.recordData
          ? this.recordData.fields[
              EXPERIENCES_IMPROVE_FIELD.fieldApiName
            ].value?.split(";")
          : []
      },
      functionalCompetenciesImproveField: {
        field: FUNCTIONAL_COMPETENCIES_IMPROVE_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[
              FUNCTIONAL_COMPETENCIES_IMPROVE_FIELD.fieldApiName
            ].values
          : [],
        value: this.recordData
          ? this.recordData.fields[
              FUNCTIONAL_COMPETENCIES_IMPROVE_FIELD.fieldApiName
            ].value?.split(";")
          : []
      },

      // Mentor Competencies and Experiences
      greatCompetenciesField: {
        field: GREAT_COMPETENCIES_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[GREAT_COMPETENCIES_FIELD.fieldApiName]
              .values
          : [],
        value: this.recordData
          ? this.recordData.fields[
              GREAT_COMPETENCIES_FIELD.fieldApiName
            ].value?.split(";")
          : []
      },
      experienceField: {
        field: EXPERIENCES_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[EXPERIENCES_FIELD.fieldApiName].values
          : [],
        value: this.recordData
          ? this.recordData.fields[EXPERIENCES_FIELD.fieldApiName].value?.split(
              ";"
            )
          : []
      },
      functionalCompetenciesField: {
        field: FUNCTIONAL_COMPETENCIES_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[FUNCTIONAL_COMPETENCIES_FIELD.fieldApiName]
              .values
          : [],
        value: this.recordData
          ? this.recordData.fields[
              FUNCTIONAL_COMPETENCIES_FIELD.fieldApiName
            ].value?.split(";")
          : []
      },
      functionalCompetenciesField: {
        field: FUNCTIONAL_COMPETENCIES_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[FUNCTIONAL_COMPETENCIES_FIELD.fieldApiName]
              .values
          : [],
        value: this.recordData
          ? this.recordData.fields[
              FUNCTIONAL_COMPETENCIES_FIELD.fieldApiName
            ].value?.split(";")
          : []
      },
      // User Bio
      userBioField: {
        field: USER_BIO_FIELD,
        value: this.recordData
          ? this.recordData.fields[USER_BIO_FIELD.fieldApiName].value?.split(
              ";"
            )
          : []
      },
      mentoringTypeField: {
        field: MENTOR_TYPE_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[MENTOR_TYPE_FIELD.fieldApiName].values
          : [],
        value: this.recordData
          ? this.recordData.fields[MENTOR_TYPE_FIELD.fieldApiName].value?.split(
              ";"
            )
          : []
      },
      mentoringLanguageField: {
        field: MENTORING_LANGUAGE_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[MENTORING_LANGUAGE_FIELD.fieldApiName]
              .values
          : [],
        value: this.recordData
          ? this.recordData.fields[
              MENTORING_LANGUAGE_FIELD.fieldApiName
            ].value?.split(";")
          : []
      },
      interestsField: {
        field: INTERESTS_FIELD,
        options: this.picklistFieldValues
          ? this.picklistFieldValues[INTERESTS_FIELD.fieldApiName].values
          : [],
        value: this.recordData
          ? this.recordData.fields[INTERESTS_FIELD.fieldApiName].value?.split(
              ";"
            )
          : []
      },
      linkedInField: {
        field: LINKEDIN_FIELD,
        value: this.recordData
          ? this.recordData.fields[LINKEDIN_FIELD.fieldApiName].value
          : ""
      }
    };
  }

  get flowSteps() {
    let steps;
    const menteeSteps = [{ step: "mentee-skills", progress: "0" }];
    const mentorSteps = [{ step: "mentor-skills", progress: "0" }];
    const commonSteps = [
      { step: "location", progress: "25" },
      { step: "interests", progress: "75" }
    ];

    switch (this.mode) {
      case "Mentee":
        steps = [...menteeSteps, ...commonSteps];
        break;
      case "Mentor":
        steps = [...mentorSteps, ...commonSteps];
        break;
      default:
        steps = [...menteeSteps, ...mentorSteps, ...commonSteps];
        break;
    }
    return steps;
  }

  @api onNext(event) {
    console.log('What am i sending');
    console.log(event)
    this.showExperiencesToImproveError = false;
    this.showGreatCompetenciesToImproveError = false;
    this.showFunctionalCompetenciesToImproveError = false;
    this.showHowCanYouSupportOthersError = false;
    this.showWhatGreatCompetenciesAreYouAbleToShareError = false;
    this.showWhatFunctionalCompetenciesAreYouAbleToShareError = false;
    this.showWhatTypeOfMentoringDoYouPreferError = false;
    this.showWhatLanguagesDoYouPreferError = false;
    this.showBestDescribedError = false;
    this.loading = true;
    const action = event.target.dataset.action;
    let fields = { Id: this.userId };
    if (action === "back") {
      this.loading = false;
      this.setStep(action);
    } else {
      fields = { ...fields, ...this.getFormValues() };
      console.log("fields: ", fields);
      // console.log("action: ", action);
      if (action === "finish") {
        console.log("this.mode: ", this.mode)
        if (this.mode === "Mentee") {
          fields[COMPLETED_MENTEE_FLOW_FIELD.fieldApiName] = true;
        } else {
          fields[COMPLETED_MENTOR_FLOW_FIELD.fieldApiName] = true;
        }
      }

      if (action == "save" || action == "next" || action == "finish") {
        this.showExperiencesToImproveError =
          fields.Experiences_to_Improve__c == "" ? true : false;
        this.showGreatCompetenciesToImproveError =
          fields.Great_Competencies_to_Improve__c == "" ? true : false;
        //this.showFunctionalCompetenciesToImproveError =
         // fields.Functional_Competencies_to_Improve__c == "" ? true : false;
        this.showHowCanYouSupportOthersError =
          fields.Experiences__c == "" ? true : false;
        this.showWhatGreatCompetenciesAreYouAbleToShareError =
          fields.Great_Competencies__c == "" ? true : false;
        //this.showWhatFunctionalCompetenciesAreYouAbleToShareError =
         // fields.Functional_Competencies__c == "" ? true : false;
        this.showWhatTypeOfMentoringDoYouPreferError =
          fields.Mentor_Type_Preference__c == "" ? true : false;
        this.showWhatLanguagesDoYouPreferError =
          fields.Mentoring_Language__c == "" ? true : false;
        this.showBestDescribedError = fields.Interests__c == "" ? true : false;

        if (
          this.showExperiencesToImproveError ||
          this.showGreatCompetenciesToImproveError ||
         // this.showFunctionalCompetenciesToImproveError ||
          this.showHowCanYouSupportOthersError ||
          this.showWhatGreatCompetenciesAreYouAbleToShareError ||
          //this.showWhatFunctionalCompetenciesAreYouAbleToShareError ||
          this.showWhatTypeOfMentoringDoYouPreferError ||
          this.showWhatLanguagesDoYouPreferError ||
          this.showBestDescribedError
        ) {
          this.loading = false;
        } else {
          this.recordUpdate({ fields }, action);
        }
      }
    }
  }

/*  renderedCallback() {
    this.activateTabTrap();
  }*/

  async recordUpdate(fields, action) {
    // console.log("fields: ", fields);
    await updateRecord(fields)
      .then(() => {
        if (action === "next") {
          this.loading = false;
          this.setStep(action);
        } else if (action === "save") {
          this.loading = false;
          this.skipFlow();
        } else {
          // this[NavigationMixin.Navigate]({
          //   // type: "standard__recordPage",
          //   // attributes: {
          //   //   recordId: this.userId,
          //   //   actionName: "view",
          //   // },
          //   type: "standard__namedPage",
          //   attributes: {
          //     pageName: "home",
          //   },
          this.loading = false;
          window.location.href = "../";
        }
      })
      .catch((error) => {
        this.loading = false;
        console.error(error);
      });
  }

  getFormValues() {
    const fields = {};
    const comboboxes = this.template.querySelectorAll(
      "c-m-fmulti-select-combobox "
    );
    const bioInput = this.template.querySelector("lightning-textarea");
    const linkedInUsername = this.template.querySelector("lightning-input");
    comboboxes.forEach((element) => {
      fields[element.dataset.field] = element.multiSelect
        ? element.values.join(";")
        : element.value;
    });
    if (bioInput) fields[bioInput.dataset.field] = bioInput.value;
    if (linkedInUsername)
      fields[linkedInUsername.dataset.field] = linkedInUsername.value;
    return fields;
  }

  setStep(action) {
    const nextStep =
      action === "next"
        ? this.flowSteps[this.stepIndex + 1]
        : this.flowSteps[this.stepIndex - 1];
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {
        ...this.pageRef.state,
        step: nextStep.step,
        progress: this.progress
      }
    });
  }

  // Getters
  @api get stepIndex() {
    return this.flowSteps.findIndex(
      (element) => element.step == this.pageRef.state.step
    );
  }

  get progressIsSet() {
    return this.pageRef.state.progress;
  }

 get showNextButton() {
    return this.stepIndex < this.flowSteps.length - 1;
  }

  get showFinishButton() {
    return !this.showNextButton;
  }

  get step() {
    return this.pageRef.state.step;
  }

  get progress() {
    return Math.round((100 / this.flowSteps.length) * (this.stepIndex + 1));
  }

  get showLocation() {
    return this.step === "location";
  }

  get showMenteeSkills() {
    return this.step === "mentee-skills";
  }

  get showMentorSkills() {
    return this.step === "mentor-skills";
  }

  get showInterests() {
    return this.step === "interests";
  }

  handleSelected() {
    let fields = { Id: this.userId };
    fields = { ...fields, ...this.getFormValues() };
    console.log(JSON.stringify(fields));
    this.showExperiencesToImproveError =
          fields.Experiences_to_Improve__c == "" ? true : false;
        this.showGreatCompetenciesToImproveError =
          fields.Great_Competencies_to_Improve__c == "" ? true : false;
        //this.showFunctionalCompetenciesToImproveError =
         // fields.Functional_Competencies_to_Improve__c == "" ? true : false;
        this.showHowCanYouSupportOthersError =
          fields.Experiences__c == "" ? true : false;
        this.showWhatGreatCompetenciesAreYouAbleToShareError =
          fields.Great_Competencies__c == "" ? true : false;
        //this.showWhatFunctionalCompetenciesAreYouAbleToShareError =
         // fields.Functional_Competencies__c == "" ? true : false;
        this.showWhatTypeOfMentoringDoYouPreferError =
          fields.Mentor_Type_Preference__c == "" ? true : false;
        this.showWhatLanguagesDoYouPreferError =
          fields.Mentoring_Language__c == "" ? true : false;
        this.showBestDescribedError = fields.Interests__c == "" ? true : false;
  }
  
  handleKeyDown(event) {
    console.log('event.code 2 '+event.code);
    if(event.code == 'Escape') {
      this.showDropdown = false;
      console.log('this.showDropdown 1 '+this.showDropdown);
      this.template.querySelectorAll('c-m-fmulti-select-combobox').forEach(element => {
        console.log('element.isDDopen() '+element.showDropdown);
        if(!this.showDropdown){
          this.showDropdown = element.showDropdown;
        }
      });
      console.log('this.showDropdown 2 '+this.showDropdown);
      if(!this.showDropdown){
        /*this.dispatchEvent(new CustomEvent('escape', {
          detail: this.showDropdown
        }));*/
        console.log('In IF');
        MyModal.closeModal();
        this.openModal = false;
      }      
      //MyModal.closeModal();
      event.preventDefault();
      event.stopImmediatePropagation();
    }
   }
}