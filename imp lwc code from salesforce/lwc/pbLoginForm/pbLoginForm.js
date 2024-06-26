/* @Author Ronak Bandwal 
 * @Description Login Component for Preboarding Component
*/
import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getUser from "@salesforce/apex/R2H_CommOTPSignInController.signInUser";
import verifyUser from "@salesforce/apex/R2H_CommOTPSignInController.verifyUser";

export default class PbLoginForm  extends NavigationMixin(LightningElement) {

    
    _candidateEmail;
    _errorMessage;
    _verificationCode;
    _signInUserResponseObject;

    @api isVerifyForm = false;
    @track isLoading = false;
  
    handleKeyPressLogin(event) {
        if(event.keyCode === 13) {
          this.handlelogin();
        }
    }

    handleKeyPressCode(event) {
      if(event.keyCode === 13) {
        this.handleSubmit();
      }    
    }

    handleBack(event) {
        this.isVerifyForm = false; //go back to login view
    }

    // email input
    handleEmailChange(event) {
      this._candidateEmail = event.target.value;
    }

  
    // handle verification code change from user
    handleCodeChange(event) {
      this._verificationCode = event.target.value;
    }

    showToast(msg,iserror) {
        this.template.querySelector('c-pb-toast-message').showToast(msg,iserror); //show toast
    }
  
    // handle login  button click
    handlelogin() {
      this.isLoading = true;
      const userEmail = this._candidateEmail;
      getUser({ userEmail:userEmail , communityName: 'Preboarding_Community' })
        .then((result) => {
          this._signInUserResponseObject = result;
          this._errorMessage = result.errorMessage;
          this.isLoading = false;
          if(this._errorMessage) {
            this.showToast(this._errorMessage,false);
          } else {
             this.isVerifyForm = true;
          }
        })
        .catch((error) => {
          this.isLoading = false;
          this.showToast("Please Contact Support",false);
        });
    }


    navigateToHomePage(res) { //navigate to Home page
        //  this[NavigationMixin.Navigate]({
        //      type: 'comm__namedPage',
        //      attributes: { name: 'Home' }
        //  });
      location.href = res.redirectURL;        
    }
  
    // handle submit after verification code input
    handleSubmit() {
      this.isLoading = true;
      const responseObject = this._signInUserResponseObject;
      const userInput = this._verificationCode;
      const userEmail = this._candidateEmail;
      verifyUser({ responseObject, userInput, userEmail })
        .then((res) => {
            this.isLoading = false;
            res.success ? this.navigateToHomePage(res) : this.showToast(res.message,false); 
        })
        .catch((error) => {
          this.isLoading = false;
          this.showToast("Please Contact Support",false); 
        });
    }
}