import { LightningElement, wire, track, api } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import NAME_FIELD from "@salesforce/schema/User.FirstName";
import CITY_FIELD from "@salesforce/schema/User.City";
import COUNTRY_FIELD from "@salesforce/schema/User.Country";
import MODE_FIELD from "@salesforce/schema/User.Mentoring_Mode__c";
import AVAILABLE_FIELD from "@salesforce/schema/User.Available__c";
import DISMISSED_FIELD from "@salesforce/schema/User.Onboarding_Dismissed__c";
import EINSTEIN_SITTING from "@salesforce/resourceUrl/EinsteinSitting";
import WELCOME_SCREEN from "@salesforce/resourceUrl/welcomeScreen";
import EINSTEIN_STANDING from "@salesforce/resourceUrl/einsteinStanding";
import MENTEE_CHARACTER from "@salesforce/resourceUrl/menteeCharacter";
import MENTOR_CHARACTER from "@salesforce/resourceUrl/mentorCharacter";
import BOTH_MENTEE_AND_MENTOR from "@salesforce/resourceUrl/bothMenteeAndMentor";

import COMPLETED_MENTEE_FLOW_FIELD from "@salesforce/schema/User.Completed_Mentee_Onboarding_Flow__c";
import COMPLETED_MENTOR_FLOW_FIELD from "@salesforce/schema/User.Completed_Mentor_Onboarding_Flow__c";
import Id from "@salesforce/user/Id";

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
import create_profile_Which_competencies_do_you_wish_to_improve from "@salesforce/label/c.create_profile_Which_competencies_do_you_wish_to_improve";
//import { getDataConnectorSourceFields } from "lsightning/analyticsWaveApi";


import MyModal from 'c/mFWelcomePageModal';

export default class WelcomePage extends NavigationMixin(LightningElement) {
  mentorLearnMoreUrl =
    "https://org62.my.trailhead.com/content/employee/modules/mentorship-at-salesforce";
  menteeLearnMoreUrl =
    "https://org62.my.trailhead.com/content/employee/modules/mentorship-at-salesforce";
  einsteinSittingUrl = EINSTEIN_SITTING;
  einsteinStandingUrl = EINSTEIN_STANDING;
  menteeCharacterUrl = MENTEE_CHARACTER;
  mentorCharacterUrl = MENTOR_CHARACTER;
  bothMenteeAndMentorUrl = BOTH_MENTEE_AND_MENTOR;
  welcomeBackground = WELCOME_SCREEN;
  userId = Id;
  mentoringProfiles;

 // @api focusableEls;
  //@api lastFocusableEl;
 // @api firstFocusableEl;

  @track user;

  @track showOnboarding = false;
  @track openresult = '';

  labels = {
    welcome_mentor_finder,
    welcome_Use_this_app_to_find_mentors_or_mentees_track_your_mentoring_journey_an,
    welcome_Before_using_this_app_make_sure_you_have_completed_the_Mentorship_at_S,
    welcome_To_Trailhead,
    welcome_I_already_have_the_badge,
    welcome,
    welcome_First_tell_us_what_you_would_like_to_do,
    welcome_Find_a_Mentor,
    welcome_I_am_looking_for_a_mentor_to_help_build_my_career,
    welcome_Learn_More,
    welcome_Be_a_Mentor,
    welcome_I_d_like_to_volunteer_my_time_to_help_a_Mentee_succeed,
    welcome_Be_Both,
    welcome_I_d_like_to_become_both_a_Mentor_and_a_Mentee,
    welcome_to,
    next
  };

  @wire(getRecord, {
    recordId: "$userId",
    fields: [
      NAME_FIELD,
      CITY_FIELD,
      COUNTRY_FIELD,
      MODE_FIELD,
      COMPLETED_MENTEE_FLOW_FIELD,
      COMPLETED_MENTOR_FLOW_FIELD,
      DISMISSED_FIELD
    ]
  })
  wiredRecord({ data, error }) {
    if (error) {
      // eslint-disable-next-line
      console.error(error);
    } else if (data) {
      this.user = data;
      if (this.completedOnboardingFlow && this.previousMode) {
        if (this.isMobile && this.mentoringMode === "Mentor") {
          this.navigateToMyMentees();
        }
      } else {
        this.showOnboarding = true;
      }
    }
  }

  @wire(CurrentPageReference)
  pageRef;

  @track loading;

  async setMode(mode) {
    try {
      const fields = {};
      fields.Id = this.userId;
      fields[MODE_FIELD.fieldApiName] = mode;
      if (mode === "Mentor" || mode === "Both") {
        fields[AVAILABLE_FIELD.fieldApiName] = true;
      }
      const recordInput = {
        fields
      };
      await updateRecord(recordInput);  
      this.showProfileFlow1();
      this.loading = false;
    } catch (error) {
      //eslint-disable-next-line
      console.error(error);
    }
  }

  // getStartedClicked() {
  //   this[NavigationMixin.Navigate]({
  //     ...this.pageRef,
  //     state: {
  //       showModePicker: true
  //     }
  //   });

   
  // }

  

  navigateToSearchMentors() {
    // Navigate to a URL
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "search-mentors"
      }
    });
  }

  async closeModal() {
    //this.showOnboarding = false;
    if (this.mentoringMode === "Mentee" || !this.isMobile) {
      this[NavigationMixin.Navigate]({
        ...this.pageRef,
        state: {}
      });
    } else {
      this.navigateToMyMentees();
    }
    try {
      const fields = {};
      fields.Id = this.userId;
      fields[DISMISSED_FIELD.fieldApiName] = true;
      const recordInput = {
        fields
      };
      await updateRecord(recordInput);
    } catch (error) {
      //eslint-disable-next-line
      console.error(error);
    }
  }

  navigateToMyMentees() {
    // Navigate to a URL
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "my-mentees"
      }
    });
  }

  goToSearchMentors() {
    // Set mode to "Mentee"
   this.loading = true;
    this.setMode("Mentee");
    //console.log('I should be here');
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {
        showProfileFlow: true,
        mode: "Mentee"
      }
    });
  }

  goToMyMentees() {
    // Set mode to "Mentor"
    ///this.checking();
    this.loading = true;
    this.setMode("Mentor");
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {
        showProfileFlow: true,
        mode: "Mentor"
      }
    });
    
  }

  goToBoth() {
    // Set mode to "Mentor"
    this.loading = true;
    this.setMode("Both");
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {
        showProfileFlow: true,
        mode: "Both"
      }
    });
    
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
        variant: "error"
      })
    );
  }

  // Getters
  get userName() {
    return getFieldValue(this.user.data, NAME_FIELD);
  }

  get backgroundImage() {
    return `background-image: url(${this.welcomeBackground})`;
  }

  get mentoringMode() {
    return getFieldValue(this.user, MODE_FIELD);
  }

  get dismissedOnboarding() {
    return getFieldValue(this.user, DISMISSED_FIELD);
  }

  get completedOnboardingFlow() {
    return getFieldValue(this.user, COMPLETED_MENTOR_FLOW_FIELD);
  }

  get previousMode() {
    return getFieldValue(this.user, MODE_FIELD);
  }

  get showWelcomeScreen() {
    return !this.showModePicker && !this.showProfileFlow;
  }

  //get showModePicker() {
  async showModePicker1() {
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {
        showModePicker: true
      }
    }); 

    MyModal.open({
      size: 'small',
      description: 'Choose if you want to be a mentor, mentee or both',
      content: 'Passed into content api',
      pageRef:this.pageRef,
      cancelLabel:'Cancel',
      hideFooter: false,
      completeProfileFlow:false,
      welcomeModal:true,
      mode:this.pageRef.state.mode,
      label:'Welcome',
      onselect: (e) => {
        // stop further propagation of the event
        e.stopPropagation();   
        if(e.detail.id == 'mentee'){
          this.goToSearchMentors();
        }else if(e.detail.id == 'mentor'){
          this.goToMyMentees();
        } else if(e.detail.id == 'both'){
          this.goToBoth();
        }  
        
      }
  }).then((result) => {
    console.log(result);
  });
    //return this.pageRef.state.showModePicker;
  }

  async showProfileFlow1(mode){
    //console.log("welcomepage")
    MyModal.open({
      size: 'small',
      description: 'Choose if you want to complete your profile',
      content: 'Passed into content api',
      user:this.user,
      completeProfileFlow:true,
      welcomeModal:true,
      hideFooter: false,
      mode:this.pageRef.state.mode,
      backLabel: 'Back',
       nextLabel: 'Next',
      finishLabel:'Finish',
      label:'Complete Profile',
      
  }).then((result) => {
    //console.log('result?'+result);
    this.closeModal();
  });
  }

  get showProfileFlow() {
   // console.log('this.pageRef.state.showProfileFlow is what?'+this.pageRef.state.showProfileFlow);
    //if(this.pageRef.state.showProfileFlow != undefined) this.showProfileFlow1();
    //else
    return this.pageRef.state.showProfileFlow;
  }

  get mode() {
    return this.pageRef.state.mode;
  }

  get isMobile() {
    return screen.width <= 768;
  }
}