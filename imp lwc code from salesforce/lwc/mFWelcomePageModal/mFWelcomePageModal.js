import { api, wire, track } from 'lwc';

import welcome_First_tell_us_what_you_would_like_to_do from "@salesforce/label/c.welcome_First_tell_us_what_you_would_like_to_do";
import welcome_Find_a_Mentor from "@salesforce/label/c.welcome_Find_a_Mentor";
import welcome_I_am_looking_for_a_mentor_to_help_build_my_career from "@salesforce/label/c.welcome_I_am_looking_for_a_mentor_to_help_build_my_career";
import welcome_I_d_like_to_volunteer_my_time_to_help_a_Mentee_succeed from "@salesforce/label/c.welcome_I_d_like_to_volunteer_my_time_to_help_a_Mentee_succeed";
import welcome_I_d_like_to_become_both_a_Mentor_and_a_Mentee from "@salesforce/label/c.welcome_I_d_like_to_become_both_a_Mentor_and_a_Mentee";
import welcome_Learn_More from "@salesforce/label/c.welcome_Learn_More";
import welcome_Be_Both from "@salesforce/label/c.welcome_Be_Both";
import welcome_Be_a_Mentor from "@salesforce/label/c.welcome_Be_a_Mentor";

import { CurrentPageReference } from "lightning/navigation";

import MENTOR_CHARACTER from "@salesforce/resourceUrl/mentorCharacter";
import BOTH_MENTEE_AND_MENTOR from "@salesforce/resourceUrl/bothMenteeAndMentor";
import MENTEE_CHARACTER from "@salesforce/resourceUrl/menteeCharacter";
import backLabel from "@salesforce/label/c.Back";
import nextLabel from "@salesforce/label/c.Next";
import finishLabel from "@salesforce/label/c.Finish";
import LightningModal from 'lightning/modal';

export default class MFWelcomePageModal extends LightningModal {
    mentorCharacterUrl = MENTOR_CHARACTER;
    menteeCharacterUrl = MENTEE_CHARACTER;
    bothMenteeAndMentorUrl = BOTH_MENTEE_AND_MENTOR;
    mentorLearnMoreUrl =
    "https://org62.my.trailhead.com/content/employee/modules/mentorship-at-salesforce";
  menteeLearnMoreUrl =
    "https://org62.my.trailhead.com/content/employee/modules/mentorship-at-salesforce";
    labels = {
       
        welcome_First_tell_us_what_you_would_like_to_do,
        welcome_Find_a_Mentor,
        welcome_I_am_looking_for_a_mentor_to_help_build_my_career,
        welcome_Learn_More,
        welcome_Be_a_Mentor,
        welcome_Be_Both,
        welcome_I_d_like_to_volunteer_my_time_to_help_a_Mentee_succeed,
        welcome_I_d_like_to_become_both_a_Mentor_and_a_Mentee,
        backLabel,
        nextLabel,
        finishLabel,
      };

      @api pageRef = '';
      @api userName = '';
      @api cancelLabel = '';
      @api saveLabel = '';
      @api hideFooter = false;
      @api completeProfileFlow = false;
      @api showCreateForm = false;
      @api user = '';
      @api mode = '';
      @api welcomeModal=false;
     @track headerNotRequired = true;
     @api label;
     
    

      @wire(CurrentPageReference)
      pageRef;

      get mode(){
        
        return this. pageRef.state.mode;
      }

      goToSearchMentors(event) {
        console.log('search mentors');
     this.close('gotosearchmentors');
        console.log('Aare u firing?')
      }
      
  goToMyMentees() {
    // Set mode to "Mentor"
    ///this.checking();
    console.log('my mentees');
    //this.setMode("Mentor");
    this.close('gotomymentees');
  }

  goToBoth() {
    // Set mode to "Mentor"
    console.log('both');
    this.close('gotoboth');
    
  }
  get showAllButtons(){
    return this.stepIndex>=0;
  }

  cancelClickedHandler(){
    this.close('cancel');
    this.dispatchEvent(
      new CustomEvent("closemodal", {
          bubbles: true, 
          composed: true,
          detail: {
              message: 'close modal'
          }
      })
  );
  
  }

  submitClickedHandler(event){
    console.log('fireeeeee ')
    console.log(this.template.querySelector("c-complete-profile-flow"));
    this.template.querySelector("c-complete-profile-flow").callcreateprofile(event);
  }
  saveClickedHandler(event){
    
    this.template.querySelector("c-create-profile-form").onNext(event);
    
   }
   handleescape(event){
    console.log('in Handle Escape'+event.detail);
    event.preventDefault();
      event.stopImmediatePropagation();
      //MyModal.closeModal();
   }
   handleKeyDown(event) {
    console.log('event.code 1 '+event.code);
    if(event.code == 'Escape') {
      console.log('in Escape ');
      this.template.querySelectorAll('c-create-profile-form').forEach(element => {
        console.log('element.showDropdown() '+element.showDropdown);
        if(!element.showDropdown){
          MyModal.closeModal();
          //this.openModal = false;
        }
      });
      

      this.showDropdown = false;
      console.log('this.showDropdown 3 '+this.showDropdown);
      this.template.querySelectorAll('c-m-fmulti-select-combobox').forEach(element => {
        console.log('element.isopen() '+element.showDropdown);
        if(!this.showDropdown){
          this.showDropdown = element.showDropdown;
        }
      });
      console.log('this.showDropdown 4 '+this.showDropdown);
      if(!this.showDropdown){
        MyModal.closeModal();
      }

      //this.openModal = false;
      //MyModal.closeModal();
      event.preventDefault();
      event.stopImmediatePropagation();
    }
   }
   
  

  //new
    // Getters
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

    get stepIndex() {
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
  
    get isMobile() {
      return screen.width <= 768;
    }
}