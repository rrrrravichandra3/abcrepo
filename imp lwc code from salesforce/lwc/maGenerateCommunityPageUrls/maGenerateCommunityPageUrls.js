import { wire,api,track } from "lwc"
import { LightningElement } from 'lwc'
import getCompanyList from '@salesforce/apex/MA_GenerateCommunityPageUrls.getCompanyList'
import { reduceErrors } from 'c/maErrorHandlingUtility'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import MA_Company_Combobox_Label from '@salesforce/label/c.MA_Company_Combobox_Label'
import MA_PagesCombobox_Label from '@salesforce/label/c.MA_PagesCombobox_Label'
import MA_URL_Copied_Label from '@salesforce/label/c.MA_URL_Copied_Label'
import MA_Select_Company_Label from '@salesforce/label/c.MA_Select_Company_Label'

export default class MAGenerateCommunityPageUrls extends LightningElement {
    @api recordId
    @track activeCompanyList
    @track communityPages
    acqCompanyRecords
    ssoKnowledgeUrl
    showSpinner = true
    communityUrls = []
    urlGenerated =  false
    ifSuccessCopy = false
    showCompanyComboBox = false
    showPagesComboBox = false

    label = {
        MA_Company_Combobox_Label,
        MA_PagesCombobox_Label,
        MA_URL_Copied_Label,
        MA_Select_Company_Label
    }
    

    @wire(getCompanyList,{recordId: '$recordId'})
    wiredCompany({error, data}){
        
        if(data){
            
            this.acqCompanyRecords = data
            const pickListValues = []
            data.forEach(element => {
                pickListValues.push({label:element.acqCompanyName, value:element.acqCompanyName})
            })
            this.activeCompanyList = pickListValues
            if(this.recordId.substring(0,3) == 'ka1'){
                this.showCompanyComboBox = true
            }else{
                this.buildCommunityPagesPicklist()
                
            }
            
        }else if (error) {
            this.showErrorMessage(error);
        }

        this.showSpinner = false
    }

    buildCommunityPagesPicklist(){
        let pickListValues = []
        for(const key in this.acqCompanyRecords[0].communityPageUrls){
            pickListValues.push({label:key, value:key})
        }
        this.communityPages = pickListValues
        this.showPagesComboBox = true
    }

    handlePageChange(event){
        const selectedPage = event.currentTarget.value
        let selected = ''
        const urlsMapObject = []
        for(const key in this.acqCompanyRecords[0].communityPageUrls){
            if(selectedPage == key){
                urlsMapObject.push({'Title':key, 'URL': this.acqCompanyRecords[0].communityPageUrls[key]})
               
                this.urlGenerated = true
            }
            
        }
        this.communityUrls = urlsMapObject
        
    }

    handleChange(event){
        const selectedCompany = event.currentTarget.value
        const selected = this.acqCompanyRecords.find(o => o.acqCompanyName == selectedCompany)
        
        this.ifSuccessCopy = false;

        const urlsMapObject = []
        for(const key in selected.communityPageUrls){
            urlsMapObject.push({'Title':key, 'URL': selected.communityPageUrls[key]})
        }
        
        this.communityUrls = urlsMapObject
        this.urlGenerated = true
    }

    copyToClipBoard(event){
        const clickedIcon =  event.currentTarget.dataset.title
        const parent = event.target.parentElement.parentElement
        const prara = parent.querySelector('.urlText')

        
        var range = document.createRange();
        range.selectNode(prara);
        window.getSelection().removeAllRanges();
        window.getSelection().addRange(range);

        document.queryCommandSupported('copy')
        document.execCommand('copy');
        this.ifSuccessCopy = true
    }

    showErrorMessage(error) {
        
        this.showSpinner = false
        this.dispatchEvent(new ShowToastEvent({"title" : "Error", "message" : reduceErrors(error), "variant" : "error"}))
    }

}