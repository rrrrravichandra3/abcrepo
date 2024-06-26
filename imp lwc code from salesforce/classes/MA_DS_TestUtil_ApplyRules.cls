/**
 * Test utility class for MA_DS_Test_ApplyRules.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         18/12/2023      Chakshu Malhotra        Adds utility methods for MA_DS_Test_ApplyRules class.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_ApplyRules {

    private static final String INVALID_QUERY_SUFFIX = 'AND';
    public static final String STATE_CALIFORNIA = 'California';
    public static final String STATE_WASHINGTON = 'Washington';
    private static final String COUNTRY_USA = 'United States of America';

    private static final String TEST_APPLIED_AUDIT_FLAGS_KEY = 'Acquisition_Contacts__cbusiness_title__cManager';

    private static final Integer TEST_APPLIED_AUDIT_FLAGS_KEY_COUNT = 2;

    private static final String PD_TYPE_APPLIED_RULE = Label.MA_DS_PD_Type_Applied_Rule;
    private static final String IUT_TYPE_APPLIED_RULE = Label.MA_DS_IUT_Type_Applied_Rule;
    private static final String SYNCING_PACKAGE_RULES = Label.MA_DS_Syncing_Package_Rules_Status;
    private static final String PREPARING_SUMMARIES = Label.MA_DS_Integration_Status_Summary_Prep;
    private static final String PACAKGE_AUDIT_COMPLETE = Label.MA_DS_PD_Status_Package_Audit_Complete;

    // Maximum number of PD Type Applied rules that can be created by MA_DS_PackageAppliedRuleSyncService.PackageRuleSync Queueable job in a single transaction.
    private static final Integer MAX_PD_TYPE_RULES = MA_DS_AppliedRulesWrapper.PACKAGE_RULE_MAX_QUERY_COUNT * MA_DS_AppliedRulesWrapper.PACKAGE_RULE_QUERY_SIZE_LIMIT;
    
    // Maximum number of IUT Type Applied rules that can be created by MA_DS_TemplateAppliedRuleSyncService.TemplateRuleSync Queueable job in a single transaction.
    private static final Integer MAX_IUT_TYPE_RULES = MA_DS_AppliedRulesWrapper.TEMPLATE_RULE_MAX_QUERY_COUNT * MA_DS_AppliedRulesWrapper.TEMPLATE_RULE_QUERY_SIZE_LIMIT;

    // Maximum number of Applied rules that can be purged by MA_DS_PurgeAppliedRuleSyncService.PurgeRuleSync Queueable job in a single transaction.
    private static final Integer MAX_PURGE_RULES = MA_DS_AppliedRulesWrapper.PURGE_RULE_MAX_QUERY_COUNT * MA_DS_AppliedRulesWrapper.PURGE_RULE_QUERY_SIZE_LIMIT;
    
    private static void updatePackageDistribution(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = triggerDisabled;
        update packageDistribution;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = false;
    }

    private static void updateInUseTemplates(List<MA_DS_In_Use_Template__c> inUseTemplates, Boolean triggerDisabled) {
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = triggerDisabled;
        update inUseTemplates;
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = false;
    }

    public static void updatePackageDistributionToCauseIneligibleIntegrationStatusException(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Integration_Status__c = PREPARING_SUMMARIES;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updatePackageDistributionToCauseIneligibleRulesSyncStatusException(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Rules_Sync_Status__c = SYNCING_PACKAGE_RULES;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updatePackageDistributionToCauseNoRulesCriteriaQueryException(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Rules_Criteria_Query__c = null;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updatePackageDistributionToCauseIneligibleStatusException(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        packageDistribution.MA_DS_Status__c = PACAKGE_AUDIT_COMPLETE;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static Integer getExpectedAcqContactCountForUSCaliforniaDistribution(Id acqCompanyId) {
        Integer recordCount = [SELECT Count() FROM Acquisition_Contacts__c 
                               WHERE Acquisition_Company__c = :acqCompanyId AND
                               Office_Address_Country__c = :COUNTRY_USA AND
                               Office_Address_State_Province__c = :STATE_CALIFORNIA AND
                               Executive__c = false AND
                               People_Manager__c = false];
        return (recordCount > MAX_PD_TYPE_RULES) ? MAX_PD_TYPE_RULES : recordCount;
    }

    public static void updatePackageDistributionToLogQueryExceptionForPDRuleSync(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper = MA_DS_RulesCriteriaQueryParser.instance.getQueryWrapper(packageDistribution.Id, packageDistribution.MA_DS_Rules_Criteria_Query__c);
        rulesQueryWrapper.queryString += INVALID_QUERY_SUFFIX;
        packageDistribution.MA_DS_Rules_Criteria_Query__c = JSON.serialize(rulesQueryWrapper);
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static Integer getPackageDistributionTypeAppliedRuleCount(Id packageDistributionId) {
        return [SELECT Count() FROM MA_DS_Applied_Rule__c
                WHERE MA_DS_Rule_Type__c = :PD_TYPE_APPLIED_RULE AND
                MA_DS_Package_Distribution__c = :packageDistributionId];
    }

    public static Integer getExpectedAcqContactCountForUSAllEmpDistribution(Id acqCompanyId) {
        Integer recordCount = [SELECT Count() FROM Acquisition_Contacts__c 
                               WHERE Acquisition_Company__c = :acqCompanyId AND
                               Office_Address_Country__c = :COUNTRY_USA AND
                               Executive__c = false];
        return (recordCount > MAX_PD_TYPE_RULES) ? MAX_PD_TYPE_RULES : recordCount;
    }

    public static void deleteInUseTemplatesExcept(Id packageId, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Boolean triggerDisabled) {
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = triggerDisabled;
        delete [SELECT Id FROM MA_DS_In_Use_Template__c WHERE MA_DS_Package_Using__c = :packageId AND MA_DS_Template_Being_Used__r.Name NOT IN :MA_DS_TestUtil_Templates.getTemplateNames(maTemplates)];
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = false;
    }

    public static void initTemplateAppliedRuleSyncJob(Id acqCompanyId, Id packageId, Id packageDistributionId) {
        Set<Id> asyncApexJobIds = new Set<Id> {MA_DS_TestUtil_AppliedRules.DEFAULT_PD_RULE_ASYNC_APEX_ID};
        MA_DS_PackageAppliedRuleSyncUtility.initTemplateAppliedRuleJob(MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE, acqCompanyId, packageId, packageDistributionId, asyncApexJobIds);
    }

    public static void updateInUseTemplateWithSyncRulesOnPDIds(Id packageId, Id packageDistributionId, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Boolean triggerDisabled) {
        List<MA_DS_In_Use_Template__c> inUseTemplates = getUpdatedInUseTemplatesWithSyncRulesOnPDIds(packageId, packageDistributionId, maTemplates);
        updateInUseTemplates(inUseTemplates, triggerDisabled);
    }

    private static List<MA_DS_In_Use_Template__c> getUpdatedInUseTemplatesWithSyncRulesOnPDIds(Id packageId, Id packageDistributionId, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        List<MA_DS_In_Use_Template__c> inUseTemplates = getInUseTemplates(packageId, maTemplates);
        
        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            String syncRulesOnPDIds = inUseTemplate.MA_DS_Sync_Rules_On_PD_Ids__c;
            Set<String> pdIds = String.isBlank(syncRulesOnPDIds) ? new Set<String>() : new Set<String>((List<String>)JSON.deserialize(syncRulesOnPDIds, List<String>.class));
            pdIds.add(packageDistributionId);
            inUseTemplate.MA_DS_Sync_Rules_On_PD_Ids__c = JSON.serialize(pdIds);
        }

        return inUseTemplates;
    }

    public static List<MA_DS_In_Use_Template__c> getInUseTemplates(Id packageId, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        return [SELECT Id, MA_DS_Audit_All__c, MA_DS_Concatenated_Id__c, MA_DS_Package_Using__c, MA_DS_Package_Using__r.Name, MA_DS_Template_Being_Used__c, MA_DS_Template_Being_Used__r.Name, MA_DS_Template_Being_Used__r.MA_DS_Template_Document_Type__c, MA_DS_Sort_Order__c, 
                MA_DS_Audit_Flags_Added__c, MA_DS_Rules_Criteria_Added__c, MA_DS_Suppress_Audit_Flags__c, MA_DS_Suppress_Rules_Criteria__c, MA_DS_Audit_Flags_JSON__c, MA_DS_Applied_Audit_Flags_JSON__c, MA_DS_Rules_Criteria_JSON__c, MA_DS_Rules_Criteria_Query__c, MA_DS_Sync_Rules_On_PD_Ids__c
                FROM MA_DS_In_Use_Template__c
                WHERE MA_DS_Package_Using__c = :packageId AND 
                MA_DS_Template_Being_Used__r.Name IN :MA_DS_TestUtil_Templates.getTemplateNames(maTemplates)];
    }

    public static void updateInUseTemplateWithSyncRulesOnPDIdsAndAppliedAuditFlagsJSON(Id packageId, Id packageDistributionId, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Boolean triggerDisabled) {
        List<MA_DS_In_Use_Template__c> inUseTemplates = getUpdatedInUseTemplatesWithSyncRulesOnPDIds(packageId, packageDistributionId, maTemplates);
        
        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            inUseTemplate.MA_DS_Applied_Audit_Flags_JSON__c = JSON.serialize(getTestAppliedAuditFlagsJSON(packageDistributionId));
        }
        
        updateInUseTemplates(inUseTemplates, triggerDisabled);
    }

    private static Map<String, Map<String, Integer>> getTestAppliedAuditFlagsJSON(Id packageDistributionId) {
        Map<String, Map<String, Integer>> appliedAuditFlagsJSON = new Map<String, Map<String, Integer>>();
        appliedAuditFlagsJSON.put(packageDistributionId, new Map<String, Integer> {TEST_APPLIED_AUDIT_FLAGS_KEY => TEST_APPLIED_AUDIT_FLAGS_KEY_COUNT});
        return appliedAuditFlagsJSON;
    }

    public static Integer getExpectedAcqContactCountForSummaryTemplateInUSCalDistribution(Id acqCompanyId) {
        Integer recordCount = [SELECT Count() FROM Acquisition_Compensation__c 
                               WHERE Acquisition_Contact__r.Acquisition_Company__c = :acqCompanyId AND
                               Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                               Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                               Acquisition_Contact__r.Office_Address_Country__c = :COUNTRY_USA AND
                               Acquisition_Contact__r.Office_Address_State_Province__c = :STATE_CALIFORNIA AND
                               Acquisition_Contact__r.Executive__c = false AND
                               Acquisition_Contact__r.People_Manager__c = false];
        return (recordCount > MAX_IUT_TYPE_RULES) ? MAX_IUT_TYPE_RULES : recordCount;
    }

    public static Integer getInUseTemplateTypeAppliedRuleCount(Id packageDistributionId, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        return [SELECT Count() FROM MA_DS_Applied_Rule__c
                WHERE MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                MA_DS_Package_Distribution__c = :packageDistributionId AND
                MA_DS_Template__r.Name IN :MA_DS_TestUtil_Templates.getTemplateNames(maTemplates)];
    }

    public static Integer getInUseTemplateTypeAppliedRuleCountWithFlaggedForAudit(Id packageDistributionId, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        return [SELECT Count() FROM MA_DS_Applied_Rule__c
                WHERE MA_DS_Flagged_For_Audit__c = true AND
                MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                MA_DS_Package_Distribution__c = :packageDistributionId AND
                MA_DS_Template__r.Name IN :MA_DS_TestUtil_Templates.getTemplateNames(maTemplates)];
    }

    public static Integer getExpectedAcqContactCountForUSOfferLetterTemplateInUSCalDistribution(Id acqCompanyId) {
        Integer recordCount = [SELECT Count() FROM Acquisition_Compensation__c 
                               WHERE Acquisition_Contact__r.Acquisition_Company__c = :acqCompanyId AND
                               Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                               Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                               Acquisition_Contact__r.Office_Address_Country__c = :COUNTRY_USA AND
                               Acquisition_Contact__r.Office_Address_State_Province__c = :STATE_CALIFORNIA AND
                               Acquisition_Contact__r.Executive__c = false AND
                               Acquisition_Contact__r.People_Manager__c = false AND
                               Acquisition_Contact__r.Employee_Type__c = 'Regular' AND
                               Acquisition_Contact__r.Email_Address_Target__c LIKE '%.com' AND
                               Acquisition_Contact__r.Confirmed_On__c > :Datetime.valueOf('2024-02-02 04:09:00') AND
                               Acquisition_Contact__r.Hire_Date__c != null AND
                               Job_Grade__c > 0 AND
                               Annualized_Base_Salary__c >= 10000];
        return (recordCount > MAX_IUT_TYPE_RULES) ? MAX_IUT_TYPE_RULES : recordCount;
    }

    public static Integer getExpectedAcqContactCountForSummaryTemplateInUSKeyEmpDistribution(Id acqCompanyId) {
        Integer recordCount = [SELECT Count() FROM Acquisition_Compensation__c 
                               WHERE Acquisition_Contact__r.Acquisition_Company__c = :acqCompanyId AND
                               Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                               Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                               Acquisition_Contact__r.Office_Address_Country__c = :COUNTRY_USA AND
                               Acquisition_Contact__r.Key_Critical_Employee__c = 'Key' AND
                               Acquisition_Contact__r.Executive__c = false AND
                               Acquisition_Contact__r.People_Manager__c = true];
        return (recordCount > MAX_IUT_TYPE_RULES) ? MAX_IUT_TYPE_RULES : recordCount;
    }

    public static Integer getExpectedAcqContactCountForPIIACalTemplateInUSKeyEmpDistribution(Id acqCompanyId) {
        Integer recordCount = [SELECT Count() FROM Acquisition_Compensation__c 
                               WHERE Acquisition_Contact__r.Acquisition_Company__c = :acqCompanyId AND
                               Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                               Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                               Acquisition_Contact__r.Office_Address_Country__c = :COUNTRY_USA AND
                               Acquisition_Contact__r.Office_Address_State_Province__c = :STATE_CALIFORNIA AND
                               Acquisition_Contact__r.Key_Critical_Employee__c = 'Key' AND
                               Acquisition_Contact__r.Executive__c = false AND
                               Acquisition_Contact__r.People_Manager__c = true];
        return (recordCount > MAX_IUT_TYPE_RULES) ? MAX_IUT_TYPE_RULES : recordCount;
    }

    public static Integer getExpectedAcqContactCountForUSHippaNoticeTemplateInUSKeyEmpDistribution(Id acqCompanyId) {
        Integer recordCount = [SELECT Count() FROM Acquisition_Compensation__c 
                               WHERE Acquisition_Contact__r.Acquisition_Company__c = :acqCompanyId AND
                               Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                               Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                               Acquisition_Contact__r.Office_Address_Country__c = :COUNTRY_USA AND
                               Acquisition_Contact__r.Key_Critical_Employee__c = 'Key' AND
                               Acquisition_Contact__r.Executive__c = false AND
                               Acquisition_Contact__r.People_Manager__c = true];
        return (recordCount > MAX_IUT_TYPE_RULES) ? MAX_IUT_TYPE_RULES : recordCount;
    }

    public static Integer getExpectedAcqContactCountForGlRSUTemplateInUSKeyEmpDistribution(Id acqCompanyId) {
        Integer recordCount = [SELECT Count() FROM Acquisition_Compensation__c 
                               WHERE Acquisition_Contact__r.Acquisition_Company__c = :acqCompanyId AND
                               Acquisition_Contact__r.MA_DS_No_Offer__c = false AND
                               Acquisition_Contact__r.MA_DS_Offer_Declined__c = false AND
                               Acquisition_Contact__r.Office_Address_Country__c = :COUNTRY_USA AND
                               Acquisition_Contact__r.Key_Critical_Employee__c = 'Key' AND
                               Acquisition_Contact__r.Executive__c = false AND
                               Acquisition_Contact__r.People_Manager__c = true AND
                               Acquisition_Contact__r.Employee_Type__c = 'Regular' AND
                               Acquisition_Contact__r.Pay_Rate_Type__c = 'Salary' AND
                               Stock_Grant_Date__c != null AND
                               (Stock_Grant_Amount__c > 0 OR Additional_Stock_Grant_Amount__c > 0)];
        return (recordCount > MAX_IUT_TYPE_RULES) ? MAX_IUT_TYPE_RULES : recordCount;
    }

    public static String getInvalidAppliedRuleQueryStringToCauseQueryException() {
        return 'SELECT Id FROM MA_DS_Applied_Rule__c WHERE';
    }

    public static void updateInUseTemplatesToLogQueryExceptionForTemplateRuleSync(Id packageId, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Boolean triggerDisabled) {
        List<MA_DS_In_Use_Template__c> inUseTemplates = getInUseTemplates(packageId, maTemplates);
        
        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            MA_DS_RulesCriteriaQueryParser.QueryWrapper rulesQueryWrapper = MA_DS_RulesCriteriaQueryParser.instance.getQueryWrapper(inUseTemplate.Id, inUseTemplate.MA_DS_Rules_Criteria_Query__c);
            rulesQueryWrapper.queryString += INVALID_QUERY_SUFFIX;
            inUseTemplate.MA_DS_Rules_Criteria_Query__c = JSON.serialize(rulesQueryWrapper);
        }

        updateInUseTemplates(inUseTemplates, triggerDisabled);
    }

    public static void updateInUseTemplatesWithAuditAll(Id packageId, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Boolean triggerDisabled) {
        List<MA_DS_In_Use_Template__c> inUseTemplates = getInUseTemplates(packageId, maTemplates);
        
        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            inUseTemplate.MA_DS_Audit_All__c = true;
            inUseTemplate.MA_DS_Audit_Flags_JSON__c = null;
            inUseTemplate.MA_DS_Audit_Flags_Added__c = false;
        }

        updateInUseTemplates(inUseTemplates, triggerDisabled);
    }

    public static void initPurgeAppliedRuleSyncJob(Id packageDistributionId, List<MA_DS_In_Use_Template__c> inUseTemplates, MA_DS_AppliedRulesService.ExecutionJob originExecJob, Boolean summaryDocRuleSync, Boolean packageDocRuleSync) {
        Set<Id> asyncApexJobIds = new Set<Id> {MA_DS_TestUtil_AppliedRules.DEFAULT_PD_RULE_ASYNC_APEX_ID, MA_DS_TestUtil_AppliedRules.DEFAULT_IUT_RULE_ASYNC_APEX_ID};
        MA_DS_TemplateAppliedRuleSyncUtility.initPurgeAppliedRuleJob(packageDistributionId, summaryDocRuleSync, packageDocRuleSync, originExecJob, MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE, asyncApexJobIds, getTemplateIds(inUseTemplates));
    }

    private static List<Id> getTemplateIds(List<MA_DS_In_Use_Template__c> inUseTemplates) {
        Set<Id> templateIds = new Set<Id>();
        for(MA_DS_In_Use_Template__c inUseTemplate : inUseTemplates) {
            templateIds.add(inUseTemplate.MA_DS_Template_Being_Used__c);
        }
        return new List<Id>(templateIds);
    }

    public static Integer getAppliedRuleCountForPackageDistribution(Id packageDistributionId) {
        return [SELECT Count() FROM MA_DS_Applied_Rule__c
                WHERE MA_DS_Package_Distribution__c = :packageDistributionId];
    }

    public static Integer getExpectedAppliedRuleCountForPurgeRuleSync(Id packageDistributionId, Set<Id> asyncApexJobIds) {
        Integer recordCount = [SELECT Count() FROM MA_DS_Applied_Rule__c
                               WHERE MA_DS_Package_Distribution__c = :packageDistributionId AND
                               MA_DS_Async_Apex_Job_Id__c IN :asyncApexJobIds];
        return (recordCount > MAX_PURGE_RULES) ? MAX_PURGE_RULES : recordCount;
    }

    public static void updateDistributionWrapperWithState(MA_DS_Package_Distribution__c packageDistribution, String state) {
        MA_DS_TestUtil_PackageDistributions.DistributionWrapper distributionWrapper = MA_DS_TestUtil_PackageDistributions.getDistributionWrapper(packageDistribution.Name);
        distributionWrapper.state = state;
    }

    public static Integer getExpectedRuleAppliedCount(Id packageDistributionId, Set<MA_DS_TestUtil_Templates.Template> maTemplates) {
        Integer maxRuleAppliedCount = MA_DS_AppliedRulesWrapper.RULE_APPLIED_QUERY_SIZE_LIMIT * MA_DS_AppliedRulesWrapper.RULE_APPLIED_MAX_QUERY_COUNT * 2;
        Integer recordCount = [SELECT Count() FROM MA_DS_Applied_Rule__c
                               WHERE MA_DS_Rule_Type__c = :IUT_TYPE_APPLIED_RULE AND
                               MA_DS_Package_Distribution__c = :packageDistributionId AND
                               MA_DS_Template__r.Name IN :MA_DS_TestUtil_Templates.getTemplateNames(maTemplates)];
        return (recordCount > maxRuleAppliedCount) ? maxRuleAppliedCount : recordCount;
    }

    public static void initRuleAppliedSyncJob(Id packageDistributionId, MA_DS_AppliedRulesService.ExecutionJob originExecJob, Boolean summaryDocRuleSync, Boolean packageDocRuleSync) {
        MA_DS_PurgeAppliedRuleSyncUtility.initRuleAppliedJob(packageDistributionId, summaryDocRuleSync, packageDocRuleSync, originExecJob, MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE);
    }

    public static Integer getAppliedRuleCountWithSummaryRuleApplied(Id packageDistributionId) {
        return [SELECT Count() FROM MA_DS_Applied_Rule__c
                WHERE MA_DS_Rule_Type__c = :PD_TYPE_APPLIED_RULE AND
                MA_DS_Package_Distribution__c = :packageDistributionId AND
                MA_DS_Manager_Summary_Rule_Applied__c = true];
    }

    public static Integer getAppliedRuleCountWithPackageRuleApplied(Id packageDistributionId) {
        return [SELECT Count() FROM MA_DS_Applied_Rule__c
                WHERE MA_DS_Rule_Type__c = :PD_TYPE_APPLIED_RULE AND
                MA_DS_Package_Distribution__c = :packageDistributionId AND
                MA_DS_Package_Rule_Applied__c = true];
    }
}