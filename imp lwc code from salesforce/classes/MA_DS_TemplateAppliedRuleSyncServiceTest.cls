@isTest
public class MA_DS_TemplateAppliedRuleSyncServiceTest {
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

        MA_DS_Applied_Rule__c apldRule = new MA_DS_Applied_Rule__c();
        apldRule.MA_DS_Acquisition_Contact__c = AcqContacts[0].Id;
        apldRule.MA_DS_Async_Apex_Job_Id__c = '7077z000008PIi3AAG';
        apldRule.MA_DS_Package_Distribution__c=packageDistribution.Id;
        apldRule.MA_DS_Rule_Type__c  = 'Package Distribution Rule';
        insert apldRule;
    }
    
    
    @isTest
    public static void addProcessRulesTestMethod(){
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c];
        List<MA_DS_Package__c> masterPackages = [Select id from MA_DS_Package__c LIMIT 1];
        MA_DS_Package_Distribution__c packageDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        MA_DS_TemplateAppliedRuleSyncService abc = new MA_DS_TemplateAppliedRuleSyncService();
        abc.initAppliedRuleJob(acqCompany.Id,masterPackages[0].id,packageDistribution.id,MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE);
        MA_DS_AppliedRulesService.strategyInstance.setExecutionModeEnum(MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE)
            .setExecutionJobEnum(MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC)
            .setAcquisitionCompanyId(acqCompany.Id)
            .setPackageId(masterPackages[0].id)
            .setPackageDistributionId(packageDistribution.Id)
            .setAsyncApexJobIds(new set<Id>{'7077z000008PIi3AAG'})
            .initAppliedRuleJob()
            .execute();
    }
    
    @isTest
    public static void addProcessRulesTestMethod1(){
        List<MA_DS_Package__c> masterPackages = [Select id,name from MA_DS_Package__c LIMIT 1];
        
        List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
        insert masterTemplates;
        
        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
        inUseMasterTemplates[0].MA_DS_Suppress_Audit_Flags__c = true;
        inUseMasterTemplates[0].MA_DS_Suppress_Rules_Criteria__c = true;
        inUseMasterTemplates[0].MA_DS_Audit_Flags_JSON__c = '{"Acquisition_Contacts__c":{"employee_type_target__c":{"type":"STRING","sampleSize":1},"business_title_target__c":{"type":"STRING","sampleSize":1}},"Acquisition_Compensation__c":{"pay_plan__c":{"type":"PICKLIST","sampleSize":1},"job_grade_target__c":{"type":"STRING","sampleSize":1}}}';
        
        insert inUseMasterTemplates;
        
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c];
        
        MA_DS_Package_Distribution__c packageDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        MA_DS_TemplateAppliedRuleSyncService abc = new MA_DS_TemplateAppliedRuleSyncService();
        abc.initAppliedRuleJob(acqCompany.Id,masterPackages[0].id,packageDistribution.id,MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE);
        MA_DS_AppliedRulesService.strategyInstance.setExecutionModeEnum(MA_DS_AppliedRulesService.ExecutionMode.SYNC_RULE)
            .setExecutionJobEnum(MA_DS_AppliedRulesService.ExecutionJob.TEMPLATE_RULE_SYNC)
            .setAcquisitionCompanyId(acqCompany.Id)
            .setPackageId(masterPackages[0].id)
            .setPackageDistributionId(packageDistribution.Id)
            .setAsyncApexJobIds(new set<Id>{'7077z000008PIi3AAG'})
            .initAppliedRuleJob()
            .execute();
    }
}