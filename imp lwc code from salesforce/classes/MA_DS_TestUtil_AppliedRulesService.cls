/**
 * Test Utility service class to setup Applied Rules for the different Package Distributions.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         24/12/2023      Chakshu Malhotra        Adds utility methods to setup Applied Rules for the different Package Distributions.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_AppliedRulesService {

    private static final String ACQ_CONTACT_SOBJECT = 'Acquisition_Contacts__c';
    private static final String ACQ_COMP_SOBJECT = 'Acquisition_Compensation__c';
    
    private static final String ACQ_COMPANY_FILTER = 'Acquisition_Company__c = :acqCompany';
    private static final String NO_OFFER_FILTER = 'MA_DS_No_Offer__c = :noOffer';
    private static final String OFFER_DECLINED_FILTER = 'MA_DS_Offer_Declined__c = :offerDeclined';

    private static final String EXECUTIVE_FILTER = 'Executive__c = :executive';
    private static final String PEOPLE_MANAGER_FILTER = 'People_Manager__c = :peopleManager';
    private static final String CONTRY_FILTER = 'Office_Address_Country__c = :officeCountry';
    private static final String STATE_FILTER = 'Office_Address_State_Province__c = :officeState';
    private static final String KEY_CRITICAL_EMP_FILTER = 'Key_Critical_Employee__c = :keyCriticalEmp';
    private static final String STATE_ILLINOIS_FILTER = 'Office_Address_State_Province__c != :officeStateIllinois';
    private static final String STATE_WASHINGTON_FILTER = 'Office_Address_State_Province__c != :officeStateWashington';
    private static final String STATE_CALIFORNIA_FILTER = 'Office_Address_State_Province__c != :officeStateCalifornia';

    private static final String ACQ_CONTACTS_QUERY_STR = 'SELECT {0}, (SELECT {1} FROM Acquisition_Compensation__r{2} LIMIT 1) FROM Acquisition_Contacts__c WHERE {3}';
    
    private static final Map<String, String> CHILD_RELATIONSHIP_MAP = new Map<String, String> {'Acquisition_Compensation__c' => 'Acquisition_Compensation__r'};

    private static List<String> acqCompSubQueryFields {
        get {
            if(acqCompSubQueryFields == null) {
                acqCompSubQueryFields = new List<String> {'Id', 'Job_Grade__c', 'Annualized_Base_Salary__c', 'Flextime_Eligible__c', 'Stock_Grant_Amount__c', 
                    'Additional_Stock_Grant_Amount__c', 'Stock_Grant_Date__c', 'Pay_Rate_Type__c', 'Stock_Reason__c', 'Pay_Plan__c', 'Time_Type__c'};
            }
            return acqCompSubQueryFields;
        }set;
    }

    private static List<String> acqContactsQueryFields {
        get {
            if(acqContactsQueryFields == null) {
                acqContactsQueryFields = new List<String> {'Id', 'Name', 'Business_Title__c', 'Gender__c', 'Work_Location_Status__c', 'Email_Address_Target__c', 
                    'Personal_Email_Address__c', 'Office_Address_Country__c', 'Office_Address_State_Province__c', 'Office_Address_City__c', 'Employee_Type__c', 
                    'Confirmed_On__c', 'Hire_Date__c', 'Pay_Rate_Type__c', 'People_Manager__c', 'Executive__c', 'Key_Critical_Employee__c'};
            }
            return acqContactsQueryFields;
        }set;
    }

    public static List<Acquisition_Contacts__c> getAquisitionContacts(Id acqCompanyId, MA_DS_Package_Distribution__c packageDistribution) {
        MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper = MA_DS_TestUtil_PackageDistributions.getDistributionWrapper(packageDistribution.Name);
        String acqContactFields = String.join(acqContactsQueryFields, ', ');
        String acqCompensationFields = String.join(acqCompSubQueryFields, ', ');
        String acqContactFilters = containsQueryFilters(ACQ_CONTACT_SOBJECT, distributionWrapper) ? getAcqContactFilters(distributionWrapper) : '';
        String acqCompFilters = containsQueryFilters(ACQ_COMP_SOBJECT, distributionWrapper) ? (' WHERE ' + getAcqCompFilters(distributionWrapper)) : '';
        String queryString = String.format(ACQ_CONTACTS_QUERY_STR, new String[] {acqContactFields, acqCompensationFields, acqCompFilters, acqContactFilters});
        Map<String, Object> bindMap = getQueryBindMap(acqCompanyId, distributionWrapper);
        return (List<Acquisition_Contacts__c>)Database.queryWithBinds(queryString, bindMap, AccessLevel.SYSTEM_MODE);
    }

    private static Boolean containsQueryFilters(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        Boolean containsQueryFilters = false;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                containsQueryFilters = isAcqContact ? true : false;
            }when US_OTHERS {
                containsQueryFilters = isAcqContact ? true : false;
            }when US_KEY_EMP, IN_KEY_EMP {
                containsQueryFilters = isAcqContact ? true : false;
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                containsQueryFilters = isAcqContact ? true : false;
            }when US_ALL_EMP, IN_ALL_EMP {
                containsQueryFilters = isAcqContact ? true : false;
            }
        }

        return containsQueryFilters;
    }

    private static String getAcqCompFilters(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        String queryFilters = '';

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                queryFilters += '';
            }when US_OTHERS {
                queryFilters += '';
            }when US_KEY_EMP, IN_KEY_EMP {
                queryFilters += '';
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                queryFilters += '';
            }when US_ALL_EMP, IN_ALL_EMP {
                queryFilters += '';
            }
        }

        return queryFilters;
    }

    private static String getAcqContactFilters(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        String queryFilters = ACQ_COMPANY_FILTER + ' AND ' + NO_OFFER_FILTER + ' AND ' + OFFER_DECLINED_FILTER;

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                queryFilters += ' AND ' + CONTRY_FILTER + ' AND ' + STATE_FILTER + ' AND ' + PEOPLE_MANAGER_FILTER + ' AND ' + EXECUTIVE_FILTER;
            }when US_OTHERS {
                queryFilters += ' AND ' + CONTRY_FILTER + ' AND ' + STATE_ILLINOIS_FILTER + ' AND ' + STATE_WASHINGTON_FILTER + ' AND ' + STATE_CALIFORNIA_FILTER + ' AND ' + PEOPLE_MANAGER_FILTER + ' AND ' + EXECUTIVE_FILTER;
            }when US_KEY_EMP, IN_KEY_EMP {
                queryFilters += ' AND ' + CONTRY_FILTER + ' AND ' + KEY_CRITICAL_EMP_FILTER + ' AND ' + PEOPLE_MANAGER_FILTER + ' AND ' + EXECUTIVE_FILTER;
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                queryFilters += ' AND ' + CONTRY_FILTER + ' AND ' + KEY_CRITICAL_EMP_FILTER + ' AND ' + PEOPLE_MANAGER_FILTER + ' AND ' + EXECUTIVE_FILTER;
            }when US_ALL_EMP, IN_ALL_EMP {
                queryFilters += ' AND ' + CONTRY_FILTER + ' AND ' + EXECUTIVE_FILTER;
            }
        }

        return queryFilters;
    }

    private static Map<String, Object> getQueryBindMap(Id acqCompanyId, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        Map<String, Object> bindMap = new Map<String, Object>();
        bindMap.put('acqCompany', acqCompanyId);
        bindMap.put('noOffer', false);
        bindMap.put('offerDeclined', false);
        bindMap.put('officeCountry', distributionWrapper.country);
        bindMap.put('officeState', distributionWrapper.state);
        bindMap.put('officeStateIllinois', 'Illinois');
        bindMap.put('officeStateWashington', 'Washington');
        bindMap.put('officeStateCalifornia', 'California');
        bindMap.put('executive', getExecutiveValue(distributionWrapper));
        bindMap.put('peopleManager', getPeopleManagerValue(distributionWrapper));
        bindMap.put('keyCriticalEmp', getKeyCriticalEmpValue(distributionWrapper));
        return bindMap;
    }

    private static Boolean getExecutiveValue(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        Boolean executiveVal = false;

        switch on distributionWrapper.distributionType {
            when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                executiveVal = true;
            }
        }

        return executiveVal;
    }

    private static Boolean getPeopleManagerValue(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        Boolean peopleManagerVal = false;

        switch on distributionWrapper.distributionType {
            when US_KEY_EMP, IN_KEY_EMP {
                peopleManagerVal = true;
            }
        }

        return peopleManagerVal;
    }

    private static String getKeyCriticalEmpValue(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        String keyCriticalEmpVal = null;

        switch on distributionWrapper.distributionType {
            when US_KEY_EMP, IN_KEY_EMP {
                keyCriticalEmpVal = 'Key';
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                keyCriticalEmpVal = 'Critical';
            }
        }

        return keyCriticalEmpVal;
    }

    public static Boolean applyTemplateRule(Acquisition_Contacts__c acqContact, Acquisition_Compensation__c acqComp, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        Set<String> states = new Set<String> {'Illinois', 'Washington', 'California'};
        Set<String> allStates = new Set<String> {'Illinois', 'Washington', 'California', 'New York'};

        Boolean applyTemplateRule = false;

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                applyTemplateRule = acqContact.Office_Address_Country__c.equals(templateWrapper.country) && acqContact.Office_Address_State_Province__c.equals(templateWrapper.state);
            }when PIIA_US_OTHERS {
                applyTemplateRule = acqContact.Office_Address_Country__c.equals(templateWrapper.country) && !states.contains(acqContact.Office_Address_State_Province__c);
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                applyTemplateRule = acqContact.Office_Address_Country__c.equals(templateWrapper.country) && acqContact.Employee_Type__c.equals('Regular') && 
                                    acqContact.Email_Address_Target__c.endsWith('.com') && acqContact.Confirmed_On__c > Datetime.valueOf('2024-02-02 04:09:00') && acqContact.Hire_Date__c != null && 
                                    acqComp.Job_Grade__c > 0 && acqComp.Annualized_Base_Salary__c >= 10000;
            }when CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE {
                applyTemplateRule = acqContact.Office_Address_Country__c.equals(templateWrapper.country) && acqContact.Office_Address_State_Province__c.equals(templateWrapper.state) && 
                                    acqContact.Name.startsWith('testN') && acqContact.Personal_Email_Address__c.contains('@testmail') && 
                                    acqComp.Flextime_Eligible__c && acqComp.Job_Grade__c > 0;
            }when NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE {
                applyTemplateRule = acqContact.Office_Address_Country__c.equals(templateWrapper.country) && acqContact.Office_Address_State_Province__c.equals(templateWrapper.state) && 
                                    acqContact.Name.startsWith('testN') && !acqContact.Personal_Email_Address__c.contains('@hotmail') && 
                                    acqComp.Flextime_Eligible__c && acqComp.Job_Grade__c > 0;
            }when SF_FAIR_CHANCE_ORDINANCE {
                applyTemplateRule = acqContact.Office_Address_Country__c.equals(templateWrapper.country) && acqContact.Office_Address_State_Province__c.equals(templateWrapper.state) && 
                                    acqContact.Office_Address_City__c.equals(templateWrapper.city);
            }when US_HIPAA_NOTICE {
                applyTemplateRule = acqContact.Office_Address_Country__c.equals(templateWrapper.country) && allStates.contains(acqContact.Office_Address_State_Province__c);
            }when GL_RSU_LETTER {
                applyTemplateRule = acqContact.Employee_Type__c.equals('Regular') && acqContact.Pay_Rate_Type__c.equals('Salary') && 
                                    (acqComp.Stock_Grant_Amount__c > 0 || acqComp.Additional_Stock_Grant_Amount__c > 0) && acqComp.Stock_Grant_Date__c != null;
            }when GL_OBA_FORM, GL_SEC_BEST_PRAC, GL_SIG_ACK_FORM, GL_COC, GL_EMP_HANDBOOK, MANAGER_SUMMARY {
                applyTemplateRule = true;
            }
        }

        return applyTemplateRule;
    }

    public static AuditFlagsWrapper getAuditFlagsWrapper(MA_DS_In_Use_Template__c inUseTemplate) {
        AuditFlagsWrapper wrapperInstance = new AuditFlagsWrapper();
        wrapperInstance.auditAll = inUseTemplate.MA_DS_Audit_All__c;
        wrapperInstance.templateId = inUseTemplate.MA_DS_Template_Being_Used__c;
        wrapperInstance.templateDocumentType = inUseTemplate.MA_DS_Template_Being_Used__r.MA_DS_Template_Document_Type__c;
        Boolean suppressFlags = (inUseTemplate.MA_DS_Audit_All__c || inUseTemplate.MA_DS_Suppress_Audit_Flags__c);

        if(!suppressFlags) {
            updateAuditFlagsWrapperWithFlagsMaps(wrapperInstance, inUseTemplate);
        }

        return wrapperInstance;
    }

    private static void updateAuditFlagsWrapperWithFlagsMaps(AuditFlagsWrapper wrapperInstance, MA_DS_In_Use_Template__c inUseTemplate) {
        Type auditFlagsJSONApexType = Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>.class;
        Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>> auditFlagsMap = (Map<String, Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper>>)JSON.deserialize(inUseTemplate.MA_DS_Audit_Flags_JSON__c, auditFlagsJSONApexType);

        for(String sObjectName : auditFlagsMap.keySet()) {
            String sObjectKey = sObjectName.equalsIgnoreCase(ACQ_CONTACT_SOBJECT) ? sObjectName : CHILD_RELATIONSHIP_MAP.get(sObjectName);
            Map<String, MA_DS_AddRulesCriteriaWrapper.FieldWrapper> fieldMap = auditFlagsMap.get(sObjectName);

            for(String fieldKey : fieldMap.keySet()) {
                String concatenatedKey = sObjectKey + fieldKey;
                wrapperInstance.auditFlagsTypeMap.put(concatenatedKey, fieldMap.get(fieldKey).type);
                wrapperInstance.auditFlagsSampleSizeMap.put(concatenatedKey, fieldMap.get(fieldKey).sampleSize);
            }

            wrapperInstance.auditFlagsFieldMap.put(sObjectKey, new List<String>(fieldMap.keySet()));
        }
    }

    public static List<String> getAppliedAuditFlagKeys(AuditFlagsWrapper wrapperInstance, Acquisition_Contacts__c acqContact) {
        Set<String> appliedAuditFlagKeys = new Set<String>();

        for(String sObjectKey : wrapperInstance.auditFlagsFieldMap.keySet()) {
            for(String fieldKey : wrapperInstance.auditFlagsFieldMap.get(sObjectKey)) {
                String concatenatedkey = sObjectKey + fieldKey;
                
                String fieldType = wrapperInstance.auditFlagsTypeMap.get(concatenatedkey);
                Integer maxSampleSize = wrapperInstance.auditFlagsSampleSizeMap.get(concatenatedkey);

                Object fieldValue = sObjectKey.equalsIgnoreCase(ACQ_CONTACT_SOBJECT) ? acqContact.get(fieldKey) : acqContact.getSObjects(sObjectKey)[0].get(fieldKey);
                String appliedAuditFlagKey = MA_DS_RulesCriteriaQueryFormatter.strategy.getAppliedAuditFlagKey(concatenatedKey, fieldValue, fieldType);

                if(updateAppliedAuditFlagsMap(wrapperInstance.appliedAuditFlagsMap, appliedAuditFlagKey, maxSampleSize)) {
                    appliedAuditFlagKeys.add(appliedAuditFlagKey);
                }
            }
        }

        return new List<String>(appliedAuditFlagKeys);
    }

    private static Boolean updateAppliedAuditFlagsMap(Map<String, Integer> appliedAuditFlagsMap, String appliedAuditFlagKey, Integer maxSampleSize) {
        Boolean updated = false;
        Boolean containsAppliedAuditFlagKey = appliedAuditFlagsMap.containsKey(appliedAuditFlagKey);
        Integer appliedSampleSize = containsAppliedAuditFlagKey ? appliedAuditFlagsMap.get(appliedAuditFlagKey) : 0;

        if(appliedSampleSize < maxSampleSize) {
            updated = true;
            appliedAuditFlagsMap.put(appliedAuditFlagKey, (appliedSampleSize + 1));
        }

        return updated;
    }

    public class AuditFlagsWrapper {
        public Id templateId {get; set;}
        public Boolean auditAll {get; set;}
        public String templateDocumentType {get; set;}

        public Map<String, String> auditFlagsTypeMap = new Map<String, String>();
        public Map<String, Integer> appliedAuditFlagsMap = new Map<String, Integer>();
        public Map<String, Integer> auditFlagsSampleSizeMap = new Map<String, Integer>();
        public Map<String, List<String>> auditFlagsFieldMap = new Map<String, List<String>>();
    }
}