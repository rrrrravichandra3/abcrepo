import { LightningElement, api } from 'lwc';
import patchObjectives from "@salesforce/apex/IDP_WSController.patchObjectives"
import updateText from "@salesforce/apex/IDP_WSController.updateText";
import { fireCustomEvent, setToast } from "c/iDP_Utils";
import LightningConfirm from 'lightning/confirm';

// Import message service features required for publishing and the message channel
import UtilBaseComponent from 'c/utilBaseComponent';

export default class IDP_ObjectivesAccordion extends UtilBaseComponent {
    @api ismanager;
    @api objectiveName = "Objective";
    @api isCompleted = false;
    @api _objective;
    @api 
    get objective() {
        return this._objective;
    }
    set objective(value) {
        this._objective = value;
        this.actions = this._objective.actions;
        this.sortActions();
    }
    @api isEditable = false;
    @api isReadOnly;
    keyIndex = 0;
    actions = [];
    newActions = [];
    @api idpId;
    recordToDelete = "";
    tempObjName = "";
    isLoading = false;
    actionsAvailable = false;
    record;
    tempRecordId='';
    errorMessage='';
    isNewActionInserted=false;
    actionSortOrder = new Array('Not Started','In Progress','Complete,Archived - FY24');
    dueDateSortingStatusNo=2;
    
//================================================== PAYLOAD GETTERS  ==================================================
    get getActionDeletePayload() {
        const fieldName = 'IsDeleted__c';
        const fieldValue = 'True';
        const recordId = this.recordToDelete;
        const objectName= 'IDP_Action__c';
        return { fieldName, fieldValue, recordId, objectName};
    }

    get getPatchObjectivePayload() {
        const idpId = this.idpId;
        const objectiveId = this._objective.recordId;
        const objectiveName = this.tempObjName;
        const actions = this.actions;
        const newActions = this.newActions;
        return { idpId, objectiveId, objectiveName, actions, newActions };
    }

    get getScrollOptions() {
        return {
            behavior: 'smooth',
            block: 'center',
            inline: 'nearest'
        };
    }

//================================================== LIFE CYCLE HOOKS ==================================================
    connectedCallback() {
        if(this._objective.actions){//this._objective.actions
            this.actionsAvailable = true;
        }
        this.objectiveName = (this._objective?.objectiveName ? this._objective.objectiveName: "Objective")
        this.tempObjName = this._objective.objectiveName;        
    }    

    renderedCallback(){
        if(this.isNewActionInserted){
            const element = this.template.querySelector('div[data-id="act' + this.keyIndex + '"]');
            element?.scrollIntoView(this.getScrollOptions); 
            this.isNewActionInserted = false;
        }
    }
//================================================== LOGIC METHODS ==================================================
//Sort Actions
    sortActions(){
        this.actions = [];
        let numberedActions = [];
        this._objective?.actions?.forEach(key => {
            const recordIndex = this.actionSortOrder.findIndex((record) => record.includes(key.Status));
            if (recordIndex>-1) {
                if(numberedActions[recordIndex]){
                    numberedActions[recordIndex] = [...numberedActions[recordIndex], key];
                }
                else{
                    numberedActions[recordIndex] = [];
                    numberedActions[recordIndex] = [...numberedActions[recordIndex], key];
                }
            }
        });
        numberedActions[this.dueDateSortingStatusNo]?.sort((a,b) => (new Date(a.completionDate) > new Date(b.completionDate)) ? 1 : ((new Date(b.completionDate) > new Date(a.completionDate)) ? -1 : 0))
        numberedActions = numberedActions.filter((ele) => {
            return (ele);
        });
        this.actions = [].concat(...numberedActions);
    }
//Make the objective accordion editable
    makeObjEditable(event) {
        this.isEditable = true;
        this.isReadOnly = !this.isEditable;
        let paramData = { recordId: this._objective.recordId };
        fireCustomEvent(this,'editobjective',paramData);
        this.publishUserEventToGoogleAnalytics('short-term_objectives_edit_icon', 'idp');
    }
// Method to Add new Action
    addAccordion() {
        let objRow = {
            Status: 'Not Started',
            completionDate: '',
            Action: '',
            recordId: 'act'+ ++this.keyIndex
        }
        this.newActions = [...this.newActions, Object.create(objRow)];
        this.actionsAvailable = true;
        this.isEditable = true;
        this.isReadOnly = !this.isEditable;
        this.isNewActionInserted = true;
        fireCustomEvent(this,'editobjective',objRow.recordId);
        this.publishUserEventToGoogleAnalytics('new_short_term_objectives_button', 'idp');
    }
// Method to Remove an Objective
    async handleRemoveRow(event) {
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to delete this Objective?',
            variant: 'header',
            theme: 'offline',
            label: 'Delete Objective',
        });
        if(result === true){
            let paramData = { objective: this._objective };
        fireCustomEvent(this,'deleteobjective',paramData);
        }
    this.publishUserEventToGoogleAnalytics('delete_' + (this.isCompleted ? 'completed_archived_objectives' : 'short_term_objectives') +'_icon', 'idp');
    }

// Method to Remove an Action
     async deleteAction(event) {
        this.actions = this._objective.actions;
        this.isLoading = true;
        this.newActions = this.newActions.filter((ele) => {
            return (ele.recordId) !== (event.detail.action.recordId);
        });
        if(this.actions){
            this.actions = this.actions.filter((ele) => {
                if ((ele.recordId) === (event.detail.action.recordId)) {
                    this.recordToDelete = ele.recordId;
                }
                return (ele.recordId) !== (event.detail.action.recordId);
            });
        }
        
        if (this.recordToDelete) {
            try {
                const payload = this.getActionDeletePayload;
                let result = await updateText(payload);
                this.errorMessage = result.errorMessage;
                if(this.errorMessage!==undefined && this.errorMessage!==null){
                    setToast(this,'Error', this.errorMessage,'Error','sticky');
                    return;
                }
                this._objective = {...this._objective, 'actions': this.actions};
                this.tempRecordId = this._objective.recordId;
                this.reorganizeObjective();
                setToast(this,"Successfully Deleted","",'success');
            } catch (error) {
                setToast(this,"Failed to Save",error,"error");
            }
        }

        if (!this.newActions?.length && !this.actions?.length) {
            this.actionsAvailable = true;
        }
        
        this.publishUserEventToGoogleAnalytics((this.isCompleted ? 'completed_archived_objectives' : 'short_term_objectives') + 'delete_action_icon', 'idp');
        this.isLoading = false;
    }
// Method to handle changes to an Action
    changeAction(event) {
        //this.actions = this._objective.actions;
        this.newActions.forEach(key => {
            if (key.recordId == event.detail.action.recordId) {
                let obj = new Object();
                obj.Action = event.detail.action.Action;
                obj.Status = event.detail.action.Status;
                obj.completionDate = event.detail.action.completionDate;
                obj.Comments = event.detail.action.Comments;
                obj.recordId = event.detail.action.recordId;
                key = Object.assign(key, event.detail.action);
            }
        });

        let actArr = [];
        if(this.actions?.length){
            for (let i = 0; i < this.actions.length; i++) {
                if (this.actions[i].recordId == event.detail.action.recordId) {
                    let obj = new Object();
                    obj.Action = event.detail.action.Action;
                    obj.Status = event.detail.action.Status;
                    obj.completionDate = event.detail.action.completionDate;
                    obj.Comments = event.detail.action.Comments;
                    obj.recordId = event.detail.action.recordId;
                    actArr[i] = obj;
                }
                else {
                    actArr[i] = this.actions[i];
                }
            }
            this.actions = actArr;
            //this._objective = {...this._objective, 'actions': this.actions};
        }
        
    }

// Method to handle change to an Objective Name
    handleObjectiveNameChange(event) {
        this.tempObjName = event.target.value;
    }

// Method to save entire Objective
    async saveObjective() {
        this.isLoading = true;
        let isError = false;
        //this.actions = this._objective.actions;
        if(this.tempObjName !== ""){
            this.newActions.filter((ele) => {
                if(!ele.Action){
                    isError = true; 
                }
                return ele.Action !== "";
            });
            this.actions?.forEach(ele => {
                if(!ele.Action){
                    isError = true; 
                }
            });

            if(!isError){

                const payload = this.getPatchObjectivePayload;
                try {
                    let result = await patchObjectives({ "payload": JSON.stringify(payload) });
                    this.errorMessage = result.errorMessage;
                    if(this.errorMessage!==undefined && this.errorMessage!==null){
                      setToast(this,'Error', this.errorMessage,'Error','sticky');
                      return;
                    }
                    this.tempRecordId = this._objective.recordId;
                    this._objective = result;
                    this.sortActions();
                    this.reorganizeObjective();
                    this.isLoading = false;
                    setToast(this,"Successfully Saved","Successfully Saved","success");
                    this.newActions =[];
                }
                catch (e) {
                    setToast(this,"Failed to Save",e,"error");
                }
                this.isLoading = false;
                this.objectiveName = this.tempObjName;
                this.isEditable = false;
                this.isReadOnly = !this.isEditable;
                
            }
        }
        else{
            isError = true;
        }
        if(isError){
            this.isLoading = false;
            
        }
    }

// Method to fire event in parent component to reorganize Objective
    reorganizeObjective(){
        let paramData = { objectiveId: this.tempRecordId, updateObj: this._objective };
        fireCustomEvent(this,'reorganizeobjectives',paramData);
    }

// Cancel changes and return back to read-only mode
    cancelObjective() {
        this.sortActions();
        this.isEditable = false;
        let paramData = { objectiveId: this._objective.recordId, isCancelEvent: true };
        fireCustomEvent(this,'reorganizeobjectives',paramData);
        this.isReadOnly = !this.isEditable;
        this.newActions = [];
    }
}