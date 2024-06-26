import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import returnGPTResponse from '@salesforce/apex/einstein_GPT_Service.returnGPTResponse';
import { loadScript } from 'c/resourceLoader';
import getPreferences from '@salesforce/apex/te_PreferencesController.getPreferences';
import updatePreferences from '@salesforce/apex/te_PreferencesController.updatePreferences';
import getEmployeeContactData from '@salesforce/apex/te_GrowthAppService.getEmployeeContactData';
import LightningModal from 'lightning/modal';
import processNewSkillAssignments from '@salesforce/apex/talentMP_SkillsService.processNewSkillAssignments'




export default class Te_firstLoginProfileSetup extends NavigationMixin(LightningModal) {
    firstLoginComplete = true;
    skillsCmpVisible;
    @track pdfText = '';
    @track disableButton = true;
    selectedFile;
    spinner = false;
    promptStart = 'You are a resume parsing engine that has knowledge of industry required skills. What are the all the skills listed and inferred of this person from the following resume? Look over the specific on details of each position and extract skills from there as well. Response should be returned in a comma separated list only for ease of processing in the following format with no spaces next to the commas: Skill Name,Skill Name,Skill Name Limit the response to the 30 most relevent skills in the array format.'
    errorText = '';
    @track myVal;
    @api recordId;
    pageReference;
    @api contact;
    @api preferences;
    @api skillList;
    usr;
    addedSkills;
    

    async connectedCallback() {
        console.log('Component Loaded');
        this.getPreferencesFromServer();
        this.getEmployeeContact();
        this.showSkillCmp();
        try {
            // Load the remote PDF.js library from a CDN or an external source
            await loadScript('https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.3.200/pdf.min.js');
            this.disableButton = false;
        } catch (error) {
            console.error('Error loading PDF.js:', error);
            this.disableButton = true; // Disable the extract button if PDF.js fails to load
        }
    }

    getEmployeeContact(){
        getEmployeeContactData()
          .then((result) => {
            this.contact = result.contact;
            this.skillList = result.skillList;
            this.usr = result.usr;
            if(this.skillList.length > 0){
                this.showSkillCmp();
            }else{
                this.hideSkillCmp();
            }
            this.usr = result.usr;
          })
          .catch((error) => {
            console.log(error);
          });
    }

    getPreferencesFromServer(){
        getPreferences()
        .then(result => {
            console.log(result);
            this.preferences = result;
            this.firstLoginComplete = result.First_Login_Complete__c;
            console.log('show first login : ' + this.firstLoginComplete);
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }
    handleFileChange(event) {
        this.selectedFile = event.target.files[0];
        if (!this.selectedFile || this.selectedFile.type !== 'application/pdf') {
            // Make sure a PDF file is selected
            return;
        }

        const reader = new FileReader();
        reader.onload = async () => {
            const pdfData = new Uint8Array(reader.result);
            const pdfText = await this.extractTextFromPDF(pdfData);
            this.pdfText = pdfText;
            this.extractSkills();
        };
        reader.readAsArrayBuffer(this.selectedFile);
        
    }

    extractSkills(){
        //console.log(this.pdfText);
        console.log(this.promptStart);
        let prompText = this.promptStart + this.pdfText;
        console.log(prompText);
        this.showSpinner();
        returnGPTResponse({
            textPrompt: prompText
        })
          .then((result) => {
            let skillString = result;
            this.myVal = skillString;

            this.addedSkills = this.myVal.split(",");
            this.createNewSkills();
            this.hideSpinner();
          })
          .catch((error) => {
            console.log(error);
            //handle error
            this.hideSpinner();
            if (error && error.body) {
                console.log(error.body.message);
              //this.fireToastEvent("Error!", error.body.message, "error");
            }
          });

    }

    handleSaveSkills(event){
        this.skillList = event.detail.skillsListUpdated;
    }

    async extractTextFromPDF(pdfData) {
        try {
            const loadingTask = pdfjsLib.getDocument({ data: pdfData });
            const pdf = await loadingTask.promise;
            let pdfText = '';

            for (let pageNumber = 1; pageNumber <= pdf.numPages; pageNumber++) {
                const page = await pdf.getPage(pageNumber);
                const textContent = await page.getTextContent();
                const textItems = textContent.items;
                const pageText = textItems.map(item => item.str).join(' ');
                pdfText += pageText + '\n';
            }

            return pdfText;
        } catch (error) {
            console.error('error message:' + error);
            return 'Error occurred while extracting text from the PDF.';
        }
    }
    showSkillCmp(){
        this.skillsCmpVisible = true;
      }

    hideSkillCmp(){
        this.skillsCmpVisible = false;
    }

    showSpinner() { 
        this.spinner = true;
    }
    
    hideSpinner() {
        this.spinner = false;
    }
    showModal(){
        this.showFirstLogin = false;

    }
    "Insert failed. First exception on row 0; first error: INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, insufficient access rights on cross-reference id: 003AE0000091Tys: []"


    @api
    get skillsCmpVisible(){
        console.log("skill list"+this.skillList);
        if(this.skillList === null || this.skillList.length === 0){
            return false;
        }
        else{
            return true;
        }
    }
    
    hideModal(){
        if(this.validate()){
        this.firstLoginComplete = true;
        this.updatePreferencesFirstLogin();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Growth__c'
            }
        });
        }
        else{
            this.errorText = 'You must provide skills before progressing.'
        }
    }
    updatePreferencesFirstLogin(){
        this.preferences.First_Login_Complete__c = true;
        updatePreferences({preferences: this.preferences})
            .then(result => {
                console.log(result);
            })
            .catch(error => {
                console.error('error message:' + error);
            });
    }

    async createNewSkills(){
        console.log('Creating Skills --->' + this.addedSkills);
        await processNewSkillAssignments({skillNames : this.addedSkills, contactIds : new Array(this.contact.Id)}); 
        this.getEmployeeContact();
    }

    validate(){
        console.log(this.skillList);
        if(this.skillList.length === 0){
            return false;
        }else{
            return true;
        }
    }
}