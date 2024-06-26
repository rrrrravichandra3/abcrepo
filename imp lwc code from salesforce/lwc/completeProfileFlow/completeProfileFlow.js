import { LightningElement, api, wire } from "lwc";
import { getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import CITY_FIELD from "@salesforce/schema/User.City";
import COUNTRY_FIELD from "@salesforce/schema/User.Country";

export default class CompleteProfileFlow extends NavigationMixin(LightningElement) {
  @api user;
  @api mode;

  @wire(CurrentPageReference)
  pageRef;

  displayCreateForm() {
    this.step = "createForm";
    this[NavigationMixin.Navigate]({
      ...this.pageRef,
      state: {
        ...this.pageRef.state,
        showCreateForm: true,
        step: this.mode === "Mentor" ? "mentor-skills" : "mentee-skills",
        progress: 1,
      },
    });
  }

  dismissClickedHandler() {
    // Navigate to a URL
    this.dispatchEvent(new CustomEvent("close"));
  }

  // Getters
  get showWhatWeKnow() {
    return !this.pageRef.state.showCreateForm;
  }

  get userCity() {
    return getFieldValue(this.user, CITY_FIELD);
  }

  get userCountry() {
    return getFieldValue(this.user, COUNTRY_FIELD);
  }

  get showCreateForm() {
    return this.pageRef.state.showCreateForm;
  }

  @api callcreateprofile(event){
    console.log('fireeeeee111 ')
    console.log(this.template.querySelector("c-create-profile-form"));
    this.template.querySelector("c-create-profile-form").onNext(event);
    
   }
}