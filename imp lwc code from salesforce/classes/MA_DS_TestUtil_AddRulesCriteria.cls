/**
 * Test utility class for MA_DS_Test_AddRulesCriteria.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         16/12/2023      Chakshu Malhotra        Adds utility methods for MA_DS_Test_AddRulesCriteria class.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_AddRulesCriteria {
    
    private static final String UNWANTED_RULE_LOGIC_CHAR = ')';
    private static final String RULE_LOGIC_MAP_STR = 'ruleLogicMap';
    private static final String ACQ_CONTACT_SOBJECT = 'Acquisition_Contacts__c';

    private static void updatePackageDistribution(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = triggerDisabled;
        update packageDistribution;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = false;
    }

    private static void updateInUseTemplate(MA_DS_In_Use_Template__c inUseTemplate, Boolean triggerDisabled) {
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = triggerDisabled;
        update inUseTemplate;
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = false;
    }

    public static void updateRulesCriteriaJSONToCauseParseException(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        Map<String, Object> rulesCriteriaJSON = (Map<String, Object>)JSON.deserializeUntyped(packageDistribution.MA_DS_Rules_Criteria_JSON__c);
        rulesCriteriaJSON.put(RULE_LOGIC_MAP_STR, new List<String>());
        packageDistribution.MA_DS_Rules_Criteria_JSON__c = JSON.serialize(rulesCriteriaJSON);
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updateAuditFlagsJSONToCauseParseException(MA_DS_In_Use_Template__c inUseTemplate, Boolean triggerDisabled) {
        Map<String, Object> auditFlagsJSON = (Map<String, Object>)JSON.deserializeUntyped(inUseTemplate.MA_DS_Audit_Flags_JSON__c);
        auditFlagsJSON.put(ACQ_CONTACT_SOBJECT, new List<String>());
        inUseTemplate.MA_DS_Audit_Flags_JSON__c = JSON.serialize(auditFlagsJSON);
        updateInUseTemplate(inUseTemplate, triggerDisabled);
    }

    public static void clearRulesCriteria(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Rules_Criteria_JSON__c = null;
        packageDistribution.MA_DS_Rules_Criteria_Query__c = null;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static MA_DS_AddRulesCriteriaWrapper getRulesCriteriaWrapper(MA_DS_Package_Distribution__c packageDistribution) {
        MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper = MA_DS_TestUtil_PackageDistributions.getDistributionWrapper(packageDistribution.Name);
        return MA_DS_TestUtil_RulesCriteriaService.getRulesCriteriaGeneratorStrategy(MA_DS_TestUtil_RulesCriteriaService.RulesSObject.PACKAGE_DISTRIBUTION, new MA_DS_TestUtil_RulesGenerator())
                                                  .initRulesCriteriaGenerator(distributionWrapper)
                                                  .getRulesCriteriaWrapper();
    }

    public static MA_DS_AddRulesCriteriaWrapper getRulesCriteriaWrapperToCauseQueryException(MA_DS_Package_Distribution__c packageDistribution) {
        MA_DS_AddRulesCriteriaWrapper rulesWrapper = getRulesCriteriaWrapper(packageDistribution);
        rulesWrapper.rulesCriteriaJSON.ruleLogicMap.get(ACQ_CONTACT_SOBJECT).add(UNWANTED_RULE_LOGIC_CHAR);
        return rulesWrapper;
    }

    public static void clearRulesCriteria(MA_DS_In_Use_Template__c inUseTemplate, Boolean triggerDisabled) {
        inUseTemplate.MA_DS_Audit_Flags_JSON__c = null;
        inUseTemplate.MA_DS_Rules_Criteria_JSON__c = null;
        inUseTemplate.MA_DS_Rules_Criteria_Query__c = null;
        updateInUseTemplate(inUseTemplate, triggerDisabled);
    }

    public static MA_DS_AddRulesCriteriaWrapper getRulesCriteriaWrapper(MA_DS_In_Use_Template__c inUseTemplate) {
        MA_DS_TestUtil_Templates.TemplateWrapper templateWrapper = MA_DS_TestUtil_Templates.getTemplateWrapper(inUseTemplate.MA_DS_Template_Being_Used__r.Name);
        return MA_DS_TestUtil_RulesCriteriaService.getRulesCriteriaGeneratorStrategy(MA_DS_TestUtil_RulesCriteriaService.RulesSObject.IN_USE_TEMPLATE, new MA_DS_TestUtil_RulesGenerator())
                                                  .initRulesCriteriaGenerator(templateWrapper)
                                                  .getRulesCriteriaWrapper();
    }
}