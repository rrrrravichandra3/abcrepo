import { LightningElement, track, api } from 'lwc';
import getExperiences from '@salesforce/apex/te_ExperienceController.getExperiences';
import createExperience from '@salesforce/apex/te_ExperienceController.createExperience';
import updateExperience from '@salesforce/apex/te_ExperienceController.updateExperience';
import deleteExperience from '@salesforce/apex/te_ExperienceController.deleteExperience';

export default class ExperienceForm extends LightningElement {
    @api contact;
    @track experiences = [];
    @track hasExperiences = false;
    contactId;
    @track activeSessionName = '';
    @track showError = false;
    experienceBeforeEdit;
    @track error = null;

    connectedCallback(){
        this.getExperiences();
    }

    getExperiences(){
        getExperiences({contactId: this.contact.Id}) 
            .then((result) => {
                this.experiences = result;
                this.hasExperiences = result.length > 0;
                this.experiences = this.experiences.map(experience => {
                        let sectionTile = experience.jobTitle;
                        return { ...experience, isEditMode: false, sectionTitle: sectionTile};
                });
            })
            .catch((error) => {
                console.log(error);
            });
    }

    handleAddExperience() {
        const maxId = this.experiences.length > 0 ? Math.max(...this.experiences.map((experience) => {
            const parsedId = Number(experience.Id);
            return isNaN(parsedId) ? 0 : parsedId;
          })) : 0;
          
        const newExperienceId = maxId + 1; 
        const newExperiencesArray = Array.from(this.experiences);

        newExperiencesArray.push({
            Id: newExperienceId.toString(),
            jobTitle: '',
            isCurrent: false,
            startDate: '',
            endDate: '',
            description: '',
            organizationName: '',
            isEditMode: true,
            sectionTitle: 'New Experience'
        });


        this.experiences = newExperiencesArray; 
        setTimeout(() => {
            this.activeSessionName = newExperienceId.toString();
        }, 500);
    }

    handleInputChange(event) {
        const experienceId = event.target.dataset.id;
        const experienceIndex = this.findExperienceById(experienceId);
        if (experienceIndex !== -1) {
            if(event.target.dataset.name === 'isCurrent'){
                this.experiences[experienceIndex][event.target.dataset.name] = event.target.checked;
            }
            else{
                this.experiences[experienceIndex][event.target.dataset.name] = event.target.value;
            }
        }
    }

    validateFields(exp) {
        return (exp.jobTitle && exp.organizationName && (exp.isCurrent || exp.endDate) && exp.startDate);
    }
    
    handleSaveExperience(event) {
        const experienceId = event.target.dataset.id;
        const experienceIndex = this.findExperienceById(experienceId);
        const experience = this.experiences[experienceIndex];

        if (!this.validateFields(experience)) {
            this.showError = true;
            this.error = null;
            return;
        }

        const fields = {};
        fields.jobTitle = experience.jobTitle;
        fields.isCurrent = experience.isCurrent;
        fields.startDate = experience.startDate;
        fields.endDate = experience.endDate;
        fields.description = experience.description;
        fields.organizationName = experience.organizationName;
        fields.contactId = this.contact.Id;

        if(experience.Id.length === 18){
            fields.Id = experience.Id;
            updateExperience({expWrapper : fields})
            .then(() => {
                this.activeSessionName = experience.Id;
                this.error = null;
                this.showError = false;
                this.getExperiences();
            })
            .catch((error) => {
               console.error(error);
               this.error = error.body.message;
            });
        }
        else{
        createExperience({expWrapper : fields})
            .then((result) => {
                this.error = null;
                this.showError = false;
                this.getExperiences();
                setTimeout(() => {
                    this.activeSessionName = result;
                }, 500);
            })
            .catch((error) => {
               console.error(error)
               this.error = error.body.message;
            });
        }
    }

    handleEditExperience(event) {
        const experienceId = event.currentTarget.dataset.id;
        this.activeSessionName = experienceId;
        this.experiences = this.experiences.map(experience => {
            if (experience.Id === experienceId) {
                this.experienceBeforeEdit = experience;
                return { ...experience, isEditMode: true };
            }
            return experience;
        });
    }

    handleDeleteExperience(event) {
        const experienceId = event.currentTarget.dataset.id;
        deleteExperience({experienceId})
            .then(() => {
                this.error = null;
                this.getExperiences();
            })
            .catch((error) => {
               console.error(error);
               this.error = error.body.message;
            });
    }

    handleCancelExperience(event){
        const experienceId = event.target.dataset.id;
        const experienceIndex = this.findExperienceById(experienceId);
        if(experienceId.length === 18){
            this.experiences[experienceIndex] = this.experienceBeforeEdit;
        }
        else{
            const experienceIndex = this.findExperienceById(experienceId);
            if (experienceIndex > -1) {
                this.experiences.splice(experienceIndex, 1); // Removes 1 element from the array at the specified index
            }
        }
        this.showError = false;
        this.error = null;
    }

    findExperienceById(id) {
        return this.experiences.findIndex((experience) => experience.Id === id);
    }

    isEndDateRequired(event) {
        const experienceId = event.target.dataset.id;
        const experienceIndex = this.findExperienceById(experienceId);
        const experience = this.experiences[experienceIndex];
        return !experience.isCurrent;
    }
}