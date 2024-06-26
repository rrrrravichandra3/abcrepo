import { LightningElement,track,api } from 'lwc';
import preboardingResources from '@salesforce/resourceUrl/preboardingResources';
import getProvisionings from "@salesforce/apex/PrehireCommunityController.getProvisionings";
import getShippingBUAddress from "@salesforce/apex/PrehireCommunityEquipmentService.getShippingBUAddress";
import updateEquipmentSelections from "@salesforce/apex/PrehireCommunityEquipmentService.updateEquipmentSelections";

export default class EquipmentSelect extends LightningElement {

    _heading;
    _subHeading;
    _backBtnLabel;
    @track _isNextEnabled = false;
    _isLastSubPage = false;
    @track _currentSubPage = 0;
    @track error;
    @api provCase;
    _shippingCity;
    _shippingStreet;
    _shippingState;
    _shippingCountry;
    _shippingZipCode;
    _shippingName;
    _shippingEmail;
    _shippingPhone;
    _shippingAddress;
        
    @track _selectedMobile;
    @track _selectedLaptop;

    @track _laptopdata;
    _astroImgSrc =  preboardingResources + '/preboardingResources/astro.png';

    _subtasks = {
        mobile : {
            active:false,
            complete:false
        },
        laptop : {
            active:false,
            complete:false
        },
        review: {
            active:false,
            complete:false
        },
        address : {
            active:false,
            complete:false
        },
        confirm : {
            active:false,
            complete:false
        }
    };

    _mobiledata=[
    {
        Id:"iphone14",
        Name:"Iphone 14",
        Static_Resource_image_URL__c: "iphone.png"
    },
    {
        Id:"pixel7",
        Name:"Pixel 7",
        Static_Resource_image_URL__c: "pixel7.png"
    }];



    get disableButton(){
        return !this._isNextEnabled;
    }

    handleMobileSelect(event) {
        console.log(event.detail);
        this._mobiledata.forEach(ele => {
            if(ele.Id==event.detail) {
                this._selectedMobile = ele;
                this._selectedMobile.Static_Resource_image_URL__c =  preboardingResources + '/preboardingResources/' + ele.Static_Resource_image_URL__c;
            }
        });
        this._isNextEnabled = true;
    }

    handleLaptopSelect(event) {
        this._laptopdata.forEach(ele => {
            if(ele.Id==event.detail) {
                this._selectedLaptop = ele;
                this._selectedLaptop.Static_Resource_image_URL__c =  preboardingResources + '/preboardingResources/' + ele.Static_Resource_image_URL__c;
            }
        });
        this._isNextEnabled = true;
    }

    validateAddress() {

        const isInputsCorrect = [...this.template.querySelectorAll('wes-text-input')]
        .reduce((validSoFar, inputField) => {
            if(!inputField.value) {
                inputField.invalidated=true;
            }
            return validSoFar && inputField.value;
        }, true);

        const isInputsCorrect2 = [...this.template.querySelectorAll('wes-select')]
        .reduce((validSoFar, inputField) => {
            if(!inputField.value) {
                inputField.setAttribute('invalidated',true);
            }
            return validSoFar && inputField.value;
        }, true);


        // if(isInputsCorrect && isInputsCorrect2){ //to-do add address validation uncomment

            this._currentSubPage+=1;
            this.updateLabels();
            this.updateActiveSubTask(); 
        //}
        

       
    }

    handleNext(event) {
        if(this._currentSubPage==4) { //on confirm page

            let equipmentData = {
                shippingCity: this._shippingCity,
                shippingStreet: this._shippingStreet,
                shippingState: this._shippingState,
                shippingCountry: this._shippingCountry,
                shippingZipCode: this._shippingZipCode,
                shippingName: this._shippingName,
                shippingEmail: this._shippingEmail,
                shippingPhone: this._shippingPhone,
                selectedLaptop: this._selectedLaptop.Name,
                selectedMobile: this._selectedMobile.Name
            };
            console.log(equipmentData);
            updateEquipmentSelections({ wrapper: equipmentData, caseId: this.provCase.fields.Id.value})
                .then((result) => {
                    console.log(result);
                    this.dispatchEvent(new CustomEvent('selectedequipment'));
                })
                .catch((error) => {
                    console.log(error);
                });
           
        } else if(this._currentSubPage==3) {
            this.validateAddress();
        } else if(this._currentSubPage<3){
            this._currentSubPage+=1;
            this.updateLabels();
            this.updateNavBar();
            this.updateActiveSubTask();  
        }
    }

    handleBack(event) {
       if(this._currentSubPage==0) { //on 1st page
        this.dispatchEvent(new CustomEvent('backtohome'));
       } else if(this._currentSubPage==4) {
        this.dispatchEvent(new CustomEvent('selectedequipment',{
            detail: true
        }));
       } 
       else {
        this._currentSubPage-=1;
        this.updateLabels();
        this.updateActiveSubTask();
        if(this._currentSubPage<=3) {
            this.updateNavBar();
        }
       }
    }




    updateNavBar() {
        let k = parseInt(this._currentSubPage);
        let keys = Object.keys(this._subtasks);
        console.log(k);
        console.log(this.template.querySelectorAll('.checkicon'));
        for(let i = 0 ; i < k ; i ++) {
            this.template.querySelectorAll('.slds-progress__item')[i].className = 'slds-progress__item slds-is-completed';
           // this.template.querySelectorAll('.checkicon')[i].className = 'checkicon checked';
            this._subtasks[keys[i]].complete = true;
        }

        this.template.querySelectorAll('.slds-progress__item')[k].className = 'slds-progress__item slds-is-active';
       // this.template.querySelectorAll('.checkicon')[i].className = 'checkicon unchecked';
        this._subtasks[keys[k]].complete = false;

        for(let i = k+1 ; i < 4 ; i ++) {
            this.template.querySelectorAll('.slds-progress__item')[i].className = 'slds-progress__item';
            //this.template.querySelectorAll('.checkicon')[i].className = 'checkicon unchecked';
            this._subtasks[keys[i]].complete = false;
        }

    }

    updateLabels() {
        if(this._currentSubPage==0) {
            this._heading = 'Choose Equipment';
            this._subHeading = 'What Phone would you prefer?';
            this._backBtnLabel = 'Back to Home';
            this._isNextEnabled = false;
        }
        if(this._currentSubPage==1) {
            this._backBtnLabel = 'Go Back';
            this._heading = 'Choose Equipment';
            this._subHeading = 'What Laptop would you prefer?';
            this._isNextEnabled = false;
        }

        if(this._currentSubPage==2) {
            this._backBtnLabel = 'Go Back';
            this._heading = 'Review Choosen Equipment';
            this._subHeading = 'Confirm Your Choices';
            this._isNextEnabled = true;
        }

        if(this._currentSubPage==3) {
            this._backBtnLabel = 'Go Back';
            this._heading = 'Before we send your equipment';
            this._subHeading = 'Confirm Your Address';
            this._isNextEnabled = true;
        }

        if(this._currentSubPage==4) {
            this._backBtnLabel = 'Back to Home';
            this._heading = 'Congratulations';
            this._subHeading = 'Your Equipment was selected with success';
            this._isNextEnabled = true;
        }
    }

    updateActiveSubTask() { 
        let keys = Object.keys(this._subtasks);
        keys.forEach(key => {
            this._subtasks[key].active = false;
        });
        this._subtasks[keys[parseInt(this._currentSubPage)]].active = true;
        if(this._currentSubPage==4) {
            this._isLastSubPage=true;
        }
    }

    connectedCallback() {
        this.updateLabels();
        this.updateActiveSubTask();
        getProvisionings({ caseId: this.provCase.fields.Id.value,provisioningType: "Laptop" })
         .then((result) => {
             this._laptopdata = result;
             console.log(result);
             console.log(this._laptopdata);
         })
         .catch((error) => {
             console.log(error);
         });
        getShippingBUAddress({ caseId: this.provCase.fields.Id.value})
         .then((result) => {
            this._shippingCity = result.City;
            this._shippingCountry = result.Country;
            this._shippingName = result.ContactName;
            this._shippingEmail = result.Email;
            this._shippingPhone = result.Phone;
            this._shippingState = result.State;
            this._shippingStreet = result.Street;
            this._shippingZipCode = result.Zipcode;
            this._shippingAddress = result.Name;
         })
         .catch((error) => {
             console.log(error);
         });
     }
 
}