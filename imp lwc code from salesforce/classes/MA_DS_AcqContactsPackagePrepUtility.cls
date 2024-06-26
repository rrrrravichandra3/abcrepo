/**
 * W-13011399
 * Utility class for PackagePrepJob & PackagePrepJobFinalizer implementations within MA_DS_AcqContactsPackagePrepService.
 * Processes each Acquisition Contact & sends Package Documents (Template Ids) details to DocuSign CLM via API callout.
 * Prepares a wrapper instance, to be used by the implementation of MA_DS_CalloutFramework.CalloutRequestParams for the API callout.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         29/04/2023      Chakshu Malhotra        W-13011399 - Provides utility methods to process each Acquisition Contact & sends Package Documents (Template Ids) details to DocuSign CLM via API callout.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AcqContactsPackagePrepUtility {
    
    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String IUT_DOCUMENT_TYPE_PACKAGE = Label.MA_DS_Document_Type_Package;

    private static final String AUDIT_TYPE_PACKAGE = Label.MA_DS_Audit_Type_Package;
    private static final String AUDIT_STATUS_IN_PROGRESS = Label.MA_DS_Audit_Status_In_Progress;

    private static final String INTEGRATION_STATUS_NONE = Label.MA_DS_Eligible_Integration_Status;
    private static final String PD_STATUS_READY_FOR_PACKAGE_AUDIT = Label.MA_DS_PD_Status_Ready_For_Package_Audit;

    private static final String MESSAGING_CONFIG = Label.MA_DS_Messaging_Config_Package_Prep_Callout;
    private static final String CALLOUT_CONFIG_PACKAGE_PREP = Label.MA_DS_Callout_Config_Package_Prep;

    private static final String CALLOUT_FAILED_NOTIFICATION_BODY = Label.MA_DS_Error_Contact_Admin_Body;
    private static final String CALLOUT_FAILED_NOTIFICATION_TITLE = Label.MA_DS_Package_Prep_Callout_Failed_Title;

    private static final String CALLOUT_SUCCESS_NOTIFICATION_BODY = Label.MA_DS_Package_Prep_Callout_Notification_Body;
    private static final String CALLOUT_SUCCESS_NOTIFICATION_TITLE = Label.MA_DS_Package_Prep_Callout_Notification_Title;

    private static final String ACQ_CONTACT_IDS_VAR = 'acqContacts';
    private static final String ACQ_CONTACT_IDS_FILTER = 'Id IN :{0}';

    private static final String NO_OFFER_VAR = 'noOffer';
    private static final String NO_OFFER_FILTER = ' AND MA_DS_No_Offer__c = :{0}';

    private static final String OFFER_DECLINED_VAR = 'offerDeclined';
    private static final String OFFER_DECLINED_FILTER = ' AND MA_DS_Offer_Declined__c = :{0}';

    private static final String COMMON_IDS_VAR = 'commonIds';
    private static final String COMMON_IDS_FILTER = ' AND MA_DS_Package_Common_Id__c IN :{0}';

    private static final String RULE_TYPE_VAR = 'ruleType';
    private static final String RULE_TYPE_FILTER = 'MA_DS_Rule_Type__c = :{0}';

    private static final String DOC_TYPE_VAR = 'docType';
    private static final String DOC_TYPE_FILTER = ' AND MA_DS_Template__r.MA_DS_Template_Document_Type__c = :{0}';

    private static final String PKG_DISTRIBUTION_IDS_VAR = 'pkgDistributionIds';
    private static final String PKG_DISTRIBUTION_IDS_FILTER = ' AND MA_DS_Package_Distribution__c IN :{0}';

    private static final String NEED_GENERATE_VAR = 'needGenerate';
    private static final String NEED_GENERATE_FILTER = ' AND MA_DS_Need_To_Generate__c = :{0}';

    private static final String TEMPLATE_IDS_VAR = 'templateIds';
    private static final String TEMPLATE_IDS_FILTER = ' AND MA_DS_Template__c IN :{0}';

    private static final String APPLIED_RULE_IDS_VAR = 'appliedRuleId';
    private static final String APPLIED_RULE_IDS_FILTER = ' AND Id IN :{0}';

    private static final String ACQ_COMPENSATION_SUB_QUERY_STR = '(SELECT {0} FROM Acquisition_Compensation__r LIMIT 1)';
    private static final String APPLIED_RULES_SUB_QUERY_STR = '(SELECT {0} FROM MA_DS_Applied_Rules__r WHERE {1})';
    private static final String ACQ_CONTACTS_QUERY_STR = 'SELECT {0}, {1}, {2} FROM Acquisition_Contacts__c WHERE {3}';

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Acquisition Compensation sub query.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> acqCompSubQueryFields {
        get {
            if(acqCompSubQueryFields == null) {
                acqCompSubQueryFields = new List<String> {'Id', 'Job_Grade__c', 'Annualized_Base_Salary__c', 'Currency_Target__c', 'Bonus_Amount__c', 'Commission_Amount__c', 'On_Target_Earnings__c', 'Stock_Grant_Amount__c', 'Severance_Amount__c', 'Hourly_Rate__c', 'Bonus_Plan__c', 'Grant_Type__c', 
                'Draw_Duration__c', 'Draw_Amount__c', 'Pay_Rate_Type__c', 'Additional_Allowance_Amount__c', 'Additional_Allowance_Frequency__c', 'Additional_Allowance_Plan__c', 'Additional_Field_1__c', 'Additional_Field_2__c', 'Additional_Field_3__c', 'Additional_Field_4__c', 'Additional_Field_5__c', 
                'Additional_OTP_Amount__c', 'Additional_OTP_Effective_Date__c', 'Additional_OTP_Plan__c', 'Additional_Stock_Grant_Amount__c', 'Additional_Stock_Plan__c', 'Car_Allowance_Amount__c', 'Car_Allowance_Frequency__c', 'Car_Allowance_Plan__c', 'MA_DS_Belgium_Monthly_Base_Salary__c', 
                'MA_DS_Belgium_Monthly_Car_Allowance__c', 'Bonus_Target__c', 'Classification__c', 'Classification_Target__c', 'Commission_Plan__c', 'CurrencyIsoCode', 'Draw_Frequency__c', 'Draw_is_Recoverable__c', 'Flextime_Eligible__c', 'MA_DS_India_Basic_Pay__c', 'MA_DS_India_Basic_Pay_Monthly__c', 
                'MA_DS_India_CE_Allowance_Monthly__c', 'MA_DS_India_CE_Allowance_Num__c', 'MA_DS_India_Cost_To_Company_Monthly__c', 'MA_DS_India_Driver_Salary_Monthly__c', 'MA_DS_India_Driver_Salary_Num__c', 'MA_DS_India_House_Rent_Allowance__c', 'MA_DS_India_House_Rent_Allowance_Monthly__c', 
                'MA_DS_India_Incentive_Target__c', 'MA_DS_India_Incentive_Target_Monthly__c', 'MA_DS_India_Leave_Travel_Allow_Monthly__c', 'MA_DS_India_Leave_Travel_Allowance__c', 'MA_DS_India_Leave_Travel_Allowance_Input__c', 'MA_DS_India_Other_Allowance__c', 'MA_DS_India_Other_Allowance_Monthly__c', 
                'MA_DS_India_Provident_Fund__c', 'MA_DS_India_Provident_Fund_Monthly__c', 'MA_DS_India_Telephone_Reimburse_Montlhy__c', 'MA_DS_India_Telephone_Reimburse_Num__c', 'MA_DS_India_Vehicle_Reimburse_Montlhy__c', 'MA_DS_India_Vehicle_Reimburse_Num__c', 'MA_DS_Israel_Basic_Pay__c', 
                'MA_DS_Israel_OT_Pay_20_Hrs__c', 'MA_DS_Israel_OT_Pay_40_Hrs__c', 'MA_DS_Japan_Base_Pay__c', 'MA_DS_Japan_Fixed_OT_Allowance__c', 'MA_DS_Monthly_Base_Salary__c', 'On_call_Hourly__c', 'On_call_Seven_day__c', 'On_call_Weekend__c', 'On_call_Working__c', 'One_Time_Payment_Amount__c', 
                'One_Time_Payment_Plan__c', 'Overtime__c', 'Overtime_Ineligible__c', 'MA_Period_Salary__c', 'MA_Period_Salary_Duration_Months__c', 'Prorated_Base_Salary__c', 'Scheduled_Hours__c', 'Stock_Grant_Date__c', 'Time_Type__c'};
            }
            return acqCompSubQueryFields;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Applied Rules sub query.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> appliedRulesSubQueryFields {
        get {
            if(appliedRulesSubQueryFields == null) {
                appliedRulesSubQueryFields = new List<String> {'Id', 'Name', 'MA_DS_Package_Distribution__c', 'MA_DS_Template__c', 'MA_DS_Flagged_For_Audit__c', 'MA_DS_Need_To_Generate__c', 'MA_DS_Need_To_Deliver__c'};
            }
            return appliedRulesSubQueryFields;
        }set;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Acquisition Contacts query.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> acqContactsQueryFields {
        get {
            if(acqContactsQueryFields == null) {
                acqContactsQueryFields = new List<String> {'Id', 'Name', 'MA_DS_Acquisition_Company_Alias_Name__c', 'First_Name_Legal__c', 'Last_Name_Legal__c', 'Employee_ID_Target__c', 'MA_DS_Preferred_Email_Address__c', 'Manager_Name_Target__c', 'Manager_Name_Target__r.Name', 
                    'Manager_Name__c', 'Manager_Name__r.Name', 'Employee_Type__c', 'Pay_Rate_Type__c', 'Business_Title__c', 'COBRA_Months__c', 'Outplacement_Months__c', 'Manager_Title__c', 'Work_Location_Status__c', 'MA_DS_Envelope_Void_Date__c', 'Office_Address_City__c', 
                    'Office_Address_Country__c', 'Home_Address_City__c', 'Home_Address_Commune__c', 'Home_Address_Country__c', 'Home_Address_Region__c', 'Home_Address_State_Province__c', 'Home_Address_Street__c', 'Home_Address_Street_Arabic__c', 'Home_Address_Street_Line_2__c', 
                    'Home_Address_Street_Line_2_Arabic__c', 'Home_Address_Zip_Postal_Code__c', 'Additional_Field_1__c', 'Additional_Field_2__c', 'Additional_Field_3__c', 'Additional_Field_4__c', 'Additional_Field_5__c', 'MA_DS_Age__c', 'Birth_Date__c', 'Business_Title_Target__c', 
                    'Change_in_Control_CiC__c', 'CiC_End_Date__c', 'Continuous_Service_Date__c', 'MA_DS_Currency_Culture_Code__c', 'Department__c', 'Employment_End_Date__c', 'Entity_Name__c', 'Gender__c', 'Hire_Date__c', 'Hire_Date_Target__c', 'Manager_Email_Address__c', 'Marital_Status__c', 
                    'Nationality__c', 'Office_Address_Street__c', 'Office_Address_Zip_Postal_Code__c', 'PTO_Annual_Leave_Days__c', 'First_Name_Preferred__c', 'Last_Name_Preferred__c', 'Full_Name_Preferred__c', 'Key_Critical_Employee__c', 'Office_Address_State_Province__c', 
                    'Probation_End_Date__c', 'Remote_Non_Remote__c', 'Severance_Weeks__c', 'SSNID_Number__c', 'Term_Date_Target__c', 'Transitional_Employee__c', 'Transitional_End_Date__c', 'Transitional_Time_Period__c', 'University__c', 'Workday_Location__c', 'MA_DS_Package_Common_Id__c', 
                    'MA_DS_Package_Async_Apex_Id__c', 'MA_DS_Package_Stage__c'};
            }
            return acqContactsQueryFields;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Acquisition Contacts to be processed in a single batch of Package Prep API callout.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	                        DESCRIPTION (Data Type Boolean, True if executionOriginType is MA_DS_PackagePrepService.ExecutionOrigin.AUDIT_FAILED_REGEN)
    * @param    packagePrepPDIds	                        DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Package Prep or Regeneration)
    * @param    failedCommonIds	                            DESCRIPTION (Data Type Set<String>, Set of Failed Package Common Ids to re-process them for Package Prep)
    * @param    templateIds	                                DESCRIPTION (Data Type Set<String>, Set of Template Ids to identify the Applied Rule records)
    * @param    acqContactIds	                            DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids to identify the Applied Rule records)
    * @param    appliedRuleIds	                            DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids to identify the Applied Rule records)
    * @return   List<Acquisition_Contacts__c>               DESCRIPTION (return List of Acquisition Contacts)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> getAquisitionContacts(Boolean isAuditFailedRegen, Set<Id> packagePrepPDIds, Set<String> failedCommonIds, Set<String> templateIds, Set<String> acqContactIds, Set<String> appliedRuleIds) {
        String acqCompQueryString = String.format(ACQ_COMPENSATION_SUB_QUERY_STR, new String[] {String.join(acqCompSubQueryFields, ', ')});

        String appliedRulesFilters = getAppliedRulesSubQueryFilters(isAuditFailedRegen, templateIds, appliedRuleIds);
        String appliedRulesQueryString = String.format(APPLIED_RULES_SUB_QUERY_STR, new String[] {String.join(appliedRulesSubQueryFields, ', '), appliedRulesFilters});

        String acqContactsFilters = getAcquisitionContactsQueryFilters(isAuditFailedRegen, failedCommonIds);
        String acqContactsQueryString = String.format(ACQ_CONTACTS_QUERY_STR, new String[] {String.join(acqContactsQueryFields, ', '), acqCompQueryString, appliedRulesQueryString, acqContactsFilters});

        Map<String, Object> bindMap = getQueryBindMap(packagePrepPDIds, failedCommonIds, templateIds, acqContactIds, appliedRuleIds);
        return getAquisitionContacts(acqContactsQueryString, bindMap);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Applied Rules sub queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	                        DESCRIPTION (Data Type Boolean, True if executionOriginType is MA_DS_PackagePrepService.ExecutionOrigin.AUDIT_FAILED_REGEN)
    * @param    templateIds	                                DESCRIPTION (Data Type Set<String>, Set of Template Ids to identify the Applied Rule records)
    * @param    appliedRuleIds	                            DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids to identify the Applied Rule records)
    * @return   String                                      DESCRIPTION (return Filters string, used to form the Acquisition Contacts queryString)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAppliedRulesSubQueryFilters(Boolean isAuditFailedRegen, Set<String> templateIds, Set<String> appliedRuleIds)  {
        String filters = String.format(RULE_TYPE_FILTER, new String[] {RULE_TYPE_VAR});
        filters += String.format(DOC_TYPE_FILTER, new String[] {DOC_TYPE_VAR});
        filters += String.format(PKG_DISTRIBUTION_IDS_FILTER, new String[] {PKG_DISTRIBUTION_IDS_VAR});
        filters += isAuditFailedRegen ? '' : String.format(NEED_GENERATE_FILTER, new String[] {NEED_GENERATE_VAR});
        filters += (isAuditFailedRegen && templateIds.size() > 0) ? String.format(TEMPLATE_IDS_FILTER, new String[] {TEMPLATE_IDS_VAR}) : '';
        filters += (isAuditFailedRegen && appliedRuleIds.size() > 0) ? String.format(APPLIED_RULE_IDS_FILTER, new String[] {APPLIED_RULE_IDS_VAR}) : '';
        return filters;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Acquisition Contacts queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	                        DESCRIPTION (Data Type Boolean, True if executionOriginType is MA_DS_PackagePrepService.ExecutionOrigin.AUDIT_FAILED_REGEN)
    * @param    failedCommonIds	                            DESCRIPTION (Data Type Set<String>, Set of Failed Package Common Ids to re-process them for Package Prep)
    * @return   String                                      DESCRIPTION (return Filters string, used to form the Acquisition Contacts queryString)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAcquisitionContactsQueryFilters(Boolean isAuditFailedRegen, Set<String> failedCommonIds)  {
        String filters = String.format(ACQ_CONTACT_IDS_FILTER, new String[] {ACQ_CONTACT_IDS_VAR});
        filters += String.format(NO_OFFER_FILTER, new String[] {NO_OFFER_VAR});
        filters += String.format(OFFER_DECLINED_FILTER, new String[] {OFFER_DECLINED_VAR});
        filters += (isAuditFailedRegen && failedCommonIds.size() > 0) ? String.format(COMMON_IDS_FILTER, new String[] {COMMON_IDS_VAR}) : '';
        return filters;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Acquisition Contacts queryString, sets value for all the Bind Variables used in the queryString.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packagePrepPDIds	                        DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Package Prep or Regeneration)
    * @param    failedCommonIds	                            DESCRIPTION (Data Type Set<String>, Set of Failed Package Common Ids to re-process them for Package Prep)
    * @param    templateIds	                                DESCRIPTION (Data Type Set<String>, Set of Template Ids to identify the Applied Rule records)
    * @param    acqContactIds	                            DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids to identify the Applied Rule records)
    * @param    appliedRuleIds	                            DESCRIPTION (Data Type Set<String>, Set of Applied Rule Ids to identify the Applied Rule records)
    * @return   Map<String, Object>                         DESCRIPTION (return bindMap for the Acquisition Contacts queryString)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getQueryBindMap(Set<Id> packagePrepPDIds, Set<String> failedCommonIds, Set<String> templateIds, Set<String> acqContactIds, Set<String> appliedRuleIds) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(ACQ_CONTACT_IDS_VAR, acqContactIds);
        bindMap.put(NO_OFFER_VAR, false);
        bindMap.put(OFFER_DECLINED_VAR, false);
        bindMap.put(COMMON_IDS_VAR, failedCommonIds);
        bindMap.put(RULE_TYPE_VAR, IUT_TYPE_APPLIED_RULE);
        bindMap.put(DOC_TYPE_VAR, IUT_DOCUMENT_TYPE_PACKAGE);
        bindMap.put(PKG_DISTRIBUTION_IDS_VAR, packagePrepPDIds);
        bindMap.put(NEED_GENERATE_VAR, true);
        bindMap.put(TEMPLATE_IDS_VAR, templateIds);
        bindMap.put(APPLIED_RULE_IDS_VAR, appliedRuleIds);
        return bindMap;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to execute the Database.queryWithBinds() & return the List of Acquisition Contacts retrieved by the dynamic query string.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    queryString                         DESCRIPTION (Data Type String, Query String to use in Database.queryWithBinds() method)
    * @param    bindMap                             DESCRIPTION (Data Type Map<String, Object>, bindMap wrapped in the QueryWrapper instance)
    * @return   List<Acquisition_Contacts__c>       DESCRIPTION (return List of Acquisition Contacts)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<Acquisition_Contacts__c> getAquisitionContacts(String queryString, Map<String, Object> bindMap) {
        List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>();

        try {
            acqContacts.addAll((List<Acquisition_Contacts__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE));
        }catch(QueryException exType) {
            MA_AbstractLogger.logException(exType, MA_DS_AcqContactsPackagePrepUtility.class.getName());
        }

        return acqContacts;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to prepare the wrapper instance of PackagePrepParams, to be used by API callout request to form the payload for Package Prep.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	                            DESCRIPTION (Data Type Id, Package Common Id)
    * @param    acqCompanyId	                        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    asyncApexId	                            DESCRIPTION (Data Type Id, Async Apex Job Id)
    * @param    firstBatch                              DESCRIPTION (Data type Boolean, True if the last API callout was the first batch of the Acquisition Contacts processed for Package Prep)
    * @param    finalBatch                              DESCRIPTION (Data type Boolean, True if the last API callout was the final batch of the Acquisition Contacts processed for Package Prep)
    * @param    acqContacts	                            DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts along with their Compensation & Applied Rule details)
    * @return   MA_DS_CalloutFramework.RequestParams    DESCRIPTION (return MA_DS_CalloutFramework.RequestParams wrapper instance to be used by CalloutFramework to form request payload for the API callout)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_CalloutFramework.RequestParams getPackagePrepParams(Id commonId, Id acqCompanyId, Id asyncApexId, Boolean firstBatch, Boolean finalBatch, List<Acquisition_Contacts__c> acqContacts) {
        MA_DS_PackagePrepWrapper.PackagePrepParams packagePrepParams = new MA_DS_PackagePrepWrapper.PackagePrepParams();
        packagePrepParams.commonId = commonId;
        packagePrepParams.asyncApexId = asyncApexId;
        packagePrepParams.acqCompanyId = acqCompanyId;
        packagePrepParams.firstBatch = firstBatch;
        packagePrepParams.finalBatch = finalBatch;
        packagePrepParams.acqContacts = acqContacts;
        packagePrepParams.acqCompanyName = (acqContacts != null && acqContacts.size() > 0) ? acqContacts[0].MA_DS_Acquisition_Company_Alias_Name__c : null;
        return packagePrepParams;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to make a callout to CLM Object API to start Package Prep workflow using the CLM Callout Framework.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	            DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    requestParams	        DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void calloutPackagePrepWorkflow(Id srcRecordId, MA_DS_CalloutFramework.RequestParams requestParams) {
        MA_DS_CalloutFramework.calloutStrategy.setCalloutConfig(CALLOUT_CONFIG_PACKAGE_PREP)
                                              .setCalloutRequestParams(requestParams)
                                              .setCalloutRequest()
                                              .setResponseCallback()
                                              .initCallout(srcRecordId);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check whether HttpRequest for Package Prep is returned with success Status Code or error Status Code.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   Boolean             DESCRIPTION (return True if Http Request returned success Status Code)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Boolean calloutSuccess(MA_DS_CalloutFramework.RequestParams requestParams) {
        return ((MA_DS_PackagePrepWrapper.PackagePrepParams)requestParams).successResponse;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Contacts for each API request that returned with Success response.
    * Acquisition Contacts are updated with Package Common Id & Async Apex Job Id.
    * Package Document Applied Rules are updated with "Need To Generate" as false and "Need To Deliver" as true.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    asyncApexId	                    DESCRIPTION (Data Type Id, Async Apex Job Id)
    * @param    requestParamsList	            DESCRIPTION (Data Type List<MA_DS_CalloutFramework.RequestParams>, List of RequestParams instances, one for each API Payload)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updateAcquisitionContacts(Id asyncApexId, List<MA_DS_CalloutFramework.RequestParams> requestParamsList) {
        Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap = new Map<Id, MA_DS_Applied_Rule__c>();
        Map<Id, Acquisition_Contacts__c> acquisitionContactsMap = new Map<Id, Acquisition_Contacts__c>();

        for(MA_DS_CalloutFramework.RequestParams requestParams : requestParamsList) {
            MA_DS_PackagePrepWrapper.PackagePrepParams packagePrepParams = (MA_DS_PackagePrepWrapper.PackagePrepParams)requestParams;
            
            for(Acquisition_Contacts__c acqContact : packagePrepParams.acqContacts) {
                updateAcquisitionContact(packagePrepParams.commonId, asyncApexId, acqContact);
                acquisitionContactsMap.put(acqContact.Id, acqContact);

                for(MA_DS_Applied_Rule__c packageRule : acqContact.MA_DS_Applied_Rules__r) {
                    updatePackageAppliedRule(packageRule, appliedRulesMap);
                }
            }
        }
        
        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        
        if(acquisitionContactsMap.size() > 0) {
            updatePackageAppliedRules(appliedRulesMap);
            updateAcquisitionContacts(acquisitionContactsMap);
        }
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Contact with Package Common Id, Async Apex Job Id & Package Stage (if needed).
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	                    DESCRIPTION (Data Type Id, Package Common Id)
    * @param    asyncApexId	                    DESCRIPTION (Data Type Id, Async Apex Job Id)
    * @param    acqContact	                    DESCRIPTION (Data Type Acquisition_Contacts__c, Acquisition Contact record)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateAcquisitionContact(Id commonId, Id asyncApexId, Acquisition_Contacts__c acqContact) {
        acqContact.MA_DS_Package_Common_Id__c = commonId;
        acqContact.MA_DS_Package_Async_Apex_Id__c = asyncApexId;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Package Document IUT type Applied Rule with "Need To Deliver" as true and "Need To Generate" as false.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageAppliedRule	        DESCRIPTION (Data Type MA_DS_Applied_Rule__c, Package Document IUT type Applied Rule for Acquisition Contact)
    * @param    appliedRulesMap	            DESCRIPTION (Data Type Map<Id, MA_DS_Applied_Rule__c>, Map of Applied Rule Id to updated Applied Rule record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageAppliedRule(MA_DS_Applied_Rule__c packageAppliedRule, Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap) {
        packageAppliedRule.MA_DS_Need_To_Deliver__c = true;
        packageAppliedRule.MA_DS_Need_To_Generate__c = false;
        appliedRulesMap.put(packageAppliedRule.Id, packageAppliedRule);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Package Document IUT type Applied Rules with "Need To Deliver" as true and "Need To Generate" as false.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRulesMap	            DESCRIPTION (Data Type Map<Id, MA_DS_Applied_Rule__c>, Map of Applied Rule Id to updated Applied Rule record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageAppliedRules(Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap) {
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
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the "Package Prep Date" & "Integration Status" for each Package Distribution processed for Package Prep.
    * Notifies user of the completion of the Package Prep process.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids processed for Package Prep)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePackageDistributions(Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = [SELECT Id, MA_DS_Integration_Status__c, MA_DS_Package_Prep_Date__c
                                                                FROM MA_DS_Package_Distribution__c
                                                                WHERE Id IN :pkgDistributionIds];

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            pkgDistribution.MA_DS_Package_Prep_Date__c = Datetime.now();
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
    * Method to update the Package Audit record if the Job's ExecutionOrigin is AUDIT_FAILED_REGEN.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	            DESCRIPTION (Data Type Boolean, True if Execution Origin is AUDIT_FAILED_REGEN)
    * @param    acqCompanyId	                DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePackageAuditIfNeeded(Boolean isAuditFailedRegen, Id acqCompanyId) {
        if(isAuditFailedRegen) {
            List<MA_DS_Audit__c> auditList = [SELECT Id, MA_DS_Status__c, MA_DS_Failed_Common_Id__c, MA_DS_Failed_Regenerate_Attempt_Count__c
                                              FROM MA_DS_Audit__c
                                              WHERE MA_DS_Acquisition_Company__c = :acqCompanyId AND
                                              MA_DS_Audit_Type__c = :AUDIT_TYPE_PACKAGE];

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
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to notify user in case an exception is thrown while sending the API Request or when Status Code > 300 or any other exception.
    * Also used to send success notification to the Target user, if no error is encountered while sending the API Request or no errors in the HttpResponse.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    isAuditFailedRegen	            DESCRIPTION (Data Type Boolean, True if Execution Origin is AUDIT_FAILED_REGEN)
    * @param    success	                        DESCRIPTION (Data Type Boolean, True if no error were encountered while sending API request and no errors in the HttpResponse)
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    totalContacts	                DESCRIPTION (Data Type Integer, Denotes total number of API requests sent to Docusign CLM)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void notifyTargetIfNeeded(Boolean isAuditFailedRegen, Boolean success, Id srcRecordId, Integer totalContacts) {
        if(!isAuditFailedRegen) {
            Set<String> userIds = new Set<String> {String.valueOf(UserInfo.getUserId())};
            String notificationTitle = success ? CALLOUT_SUCCESS_NOTIFICATION_TITLE : CALLOUT_FAILED_NOTIFICATION_TITLE;
            String notificationBody = success ? String.format(CALLOUT_SUCCESS_NOTIFICATION_BODY, new String[] {String.valueOf(totalContacts)}) : CALLOUT_FAILED_NOTIFICATION_BODY;
            MA_MessageProcessing.initNotificationMessaging(MESSAGING_CONFIG, notificationTitle, notificationBody, String.valueOf(srcRecordId), userIds, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
            MA_MessageProcessing.processMessages(MA_MessageProcessing.ExecutionType.NOTIFICATION_JOB);
        }
    }
}