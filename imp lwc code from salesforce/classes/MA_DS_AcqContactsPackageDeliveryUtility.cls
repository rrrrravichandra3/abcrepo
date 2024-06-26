/**
 * W-13465459
 * Utility class for PackageDeliveryJob & PackageDeliveryJobFinalizer implementations within MA_DS_AcqContactsPackageDeliveryService.
 * Processes each Acquisition Contact & sends Package Documents (Template Ids) details to DocuSign CLM via API callout.
 * Prepares a wrapper instance, to be used by the implementation of MA_DS_CalloutFramework.CalloutRequestParams for the API callout.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         26/05/2023      Chakshu Malhotra        W-13465459 - Provides utility methods to process each Acquisition Contact & sends Package Documents (Template Ids) details to DocuSign CLM via API callout.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AcqContactsPackageDeliveryUtility {
    
    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String IUT_DOCUMENT_TYPE_PACKAGE = Label.MA_DS_Document_Type_Package;
    private static final String TEMPLATE_TYPE_BGC = Label.MA_DS_Template_Type_Background_Check;

    private static final String INTEGRATION_STATUS_NONE = Label.MA_DS_Eligible_Integration_Status;

    private static final String MESSAGING_CONFIG = Label.MA_DS_Messaging_Config_Package_Delivery_Callout;
    private static final String CALLOUT_CONFIG_PACKAGE_DELIVERY = Label.MA_DS_Callout_Config_Package_Delivery;

    private static final String CALLOUT_FAILED_NOTIFICATION_BODY = Label.MA_DS_Error_Contact_Admin_Body;
    private static final String CALLOUT_FAILED_NOTIFICATION_TITLE = Label.MA_DS_Package_Delivery_Callout_Failed_Title;

    private static final String CALLOUT_SUCCESS_NOTIFICATION_BODY = Label.MA_DS_Package_Delivery_Callout_Notification_Body;
    private static final String CALLOUT_SUCCESS_NOTIFICATION_TITLE = Label.MA_DS_Package_Delivery_Callout_Notification_Title;
    private static final String SCHEDULED_CALLOUT_SUCCESS_NOTIFICATION_BODY = Label.MA_DS_Scheduled_Package_Delivery_Callout_Notification_Body;

    private static final String ACQ_CONTACT_IDS_VAR = 'acqContacts';
    private static final String ACQ_CONTACT_IDS_FILTER = 'Id IN :{0}';
    
    private static final String NO_OFFER_VAR = 'noOffer';
    private static final String NO_OFFER_FILTER = ' AND MA_DS_No_Offer__c = :{0}';

    private static final String OFFER_DECLINED_VAR = 'offerDeclined';
    private static final String OFFER_DECLINED_FILTER = ' AND MA_DS_Offer_Declined__c = :{0}';

    private static final String RULE_TYPE_VAR = 'ruleType';
    private static final String RULE_TYPE_FILTER = 'MA_DS_Rule_Type__c = :{0}';

    private static final String DOC_TYPE_VAR = 'docType';
    private static final String DOC_TYPE_FILTER = ' AND MA_DS_Template__r.MA_DS_Template_Document_Type__c = :{0}';

    private static final String PKG_DISTRIBUTION_IDS_VAR = 'pkgDistributionIds';
    private static final String PKG_DISTRIBUTION_IDS_FILTER = ' AND MA_DS_Package_Distribution__c IN :{0}';

    private static final String NEED_DELIVER_VAR = 'needGenerate';
    private static final String NEED_DELIVER_FILTER = ' AND MA_DS_Need_To_Deliver__c = :{0}';

    private static final String ACQ_COMPENSATION_SUB_QUERY_STR = '(SELECT {0} FROM Acquisition_Compensation__r LIMIT 1)';
    private static final String APPLIED_RULES_SUB_QUERY_STR = '(SELECT {0} FROM MA_DS_Applied_Rules__r WHERE {1})';
    private static final String ACQ_CONTACTS_QUERY_STR = 'SELECT {0}, {1}, {2} FROM Acquisition_Contacts__c WHERE {3}';

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Acquisition Compensation sub query.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> acqCompSubQueryFields {
        get {
            if(acqCompSubQueryFields == null) {
                acqCompSubQueryFields = new List<String> {'Id', 'Additional_Field_1__c', 'Additional_Field_2__c', 'Additional_Field_3__c', 'Additional_Field_4__c', 'Additional_Field_5__c'};
            }
            return acqCompSubQueryFields;
        }set;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Applied Rules sub query.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> appliedRulesSubQueryFields {
        get {
            if(appliedRulesSubQueryFields == null) {
                appliedRulesSubQueryFields = new List<String> {'Id', 'MA_DS_Package_Distribution__c', 'MA_DS_Package_Distribution__r.MA_DS_Package__c', 'MA_DS_Template__c', 
                    'MA_DS_Flagged_For_Audit__c', 'MA_DS_Need_To_Deliver__c'};
            }
            return appliedRulesSubQueryFields;
        }set;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Property to hold the List of Query fields for the Acquisition Contacts query.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<String> acqContactsQueryFields {
        get {
            if(acqContactsQueryFields == null) {
                acqContactsQueryFields = new List<String> {'Id', 'Name', 'First_Name_Legal__c', 'Last_Name_Legal__c', 'First_Name_Preferred__c', 'Last_Name_Preferred__c', 'MA_DS_Preferred_Email_Address__c', 
                    'MA_DS_Envelope_Void_Period_Days__c', 'MA_DS_Envelope_Void_Date__c', 'Office_Address_Country__c', 'Background_Check__c', 'MA_DS_Custom_Package_Envelope_Email__c', 'Full_Name_Preferred__c', 
                    'Additional_Field_1__c', 'Additional_Field_2__c', 'Additional_Field_3__c', 'Additional_Field_4__c', 'Additional_Field_5__c'};
            }
            return acqContactsQueryFields;
        }set;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Package Distribution records based on the packageDeliveryPDIds.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageDeliveryPDIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Package Delivery)
    * @return   List<MA_DS_Package_Distribution__c>         DESCRIPTION (return List of Package Distributions)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<MA_DS_Package_Distribution__c> getPackageDistributions(Set<Id> packageDeliveryPDIds) {
        return [SELECT Id, CreatedById, MA_DS_Package__c, MA_DS_Custom_Package_Envelope_Email__c, MA_DS_Package__r.MA_DS_Acquisition_Company__c 
                FROM MA_DS_Package_Distribution__c
                WHERE Id IN :packageDeliveryPDIds];
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Concatenated Id (Package Id + Template Id) to "Sort Order" value, used to set the Order of Package Documents when being attached in the Package Delivery Email.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distributions)
    * @return   Map<String, Integer>                DESCRIPTION (return Map of Concatenated Id (Package Id + Template Id) to "Sort Order" value)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<String, Integer> getSortOrderMap(List<MA_DS_Package_Distribution__c> pkgDistributions) {
        Map<String, Integer> sortOrderMap = new Map<String, Integer>();

        Set<Id> packageIds = new Set<Id>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            packageIds.add(pkgDistribution.MA_DS_Package__c);
        }

        for(MA_DS_In_Use_Template__c inUseTemplate : [SELECT Id, MA_DS_Concatenated_Id__c, MA_DS_Sort_Order__c FROM MA_DS_In_Use_Template__c WHERE MA_DS_Package_Using__c IN :packageIds]) {
            sortOrderMap.put(inUseTemplate.MA_DS_Concatenated_Id__c, Integer.valueOf(inUseTemplate.MA_DS_Sort_Order__c));
        }

        return sortOrderMap;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Package Distribution record Id to the "Custom Package Envelope Email" flag value.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributions	                DESCRIPTION (Data Type List<MA_DS_Package_Distribution__c>, List of Package Distributions)
    * @return   Map<Id, Boolean>                    DESCRIPTION (return Map of Package Distribution Id to "Custom Package Envelope Email" flag)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<Id, Boolean> getCustomDeliveryEmailMap(List<MA_DS_Package_Distribution__c> pkgDistributions) {
        Map<Id, Boolean> customPackageEnvelopeEmailMap = new Map<Id, Boolean>();

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            customPackageEnvelopeEmailMap.put(pkgDistribution.Id, pkgDistribution.MA_DS_Custom_Package_Envelope_Email__c);
        }

        return customPackageEnvelopeEmailMap;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch Acquisition Company record details containing Package Envelope Email Subject & Body, for the given Acquisition Company record Id.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                    DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @return   Acquisition_Company__c              DESCRIPTION (return Acquisition Company record)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Acquisition_Company__c getAcquisitionCompanyWithPackageEnvelopeEmail(Id acqCompanyId) {
        return [SELECT Id, MA_DS_Package_Envelope_Email_Subject__c, MA_DS_Package_Envelope_Email_Body__c
                FROM Acquisition_Company__c
                WHERE Id = :acqCompanyId LIMIT 1];
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the List of Acquisition Contacts to be processed in a single batch of Package Delivery API callout.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageDeliveryPDIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Package Delivery)
    * @param    acqContactIds	                            DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids to identify the Applied Rule records)
    * @return   List<Acquisition_Contacts__c>               DESCRIPTION (return List of Acquisition Contacts)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> getAquisitionContacts(Set<Id> packageDeliveryPDIds, Set<String> acqContactIds) {
        String acqCompQueryString = String.format(ACQ_COMPENSATION_SUB_QUERY_STR, new String[] {String.join(acqCompSubQueryFields, ', ')});

        String appliedRulesFilters = getAppliedRulesSubQueryFilters();
        String appliedRulesQueryString = String.format(APPLIED_RULES_SUB_QUERY_STR, new String[] {String.join(appliedRulesSubQueryFields, ', '), appliedRulesFilters});

        String acqContactsFilters = getAcquisitionContactsQueryFilters();
        String acqContactsQueryString = String.format(ACQ_CONTACTS_QUERY_STR, new String[] {String.join(acqContactsQueryFields, ', '), acqCompQueryString, appliedRulesQueryString, acqContactsFilters});

        Map<String, Object> bindMap = getQueryBindMap(packageDeliveryPDIds, acqContactIds);
        return getAquisitionContacts(acqContactsQueryString, bindMap);
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Applied Rules sub queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   String                                      DESCRIPTION (return Filters string, used to form the Acquisition Contacts queryString)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAppliedRulesSubQueryFilters()  {
        String filters = String.format(RULE_TYPE_FILTER, new String[] {RULE_TYPE_VAR});
        filters += String.format(DOC_TYPE_FILTER, new String[] {DOC_TYPE_VAR});
        filters += String.format(PKG_DISTRIBUTION_IDS_FILTER, new String[] {PKG_DISTRIBUTION_IDS_VAR});
        filters += String.format(NEED_DELIVER_FILTER, new String[] {NEED_DELIVER_VAR});
        return filters;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the Filters string, to be used to form the Acquisition Contacts queryString (to fetch records dynamically using Database.queryWithBinds() method).
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   String                                      DESCRIPTION (return Filters string, used to form the Acquisition Contacts queryString)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static String getAcquisitionContactsQueryFilters()  {
        String filters = String.format(ACQ_CONTACT_IDS_FILTER, new String[] {ACQ_CONTACT_IDS_VAR});
        filters += String.format(NO_OFFER_FILTER, new String[] {NO_OFFER_VAR});
        filters += String.format(OFFER_DECLINED_FILTER, new String[] {OFFER_DECLINED_VAR});
        return filters;
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to fetch the bindMap for the Acquisition Contacts queryString, sets value for all the Bind Variables used in the queryString.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageDeliveryPDIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Package Delivery)
    * @param    acqContactIds	                            DESCRIPTION (Data Type Set<String>, Set of Acquisition Contact Ids to identify the Applied Rule records)
    * @return   Map<String, Object>                         DESCRIPTION (return bindMap for the Acquisition Contacts queryString)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, Object> getQueryBindMap(Set<Id> packageDeliveryPDIds, Set<String> acqContactIds) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put(ACQ_CONTACT_IDS_VAR, acqContactIds);
        bindMap.put(NO_OFFER_VAR, false);
        bindMap.put(OFFER_DECLINED_VAR, false);
        bindMap.put(RULE_TYPE_VAR, IUT_TYPE_APPLIED_RULE);
        bindMap.put(DOC_TYPE_VAR, IUT_DOCUMENT_TYPE_PACKAGE);
        bindMap.put(PKG_DISTRIBUTION_IDS_VAR, packageDeliveryPDIds);
        bindMap.put(NEED_DELIVER_VAR, true);
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
            MA_AbstractLogger.logException(exType, MA_DS_AcqContactsPackageDeliveryUtility.class.getName());
        }

        return acqContacts;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Set of Background Check Regions (Office Address Countries) from the Acquisition Contacts.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContacts                             DESCRIPTION (Data Type Set<String>, Set of Office Address Countries for the Acquisition Contacts)
    * @return   Set<String>                             DESCRIPTION (return Set of Background Check Regions (Office Address Countries) from the Acquisition Contacts)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Set<String> getBackgroundCheckRegions(List<Acquisition_Contacts__c> acqContacts) {
        Set<String> bgcRegions = new Set<String>();
        for(Acquisition_Contacts__c acqContact : acqContacts) {
            bgcRegions.add(acqContact.Office_Address_Country__c);
        }
        return bgcRegions;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the Map of Background Check Email Templates for the Acquisition Contacts based on their Office Address Countries.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqCompanyId	                        DESCRIPTION (Data Type Id, Acquisition Company record Id)
    * @param    bgcRegions                              DESCRIPTION (Data Type Set<String>, Set of Office Address Countries for the Acquisition Contacts)
    * @return   Map<String, MA_DS_Template__c>          DESCRIPTION (return Map of Background Check Region to the the Background Check type Template record details)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Map<String, MA_DS_Template__c> getBackgroudCheckEmailTemplateMap(Id acqCompanyId, Set<String> bgcRegions) {
        Map<String, MA_DS_Template__c> bgcEmailTemplateMap = new Map<String, MA_DS_Template__c>();

        for(MA_DS_Template__c bgcEmailTemplate : [SELECT Id, MA_DS_Background_Check_Region__c, MA_DS_Background_Check_URL__c, MA_DS_Background_Check_Email_Subject__c, MA_DS_Background_Check_Email_Body__c
                                                  FROM MA_DS_Template__c
                                                  WHERE MA_DS_Template_Type__c = :TEMPLATE_TYPE_BGC AND
                                                  MA_DS_Background_Check_Region__c IN :bgcRegions AND
                                                  MA_DS_Acquisition_Company__c = :acqCompanyId]) {
            bgcEmailTemplateMap.put(bgcEmailTemplate.MA_DS_Background_Check_Region__c, bgcEmailTemplate);
        }

        return bgcEmailTemplateMap;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to prepare the wrapper instance of PackageDeliveryParams, to be used by API callout request to form the payload for Package Delivery.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    commonId	                            DESCRIPTION (Data Type Id, Common Id used for the payload)
    * @param    acqCompany	                            DESCRIPTION (Data Type Acquisition_Company__c, Acquisition Company record)
    * @param    firstBatch                              DESCRIPTION (Data Type Boolean, True if the API callout is the first batch of the Acquisition Contacts processed for Package Delivery)
    * @param    finalBatch                              DESCRIPTION (Data Type Boolean, True if the API callout is the final batch of the Acquisition Contacts processed for Package Delivery)
    * @param    singleContactDelivery                   DESCRIPTION (Data Type Boolean, True if the Package Delivery API callout is initiated for the Single Contact)
    * @param    acqContacts	                            DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts along with their Compensation & Applied Rule details)
    * @param    sortOrderMap	                        DESCRIPTION (Data Type Map<String, Integer>, Map of Concatenated Id (Package Id + Template Id) to "Sort Order" value)
    * @param    bgcEmailTemplates	                    DESCRIPTION (Data Type List<MA_DS_Template__c>, List of Background Check type Template record details)
    * @param    customDeliveryEmailMap	                DESCRIPTION (Data Type Map<Id, Boolean>, Map of Package Distribution Id to "Custom Package Envelope Email" flag value)
    * @return   MA_DS_CalloutFramework.RequestParams    DESCRIPTION (return MA_DS_CalloutFramework.RequestParams wrapper instance to be used by CalloutFramework to form request payload for the API callout)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static MA_DS_CalloutFramework.RequestParams getPackageDeliveryParams(Id commonId, Acquisition_Company__c acqCompany, Boolean firstBatch, Boolean finalBatch, Boolean singleContactDelivery, List<Acquisition_Contacts__c> acqContacts, Map<String, Integer> sortOrderMap, List<MA_DS_Template__c> bgcEmailTemplates, Map<Id, Boolean> customDeliveryEmailMap) {
        MA_DS_PackageDeliveryWrapper.PackageDeliveryParams packageDeliveryParams = new MA_DS_PackageDeliveryWrapper.PackageDeliveryParams();
        packageDeliveryParams.commonId = commonId;
        packageDeliveryParams.acqCompany = acqCompany;
        packageDeliveryParams.firstBatch = firstBatch;
        packageDeliveryParams.finalBatch = finalBatch;
        packageDeliveryParams.acqContacts = acqContacts;
        packageDeliveryParams.sortOrderMap = sortOrderMap;
        packageDeliveryParams.bgcEmailTemplates = bgcEmailTemplates;
        packageDeliveryParams.singleContactDelivery = singleContactDelivery;
        packageDeliveryParams.customDeliveryEmailMap = customDeliveryEmailMap;
        return packageDeliveryParams;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to make a callout to CLM Object API to start Package Delivery workflow using the CLM Callout Framework.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    srcRecordId	            DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    requestParams	        DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void calloutPackageDeliveryWorkflow(Id srcRecordId, MA_DS_CalloutFramework.RequestParams requestParams) {
        MA_DS_CalloutFramework.calloutStrategy.setCalloutConfig(CALLOUT_CONFIG_PACKAGE_DELIVERY)
                                              .setCalloutRequestParams(requestParams)
                                              .setCalloutRequest()
                                              .setResponseCallback()
                                              .initCallout(srcRecordId);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to check whether HttpRequest for Package Delivery is returned with success Status Code or error Status Code.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   Boolean             DESCRIPTION (return True if Http Request returned success Status Code)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Boolean calloutSuccess(MA_DS_CalloutFramework.RequestParams requestParams) {
        return ((MA_DS_PackageDeliveryWrapper.PackageDeliveryParams)requestParams).successResponse;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Package Docuemnt IUT type Applied Rules for each Acquisition Contact.
    * Applied Rules are updated with "Need To Deliver" as false.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParamsList	    DESCRIPTION (Data Type List<MA_DS_CalloutFramework.RequestParams>, List of RequestParams instances, one for each API Payload)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePackageAppliedRules(List<MA_DS_CalloutFramework.RequestParams> requestParamsList) {
        Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap = new Map<Id, MA_DS_Applied_Rule__c>();

        for(MA_DS_CalloutFramework.RequestParams requestParams : requestParamsList) {
            MA_DS_PackageDeliveryWrapper.PackageDeliveryParams packageDeliveryParams = (MA_DS_PackageDeliveryWrapper.PackageDeliveryParams)requestParams;

            for(Acquisition_Contacts__c acqContact : packageDeliveryParams.acqContacts) {
                for(MA_DS_Applied_Rule__c packageRule : acqContact.MA_DS_Applied_Rules__r) {
                    updatePackageAppliedRule(packageRule, appliedRulesMap);
                }
            }
        }

        if(appliedRulesMap.size() > 0) {
            updatePackageAppliedRules(appliedRulesMap);
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Package Document IUT type Applied Rule with "Need To Deliver" as false.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageAppliedRule	        DESCRIPTION (Data Type MA_DS_Applied_Rule__c, Package Document IUT type Applied Rule for Acquisition Contact)
    * @param    appliedRulesMap	            DESCRIPTION (Data Type Map<Id, MA_DS_Applied_Rule__c>, Map of Applied Rule Id to updated Applied Rule record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageAppliedRule(MA_DS_Applied_Rule__c packageAppliedRule, Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap) {
        packageAppliedRule.MA_DS_Need_To_Deliver__c = false;
        appliedRulesMap.put(packageAppliedRule.Id, packageAppliedRule);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Package Document IUT type Applied Rules with "Need To Deliver" as false.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRulesMap	            DESCRIPTION (Data Type Map<Id, MA_DS_Applied_Rule__c>, Map of Applied Rule Id to updated Applied Rule record)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updatePackageAppliedRules(Map<Id, MA_DS_Applied_Rule__c> appliedRulesMap) {
        Acquisition_Contacts_Trigger_Handler.triggerDisabled = true;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
        Database.SaveResult[] appliedRulesSRList = Database.update(appliedRulesMap.values(), false);
        MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(appliedRulesSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update the "Package Sent Date" & "Integration Status" for each Package Distribution processed for Package Delivery.
    * Notifies user of the completion of the Package Delivery process.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    pkgDistributionIds	            DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids processed for Package Delivery)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void updatePackageDistributions(Set<Id> pkgDistributionIds) {
        List<MA_DS_Package_Distribution__c> pkgDistributions = [SELECT Id, MA_DS_Integration_Status__c, MA_DS_Package_Sent_Date__c, MA_DS_Trigger_Package_Delivery__c
                                                                FROM MA_DS_Package_Distribution__c
                                                                WHERE Id IN :pkgDistributionIds];

        for(MA_DS_Package_Distribution__c pkgDistribution : pkgDistributions) {
            pkgDistribution.MA_DS_Trigger_Package_Delivery__c = false;
            pkgDistribution.MA_DS_Package_Sent_Date__c = Datetime.now();
            pkgDistribution.MA_DS_Integration_Status__c = INTEGRATION_STATUS_NONE;
        }

        if(pkgDistributions.size() > 0) {
            MA_DS_PackageDistributionTriggerHandler.triggerDisabled = true;
            Database.SaveResult[] pkgDistributionsSRList = Database.update(pkgDistributions, false);
            MA_AbstractLogger.getBulkLoggerStrategy().traceAndLogErrors(pkgDistributionsSRList, MA_AbstractLogger.BulkLoggerType.SAVE_RESULT);
        }
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to notify user in case an exception is thrown while sending the API Request or when Status Code > 300 or any other exception.
    * Also used to send success notification to the Target user, if no error is encountered while sending the API Request or no errors in the HttpResponse.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    success	                        DESCRIPTION (Data Type Boolean, True if no error were encountered while sending API request and no errors in the HttpResponse)
    * @param    srcRecordId	                    DESCRIPTION (Data Type Id, Source record Id which initiated the API callout)
    * @param    targetUserId	                DESCRIPTION (Data Type Id, The target User record Id who receives the Notification post all batches of API callouts)
    * @param    totalContacts	                DESCRIPTION (Data Type Integer, Denotes total number of API requests sent to Docusign CLM)
    * @param    executionOriginType	            DESCRIPTION (Data Type MA_DS_PackageDeliveryService.ExecutionOrigin, ExecutionOrigin enum type)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void notifyTargetIfNeeded(Boolean success, Id srcRecordId, Id targetUserId, Integer totalContacts, MA_DS_PackageDeliveryService.ExecutionOrigin executionOriginType) {
        Set<String> userIds = new Set<String> {String.valueOf(targetUserId)};
        String notificationTitle = success ? CALLOUT_SUCCESS_NOTIFICATION_TITLE : CALLOUT_FAILED_NOTIFICATION_TITLE;
        String notificationBody = success ? String.format((executionOriginType == MA_DS_PackageDeliveryService.ExecutionOrigin.SCHEDULED_DELIVERY) ? 
                                            SCHEDULED_CALLOUT_SUCCESS_NOTIFICATION_BODY : CALLOUT_SUCCESS_NOTIFICATION_BODY, new String[] {String.valueOf(totalContacts)}) : CALLOUT_FAILED_NOTIFICATION_BODY;
        MA_MessageProcessing.initNotificationMessaging(MESSAGING_CONFIG, notificationTitle, notificationBody, String.valueOf(srcRecordId), userIds, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
        MA_MessageProcessing.processMessages(MA_MessageProcessing.ExecutionType.NOTIFICATION_JOB);
    }
}