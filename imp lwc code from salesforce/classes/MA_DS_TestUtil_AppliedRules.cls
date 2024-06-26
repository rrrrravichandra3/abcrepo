/**
 * Test Utility class to setup Applied Rules data.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/12/2023      Chakshu Malhotra        Adds utility methods to setup Applied Rules data.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_AppliedRules {

    public static final Id DEFAULT_PD_RULE_ASYNC_APEX_ID = '707AE00000RT1ArPKG';
    public static final Id DEFAULT_IUT_RULE_ASYNC_APEX_ID = '707AE00000RT1ArIUT';

    public static final Id PURGED_PD_RULE_ASYNC_APEX_ID = '707AE00000RT2ArPKG';
    public static final Id PURGED_IUT_RULE_ASYNC_APEX_ID = '707AE00000RT2ArIUT';

    private static final String PD_TYPE_APPLIED_RULE = Label.MA_DS_PD_Type_Applied_Rule;
    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;

    public static void setupAppliedRules(Id acqCompanyId, List<MA_DS_Package_Distribution__c> packageDistributions) {
        setupAppliedRules(acqCompanyId, packageDistributions, DEFAULT_PD_RULE_ASYNC_APEX_ID);
    }
    
    public static void setupAppliedRules(Id acqCompanyId, List<MA_DS_Package_Distribution__c> packageDistributions, Id pdRuleAsyncApexId) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();

        for(MA_DS_Package_Distribution__c packageDistribution : packageDistributions) {
            List<Acquisition_Contacts__c> acqContacts = getAcquisitionContacts(acqCompanyId, packageDistribution);
            appliedRules.addAll(getDistributionAppliedRules(packageDistribution, acqContacts, false, false, pdRuleAsyncApexId));
        }

        upsertAppliedRules(appliedRules);
    }

    private static void upsertAppliedRules(List<MA_DS_Applied_Rule__c> appliedRules) {
        disableTriggers(true);
        upsert appliedRules MA_DS_Concatenated_Id__c;
        disableTriggers(false);
    }

    private static List<Acquisition_Contacts__c> getAcquisitionContacts(Id acqCompanyId, MA_DS_Package_Distribution__c packageDistribution) {
        List<Acquisition_Contacts__c> acqContacts = new List<Acquisition_Contacts__c>();
        acqContacts.addAll(MA_DS_TestUtil_AppliedRulesService.getAquisitionContacts(acqCompanyId, packageDistribution));
        return acqContacts;
    }

    private static List<MA_DS_Applied_Rule__c> getDistributionAppliedRules(MA_DS_Package_Distribution__c packageDistribution, List<Acquisition_Contacts__c> acqContacts, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, Id pdRuleAsyncApexId) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();

        for(Acquisition_Contacts__c acqContact : acqContacts) {
            appliedRules.add(getDistributionAppliedRule(acqContact.Id, packageDistribution.Id, summaryDocRuleSync, packageDocRuleSync, pdRuleAsyncApexId));
        }

        return appliedRules;
    }

    private static MA_DS_Applied_Rule__c getDistributionAppliedRule(Id acqContactId, Id packageDistributionId, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, Id pdRuleAsyncApexId) {
        MA_DS_Applied_Rule__c appliedRule = new MA_DS_Applied_Rule__c();
        appliedRule.MA_DS_Rule_Type__c = PD_TYPE_APPLIED_RULE;
        appliedRule.MA_DS_Acquisition_Contact__c = acqContactId;
        appliedRule.MA_DS_Async_Apex_Job_Id__c = pdRuleAsyncApexId;
        appliedRule.MA_DS_Package_Rule_Applied__c = packageDocRuleSync;
        appliedRule.MA_DS_Package_Distribution__c = packageDistributionId;
        appliedRule.MA_DS_Manager_Summary_Rule_Applied__c = summaryDocRuleSync;
        appliedRule.MA_DS_Concatenated_Id__c = String.valueOf(packageDistributionId) + String.valueOf(acqContactId);
        return appliedRule;
    }

    private static void disableTriggers(Boolean triggerDisabled) {
        Acquisition_Contacts_Trigger_Handler.triggerDisabled = triggerDisabled;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = triggerDisabled;
    }

    public static void setupAppliedRules(Id acqCompanyId, List<MA_DS_Package_Distribution__c> packageDistributions, List<MA_DS_In_Use_Template__c> inUseTemplates, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, Boolean needToGenerate, Boolean needToDeliver) {
        setupAppliedRules(acqCompanyId, packageDistributions, inUseTemplates, summaryDocRuleSync, packageDocRuleSync, needToGenerate, needToDeliver, DEFAULT_PD_RULE_ASYNC_APEX_ID, DEFAULT_IUT_RULE_ASYNC_APEX_ID);
    }

    public static void setupAppliedRules(Id acqCompanyId, List<MA_DS_Package_Distribution__c> packageDistributions, List<MA_DS_In_Use_Template__c> inUseTemplates, Boolean summaryDocRuleSync, Boolean packageDocRuleSync, Boolean needToGenerate, Boolean needToDeliver, Id pdRuleAsyncApexId, Id iutRuleAsyncApexId) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();

        for(MA_DS_Package_Distribution__c packageDistribution : packageDistributions) {
            List<Acquisition_Contacts__c> acqContacts = getAcquisitionContacts(acqCompanyId, packageDistribution);
            appliedRules.addAll(getDistributionAppliedRules(packageDistribution, acqContacts, summaryDocRuleSync, packageDocRuleSync, pdRuleAsyncApexId));
            appliedRules.addAll(getTemplateAppliedRules(packageDistribution, inUseTemplates, acqContacts, needToGenerate, needToDeliver, iutRuleAsyncApexId));
        }

        upsertAppliedRules(appliedRules);
    }

    private static List<MA_DS_Applied_Rule__c> getTemplateAppliedRules(MA_DS_Package_Distribution__c packageDistribution, List<MA_DS_In_Use_Template__c> inUseTemplates, List<Acquisition_Contacts__c> acqContacts, Boolean needToGenerate, Boolean needToDeliver, Id iutRuleAsyncApexId) {
        List<MA_DS_Applied_Rule__c> appliedRules = new List<MA_DS_Applied_Rule__c>();

        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper = MA_DS_TestUtil_Templates.getTemplateWrapper(inUseTemplate.MA_DS_Template_Being_Used__r.Name);
            MA_DS_TestUtil_AppliedRulesService.AuditFlagsWrapper wrapperInstance = MA_DS_TestUtil_AppliedRulesService.getAuditFlagsWrapper(inUseTemplate);

            for(Acquisition_Contacts__c acqContact : acqContacts) {
                if(MA_DS_TestUtil_AppliedRulesService.applyTemplateRule(acqContact, acqContact.Acquisition_Compensation__r[0], templateWrapper)) {
                    List<String> appliedAuditFlagKeys = (wrapperInstance.auditFlagsSampleSizeMap.size() > 0) ? MA_DS_TestUtil_AppliedRulesService.getAppliedAuditFlagKeys(wrapperInstance, acqContact) : new List<String>();
                    appliedRules.add(getInUseTemplateAppliedRule(wrapperInstance, appliedAuditFlagKeys, acqContact.Id, packageDistribution.Id, needToGenerate, needToDeliver, iutRuleAsyncApexId));
                }
            }
        }

        return appliedRules;
    }

    private static MA_DS_Applied_Rule__c getInUseTemplateAppliedRule(MA_DS_TestUtil_AppliedRulesService.AuditFlagsWrapper wrapperInstance, List<String> flaggedFields, Id acqContactId, Id packageDistributionId, Boolean needToGenerate, Boolean needToDeliver, Id iutRuleAsyncApexId) {
        MA_DS_Applied_Rule__c appliedRule = new MA_DS_Applied_Rule__c();
        appliedRule.MA_DS_Need_To_Deliver__c = needToDeliver;
        appliedRule.MA_DS_Need_To_Generate__c = needToGenerate;
        appliedRule.MA_DS_Rule_Type__c = IUT_TYPE_APPLIED_RULE;
        appliedRule.MA_DS_Acquisition_Contact__c = acqContactId;
        appliedRule.MA_DS_Template__c = wrapperInstance.templateId;
        appliedRule.MA_DS_Async_Apex_Job_Id__c = iutRuleAsyncApexId;
        appliedRule.MA_DS_Package_Distribution__c = packageDistributionId;
        appliedRule.MA_DS_Flagged_Fields__c = JSON.serialize(flaggedFields);
        appliedRule.MA_DS_Template_Document_Type__c = wrapperInstance.templateDocumentType;
        appliedRule.MA_DS_Flagged_For_Audit__c = (flaggedFields.size() > 0) || wrapperInstance.auditAll;
        appliedRule.MA_DS_Concatenated_Id__c = String.valueOf(packageDistributionId) + String.valueOf(wrapperInstance.templateId) + String.valueOf(acqContactId);
        return appliedRule;
    }
}