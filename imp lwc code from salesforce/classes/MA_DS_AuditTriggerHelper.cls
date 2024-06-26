/**
 * W-12578116
 * Trigger helper class for MA_DS_AuditTriggerHandler
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         01/04/2023      Chakshu Malhotra        Trigger helper logic for MA_DS_AuditTriggerHandler.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_AuditTriggerHelper {

    private static final String AUDIT_TYPE_PACKAGE = Label.MA_DS_Audit_Type_Package;
    private static final String AUDIT_TYPE_MANAGER_SUMMARY = Label.MA_DS_Audit_Type_Manager_Summary;
    private static final String ELIGIBLE_AUDIT_REGEN_STATUS = Label.MA_DS_Audit_Regen_Eligible_Status;
    private static final String FAILED_COMMON_ID_PARSE_EXCEPTION = Label.MA_DS_Failed_Common_Id_Parse_Exception;
    private static final Integer MAX_FAILED_REGEN_ATTEMPT_COUNT = Integer.valueOf(Label.MA_DS_Max_Failed_Regen_Attempt_Count);

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the singleton instance of the MA_DS_AuditTriggerHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final MA_DS_AuditTriggerHelper helperInstance {
        get {
            if(helperInstance == null) {
                helperInstance = new MA_DS_AuditTriggerHelper();
            }
            return helperInstance;
        }private set;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the Set of Audit Status values that makes it eligible to re-generate Summary / Package based on details in Failed Common Id.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<String> auditRegenStatusSet {
        get {
            if(auditRegenStatusSet == null) {
                auditRegenStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_AUDIT_REGEN_STATUS, List<String>.class));
            }
            return auditRegenStatusSet;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Private default constructor of the MA_DS_AuditTriggerHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private MA_DS_AuditTriggerHelper() {
        // to enforce singleton design
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Offer Communicators and/or Package Distribution record and to denote Failure during Summary Audit phase.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Audit__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_Audit__c>, Trigger.oldMap of Audit records)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handleFailedCommonIdUpdate(List<MA_DS_Audit__c> newRecords, Map<Id, MA_DS_Audit__c> oldMap) {        
        for(MA_DS_Audit__c newRec : newRecords) {
            if(isAuditFailedRegen(newRec, oldMap.get(newRec.Id))) {
                Map<String, List<String>> failedCommonIdMap = getFailedCommonIdMap(newRec.Id, newRec.MA_DS_Failed_Common_Id__c);

                if(newRec.MA_DS_Audit_Type__c.equalsIgnoreCase(AUDIT_TYPE_MANAGER_SUMMARY) && failedCommonIdMap.size() > 0) {
                    prepareManagerSummaries(newRec, failedCommonIdMap);
                }else if(newRec.MA_DS_Audit_Type__c.equalsIgnoreCase(AUDIT_TYPE_PACKAGE) && failedCommonIdMap.size() > 0) {
                    preparePackages(newRec, failedCommonIdMap);
                }
            }
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Manager Summary Common Id need to be processed for handling failure during Summary Audit process.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_Audit__c, The new Audit record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_Audit__c, The old Audit record)
    * @return   Boolean     DESCRIPTION (return True if Status / Failed Common Id is updated to regenerate the Manager Summary Prep)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isAuditFailedRegen(MA_DS_Audit__c newRec, MA_DS_Audit__c oldRec) {
        return newRec.MA_DS_Status__c != oldRec.MA_DS_Status__c && auditRegenStatusSet.contains(newRec.MA_DS_Status__c) && newRec.MA_DS_Failed_Common_Id__c != null;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update failedCommonIds to denote failure on Package Distribution during Summary / Package Audit process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    auditId 	   	            DESCRIPTION (Data type Id, Audit record Id)
    * @param    failedCommonIdStr           DESCRIPTION (Data type String, Failed Common Id from Audit record)
    * @return   Map<String, List<String>>   DESCRIPTION (return Map of Manager Summary to List of Offer Communicator Ids or Package Common Id to List of Template Ids)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, List<String>> getFailedCommonIdMap(Id auditId, String failedCommonIdStr) {
        Map<String, List<String>> failedCommonIdMap = new Map<String, List<String>>();

        try {
            failedCommonIdMap = (Map<String, List<String>>)JSON.deserialize(failedCommonIdStr, Map<String, List<String>>.class);
        }catch(Exception exType) {
            List<String> exceptionMsgParams = new List<String> {String.valueOf(auditId)};
            MA_AbstractLogger.logException(new MA_DS_FailedCommonIdParseException(exceptionMsgParams), MA_DS_FailedCommonIdParseException.class.getName());
        }

        return failedCommonIdMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to auto-initiate the processing of Manager Summaries Prep for Failed Common Id / Offer Communicator Ids and return Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	            DESCRIPTION (Data type MA_DS_Audit__c, The new Audit record)
    * @param    failedCommonIdMap	    DESCRIPTION (Data Type Map<String, List<String>>, Map of Manager Summary Common Id to List of Offer Communicator Ids)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void prepareManagerSummaries(MA_DS_Audit__c newRec, Map<String, List<String>> failedCommonIdMap) {
        try {
            MA_DS_ManagerSummariesPrepHelper.prepareManagerSummaries(newRec.MA_DS_Acquisition_Company__c, failedCommonIdMap, newRec.MA_DS_Status__c);
        }catch(Exception exType) {
            handleFailedCommonIdParseException(newRec, exType);
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to handle exception while parsing Failed Common Id. Error is added back on the trigger and CLM would attempt regen for 4 times if exception persists.
    * After 4th attempt, an Event is published with Failure details to denote the Applied Rule records as "Need To Generate".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	            DESCRIPTION (Data type MA_DS_Audit__c, The new Audit record)
    * @param    exType	                DESCRIPTION (Data Type Exception, Exception while parsing Failed Common Id)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void handleFailedCommonIdParseException(MA_DS_Audit__c newRec, Exception exType) {
        if(Integer.valueOf(newRec.MA_DS_Failed_Regenerate_Attempt_Count__c) == MAX_FAILED_REGEN_ATTEMPT_COUNT) {
            EventBus.publish(getAuditFailedRegenerateEvent(newRec));
        }
        newRec.addError(exType);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to auto-initiate the processing of Package Prep for Failed Common Id / Template Ids and return Processing Status Message.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	            DESCRIPTION (Data type MA_DS_Audit__c, The new Audit record)
    * @param    failedCommonIdMap	    DESCRIPTION (Data Type Map<String, List<String>>, Map of Package Common Id to List of Template Ids)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void preparePackages(MA_DS_Audit__c newRec, Map<String, List<String>> failedCommonIdMap) {
        try {
            MA_DS_PackagePrepHelper.preparePackages(newRec.MA_DS_Acquisition_Company__c, failedCommonIdMap, newRec.MA_DS_Status__c);
        }catch(Exception exType) {
            handleFailedCommonIdParseException(newRec, exType);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & return Audit Failed Regenrate Event type, to handle exception while processing Failed Common Id.
    * Event is published immediately to flag the required Package Distributions to regenerate Manager Summaries manually.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	                                DESCRIPTION (Data type MA_DS_Audit__c, The new Audit record)
    * @return   MA_DS_Audit_Failed_Regenerate_Event__e      DESCRIPTION (return Audit Failed Regenrate Event type)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static MA_DS_Audit_Failed_Regenerate_Event__e getAuditFailedRegenerateEvent(MA_DS_Audit__c newRec) {
        MA_DS_Audit_Failed_Regenerate_Event__e auditFailedRegenEvent = new MA_DS_Audit_Failed_Regenerate_Event__e();
        auditFailedRegenEvent.MA_DS_Audit_Id__c = newRec.Id;
        auditFailedRegenEvent.MA_DS_Audit_Status__c = newRec.MA_DS_Status__c;
        auditFailedRegenEvent.MA_DS_Audit_Type__c = newRec.MA_DS_Audit_Type__c;
        auditFailedRegenEvent.MA_DS_Failed_Common_Id__c = newRec.MA_DS_Failed_Common_Id__c;
        auditFailedRegenEvent.MA_DS_Acquisition_Company_Id__c = newRec.MA_DS_Acquisition_Company__c;
        return auditFailedRegenEvent;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to log Error in the PF Debug Log sObject to denote exception while parsing JSON structured Failed Offer Communicator Ids.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MA_DS_FailedCommonIdParseException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the MA_DS_FailedCommonIdParseException class.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public MA_DS_FailedCommonIdParseException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = new List<String> {MA_DS_AuditTriggerHelper.MA_DS_FailedCommonIdParseException.class.getName()};
            this.exceptionMsgParams.addAll(exceptionMsgParams);
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(FAILED_COMMON_ID_PARSE_EXCEPTION, exceptionMsgParams);
        }
    }
}