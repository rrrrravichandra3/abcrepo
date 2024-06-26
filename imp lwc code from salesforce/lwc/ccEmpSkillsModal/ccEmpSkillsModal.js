import LightningModal from 'lightning/modal';
import {api, track} from 'lwc'
import getSkillsSearchResult from '@salesforce/apex/CcEmp_SkillsService.getSkillsSearchResult';
import addSkillAssignments from '@salesforce/apex/CcEmp_SkillsService.addSkillAssignments';
export default class CcEmpSkillsModal extends LightningModal {

    labels = {
        close: 'Close', 
        add: 'Add'
    }

    @api skillsLimit;
    @api existingSkillIds;

    @track selectedSkills = [];
    @track searchSkillResults;

    get addSkillLimit() {
        return this.skillsLimit - this.selectedSkills.length;
    }

    handleCancel() {
        this.close();
    }

    async handleKeyUp(event) {
        let searchString = event.target.value;
        if(searchString.trim().length >= 3){
            getSkillsSearchResult({skillName: searchString, existingSkillIds: this.existingSkillIds})
                .then(result => {
                    this.searchComboStyleClass = result.length > 0 ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open" : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
                    this.searchSkillResults = result;
                }).catch(error => {
                    console.log(error);
                });
        }
        else{
            this.searchSkillResults = [];
            this.searchComboStyleClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
        }
    }

    addSkillToList(event) {
        let selectedSkill = {
            Name: event.currentTarget.getAttribute("data-name"),
            Id: event.currentTarget.getAttribute("data-id")
        };
        if(this.selectedSkills.length < this.skillsLimit) {
            this.selectedSkills.push(selectedSkill);
        }
        console.log(JSON.stringify(this.selectedSkills));
        this.searchSkillResults = [];
    }

    handleAddSkillsClick() {
        let skillsIdsToAdd = this.selectedSkills.map(skill => skill.Id);
        if(skillsIdsToAdd.length > 0) {
            addSkillAssignments({skillIds: skillsIdsToAdd})
            .then(result => {
                this.close('skillsAdded');
            }).catch(error => {
            console.log(error);
            this.close();
            });
        }
    }

    handleSkillRemove(event) {
        let index = event.target.dataset.index;
        this.selectedSkills.splice(index, 1);
    }
}