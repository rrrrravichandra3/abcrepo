/**
 * W-12456764
 * LWC quick action, holds layout for Package combobox, Package details and Table Data to display available Templates to be copied.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         08/02/2023      Chakshu Malhotra        W-12456764 - Fetches data from Apex controller and interacts with Package combobox, Package details & Table Data
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
import { LightningElement, api, wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { loadStyle } from 'lightning/platformResourceLoader';
import { reduceErrors } from 'c/maErrorHandlingUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import madsSetupPackagesCSS from '@salesforce/resourceUrl/madsSetupPackagesCSS';

import getMasterPackages from '@salesforce/apex/MA_DS_SetupPackages.getMasterPackages';
import getInUseTemplates from '@salesforce/apex/MA_DS_SetupPackages.getInUseTemplates';
import copyPackagesAndTemplates from '@salesforce/apex/MA_DS_SetupPackages.copyPackagesAndTemplates';

import setupPackageModalHeader from '@salesforce/label/c.MA_DS_Setup_Package_Modal_Header';
import packageCopyInstructions from '@salesforce/label/c.MA_DS_Package_Copy_Instructions';
import noAvailablePackages from '@salesforce/label/c.MA_DS_No_Available_Packages';
import successMessage from '@salesforce/label/c.MA_DS_Setup_Package_Success_Message';
import docusignSyncMessage from '@salesforce/label/c.MA_DS_Setup_Package_Docusign_Sync_Message';
import { RefreshEvent } from "lightning/refresh";

export default class MadsSetupPackages extends LightningElement {
    
    @api recordId;
    @track availableTemplatesMap;

    showSpinner;

    masterPackagesMap;
    selectedPackage;

    disabledSaveButton;
    disabledSelectAllRows;

    totalDerivedTemplates;
    totalDerivedDistributions;

    label = {
        setupPackageModalHeader,
        packageCopyInstructions,
        noAvailablePackages,
        successMessage,
        docusignSyncMessage
    };

    constructor() {
        super();
        this.showSpinner = true;
        this.disabledSaveButton = true;
        this.disabledSelectAllRows = false;
        this.masterPackagesMap = new Map();
    }

    get hasMasterPackages() {
        return (this.masterPackagesMap.size > 0);
    }

    get isPackageCopied() {
        return (this.totalDerivedTemplates > 0);
    }

    get derivedTemplatesMap() {
        if(this._derivedTemplatesMap === undefined) {
            this._derivedTemplatesMap = new Map();
        }
        return this._derivedTemplatesMap;
    }
    
    get unselectedTemplatesMap() {
        if(this._unselectedTemplatesMap === undefined) {
            this._unselectedTemplatesMap = new Map();
        }
        return this._unselectedTemplatesMap;
    }

    get newlySelectedTemplatesMap() {
        if(this._newlySelectedTemplatesMap === undefined) {
            this._newlySelectedTemplatesMap = new Map();
        }
        return this._newlySelectedTemplatesMap;
    }

    connectedCallback() {
        Promise.all([
            loadStyle(this, madsSetupPackagesCSS),
            this.fetchPackagesAndTemplates()
        ]).then(() => {
            this.showSpinner = false;
        });
    }

    async fetchPackagesAndTemplates() {
        try {
            let masterPackagesData = await getMasterPackages({});
            if(masterPackagesData.length > 0) {
                this.initMasterPackages(masterPackagesData);
                let inUseTemplatesData = await getInUseTemplates({acqCompanyId: this.recordId, masterPackageId: this.selectedPackage.Id});
                this.initInUseTemplates(inUseTemplatesData);
            }
        }catch(error) {
            this.showErrorMessage(error);
        }
    }

    initMasterPackages(masterPackagesData) {
        let masterPackages = masterPackagesData.map((masterPackage) => ({...masterPackage, "label": masterPackage.Name, "value": masterPackage.Id}));
        this.selectedPackage = masterPackages[0];
        masterPackages.forEach((masterPackage) => {
            this.masterPackagesMap.set(masterPackage.Id, masterPackage);
        });
    }

    initInUseTemplates(inUseTemplatesData) {
        this.initAvailableTemplatesMap(this.getMasterInUseTemplates(inUseTemplatesData));
        this.setDerivedPackageAndTemplateDetails(inUseTemplatesData);
    }

    getMasterInUseTemplates(inUseTemplates) {
        return inUseTemplates.filter(inUseTemplate => inUseTemplate.MA_DS_Package_Using__c === this.selectedPackage.Id)
        .map((inUseTemplate, templateIndex) => ({
            ...inUseTemplate, 
            "disabled": false, 
            "derived": false, 
            "templateCopied": "No", 
            "templateRowNum": (templateIndex + 1), 
            "selected": this.isNewlySelectedTemplate(inUseTemplate), 
            "mergeCapable": (inUseTemplate.MA_DS_Template_Being_Used__r.MA_DS_Merge_Capable__c ? "Yes" : "No")}));
    }

    isNewlySelectedTemplate(inUseTemplate) {
        let concatenatedId = inUseTemplate.MA_DS_Package_Using__c + inUseTemplate.MA_DS_Template_Being_Used__c;
        return this.newlySelectedTemplatesMap.has(concatenatedId);
    }

    initAvailableTemplatesMap(masterInUseTemplates) {
        this.availableTemplatesMap = new Map();
        masterInUseTemplates.forEach((masterInUseTemplate) => {
            masterInUseTemplate.concatenatedId = masterInUseTemplate.MA_DS_Package_Using__c + masterInUseTemplate.MA_DS_Template_Being_Used__c;
            this.availableTemplatesMap.set(masterInUseTemplate.concatenatedId, masterInUseTemplate);
        });
    }

    setDerivedPackageAndTemplateDetails(inUseTemplates) {
        this.totalDerivedTemplates = 0;
        this.totalDerivedDistributions = 0;
        let derivedPackageIdSet = new Set();

        inUseTemplates.forEach((inUseTemplate => {
            if(inUseTemplate.MA_DS_Package_Using__r.MA_DS_Derived_From_Package__c === this.selectedPackage.Id) {
                let derivedFromPackageId = inUseTemplate.MA_DS_Package_Using__r.MA_DS_Derived_From_Package__c;
                let derivedFromTemplateId = inUseTemplate.MA_DS_Template_Being_Used__r.MA_DS_Derived_From_Template__c;
                let concatenatedId = derivedFromPackageId + derivedFromTemplateId;

                if(this.availableTemplatesMap.has(concatenatedId)) {
                    let masterInUseTemplate = this.availableTemplatesMap.get(concatenatedId);
                    masterInUseTemplate.derived = true;
                    masterInUseTemplate.templateCopied = "Yes";
                    masterInUseTemplate.selected = this.isUnselectedTemplate(concatenatedId) ? false : true;

                    if(!derivedPackageIdSet.has(inUseTemplate.MA_DS_Package_Using__c)) {
                        derivedPackageIdSet.add(inUseTemplate.MA_DS_Package_Using__c);
                        this.totalDerivedTemplates += inUseTemplate.MA_DS_Package_Using__r.MA_DS_Available_Number_of_Templates__c;
                        this.totalDerivedDistributions += inUseTemplate.MA_DS_Package_Using__r.MA_DS_Available_Number_of_Distributions__c;
                    }

                    masterInUseTemplate.disabled = (this.totalDerivedDistributions > 0);
                    this.derivedTemplatesMap.set(concatenatedId, inUseTemplate);
                }
            }
        }));
        
        this.disabledSelectAllRows = this.isDisabledSelectAllRows();
    }

    isDisabledSelectAllRows() {
        return (this.selectedPackage.MA_DS_Available_Number_of_Templates__c === this.totalDerivedTemplates && this.totalDerivedDistributions > 0);
    }

    isUnselectedTemplate(concatenatedId) {
        return this.unselectedTemplatesMap.has(concatenatedId);
    }

    updateSelectedPackageId(event) {
        let selectedPackageId = event.detail;
        this.selectedPackage = this.masterPackagesMap.get(selectedPackageId);
        this.fetchTemplates();
    }

    async fetchTemplates() {
        try {
            this.showSpinner = true;
            let inUseTemplatesData = await getInUseTemplates({acqCompanyId: this.recordId, masterPackageId: this.selectedPackage.Id});
            this.initInUseTemplates(inUseTemplatesData);
        }catch(error) {
            this.showErrorMessage(error);
        }finally {
            this.showSpinner = false;
        }
    }

    toggleTemplateAllRowSelection(event) {
        let allRowsSelected = event.detail.allRowsSelected;
        this.availableTemplatesMap.forEach((inUseTemplate, concatenatedId) => {
            if(!inUseTemplate.disabled) {
                let isCopiedTemplate = inUseTemplate.derived;
                this.deleteFromTemplateMap(allRowsSelected, concatenatedId);
                this.addToTemplateMap(allRowsSelected, isCopiedTemplate, concatenatedId);
            }
        });
    }

    deleteFromTemplateMap(isSelected, concatenatedId) {
        if(isSelected) {
            this.unselectedTemplatesMap.delete(concatenatedId);
        }else {
            this.newlySelectedTemplatesMap.delete(concatenatedId);
        }
    }

    addToTemplateMap(isSelected, isCopiedTemplate, concatenatedId) {
        if(isSelected && !isCopiedTemplate) {
            this.newlySelectedTemplatesMap.set(concatenatedId, this.getInUseTemplatesWrapper(concatenatedId));
        }else if(!isSelected && isCopiedTemplate) {
            this.unselectedTemplatesMap.set(concatenatedId, this.getInUseTemplatesWrapper(concatenatedId));
        }
        this.disabledSaveButton = (this.unselectedTemplatesMap.size + this.newlySelectedTemplatesMap.size) === 0;
    }

    getInUseTemplatesWrapper(concatenatedId) {
        const masterInUseTemplateStr = "masterInUseTemplate";
        const derivedInUseTemplateStr = "derivedInUseTemplate";

        let inUseTemplatesWrapper = {};
        let masterTemplate = this.availableTemplatesMap.get(concatenatedId);
        let derivedTemplate = this.derivedTemplatesMap.get(concatenatedId);
        
        if(masterTemplate) {
            inUseTemplatesWrapper[masterInUseTemplateStr] = this.getInUseTemplateWrapper(masterTemplate);
        }
        if(derivedTemplate) {
            inUseTemplatesWrapper[derivedInUseTemplateStr] = this.getInUseTemplateWrapper(derivedTemplate);
        }

        return inUseTemplatesWrapper;
    }

    getInUseTemplateWrapper(inUseTemplate) {
        return {"inUseTemplateId": inUseTemplate.Id, 
                "packageUsing": this.getPackageWrapper(inUseTemplate.MA_DS_Package_Using__r), 
                "templateBeingUsed": this.getTemplateWrapper(inUseTemplate.MA_DS_Template_Being_Used__r)};
    }

    getPackageWrapper(packageUsing) {
        return {"packageId": packageUsing.Id, 
                "packageName": this.selectedPackage.Name, 
                "packageDescription": this.selectedPackage.MA_DS_Package_Description__c};
    }

    getTemplateWrapper(templateBeingUsed) {
        return {"templateId": templateBeingUsed.Id, 
                "templateName": templateBeingUsed.Name, 
                "mergeCapable": templateBeingUsed.MA_DS_Merge_Capable__c, 
                "templateDocumentType": templateBeingUsed.MA_DS_Template_Document_Type__c};
    }

    toggleTemplateRowSelection(event) {
        let rowSelected = event.detail.rowSelected;
        let concatenatedId = event.detail.concatenatedId;
        let isCopiedTemplate = this.availableTemplatesMap.get(concatenatedId).derived;
        this.deleteFromTemplateMap(rowSelected, concatenatedId);
        this.addToTemplateMap(rowSelected, isCopiedTemplate, concatenatedId);
    }

    showErrorMessage(error) {
        this.showSpinner = false;
        this.dispatchEvent(new ShowToastEvent({"title": "Error", "message": reduceErrors(error), "variant": "error"}));
    }

    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave(event) {
        this.showSpinner = true;
        copyPackagesAndTemplates({acqCompanyId: this.recordId, 
                                  newlySelectedInUseTemplates: [...this.newlySelectedTemplatesMap.values()], 
                                  unselectedInUseTemplates: [...this.unselectedTemplatesMap.values()]})
        .then((response) => {
            this.showSpinner = false;
            this.showCopySuccessMessage();
        }).catch((error) => {
            this.showErrorMessage(error);
        }).finally(() => {
            this.dispatchEvent(new RefreshEvent());
            this.dispatchEvent(new CloseActionScreenEvent());
        });
    }

    showCopySuccessMessage() {
        let successToastMessage = this.label.successMessage;
        successToastMessage += ((this.newlySelectedTemplatesMap.size > 0) ? " " + this.label.docusignSyncMessage : "") + "!";
        this.dispatchEvent(new ShowToastEvent({"title" : "Success!", "message" : successToastMessage, "variant" : "success"}));
    }

    disconnectedCallback() {
        let customCssElement = document.querySelector("link[rel=stylesheet][href*='madsSetupPackagesCSS']");
        customCssElement.parentNode.removeChild(customCssElement);
    }
}