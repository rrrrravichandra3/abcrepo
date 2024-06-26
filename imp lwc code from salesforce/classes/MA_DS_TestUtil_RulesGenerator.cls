/**
 * Test Utility class to setup Rules (Rules Criteria JSON, Rules Criteria Query & Audit Flags JSON) data for In Use Templates & Package Distributions.
 * 
 * Version      Date            Author                  Description
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         05/12/2023      Chakshu Malhotra        Adds utility methods to setup Rules (Rules Criteria JSON, Rules Criteria Query & Audit Flags JSON) data for In Use Templates & Package Distributions.
 * --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_RulesGenerator implements MA_DS_TestUtil_RulesCriteriaService.RulesCriteriaGeneratorUtility {
    
    private static final String ACQ_CONTACT_SOBJECT = 'Acquisition_Contacts__c';
    private static final String ACQ_COMP_SOBJECT = 'Acquisition_Compensation__c';

    public static void generateRules(List<MA_DS_In_Use_Template__c> inUseTemplates, Boolean triggerDisabled) {
        MA_DS_RulesCriteriaQueryParser.skipQueryValidation = true;

        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper = MA_DS_TestUtil_Templates.getTemplateWrapper(inUseTemplate.MA_DS_Template_Being_Used__r.Name);

            MA_DS_TestUtil_RulesCriteriaService.getRulesCriteriaGeneratorStrategy(MA_DS_TestUtil_RulesCriteriaService.RulesSObject.IN_USE_TEMPLATE, new MA_DS_TestUtil_RulesGenerator())
                                               .initRulesCriteriaGenerator(templateWrapper)
                                               .initRulesCriteriaService()
                                               .generateRulesCriteria(inUseTemplate.Id);
        }
        MA_DS_TestUtil_RulesCriteriaService.updateRulesOnSObject(MA_DS_TestUtil_RulesCriteriaService.RulesSObject.IN_USE_TEMPLATE, triggerDisabled);
    }

    public List<String> getRulesSObjectTypes(MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> sObjectTypes;

        switch on templateWrapper.templateEnumType {
            when GL_OBA_FORM, GL_SEC_BEST_PRAC, GL_SIG_ACK_FORM, GL_COC, GL_EMP_HANDBOOK, MANAGER_SUMMARY {
                sObjectTypes = new List<String>();
            }when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_US_OTHERS, PIIA_TL, PIIA_KA, SF_FAIR_CHANCE_ORDINANCE, US_HIPAA_NOTICE {
                sObjectTypes = new List<String> {ACQ_CONTACT_SOBJECT};
            }when US_OFFER_LETTER, IN_OFFER_LETTER, CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE, NYC_PREG_EMP_RIGHTS_NOTICE, 
                  NYC_PAID_SICK_LEAVE_NOTICE, GL_RSU_LETTER {
                sObjectTypes = new List<String> {ACQ_CONTACT_SOBJECT, ACQ_COMP_SOBJECT};
            }
        }

        return sObjectTypes;
    }

    public List<String> getAuditSObjectTypes(MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> sObjectTypes;

        switch on templateWrapper.templateEnumType {
            when GL_OBA_FORM, GL_SEC_BEST_PRAC, GL_SIG_ACK_FORM, GL_COC, GL_EMP_HANDBOOK, CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE, 
                 NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE, SF_FAIR_CHANCE_ORDINANCE, US_HIPAA_NOTICE {
                sObjectTypes = new List<String>();
            }when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_US_OTHERS, PIIA_TL, PIIA_KA, US_OFFER_LETTER, IN_OFFER_LETTER, GL_RSU_LETTER, MANAGER_SUMMARY {
                sObjectTypes = new List<String> {ACQ_CONTACT_SOBJECT, ACQ_COMP_SOBJECT};
            }
        }

        return sObjectTypes;
    }

    public Boolean customLogic(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        Boolean customLogic = false;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when US_HIPAA_NOTICE {
                customLogic = isAcqContact ? true : false;
            }when GL_RSU_LETTER {
                customLogic = isAcqContact ? false : true;
            }when else {
                customLogic = false;
            }
        }

        return customLogic;
    }

    public List<String> ruleLogic(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> ruleLogic;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2'} : null;
            }when PIIA_US_OTHERS {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3', 'AND', '4'} : null;
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3', 'AND', '4', 'AND', '5'} : 
                                           new List<String> {'1', 'AND', '2'};
            }when CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3', 'AND', '4'} : 
                                           new List<String> {'1', 'AND', '2'};
            }when NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3', 'AND', '4'} : 
                                           new List<String> {'1', 'AND', '2'};
            }when SF_FAIR_CHANCE_ORDINANCE {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3'} : null;
            }when US_HIPAA_NOTICE {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '(', '2', 'OR', '3', 'OR', '4', 'OR', '5', ')'} : null;
            }when GL_RSU_LETTER {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2'} : 
                                           new List<String> {'(', '1', 'OR', '2', ')', 'AND', '3'};
            }
        }

        return ruleLogic;
    }

    public List<String> ruleFieldOperators(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> ruleFieldOperators;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'EQUALS'} : null;
            }when PIIA_US_OTHERS {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'DOES NOT EQUAL', 'DOES NOT EQUAL', 'DOES NOT EQUAL'} : null;
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'CONTAINS', 'ENDS WITH', 'GREATER THAN', 'DOES NOT EQUAL'} : 
                                                    new List<String> {'GREATER THAN', 'GREATER THAN EQUALS'};
            }when CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'EQUALS', 'STARTS WITH', 'CONTAINS'} : 
                                                    new List<String> {'EQUALS', 'GREATER THAN'};
            }when NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'EQUALS', 'STARTS WITH', 'DOES NOT CONTAIN'} : 
                                                    new List<String> {'EQUALS', 'GREATER THAN'};
            }when SF_FAIR_CHANCE_ORDINANCE {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'EQUALS', 'EQUALS'} : null;
            }when US_HIPAA_NOTICE {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'EQUALS', 'EQUALS', 'EQUALS', 'EQUALS'} : null;
            }when GL_RSU_LETTER {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'CONTAINS'} : 
                                                    new List<String> {'GREATER THAN', 'GREATER THAN', 'DOES NOT EQUAL'};
            }
        }

        return ruleFieldOperators;
    }

    public List<String> ruleFieldTypes(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> ruleFieldTypes;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING'}  : null;
            }when PIIA_US_OTHERS {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING', 'STRING', 'STRING'} : null;
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'PICKLIST', 'EMAIL', 'DATETIME', 'DATE'} : 
                                                new List<String> {'DOUBLE', 'CURRENCY'};
            }when CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING', 'STRING', 'EMAIL'} : 
                                                new List<String> {'BOOLEAN', 'DOUBLE'};
            }when NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING', 'STRING', 'EMAIL'} : 
                                                new List<String> {'BOOLEAN', 'DOUBLE'};
            }when SF_FAIR_CHANCE_ORDINANCE {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING', 'STRING'}  : null;
            }when US_HIPAA_NOTICE {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING', 'STRING', 'STRING', 'STRING'} : null;
            }when GL_RSU_LETTER {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'PICKLIST'} : 
                                                new List<String> {'DOUBLE', 'CURRENCY', 'DATE'};
            }
        }

        return ruleFieldTypes;
    }

    public List<String> ruleFieldValues(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> ruleFieldValues;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                ruleFieldValues = isAcqContact ? new List<String> {templateWrapper.country, templateWrapper.state} : null;
            }when PIIA_US_OTHERS {
                ruleFieldValues = isAcqContact ? new List<String> {templateWrapper.country, 'California', 'Washington', 'Illinois'} : null;
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                ruleFieldValues = isAcqContact ? new List<String> {templateWrapper.country, 'Regular', '.com', '2024-02-02T04:09:00.000Z', ''} : 
                                                 new List<String> {'0', '10000'};
            }when CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE {
                ruleFieldValues = isAcqContact ? new List<String> {templateWrapper.country, templateWrapper.state, 'testN', '@testmail'} : 
                                                 new List<String> {'True', '0'};
            }when NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE {
                ruleFieldValues = isAcqContact ? new List<String> {templateWrapper.country, templateWrapper.state, 'testN', '@hotmail'} : 
                                                 new List<String> {'True', '0'};
            }when SF_FAIR_CHANCE_ORDINANCE {
                ruleFieldValues = isAcqContact ? new List<String> {templateWrapper.country, templateWrapper.state, templateWrapper.city} : null;
            }when US_HIPAA_NOTICE {
                ruleFieldValues = isAcqContact ? new List<String> {templateWrapper.country, 'California', 'Washington', 'Illinois', 'New York'} : null;
            }when GL_RSU_LETTER {
                ruleFieldValues = isAcqContact ? new List<String> {'Regular', 'Salary'} : 
                                                 new List<String> {'0', '0', ''};
            }
        }

        return ruleFieldValues;
    }

    public List<String> ruleFieldLabels(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> ruleFieldLabels;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Office Address - State/Province'} : null;
            }when PIIA_US_OTHERS {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Office Address - State/Province', 'Office Address - State/Province', 'Office Address - State/Province'} : null;
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Employee Type', 'Email Address (Target)', 'Acknowledged On', 'Hire Date'} : 
                                                 new List<String> {'Job Grade', 'Annualized Base Salary'};
            }when CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Office Address - State/Province', 'Full Name (Legal)', 'Personal Email Address'} : 
                                                 new List<String> {'Flextime Eligible', 'Job Grade'};
            }when NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Office Address - State/Province', 'Full Name (Legal)', 'Personal Email Address'} : 
                                                 new List<String> {'Flextime Eligible', 'Job Grade'};
            }when SF_FAIR_CHANCE_ORDINANCE {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Office Address - State/Province', 'Office Address - City'} : null;
            }when US_HIPAA_NOTICE {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Office Address - State/Province', 'Office Address - State/Province', 'Office Address - State/Province', 'Office Address - State/Province'} : null;
            }when GL_RSU_LETTER {
                ruleFieldLabels = isAcqContact ? new List<String> {'Employee Type', 'Pay Rate Type'} : 
                                                 new List<String> {'Stock Grant Amount', 'Additional Stock Grant Amount', 'Stock Grant Date'};
            }
        }

        return ruleFieldLabels;
    }

    public List<String> ruleFieldNames(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> ruleFieldNames;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Office_Address_State_Province__c'} : null;
            }when PIIA_US_OTHERS {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Office_Address_State_Province__c', 'Office_Address_State_Province__c', 'Office_Address_State_Province__c'} : null;
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Employee_Type__c', 'Email_Address_Target__c', 'Confirmed_On__c', 'Hire_Date__c'} : 
                                                new List<String> {'Job_Grade__c', 'Annualized_Base_Salary__c'};
            }when CAL_WORKER_COMP_FORM, CAL_WORKER_COMP_GUIDE {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Office_Address_State_Province__c', 'Name', 'Personal_Email_Address__c'} : 
                                                new List<String> {'Flextime_Eligible__c', 'Job_Grade__c'};
            }when NYC_PREG_EMP_RIGHTS_NOTICE, NYC_PAID_SICK_LEAVE_NOTICE {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Office_Address_State_Province__c', 'Name', 'Personal_Email_Address__c'} : 
                                                new List<String> {'Flextime_Eligible__c', 'Job_Grade__c'};
            }when SF_FAIR_CHANCE_ORDINANCE {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Office_Address_State_Province__c', 'Office_Address_City__c'} : null;
            }when US_HIPAA_NOTICE {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Office_Address_State_Province__c', 'Office_Address_State_Province__c', 'Office_Address_State_Province__c', 'Office_Address_State_Province__c'} : null;
            }when GL_RSU_LETTER {
                ruleFieldNames = isAcqContact ? new List<String> {'Employee_Type__c', 'Pay_Rate_Type__c'} : 
                                                new List<String> {'Stock_Grant_Amount__c', 'Additional_Stock_Grant_Amount__c', 'Stock_Grant_Date__c'};
            }
        }

        return ruleFieldNames;
    }

    public List<String> auditFieldNames(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> auditFieldNames;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                auditFieldNames = isAcqContact ? new List<String> {'business_title__c', 'gender__c', 'work_location_status__c'} : 
                                                 new List<String> {'flextime_eligible__c', 'pay_rate_type__c'};
            }when PIIA_US_OTHERS {
                auditFieldNames = isAcqContact ? new List<String> {'business_title__c', 'gender__c', 'work_location_status__c'} : 
                                                 new List<String> {'flextime_eligible__c', 'pay_rate_type__c'};
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                auditFieldNames = isAcqContact ? new List<String> {'employee_type__c', 'business_title__c'} : 
                                                 new List<String> {'stock_reason__c', 'pay_plan__c'};
            }when GL_RSU_LETTER {
                auditFieldNames = isAcqContact ? new List<String> {'employee_type__c', 'business_title__c'} : 
                                                 new List<String> {'time_type__c', 'pay_plan__c'};
            }when MANAGER_SUMMARY {
                auditFieldNames = isAcqContact ? new List<String> {'business_title__c', 'email_address_target__c'} : 
                                                 new List<String> {'time_type__c', 'pay_plan__c'};
            }
        }

        return auditFieldNames;
    }

    public List<String> auditFieldTypes(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<String> auditFieldTypes;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                auditFieldTypes = isAcqContact ? new List<String> {'STRING', 'PICKLIST', 'PICKLIST'} : 
                                                 new List<String> {'BOOLEAN', 'PICKLIST'};
            }when PIIA_US_OTHERS {
                auditFieldTypes = isAcqContact ? new List<String> {'STRING', 'PICKLIST', 'PICKLIST'} : 
                                                 new List<String> {'BOOLEAN', 'PICKLIST'};
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                auditFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING'} : 
                                                 new List<String> {'PICKLIST', 'PICKLIST'};
            }when GL_RSU_LETTER {
                auditFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING'} : 
                                                 new List<String> {'PICKLIST', 'PICKLIST'};
            }when MANAGER_SUMMARY {
                auditFieldTypes = isAcqContact ? new List<String> {'STRING', 'EMAIL'} : 
                                                 new List<String> {'PICKLIST', 'PICKLIST'};
            }
        }

        return auditFieldTypes;
    }

    public List<Integer> auditFieldSampleSizes(String sObjectType, MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper) {
        List<Integer> auditFieldSampleSizes;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on templateWrapper.templateEnumType {
            when PIIA_CAL, PIIA_WA, PIIA_IL, PIIA_TL, PIIA_KA {
                auditFieldSampleSizes = isAcqContact ? new List<Integer> {2, 1, 1} : new List<Integer> {2, 1};
            }when PIIA_US_OTHERS {
                auditFieldSampleSizes = isAcqContact ? new List<Integer> {2, 1, 1} : new List<Integer> {2, 1};
            }when US_OFFER_LETTER, IN_OFFER_LETTER {
                auditFieldSampleSizes = isAcqContact ? new List<Integer> {2, 3} : new List<Integer> {2, 2};
            }when GL_RSU_LETTER {
                auditFieldSampleSizes = isAcqContact ? new List<Integer> {3, 3} : new List<Integer> {3, 3};
            }when MANAGER_SUMMARY {
                auditFieldSampleSizes = isAcqContact ? new List<Integer> {2, 5} : new List<Integer> {3, 3};
            }
        }

        return auditFieldSampleSizes;
    }

    public static void generateRules(List<MA_DS_Package_Distribution__c> packageDistributions, Boolean triggerDisabled) {
        MA_DS_RulesCriteriaQueryParser.skipQueryValidation = true;
        
        for(MA_DS_Package_Distribution__c packageDistribution : packageDistributions) {
            MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper = MA_DS_TestUtil_PackageDistributions.getDistributionWrapper(packageDistribution.Name);

            MA_DS_TestUtil_RulesCriteriaService.getRulesCriteriaGeneratorStrategy(MA_DS_TestUtil_RulesCriteriaService.RulesSObject.PACKAGE_DISTRIBUTION, new MA_DS_TestUtil_RulesGenerator())
                                               .initRulesCriteriaGenerator(distributionWrapper)
                                               .initRulesCriteriaService()
                                               .generateRulesCriteria(packageDistribution.Id);
        }
        MA_DS_TestUtil_RulesCriteriaService.updateRulesOnSObject(MA_DS_TestUtil_RulesCriteriaService.RulesSObject.PACKAGE_DISTRIBUTION, triggerDisabled);
    }

    public List<String> getRulesSObjectTypes(MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        List<String> sObjectTypes;

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, US_OTHERS, US_KEY_EMP, US_CRITICAL_EMP, US_ALL_EMP, IN_TELANGANA, IN_KARNATAKA, IN_KEY_EMP, IN_CRITICAL_EMP, IN_ALL_EMP {
                sObjectTypes = new List<String> {ACQ_CONTACT_SOBJECT};
            }
        }

        return sObjectTypes;
    }
    
    public Boolean customLogic(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        Boolean customLogic = false;
        return customLogic;
    }

    public List<String> ruleLogic(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        List<String> ruleLogic;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3', 'AND', '4'} : null;
            }when US_OTHERS {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3', 'AND', '4', 'AND', '5', 'AND', '6'} : null;
            }when US_KEY_EMP, IN_KEY_EMP {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3', 'AND', '4'} : null;
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2', 'AND', '3', 'AND', '4'} : null;
            }when US_ALL_EMP, IN_ALL_EMP {
                ruleLogic = isAcqContact ? new List<String> {'1', 'AND', '2'} : null;
            }
        }

        return ruleLogic;
    }

    public List<String> ruleFieldOperators(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        List<String> ruleFieldOperators;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'EQUALS', 'EQUALS', 'EQUALS'} : null;
            }when US_OTHERS {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'DOES NOT EQUAL', 'DOES NOT EQUAL', 'DOES NOT EQUAL', 'EQUALS', 'EQUALS'} : null;
            }when US_KEY_EMP, IN_KEY_EMP {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'CONTAINS', 'EQUALS', 'EQUALS'} : null;
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'CONTAINS', 'EQUALS', 'EQUALS'} : null;
            }when US_ALL_EMP, IN_ALL_EMP {
                ruleFieldOperators = isAcqContact ? new List<String> {'CONTAINS', 'EQUALS'} : null;
            }
        }

        return ruleFieldOperators;
    }

    public List<String> ruleFieldTypes(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        List<String> ruleFieldTypes;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING', 'BOOLEAN', 'BOOLEAN'}  : null;
            }when US_OTHERS {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'STRING', 'STRING', 'STRING', 'BOOLEAN', 'BOOLEAN'}  : null;
            }when US_KEY_EMP, IN_KEY_EMP {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'PICKLIST', 'BOOLEAN', 'BOOLEAN'}  : null;
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'PICKLIST', 'BOOLEAN', 'BOOLEAN'}  : null;
            }when US_ALL_EMP, IN_ALL_EMP {
                ruleFieldTypes = isAcqContact ? new List<String> {'PICKLIST', 'BOOLEAN'}  : null;
            }
        }

        return ruleFieldTypes;
    }

    public List<String> ruleFieldValues(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        List<String> ruleFieldValues;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                ruleFieldValues = isAcqContact ? new List<String> {distributionWrapper.country, distributionWrapper.state, 'False', 'False'} : null;
            }when US_OTHERS {
                ruleFieldValues = isAcqContact ? new List<String> {distributionWrapper.country, 'California', 'Washington', 'Illinois', 'False', 'False'} : null;
            }when US_KEY_EMP, IN_KEY_EMP {
                ruleFieldValues = isAcqContact ? new List<String> {distributionWrapper.country, 'Key', 'True', 'False'} : null;
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                ruleFieldValues = isAcqContact ? new List<String> {distributionWrapper.country, 'Critical', 'False', 'True'} : null;
            }when US_ALL_EMP, IN_ALL_EMP {
                ruleFieldValues = isAcqContact ? new List<String> {distributionWrapper.country, 'False'} : null;
            }
        }

        return ruleFieldValues;
    }

    public List<String> ruleFieldLabels(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        List<String> ruleFieldLabels;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Office Address - State/Province', 'People Manager', 'Executive'} : null;
            }when US_OTHERS {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Office Address - State/Province', 'Office Address - State/Province', 'Office Address - State/Province', 'People Manager', 'Executive'} : null;
            }when US_KEY_EMP, IN_KEY_EMP {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Key/Critical Employee', 'People Manager', 'Executive'} : null;
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Key/Critical Employee', 'People Manager', 'Executive'} : null;
            }when US_ALL_EMP, IN_ALL_EMP {
                ruleFieldLabels = isAcqContact ? new List<String> {'Office Address - Country', 'Executive'} : null;
            }
        }

        return ruleFieldLabels;
    }

    public List<String> ruleFieldNames(String sObjectType, MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper) {
        List<String> ruleFieldNames;
        Boolean isAcqContact = sObjectType.equalsIgnoreCase(ACQ_CONTACT_SOBJECT);

        switch on distributionWrapper.distributionType {
            when US_CALIFORNIA, US_WASHINGTON, US_ILLINOIS, IN_TELANGANA, IN_KARNATAKA {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Office_Address_State_Province__c', 'People_Manager__c', 'Executive__c'} : null;
            }when US_OTHERS {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Office_Address_State_Province__c', 'Office_Address_State_Province__c', 'Office_Address_State_Province__c', 'People_Manager__c', 'Executive__c'} : null;
            }when US_KEY_EMP, IN_KEY_EMP {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Key_Critical_Employee__c', 'People_Manager__c', 'Executive__c'} : null;
            }when US_CRITICAL_EMP, IN_CRITICAL_EMP {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Key_Critical_Employee__c', 'People_Manager__c', 'Executive__c'} : null;
            }when US_ALL_EMP, IN_ALL_EMP {
                ruleFieldNames = isAcqContact ? new List<String> {'Office_Address_Country__c', 'Executive__c'} : null;
            }
        }

        return ruleFieldNames;
    }
}