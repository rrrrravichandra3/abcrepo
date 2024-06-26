import { LightningElement,track,wire } from 'lwc';
import preboardingResources from '@salesforce/resourceUrl/preboardingResources';
import getProvisioningCaseId from "@salesforce/apex/PrehireCommunityController.getProvisioningCaseId";
import updateCurrentTask from "@salesforce/apex/PrehireCommunityController.updateCurrentTask";
import userid from "@salesforce/user/Id";
import { getRecord } from "lightning/uiRecordApi";

const caseFields = [
    "Case.Id",
  "Case.NHW_Start_Date__c",
  "Case.First_Name__c",
  "Case.Last_Name__c",
  "Case.NH_Community_Page_Number__c"
];


const LABELS = ['Choose Equipment','Workday Tasks','Accessibility Needs','Request a Badge','Complete Profile'];

export default class PbHome extends LightningElement {

    @track _tasks = {
        equipment : false,
        workday : false,
        accessiblity: false,
        badge : false,
        profile : false
    };

    _background = preboardingResources + '/preboardingResources/homeBG.png';
    _background2 = preboardingResources + '/preboardingResources/homeBG2.png';
    _successMsg = 'Your selections were submitted successfully';
    _errorMsg = 'There were an error while processing your request';
    _newhireName;
    _newhireStartdate;
    @track _provcaseId;
    _currentTask = 1; //get from apex
    @track error = false;
    @track data = false;
    @track isLoading = false;

    _totalTasks;

    @wire(getRecord, { recordId: "500AE000006QH1lYAG", fields: caseFields })
    _provCase({error,data}) {
        if(error) {
            this.error = error;
            console.log(error.body.message);
        } else if(data) {
            console.log(data.fields.NH_Community_Page_Number__c.value);
            let pageNo = data.fields.NH_Community_Page_Number__c.value;
            if(pageNo!=null) {
                //this._currentTask = pageNo;
            }
            this.updateActiveTask();
            this.data = data;
            this.isLoading = false;
        }
    }


    get navlabel() {
        if(this._showmain) {
            return LABELS[parseInt(this._currentTask)-1];
        } else {
            return 'Back to Home'
        }
    }

    handleTaskComplete(event) {

        if(event.detail.finish) {
            updateCurrentTask({caseId: this.data.fields.Id.value,currentTask: this._currentTask+1})
            .then((result) => {
                console.log(result);
                this._currentTask+=1;
                let ele = this.template.querySelector('c-pb-home-nav');
                ele.currentTask = this._currentTask;
                ele.buttonlabel = this.navlabel;
                this.showSuccessToast();
               
                if((event.detail.next)) {
                    this.updateActiveTask();
                } 
                if(event.detail.main) {
                    this.updateActiveTask();
                    this._showmain = true;
                }
                console.log(this._tasks.accessiblity);
                console.log(this._showmain);

            })
            .catch((error) => {
                console.log(error);
                this.error = true;
                this.showErrorToast();
            });
        } else {

            if((event.detail.next)) {
                this.updateActiveTask();
                console.log(this._tasks.accessiblity);
            } 

            if(event.detail.main) {
                this.updateActiveTask();
                this._showmain = true;
            }
        }


        
    }

    showSuccessToast() {
        this.template.querySelector('c-pb-toast-message').showToast(this._successMsg,true);
    }

    showErrorToast() {
        this.template.querySelector('c-pb-toast-message').showToast(this._errorMsg,false);
    }

    @track _showmain=true;

    updateActiveTask() { 
        let keys = Object.keys(this._tasks);
        keys.forEach(key => {
            this._tasks[key] = false;
        });
        this._tasks[keys[parseInt(this._currentTask)-1]] = true;
    }

    handleNav(event) {
        this.updateActiveTask();
        this._showmain=!this._showmain;
    }


    connectedCallback() {
        this._totalTasks = Object.keys(this._tasks).length;
        this.isLoading = true;
        getProvisioningCaseId({userId:userid})
            .then((result) => {
                this._provcaseId = result;
            })
        .catch((error) => {
            console.log(error);
            this.showErrorToast();            
        });
    }
    
}