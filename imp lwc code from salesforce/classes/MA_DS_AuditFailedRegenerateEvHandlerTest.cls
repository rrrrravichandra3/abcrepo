@isTest
public class MA_DS_AuditFailedRegenerateEvHandlerTest {
	@testSetup
    public static void MS_DS_TestSetupMethod(){
        Acquisition_Company__c acqCompany = MA_DS_TestUtility.createAcqCompanies();
        insert acqCompany;
        
        List<Acquisition_Contacts__c> AcqContacts = MA_DS_TestUtility.createAcqContacts(acqCompany.Id,2);
        AcqContacts[0].Employment_Package__c ='Not Started';
        AcqContacts[0].MA_DS_Manager_Summary_Stage__c ='Not Started';
        AcqContacts[0].Office_Address_Country__c ='India';
        AcqContacts[0].Office_Address_State_Province__c = 'Karnataka'; 
        AcqContacts[0].Executive__c = false;
        AcqContacts[0].Confirmed_On__c = datetime.ValueofGmt('2023-05-02 02:43:00');
        AcqContacts[0].Contractor_End_Date__c = system.Today()+10;
        AcqContacts[0].MA_DS_No_Offer__c =  false; 
        AcqContacts[0].MA_DS_Offer_Declined__c = false;
        insert AcqContacts;
        
        Acquisition_Compensation__c acompen = new Acquisition_Compensation__c();
        acompen.Car_Allowance_Amount__c = 11;
        acompen.Acquisition_Contact__c = AcqContacts[0].id;
        insert acompen;
        
        List<MA_DS_Package__c> masterPackages = MA_DS_TestUtility.getMasterPackages();
        masterPackages[0].MA_DS_Acquisition_Company__c = acqCompany.id;
        insert masterPackages;
        MA_DS_Package_Distribution__c packageDistribution = MA_DS_TestUtility.createPackageDistribution(masterPackages[0].Id);
        packageDistribution.MA_DS_Status__c = 'Ready for Summary';
        packageDistribution.MA_DS_Package_Distribution_Stage__c = 'Ready for Manager Summary Prep';
        packageDistribution.MA_DS_Summary_Required__c = true;
        insert packageDistribution;
        
        MA_DS_Applied_Rule__c apldRule = new MA_DS_Applied_Rule__c();
        apldRule.MA_DS_Acquisition_Contact__c = AcqContacts[0].Id;
        apldRule.MA_DS_Package_Distribution__c=packageDistribution.Id;
        apldRule.MA_DS_Rule_Type__c  = 'In Use Template Rule';
        apldRule.MA_DS_Template_Document_Type__c = 'Manager Summary';
        apldRule.MA_DS_Need_To_Generate__c = true;
        insert apldRule;
        
        List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
        insert masterTemplates;
        
        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
        insert inUseMasterTemplates;
        
        MA_DS_Audit__c audit = new MA_DS_Audit__c();
        MA_DS_Audit__c audit1 = new MA_DS_Audit__c();
        List<MA_DS_Audit__c> listOfAudits = new List<MA_DS_Audit__c>();
        audit.MA_DS_Acquisition_Company__c = acqCompany.id;
        audit.MA_DS_Audit_Type__c = 'Manager Summary';
        audit.MA_DS_Status__c = 'In Progress';
		listOfAudits.add(audit);	        
       	audit1.MA_DS_Acquisition_Company__c = acqCompany.id;
        audit1.MA_DS_Audit_Type__c = 'Package';
        audit1.MA_DS_Status__c = 'In Progress';
        listOfAudits.add(audit1);
        insert listOfAudits;
        
        
    }
    @isTest
    public static void addProcessRulesTestMethod(){
        
        MA_DS_Audit__c listOfAudits = [Select id,MA_DS_Failed_Common_Id__c,MA_DS_Status__c,MA_DS_Failed_Regenerate_Attempt_Count__c from  MA_DS_Audit__c LIMIT 1];
        
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c LIMIT 1];
        Test.startTest();
        MA_DS_Audit_Failed_Regenerate_Event__e event = new MA_DS_Audit_Failed_Regenerate_Event__e(
        MA_DS_Audit_Id__c = listOfAudits.id,
        MA_DS_Acquisition_Company_Id__c = acqCompany.id,
        MA_DS_Audit_Status__c = 'Regenerate - Package Templates',
        MA_DS_Audit_Type__c = 'Manager Summary',
        MA_DS_Failed_Common_Id__c = '{"7077z000008ix9UAAQ":[]}');
        EventBus.publish(event);
        Test.stopTest();
    }
    
    @isTest
    public static void addProcessRulesTestMethod1(){
        
        MA_DS_Audit__c listOfAudits = [Select id,MA_DS_Failed_Common_Id__c,MA_DS_Status__c,MA_DS_Failed_Regenerate_Attempt_Count__c from  MA_DS_Audit__c LIMIT 1];
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c LIMIT 1];
        Test.startTest();
        MA_DS_Audit_Failed_Regenerate_Event__e event = new MA_DS_Audit_Failed_Regenerate_Event__e(
        MA_DS_Audit_Id__c = listOfAudits.id,
        MA_DS_Acquisition_Company_Id__c = acqCompany.id,
        MA_DS_Audit_Status__c = 'Regenerate - Package Templates',
        MA_DS_Audit_Type__c = 'Package',
        MA_DS_Failed_Common_Id__c = '{"7077z000008ix9UAAQ":[]}');
        EventBus.publish(event);
        Test.stopTest();
    }
    
     @isTest
    public static void addProcessRulesTestMethod3(){
        
        MA_DS_Audit__c listOfAudits = [Select id,MA_DS_Failed_Common_Id__c,MA_DS_Status__c,MA_DS_Failed_Regenerate_Attempt_Count__c from  MA_DS_Audit__c LIMIT 1];
        
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c LIMIT 1];
        
        List<Acquisition_Contacts__c> AcqContacts = [Select id from Acquisition_Contacts__c LIMIT 1];
        
        List<MA_DS_Template__c> masterTemplates = [Select id from MA_DS_Template__c LIMIT 1];
        
        MA_DS_Applied_Rule__c rule = [Select id from MA_DS_Applied_Rule__c LIMIT 1];
        
        Test.startTest();
        
        MA_DS_FailureHandlerService.strategyInstance.setCommonIds(new set<string>{'7077z000008ix9UAAQ'})
            										.setAcqContactIds(new set<string>{AcqContacts[0].id})
            										.setTemplateIds(new set<string>{masterTemplates[0].id})
           										    .setAppliedRuleIds(new set<string>{rule.id})
                                                    .setFailureType(MA_DS_FailureHandlerService.Failure.SUMMARY_DELIVERY)
                                                    .initHandlerService()
                                                    .initFailureHandlerJob()
                                                    .execute();
        Test.stopTest();
    }
    
    @isTest
    public static void addProcessRulesTestMethod5(){
        
        MA_DS_Audit__c listOfAudits = [Select id,MA_DS_Failed_Common_Id__c,MA_DS_Status__c,MA_DS_Failed_Regenerate_Attempt_Count__c from  MA_DS_Audit__c LIMIT 1];        
       
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c LIMIT 1];
        
        List<Acquisition_Contacts__c> AcqContacts = [Select id from Acquisition_Contacts__c LIMIT 1];
        
        List<MA_DS_Template__c> masterTemplates = [Select id from MA_DS_Template__c LIMIT 1];
        
        MA_DS_Applied_Rule__c rule = [Select id from MA_DS_Applied_Rule__c LIMIT 1];
        
        Test.startTest();
        
        MA_DS_FailureHandlerService.strategyInstance.setCommonIds(new set<string>{'7077z000008ix9UAAQ'})
            										.setAcqContactIds(new set<string>{AcqContacts[0].id})
            										.setTemplateIds(new set<string>{masterTemplates[0].id})
           										    .setAppliedRuleIds(new set<string>{rule.id})
                                                    .setFailureType(MA_DS_FailureHandlerService.Failure.PACKAGE_PREP)
                                                    .initHandlerService()
                                                    .initFailureHandlerJob()
                                                    .execute();
        Test.stopTest();
    }
    
    @isTest
    public static void addProcessRulesTestMethod6(){
        
        MA_DS_Audit__c listOfAudits = [Select id,MA_DS_Failed_Common_Id__c,MA_DS_Status__c,MA_DS_Failed_Regenerate_Attempt_Count__c from  MA_DS_Audit__c LIMIT 1];
        
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c LIMIT 1];
        
        List<Acquisition_Contacts__c> AcqContacts = [Select id from Acquisition_Contacts__c LIMIT 1];
        
        List<MA_DS_Template__c> masterTemplates = [Select id from MA_DS_Template__c LIMIT 1];
        
        MA_DS_Applied_Rule__c rule = [Select id from MA_DS_Applied_Rule__c LIMIT 1];
        
        Test.startTest();
        
        MA_DS_FailureHandlerService.strategyInstance.setCommonIds(new set<string>{'7077z000008ix9UAAQ'})
            										.setAcqContactIds(new set<string>{AcqContacts[0].id})
            										.setTemplateIds(new set<string>{masterTemplates[0].id})
           										    .setAppliedRuleIds(new set<string>{rule.id})
                                                    .setFailureType(MA_DS_FailureHandlerService.Failure.PACKAGE_DELIVERY)
                                                    .initHandlerService()
                                                    .initFailureHandlerJob()
                                                    .execute();
        Test.stopTest();
    }
    
    @isTest
    public static void addProcessRulesTestMethod7(){
        
        MA_DS_Audit__c listOfAudits = [Select id,MA_DS_Failed_Common_Id__c,MA_DS_Status__c,MA_DS_Failed_Regenerate_Attempt_Count__c from  MA_DS_Audit__c LIMIT 1];
        
        Acquisition_Company__c acqCompany = [Select id from Acquisition_Company__c LIMIT 1];
        
        List<Acquisition_Contacts__c> AcqContacts = [Select id from Acquisition_Contacts__c LIMIT 1];
        
        List<MA_DS_Template__c> masterTemplates = [Select id from MA_DS_Template__c LIMIT 1];
        
        List<MA_DS_Applied_Rule__c> rule = [Select id from MA_DS_Applied_Rule__c LIMIT 1];
        
        Test.startTest();
        
        MA_DS_FailureHandlerService.strategyInstance.setCommonIds(new set<string>{'7077z000008ix9UAAQ'})
            										.setAcqContactIds(new set<string>{AcqContacts[0].id})
            										.setTemplateIds(new set<string>{masterTemplates[0].id})
           										    .setAppliedRuleIds(new set<string>{rule[0].id})
                                                    .setFailureType(MA_DS_FailureHandlerService.Failure.SUMMARY_PREP)
                                                    .initHandlerService()
                                                    .initFailureHandlerJob()
                                                    .execute();
        Test.stopTest();
    }
    
        
    @isTest
    public static void addProcessRulesTestMethod8(){
        
    List<MA_DS_Applied_Rule__c> rule = [Select id,MA_DS_Acquisition_Contact__r.MA_DS_Package_Stage__c,MA_DS_Acquisition_Contact__r.Offer_Communicator__r.MA_DS_Manager_Summary_Stage__c 
                                        from MA_DS_Applied_Rule__c LIMIT 1];
        
    MA_DS_FailureHandlerUtility.updateAppliedRules(TRUE, rule, MA_DS_FailureHandlerService.Failure.SUMMARY_PREP);
    }

}