/**
 * W-12404865
 * Helper class of MA_DS_SetupPackages controller to copy master Packages, Templates & In Use Templates.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         31/01/2023      Chakshu Malhotra        W-12404865 - Adds helper logic for LWC controller to automate copy of Packages, Templates & In Use Templates.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_SetupPackagesHelper {

    private static final String PACKAGE_TYPE_ACQUISITION = Label.MA_DS_Package_Type_Acquisition;
    private static final String TEMPLATE_TYPE_ACQUISITION = Label.MA_DS_Template_Type_Acquisition;

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create newly selected Acquisition Packages & Templates added in the List of MA_DS_SetupPackagesWrapper instance.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	 	                DESCRIPTION (Data Type Id, Acquistion Company record Id)
    * @param    setupPackagesWrapperList	 	    DESCRIPTION (Data Type List, List of MA_DS_SetupPackagesWrapper instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setupNewPackagesAndTemplates(Id acqCompanyId, List<MA_DS_SetupPackagesWrapper> setupPackagesWrapperList) {
        setPackageAndTemplateIds(setupPackagesWrapperList, true);
        setDerivedPackageMap(acqCompanyId);
        setDerivedTemplateMap(acqCompanyId);
        createNewDerivedPackagesAndTemplates(acqCompanyId, setupPackagesWrapperList);
        setRulesAndAuditFlagsMap(setupPackagesWrapperList);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to set Package Ids, Template Ids & In Use Template Ids (master & derived records based on user selection).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    setupPackagesWrapperList	    DESCRIPTION (Data Type List, List of MA_DS_SetupPackagesWrapper instance)
    * @param    masterInUseTemplate	 	        DESCRIPTION (Data Type Boolean, True if Master In Use Template)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void setPackageAndTemplateIds(List<MA_DS_SetupPackagesWrapper> setupPackagesWrapperList, Boolean masterInUseTemplate) {
        MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance = MA_DS_SetupPackagesWrapper.getInstance();

        for(MA_DS_SetupPackagesWrapper setupPackagesWrapper : setupPackagesWrapperList) {
            MA_DS_SetupPackagesWrapper.InUseTemplateWrapper inUseTemplateWrapper = masterInUseTemplate ? setupPackagesWrapper.masterInUseTemplate : setupPackagesWrapper.derivedInUseTemplate;
            
            Id packageId = inUseTemplateWrapper.packageUsing.packageId;
            Id templateId = inUseTemplateWrapper.templateBeingUsed.templateId;
            
            if(packageId != null) {
                Set<Id> packageIds = masterInUseTemplate ? wrapperInstance.masterPackageIds : wrapperInstance.derivedPackageIds;
                packageIds.add(packageId);
            }

            if(templateId != null) {
                Set<Id> templateIds = masterInUseTemplate ? wrapperInstance.masterTemplateIds : wrapperInstance.derivedTemplateIds;
                templateIds.add(templateId);
            }

            Set<Id> inUseTemplates = masterInUseTemplate ? wrapperInstance.masterInUseTemplateIds : wrapperInstance.derivedInUseTemplateIds;
            inUseTemplates.add(inUseTemplateWrapper.inUseTemplateId);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to identify & create derivedPackageMap for existing Derived Packages (if any) based on selected In Use Templates on the UI.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void setDerivedPackageMap(Id acqCompanyId) {
        MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance = MA_DS_SetupPackagesWrapper.getInstance();

        List<MA_DS_Package__c> masterPackages = [SELECT Id, (SELECT Id FROM MA_DS_Packages__r 
                                                             WHERE MA_DS_Acquisition_Company__c = :acqCompanyId LIMIT 1)
                                                 FROM MA_DS_Package__c
                                                 WHERE Id IN :wrapperInstance.masterPackageIds];

        for(MA_DS_Package__c masterPackage : masterPackages) {
            if(masterPackage.MA_DS_Packages__r != null && masterPackage.MA_DS_Packages__r.size() > 0) {
                wrapperInstance.derivedPackageMap.put(masterPackage.Id, masterPackage.MA_DS_Packages__r[0]);
            }
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to identify & create derivedTemplateMap for existing Derived Templates (if any) based on selected In Use Templates on the UI.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void setDerivedTemplateMap(Id acqCompanyId) {
        MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance = MA_DS_SetupPackagesWrapper.getInstance();

        List<MA_DS_Template__c> masterTemplates = [SELECT Id, (SELECT Id FROM MA_DS_Templates__r 
                                                               WHERE MA_DS_Acquisition_Company__c = :acqCompanyId LIMIT 1)
                                                   FROM MA_DS_Template__c 
                                                   WHERE Id IN :wrapperInstance.masterTemplateIds];

        for(MA_DS_Template__c masterTemplate : masterTemplates) {
            if(masterTemplate.MA_DS_Templates__r != null && masterTemplate.MA_DS_Templates__r.size() > 0) {
                wrapperInstance.derivedTemplateMap.put(masterTemplate.Id, masterTemplate.MA_DS_Templates__r[0]);
            }
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to populate newDerivedPackageMap & newDerivedTemplateMap & create new Derived Packages & new Derived Templates.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    setupPackagesWrapperList	        DESCRIPTION (Data Type List, List of MA_DS_SetupPackagesWrapper instance)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void createNewDerivedPackagesAndTemplates(Id acqCompanyId, List<MA_DS_SetupPackagesWrapper> setupPackagesWrapperList) {
        MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance = MA_DS_SetupPackagesWrapper.getInstance();

        for(MA_DS_SetupPackagesWrapper setupPackagesWrapper : setupPackagesWrapperList) {
            MA_DS_SetupPackagesWrapper.InUseTemplateWrapper inUseTemplateWrapper = setupPackagesWrapper.masterInUseTemplate;
            
            Id masterPackageId = inUseTemplateWrapper.packageUsing.packageId;
            Id masterTemplateId = inUseTemplateWrapper.templateBeingUsed.templateId;

            if(!wrapperInstance.derivedPackageMap.containsKey(masterPackageId)) {
                wrapperInstance.newDerivedPackageMap.put(masterPackageId, getNewDerivedPackage(acqCompanyId, inUseTemplateWrapper.packageUsing));
            }

            if(!wrapperInstance.derivedTemplateMap.containsKey(masterTemplateId)) {
                wrapperInstance.newDerivedTemplateMap.put(masterTemplateId, getNewDerivedTemplate(acqCompanyId, inUseTemplateWrapper.templateBeingUsed));
            }
        }
        
        if(wrapperInstance.newDerivedPackageMap.size() > 0) {
            Database.SaveResult[] packageSRList = Database.insert(wrapperInstance.newDerivedPackageMap.values(), false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(packageSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
        if(wrapperInstance.newDerivedTemplateMap.size() > 0) {
            MA_DS_TemplateTriggerHelper.overrideTemplateCRUDAccess = true;
            Database.SaveResult[] templateSRList = Database.insert(wrapperInstance.newDerivedTemplateMap.values(), false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(templateSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to populate new MA_DS_Package__c record for the newly selected Package on the UI.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    masterPackage	                DESCRIPTION (Data Type MA_DS_SetupPackagesWrapper.PackageWrapper, PackageWrapper instance containing Master Package details)
    * @return   MA_DS_Package__c                DESCRIPTION (return New Derived Package to be inserted)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_Package__c getNewDerivedPackage(Id acqCompanyId, MA_DS_SetupPackagesWrapper.PackageWrapper masterPackage) {
        MA_DS_Package__c newDerivedPackage = new MA_DS_Package__c();
        newDerivedPackage.Name = masterPackage.packageName;
        newDerivedPackage.MA_DS_Acquisition_Company__c = acqCompanyId;
        newDerivedPackage.MA_DS_Package_Type__c = PACKAGE_TYPE_ACQUISITION;
        newDerivedPackage.MA_DS_Derived_From_Package__c = masterPackage.packageId;
        newDerivedPackage.MA_DS_Package_Description__c = masterPackage.packageDescription;
        return newDerivedPackage;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to populate new MA_DS_Template__c record for the newly selected Template on the UI.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    masterTemplate	                DESCRIPTION (Data Type MA_DS_SetupPackagesWrapper.TemplateWrapper, TemplateWrapper instance containing Master Template details)
    * @return   MA_DS_Template__c               DESCRIPTION (return New Derived Template to be inserted)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_Template__c getNewDerivedTemplate(Id acqCompanyId, MA_DS_SetupPackagesWrapper.TemplateWrapper masterTemplate) {
        MA_DS_Template__c newDerivedTemplate = new MA_DS_Template__c();
        newDerivedTemplate.Name = masterTemplate.templateName;
        newDerivedTemplate.MA_DS_Acquisition_Company__c = acqCompanyId;
        newDerivedTemplate.MA_DS_Template_Type__c = TEMPLATE_TYPE_ACQUISITION;
        newDerivedTemplate.MA_DS_Merge_Capable__c = masterTemplate.mergeCapable;
        newDerivedTemplate.MA_DS_Derived_From_Template__c = masterTemplate.templateId;
        newDerivedTemplate.MA_DS_Template_Document_Type__c = masterTemplate.templateDocumentType;
        return newDerivedTemplate;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to populate masterInUseTemplateMap based on the In Use Templates selected, to be used to copy Rules & Audit Flags on dervied In Use Templates.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    setupPackagesWrapperList	        DESCRIPTION (Data Type List, List of MA_DS_SetupPackagesWrapper instance)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void setRulesAndAuditFlagsMap(List<MA_DS_SetupPackagesWrapper> setupPackagesWrapperList) {
        MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance = MA_DS_SetupPackagesWrapper.getInstance();
        Set<Id> masterInUseTemplateIds = getMasterInUseTemplateIds(setupPackagesWrapperList);

        List<MA_DS_In_Use_Template__c> inUseTemplates = [SELECT Id, MA_DS_Sort_Order__c, MA_DS_Audit_All__c, MA_DS_Audit_Flags_JSON__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c, 
                                                         MA_DS_Audit_Flags_Added__c, MA_DS_Rules_Criteria_Added__c, MA_DS_Suppress_Audit_Flags__c, MA_DS_Suppress_Rules_Criteria__c
                                                         FROM MA_DS_In_Use_Template__c 
                                                         WHERE Id IN :masterInUseTemplateIds];

        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            wrapperInstance.masterInUseTemplateMap.put(inUseTemplate.Id, inUseTemplate);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Master In Use Template record Ids for the selected Templates on the UI.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    setupPackagesWrapperList	        DESCRIPTION (Data Type List, List of MA_DS_SetupPackagesWrapper instance)
    * @return   Set<Id>                             DESCRIPTION (return Set of Master In Use Template record Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<Id> getMasterInUseTemplateIds(List<MA_DS_SetupPackagesWrapper> setupPackagesWrapperList) {
        Set<Id> masterInUseTemplateIds = new Set<Id>();
        for(MA_DS_SetupPackagesWrapper setupPackagesWrapper : setupPackagesWrapperList) {
            MA_DS_SetupPackagesWrapper.InUseTemplateWrapper inUseTemplateWrapper = setupPackagesWrapper.masterInUseTemplate;
            masterInUseTemplateIds.add(inUseTemplateWrapper.inUseTemplateId);
        }
        return masterInUseTemplateIds;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create the derived In Use Template records based on the selection of Templates on the UI.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    setupPackagesWrapperList	        DESCRIPTION (Data Type List, List of MA_DS_SetupPackagesWrapper instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void setupNewInUseTemplates(List<MA_DS_SetupPackagesWrapper> setupPackagesWrapperList) {
        MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance = MA_DS_SetupPackagesWrapper.getInstance();

        for(MA_DS_SetupPackagesWrapper setupPackagesWrapper : setupPackagesWrapperList) {
            MA_DS_SetupPackagesWrapper.InUseTemplateWrapper inUseTemplateWrapper = setupPackagesWrapper.masterInUseTemplate;

            Id derivedPackageId = getDerivedPackageId(inUseTemplateWrapper.packageUsing.packageId, wrapperInstance);
            Id derivedTemplateId = getDerivedTemplateId(inUseTemplateWrapper.templateBeingUsed.templateId, wrapperInstance);
            MA_DS_In_Use_Template__c masterInUseTemplate = wrapperInstance.masterInUseTemplateMap.get(inUseTemplateWrapper.inUseTemplateId);

            wrapperInstance.newDerivedInUseTemplates.add(getNewDerivedInUseTemplate(derivedPackageId, derivedTemplateId, masterInUseTemplate));
        }

        if(wrapperInstance.newDerivedInUseTemplates.size() > 0) {
            Database.UpsertResult[] inUseTemplateURList = Database.upsert(wrapperInstance.newDerivedInUseTemplates, MA_DS_In_Use_Template__c.MA_DS_Concatenated_Id__c, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(inUseTemplateURList, MA_AbstractLogger.BulkLoggerType.UPSERT_RESULT);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Package Reference for the new In Use Template being created.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    masterPackageId	        DESCRIPTION (Data Type Id, Id of the Master Package record)
    * @param    wrapperInstance	        DESCRIPTION (Data Type MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper, Wrapper instance of SetupPackagesHelperWrapper)
    * @return   Id                      DESCRIPTION (return Derived Package record Id)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Id getDerivedPackageId(Id masterPackageId, MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance) {
        Boolean isNewDerivedPackage = wrapperInstance.newDerivedPackageMap.containsKey(masterPackageId);
        return isNewDerivedPackage ? wrapperInstance.newDerivedPackageMap.get(masterPackageId).Id : wrapperInstance.derivedPackageMap.get(masterPackageId).Id;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Template Reference for the new In Use Template being created.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    masterTemplateId	    DESCRIPTION (Data Type Id, Id of the Master Template record)
    * @param    wrapperInstance	        DESCRIPTION (Data Type MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper, Wrapper instance of SetupPackagesHelperWrapper)
    * @return   Id                      DESCRIPTION (return Derived Template record Id)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Id getDerivedTemplateId(Id masterTemplateId, MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance) {
        Boolean isNewDerivedTemplate = wrapperInstance.newDerivedTemplateMap.containsKey(masterTemplateId);
        return isNewDerivedTemplate ? wrapperInstance.newDerivedTemplateMap.get(masterTemplateId).Id : wrapperInstance.derivedTemplateMap.get(masterTemplateId).Id;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to populate the In Use Template record based on the Derived Package & Template reference and Copying Rules & Audit Fields as well.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    derivedPackageId	                DESCRIPTION (Data Type Id, Package reference for the In Use Template record)
    * @param    derivedTemplateId	                DESCRIPTION (Data Type Id, Template reference for the In Use Template record)
    * @param    masterInUseTemplate	                DESCRIPTION (Data Type MA_DS_In_Use_Template__c, Master In Use Template record)
    * @return   MA_DS_In_Use_Template__c            DESCRIPTION (return In Use Template record for Upsert DML operation)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_In_Use_Template__c getNewDerivedInUseTemplate(Id derivedPackageId, Id derivedTemplateId, MA_DS_In_Use_Template__c masterInUseTemplate) {
        MA_DS_In_Use_Template__c newDerivedInUseTemplate = new MA_DS_In_Use_Template__c();
        newDerivedInUseTemplate.MA_DS_Package_Using__c = derivedPackageId;
        newDerivedInUseTemplate.MA_DS_Template_Being_Used__c = derivedTemplateId;
        newDerivedInUseTemplate.MA_DS_Audit_All__c = masterInUseTemplate?.MA_DS_Audit_All__c;
        newDerivedInUseTemplate.MA_DS_Sort_Order__c = masterInUseTemplate?.MA_DS_Sort_Order__c;
        newDerivedInUseTemplate.MA_DS_Audit_Flags_JSON__c = masterInUseTemplate?.MA_DS_Audit_Flags_JSON__c;
        newDerivedInUseTemplate.MA_DS_Audit_Flags_Added__c = masterInUseTemplate?.MA_DS_Audit_Flags_Added__c;
        newDerivedInUseTemplate.MA_DS_Rules_Criteria_JSON__c = masterInUseTemplate?.MA_DS_Rules_Criteria_JSON__c;
        newDerivedInUseTemplate.MA_DS_Rules_Criteria_Query__c = masterInUseTemplate?.MA_DS_Rules_Criteria_Query__c;
        newDerivedInUseTemplate.MA_DS_Rules_Criteria_Added__c = masterInUseTemplate?.MA_DS_Rules_Criteria_Added__c;
        newDerivedInUseTemplate.MA_DS_Suppress_Audit_Flags__c = masterInUseTemplate?.MA_DS_Suppress_Audit_Flags__c;
        newDerivedInUseTemplate.MA_DS_Suppress_Rules_Criteria__c = masterInUseTemplate?.MA_DS_Suppress_Rules_Criteria__c;
        newDerivedInUseTemplate.MA_DS_Concatenated_Id__c = String.valueOf(derivedPackageId) + String.valueOf(derivedTemplateId);
        return newDerivedInUseTemplate;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to delete the Templates (if unselected on the UI). In Use Template record is deleted.
    * If the Derived Package is left with no available templates, then the Derived Package gets deleted as well.
    * If the Derived Template is not referenced in any other In Use Template, then the Derived Template gets deleted as well.
    * Performs a hard delete operation to remove all deleted record from the Recycle Bin as well.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    setupPackagesWrapperList	        DESCRIPTION (Data Type List, List of MA_DS_SetupPackagesWrapper instance)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void removeUnselectedPackagesAndTemplates(List<MA_DS_SetupPackagesWrapper> setupPackagesWrapperList) {
        MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance = MA_DS_SetupPackagesWrapper.getInstance();
        setPackageAndTemplateIds(setupPackagesWrapperList, false);

        MA_DS_TemplateTriggerHelper.overrideTemplateCRUDAccess = true;

        List<sObject> deletedSObjects = new List<sObject>();
        deletedSObjects.addAll(removeUnselectedInUseTemplateIds(wrapperInstance));
        deletedSObjects.addAll(removePackagesWithNoAvailableTemplates(wrapperInstance));
        deletedSObjects.addAll(removeTemplatesWithNoUsage(wrapperInstance));
        hardDeleteSObjectRecords(deletedSObjects);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to delete and return the List of In Use Template records being deleted (due to unselection from the UI).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    wrapperInstance	                    DESCRIPTION (Data Type MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper, Wrapper instance of SetupPackagesHelperWrapper)
    * @return   List<MA_DS_In_Use_Template__c>      DESCRIPTION (return the List of deleted In Use Template records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_In_Use_Template__c> removeUnselectedInUseTemplateIds(MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance) {
        List<MA_DS_In_Use_Template__c> inUseTemplates = new List<MA_DS_In_Use_Template__c>();
        
        for(Id inUseTemplateId : wrapperInstance.derivedInUseTemplateIds) {
            inUseTemplates.add(new MA_DS_In_Use_Template__c(Id = inUseTemplateId));
        }

        if(inUseTemplates.size() > 0) {
            List<Database.DeleteResult> drList = Database.delete(inUseTemplates, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(drList, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);
        }

        return inUseTemplates;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to delete and return the List of Derived Package records being deleted (due to no available Templates on them).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    wrapperInstance	                    DESCRIPTION (Data Type MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper, Wrapper instance of SetupPackagesHelperWrapper)
    * @return   List<MA_DS_Package__c>              DESCRIPTION (return the List of deleted Package records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Package__c> removePackagesWithNoAvailableTemplates(MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance) {
        List<MA_DS_Package__c> derivedPackages = [SELECT Id, MA_DS_Available_Number_of_Templates__c
                                                  FROM MA_DS_Package__c 
                                                  WHERE Id IN :wrapperInstance.derivedPackageIds AND
                                                  MA_DS_Available_Number_of_Templates__c = 0];
        
        if(derivedPackages.size() > 0) {
            List<Database.DeleteResult> drList = Database.delete(derivedPackages, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(drList, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);
        }

        return derivedPackages;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to delete and return the List of Derived Template records being deleted (due to no usage in "In Use Template" records).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    wrapperInstance	                    DESCRIPTION (Data Type MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper, Wrapper instance of SetupPackagesHelperWrapper)
    * @return   List<MA_DS_Package__c>              DESCRIPTION (return the List of deleted Template records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<MA_DS_Template__c> removeTemplatesWithNoUsage(MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance) {
        List<MA_DS_Template__c> derivedTemplates = [SELECT Id FROM MA_DS_Template__c
                                                    WHERE Id IN :wrapperInstance.derivedTemplateIds AND
                                                    Id NOT IN (SELECT MA_DS_Template_Being_Used__c FROM MA_DS_In_Use_Template__c
                                                               WHERE MA_DS_Template_Being_Used__c IN :wrapperInstance.derivedTemplateIds)];

        if(derivedTemplates.size() > 0) {
            List<Database.DeleteResult> drList = Database.delete(derivedTemplates, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(drList, MA_AbstractLogger.BulkLoggerType.DELETE_RESULT);
        }

        return derivedTemplates;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to perform a hard delete on the deleted sObject records. Removes all deleted sObject records from the Recycle Bin).
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    deletedSObjects	                    DESCRIPTION (Data Type List<sObject>, Deleted sObject records - In Use Templates, Packages & Templates)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void hardDeleteSObjectRecords(List<sObject> deletedSObjects) {
        if(deletedSObjects.size() > 0) {
            DataBase.emptyRecycleBin(deletedSObjects);
        }
    }
}