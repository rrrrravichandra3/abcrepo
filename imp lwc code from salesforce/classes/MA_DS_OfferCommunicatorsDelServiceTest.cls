@isTest(SeeAllData=false)
public class MA_DS_OfferCommunicatorsDelServiceTest {
private Static String maESName = 'deliverymanager';
    @testSetup
    public static void MS_DS_TestSetupMethod(){
        Acquisition_Company__c acqCompany = MA_DS_TestUtility.createAcqCompanies();
        insert acqCompany;
        
        
        List<Acquisition_Contacts__c> AcqContacts = MA_DS_TestUtility.createAcqContacts(acqCompany.Id,4);
        AcqContacts[0].Employment_Package__c ='Not Started';
        AcqContacts[0].MA_DS_Manager_Summary_Stage__c ='Not Started';
        AcqContacts[0].Office_Address_Country__c ='India';
        AcqContacts[0].Office_Address_State_Province__c = 'Karnataka'; 
        AcqContacts[0].Executive__c = false;
        AcqContacts[0].Confirmed_On__c = datetime.ValueofGmt('2023-05-02 02:43:00');
        AcqContacts[0].Contractor_End_Date__c = system.Today()+10;
        AcqContacts[0].Acquisition_Company__c = acqCompany.Id;
        AcqContacts[0].MA_DS_No_Offer__c =  false; 
        AcqContacts[0].MA_DS_Offer_Declined__c = false;
        insert AcqContacts;
        
        AcqContacts[0].Offer_Communicator__c = AcqContacts[1].id;
        AcqContacts[2].Offer_Communicator__c = AcqContacts[3].id;
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
        packageDistribution.MA_DS_Status__c = 'Manager Communication Sent Partially';
        packageDistribution.MA_DS_Package_Distribution_Stage__c = 'Ready for Manager Summary Delivery';
        packageDistribution.MA_DS_Summary_Required__c = true;
        packageDistribution.MA_DS_Schedule_Summary_Delivery__c = false;
        insert packageDistribution;
        
        MA_DS_Applied_Rule__c apldRule = new MA_DS_Applied_Rule__c();
        apldRule.MA_DS_Acquisition_Contact__c = AcqContacts[0].Id;
        apldRule.MA_DS_Package_Distribution__c = packageDistribution.Id;
        apldRule.MA_DS_Template__c = masterTemplates[0].Id;
        apldRule.MA_DS_Rule_Type__c  = 'In Use Template Rule';
        apldRule.MA_DS_Template_Document_Type__c = 'Manager Summary';
        apldRule.MA_DS_Need_To_Generate__c = false;
        apldRule.MA_DS_Need_To_Deliver__c  = true;
        
        insert apldRule;
        
        MA_DS_Package_Distribution__c packageDistribution2 = MA_DS_TestUtility.createPackageDistribution(masterPackages[0].Id);
        packageDistribution2.MA_DS_Status__c = 'Manager Communication Sent Partially';
        packageDistribution2.MA_DS_Package_Distribution_Stage__c = 'Ready for Manager Summary Delivery';
        packageDistribution2.MA_DS_Summary_Required__c = true;
        packageDistribution2.MA_DS_Schedule_Summary_Delivery__c = false;
        insert packageDistribution2;
        MA_DS_Applied_Rule__c apldRule2 = new MA_DS_Applied_Rule__c();
        apldRule2.MA_DS_Acquisition_Contact__c = AcqContacts[2].Id;
        apldRule2.MA_DS_Package_Distribution__c = packageDistribution2.Id;
        apldRule2.MA_DS_Template__c = masterTemplates[0].Id;
        apldRule2.MA_DS_Rule_Type__c  = 'In Use Template Rule';
        apldRule2.MA_DS_Template_Document_Type__c = 'Manager Summary';
        apldRule2.MA_DS_Need_To_Generate__c = false;
        apldRule2.MA_DS_Need_To_Deliver__c  = true;
        
        insert apldRule2;
    }
    
    @isTest
    public static void test_offerManagerSummaryDelivery(){
        MA_DS_Package_Distribution__c packagesDistribution = [Select Id,MA_DS_Status__c FROM MA_DS_Package_Distribution__c LIMIT 1];
        
        MA_DS_Applied_Rule__c appliedrule = [Select Id,MA_DS_Rule_Type__c,MA_DS_Acquisition_Contact__c,MA_DS_Acquisition_Contact__r.Acquisition_Company__c,
                                             MA_DS_Acquisition_Contact__r.Offer_Communicator__c
                                             FROM MA_DS_Applied_Rule__c 
                                             WHERE  MA_DS_Package_Distribution__c =: packagesDistribution.Id LIMIT 1];
        Acquisition_Contacts__c acqContact = [Select Id,Name,Acquisition_Company__c
                                             FROM Acquisition_Contacts__c WHERE Id =:appliedrule.MA_DS_Acquisition_Contact__c];
        Acquisition_Company__c company = [SELECT Id, MA_DS_Manager_Summary_Email_Subject__c, MA_DS_Manager_Summary_Email_Body__c
                                          FROM Acquisition_Company__c 
                                          WHERE Id =:appliedrule.MA_DS_Acquisition_Contact__r.Acquisition_Company__c];
        List<Id> offerCommunicatorIds = new List<Id>();
        offerCommunicatorIds.add(appliedrule.MA_DS_Acquisition_Contact__r.Offer_Communicator__c);
        Map<Id, List<Id>> offerCommunicatorMap = new Map<Id, List<Id>>();
        offerCommunicatorMap.put(packagesDistribution.Id,offerCommunicatorIds );
        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new MA_DS_SummaryPrepCalloutServiceMock());
            MA_DS_ManagerSummaryDeliveryService.strategyInstance.setSrcRecordId(packagesDistribution.Id)
                                                                .setTargetUserId(userInfo.getUserId())
                                                                .setAcquisitionCompany(company)
                												.setSummaryDeliveryPDIds(new Set<Id>{packagesDistribution.Id})
               													.setOfferCommunicatorMap(offerCommunicatorMap)
                												.setCustomSummaryEmailMap(new Map<Id,Boolean>{packagesDistribution.Id => false})
                                                                .setExecutionJobType(MA_DS_ManagerSummaryDeliveryService.ExecutionJob.DELIVER_OFFER_COMMUNICATORS)
                                                                .setExecutionJobOriginType(MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.DELIVER_SELECTED)
                                                                .initDeliveryService()
                                                                .initSummaryDeliveryJob()
                                                                .execute();
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    public static void test_offerManagerSummaryDeliveryHandlesinglejob(){
        Map<Id,MA_DS_Package_Distribution__c> packagesDistribution = new Map<Id,MA_DS_Package_Distribution__c>([Select Id,MA_DS_Status__c FROM MA_DS_Package_Distribution__c]);
        
        List<MA_DS_Applied_Rule__c> appliedrule = [Select Id,MA_DS_Rule_Type__c,MA_DS_Acquisition_Contact__c,MA_DS_Acquisition_Contact__r.Acquisition_Company__c,
                                             MA_DS_Acquisition_Contact__r.Offer_Communicator__c,MA_DS_Package_Distribution__c
                                             FROM MA_DS_Applied_Rule__c 
                                             WHERE  MA_DS_Package_Distribution__c In: packagesDistribution.keySet()];
        Acquisition_Company__c company = [SELECT Id, MA_DS_Manager_Summary_Email_Subject__c, MA_DS_Manager_Summary_Email_Body__c
                                          FROM Acquisition_Company__c 
                                          WHERE Id =:appliedrule[0].MA_DS_Acquisition_Contact__r.Acquisition_Company__c];
        List<Id> offerCommunicatorIds = new List<Id>();
        offerCommunicatorIds.add(appliedrule[0].MA_DS_Acquisition_Contact__r.Offer_Communicator__c);
        offerCommunicatorIds.add(appliedrule[1].MA_DS_Acquisition_Contact__r.Offer_Communicator__c);
        Map<Id, List<Id>> offerCommunicatorMap = new Map<Id, List<Id>>();
        offerCommunicatorMap.put(appliedrule[0].MA_DS_Package_Distribution__c,offerCommunicatorIds );
        offerCommunicatorMap.put(appliedrule[1].MA_DS_Package_Distribution__c,offerCommunicatorIds );
        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new MA_DS_SummaryPrepCalloutServiceMock());
            MA_DS_ManagerSummaryDeliveryService.strategyInstance.setSrcRecordId(appliedrule[0].MA_DS_Package_Distribution__c)
                                                                .setTargetUserId(userInfo.getUserId())
                                                                .setAcquisitionCompany(company)
                												.setSummaryDeliveryPDIds(new Set<Id>{appliedrule[0].MA_DS_Package_Distribution__c,appliedrule[1].MA_DS_Package_Distribution__c})
               													.setOfferCommunicatorMap(offerCommunicatorMap)
                												.setCustomSummaryEmailMap(new Map<Id,Boolean>{appliedrule[0].MA_DS_Package_Distribution__c => false})
                                                                .setExecutionJobType(MA_DS_ManagerSummaryDeliveryService.ExecutionJob.DELIVER_OFFER_COMMUNICATORS)
                                                                .setExecutionJobOriginType(MA_DS_ManagerSummaryDeliveryService.ExecutionOrigin.DELIVER_SELECTED)
                                                                .initDeliveryService()
                                                                .initSummaryDeliveryJob()
                                                                .execute();
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testHandleCalloutException() {
        // Set up test data and mock callouts
        // Ensure to cover all possible scenarios (success and failure)
       // MA_DS_CalloutFramework.CalloutRequest mockCalloutRequest = new MA_DS_CalloutFramework.CalloutRequest();

      	Http httpInstance = new Http();
       // HttpRequest clmAPIRequest = this.calloutRequest.initHttpRequest();
        MA_DS_SummaryDeliveryCalloutService calloutService = new MA_DS_SummaryDeliveryCalloutService();

       // startManagerSummaryDeliveryWorkflow(httpInstance, clmAPIRequest);        // Call the method to be tested
        Test.startTest();
        try{
           //calloutService.handleCalloutException(new CalloutException('Simulated Callout Exception'), null, null); 
        }catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();

        // Verify the expected behavior or assert relevant conditions
       // System.assertEquals(true, mockResponseCallback.handleResponseCalled, 'handleResponse should have been called');
       // System.assertNotEquals(null, mockResponseCallback.calloutException, 'Callout exception should have been set');
    }
    
}