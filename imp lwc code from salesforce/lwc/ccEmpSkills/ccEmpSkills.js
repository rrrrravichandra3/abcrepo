import {api,track, LightningElement } from 'lwc';
import ccEmpSkillsModal from 'c/ccEmpSkillsModal';
import getSkillAssignments from '@salesforce/apex/CcEmp_SkillsService.getSkillAssignments';
import removeSkillAssignments from '@salesforce/apex/CcEmp_SkillsService.removeSkillAssignments';
import markAsTopSkill from '@salesforce/apex/CcEmp_SkillsService.markAsTopSkill';
import unmarkTopSkill from '@salesforce/apex/CcEmp_SkillsService.unmarkTopSkill';

export default class CcEmpSkills extends LightningElement {

    @api editAbility = false;
    @api topSkillsLimit = 5;
    @api mySkillsLimit = 15;

    mySkills = [];
    topSkills = [];

    editMode = false;
    skillToolsOpen = false;
    isButtonType = false;
    popoverToggleCss = 'slds-text-align_right slds-dropdown-trigger slds-dropdown-trigger_click';
    activeIconCss = ' active-icon';

    connectedCallback() {
      this.loadSkillsData();
    }

    loadSkillsData() {
        getSkillAssignments()
        .then(result => {
            this.allSkills = result;
            this.mySkills = result.filter((skill) => skill.Skill_Category__c === 'MySkills');
            this.topSkills = result.filter((skill) => skill.Skill_Category__c === 'TopSkills');
        }).catch(error => {
            console.log(error);
        });
    }

    async addNewSkill() {
        console.log(this.allSkills.map(skill => skill.Skill__c));
        const result = await ccEmpSkillsModal.open({
            size: 'small',
            label: 'Add Skill Modal',
            skillsLimit: (this.mySkillsLimit - this.mySkillsCount),
            existingSkillIds: this.allSkills.map(skill => skill.Skill__c)
        });
        if(result === 'skillsAdded') {
            this.loadSkillsData();
        }
    }

    @api
    get editButtonVisibility(){
      return !this.editMode && this.editAbility == "true" ? true : false;
    }

    @api
    get isEditView(){
      return this.editAbility && this.editMode;
    } 

    get topSkillsCount() {
      return this.topSkills.length;
    }

    get mySkillsCount() {
      return this.mySkills.length;
    }

    labels = {
        editSkill : 'Edit Skill',
        delete : 'Delete',
        skill : 'skill',
        unmark : 'unmark',
        skills : 'Skills',
        skillsDescription: 'You can select up to 20 skills to add to your profile and select your top 5 for AI matching.',
        visibleTo: 'Visible To',
        topSkills: 'Top 5 Skills'
    };
  
    get bubbleButtonLabel() {return this.skillToolsOpen ? 'Close Skill Menu' : 'Open Skill Menu';}
  
    handleTopSkillToolsClick(event){
        let index = event.currentTarget.dataset.index;
        this.popoverToOpen = this.template.querySelector(`[data-top-skill-index="${index}"]`);
        this.popoverToOpen.classList.toggle('slds-is-open');
        this.skillIconName = this.skillToolsOpen ? 'utility:edit' : 'utility:close';
        this.skillToolsOpen = !this.skillToolsOpen;
    }

    handleSkillToolsClick(event) {
        console.log('handleSkillToolsClick');
        let index = event.currentTarget.dataset.index;
        console.log(index);
        this.popoverToOpen = this.template.querySelector(`[data-skill-index="${index}"]`);
        this.popoverToOpen.classList.toggle('slds-is-open');
        // this.popoverToggleCss = this.skillToolsOpen ? this.popoverToggleCss.replace(' slds-is-open', '') : this.popoverToggleCss + ' slds-is-open';
        this.skillIconName = this.skillToolsOpen ? 'utility:edit' : 'utility:close';
        this.skillToolsOpen = !this.skillToolsOpen;
    }
  
    handleSkillToolsBlur() {
        console.log('handleSkillToolsBlur');
        this.skillToolsOpen = true;
        this.popoverToggleCss.replace('slds-is-open', '');
    }

    handleMouseDown(event) {
        event.preventDefault();
    }
  
    trapFocus(event) {
        let KEYCODE_ESC = 27;
        let isKeyPressed = (event.key === 'Escape' || event.keyCode === KEYCODE_ESC); 

        if (!isKeyPressed) { 
            return;
        }

        if((event.key === 'Escape' || event.keyCode === KEYCODE_ESC) && this.skillToolsOpen) {
            this.handleSkillToolsClick();
            this.template.querySelector('.skill-button').focus();
        }
    }

    handleMarkAsTopSkill(event) {
        event.preventDefault();
        if(this.topSkillsCount < this.topSkillsLimit) { 
            let skillAssignementId = event.currentTarget.dataset.skill;
            markAsTopSkill({skillAssignementId: skillAssignementId}).then(result => {
              // SUCCESS TOAST PLACEHOLDER
              console.log('mark top 5 success toast goes here!');
            }).catch(error => {
              console.log(error);
            }).finally(() => {
              this.loadSkillsData();
            });
        } else {
            // ERROR TOAST PLACEHOLDER
            console.log('error toast goes here! topSkillsLimitReached');
            this.popoverToOpen.classList.toggle('slds-is-open');
        }
    }

    handleUnmarkTopSkill(event) {
        event.preventDefault();
        if(this.mySkillsCount < this.mySkillsLimit) { 
            let skillAssignementId = event.currentTarget.dataset.skill;
            unmarkTopSkill({skillAssignementId: skillAssignementId}).then(result => {
              // SUCCESS TOAST PLACEHOLDER
              console.log('unmark top 5 success toast goes here!');
            }).catch(error => {
              console.log(error);
            }).finally(() => {
              this.loadSkillsData();
            });
        } else {
            // ERROR TOAST PLACEHOLDER
            console.log('error toast goes here! MySkillsLimitReached');
            this.popoverToOpen.classList.toggle('slds-is-open');
        }
    }

    handleClick(event) {
        event.preventDefault();
        let skillAssignementId = event.currentTarget.dataset.skill;
        let assignmentsToRemove = [];
        assignmentsToRemove.push(skillAssignementId);
        removeSkillAssignments({ skillAssignmentIds: assignmentsToRemove}).then(result => {
            // SUCCESS TOAST PLACEHOLDER
            console.log('success toast goes here!');
        }).catch(error => {
            console.log(error);
        }).finally(() => {
            this.loadSkillsData();
        });
    }
}