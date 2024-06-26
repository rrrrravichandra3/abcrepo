import { LightningElement, api, wire } from "lwc";
import getIDPList from "@salesforce/apex/IDP_WSController.getIDPList";
import IDPBANNER from "@salesforce/resourceUrl/IDP_Banner_2023";
import IDP_GuideUrl from "@salesforce/label/c.IDP_GuideUrl";
import IDP_CompletedGoals_HelpText from "@salesforce/label/c.IDP_CompletedGoals_HelpText";
import IDP_CompletedGoals_Placeholder from "@salesforce/label/c.IDP_CompletedGoals_Placeholder";
import IDP_KeyStrengths_HelpText from "@salesforce/label/c.IDP_KeyStrengths_HelpText";
import IDP_KeyStrengths_Placeholder from "@salesforce/label/c.IDP_KeyStrengths_Placeholder";
import IDP_LongTermGoals_HelpText from "@salesforce/label/c.IDP_LongTermGoals_HelpText";
import IDP_LongTermGoals_Placeholder from "@salesforce/label/c.IDP_longTermGoals_PlaceHolder";
import IDP_ShortTermGoals_HelpText from "@salesforce/label/c.IDP_ShortTermGoals_HelpText";
import IDP_Intro from "@salesforce/label/c.IDP_Intro";
import IDP_Intro2 from "@salesforce/label/c.IDP_Intro2";
import IDP_Intro_Manager_Access_Info from "@salesforce/label/c.IDP_Intro_Manager_Access_Info";
import { setToast } from "c/iDP_Utils";

// Import message service features required for publishing and the message channel
import UtilBaseComponent from 'c/utilBaseComponent';

export default class iDP_ObjectivesContainer extends UtilBaseComponent {
    idpBanner = IDPBANNER;
    @api v2MomEmployeeNumber;
    @api isManager;
    @api employeeName;
    @api managerName;
    keyStrengths = "";
    longTermGoals = "";
    records=[];
    idpId = "";
    inProgressObjs = [];
    completedObjs = [];
    isCompletedObjs;
    isInProgressObjs = false;
    lastSavedDateTime;
    errorMessage;
    isLoading = true;
    activeSections=[];
    baseURL = "";

    label = {
        IDP_GuideUrl,
        IDP_CompletedGoals_HelpText,
        IDP_CompletedGoals_Placeholder,
        IDP_KeyStrengths_HelpText,
        IDP_KeyStrengths_Placeholder,
        IDP_LongTermGoals_HelpText,
        IDP_LongTermGoals_Placeholder,
        IDP_ShortTermGoals_HelpText,
        IDP_Intro,
        IDP_Intro2,
        IDP_Intro_Manager_Access_Info
    };

//================================================== LIFECYCLE HOOKS ==================================================
    async connectedCallback() {
        await this.initialisation();
        this.isLoading = false;
    }
//=================================================== LOGIC FUNCTIONS ==================================================
// method to handle action/objective change event and reorganize objectives
    async reorganizeObjectives(event) {
        //this.isLoading = true;
        
        // Check if the objective already exists in this.records
        const eventData = event.detail;
        let recordsArray = Object.entries(this.records.objectives);
        let existingObjective;
        let eventObjective ;
        let isDelete = eventData.isDelete;
        let passedActiveSections = eventData?.activeSections;
        
        if(isDelete){
            this.records.objectives = this.records.objectives.filter((ele) => {
                return (ele.recordId) !== (eventData.updateObj.recordId);
            });
        }
        if (recordsArray && !isDelete) {
          // Check if recordId already exists in this.records
          const recordIndex = recordsArray.findIndex(record => record[1].recordId === eventData.updateObj.recordId);
          
          if (recordIndex < 0) {
            // Add new record to this.records
            existingObjective = eventData.updateObj;
            this.records.objectives.push(JSON.parse(JSON.stringify(existingObjective)));
          } else {
            // Check if objectives and actions match
            eventObjective = eventData.updateObj;
            this.records.objectives[recordIndex] = JSON.parse(JSON.stringify(eventObjective));
          }
        }
        
        this.organizeObjectives();
        if(passedActiveSections!= null && !passedActiveSections?.includes(eventData.updateObj?.recordId)){
            this.activeSections = [...passedActiveSections, eventData.updateObj?.recordId];
        }
        if(isDelete){
            this.activeSections = [this.inProgressObjs[0]?.recordId];
        }
        //this.isLoading = false;
    }      
          
// method to initialize objectives
    async initialisation() {
        console.log('Initializing...');
        this.publishUserEventToGoogleAnalytics("idp_tab_opened", "idp");
        try {
            console.log('Getting objectives...');
            this.records = await getIDPList({ v2momEmpNum: this.v2MomEmployeeNumber });
            this.idpId = this.records.recordId;
            this.keyStrengths = this.records.keyStrengths;
            this.longTermGoals = this.records.careerInterest;
            this.lastSavedDateTime = this.records.lastModifiedDate;
            this.baseURL = this.records.sfdcBaseURL;
            this.organizeObjectives(); // organize Objective into in progress and Completed ones based on Action Status
            this.activeSections = [this.inProgressObjs[0]?.recordId];
            this.errorMessage = this.records.errorMessage;
            if (this.errorMessage !== undefined && this.errorMessage !== null) {
                console.log('error getting idp');
                setToast(this,"Error", this.errorMessage, "Error", "sticky");
            }
        } catch (e) {
            console.error("in catch" + e.message);
            setToast(this,"Failed to Load", this.errorMessage, "error");
            console.error(e.message);
        }
    }
// method to organize objectives based on their action statuses
    organizeObjectives() {
        this.completedObjs = [];
        this.inProgressObjs = [];
        if (this.records.objectives !== undefined) {
            this.records.objectives.forEach((obj) => {
                let j = true;
                if (obj.actions !== undefined && obj?.actions?.length) {
                    for (let i = 0; i < obj.actions.length; i++) {
                        if (obj.actions[i].Status === null || obj.actions[i].Status === undefined) {
                            this.inProgressObjs.push(obj);
                            j = false;
                            break;
                        } else if (obj.actions[i].Status != null || obj.actions[i].Status != undefined) {
                            if (!(obj.actions[i].Status.includes("Archive") || obj.actions[i].Status.includes("Complete"))) {
                                this.inProgressObjs.push(obj);
                                j = false;
                                break;
                            }
                        } else if (obj.actions[i].Status === null || obj.actions[i].Status === undefined) {
                            this.inProgressObjs.push(obj);
                        }
                    }
                    if (j) {
                        this.completedObjs.push(obj);
                    }
                } else {
                    this.inProgressObjs.push(obj);
                }
            });
            this.isCompletedObjs = true;
            this.isInProgressObjs = true;
        }
    }
    handleSelect(event) {
        let selectedMenuItemValue = event.detail.value;
        switch (selectedMenuItemValue) {
            case "Print to PDF":
                this.navigateToPdf();
                break;
        }
    }
    navigateToPdf() {
        window.open(this.baseURL + '/apex/IDPPrint?employeeNumber='+this.v2MomEmployeeNumber);
        this.publishUserEventToGoogleAnalytics('print_to_pdf_clicked', 'idp');
    }
}