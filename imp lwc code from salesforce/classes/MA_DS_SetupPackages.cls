/**
 * W-12404865, W-12456766
 * Controller class of madsSetupPackages (LWC component) to copy master Packages, Templates & In Use Templates.
 * Implements API callout to Docusign CLM to start Master and Custom Package Copy workflow.
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/01/2023      Chakshu Malhotra        W-12404865 - Adds controller logic for LWC to automate copy of Packages, Templates & In Use Templates.
 * v2.0         02-03-2023      Chakshu Malhotra        W-12456766 - Adds API Callout to Docusign CLM usign CLM Callout Framework.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_SetupPackages {
    
    private static final String PACKAGE_TYPE_MASTER = Label.MA_DS_Package_Type_Master;
    private static final String CALLOUT_CONFIG_PACKAGE_COPY = Label.MA_DS_Callout_Config_Package_Copy;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to return List of Master Packages which have atleast 1 In Use Template.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   List<MA_DS_Package__c>  DESCRIPTION (return List of MA_DS_Package__c records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static List<MA_DS_Package__c> getMasterPackages() {
        return [SELECT Id, Name, MA_DS_Package_Description__c, MA_DS_Available_Number_of_Templates__c
                FROM MA_DS_Package__c
                WHERE MA_DS_Package_Type__c = :PACKAGE_TYPE_MASTER AND
                MA_DS_Available_Number_of_Templates__c > 0];
    }
    
    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch In Use Template records related to Master Packages as well as related to Derived Acquisition Master Packages.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	 	                DESCRIPTION (Data Type Id, Acquistion Company record Id)
    * @param    masterPackageId	 	                DESCRIPTION (Data Type Id, Selected Master Package record Id)
    * @return   List<MA_DS_In_Use_Template__c>      DESCRIPTION (return List of In Use Template records)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static List<MA_DS_In_Use_Template__c> getInUseTemplates(Id acqCompanyId, Id masterPackageId) {
        return [SELECT Id, MA_DS_Package_Using__c, MA_DS_Template_Being_Used__c, MA_DS_Package_Using__r.MA_DS_Derived_From_Package__c, 
                MA_DS_Package_Using__r.MA_DS_Available_Number_of_Templates__c, MA_DS_Package_Using__r.MA_DS_Available_Number_of_Distributions__c, 
                MA_DS_Template_Being_Used__r.Name, MA_DS_Template_Being_Used__r.MA_DS_Derived_From_Template__c, MA_DS_Template_Being_Used__r.MA_DS_Merge_Capable__c, 
                MA_DS_Template_Being_Used__r.MA_DS_Template_Document_Type__c
                FROM MA_DS_In_Use_Template__c
                WHERE MA_DS_Package_Using__c = :masterPackageId OR
                (MA_DS_Package_Using__r.MA_DS_Acquisition_Company__c = :acqCompanyId AND 
                MA_DS_Package_Using__r.MA_DS_Derived_From_Package__c = :masterPackageId)];
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create copy of newly selected / derived In Use Templates (along with copy of selected Packages & Templates if does not exist already)
    * Method also removes unselected / derived In Use Templates (removes Derived Templates if no more related In Use Templates, removes Derived Packages if no more related In Use Templates)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	 	                DESCRIPTION (Data Type Id, Acquistion Company record Id)
    * @param    newlySelectedInUseTemplates	 	    DESCRIPTION (Data Type List<MA_DS_SetupPackagesWrapper>, List of newly selected In Use Templates in the form of MA_DS_SetupPackagesWrapper)
    * @param    unselectedInUseTemplates	 	    DESCRIPTION (Data Type List<MA_DS_SetupPackagesWrapper>, List of unselected In Use Templates in the form of MA_DS_SetupPackagesWrapper)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void copyPackagesAndTemplates(Id acqCompanyId, List<MA_DS_SetupPackagesWrapper> newlySelectedInUseTemplates, List<MA_DS_SetupPackagesWrapper> unselectedInUseTemplates) {
        try {
            createNewlySelectedInUseTemplates(acqCompanyId, newlySelectedInUseTemplates);
            removeUnselectedInUseTemplates(unselectedInUseTemplates);
            calloutPackageCopyWorkflow(acqCompanyId);
        }catch(Exception packageCopyException) {
            throw new AuraHandledException(packageCopyException.getMessage());
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create copy of newly selected / derived In Use Templates (along with copy of selected Packages & Templates if does not exist already)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	 	                DESCRIPTION (Data Type Id, Acquistion Company record Id)
    * @param    setupPackagesWrapperList	 	    DESCRIPTION (Data Type List<MA_DS_SetupPackagesWrapper>, List of newly selected In Use Templates in the form of MA_DS_SetupPackagesWrapper)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void createNewlySelectedInUseTemplates(Id acqCompanyId, List<MA_DS_SetupPackagesWrapper> setupPackagesWrapperList) {
        MA_DS_SetupPackagesHelper.setupNewPackagesAndTemplates(acqCompanyId, setupPackagesWrapperList);
        MA_DS_SetupPackagesHelper.setupNewInUseTemplates(setupPackagesWrapperList);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to remove unselected / derived In Use Templates (removes Derived Templates if no more related In Use Templates, removes Derived Packages if no more related In Use Templates)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	 	                DESCRIPTION (Data Type Id, Acquistion Company record Id)
    * @param    unselectedInUseTemplates	 	    DESCRIPTION (Data Type List<MA_DS_SetupPackagesWrapper>, List of unselected In Use Templates in the form of MA_DS_SetupPackagesWrapper)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void removeUnselectedInUseTemplates(List<MA_DS_SetupPackagesWrapper> unselectedInUseTemplates) {
        MA_DS_SetupPackagesHelper.removeUnselectedPackagesAndTemplates(unselectedInUseTemplates);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to make a callout to CLM Object API to start Master and Custom Package Copy workflow using the CLM Callout Framework.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	 	                DESCRIPTION (Data Type Id, Acquistion Company record Id)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void calloutPackageCopyWorkflow(Id acqCompanyId) {
        MA_DS_SetupPackagesWrapper.SetupPackagesHelperWrapper wrapperInstance = MA_DS_SetupPackagesWrapper.getInstance();
        List<MA_DS_Template__c> newDerivedTemplates = wrapperInstance.newDerivedTemplateMap.values();

        if(newDerivedTemplates.size() > 0) {
            MA_DS_CalloutFramework.calloutStrategy.setCalloutConfig(CALLOUT_CONFIG_PACKAGE_COPY)
                                                  .setCalloutRequestParams(newDerivedTemplates)
                                                  .setCalloutRequest()
                                                  .setResponseCallback()
                                                  .initAsyncCallout(acqCompanyId);
        }
    }
}