import { LightningElement,track } from 'lwc';
import NHW_CloudCard from '@salesforce/resourceUrl/NHW_CloudCard';
import NHW_Badgeforce2 from '@salesforce/resourceUrl/NHW_Badgeforce2';

export default class nhwExperienceBadge extends LightningElement {
    _image1 = NHW_CloudCard;
    _image2 = NHW_Badgeforce2;
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
        this.dispatchEvent(new CustomEvent('badge', {
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