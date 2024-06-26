import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getUser from "@salesforce/apex/PB_CommSignInController.signInUser";
import verifyUser from "@salesforce/apex/PB_CommSignInController.verifyUser";

export default class NhwCommunityLoginForm extends LightningElement {

    @track candidateEmail;
    @track isLoaded = false;
    @track isLoadedEmail = false;
    isInternalButtonClick = false;
    registrationId;
    errorMessage;
    notifyClassName = "slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_error";
    @track verificationCode;
    @track isVerifyForm = false;
    @track isInternal = false;
    @track hasRegisterError = false;
    @track hasValidationError = false;
    @track signInErrorMessage;
    @track verificationErrorMessage;
    @track signInUserResponseObject;
  
    // email input
    handleEmailChange(event) {
      this.candidateEmail = event.target.value;
      this.hasRegisterError = false;
    }
  
    // handle login to Insiders button click
    handleloginToInsiders() {
      this.isLoadedEmail = !this.isLoadedEmail;
      this.hasRegisterError = false; // to trigger content changes and trigger accessibility once more
      const userEmail = this.candidateEmail;
      getUser({ userEmail })
        .then((result) => {
          this.signInUserResponseObject = result;
          this.errorMessage = result.errorMessage;
          if (this.errorMessage) {
            this.isLoadedEmail = !this.isLoadedEmail;
            this.hasRegisterError = true;
            this.signInErrorMessage = this.errorMessage;
          } else {
            this.isLoadedEmail = !this.isLoadedEmail;
            this.isVerifyForm = true;
          }
        })
        .catch((error) => {
          this.isLoadedEmail = !this.isLoadedEmail;
          this.hasRegisterError = true;
          console.error("error " + error.body.message);
          this.signInErrorMessage = "Please contact support at insiders@salesforce.com";
        });
    }
  
    // handle verification code change from user
    handleCodeChange(event) {
      this.verificationCode = event.target.value;
      this.hasValidationError = false;
    }
  
    // handle submit after verification code input
    handleSubmit() {
      this.isLoaded = !this.isLoaded;
      const responseObject = this.signInUserResponseObject;
      const userInput = this.verificationCode;
      const userEmail = this.candidateEmail;
      this.hasValidationError = false; // trigger content changes and trigger accessibility once more
      verifyUser({ responseObject, userInput, userEmail })
        .then((res) => {
          if (res.success) {
            // TODO: we have to avoid usage of location so we have to use "NavigationMixin" features instead
            location.href = res.redirectURL;
          } else if (!res.success) {
            this.hasValidationError = true;
            this.verificationErrorMessage = res.message;
            this.isLoaded = !this.isLoaded;
          }
        })
        .catch((error) => {
          this.isLoaded = !this.isLoaded;
          this.hasValidationError = true;
          console.error("error " + error.body.message);
          this.verificationErrorMessage = "Please Contact your Administrator";
        });
    }

}