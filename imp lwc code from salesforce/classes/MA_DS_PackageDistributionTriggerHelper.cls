/**
 * W-12612799
 * Trigger helper class for MA_DS_PackageDistributionTriggerHandler
 * 
 * Version      Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         12/03/2023      Chakshu Malhotra        Trigger helper logic for MA_DS_PackageDistributionTriggerHandler.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_DS_PackageDistributionTriggerHelper {

    private static final String ELIGIBLE_SUMMARY_SYNC_STATUS = Label.MA_DS_Eligible_Package_Status_For_Rules_Update;
    
    private static final String SYNCING_PACKAGE_RULES_STATUS = Label.MA_DS_Syncing_Package_Rules_Status;
    private static final String SYNCING_TEMPLATE_RULES_STATUS = Label.MA_DS_Syncing_Templates_Rules_Status;
    private static final String NEED_SYNC_TEMPLATE_RULES_STATUS = Label.MA_DS_Need_Sync_Template_Rules_Status;
    private static final String NEED_SYNC_PACKAGE_TEMPLATE_RULES_STATUS = Label.MA_DS_Need_Sync_Package_Template_Rules_Status;

    private static final String PD_STATUS_EXCEPTION_MESSAGE = Label.MA_DS_Ineligible_PD_Status_Exception_Message;
    private static final String RULES_SYNC_STATUS_EXCEPTION_MESSAGE = Label.MA_DS_Ineligible_Rules_Sync_Status_Exception_Message;

    private static final String RULES_CRITERIA_STR = Label.MA_DS_Rules_Criteria_String;
    private static final String SUMMARY_REQUIRED_STR = Label.MA_DS_Summary_Required_String;

    private static final String RULES_SYNCED_STATUS = Label.MA_DS_Rules_Synced_Status;
    private static final String DOCUMENT_TYPE_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;

    private static final String STATUS_PACKAGE_RECALLED = Label.MA_DS_PD_Status_Recalled;
    private static final String STATUS_SUMMARY_PARTIAL_DELIVERY = Label.MA_DS_Summary_Partial_Delivery;
    private static final String STATUS_PACKAGE_PARTIAL_DELIVERY = Label.MA_DS_Package_Partial_Delivery;
    
    private static final String SCHEDULED_DELIVERY_DATETIME_FORMAT = Label.MA_DS_Scheduled_Delivery_Datetime_Format;

    private static final String STATUS_FAILED_GEN_ALL_SUMMARIES = Label.MA_DS_PD_Status_Failed_All_Summaries_Generation;
    private static final String STATUS_FAILED_GEN_ALL_PACKAGES = Label.MA_DS_PD_Status_Failed_All_Package_Docs_Generation;
    private static final String FAILED_OFFER_COMM_IDS_EXCEPTION = Label.MA_DS_Failed_Offer_Comm_Ids_Parse_Exception;
    private static final String FAILED_ACQ_CONTACT_IDS_EXCEPTION = Label.MA_DS_Failed_Acq_Contact_Ids_Parse_Exception;
    private static final String FAILED_PKG_COMMON_ID_EXCEPTION = Label.MA_DS_Failed_Package_Common_Id_Parse_Exception;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the singleton instance of the MA_DS_PackageDistributionTriggerHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static final MA_DS_PackageDistributionTriggerHelper helperInstance {
        get {
            if(helperInstance == null) {
                helperInstance = new MA_DS_PackageDistributionTriggerHelper();
            }
            return helperInstance;
        }private set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Private default constructor of the MA_DS_PackageDistributionTriggerHelper class.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private MA_DS_PackageDistributionTriggerHelper() {
        // to enforce singleton design
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the Set of Rules Syncing status when Package or Template Rules are syncing.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<String> rulesSyncingStatus {
        get {
            if(rulesSyncingStatus == null) {
                rulesSyncingStatus = new Set<String> {SYNCING_PACKAGE_RULES_STATUS.toLowerCase(), SYNCING_TEMPLATE_RULES_STATUS.toLowerCase()};
            }
            return rulesSyncingStatus;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of eligible Status values of the Package Distribution for updating the Rule Criteria.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<String> summarySyncStatusSet {
        get {
            if(summarySyncStatusSet == null) {
                summarySyncStatusSet = new Set<String>((List<String>)JSON.deserialize(ELIGIBLE_SUMMARY_SYNC_STATUS, List<String>.class));
            }
            return summarySyncStatusSet;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the set of Package reference of the Package Distribution records.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<Id> packageIds {
        get {
            if(packageIds == null) {
                packageIds = new Set<Id>();
                for(MA_DS_Package_Distribution__c newRec : (List<MA_DS_Package_Distribution__c>)Trigger.new) {
                    packageIds.add(newRec.MA_DS_Package__c);
                }
            }
            return packageIds;
        }set;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the map of Package Id to the manager summary In Use Template record.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<Id, MA_DS_In_Use_Template__c> summaryTemplateMap {
        get {
            if(summaryTemplateMap == null) {
                summaryTemplateMap = new Map<Id, MA_DS_In_Use_Template__c>();
                for(MA_DS_In_Use_Template__c inUseTemplate : [SELECT Id, MA_DS_Package_Using__c, MA_DS_Sync_Rules_On_PD_Ids__c 
                                                              FROM MA_DS_In_Use_Template__c 
                                                              WHERE MA_DS_Package_Using__c IN :packageIds AND
                                                              MA_DS_Template_Being_Used__r.MA_DS_Template_Document_Type__c = :DOCUMENT_TYPE_SUMMARY]) {
                    summaryTemplateMap.put(inUseTemplate.MA_DS_Package_Using__c, inUseTemplate);
                }
            }
            return summaryTemplateMap;
        }set;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the map of Package Id to the set of Package Distribution Ids that require resycning of manager summary template rules.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Map<Id, Set<String>> pkgIdToNeedSyncPDIdsMap {
        get {
            if(pkgIdToNeedSyncPDIdsMap == null) {
                pkgIdToNeedSyncPDIdsMap = new Map<Id, Set<String>>();
            }
            return pkgIdToNeedSyncPDIdsMap;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the Rule Sync Status of the Package Distribution if the Rule Criteria Query is updated.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updateRuleSyncStatus(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        if(newRec.MA_DS_Rules_Criteria_Query__c != oldRec.MA_DS_Rules_Criteria_Query__c) {
            updateRuleSyncStatus(newRec, true);
        }else if(newRec.MA_DS_Summary_Required__c != oldRec.MA_DS_Summary_Required__c) {
            updateRuleSyncStatus(newRec, false);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks updates the Rule Sync Status of the Package Distribution based on its current value.
    * Method throws MA_DS_IneligiblePackageDistributionStatusException if the update is not allowed for current value of Status.
    * Method throws MA_DS_IneligibleRulesSyncStatusException if Package / Templates rules are currently syncing.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private void updateRuleSyncStatus(MA_DS_Package_Distribution__c newRec, Boolean rulesUpdate) {
        String exceptionFieldStr = rulesUpdate ? RULES_CRITERIA_STR : SUMMARY_REQUIRED_STR;

        if(!summarySyncStatusSet.contains(newRec.MA_DS_Status__c)) {
            newRec.addError(new MA_DS_IneligiblePackageDistributionStatusException(new String[] {MA_DS_IneligiblePackageDistributionStatusException.class.getName(), exceptionFieldStr, newRec.MA_DS_Status__c}));
        }else if(rulesSyncingStatus.contains(newRec.MA_DS_Rules_Sync_Status__c.toLowerCase())) {
            newRec.addError(new MA_DS_IneligibleRulesSyncStatusException(new String[] {MA_DS_IneligibleRulesSyncStatusException.class.getName(), exceptionFieldStr, newRec.MA_DS_Rules_Sync_Status__c}));
        }else {
            newRec.MA_DS_Rules_Sync_Status__c = rulesUpdate ? NEED_SYNC_PACKAGE_TEMPLATE_RULES_STATUS : getRulesSyncStatusForSummaryRequiredUpdate(newRec);
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Rules Sync Status value if Summary Required field is updated.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String getRulesSyncStatusForSummaryRequiredUpdate(MA_DS_Package_Distribution__c newRec) {
        Id packageId = newRec.MA_DS_Package__c;
        Boolean rulesSyncedStatus = newRec.MA_DS_Rules_Sync_Status__c.equalsIgnoreCase(RULES_SYNCED_STATUS);

        Boolean containsPackageIdKey = summaryTemplateMap.containsKey(packageId);

        if(containsPackageIdKey) {
            Set<String> pdIds = pkgIdToNeedSyncPDIdsMap.containsKey(packageId) ? pkgIdToNeedSyncPDIdsMap.get(packageId) : new Set<String>();
            pdIds.add(String.valueOf(newRec.Id));
            pkgIdToNeedSyncPDIdsMap.put(packageId, pdIds);
        }

        return (containsPackageIdKey && rulesSyncedStatus) ? NEED_SYNC_TEMPLATE_RULES_STATUS : newRec.MA_DS_Rules_Sync_Status__c;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the "Summary Delivery Datetime GMT" / "Package Delivery Datetime GMT" field(s) based on the Scheduled Flag / Scheduled Date / Time or Time Zone.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updateDeliverySchedule(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        if(isSummaryDeliveryScheduleUpdated(newRec, oldRec)) {
            updateSummaryDeliverySchedule(newRec, newRec.MA_DS_Schedule_Summary_Delivery__c);
        }
        if(isPackageDeliveryScheduleUpdated(newRec, oldRec)) {
            updatePackageDeliverySchedule(newRec, newRec.MA_DS_Schedule_Package_Delivery__c);
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if the Summary Delivery Schedule (Schedule Flag / Date / Time / Time Zone) is updated.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   Boolean         DESCRIPTION (return True if Package Distribution record is eligible to update the Summary Schedule details)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isSummaryDeliveryScheduleUpdated(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        return newRec.MA_DS_Schedule_Summary_Delivery__c != oldRec.MA_DS_Schedule_Summary_Delivery__c || 
               newRec.MA_DS_Summary_Delivery_Date__c != oldRec.MA_DS_Summary_Delivery_Date__c || 
               newRec.MA_DS_Summary_Delivery_Time__c != oldRec.MA_DS_Summary_Delivery_Time__c || 
               newRec.MA_DS_Summary_Delivery_Time_Zone__c != oldRec.MA_DS_Summary_Delivery_Time_Zone__c;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the "Summary Delivery Datetime GMT" field based on the update on Schedule Flag / Scheduled Date / Time or Time Zone.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateSummaryDeliverySchedule(MA_DS_Package_Distribution__c newRec, Boolean scheduled) {
        if(scheduled && newRec.MA_DS_Summary_Delivery_Date__c != null && newRec.MA_DS_Summary_Delivery_Time__c != null && newRec.MA_DS_Summary_Delivery_Time_Zone__c != null) {
            newRec.MA_DS_Summary_Delivery_Datetime_GMT__c = getScheduledDeliveryDatetimeGMT(newRec.MA_DS_Summary_Delivery_Date__c, newRec.MA_DS_Summary_Delivery_Time__c, newRec.MA_DS_Summary_Delivery_Time_Zone__c);
        }else {
            newRec.MA_DS_Summary_Delivery_Date__c = null;
            newRec.MA_DS_Summary_Delivery_Time__c = null;
            newRec.MA_DS_Summary_Delivery_Time_Zone__c = null;
            newRec.MA_DS_Summary_Delivery_Datetime_GMT__c = null;
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method calculates the Scheduled Delivery Date/Time based on the user's input of Scheduled Delivery Date, Time & Time Zone
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    scheduledDate 	   	DESCRIPTION (Data type Date, The Scheduled Delivery Date)
    * @param    scheduledTime 	   	DESCRIPTION (Data type Time, The Scheduled Delivery Time)
    * @param    timeZoneStr 	    DESCRIPTION (Data type String, The Time Zone for the Scheduled Delivery)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Datetime getScheduledDeliveryDatetimeGMT(Date scheduledDate, Time scheduledTime, String timeZoneStr) {
        Datetime scheduledDatetimeGMT = Datetime.newInstanceGmt(scheduledDate, scheduledTime);
        Integer timeZoneOffset = (TimeZone.getTimeZone(timeZoneStr).getOffset(scheduledDatetimeGMT)) / 1000;
        return scheduledDatetimeGMT.addSeconds(-timeZoneOffset);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method checks if the Package Delivery Schedule (Schedule Flag / Date / Time / Time Zone) is updated.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   Boolean         DESCRIPTION (return True if Package Distribution record is eligible to update the Package Schedule details)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isPackageDeliveryScheduleUpdated(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        return newRec.MA_DS_Schedule_Package_Delivery__c != oldRec.MA_DS_Schedule_Package_Delivery__c || 
               newRec.MA_DS_Package_Delivery_Date__c != oldRec.MA_DS_Package_Delivery_Date__c || 
               newRec.MA_DS_Package_Delivery_Time__c != oldRec.MA_DS_Package_Delivery_Time__c || 
               newRec.MA_DS_Package_Delivery_Time_Zone__c != oldRec.MA_DS_Package_Delivery_Time_Zone__c;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method updates the "Package Delivery Datetime GMT" field based on the update on Schedule Flag / Scheduled Date / Time or Time Zone.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageDeliverySchedule(MA_DS_Package_Distribution__c newRec, Boolean scheduled) {
        if(scheduled && newRec.MA_DS_Package_Delivery_Date__c != null && newRec.MA_DS_Package_Delivery_Time__c != null && newRec.MA_DS_Package_Delivery_Time_Zone__c != null) {
            newRec.MA_DS_Package_Delivery_Datetime_GMT__c = getScheduledDeliveryDatetimeGMT(newRec.MA_DS_Package_Delivery_Date__c, newRec.MA_DS_Package_Delivery_Time__c, newRec.MA_DS_Package_Delivery_Time_Zone__c);
        }else {
            newRec.MA_DS_Package_Delivery_Date__c = null;
            newRec.MA_DS_Package_Delivery_Time__c = null;
            newRec.MA_DS_Package_Delivery_Time_Zone__c = null;
            newRec.MA_DS_Package_Delivery_Datetime_GMT__c = null;
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update "Sync Rules On PD Ids" on Manager Summary In Use Templates due to update on Summary Required field.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void updateSyncRulesOnPDIds() {
        List<MA_DS_In_Use_Template__c> inUseTemplates = new List<MA_DS_In_Use_Template__c>();

        for(MA_DS_In_Use_Template__c inUseTemplate : summaryTemplateMap.values()) {
            if(pkgIdToNeedSyncPDIdsMap.containsKey(inUseTemplate.MA_DS_Package_Using__c)) {
                String syncRulesOnPDIds = inUseTemplate.MA_DS_Sync_Rules_On_PD_Ids__c;
                Set<String> pdIds = String.isBlank(syncRulesOnPDIds) ? new Set<String>() : getPDIdSet(syncRulesOnPDIds);

                pdIds.addAll(pkgIdToNeedSyncPDIdsMap.get(inUseTemplate.MA_DS_Package_Using__c));
                inUseTemplate.MA_DS_Sync_Rules_On_PD_Ids__c = JSON.serialize(pdIds);
            }
        }

        if(inUseTemplates.size() > 0) {
            MA_DS_InUseTemplateTriggerHandler.triggerDisabled = true;
            Database.SaveResult[] iutSRList = Database.update(inUseTemplates, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(iutSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method deseralizes MA_DS_Sync_Rules_On_PD_Ids__c on In Use Templates into Set of Package Distribution Ids.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    syncRulesOnPDIds 	   	DESCRIPTION (Data type String, The old Package Distribution record)
    * @return   Set<String>             DESCRIPTION (return Set of Package Distribution Ids by de-serializing the string)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private Set<String> getPDIdSet(String syncRulesOnPDIds) {
        return new Set<String>((List<String>)JSON.deserialize(syncRulesOnPDIds, List<String>.class));
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to initiate the processing of Acquisition Contacts and to handle Failure during Summary / Package Prep or Delivery phase.
    * Method to initiate the post-processing logic for Package Distribution Status update.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Package_Distribution__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_Package_Distribution__c>, Trigger.oldMap of Package Distribution records)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handleStatusUpdate(List<MA_DS_Package_Distribution__c> newRecords, Map<Id, MA_DS_Package_Distribution__c> oldMap) {
        Set<String> acqContactIds = new Set<String>();
        Set<String> offerCommunicatorIds = new Set<String>();

        List<String> templateIds = new List<String>();
        Set<String> summaryPrepCommonIds = new Set<String>();
        Set<String> packagePrepCommonIds = new Set<String>();

        Set<Id> pkgPrepDistributionIds = new Set<Id>();
        Set<Id> pkgRecalledDistributionIds = new Set<Id>();
        Set<Id> summaryDeliveryDistributionIds = new Set<Id>();
        Set<Id> packageDeliveryDistributionIds = new Set<Id>();

        for(MA_DS_Package_Distribution__c newRec : newRecords) {
            if(isSummaryPrepFailure(newRec, oldMap.get(newRec.Id))) {
                summaryPrepCommonIds.add(newRec.MA_DS_Manager_Summary_Common_Id__c);
            }else if(isSummaryDeliveryFailure(newRec, oldMap.get(newRec.Id))) {
                updateFailedAcquisitionContactIds(false, newRec.Id, newRec.MA_DS_Failed_Offer_Communicator_Ids__c, offerCommunicatorIds, summaryDeliveryDistributionIds);
            }else if(isPackagePrepFailure(newRec, oldMap.get(newRec.Id))) {
                updateFailedCommonAndTemplateIds(newRec.Id, newRec.MA_DS_Package_Common_Id__c, packagePrepCommonIds, templateIds, pkgPrepDistributionIds);
            }else if(isPackageDeliveryFailure(newRec, oldMap.get(newRec.Id))) {
                updateFailedAcquisitionContactIds(true, newRec.Id, newRec.MA_DS_Failed_Package_Contact_Ids__c, acqContactIds, packageDeliveryDistributionIds);
            }else if(isPackageRecalled(newRec, oldMap.get(newRec.Id))) {
                pkgRecalledDistributionIds.add(newRec.Id);
            }
        }

        if(summaryPrepCommonIds.size() > 0) {
            initSummaryPrepFailureHandlerService(summaryPrepCommonIds, MA_DS_FailureHandlerService.Failure.SUMMARY_PREP);
        }

        if(summaryDeliveryDistributionIds.size() > 0 && offerCommunicatorIds.size() > 0) {
            initDeliveryFailureHandlerService(summaryDeliveryDistributionIds, offerCommunicatorIds, MA_DS_FailureHandlerService.Failure.SUMMARY_DELIVERY);
        }

        if(packagePrepCommonIds.size() > 0) {
            initPackagePrepFailureHandlerService(pkgPrepDistributionIds, packagePrepCommonIds, new Set<String>(templateIds), MA_DS_FailureHandlerService.Failure.PACKAGE_PREP);
        }

        if(packageDeliveryDistributionIds.size() > 0 && acqContactIds.size() > 0) {
            initDeliveryFailureHandlerService(packageDeliveryDistributionIds, acqContactIds, MA_DS_FailureHandlerService.Failure.PACKAGE_DELIVERY);
        }

        if(pkgRecalledDistributionIds.size() > 0) {
            initRecalledPackageStatusHandlerService(pkgRecalledDistributionIds, MA_DS_PackageStatusHandlerService.PackageStatus.RECALLED);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Package Distribution record is eligible for handling failure during Summary Prep process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   Boolean         DESCRIPTION (return True if Package Distribution record is eligible to handle Summary Prep failure)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isSummaryPrepFailure(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        return newRec.MA_DS_Status__c.equalsIgnoreCase(STATUS_FAILED_GEN_ALL_SUMMARIES) && 
               newRec.MA_DS_Manager_Summary_Common_Id__c != oldRec.MA_DS_Manager_Summary_Common_Id__c && 
               newRec.MA_DS_Manager_Summary_Common_Id__c != null;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Package Distribution record is eligible for handling failure during Package Prep process.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   Boolean         DESCRIPTION (return True if Package Distribution record is eligible to handle Package Prep failure)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isPackagePrepFailure(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        return newRec.MA_DS_Status__c.equalsIgnoreCase(STATUS_FAILED_GEN_ALL_PACKAGES) && 
               newRec.MA_DS_Package_Common_Id__c != oldRec.MA_DS_Package_Common_Id__c && 
               newRec.MA_DS_Package_Common_Id__c != null;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Package Distribution record is eligible for handling failure during Summary Delivery process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   Boolean         DESCRIPTION (return True if Package Distribution record is eligible to handle Summary Delivery failure)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isSummaryDeliveryFailure(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        return newRec.MA_DS_Status__c.equalsIgnoreCase(STATUS_SUMMARY_PARTIAL_DELIVERY) && 
               newRec.MA_DS_Failed_Offer_Communicator_Ids__c != oldRec.MA_DS_Failed_Offer_Communicator_Ids__c && 
               newRec.MA_DS_Failed_Offer_Communicator_Ids__c != null;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Package Distribution record is eligible for handling failure during Package Delivery process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   Boolean         DESCRIPTION (return True if Package Distribution record is eligible to handle Package Delivery failure)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isPackageDeliveryFailure(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        return newRec.MA_DS_Status__c.equalsIgnoreCase(STATUS_PACKAGE_PARTIAL_DELIVERY) && 
               newRec.MA_DS_Failed_Package_Contact_Ids__c != oldRec.MA_DS_Failed_Package_Contact_Ids__c && 
               newRec.MA_DS_Failed_Package_Contact_Ids__c != null;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check if Package Distribution record is eligible for handling the post-processing logic for Recalled status update.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The new Package Distribution record)
    * @param    oldRec 	   	    DESCRIPTION (Data type MA_DS_Package_Distribution__c, The old Package Distribution record)
    * @return   Boolean         DESCRIPTION (return True if Package Distribution record is eligible to handle Package Recalled status update)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Boolean isPackageRecalled(MA_DS_Package_Distribution__c newRec, MA_DS_Package_Distribution__c oldRec) {
        return newRec.MA_DS_Status__c != oldRec.MA_DS_Status__c && 
               newRec.MA_DS_Status__c.equalsIgnoreCase(STATUS_PACKAGE_RECALLED);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update acqContactIds to mark Applied Rules as "Need To Deliver", during Summary / Package Delivery process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    failedAcqContacts 	   	        DESCRIPTION (Data type Boolean, True if updating Acquisition Contact Ids during Package Delivery process)
    * @param    pkgDistributionId 	   	        DESCRIPTION (Data type Id, Package Distribution record Id)
    * @param    failedAcqContactIdsStr          DESCRIPTION (Data type String, Failed Offer Communicator Ids / Failed Package Contact Ids from Package Distribution record)
    * @param    acqContactIds                   DESCRIPTION (Data type Set<String>, Set of Failed Offer Communicator Ids / Failed Package Contact Ids to process)
    * @param    pkgDistributionIds              DESCRIPTION (Data type Set<Id>, Set of Failed Package Distribution Ids)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateFailedAcquisitionContactIds(Boolean failedAcqContacts, Id pkgDistributionId, String failedAcqContactIdsStr, Set<String> acqContactIds, Set<Id> pkgDistributionIds) {
        try {
            Set<String> failedAcqContactIds = new Set<String>((List<String>)JSON.deserialize(failedAcqContactIdsStr, List<String>.class));
            acqContactIds.addAll(failedAcqContactIds);
            pkgDistributionIds.add(pkgDistributionId);
        }catch(Exception exType) {
            List<String> exceptionMsgParams = new List<String> {String.valueOf(pkgDistributionId)};
            MA_AbstractLogger.logException(new MA_DS_FailedIdsParseException(failedAcqContacts ? FAILED_ACQ_CONTACT_IDS_EXCEPTION : FAILED_OFFER_COMM_IDS_EXCEPTION, exceptionMsgParams), MA_DS_FailedIdsParseException.class.getName());
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update acqContactIds to mark Applied Rules as "Need To Deliver", during Summary / Package Delivery process.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionId 	   	        DESCRIPTION (Data type Id, Package Distribution record Id)
    * @param    pkgCommonIdStr                  DESCRIPTION (Data type String, Package Common Id string from Package Distribution record)
    * @param    pkgPrepCommonIds                DESCRIPTION (Data type Set<String>, Set of Common Ids to be processed for failure during Package Prep)
    * @param    templateIds                     DESCRIPTION (Data type List<String>, Set of Template Ids to be processed for failure during Package Prep)
    * @param    pkgDistributionIds              DESCRIPTION (Data type Set<Id>, Set of Failed Package Distribution Ids)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateFailedCommonAndTemplateIds(Id pkgDistributionId, String pkgCommonIdStr, Set<String> pkgPrepCommonIds, List<String> templateIds, Set<Id> pkgDistributionIds) {
        Map<String, List<String>> pkgCommonIdMap = new Map<String, List<String>>();

        try {
            pkgCommonIdMap = (Map<String, List<String>>)JSON.deserialize(pkgCommonIdStr, Map<String, List<String>>.class);
            String commonId = new List<String>(pkgCommonIdMap.keySet())?.get(0);
            pkgPrepCommonIds.add(commonId);
            pkgDistributionIds.add(pkgDistributionId);
            templateIds.addAll(pkgCommonIdMap.get(commonId));
        }catch(Exception exType) {
            List<String> exceptionMsgParams = new List<String> {String.valueOf(pkgDistributionId)};
            MA_AbstractLogger.logException(new MA_DS_FailedIdsParseException(FAILED_PKG_COMMON_ID_EXCEPTION, exceptionMsgParams), MA_DS_FailedIdsParseException.class.getName());
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute FailureHandlerJob to handle Manager Summary Prep failure.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonIds	                    DESCRIPTION (Data Type Set<String>, Set of Manager Summary Common Id)
    * @param    failureType	                    DESCRIPTION (Data Type MA_DS_FailureHandlerService.Failure, Failure type for Summaries)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initSummaryPrepFailureHandlerService(Set<String> commonIds, MA_DS_FailureHandlerService.Failure failureType) {
        MA_DS_FailureHandlerService.strategyInstance.setCommonIds(commonIds)
                                                    .setFailureType(failureType)
                                                    .initHandlerService()
                                                    .initFailureHandlerJob()
                                                    .execute();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute FailureHandlerJob to handle Package Prep failure.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @param    commonIds	                    DESCRIPTION (Data Type Set<String>, Set of Package Common Ids)
    * @param    templateIds	                    DESCRIPTION (Data Type Set<String>, Set of Template Ids)
    * @param    failureType	                    DESCRIPTION (Data Type MA_DS_FailureHandlerService.Failure, Failure type for Packages)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initPackagePrepFailureHandlerService(Set<Id> pkgDistributionIds, Set<String> commonIds, Set<String> templateIds, MA_DS_FailureHandlerService.Failure failureType) {
        MA_DS_FailureHandlerService.strategyInstance.setCommonIds(commonIds)
                                                    .setPkgDistributionIds(pkgDistributionIds)
                                                    .setTemplateIds(templateIds)
                                                    .setFailureType(failureType)
                                                    .initHandlerService()
                                                    .initFailureHandlerJob()
                                                    .execute();
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute FailureHandlerJob to handle Manager Summary / Package Delivery failure.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids)
    * @param    acqContactIds 	   	            DESCRIPTION (Data type Set<String>, Set of Failed Offer Communicator / Package Acquisition Contact Ids)
    * @param    failureType	                    DESCRIPTION (Data Type MA_DS_FailureHandlerService.Failure, Failure type for Summaries / Packages)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initDeliveryFailureHandlerService(Set<Id> pkgDistributionIds, Set<String> acqContactIds, MA_DS_FailureHandlerService.Failure failureType) {
        MA_DS_FailureHandlerService.strategyInstance.setPkgDistributionIds(pkgDistributionIds)
                                                    .setAcqContactIds(acqContactIds)
                                                    .setFailureType(failureType)
                                                    .initHandlerService()
                                                    .initFailureHandlerJob()
                                                    .execute();
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute PackageStatusHandlerJob to handle post-processing logic for Recalled status update.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<String>, Set of Package Distribution Ids)
    * @param    packageStatusType	            DESCRIPTION (Data Type MA_DS_PackageStatusHandlerService.PackageStatus, PackageStatus type for Recalled update)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void initRecalledPackageStatusHandlerService(Set<Id> pkgDistributionIds, MA_DS_PackageStatusHandlerService.PackageStatus packageStatusType) {
        MA_DS_PackageStatusHandlerService.strategyInstance.setPkgDistributionIds(pkgDistributionIds)
                                                          .setPackageStatusType(packageStatusType)
                                                          .initHandlerService()
                                                          .initPackageStatusHandlerJob()
                                                          .execute();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method handles the update on "Summary Delivery Datetime GMT" / "Package Delivery Datetime GMT" field(s), sends schedule updates to Docusign CLM via API callout.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Package_Distribution__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_Package_Distribution__c>, Trigger.oldMap of Package Distribution records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handleDeliveryScheduleUpdate(List<MA_DS_Package_Distribution__c> newRecords, Map<Id, MA_DS_Package_Distribution__c> oldMap) {
        Set<Id> unscheduledSummaryDeliveryPDIds = new Set<Id> ();
        Set<Id> unscheduledPackageDeliveryPDIds = new Set<Id> ();

        Map<Id, String> scheduledSummaryDeliveryMap = new Map<Id, String>();
        Map<Id, String> scheduledPackageDeliveryMap = new Map<Id, String>();

        for(MA_DS_Package_Distribution__c newRec : newRecords) {
            MA_DS_Package_Distribution__c oldRec = oldMap.get(newRec.Id);

            Boolean updatedSummaryDeliverySchedule = (newRec.MA_DS_Summary_Delivery_Datetime_GMT__c != oldRec.MA_DS_Summary_Delivery_Datetime_GMT__c);
            Boolean updatedPackageDeliverySchedule = (newRec.MA_DS_Package_Delivery_Datetime_GMT__c != oldRec.MA_DS_Package_Delivery_Datetime_GMT__c);

            if(updatedSummaryDeliverySchedule && newRec.MA_DS_Schedule_Summary_Delivery__c) {
                scheduledSummaryDeliveryMap.put(newRec.Id, newRec.MA_DS_Summary_Delivery_Datetime_GMT__c.formatGmt(SCHEDULED_DELIVERY_DATETIME_FORMAT));
            }else if(updatedPackageDeliverySchedule && newRec.MA_DS_Schedule_Package_Delivery__c) {
                scheduledPackageDeliveryMap.put(newRec.Id, newRec.MA_DS_Package_Delivery_Datetime_GMT__c.formatGmt(SCHEDULED_DELIVERY_DATETIME_FORMAT));
            }else if(updatedSummaryDeliverySchedule) {
                unscheduledSummaryDeliveryPDIds.add(newRec.Id);
            }else if(updatedPackageDeliverySchedule) {
                unscheduledPackageDeliveryPDIds.add(newRec.Id);
            }   
        }

        if(unscheduledSummaryDeliveryPDIds.size() > 0 || unscheduledPackageDeliveryPDIds.size() > 0 || scheduledSummaryDeliveryMap.size() > 0 || scheduledPackageDeliveryMap.size() > 0) {
            MA_DS_ScheduledDeliveryHelper.initScheduledDelivery(unscheduledSummaryDeliveryPDIds, unscheduledPackageDeliveryPDIds, scheduledSummaryDeliveryMap, scheduledPackageDeliveryMap);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method initializes the scheduled delivery of Manager Summaries / Packages when "Trigger Manager Summary Delivery" / "Trigger Package Delivery" is set by Docusign CLM.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    newRecords 	   	DESCRIPTION (Data type List<MA_DS_Package_Distribution__c>, Trigger.new list)
    * @param    oldMap          DESCRIPTION (Data type Map<Id, MA_DS_Package_Distribution__c>, Trigger.oldMap of Package Distribution records)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void handleInitScheduledDelivery(List<MA_DS_Package_Distribution__c> newRecords, Map<Id, MA_DS_Package_Distribution__c> oldMap) {
        Set<Id> summaryDeliveryDistributionIds = new Set<Id>();
        Set<Id> packageDeliveryDistributionIds = new Set<Id>();

        for(MA_DS_Package_Distribution__c newRec : newRecords) {
            MA_DS_Package_Distribution__c oldRec = oldMap.get(newRec.Id);

            if(newRec.MA_DS_Trigger_Manager_Summary_Delivery__c != oldRec.MA_DS_Trigger_Manager_Summary_Delivery__c && newRec.MA_DS_Trigger_Manager_Summary_Delivery__c) {
                summaryDeliveryDistributionIds.add(newRec.Id);
            }else if(newRec.MA_DS_Trigger_Package_Delivery__c != oldRec.MA_DS_Trigger_Package_Delivery__c && newRec.MA_DS_Trigger_Package_Delivery__c) {
                packageDeliveryDistributionIds.add(newRec.Id);
            }
        }

        try {
            if(summaryDeliveryDistributionIds.size() > 0) {
                MA_DS_ManagerSummariesDeliveryHelper.deliverManagerSummaries(summaryDeliveryDistributionIds);
            }
            if(packageDeliveryDistributionIds.size() > 0) {
                MA_DS_PackageDeliveryHelper.deliverPackages(packageDeliveryDistributionIds);
            }
        }catch(Exception exType) {
            MA_AbstractLogger.logException(exType, MA_DS_ScheduledDeliveryException.class.getName());
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to addError to the Trigger.new record when Rule Criteria is updated but summarySyncStatusSet doesn't contains Status value.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MA_DS_IneligiblePackageDistributionStatusException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the MA_DS_IneligiblePackageDistributionStatusException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public MA_DS_IneligiblePackageDistributionStatusException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = exceptionMsgParams;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(PD_STATUS_EXCEPTION_MESSAGE, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to addError to the Trigger.new record when Rule Criteria is updated but Rules Sync Status is not valid to allow the update.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MA_DS_IneligibleRulesSyncStatusException extends Exception {
        private List<String> exceptionMsgParams;

        /**
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the MA_DS_IneligibleRulesSyncStatusException class.
        * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public MA_DS_IneligibleRulesSyncStatusException(List<String> exceptionMsgParams) {
            this.exceptionMsgParams = exceptionMsgParams;
        }

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * This method overrides the getMessage() method of the Exception class to return the custom exception message.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
        * @return   void
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public override String getMessage() {
            return String.format(RULES_SYNC_STATUS_EXCEPTION_MESSAGE, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to log Error in the PF Debug Log sObject to denote exception while parsing JSON structured Failed Offer Communicator Ids / Failed Package Contact Ids / Package Common Id.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MA_DS_FailedIdsParseException extends Exception {
        private String exceptionsMsg;
        private List<String> exceptionMsgParams;

        /**
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
        * Parameterized constructor of the MA_DS_FailedIdsParseException class.
        * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
        */
        public MA_DS_FailedIdsParseException(String exceptionsMsg, List<String> exceptionMsgParams) {
            this.exceptionsMsg = exceptionsMsg;
            this.exceptionMsgParams = new List<String> {MA_DS_FailedIdsParseException.class.getName()};
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
            return String.format(exceptionsMsg, exceptionMsgParams);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Custom Exception class to log Error in the PF Debug Log sObject to denote exception while initiating Scheduled Manager Summary / Package Delivery.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public class MA_DS_ScheduledDeliveryException extends Exception {}
}