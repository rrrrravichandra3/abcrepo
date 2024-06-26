@isTest
public class MA_DS_PrepareManagerSummariesTest {
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
        AcqContacts[0].MA_DS_Manager_Summary_Common_Id__c = '7077z000008ix9UAAQ';
        insert AcqContacts;
        
        AcqContacts[0].Offer_Communicator__c = AcqContacts[1].id;
        update AcqContacts;
        
        Acquisition_Compensation__c acompen = new Acquisition_Compensation__c();
		acompen.Car_Allowance_Amount__c = 11;
        acompen.Acquisition_Contact__c = AcqContacts[0].id;
        insert acompen;
        
        List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
        masterTemplates[0].MA_DS_Template_Document_Type__c = 'Manager Summary';
        insert masterTemplates;
        
        List<MA_DS_Package__c> masterPackages = MA_DS_TestUtility.getMasterPackages();
        masterPackages[0].MA_DS_Acquisition_Company__c = acqCompany.id;
        insert masterPackages;
        
        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
        insert inUseMasterTemplates;
        
        MA_DS_Package_Distribution__c packageDistribution = MA_DS_TestUtility.createPackageDistribution(masterPackages[0].Id);
        packageDistribution.MA_DS_Package__c = masterPackages[0].Id;
        packageDistribution.MA_DS_Status__c = 'Ready for Summary';
        packageDistribution.MA_DS_Package_Distribution_Stage__c = 'Ready for Manager Summary Prep';
        packageDistribution.MA_DS_Summary_Required__c = true;
        insert packageDistribution;
        
        MA_DS_Applied_Rule__c apldRule = new MA_DS_Applied_Rule__c();
        apldRule.MA_DS_Acquisition_Contact__c = AcqContacts[0].Id;
        apldRule.MA_DS_Package_Distribution__c = packageDistribution.Id;
        apldRule.MA_DS_Template__c = masterTemplates[0].Id;
        apldRule.MA_DS_Rule_Type__c  = 'In Use Template Rule';
        apldRule.MA_DS_Template_Document_Type__c = 'Manager Summary';
        apldRule.MA_DS_Need_To_Generate__c = true;
        insert apldRule;
        
    }
    
    @isTest
    public static void test_prepareManagerSummarieswithPDId(){
        
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        Test.startTest();
        try{
            MA_DS_PrepareManagerSummaries.prepareManagerSummaries(listOfPAckagesDistribution[0].id);
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage()); 
        }
    	Test.stopTest();
    }
    
    @isTest
    public static void test_prepareManagerSummariesWithCompanyId(){
        List<Acquisition_Company__c> listOfAcqCompanies = [Select id from Acquisition_Company__c LIMIT 1];
        
        Test.startTest();
        try{
            MA_DS_PrepareManagerSummaries.prepareManagerSummaries(listOfAcqCompanies[0].id);
        }catch (exception e){
           System.debug('Exception: ' + e.getMessage());  
        }
    	Test.stopTest();
    }
    
    @isTest
    public static void test_PrepareManagerSummarybyHelperpkgDistribution(){
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [SELECT Id FROM MA_DS_Package_Distribution__c LIMIT 1];
        listOfPAckagesDistribution[0].MA_DS_Manager_Summaries_Prep_Date__c = system.Today();
        update listOfPAckagesDistribution;
        
        List<MA_DS_Applied_Rule__c> appliedrule = [SELECT Id,MA_DS_Rule_Type__c,MA_DS_Acquisition_Contact__c,MA_DS_Acquisition_Contact__r.Acquisition_Company__c,
                                             	   MA_DS_Acquisition_Contact__r.Offer_Communicator__c,MA_DS_Package_Distribution__c,MA_DS_Acquisition_Contact__r.MA_DS_Manager_Summary_Common_Id__c
                                                   FROM MA_DS_Applied_Rule__c 
                                                   WHERE  MA_DS_Package_Distribution__c =: listOfPAckagesDistribution[0].Id];
        appliedrule[0].MA_DS_Rule_Type__c = 'Package Distribution Rule';
        appliedrule[0].MA_DS_Manager_Summary_Rule_Applied__c = true;
        update appliedrule;
        
        Map<String, List<String>> commonIdMap = new Map<String, List<String>>{appliedrule[0].MA_DS_Acquisition_Contact__r.MA_DS_Manager_Summary_Common_Id__c => new List<String>{appliedrule[0].MA_DS_Acquisition_Contact__r.Offer_Communicator__c}};
        
        Test.startTest();
        try{
            MA_DS_ManagerSummariesPrepHelper.prepareManagerSummaries(appliedrule[0].MA_DS_Acquisition_Contact__r.Acquisition_Company__c,commonIdMap,'Regenerate - All Documents for Contacts');
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    	Test.stopTest();
    }
    
    @isTest
    public static void test_PrepareManagerSummaryError(){
        
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [SELECT Id FROM MA_DS_Package_Distribution__c LIMIT 1];
        MA_DS_Applied_Rule__c appliedrule = [SELECT Id,MA_DS_Rule_Type__c 
                                             FROM MA_DS_Applied_Rule__c 
                                             WHERE  MA_DS_Package_Distribution__c =: listOfPAckagesDistribution[0].Id LIMIT 1];
        appliedrule.MA_DS_Rule_Type__c = 'Package Distribution Rule';
        update appliedrule;
        
        Test.startTest();
        try{
            MA_DS_PrepareManagerSummaries.prepareManagerSummaries(listOfPAckagesDistribution[0].id);
        }catch (exception e){
             System.debug('Exception: ' + e.getMessage());
        }
    	Test.stopTest();
    }
    
    @isTest
    public static void test_DeliverManagerSummaryError2(){
        
        MA_DS_Package_Distribution__c packagesDistribution = [SELECT Id,MA_DS_Status__c FROM MA_DS_Package_Distribution__c LIMIT 1];
        packagesDistribution.MA_DS_Integration_Status__c = 'Sending Manager Summaries';
        update packagesDistribution;
        
        Test.startTest();
        try{
            MA_DS_PrepareManagerSummaries.prepareManagerSummaries(packagesDistribution.id);
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    public static void test_DeliverManagerSummaryError3(){
        
        MA_DS_Package_Distribution__c packagesDistribution = [SELECT Id,MA_DS_Status__c FROM MA_DS_Package_Distribution__c LIMIT 1];
        packagesDistribution.MA_DS_Rules_Sync_Status__c = 'Syncing Package Rules';
        update packagesDistribution;
        
        Test.startTest();
        try{
            MA_DS_PrepareManagerSummaries.prepareManagerSummaries(packagesDistribution.id);
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void test_DeliverManagerSummaryError4(){
        
        MA_DS_Package_Distribution__c packagesDistribution = [SELECT Id,MA_DS_Status__c FROM MA_DS_Package_Distribution__c LIMIT 1];
        MA_DS_Applied_Rule__c appliedrule = [SELECT Id,MA_DS_Rule_Type__c,MA_DS_Acquisition_Contact__c,MA_DS_Template__c 
                                             FROM MA_DS_Applied_Rule__c
                                             WHERE  MA_DS_Package_Distribution__c =: packagesDistribution.Id];
        appliedrule.MA_DS_Need_To_Generate__c = true;
        appliedrule.MA_DS_Manager_Summary_Rule_Applied__c  = false;
        update appliedrule;
        
        Test.startTest();
        try{
            MA_DS_PrepareManagerSummaries.prepareManagerSummaries(packagesDistribution.id);
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void test_DeliverManagerSummaryError5(){
        
        MA_DS_Package_Distribution__c packagesDistribution = [SELECT Id,MA_DS_Status__c FROM MA_DS_Package_Distribution__c LIMIT 1];
        MA_DS_Applied_Rule__c appliedrule = [SELECT Id,MA_DS_Rule_Type__c,MA_DS_Acquisition_Contact__c 
                                             FROM MA_DS_Applied_Rule__c
                                             WHERE  MA_DS_Package_Distribution__c =: packagesDistribution.Id];
        appliedrule.MA_DS_Rule_Type__c = 'Package Distribution Rule';
        appliedrule.MA_DS_Manager_Summary_Rule_Applied__c = true;
        update appliedrule;
        Acquisition_Contacts__c acqContact  = [SELECT Id,Name,Acquisition_Company__c,Offer_Communicator__c,MA_DS_Manager_Summary_Common_Id__c
                                              FROM Acquisition_Contacts__c 
                                              WHERE Id =:appliedrule.MA_DS_Acquisition_Contact__c];
        acqContact.Offer_Communicator__c = null;
        update acqContact;
        
        Map<String, List<String>> commonIdMap = new Map<String, List<String>>{acqContact.MA_DS_Manager_Summary_Common_Id__c => new List<String>{acqContact.Offer_Communicator__c}};
        
        Test.startTest();
        try{
           MA_DS_ManagerSummariesPrepHelper.prepareManagerSummaries(acqContact.Acquisition_Company__c,commonIdMap,'Regenerate - All Documents for Contacts');
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    	Test.stopTest();
    }
    
    

}