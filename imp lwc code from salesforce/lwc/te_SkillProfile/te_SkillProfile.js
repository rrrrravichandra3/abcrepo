import { LightningElement, api, track } from 'lwc';
import getSkillProfile from '@salesforce/apex/te_SkillProfileController.getSkillProfile'

export default class Te_SkillProfile extends LightningElement {

    @api skillName = "";
    @track skillDescription = "";
    @track isCritical = false;
    @track numberEmployeesWithSkill = 0;
    @track userDoesNotHaveSkill = false;
    @api showMentorships;
    @api showTraining;
    @api showGigs;

    connectedCallback(){
        this.userDoesNotHaveSkill = true;
        this.getSkillData();
    }

    getSkillData(){
        getSkillProfile()
        .then(result => {
            if (result) {
                this.skillName = result.skillName;
                this.skillDescription = result.skillDescription;
                this.numberEmployeesWithSkill = result.skillCount;
                this.isCritical = result.isCritical;
            }
            else {
                this.skillName = "";
            }
        })
        .catch(error => {
            console.error('Error:', error);
            //this.skillName = "OOPS ERRORS";
        });
    }

}