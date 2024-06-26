@isTest
public class MA_DS_SummarizedContactsPrepServiceTest {
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
        
        AcqContacts[0].Offer_Communicator__c = AcqContacts[1].id;
        update AcqContacts;
        
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
        
        
        List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
        masterTemplates[0].MA_DS_Template_Document_Type__c = 'Manager Summary';
        insert masterTemplates;
        
        MA_DS_Applied_Rule__c apldRule = new MA_DS_Applied_Rule__c();
        apldRule.MA_DS_Acquisition_Contact__c = AcqContacts[0].Id;
        apldRule.MA_DS_Package_Distribution__c=packageDistribution.Id;
        apldRule.MA_DS_Rule_Type__c  = 'In Use Template Rule';
        apldRule.MA_DS_Template_Document_Type__c = 'Manager Summary';
        apldRule.MA_DS_Need_To_Generate__c = true;
        apldRule.MA_DS_Template__c = masterTemplates[0].id;
        insert apldRule;
        
        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
        insert inUseMasterTemplates;
    }
    
    @isTest
    public static void addProcessRulesTestMethod(){
        List<Acquisition_Company__c> listOfPAckagesDistribution1 = [Select id from Acquisition_Company__c LIMIT 1];
        
        List<Acquisition_Contacts__c> AcqContacts = [Select id from Acquisition_Contacts__c where Offer_Communicator__c = null LIMIT 1];
        
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new MA_DS_SummaryPrepCalloutServiceMock());
           MA_DS_ManagerSummaryPrepService.strategyInstance.setCommonId('7077z000008VWzwAAG')
                                                            .setSrcRecordId(listOfPAckagesDistribution[0].id)
                                                            .setAcqCompanyId(listOfPAckagesDistribution1[0].id)
                                                            .setSummaryTemplateId(null)
            											    .setSummaryPrepPDIds(new set<id>{listOfPAckagesDistribution[0].id})
               												.setofferCommunicatorIds(new set<string>{AcqContacts[0].id})
                                                            .setExecutionJobType(MA_DS_ManagerSummaryPrepService.ExecutionJob.PREP_SUMMARIZED_CONTACTS)
                                                            .setExecutionJobOriginType(MA_DS_ManagerSummaryPrepService.ExecutionOrigin.PREP_REGEN_SELECTED)
                                                            .initPrepService()
                                                            .initSummaryPrepJob()
                                                            .execute();
        }
        catch (exception e){
             
        }
        
    	Test.stopTest();
    }
    
    @isTest
    public static void addProcessRulesTestMethod1(){
                List<Acquisition_Company__c> listOfPAckagesDistribution1 = [Select id from Acquisition_Company__c LIMIT 1];
        
        List<Acquisition_Contacts__c> AcqContacts = [Select id from Acquisition_Contacts__c where Offer_Communicator__c = null LIMIT 1];
        
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new MA_DS_SummaryPrepCalloutServiceMock());
           MA_DS_ManagerSummaryPrepService.strategyInstance.setCommonId('7077z000008VWzwAAG')
                                                            .setSrcRecordId(listOfPAckagesDistribution[0].id)
                                                            .setAcqCompanyId(listOfPAckagesDistribution1[0].id)
                                                            .setSummaryTemplateId(null)
            											    .setSummaryPrepPDIds(new set<id>{listOfPAckagesDistribution[0].id})
               												.setofferCommunicatorIds(new set<string>{AcqContacts[0].id})
                                                            .setExecutionJobType(MA_DS_ManagerSummaryPrepService.ExecutionJob.PREP_SUMMARIZED_CONTACTS)
                                                            .setExecutionJobOriginType(MA_DS_ManagerSummaryPrepService.ExecutionOrigin.PREP_REGEN_SELECTED)
                                                            .initPrepService()
                                                            .initSummaryPrepJob()
                                                            .execute();
        }
        catch (exception e){
             
        }
        
    	Test.stopTest();
    }
   
}