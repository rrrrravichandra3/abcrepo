/**
 * W-12578116
 * Utility class for SummaryPrepJob & SummaryPrepJobFinalizer implementations within MA_DS_SummarizedContactsPrepService.
 * Processes each Offer Communicator along with its Summarized Contacts & sends it to DocuSign CLM via API callout.
 * Prepares a wrapper instance, to be used by the implementation of MA_DS_CalloutFramework.CalloutRequestParams for the API callout.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         29/03/2023      Chakshu Malhotra        W-12578116 - Provides utility methods to process each Offer Communicator along with its Summarized Contacts & sends it to DocuSign CLM via API callout.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_SummarizedContactsPrepUtility {

    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String DOCUMENT_TYPE_MANAGER_SUMMARY = Label.MA_DS_Document_Type_Manager_Summary;

    private static final String INTEGRATION_STATUS_NONE = Label.MA_DS_Eligible_Integration_Status;
    private static final String PD_STATUS_READY_FOR_SUMMARY_AUDIT = Label.MA_DS_PD_Status_Ready_For_Summary_Audit;
    
    private static final String AUDIT_STATUS_IN_PROGRESS = Label.MA_DS_Audit_Status_In_Progress;
    private static final String AUDIT_TYPE_MANAGER_SUMMARY = Label.MA_DS_Audit_Type_Manager_Summary;

    private static final String MESSAGING_CONFIG = Label.MA_DS_Messaging_Config_Summary_Prep_Callout;
    private static final String CALLOUT_CONFIG_SUMMARY_PREP = Label.MA_DS_Callout_Config_Manager_Summary_Prep;

    private static final String CALLOUT_FAILED_NOTIFICATION_BODY = Label.MA_DS_Error_Contact_Admin_Body;
    private static final String CALLOUT_FAILED_NOTIFICATION_TITLE = Label.MA_DS_Summary_Prep_Callout_Failed_Title;

    private static final String CALLOUT_SUCCESS_NOTIFICATION_BODY = Label.MA_DS_Summary_Prep_Callout_Notification_Body;
    private static final String CALLOUT_SUCCESS_NOTIFICATION_TITLE = Label.MA_DS_Summary_Prep_Callout_Notification_Title;

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Offer Communicator Id to its record details (Acq Contact Id => Acq Contact record) from the startIndex to endIndex.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorIdList	            DESCRIPTION (Data Type List<String>, List of all Offer Communicators to be processed for Manager Summary Prep)
    * @param    startIndex	                        DESCRIPTION (Data Type Integer, Start Index of the offerCommunicatorList)
    * @param    maxCount                            DESCRIPTION (Data Type Integer, Maximum number of Ids to fetch starting from the startIndex)
    * @return   Map<Id, Acquisition_Contacts__c>    DESCRIPTION (return Map of Offer Communicator Id to its record details)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, Acquisition_Contacts__c> getOfferCommunicatorMap(List<String> offerCommunicatorIdList, Integer startIndex, Integer maxCount) {
        Set<Id> offerCommunicatorIdSet = getOfferCommunicatorIds(offerCommunicatorIdList, startIndex, (startIndex + maxCount));
        return getOfferCommunicatorMap(offerCommunicatorIdSet);
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Set of Offer Communicator Ids from startIndex to endIndex in the offerCommunicatorList.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorIdList	            DESCRIPTION (Data Type List<String>, List of all Offer Communicators to be processed for Manager Summary Prep)
    * @param    startIndex	                        DESCRIPTION (Data Type Integer, Start Index of the offerCommunicatorList)
    * @param    endIndex                            DESCRIPTION (Data Type Integer, End Index of the offerCommunicatorList)
    * @return   Set<Id>                             DESCRIPTION (return Set of Offer Communicator Ids)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Set<Id> getOfferCommunicatorIds(List<String> offerCommunicatorList, Integer startIndex, Integer endIndex) {
        Set<Id> offerCommunicatorIds = new Set<Id>();

        for(Integer currentIndex=startIndex; currentIndex < endIndex; currentIndex++) {
            offerCommunicatorIds.add(Id.valueOf(offerCommunicatorList[currentIndex]));
        }

        return offerCommunicatorIds;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Offer Communicators (Id => Record detail) for the given Set of offerCommunicatorIds.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorIds	            DESCRIPTION (Data Type Set<Id>, Set of Offer Communicator Ids)
    * @return   Map<Id, Acquisition_Contacts__c>    DESCRIPTION (return Map of Acquisition record Id (Offer Communicator Id) => Offer Communicator)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<Id, Acquisition_Contacts__c> getOfferCommunicatorMap(Set<Id> offerCommunicatorIds) {
        return new Map<Id, Acquisition_Contacts__c>([SELECT Id, Name, MA_DS_Acquisition_Company_Alias_Name__c, First_Name_Legal__c, Last_Name_Legal__c, MA_DS_Preferred_Email_Address__c, 
                                                     Employee_ID_Target__c, MA_DS_Manager_Summary_Stage__c, MA_DS_Manager_Summary_Common_Id__c, MA_DS_Manager_Summary_Async_Apex_Id__c
                                                     FROM Acquisition_Contacts__c
                                                     WHERE Id IN :offerCommunicatorIds]);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Offer Communicator Id to Summarized Contact details (Offer Communicator Id => (Summarized Acq Contact Id => Summarized Acq Contact Record)) for the given Set of offerCommunicatorIds.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorIds	                            DESCRIPTION (Data Type Set<Id>, Set of Offer Communicator Ids)
    * @param    summaryPrepPDIds	                                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids processed for Manager Summary Prep)
    * @return   Map<Id, Map<Id, Acquisition_Contacts__c>>           DESCRIPTION (return Map of Offer Communicator Id to Summarized Contact details)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, Map<Id, Acquisition_Contacts__c>> getSummarizedContactsMap(Set<Id> offerCommunicatorIds, Set<Id> summaryPrepPDIds) {
        Map<Id, Map<Id, Acquisition_Contacts__c>> summarizedContactsMap = new Map<Id, Map<Id, Acquisition_Contacts__c>>();
        
        for(Acquisition_Contacts__c summarizedContact : getSummarizedContacts(offerCommunicatorIds, summaryPrepPDIds)) {
            if(summarizedContact.MA_DS_Applied_Rules__r != null && summarizedContact.MA_DS_Applied_Rules__r.size() > 0) {
                Id offerCommKey = summarizedContact.Offer_Communicator__c;
                Boolean containsOfferCommKey = summarizedContactsMap.containsKey(offerCommKey);
                Map<Id, Acquisition_Contacts__c> summarizedAcqContact = containsOfferCommKey ? summarizedContactsMap.get(offerCommKey) : new Map<Id, Acquisition_Contacts__c>();
                summarizedAcqContact.put(summarizedContact.Id, summarizedContact);
                summarizedContactsMap.put(offerCommKey, summarizedAcqContact);
            }
        }

        return summarizedContactsMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Summarized Contacts details for the given Set of offerCommunicatorIds.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    offerCommunicatorIds	                DESCRIPTION (Data Type Set<Id>, Set of Offer Communicator Ids)
    * @param    summaryPrepPDIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids processed for Manager Summary Prep)
    * @return   List<Acquisition_Contacts__c>           DESCRIPTION (return List of Summarized Contacts for the Offer Communicator Ids)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getSummarizedContacts(Set<Id> offerCommunicatorIds, Set<Id> summaryPrepPDIds) {
        return [SELECT Id, Offer_Communicator__c, Name, First_Name_Legal__c, Last_Name_Legal__c, Manager_Name_Target__c, Manager_Name_Target__r.Name, Manager_Name__c, Manager_Name__r.Name, Employee_Type__c, Business_Title__c, COBRA_Months__c, 
                Outplacement_Months__c, Additional_Field_1__c, Additional_Field_2__c, Additional_Field_3__c, Additional_Field_4__c, Additional_Field_5__c, Business_Title_Target__c, Change_in_Control_CiC__c, CiC_End_Date__c, 
                Continuous_Service_Date__c, MA_DS_Currency_Culture_Code__c, Department__c, Employment_End_Date__c, First_Name_Preferred__c, Last_Name_Preferred__c, Full_Name_Preferred__c, Key_Critical_Employee__c, Office_Address_City__c, 
                Office_Address_State_Province__c, Probation_End_Date__c, Remote_Non_Remote__c, Severance_Weeks__c, Transitional_Employee__c, Transitional_End_Date__c, Transitional_Time_Period__c, Work_Location_Status__c, Workday_Location__c, 
                Employee_ID_Target__c, Office_Address_Country__c, MA_DS_Manager_Summary_Common_Id__c, MA_DS_Manager_Summary_Async_Apex_Id__c, 
                    (SELECT Id, Job_Grade__c, Annualized_Base_Salary__c, Currency_Target__c, Bonus_Amount__c, Commission_Amount__c, On_Target_Earnings__c, Stock_Grant_Amount__c, Severance_Amount__c, CurrencyIsoCode, 
                     Additional_Allowance_Amount__c, Additional_Allowance_Frequency__c, Additional_Allowance_Plan__c, Additional_Field_1__c, Additional_Field_2__c, Additional_Field_3__c, Additional_Field_4__c, Additional_Field_5__c, 
                     Additional_OTP_Amount__c, Additional_OTP_Effective_Date__c, Additional_OTP_Plan__c, Additional_Stock_Grant_Amount__c, Additional_Stock_Plan__c, Car_Allowance_Amount__c, Car_Allowance_Frequency__c, Car_Allowance_Plan__c, 
                     MA_DS_Belgium_Monthly_Base_Salary__c, MA_DS_Belgium_Monthly_Car_Allowance__c, Bonus_Plan__c, Bonus_Target__c, Business_Title__c, Coefficient__c, Classification__c, Classification_Target__c, Commission_Plan__c, Draw_Amount__c, 
                     Draw_Duration__c, Draw_Frequency__c, Draw_is_Recoverable__c, Flextime_Eligible__c, Grant_Type__c, Hourly_Rate__c, MA_DS_Monthly_Base_Salary__c, On_call_Hourly__c, On_call_Seven_day__c, On_call_Weekend__c, On_call_Working__c, 
                     One_Time_Payment_Amount__c, One_Time_Payment_Plan__c, Overtime__c, Overtime_Ineligible__c, Pay_Rate_Type__c, MA_Period_Salary__c, MA_Period_Salary_Duration_Months__c, Prorated_Base_Salary__c, Scheduled_Hours__c, 
                     Stock_Grant_Date__c, Time_Type__c, Workday_Location__c
                     FROM Acquisition_Compensation__r LIMIT 1), 
                    (SELECT Id, MA_DS_Package_Distribution__c, MA_DS_Flagged_For_Audit__c, MA_DS_Need_To_Deliver__c, MA_DS_Need_To_Generate__c
                     FROM MA_DS_Applied_Rules__r
                     WHERE MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                     MA_DS_Template__r.MA_DS_Template_Document_Type__c = :DOCUMENT_TYPE_MANAGER_SUMMARY AND
                     MA_DS_Package_Distribution__c IN :summaryPrepPDIds) 
                FROM Acquisition_Contacts__c
                WHERE Offer_Communicator__c IN :offerCommunicatorIds AND
                MA_DS_No_Offer__c = false AND
                MA_DS_Offer_Declined__c = false];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to prepare the wrapper instance of ManagerSummaryPrepParams, to be used by API callout request to form the payload for Manager Summary Prep.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	                            DESCRIPTION (Data Type Id, Manager Summary Common Id)
    * @param    acqCompanyId	                        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    summaryTemplateId	                    DESCRIPTION (Data Type Id, Template record Id for the Manager Summary template being used)
    * @param    asyncApexId	                            DESCRIPTION (Data Type Id, Async Apex Job Id)
    * @param    totalBatches	                        DESCRIPTION (Data Type Integer, Total number of APi requests being sent)
    * @param    currentBatchNumber	                    DESCRIPTION (Data Type Integer, Current Batch Number representing the current Callout count)
    * @param    summaryPrepPDIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    offerCommunicator	                    DESCRIPTION (Data Type Acquisition_Contacts__c, Offer Communicator (Acquisition Contact) record details)
    * @param    summarizedContacts	                    DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Summarized Contacts (Acquisition Contacts) along with their Compensation & Applied Rule details)
    * @return   MA_DS_CalloutFramework.RequestParams    DESCRIPTION (return MA_DS_CalloutFramework.RequestParams wrapper instance to be used by CalloutFramework to form request payload for the API callout)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_CalloutFramework.RequestParams getManagerSummaryPrepParams(Id commonId, Id acqCompanyId, Id summaryTemplateId, Id asyncApexId, Integer totalBatches, Integer currentBatchNumber, Set<Id> summaryPrepPDIds, 
                                                                                   Acquisition_Contacts__c offerCommunicator, List<Acquisition_Contacts__c> summarizedContacts) {
        MA_DS_ManagerSummaryPrepWrapper.ManagerSummaryPrepParams summaryPrepParams = new MA_DS_ManagerSummaryPrepWrapper.ManagerSummaryPrepParams();

        summaryPrepParams.commonId = commonId;
        summaryPrepParams.asyncApexId = asyncApexId;
        summaryPrepParams.totalBatches = totalBatches;
        summaryPrepParams.currentBatchNumber = currentBatchNumber;
        
        summaryPrepParams.primaryPDIds.addAll(summaryPrepPDIds);
        
        summaryPrepParams.acqCompanyId = acqCompanyId;
        summaryPrepParams.summaryTemplateId = summaryTemplateId;
        summaryPrepParams.offerCommunicator = offerCommunicator;
        summaryPrepParams.summarizedContacts = summarizedContacts;
        summaryPrepParams.acqCompanyName = offerCommunicator.MA_DS_Acquisition_Company_Alias_Name__c;
        
        return summaryPrepParams;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to make a callout to CLM Object API to start Manager Summary Prep workflow using the CLM Callout Framework.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	    DESCRIPTION (Data Type Id, Acquistion Company record Id)
    * @param    requestParams	    DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void calloutManagerSummaryPrepWorkflow(Id acqCompanyId, MA_DS_CalloutFramework.RequestParams requestParams) {
        MA_DS_CalloutFramework.calloutStrategy.setCalloutConfig(CALLOUT_CONFIG_SUMMARY_PREP)
                                              .setCalloutRequestParams(requestParams)
                                              .setCalloutRequest()
                                              .setResponseCallback()
                                              .initCallout(acqCompanyId);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check whether HttpRequest for Manager Summary Prep is returned with success Status Code or error Status Code.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   Boolean             DESCRIPTION (return True if Http Request returned success Status Code)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Boolean calloutSuccess(MA_DS_CalloutFramework.RequestParams requestParams) {
        return ((MA_DS_ManagerSummaryPrepWrapper.ManagerSummaryPrepParams)requestParams).successResponse;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Offer Communicators & Summarized Contacts for each API request that returned with Success response.
    * Offer Communicators are updated with Manager Summany Common Id, Async Apex Job Id.
    * Summarized Contacts are updated with Manager Summany Common Id & Async Apex Job Id.
    * Manager Summary Applied Rules are updated with "Need To Generate" as false and "Need To Deliver" as true.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    asyncApexId	            DESCRIPTION (Data Type Id, Async Apex Job Id)
    * @param    requestParamsList	    DESCRIPTION (Data Type List<MA_DS_CalloutFramework.RequestParams>, List of RequestParams instances, one for each API Payload)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateOfferCommunicatorsAndSummarizedContacts(Id asyncApexId, List<MA_DS_CalloutFramework.RequestParams> requestParamsList) {
        Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap = new Map<Id, MA_DS_Applied_Rule__c>();
        Map<Id, Acquisition_Contacts__c> acquisitionContactsMap = new Map<Id, Acquisition_Contacts__c>();

        Set<Id> summarizedContactIds = new Set<Id>();

        for(MA_DS_CalloutFramework.RequestParams requestParams : requestParamsList) {
            MA_DS_ManagerSummaryPrepWrapper.ManagerSummaryPrepParams summaryPrepParams = (MA_DS_ManagerSummaryPrepWrapper.ManagerSummaryPrepParams)requestParams;
            updateAcquisitionContact(summaryPrepParams.commonId, asyncApexId, summaryPrepParams.offerCommunicator);

            for(Acquisition_Contacts__c summarizedContact : summaryPrepParams.summarizedContacts) {
                updateAcquisitionContact(summaryPrepParams.commonId, asyncApexId, summarizedContact);
                acquisitionContactsMap.put(summarizedContact.Id, summarizedContact);
                summarizedContactIds.add(summarizedContact.Id);

                for(MA_DS_Applied_Rule__c summaryAppliedRule : summarizedContact.MA_DS_Applied_Rules__r) {
                    updateSummaryAppliedRule(summaryAppliedRule, appliedRulesMap);
                }
            }

            acquisitionContactsMap.put(summaryPrepParams.offerCommunicator.Id, summaryPrepParams.offerCommunicator);
        }

        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        
        if(acquisitionContactsMap.size() > 0) {
            updateSummaryAppliedRules(appliedRulesMap);
            updateAcquisitionContacts(acquisitionContactsMap);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Contact with Manager Summany Common Id & Async Apex Job Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	            DESCRIPTION (Data Type Id, Manager Summary Common Id)
    * @param    asyncApexId	            DESCRIPTION (Data Type Id, Async Apex Job Id)
    * @param    acqContact	            DESCRIPTION (Data Type Acquisition_Contacts__c, Acquisition Contact record (either Offer Communicator or Summarized Contact))
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateAcquisitionContact(Id commonId, Id asyncApexId, Acquisition_Contacts__c acqContact) {
        acqContact.MA_DS_Manager_Summary_Common_Id__c = commonId;
        acqContact.MA_DS_Manager_Summary_Async_Apex_Id__c = asyncApexId;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Manager Summary IUT type Applied Rule with "Need To Deliver" as true and "Need To Generate" as false.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryAppliedRule	        DESCRIPTION (Data Type MA_DS_Applied_Rule__c, Manager Summary IUT type Applied Rule for Summarized Contact)
    * @param    appliedRulesMap	            DESCRIPTION (Data Type Map<Id, MA_DS_Applied_Rule__c>, Map of Applied Rule Id to updated Applied Rule record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateSummaryAppliedRule(MA_DS_Applied_Rule__c summaryAppliedRule, Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap) {
        summaryAppliedRule.MA_DS_Need_To_Deliver__c = true;
        summaryAppliedRule.MA_DS_Need_To_Generate__c = false;
        appliedRulesMap.put(summaryAppliedRule.Id, summaryAppliedRule);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Manager Summary IUT type Applied Rules with "Need To Deliver" as true and "Need To Generate" as false.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRulesMap	            DESCRIPTION (Data Type Map<Id, MA_DS_Applied_Rule__c>, Map of Applied Rule Id to updated Applied Rule record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateSummaryAppliedRules(Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap) {
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] appliedRulesSRList = Database.update(appliedRulesMap.values(), false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(appliedRulesSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Contacts for each API request that returned with Success response.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acquisitionContactsMap	    DESCRIPTION (Data Type Map<Id, Acquisition_Contacts__c>, Map of Acquisition Contact Id to updated Acquisition Contact record)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateAcquisitionContacts(Map<Id, Acquisition_Contacts__c> acquisitionContactsMap) {
        Database.SaveResult[] acqContactsSRList = Database.update(acquisitionContactsMap.values(), false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(acqContactsSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the "Manager Summaries Prep Date" & "Integration Status" for each Package Distribution processed for Manager Summary Prep.
    * Notifies user of the completion of the Manager Summary Prep process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids processed for Manager Summary Prep)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePackageDistributions(Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = [SELECT Id, MA_DS_Integration_Status__c, MA_DS_Manager_Summaries_Prep_Date__c
                                                                FROM MA_DS_Package_Distribution__c
                                                                WHERE Id IN :pkgDistributionIds];

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            pkgDistribution.MA_DS_Manager_Summaries_Prep_Date__c = Datetime.now();
            pkgDistribution.MA_DS_Integration_Status__c = INTEGRATION_STATUS_NONE;
        }

        if(pkgDistributions.size() > 0) {
            MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
            Database.SaveResult[] pkgDistributionsSRList = Database.update(pkgDistributions, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(pkgDistributionsSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the Manager Summary Audit record if the Job's ExecutionOrigin is AUDIT_FAILED_REGEN.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	            DESCRIPTION (Data Type Boolean, True if Execution Origin is AUDIT_FAILED_REGEN)
    * @param    acqCompanyId	                DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateManagerSummaryAuditIfNeeded(Boolean isAuditFailedRegen, Id acqCompanyId) {
        if(isAuditFailedRegen) {
            List<MA_DS_Audit__c> auditList = [SELECT Id, MA_DS_Status__c, MA_DS_Failed_Common_Id__c, MA_DS_Failed_Regenerate_Attempt_Count__c
                                              FROM MA_DS_Audit__c
                                              WHERE MA_DS_Acquisition_Company__c = :acqCompanyId AND
                                              MA_DS_Audit_Type__c = :AUDIT_TYPE_MANAGER_SUMMARY];

            for(MA_DS_Audit__c audit : auditList) {
                audit.MA_DS_Failed_Common_Id__c = null;
                audit.MA_DS_Status__c = AUDIT_STATUS_IN_PROGRESS;
                audit.MA_DS_Failed_Regenerate_Attempt_Count__c = null;
            }

            if(auditList.size() > 0) {
                MA_DS_AuditTriggerHandler.triggerDisabled = true;
                Database.SaveResult[] auditsSRList = Database.update(auditList, false);
                MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(auditsSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
            }
        }
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to notify user in case an exception is thrown while sending the API Request or when Status Code > 300 or any other exception.
    * Also used to send success notification to the Target user, if no error is encountered while sending the API Request or no errors in the HttpResponse.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	            DESCRIPTION (Data Type Boolean, True if Execution Origin is AUDIT_FAILED_REGEN)
    * @param    success	                        DESCRIPTION (Data Type Boolean, True if no error were encountered while sending API request and no errors in the HttpResponse)
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    totalBatches	                DESCRIPTION (Data Type Integer, Denotes total number of API requests sent to Docusign CLM)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void notifyTargetIfNeeded(Boolean isAuditFailedRegen, Boolean success, Id srcRecordId, Integer totalBatches) {
        if(!isAuditFailedRegen) {
            Set<String> userIds = new Set<String> {String.valueOf(UserInfo.getUserId())};
            String notificationTitle = success ? CALLOUT_SUCCESS_NOTIFICATION_TITLE : CALLOUT_FAILED_NOTIFICATION_TITLE;
            String notificationBody = success ? String.format(CALLOUT_SUCCESS_NOTIFICATION_BODY, new String[] {String.valueOf(totalBatches)}) : CALLOUT_FAILED_NOTIFICATION_BODY;
            MA_MessageProcessing.initNotificationMessaging(MESSAGING_CONFIG, notificationTitle, notificationBody, String.valueOf(srcRecordId), userIds, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
            MA_MessageProcessing.processMessages(MA_MessageProcessing.ExecutionType.NOTIFICATION_JOB);
        }
    }
}