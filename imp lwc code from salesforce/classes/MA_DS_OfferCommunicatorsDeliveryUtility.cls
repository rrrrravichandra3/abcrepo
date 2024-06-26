/**
 * W-12578130
 * Utility class for SummaryDeliveryJob & SummaryDeliveryJobFinalizer implementations within MA_DS_OfferCommunicatorsDeliveryService.
 * Processes each Package Distribution along with its Offer Communicators & sends it to DocuSign CLM via API callout.
 * Prepares a wrapper instance, to be used by the implementation of MA_DS_CalloutFramework.CalloutRequestParams for the Manager Summary Delivery API callout.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         22/04/2023      Chakshu Malhotra        W-12578130 - Provides utility methods to process Aggregated Applied Rule records to identify Offer Communicators, for Manager Summary Delivery API callout.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_OfferCommunicatorsDeliveryUtility {

    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String IUT_DOCUMENT_TYPE_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;

    private static final String INTEGRATION_STATUS_NONE = Label.MA_DS_Eligible_Integration_Status;

    private static final String MESSAGING_CONFIG = Label.MA_DS_Messaging_Config_Summary_Delivery_Callout;
    private static final String CALLOUT_CONFIG_SUMMARY_DELIVERY = Label.MA_DS_Callout_Config_Manager_Summary_Delivery;

    private static final String CALLOUT_FAILED_NOTIFICATION_BODY = Label.MA_DS_Error_Contact_Admin_Body;
    private static final String CALLOUT_FAILED_NOTIFICATION_TITLE = Label.MA_DS_Summary_Delivery_Callout_Failed_Title;

    private static final String CALLOUT_SUCCESS_NOTIFICATION_BODY = Label.MA_DS_Summary_Delivery_Callout_Notification_Body;
    private static final String CALLOUT_SUCCESS_NOTIFICATION_TITLE = Label.MA_DS_Summary_Delivery_Callout_Notification_Title;
    private static final String SCHEDULED_CALLOUT_SUCCESS_NOTIFICATION_BODY = Label.MA_DS_Scheduled_Summary_Delivery_Callout_Notification_Body;

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to calculate Total Batches for the Manager Summary Delivery API callouts, used in request payload along with details such as Common Id & Current Batch Number.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorMap	                DESCRIPTION (Data Type Map<Id, Acquisition_Contacts__c>, Map of Offer Communicator Id to Offer Communicator record to be processed for the Manager Summary Delivery API)
    * @param    querySizeLimit                          DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the SummaryDeliveryJob)
    * @return   Integer                                 DESCRIPTION (return Total batches used to send Manager Summary Delivery payloads)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Integer getTotalBatches(Map<Id, List<Id>> offerCommunicatorMap, Integer querySizeLimit) {
        Integer totalBatches = 0;

        for(Id pkgDistributionId : offerCommunicatorMap.keySet()) {
            Integer totalOfferCommunicators = offerCommunicatorMap.get(pkgDistributionId).size();
            totalBatches += Integer.valueOf(Math.ceil(Double.valueOf(totalOfferCommunicators) / Double.valueOf(querySizeLimit)));
        }
        
        return totalBatches;
    }
    
    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Offer Communicator Id to Offer Communicator record (with Preferred Email Address & "Custom Manager Summary Email" flag) for the given List of offerCommunicatorIds.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorIds	                DESCRIPTION (Data Type List<Id>, List of Offer Communicator Ids)
    * @param    startIndex	                            DESCRIPTION (Data Type Integer, Start Index of offerCommunicatorIds List to fetch Offer Communicators with querySizeLimit)
    * @param    querySizeLimit                          DESCRIPTION (Data Type Integer, Maximum number of records allowed to fetch for the SummaryDeliveryJob)
    * @return   Map<Id, Acquisition_Contacts__c>        DESCRIPTION (return Map of Offer Communicator Id => Offer Communicator record)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, Acquisition_Contacts__c> getOfferCommunicators(List<Id> offerCommunicatorIds, Integer startIndex, Integer querySizeLimit) {
        Set<Id> offerCommunicatorIdSet = new Set<Id>();
        
        Integer totalOfferCommunicators = offerCommunicatorIds.size();
        Integer lastIndex = ((startIndex + querySizeLimit - 1) < totalOfferCommunicators) ? (startIndex + querySizeLimit - 1) : (totalOfferCommunicators - 1); 
        
        for(Integer offerCommunicatorIndex=startIndex; offerCommunicatorIndex <= lastIndex; offerCommunicatorIndex++) {
            offerCommunicatorIdSet.add(offerCommunicatorIds[offerCommunicatorIndex]);
        }

        return getOfferCommunicators(offerCommunicatorIdSet);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Offer Communicator Id to Offer Communicator record (with Preferred Email Address & "Custom Manager Summary Email" flag) for the given Set of offerCommunicatorIds.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorIds	                DESCRIPTION (Data Type Set<Id>, Set of Offer Communicator Ids)
    * @return   Map<Id, Acquisition_Contacts__c>        DESCRIPTION (return Map of Offer Communicator Id => Offer Communicator record)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, Acquisition_Contacts__c> getOfferCommunicators(Set<Id> offerCommunicatorIds) {
        return new Map<Id, Acquisition_Contacts__c>([SELECT Id, Name, First_Name_Legal__c, Last_Name_Legal__c, First_Name_Preferred__c, Last_Name_Preferred__c, Full_Name_Preferred__c, Employee_ID_Target__c, Additional_Field_1__c, Additional_Field_2__c, Additional_Field_3__c, 
                                                     Additional_Field_4__c, Additional_Field_5__c, MA_DS_Preferred_Email_Address__c, MA_DS_Custom_Manager_Summary_Email__c, 
                                                        (SELECT Id, Additional_Field_1__c, Additional_Field_2__c, Additional_Field_3__c, Additional_Field_4__c, Additional_Field_5__c
                                                         FROM Acquisition_Compensation__r LIMIT 1)
                                                     FROM Acquisition_Contacts__c
                                                     WHERE Id IN :offerCommunicatorIds]);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to prepare the wrapper instance of ManagerSummaryDeliveryParams, to be used by API callout request to form the payload for Manager Summary Delivery.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	                            DESCRIPTION (Data Type Id, Common Id used across all payloads of Manager Summary Delivery callout)
    * @param    pkgDistributionId	                    DESCRIPTION (Data Type Id, Package Distribution record Id)
    * @param    customSummaryEmail	                    DESCRIPTION (Data Type Boolean, True if "Custom Manager Summary Email" flag is set for the Package Distribution record)
    * @param    totalBatches	                        DESCRIPTION (Data Type Integer, Total number of APi requests being sent)
    * @param    currentBatchNumber	                    DESCRIPTION (Data Type Integer, Current Batch Number representing the current Callout count)
    * @param    acqCompany	                            DESCRIPTION (Data Type Acquisition_Company__c, Acquisition Company record with Manager Summary Email Subject & Body)
    * @param    offerCommunicatorMap	                DESCRIPTION (Data Type Map<Id, Acquisition_Contacts__c>, Map of Offer Communicator Id to Offer Communicator record to be processed for the Manager Summary Delivery API)
    * @return   MA_DS_CalloutFramework.RequestParams    DESCRIPTION (return MA_DS_CalloutFramework.RequestParams wrapper instance to be used by CalloutFramework to form request payload for the API callout)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_CalloutFramework.RequestParams getManagerSummaryDeliveryParams(Id commonId, Id pkgDistributionId, Boolean customSummaryEmail, Integer totalBatches, Integer currentBatchNumber, Acquisition_Company__c acqCompany, Map<Id, Acquisition_Contacts__c> offerCommunicatorMap) {
        MA_DS_ManagerSummaryDeliveryWrapper.ManagerSummaryDeliveryParams summaryDeliveryParams = new MA_DS_ManagerSummaryDeliveryWrapper.ManagerSummaryDeliveryParams();
        summaryDeliveryParams.commonId = commonId;
        summaryDeliveryParams.acqCompany = acqCompany;
        summaryDeliveryParams.totalBatches = totalBatches;
        summaryDeliveryParams.pkgDistributionId = pkgDistributionId;
        summaryDeliveryParams.customSummaryEmail = customSummaryEmail;
        summaryDeliveryParams.currentBatchNumber = currentBatchNumber;
        summaryDeliveryParams.offerCommunicators = offerCommunicatorMap.values();
        summaryDeliveryParams.offerCommunicatorIds = offerCommunicatorMap.keySet();
        return summaryDeliveryParams;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to make a callout to CLM Object API to start Manager Summary Delivery workflow using the CLM Callout Framework.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	    DESCRIPTION (Data Type Id, Acquistion Company record Id)
    * @param    requestParams	    DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void calloutManagerSummaryDeliveryWorkflow(Id acqCompanyId, MA_DS_CalloutFramework.RequestParams requestParams) {
        MA_DS_CalloutFramework.calloutStrategy.setCalloutConfig(CALLOUT_CONFIG_SUMMARY_DELIVERY)
                                              .setCalloutRequestParams(requestParams)
                                              .setCalloutRequest()
                                              .setResponseCallback()
                                              .initCallout(acqCompanyId);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check whether HttpRequest for Manager Summary Delivery is returned with success Status Code or error Status Code.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   Boolean             DESCRIPTION (return True if Http Request returned success Status Code)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Boolean calloutSuccess(MA_DS_CalloutFramework.RequestParams requestParams) {
        return ((MA_DS_ManagerSummaryDeliveryWrapper.ManagerSummaryDeliveryParams)requestParams).successResponse;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Manager Summary IUT type Applied Rules of Summarized Contacts, for each Offer Communicator.
    * Applied Rules are updated with "Need To Deliver" as false.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParamsList	    DESCRIPTION (Data Type List<MA_DS_CalloutFramework.RequestParams>, List of RequestParams instances, one for each API Payload)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateSummaryAppliedRules(List<MA_DS_CalloutFramework.RequestParams> requestParamsList) {
        Set<Id> offerCommunicatorIds = new Set<Id>();

        for(MA_DS_CalloutFramework.RequestParams requestParams : requestParamsList) {
            MA_DS_ManagerSummaryDeliveryWrapper.ManagerSummaryDeliveryParams summaryDeliveryParams = (MA_DS_ManagerSummaryDeliveryWrapper.ManagerSummaryDeliveryParams)requestParams;
            offerCommunicatorIds.addAll(summaryDeliveryParams.offerCommunicatorIds);
        }

        List<MA_DS_Applied_Rule__c> summaryAppliedRules = [SELECT Id, MA_DS_Need_To_Deliver__c
                                                           FROM MA_DS_Applied_Rule__c
                                                           WHERE MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                                                           MA_DS_Template__r.MA_DS_Template_Document_Type__c = :IUT_DOCUMENT_TYPE_SUMMARY AND
                                                           MA_DS_Acquisition_Contact__r.Offer_Communicator__c IN :offerCommunicatorIds];

        for(MA_DS_Applied_Rule__c summaryAppliedRule : summaryAppliedRules) {
            summaryAppliedRule.MA_DS_Need_To_Deliver__c = false;
        }

        if(summaryAppliedRules.size() > 0) {
            updateSummaryAppliedRules(summaryAppliedRules);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Manager Summary IUT type Applied Rules with "Need To Deliver" as false.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryAppliedRules	            DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, List of Applied Rule records to be updated)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateSummaryAppliedRules(List<MA_DS_Applied_Rule__c> summaryAppliedRules) {
        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] appliedRulesSRList = Database.update(summaryAppliedRules, false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(appliedRulesSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the "Manager Summaries Sent Date" for each Package Distribution processed for the Manager Summary Delivery API callout.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids processed for Manager Summary Delivery)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePackageDistributions(Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = [SELECT Id, MA_DS_Integration_Status__c, MA_DS_Manager_Summaries_Sent_Date__c, MA_DS_Trigger_Manager_Summary_Delivery__c
                                                                FROM MA_DS_Package_Distribution__c
                                                                WHERE Id IN :pkgDistributionIds];

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            pkgDistribution.MA_DS_Trigger_Manager_Summary_Delivery__c = false;
            pkgDistribution.MA_DS_Manager_Summaries_Sent_Date__c = Datetime.now();
            pkgDistribution.MA_DS_Integration_Status__c = INTEGRATION_STATUS_NONE;
        }

        if(pkgDistributions.size() > 0) {
            MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
            Database.SaveResult[] pkgDistributionsSRList = Database.update(pkgDistributions, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(pkgDistributionsSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to notify user in case an exception is thrown while sending the API Request or when Status Code > 300 or any other exception.
    * Also used to send success notification to the Target user, if no error is encountered while sending the API Request or no errors in the HttpResponse.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    success	                        DESCRIPTION (Data Type Boolean, True if no error were encountered while sending API request and no errors in the HttpResponse)
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    targetUserId	                DESCRIPTION (Data Type Id, The target User record Id who receives the Notification post all batches of API callouts)
    * @param    totalOfferCommunicators	        DESCRIPTION (Data Type Integer, Denotes total number of Offer Communicators processes across all API request payloads)
    * @param    executionOriginType	            DESCRIPTION (Data Type MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin, ExecutionOrigin enum type)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void notifyTargetIfNeeded(Boolean success, Id srcRecordId, Id targetUserId, Integer totalOfferCommunicators, MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin executionOriginType) {
        Set<String> userIds = new Set<String> {String.valueOf(targetUserId)};
        String notificationTitle = success ? CALLOUT_SUCCESS_NOTIFICATION_TITLE : CALLOUT_FAILED_NOTIFICATION_TITLE;
        String notificationBody = success ? String.format((executionOriginType == MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY) ? 
                                            SCHEDULED_CALLOUT_SUCCESS_NOTIFICATION_BODY : CALLOUT_SUCCESS_NOTIFICATION_BODY, new String[] {String.valueOf(totalOfferCommunicators)}) : CALLOUT_FAILED_NOTIFICATION_BODY;
        MA_MessageProcessing.initNotificationMessaging(MESSAGING_CONFIG, notificationTitle, notificationBody, String.valueOf(srcRecordId), userIds, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
        MA_MessageProcessing.processMessages(MA_MessageProcessing.ExecutionType.NOTIFICATION_JOB);
    }
}