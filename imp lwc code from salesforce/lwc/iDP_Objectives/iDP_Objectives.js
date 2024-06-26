import { LightningElement, api } from 'lwc';
import updateText from "@salesforce/apex/IDP_WSController.updateText";
import { fireCustomEvent, setToast } from "c/iDP_Utils";

// Import message service features required for publishing and the message channel
import UtilBaseComponent from 'c/utilBaseComponent';
export default class IDP_Objectives extends UtilBaseComponent {
    @api objectiveId;
    @api objectiveType = "Text";
    @api helptext="";
    @api title = "Short-Term Development Goals";
    @api textValue = "Test";
    @api 
    get objectives() {
        return this._objectives;
    }
    set objectives(value) {
        this.setAttribute('objectives', value);
        this._objectives = value;
        this.setPlaceHolder();
    } 
    
    _objectives = [];
    newObjectives = [];
    @api isEditable = false;
    @api ismanager; 
    @api fieldName = "";
    @api idpId = "";
    @api placeholder="";
    isEditVisible = false;
    keyIndex = 0;
    isAddObjectiveVisible = false;
    isAddActionVisible = false;
    isCompleted = false;
    isTextArea = false;
    isActions = false;
    activeSectionsMessage = 'Short-Term Development Goals';
    recordToDelete="";
    tempText ="";
    isLoading = true;
    showNewObjectives = false;
    isNewObjInserted = false;
    noObjective = false;
    _activeSections=[];
    @api 
    get activeSections() {
        return this._activeSections;
    }
    set activeSections(value) {
        this.setAttribute('activeSections', value);
        this._activeSections = value.filter((ele) => {
            return (!ele?.includes('obj'));
        });
    } 
    errorMessage='';

//================================================== PAYLOAD GETTERS ==================================================
    get getScrollOptions() {
        return {
            behavior: 'smooth',
            block: 'center',
            inline: 'nearest'
        };
    }

    get getObjectiveUpdatePayload() {
        const fieldName = 'IsDeleted__c';
        const fieldValue = 'True';
        const recordId = this.recordToDelete;
        const objectName= 'IDP_Objective__c';
        return { fieldName, fieldValue, recordId, objectName };
    }

    get getIdpTextUpdatePayload() {
        const fieldName = this.fieldName;
        const fieldValue = this.textValue;
        const recordId = this.idpId;
        const objectName= 'IDP__c';
        return { fieldName, fieldValue, recordId, objectName };
    }

    get eventTitle(){
        return this.title.replaceAll(" ", "_").toLowerCase();
    }
//================================================== LIFE CYCLE HOOKS ==================================================
    async connectedCallback() {
        this.initialisation();
        this.isLoading = false;
    }

    renderedCallback(){
        if(this.isNewObjInserted){
            const element = this.template.querySelector('div[data-id="obj' + this.keyIndex + '"]');
            element?.scrollIntoView(this.getScrollOptions); 
            this.isNewObjInserted = false;
            this.openAccordion("obj"+this.keyIndex);
        }
    }

//================================================== LOGIC METHODS ==================================================
// Method to initialize component on load
    initialisation() {
        
        this._objectives = this.objectives;
        this.setType();
    }

// Method to set type/behavior of an Objective on UI
    setType() {
        if (this.objectiveType == "In_Progress") {
            if(!this.ismanager){
                this.isAddObjectiveVisible = true;
                this.isAddActionVisible = true;
                this.isActions = true;
            }
            if(!this._objectives?.length){
                this.noObjective = true;
            }
        }
        else if (this.objectiveType == "Text") {
            if(!this.ismanager){
                this.isEditVisible = true;
            }
            this.isTextArea = true;
            if(!this.textValue){
                this.noObjective = true;
            }
        }
        else if (this.objectiveType == "Completed") {
            this.isCompleted = true;

            if(!this._objectives?.length){
                this.noObjective = true;
            }
        }
    }

    // Store active sections on section toggle
    handleSectionToggle(event){
        this._activeSections= event.detail.openSections;
    }

    // Make an Objective Editable
    makeEditable(){
        this.isEditable = true;

        // Focus on textarea when the element is rendered
        setTimeout(() => {
            this.template.querySelector('.textarea_idp').focus();
        }, 5);
        this.publishUserEventToGoogleAnalytics(this.eventTitle + '_edit_icon', 'idp');
    }

    // Open Actions Accordion 
    openAccordion(recordId){
        if(this._activeSections?.length){
            if(!this._activeSections.includes(recordId)){
                this._activeSections = [...this._activeSections, recordId];
            }
        }
        else{
            this._activeSections = [recordId];
        }
    }

    // Open an Accordion on click of edit button
    editObj(event){
        this.openAccordion(event.detail.recordId);
    }

    // Handle Text Objectives changes
    handleTextChange(event){
        this.tempText = event.target.value;
    }

    // Discard changes made to an text objective
    cancelText(event){
        this.isEditable = false;
    }

    // Handle create a new oBjective
    addObjectives(event){
        try{
            let objRow = {"objectiveName":"",recordId: 'obj'+ ++this.keyIndex,"actions":[]};
            this.newObjectives = [...this.newObjectives, Object.create(objRow)];
            this.showNewObjectives = true;
            this.isEditable = true;
            this.isNewObjInserted = true;
            this.noObjective = false;
        }
        catch(e){
            console.log(e);
        }
        this.publishUserEventToGoogleAnalytics('add_new_objective_button', 'idp');
        
    }

    // Method to delete an Objective
    async deleteObjs(event){
        this.isLoading = true;
        let objectiveToDelete;
        this.newObjectives = this.newObjectives.filter((ele) => {
            return (ele.recordId) !== (event.detail.objective.recordId);
        });
        
        this._objectives = this._objectives.filter((ele) => {
            if((ele.recordId) === (event.detail.objective.recordId)){
                objectiveToDelete = ele;
                this.recordToDelete = ele.recordId;
            }
            return (ele.recordId) !== (event.detail.objective.recordId);
        });

        let isObjPresent = true;
        if(!this.newObjectives.length){
            this.showNewObjectives = false;   
            isObjPresent = false;
        }
        if(!this._objectives.length){
            isObjPresent = false;
        }

        if(!isObjPresent){
            this.noObjective = true;
        }

        if(!this.newObjectives.length){
            this.showNewObjectives = false;
        }

        if(this.recordToDelete){
            const payload= this.getObjectiveUpdatePayload;
            try{
                let result = await updateText(payload);
                this.errorMessage = result.errorMessage;
                if(this.errorMessage!==undefined && this.errorMessage!==null){
                    setToast(this,'Error', this.errorMessage,'Error','sticky');
                    return;
                }
                let paramData = { updateObj: objectiveToDelete, isDelete: true };
                fireCustomEvent(this,'moveobjtocompleted',paramData);
                setToast(this,"Successfully Deleted","","success");
            }
            catch(e){
                setToast(this,"Failed to Save",e,"error");
            }
        }
        this.publishUserEventToGoogleAnalytics('delete_' + this.eventTitle + '_button', 'idp');
        this.isLoading = false;
    }

    // Method to use salesforce standard api and save data in field 
    async saveText(){
        this.isLoading = true;
        this.textValue = this.tempText;
        const payload= this.getIdpTextUpdatePayload;
        try{
            let result = await updateText(payload);
            if(this.textValue === ""){
                this.noObjective = true;
            }
            else{
                this.noObjective = false;
            }
            if(result){
                this.cancelText(null);
                setToast(this,"Successfully Saved","","success");
            }
            else{
                setToast(this,"Failed to Save",e,"error");
            }
            
        }
        catch(e){
            setToast(this,"Failed to Save",e,"error");
        }
        this.isLoading = false;
    }

    // Method to handle save event and reorganize objectives
    reorganizeObjectives(event){
        event.stopPropagation();
        this.newObjectives = this.newObjectives.filter((ele) => {
            return (ele.recordId) !== (event.detail.objectiveId );
        });
        if(!event.detail.isCancelEvent){
            this._objectives = this._objectives.filter((ele) => {
                return ele.recordId !== event.detail.objectiveId;
            });
            //this.objectives = [...this.objectives, Object.create(event.detail.updateObj)];
            
            let paramData = { updateObj: event.detail.updateObj, activeSections: this._activeSections };
            fireCustomEvent(this,'moveobjtocompleted',paramData);
        }
        else{
            this.isEditable = false;
            this.noObjective = (this._objectives?.length || this.newObjectives?.length ? false : true);
        }
    }

    // Handle deletion of objective
    handleRemoveRow(event) {
        deleteObjs(event.target.dataset.id);
    }

    // Method to default place holder when objectives are not present
    setPlaceHolder(){
        if(!this.isTextArea){ 
            this.noObjective = (this._objectives?.length || this.newObjectives.length ? false : true);
            if(this.noObjective){
                this.isEditable = false;
            }
        }
    }

    handleHelptextFocus(){
        this.publishUserEventToGoogleAnalytics('idp_' + this.eventTitle + '_tooltip_icon', 'idp');
    }
}