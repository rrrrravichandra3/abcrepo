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

export default class Home extends LightningElement {

    _tasks = {
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
    @track _currentTask = 1; //get from apex
    @track error = false;
    @track data = false;
    @track isLoading = false;

    _totalTasks;

    @wire(getRecord, { recordId: "$_provcaseId", fields: caseFields })
    _provCase({error,data}) {
        if(error) {
            this.error = error;
            console.log(error.body.message);
        } else if(data) {
            console.log(data.fields.NH_Community_Page_Number__c.value);
            let pageNo = data.fields.NH_Community_Page_Number__c.value;
            if(pageNo!=null) {
                this._currentTask = pageNo;
            }
            this.updateActiveTask();
            this.data = data;
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
        //update case 
        console.log(this._currentTask+1);
        updateCurrentTask({caseId: this.data.fields.Id.value,currentTask: this._currentTask+1})
        .then((result) => {
            console.log(result);
            this._currentTask+=1;
            this.updateActiveTask();
            this.showSuccessToast();
        })
        .catch((error) => {
            console.log(error);
            this.showErrorToast();
        });
        if((event.detail)) {
            this._showmain=!this._showmain;
        } 
        
    }

    showSuccessToast() {
        this.template.querySelector('c-toast-message').showToast(this._successMsg,true);
    }

    showErrorToast() {
        this.template.querySelector('c-toast-message').showToast(this._errorMsg,false);
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
        this.isLoading = false;
    }
    
}