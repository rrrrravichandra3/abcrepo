import { LightningElement, track } from 'lwc';
import returnGPTResponse from '@salesforce/apex/einstein_GPT_Service.returnGPTResponse';

export default class WriteJobDescription extends LightningElement {
    @track myVal = 'Generated Response will present here.';
    @track prompText;
    spinner = false;

    handleChange(event) {
        this.myVal = event.target.value;
    }

    handleClick(event){
        console.log('click');
        console.log(this.prompText);
        this.showSpinner();
        returnGPTResponse({
            textPrompt: this.prompText
        })
          .then((result) => {
            console.log(result);
            this.myVal = result;
            this.hideSpinner();
          })
          .catch((error) => {
            console.log(error);
            //handle error
            this.hideSpinner();
            if (error && error.body) {
              this.fireToastEvent("Error!", error.body.message, "error");
            }
          });

    }

    updatePrompText(event){
        this.prompText = event.target.value;
    }

    showSpinner() {
        this.spinner = true;
    }
    
    hideSpinner() {
        this.spinner = false;
    }
}