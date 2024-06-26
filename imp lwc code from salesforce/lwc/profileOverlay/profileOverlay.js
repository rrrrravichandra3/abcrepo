import { LightningElement, api, track, wire } from "lwc";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MODE_FIELD from "@salesforce/schema/User.Mentoring_Mode__c";
import AVAILABLE_FIELD from "@salesforce/schema/User.Available__c";
import CAPACITY_FIELD from "@salesforce/schema/User.Capacity__c";
import LINKEDIN_FIELD from "@salesforce/schema/User.LinkedIn_Profile__c";
import PHOTO_FIELD from "@salesforce/schema/User.MediumPhotoUrl";
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import TITLE_FIELD from "@salesforce/schema/User.Title";
import USER_BIO_FIELD from "@salesforce/schema/User.User_Bio__c";
import CITY_FIELD from "@salesforce/schema/User.City";
import COUNTRY_FIELD from "@salesforce/schema/User.Country";
import CERTIFICATIONS_FIELD from "@salesforce/schema/User.Certifications__c";
import Id from "@salesforce/user/Id";
import BANNER_BACKGROUND from "@salesforce/resourceUrl/bannerBackground";
import profileOptionsLabel from "@salesforce/label/c.profile_options";
import profileUpdateBioLabel from "@salesforce/label/c.profile_update_bio";
import profileMaxNumberOfMenteesLabel from "@salesforce/label/c.profile_Max_number_of_mentees";
import profileHowManyMenteesCanYouPotentiallySupportLabel from "@salesforce/label/c.profile_How_many_mentees_can_you_potentially_support";
import availableAsMentorLabel from "@salesforce/label/c.profile_Available_as_mentor";
import yourBioWasUpdatedSuccessfullyLabel from "@salesforce/label/c.profile_Your_bio_was_updated_successfully";
import profileAvailabilityUpdatedLavel from "@salesforce/label/c.profile_availability_updated_successfully";
import profileCapacityUpdatedLabel from "@salesforce/label/c.profile_capacity_updated_successfully";
import createMentoringMatch from "@salesforce/apex/MainMentoringController.createMentoringMatch";
import getMentoringMatch from "@salesforce/apex/MainMentoringController.getMentoringMatch";
import yourRequestWasSentLabel from '@salesforce/label/c.mentor_your_request_was_sent';
import writeSomethingAboutYourselfLabel from '@salesforce/label/c.mentor_Write_something_about_yourself';
import mentorRequestLabel from '@salesforce/label/c.mentor_request';
import MyModal from 'c/mFcustomLightningModal';
import MyModal1 from 'c/mFWelcomePageModal';

export default class ProfileOverlay extends NavigationMixin(LightningElement) {
  userId = Id;

  bannerBackgroundUrl = BANNER_BACKGROUND;
  available = false;
  capacity = 3;

  @track user;

  @api recordId;

  @track numberOfMentors = 0;
  @track numberOfMentees = 0;
  
  @track showMessageComposer = false;  
  @track loading = false;
  @track score;
  @track hasamatch = false;

  // @track toggles = [];

  labels = {
    profileOptionsLabel,
    profileUpdateBioLabel,
    profileMaxNumberOfMenteesLabel,
    profileHowManyMenteesCanYouPotentiallySupportLabel,
    writeSomethingAboutYourselfLabel,
    mentorRequestLabel
  };

  @wire(CurrentPageReference)
  pageRef;

  // Load User Record
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      MODE_FIELD,
      AVAILABLE_FIELD,
      CAPACITY_FIELD,
      LINKEDIN_FIELD,
      PHOTO_FIELD,
      NAME_FIELD,
      EMAIL_FIELD,
      TITLE_FIELD,
      USER_BIO_FIELD,
      CITY_FIELD,
      COUNTRY_FIELD,
      CERTIFICATIONS_FIELD,
    ],
  })
  wiredRecord({ error, data }) {
    if (error) {
      this.showNotification("Oops", `Error loading User Details ${error.body.message}`, "error");
      //eslint-disable-next-line
      console.error(error);
    } else if (data) {
      this.user = data;
      this.available = getFieldValue(this.user, AVAILABLE_FIELD);
      this.capacity = getFieldValue(this.user, CAPACITY_FIELD);
      this.checkingformentoringmatch();
    }
  }


  checkingformentoringmatch() {
    console.log('here '+ this.recordId)
    console.log('here1 '+ this.userId)
    getMentoringMatch({mentorId: this.recordId, menteeId: this.userId})
        .then(result => {
            this.hasamatch = result;
        })
        .catch(error => {
            //this.error = error;
            console.log('Any error?'+error)
        });
}

  incrementCounter = () => {
    //console.log("incrementCounter");
    if (this.capacity < 10) {
      this.capacity = this.capacity + 1;
      this.updateCapacity();
    }
  };

  decrementCounter = () => {
    //console.log("decrementCounter");
    if (this.capacity > 0) {
      this.capacity = this.capacity - 1;
      this.updateCapacity();
    }
  };

  updateCapacity = () => {
    const fields = {};
    fields.Id = this.userId;
    fields[CAPACITY_FIELD.fieldApiName] = this.capacity;
    const recordInput = {
      fields,
    };
    updateRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: profileCapacityUpdatedLabel,
            variant: "success",
          })
        );
      })
      .catch((error) => {
        console.log("error: ", error);
      });
  };

  handleToggleChange = (event) => {
    //console.log("handleToggleChange");
    this.available = event.target.checked;

    const fields = {};
    fields.Id = this.userId;
    fields[AVAILABLE_FIELD.fieldApiName] = this.available;
    const recordInput = {
      fields,
    };
    updateRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: profileAvailabilityUpdatedLavel,
            variant: "success",
          })
        );
      })
      .catch((error) => {
        console.log("error: ", error);
      });
  };

  switchMode = () => {
    console.log("switchMode");
    this.openModal();
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {
        //showModePicker: true,
      },
    });
  };
  // GETTERS

  get showSalesLeaderBadge() {
    const certifications = getFieldValue(this.user, CERTIFICATIONS_FIELD);
    if (certifications?.split(";")?.includes("Sales Leader Excellence Coach")) {
      return true;
    }
    return false;
  }

  get bannerBackground() {
    return `background-image: url(${this.bannerBackgroundUrl})`;
  }

  get bannerClasses() {
    return "banner-container";
  }

  get linkedinProfile() {
    return getFieldValue(this.user, LINKEDIN_FIELD);
  }

  get mode() {
    return getFieldValue(this.user, MODE_FIELD);
  }

  get name() {
    return getFieldValue(this.user, NAME_FIELD);
  }

  get email() {
    return getFieldValue(this.user, EMAIL_FIELD);
  }

  get title() {
    return getFieldValue(this.user, TITLE_FIELD);
  }

  get bio() {
    return getFieldValue(this.user, USER_BIO_FIELD);
  }

  get location() {
    const city = getFieldValue(this.user, CITY_FIELD) ? getFieldValue(this.user, CITY_FIELD) : "";
    const country = getFieldValue(this.user, COUNTRY_FIELD) ? getFieldValue(this.user, COUNTRY_FIELD) : "";
    return `${city}${city && country ? "," : ""} ${country}`;
  }

  get showOptions() {
    return this.userId === this.recordId || this.userId.slice(0, -3) === this.recordId;
  }

  get loggedInUser() {
    console.log("this.recordId: ", this.recordId);
    console.log("this.userId: ", this.userId);
    console.log('hasamatch '+this.hasamatch)
    if (this.userId.startsWith(this.recordId) || this.hasamatch == true) {
      return true;
    }
    return false;
  }

  get getAriaText(){
    return 'Your current role is '+getFieldValue(this.user, MODE_FIELD) +'.Click if you\'d like to switch';
  }

  async openModal(){
    MyModal1.open({
      size: 'small',
      description: 'Accessible description of modal\'s purpose',
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

  goToSearchMentors() {
    // Set mode to "Mentee"
    console.log('Should be here')
    this.setMode("Mentee");
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success!",
        message: "Changed Role to Mentee",
        variant: "success",
      })
    );
    //this.closeModal();
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
    //this.closeModal();
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
    //this.closeModal();
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


  

  async toggleComposer() {
    //this.showMessageComposer = !this.showMessageComposer;
    MyModal.open({
      size: 'small',
      description: 'Accessible description of modal\'s purpose',
      content: 'Passed into content api',
      hideFooter: false,
      inputLabel : this.labels.writeSomethingAboutYourselfLabel,
      heading : this.labels.mentorRequestLabel,
      buttonLabel: 'Send Request',
      showMessageComposer:true,
      saveLabel:'Send Request',
    onprimaryevent: (e) => {
        // stop further propagation of the event
        e.stopPropagation();   
        console.log(e.detail)     
        this.sendRequest(e.detail);
      }
  }).then((result) => {
    console.log(result);
  });
  }

  async sendRequest(event) {
    //this.toggleComposer();
    console.log(event)
    console.log('Check1111 '+event.message)
    this.loading = true;
    try {
      await createMentoringMatch({
        mentorId: this.recordId, //assuming this is same
        status: "Requested",
        requestMessage: event.message,
        score: this.score,
      });
      // Show success notification
      this.showNotification(null, yourRequestWasSentLabel, "success");
      // Stop spinner
      this.loading = false;

      // Send updated Event to parent
     // this.dispatchEvent(new CustomEvent("updated")); - Assuming not required
      //this.loggedInUser();
    } catch (error) {
      this.showNotification("Oops", error.body.message, "error");
      this.loading = false;
    }
  }

  showNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant,
    });
    this.dispatchEvent(evt);
  }

}