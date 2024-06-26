/**
 * Test utility class for MA_DS_Test_InUseTemplateTrigger class.
 * 
 * Version      Date            Author                  Description
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         10/12/2023      Chakshu Malhotra        Adds utility methods for MA_DS_Test_InUseTemplateTrigger class.
 * -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
@isTest
public class MA_DS_TestUtil_InUseTemplateTrigger {

    public static final String RULES_SYNCED = Label.MA_DS_Rules_Synced_Status;
    public static final String SYNCING_PACKAGE_RULES = Label.MA_DS_Syncing_Package_Rules_Status;
    public static final String SYNCING_TEMPLATE_RULES = Label.MA_DS_Syncing_Templates_Rules_Status;
    
    public static List<MA_DS_In_Use_Template__c> insertAcquistionInUseTemplates(Set<MA_DS_TestUtil_Packages.MA_Package> maPackages, Set<MA_DS_TestUtil_Templates.Template> maTemplates, Acquisition_Company__c acqCompany, Boolean triggerDisabled) {
        Map<MA_DS_TestUtil_Packages.MA_Package, MA_DS_Package__c> packageMap = MA_DS_TestUtil_Packages.getPackageMap(maPackages, MA_DS_TestUtil_Packages.PackageType.ACQUISITION, acqCompany);
        Map<MA_DS_TestUtil_Templates.Template, MA_DS_Template__c> templateMap = MA_DS_TestUtil_Templates.getTemplateMap(maTemplates, MA_DS_TestUtil_Templates.TemplateType.ACQUISITION, acqCompany);
        return MA_DS_TestUtil_InUseTemplates.setupInUseTemplates(packageMap, templateMap, triggerDisabled);
    }

    private static void updateInUseTemplate(MA_DS_In_Use_Template__c inUseTemplate, Boolean triggerDisabled) {
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = triggerDisabled;
        update inUseTemplate;
        MA_DS_InUseTemplateTriggerHandler.triggerDisabled = false;
    }

    public static void updateConcatenatedId(MA_DS_In_Use_Template__c inUseTemplate, Boolean triggerDisabled) {
        inUseTemplate.MA_DS_Concatenated_Id__c = null;
        updateInUseTemplate(inUseTemplate, triggerDisabled);
    }

    private static void updatePackageDistribution(MA_DS_Package_Distribution__c packageDistribution, Boolean triggerDisabled) {
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = triggerDisabled;
        update packageDistribution;
        MA_DS_PackageDistributionTriggerHandler.triggerDisabled = false;
    }

    public static void updateRulesSyncStatus(String rulesSyncStatus, MA_DS_TestUtil_PackageDistributions.Distribution maDistribution, MA_DS_Package__c packageRef, Boolean triggerDisabled) {
        MA_DS_Package_Distribution__c packageDistribution = MA_DS_TestUtil_PackageDistributions.getPackageDistribution(maDistribution, packageRef);
        packageDistribution.MA_DS_Rules_Sync_Status__c = rulesSyncStatus;
        updatePackageDistribution(packageDistribution, triggerDisabled);
    }

    public static void updateSuppressFlags(MA_DS_In_Use_Template__c inUseTemplate, Boolean suppressAuditFlags, Boolean suppresRulesCriteria, Boolean triggerDisabled) {
        inUseTemplate.MA_DS_Suppress_Audit_Flags__c = suppressAuditFlags;
        inUseTemplate.MA_DS_Suppress_Rules_Criteria__c = suppresRulesCriteria;
        updateInUseTemplate(inUseTemplate, triggerDisabled);
    }
}