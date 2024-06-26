// pdfExtractorLWC.js
import { LightningElement, track, api, wire} from 'lwc';
import returnGPTResponse from '@salesforce/apex/einstein_GPT_Service.returnGPTResponse';
import extractSkills from '@salesforce/apex/te_LightCastApiService.extractSkills';
import { loadScript } from 'c/resourceLoader';

export default class PdfExtractorLWC extends LightningElement {
    @track pdfText = '';
    @track disableButton = true;
    selectedFile;
    spinner = false;
    @track skillsList = [];
    @track componentSkillList = [];
    promptStart = 'You are a resume parsing engine that has knowledge of industry required skills. What are the all the skills listed and inferred of this person from the following resume? Look over the specific on details of each position and extract skills from there as well. Response should be returned in a comma separated list only for ease of processing in the following format with no spaces next to the commas: Skill Name,Skill Name,Skill Name Limit the response to the 30 most relevent skills in the array format.'

    @track myVal;
    @api recordId;
    isShowLookupModal = false;

    async connectedCallback() {
        try {
            // Load the remote PDF.js library from a CDN or an external source
            await loadScript('https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.3.200/pdf.min.js');
            this.disableButton = false;
        } catch (error) {
            console.log('Error loading PDF.js:', error);
            console.error('Error loading PDF.js:', error);
            this.disableButton = true; // Disable the extract button if PDF.js fails to load
        }
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
        let prompText = this.promptStart + this.pdfText;
        console.log(prompText);
        this.showSpinner();
        returnGPTResponse({
            textPrompt: prompText
        })
          .then((result) => {
            let skillString = result;
            extractSkills({text:skillString, confidenceThreshold:0.8})
            .then((result) => {
                this.skillsList = result.split(',');
            })
            this.hideSpinner();
          })
          .catch((error) => {
            console.log('Error-->>'+JSON.stringify(error));
            console.log(error);
            //handle error
            this.hideSpinner();
            if (error && error.body) {
                console.log(error.body.message);
              //this.fireToastEvent("Error!", error.body.message, "error");
            }
          });

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

    showSpinner() {
        this.spinner = true;
    }
    
    hideSpinner() {
        this.spinner = false;
    }
    showModal(){
        this.isShowLookupModal = true;

    }
    hideModal(){
        this.isShowLookupModal = false;
        this.componentSkillList = this.skillsList;

        this.dispatchEvent(new CustomEvent('sendevent',{
            detail: this.componentSkillList
        }))
    }
    

}