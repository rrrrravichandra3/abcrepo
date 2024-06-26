import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MODE_FIELD from "@salesforce/schema/User.Mentoring_Mode__c";
import AVAILABLE_FIELD from "@salesforce/schema/User.Available__c";
import LINKEDIN_FIELD from "@salesforce/schema/User.LinkedIn_Profile__c";
import PHOTO_FIELD from "@salesforce/schema/User.MediumPhotoUrl";
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import CAPACITY_FIELD from "@salesforce/schema/User.Capacity__c";
import TITLE_FIELD from "@salesforce/schema/User.Title";
import USER_BIO_FIELD from "@salesforce/schema/User.User_Bio__c";
import GREAT_COMPETENCIES_IMPROVE_FIELD from "@salesforce/schema/User.Great_Competencies_to_Improve__c";
import GREAT_COMPETENCIES_FIELD from "@salesforce/schema/User.Great_Competencies__c";
import EXPERIENCES_IMPROVE_FIELD from "@salesforce/schema/User.Experiences_to_Improve__c";
import FUNCTIONAL_COMPETENCIES_IMPROVE_FIELD from "@salesforce/schema/User.Functional_Competencies_to_Improve__c";
import FUNCTIONAL_COMPETENCIES_FIELD from "@salesforce/schema/User.Functional_Competencies__c";
//import MEMTORING_MODE from "@salesforce/schema/User.Mentoring_Mode__c";
import EXPERIENCES_FIELD from "@salesforce/schema/User.Experiences__c";
import MENTOR_TYPE_FIELD from "@salesforce/schema/User.Mentor_Type_Preference__c";
import MENTORING_LANGUAGE_FIELD from "@salesforce/schema/User.Mentoring_Language__c";
import INTERESTS_FIELD from "@salesforce/schema/User.Interests__c";
import EQUALITY_GROUP_FIELD from "@salesforce/schema/User.Equality_Group_Member__c";
import Id from "@salesforce/user/Id";

import EINSTEIN_SITTING from "@salesforce/resourceUrl/EinsteinSitting";
import EINSTEIN_STANDING from "@salesforce/resourceUrl/einsteinStanding";
import MENTEE_CHARACTER from "@salesforce/resourceUrl/menteeCharacter";
import MENTOR_CHARACTER from "@salesforce/resourceUrl/mentorCharacter";
import BOTH_MENTEE_AND_MENTOR from "@salesforce/resourceUrl/bothMenteeAndMentor";

import bioPlaceholder from "@salesforce/label/c.create_profile_This_displays_on_your_profile_and_helps_people";
import editLabel from "@salesforce/label/c.edit";
import welcome_mentor_finder from "@salesforce/label/c.welcome_mentor_finder";
import welcome_Use_this_app_to_find_mentors_or_mentees_track_your_mentoring_journey_an from "@salesforce/label/c.welcome_Use_this_app_to_find_mentors_or_mentees_track_your_mentoring_journey_an";
import welcome_Before_using_this_app_make_sure_you_have_completed_the_Mentorship_at_S from "@salesforce/label/c.welcome_Before_using_this_app_make_sure_you_have_completed_the_Mentorship_at_S";
import welcome_To_Trailhead from "@salesforce/label/c.welcome_To_Trailhead";
import welcome_I_already_have_the_badge from "@salesforce/label/c.welcome_I_already_have_the_badge";
import welcome from "@salesforce/label/c.welcome";
import welcome_First_tell_us_what_you_would_like_to_do from "@salesforce/label/c.welcome_First_tell_us_what_you_would_like_to_do";
import welcome_Find_a_Mentor from "@salesforce/label/c.welcome_Find_a_Mentor";
import welcome_I_am_looking_for_a_mentor_to_help_build_my_career from "@salesforce/label/c.welcome_I_am_looking_for_a_mentor_to_help_build_my_career";
import welcome_Learn_More from "@salesforce/label/c.welcome_Learn_More";
import welcome_Be_a_Mentor from "@salesforce/label/c.welcome_Be_a_Mentor";
import welcome_I_d_like_to_volunteer_my_time_to_help_a_Mentee_succeed from "@salesforce/label/c.welcome_I_d_like_to_volunteer_my_time_to_help_a_Mentee_succeed";
import welcome_Be_Both from "@salesforce/label/c.welcome_Be_Both";
import welcome_I_d_like_to_become_both_a_Mentor_and_a_Mentee from "@salesforce/label/c.welcome_I_d_like_to_become_both_a_Mentor_and_a_Mentee";
import welcome_to from "@salesforce/label/c.welcome_to";
import next from "@salesforce/label/c.Next";
import MyModal from 'c/mFWelcomePageModal';

export default class ProfileOnboarding extends NavigationMixin(LightningElement) {
  mentorLearnMoreUrl = "https://org62.my.trailhead.com/content/employee/modules/mentorship-at-salesforce";
  menteeLearnMoreUrl = "https://org62.my.trailhead.com/content/employee/modules/mentorship-at-salesforce";
  einsteinSittingUrl = EINSTEIN_SITTING;
  einsteinStandingUrl = EINSTEIN_STANDING;
  menteeCharacterUrl = MENTEE_CHARACTER;
  mentorCharacterUrl = MENTOR_CHARACTER;
  bothMenteeAndMentorUrl = BOTH_MENTEE_AND_MENTOR;

  @api recordId;
  userId = Id;
  @api recordData;

  @track panels;

  labels = {
    editLabel,
    bioPlaceholder,
    welcome_mentor_finder,
    welcome_Use_this_app_to_find_mentors_or_mentees_track_your_mentoring_journey_an,
    welcome_Before_using_this_app_make_sure_you_have_completed_the_Mentorship_at_S,
    welcome_To_Trailhead,
    welcome_I_already_have_the_badge,
    welcome_Find_a_Mentor,
    welcome_I_am_looking_for_a_mentor_to_help_build_my_career,
    welcome_Learn_More,
    welcome_Be_a_Mentor,
    welcome_I_d_like_to_volunteer_my_time_to_help_a_Mentee_succeed,
    welcome_Be_Both,
    welcome_I_d_like_to_become_both_a_Mentor_and_a_Mentee,
    welcome_to,
    next,
  };

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      MODE_FIELD,
      AVAILABLE_FIELD,
      LINKEDIN_FIELD,
      PHOTO_FIELD,
      NAME_FIELD,
      EMAIL_FIELD,
      CAPACITY_FIELD,
      TITLE_FIELD,
      USER_BIO_FIELD,
      GREAT_COMPETENCIES_IMPROVE_FIELD,
      GREAT_COMPETENCIES_FIELD,
      EXPERIENCES_IMPROVE_FIELD,
      FUNCTIONAL_COMPETENCIES_IMPROVE_FIELD,
      FUNCTIONAL_COMPETENCIES_FIELD,
      //MEMTORING_MODE,
      EXPERIENCES_FIELD,
      MENTOR_TYPE_FIELD,
      MENTORING_LANGUAGE_FIELD,
      INTERESTS_FIELD,
      EQUALITY_GROUP_FIELD,
    ],
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.showNotification("Oops", `Error loading User Details ${error.body.message}`, "error");
      //eslint-disable-next-line
      console.error(error);
    } else if (data) {
      this.recordData = data;
      this.panels = this.getPanels(this.recordData);
      //console.log('---->71',JSON.stringify(data));
      //this.setToggles();
    }
  }

  closeModal() {
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {},
    });
  }
  @wire(CurrentPageReference)
  pageRef;

  displayCreateForm(event) {
    let mode = event.currentTarget.dataset.id;
    console.log("mode", mode);
    this.step = "createForm";
   this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {
        ...this.pageRef.state,
        showCreateForm: false,
        step: mode,
        //progress: 0,
      },
        
    });
    this.showCreateForm1(mode);
  }

 async showCreateForm1(mode){
    MyModal.open({
      size: 'small',
      description: 'Accessible description of modal\'s purpose',
      content: 'Passed into content api',
      user:this.user,
      showCreateForm:true,
      welcomeModal:false,
      hideFooter: false,
      mode:mode,
      saveLabel:'Save',
      label: 'Edit Your Profile',
      onprimaryevent:(e)=>{
        console.log('here'+e.detail);
       
      },
      onsave:(e)=>{
        console.log('one '+e.detail)
      }  
  })/*.then((result) => {
    console.log('result?'+result);
    this.closeModal();
  });
  */
  }
  getPanels(recordData) {
    //if (!this.recordData) return [];
    const fields = recordData.fields;
    return [
      {
        Id: 4,
        Name: "About",
        step: "interests",
        showPanel: true,
        fields: this.recordData
          ? [
              {
                id: 4,
                isTextarea: true,
                isText: false,
                isPill: false,
                label: "Bio",
                values: fields.User_Bio__c.value,
              },
              {
                id: 3,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Interests",
                values: this.getFieldValues(fields.Interests__c.displayValue),
              },
              {
                id: 2,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Equality Groups",
                values: this.getFieldValues(fields.Equality_Group_Member__c.displayValue),
              },
              {
                id: 1,
                isTextarea: false,
                isText: true,
                isPill: false,
                label: "LinkedIn Profile",
                values: fields.LinkedIn_Profile__c.value,
              },
            ]
          : [],
      },
      {
        Id: 1,
        Name: "Mentee Skills",
        step: "mentee-skills",
        showPanel: fields.Mentoring_Mode__c.value !== "Mentor",
        fields: this.recordData
          ? [
              {
                id: 2,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Experiences to improve",
                values: this.getFieldValues(fields.Experiences_to_Improve__c.displayValue),
              },
              {
                id: 1,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Great Competencies to improve",
                values: this.getFieldValues(fields.Great_Competencies_to_Improve__c.displayValue),
              },
              {
                id: 3,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Functional Competencies to improve",
                values: this.getFieldValues(fields.Functional_Competencies_to_Improve__c.displayValue),
              },
            ]
          : [],
      },
      {
        Id: 2,
        Name: "Mentor Skills",
        step: "mentor-skills",
        showPanel: fields.Mentoring_Mode__c.value !== "Mentee",
        fields: this.recordData
          ? [
              {
                id: 2,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Experiences",
                values: this.getFieldValues(fields.Experiences__c.displayValue),
              },
              {
                id: 1,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Great Competencies",
                values: this.getFieldValues(fields.Great_Competencies__c.displayValue),
              },
              {
                id: 3,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Functional Competencies",
                values: this.getFieldValues(fields.Functional_Competencies__c.displayValue),
              },
            ]
          : [],
      },
      {
        Id: 3,

        Name: "Preferences",
        step: "location",
        showPanel: true,
        fields: this.recordData
          ? [
              {
                id: 2,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Mentoring Type",
                values: this.getFieldValues(fields.Mentor_Type_Preference__c.displayValue),
              },
              {
                id: 1,
                isTextarea: false,
                isText: false,
                isPill: true,
                label: "Mentoring Language",
                values: this.getFieldValues(fields.Mentoring_Language__c.displayValue),
              },
            ]
          : [],
      },
    ];
  }

  getFieldValues(field) {
    if (field) {
      return field.split(";").map((el, index) => {
        return { id: index, label: el, iconName: "standard:account" };
      });
    }
  }

  async setMode(mode) {
    console.log("mode", mode)
    try {
      const fields = {};
      fields.Id = this.userId;
      fields[MODE_FIELD.fieldApiName] = mode;
      const recordInput = {
        fields,
      };
      await updateRecord(recordInput);
     //this.showCreateForm1();
    } catch (error) {
      //eslint-disable-next-line
      console.error(error);
    }
  }

  goToSearchMentors() {
    // Set mode to "Mentee"
    this.setMode("Mentee");
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success!",
        message: "Changed Role to Mentee",
        variant: "success",
      })
    );
    this.closeModal();
  }

  goToMyMentees() {
    // Set mode to "Mentor"
    this.setMode("Mentor");
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success!",
        message: "Changed Role to Mentor",
        variant: "success",
      })
    );
    this.closeModal();
  }

  goToBoth() {
    // Set mode to "Mentor"
    this.setMode("Both");
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success!",
        message: "Changed Role to Both",
        variant: "success",
      })
    );
    this.closeModal();
  }

 

  get showCreateForm() {
    return this.pageRef.state.showCreateForm;
  }

  get showModePicker() {
    
    return this.pageRef.state.showModePicker;
  }

  get allowEdit() {
    return this.userId === this.recordId || this.userId.slice(0, -3) === this.recordId;
  }

  get isMobile() {
    return screen.width <= 768;
  }

  get ariahidden(){
   // console.log('showModePicker '+this.pageRef.state.showModePicker===true);
    return this.pageRef.state.showModePicker===true;
  } 

  handleKeyDown(event) {
    console.log('event.code 2 '+event.code);
    if(event.code == 'Escape') {
      //this.openModal = false;
      //MyModal.closeModal();
      event.preventDefault();
      event.stopImmediatePropagation();
    }
   }
}