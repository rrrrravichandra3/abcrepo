@isTest
public class MA_DS_PurgeAppliedRuleSyncServiceTest {
    public enum ExecutionMode {SYNC_RULE, AUTO_APPLY_RULE}
        
    @testSetup
    public static void MS_DS_TestSetupMethod(){
        
        Acquisition_Company__c acqCompany = MA_DS_TestUtility.createAcqCompanies();
        insert acqCompany;
        
        List<Acquisition_Contacts__c> AcqContacts = MA_DS_TestUtility.createAcqContacts(acqCompany.Id,1);
        AcqContacts[0].Employment_Package__c ='Not Started';
        AcqContacts[0].MA_DS_Manager_Summary_Stage__c ='Not Started';
        insert AcqContacts;
        
        List<MA_DS_Package__c> masterPackages = MA_DS_TestUtility.getMasterPackages();
        insert masterPackages;
        
        MA_DS_Package_Distribution__c packageDistribution = MA_DS_TestUtility.createPackageDistribution(masterPackages[0].Id);
        insert packageDistribution;
        
        List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
        insert masterTemplates;
        
        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
        inUseMasterTemplates[0].MA_DS_Suppress_Audit_Flags__c = true;
        inUseMasterTemplates[0].MA_DS_Suppress_Rules_Criteria__c = true;
        insert inUseMasterTemplates;
        
        MA_DS_Applied_Rule__c apldRule = new MA_DS_Applied_Rule__c();
        apldRule.MA_DS_Acquisition_Contact__c = AcqContacts[0].Id;
        apldRule.MA_DS_Async_Apex_Job_Id__c = '7077z000008PIi3AAG';
        apldRule.MA_DS_Package_Distribution__c=packageDistribution.Id;
        apldRule.MA_DS_Rule_Type__c  = 'Package Distribution Rule';
        insert apldRule;
    }
    
    
    @isTest
    public static void addProcessRulesTestMethod(){
        List<MA_DS_Template__c> masterTemplates = [Select id from MA_DS_Template__c Limit 1];
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c];
        List<MA_DS_Package__c> masterPackages = [Select id from MA_DS_Package__c LIMIT 1];
        MA_DS_Package_Distribution__c packageDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        MA_DS_AppliedRulesService.strategyInstance.setExecutionModeEnum(MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE)
                                                  .setExecutionJobEnum(MA_DS_AppliedRulesService.ExecutionJob.PURGE_RULE_SYNC)
                                                  .setOriginExecutionJobEnum(MA_DS_AppliedRulesService.ExecutionJob.PACKAGE_RULE_SYNC)
                                                  .setPackageDistributionId(packageDistribution.Id)
                                                  .setSummaryDocRuleSync(false)
                                                  .setPackageDocRuleSync(true)
            									  .setTemplateIds(new List<Id>{masterTemplates[0].Id})
                                                  .setAsyncApexJobIds(new set<Id>{'7077z000008PIi3AAG'})
                                                  .initAppliedRuleJob()
                                                  .execute();

    
    }
}