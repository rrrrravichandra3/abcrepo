import { LightningElement,api,track } from 'lwc';
import preboardingResources from '@salesforce/resourceUrl/preboardingResources';
import getProvisionings from "@salesforce/apex/PrehireCommunityController.getSoftwareProvisionings";
import updateSoftwareSelections from "@salesforce/apex/PrehireCommunityEquipmentService.updateSoftwareSelections";

export default class PbAccessibilityNeeds extends LightningElement {
    _heading;
    _subHeading;
    _note;
    @track isLoading = false;
    @api provCase;
    @track _nextBtnLabel = 'Confirm Selection';
    @track _isSubPage2 = false;
    @track _isSubPage1 = true;
    @track needsAccessiblity = false;
    @track _selectedSoftwareRequests = [];
    @track _selectedHardwareReq;
    @track _selectedServiceReq;
    @track _swlist;
    _isNextEnabled = false;
    _amazonLogo = preboardingResources + '/preboardingResources/amazonLogo.png';
    _astroImgSrc = preboardingResources + '/preboardingResources/astro2.png';
    _accessiSoftwareData;

    get disableButton(){
        return !this._isNextEnabled;
    }

    _accessiYesorNo=[
        {
            Id:"yes",
            Name:"I confirm I have accessibility/medical need",
            Static_Resource_image_URL__c: "accessiYes.png"
        },
        {
            Id:"no",
            Name:"I do not have accessibility/medical need",
            Static_Resource_image_URL__c: "accessiNO.png"
        }];

    handleAccessiSelection(event) {
        console.log(event.detail);
        if(event.detail == 'yes') {
            this.needsAccessiblity = true;
        }
        this._isNextEnabled = true;
    }    

    handleRequestSelection(event) {

        if(event.target.className == "softwareReq") {
            this._accessiSoftwareData.forEach(ele => {
                if(ele.Id==event.detail.id) {
                    if(event.detail.select) {
                        //console.log(ele.Name + 'selected');
                        let choice = ele;
                        choice.Static_Resource_image_URL__c = preboardingResources + '/preboardingResources/' + ele.Static_Resource_image_URL__c;
                        if(!this._selectedSoftwareRequests.find(o => o.Id === ele.Id)) {
                            this._selectedSoftwareRequests.push(choice);
                        }
                    } else {
                        //console.log(ele.Name + 'deselected');
                        this._selectedSoftwareRequests = this._selectedSoftwareRequests.filter(function( obj ) {
                            return obj.Id !== event.detail.id;
                        });
                    }

                }
            });
        }
        let sss='';
        this._selectedSoftwareRequests.forEach(ele => sss+=ele.Name);
        //console.log(sss); 
        if(this._selectedSoftwareRequests.length>0) {
            this._nextBtnLabel = 'Confirm Selection';
        } else {
            this._nextBtnLabel = 'I have no Accessibility Needs';
        }
    }

    handleNext(event) {
        console.log(this._isSubPage1);
        console.log(this.needsAccessiblity);
        if(this._isSubPage1) {
            if(this.needsAccessiblity) { //page 1 needs accesi selections
                this._isSubPage2 = true;
                this._isSubPage1 = false;
                this.updateLabels();
            } else { //page 1 doesnt need accessi selections
                this.dispatchEvent(new CustomEvent('accessiblityneeds', {
                    detail: {
                        finish:true,
                        next:false,
                        main:true
                       }
                }));
            }
        }
        else if(this._isSubPage2) {
            if(this._selectedSoftwareRequests.length > 0) { //page 2 with selections
                this._selectedSoftwareRequests.forEach(ele =>{
                    if(ele.Name!==null){
                        if(this._swlist== undefined){
                            this._swlist = ele.Name;
                        }
                        else{
                            this._swlist = [this._swlist,ele.Name].join(';');
                        }
                    }
                });
                console.log(this._swlist);
                this.isLoading = true
                updateSoftwareSelections({ accessibilityReq: 'Yes', swSelection: this._swlist, caseId: this.provCase.fields.Id.value})
                .then((result) => {
                    this.dispatchEvent(new CustomEvent('accessiblityneeds', {
                        detail: {
                            finish:false,
                            next:true,
                            main:false
                           }
                    }));
                    this.isLoading = false;
                    this._isSubPage2 = false;
                    this.updateLabels();
                })
                .catch((error) => {
                    console.log(error);
            });
               
            } else { //page 2 but no selections
                this.dispatchEvent(new CustomEvent('accessiblityneeds', {
                    detail: {
                        finish:true,
                        next:false,
                        main:true
                       }
                }));
            }
           
        } else { //page 3
            this.dispatchEvent(new CustomEvent('accessiblityneeds', {
                detail: {
                    finish:false,
                    next:true,
                    main:false
                   }
            }));
        }
    }

    handleBack(event) {
        if(this._isSubPage2||this._isSubPage1) {
            this.dispatchEvent(new CustomEvent('backtohome'));    
        } else {
            this.dispatchEvent(new CustomEvent('accessiblityneeds', {
                detail: {
                    finish:false,
                    next:false,
                    main:true
                   }
            }));
        } 
    }

    updateLabels() {
        if(this._isSubPage1) {
            this._heading = 'Confirm Your Selection';
            this._subHeading = 'Do you have an accessibility or medical need?';
            this._note = 'Salesforce provides accommodations to employees with medical/accessibility needs such as software, hardware and other services. Please select below if you require any work accommodations:'
            this._isNextEnabled = false;
        }
        else if(this._isSubPage2) {
            this._heading = 'Select Your Preferences';
            this._subHeading = 'Disability/Medical Condition Accessibility Needs';
            this._note = 'If you have a disability- or health-related condition and wish to request access to one or more of the following tools, please select the required tools below. To remove potential barriers, you do not need to supply documentation, the tool is funded centrally and your manager will not be notified.'
            this._isNextEnabled = true;
            this._nextBtnLabel = 'I have no Accessibility Needs'
        } else {
            this._heading = 'Accessibility Needs';
            this._subHeading = 'Accessibility/medical needs selected with success';
            this._note = 'Your needs were successfully communicated to the Office of Accessibility, and your accommodations will be ready as soon as possible.';
            this._isNextEnabled = true;
            this._nextBtnLabel = 'Next Step: Request a Badge'
        }
    }

    connectedCallback() {
        this.updateLabels();
        this.isLoading = true;
        getProvisionings({ caseId: this.provCase.fields.Id.value,provisioningType: "Accessibility Software" })
         .then((result) => {
             this._accessiSoftwareData = result;
             this.isLoading = false;
             console.log('data-->',this._accessiSoftwareData);
         })
         .catch((error) => {
             console.log(error);
         });
    }

}