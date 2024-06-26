import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSkillAssignments from '@salesforce/apex/talentMP_SkillsService.getSkillAssignments'
import returnGPTResponse from '@salesforce/apex/einstein_GPT_Service.returnGPTResponse'
import removeSkillAssignments from '@salesforce/apex/talentMP_SkillsService.removeSkillAssignments'
import processNewSkillAssignments from '@salesforce/apex/talentMP_SkillsService.processNewSkillAssignments'
import getSkillsSearchResult from '@salesforce/apex/talentMP_SkillsService.getSkillsSearchResult'

export default class TalentMP_skills extends LightningElement {
    
    @api title;
    @api contact;
    @api skillslist;
    @track skills = []; 
    @api editAbility = false;
    @track showSpinner = false;
    @track searchComboStyleClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
    editMode = false;
    skillsMasterData = []; 
    suggestedSkills = [];
    removedSkills = [];
    addedSkills = [];
    contactIds = [];
    existingSkillIds = [];
    searchSkillResults = [];
    skillsExist;
    skillSearchResultHasData;
    

      connectedCallback(){
        this.skills = [...this.skillslist];
        this.setSearchRelatedData();
       }

      setSearchRelatedData(){
          if(this.skills.length > 0){
            this.existingSkillIds = this.skills.map (skill => skill.Skill__c);
            this.skillsExist = true;
            this.skillsMasterData = [...this.skills];
          }
          else{
            this.skills = [];
          }
      }

       getSkillAssignments(){
        getSkillAssignments({contactId: this.contact.Id})
          .then((result) => {
            this.skills = result;
            this.setSearchRelatedData();
          })
          .catch((error) => {
            console.log(error);
          });
       }

       async resumeskillshandler(event){
        this.addedSkills = event.detail;
        console.log('resume pdf skills from skills::: '+this.skills);
        if(this.addedSkills.length !== 0){
          for(let skill of this.addedSkills){
            this.skills.push({
              Id: skill,
              Skill__r: {
                  Name: skill
              },
              skillSource: "Resume"
          });
          }
          
        }
       }

      handleSearchSkill(event){
        let searchString = event.target.value;
        if(searchString.length > 0){
          getSkillsSearchResult({skillName: searchString, existingSkillIds: this.existingSkillIds})
             .then(result => {
              console.log(JSON.stringify(result));
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

      handleRemoveSkill(event){
        /*
        Need to consider only existing skills for deletion if removed by the user. If suggested skill is added and removed there's no need to perform deletion on that as it does not exist in the DB, yet.
        Checking if the id of the skill being removed is Salesforce ID or not. If yes, consider that for deletion and filter out from skills view, if not then normalize it and consider only to filter out from the skills view
        */
        let skillId = event.target.dataset.id;
        const isSkillIdSalesforceId = this.isSalesforceId(skillId);
        const skillSource = event.target.dataset.skillsource;

        this.skills = this.skills.filter(skill => {
          return skill.Id !== skillId;
        });

        if(isSkillIdSalesforceId){
            if(skillSource != "SkillDB"){
              this.removedSkills.push(skillId);
            }
            else{
              this.existingSkillIds = this.existingSkillIds.filter(skill => {
                return skill !== skillId;
             });
            }
        }
        else{
            this.addedSkills = this.addedSkills.filter(skill => {
                return skill !== skillId;
            });
        }
      }

      handleAddSkill(event){
        console.log('Added-->>');
        const skillId = event.currentTarget.dataset.id;
        const skillName = event.currentTarget.dataset.value;
        this.addedSkills.push(skillName);
        const skillSource = this.isSalesforceId(skillId) ? "SkillDB" : "Suggested";
        console.log('skillId-->>'+skillId);
        console.log('skillName-->>'+skillName);
        console.log('skillSource-->>'+skillSource);

        this.skills.push({
            Id: skillId,
            Skill__r: {
                Name: skillName
            },
            skillSource: skillSource
        });

        console.log('skills-->>'+this.skills);

        if(skillSource == "SkillDB"){
          this.searchSkillResults = this.searchSkillResults.filter(skill => {
              return skill.Id !== skillId;
          });
          if(this.searchSkillResults.length === 0){
            this.searchComboStyleClass = "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click";
          }
          this.existingSkillIds.push(skillId);
        }

        if(skillSource == "Suggested"){
          this.suggestedSkills = this.suggestedSkills.filter(skill => {
              return skill !== skillName;
          });
        }
      }

      handleEditSkills(){
        this.suggestedSkills = [];
        this.editMode = true;
        this.callEinsteinGPTToGetSkillSuggestions();
      }

      handleCancelEditSkills(){
        this.removedSkills = [];
        this.addedSkills = [];
        this.skills = [...this.skillsMasterData];
        this.editMode = false;
      }

      async saveUpdatedSkills(){
        this.showSpinner = true;
        if(this.removedSkills.length !== 0){
          await removeSkillAssignments({skillAssignmentIds : this.removedSkills});
        }
        if(this.addedSkills.length !== 0){
          await processNewSkillAssignments({skillNames : this.addedSkills, contactIds : new Array(this.contact.Id)}); 
        }
        if(this.addedSkills.length !==0 || this.removedSkills.length !== 0){
          this.getSkillAssignments();
        }

        this.editMode = false;
        this.removedSkills = [];
        this.addedSkills = [];
        this.searchSkillResults = [];
        this.showSpinner = false;
        const customEvent = new CustomEvent('updateskills', {
              detail: { skillsListUpdated: this.skills }
        });
        this.dispatchEvent(customEvent);

    }

      callEinsteinGPTToGetSkillSuggestions(){
        let existingSkillsList = this.skillsMasterData.map(skill => {
            return skill.Skill__r.Name;
        });

        let skillsSuggestionContext;
        if(existingSkillsList.length !== 0){
            skillsSuggestionContext = existingSkillsList.join(',');
        }
        else{
            skillsSuggestionContext = this.contact.Title;
        }

        let skillsSuggestionPrompt = "Provide a response with only comma separated values of skills a professional would or can have closely related the following existing skills: " + skillsSuggestionContext + ". Only comma separated values of suggested skills so we can process suggestions without scanning any unwanted response. Do not provide any skills back that are provided in the existing skills list.";
        console.log(skillsSuggestionPrompt);
        returnGPTResponse({textPrompt : skillsSuggestionPrompt})
        .then(result => {
          this.suggestedSkills = result.split(",").slice(0,10);
          this.suggestedSkills = this.capitalizeSkills(this.suggestedSkills);
        })
        .catch(error => {
            console.log(error);
        });
      }

      isSalesforceId(value){
         return /^[a-zA-Z0-9]{15}(?:[a-zA-Z0-9]{3})?$/.test(value);
      }

      capitalizeSkills(skills){
      let capitalizedSkills = [];
      for(let i = 0;i < skills.length;i++){
         capitalizedSkills.push(skills[i]
                              .split(" ")
                              .map((word) => {
                                return word
                                  .charAt(0)
                                  .toUpperCase() + word.slice(1);
                              })
                              .join(" "))
      }
      return capitalizedSkills;
      }

      @api
      get skillsExist(){
        if(this.skills === null || this.skills.length === 0){
            return false;
        }
        else{
            return true;
        }
      }

      @api
      get editButtonVisibility(){
        return !this.editMode && this.editAbility == "true" ? true : false;
      }

      @api
      get editView(){
        return this.editAbility && this.editMode;
      } 
}