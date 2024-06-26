/**
 * W-12578116 & W-12578130
 * Trigger helper class for MA_DS_AuditFailedRegenerateEventHandler
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/04/2023      Chakshu Malhotra        Trigger helper logic for MA_DS_AuditFailedRegenerateEventHandler.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_AuditFailedRegenerateEventHelper {

    private static final String AUDIT_TYPE_PACKAGE = Label.MA_DS_Audit_Type_Package;
    private static final String AUDIT_TYPE_MANAGER_SUMMARY = Label.MA_DS_Audit_Type_Manager_Summary;
    private static final String AUDIT_STATUS_REGEN_ALL_DOCS = Label.MA_DS_Audit_Status_Regen_All_Docs;
    private static final String AUDIT_STATUS_REGEN_TEMPLATE_DOCS = Label.MA_DS_Audit_Status_Regen_Template_Docs;
    private static final String AUDIT_STATUS_REGEN_CONTACTS_DOCS = Label.MA_DS_Audit_Status_Regen_Contacts_Docs;
    private static final String AUDIT_STATUS_REGEN_ALL_CONTACTS_DOCS = Label.MA_DS_Audit_Status_Regen_All_Contacts_Docs;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the singleton instance of the MA_DS_AuditFailedRegenerateEventHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final MA_DS_AuditFailedRegenerateEventHelper helperInstance {
        get {
            if(helperInstance == null) {
                helperInstance = new MA_DS_AuditFailedRegenerateEventHelper();
            }
            return helperInstance;
        }private set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Private default constructor of the MA_DS_AuditFailedRegenerateEventHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private MA_DS_AuditFailedRegenerateEventHelper() {
        // to enforce singleton design
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle the Audit failure to regenerate Manager Summary / Package for the Failed Common Id Map.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	    DESCRIPTION (Data type MA_DS_Audit_Failed_Regenerate_Event__e, The new Audit Failed Regenerate Event record)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handleAuditFailureToRegenerate(MA_DS_Audit_Failed_Regenerate_Event__e newRec) {
        Map<String, List<String>> failedCommonIdMap = (Map<String, List<String>>)JSON.deserialize(newRec.MA_DS_Failed_Common_Id__c, Map<String, List<String>>.class);

        if(newRec.MA_DS_Audit_Type__c.equalsIgnoreCase(AUDIT_TYPE_MANAGER_SUMMARY)) {
            handleAuditFailureToRegenerateSummary(newRec.MA_DS_Audit_Status__c, failedCommonIdMap);
        }else if(newRec.MA_DS_Audit_Type__c.equalsIgnoreCase(AUDIT_TYPE_PACKAGE)) {
            handleAuditFailureToRegeneratePackage(newRec.MA_DS_Audit_Status__c, failedCommonIdMap);
        }
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle the Audit failure to regenerate Manager Summary Document (Manager Summary Prep API Callout) for the Failed Common Id Map.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    auditStatus	            DESCRIPTION (Data Type String, Audit regen status value)
    * @param    failedCommonIdMap	    DESCRIPTION (Data Type Map<String, List<String>>, Map of Manager Summary Common Id to List of Offer Communicator Ids)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void handleAuditFailureToRegenerateSummary(String auditStatus, Map<String, List<String>> failedCommonIdMap) {
        if(failedCommonIdMap.size() > 0) {
            String commonId = new List<String>(failedCommonIdMap.keySet())?.get(0);
            Set<String> offerCommunicatorIds = auditStatus.equalsIgnoreCase(AUDIT_STATUS_REGEN_ALL_CONTACTS_DOCS) ? new Set<String>(failedCommonIdMap.get(commonId)) : null;
            initAuditFailureHandlerService(failedCommonIdMap.keySet(), offerCommunicatorIds, null, null, MA_DS_FailureHandlerService.Failure.SUMMARY_AUDIT);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute FailureHandlerJob to handle Manager Summary / Package Audit Regen failure.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonIds	                    DESCRIPTION (Data Type Set<String>, Set of Manager Summary / Package Common Ids)
    * @param    acqContactIds 	   	            DESCRIPTION (Data type Set<String>, Set of Failed Offer Communicator / Package Acquisition Contact Ids)
    * @param    templateIds 	   	            DESCRIPTION (Data type Set<String>, Set of Failed Package Template Ids)
    * @param    appliedRuleIds 	   	            DESCRIPTION (Data type Set<String>, Set of Failed Applied Rule Ids)
    * @param    failureType	                    DESCRIPTION (Data Type MA_DS_FailureHandlerService.Failure, Failure type for Summaries / Packages)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initAuditFailureHandlerService(Set<String> commonIds, Set<String> acqContactIds, Set<String> templateIds, Set<String> appliedRuleIds, MA_DS_FailureHandlerService.Failure failureType) {
        MA_DS_FailureHandlerService.strategyInstance.setCommonIds(commonIds)
                                                    .setAcqContactIds(acqContactIds)
                                                    .setTemplateIds(templateIds)
                                                    .setAppliedRuleIds(appliedRuleIds)
                                                    .setFailureType(failureType)
                                                    .initHandlerService()
                                                    .initFailureHandlerJob()
                                                    .execute();
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle the Audit failure to regenerate Package Documents (Package Prep API Callout) for the Failed Common Id Map.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    auditStatus	            DESCRIPTION (Data Type Id, Audit regen status value)
    * @param    failedCommonIdMap	    DESCRIPTION (Data Type Map<String, List<String>>, Map of Package Common Id to List of Acquisition Contact Ids / Template record Ids / Applied Rule Ids)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void handleAuditFailureToRegeneratePackage(String auditStatus, Map<String, List<String>> failedCommonIdMap) {
        if(failedCommonIdMap.size() > 0) {
            String commonId = new List<String>(failedCommonIdMap.keySet())?.get(0);
            Set<String> failedIds = new Set<String>(failedCommonIdMap.get(commonId));
            Set<String> templateIds = auditStatus.equalsIgnoreCase(AUDIT_STATUS_REGEN_TEMPLATE_DOCS) ? failedIds : null;
            Set<String> appliedRuleIds = auditStatus.equalsIgnoreCase(AUDIT_STATUS_REGEN_CONTACTS_DOCS) ? failedIds : null;
            Set<String> acqContactIds = auditStatus.equalsIgnoreCase(AUDIT_STATUS_REGEN_ALL_CONTACTS_DOCS) ? failedIds : null;
            initAuditFailureHandlerService(failedCommonIdMap.keySet(), acqContactIds, templateIds, appliedRuleIds, MA_DS_FailureHandlerService.Failure.PACKAGE_AUDIT);
        }
    }
}