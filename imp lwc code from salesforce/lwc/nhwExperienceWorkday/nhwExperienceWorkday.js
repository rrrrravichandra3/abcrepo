import { LightningElement,track } from 'lwc';
import NHW_workday from '@salesforce/resourceUrl/NHW_workday';
import NHW_workday2 from '@salesforce/resourceUrl/NHW_workday2';
import NHW_workday3 from '@salesforce/resourceUrl/NHW_workday3';

export default class Nhw_Experience_Workday extends LightningElement {
    _image1 = NHW_workday;
    _image2 = NHW_workday2;
    _image3 = NHW_workday3;
    disabledValue = true;
    @track isLoading = false;
    @track _backBtnLabel = 'Back to home';    
    handlecheck(event){
        if(event.target.checked === true){
            this.disabledValue = false;
        }
        else{
            this.disabledValue = true;
        }
    }
    handleNext(event){
        this.isLoading = true;
        this.dispatchEvent(new CustomEvent('workday', {
            detail: {
                finish:true,
                next:true,
                main:false
               }
        }));
    }
    handleHome(event){
        this.dispatchEvent(new CustomEvent('backtohome'));
    }
}