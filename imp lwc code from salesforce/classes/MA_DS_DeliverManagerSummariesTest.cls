@isTest(SeeAllData=false)
public class MA_DS_DeliverManagerSummariesTest {
    private Static String maESName = 'deliverymanager';
    @testSetup
    public static void MS_DS_TestSetupMethod(){
        
       /* UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, false, maESName);
        maUser[0].Email = maESName +'@gmail.com';
        insert maUser;
		UserRole adminrole = MA_DS_TestUtility.getUserRoleByType(MA_TestUtilityValues.MA_ROLETYPE_NONE);
        profile adminuserProfile = MA_DS_TestUtility.getUserProfile(MA_TestUtilityValues.MA_SYSADMIN_PROFILE);
        List<User> adminUsers = MA_DS_TestUtility.createSystemAdminUser(1,adminuserProfile.Id, adminrole.Id,true, maESName+1);*/
        //User dsAdmin = MA_DS_TestUtility.getDSAdmin(maESName);
        
      //  PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
      //  MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        Acquisition_Company__c acqCompany;
       // System.runAs(dsAdmin){
            acqCompany = MA_DS_TestUtility.createAcqCompanies();
            insert acqCompany;
        
        
        List<Acquisition_Contacts__c> AcqContacts = MA_DS_TestUtility.createAcqContacts(acqCompany.Id,2);
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
        //}
    }
    
    
    @isTest
    public static void test_DeliverManagerSummarybyCompanyId(){
        List<Acquisition_Company__c> listOfAcqCompanies = [Select id from Acquisition_Company__c LIMIT 1];
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id,MA_DS_Total_In_Need_To_Deliver_Summary__c from MA_DS_Package_Distribution__c LIMIT 1];
        Test.startTest();
        try{
            MA_DS_DeliverManagerSummaries.deliverManagerSummaries(listOfAcqCompanies[0].id);
        }
        catch (exception e){
           System.debug('Exception: ' + e.getMessage()); 
        }
        Test.stopTest();
    }
    
    @isTest
    public static void test_DeliverManagerSummarybypkgDistribution(){
        
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        Test.startTest();
        try{
            MA_DS_DeliverManagerSummaries.deliverManagerSummaries(listOfPAckagesDistribution[0].id);
        }
        catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    	Test.stopTest();
    }
    
    @isTest
    public static void test_DeliverManagerSummarybyHelperpkgDistribution(){
        
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        listOfPAckagesDistribution[0].MA_DS_Schedule_Summary_Delivery__c = true;
        update listOfPAckagesDistribution;
        Test.startTest();
        try{
            MA_DS_ManagerSummariesDeliveryHelper.deliverManagerSummaries(new Set<Id>{listOfPAckagesDistribution[0].id});
        }
        catch (exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    	Test.stopTest();
    }
    
    @isTest
    public static void test_DeliverManagerSummaryError(){
        
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select Id from MA_DS_Package_Distribution__c LIMIT 1];
        MA_DS_Applied_Rule__c appliedrule = [Select Id,MA_DS_Rule_Type__c from MA_DS_Applied_Rule__c
                                                                          WHERE  MA_DS_Package_Distribution__c =: listOfPAckagesDistribution[0].Id LIMIT 1];
        appliedrule.MA_DS_Rule_Type__c = 'Package Distribution Rule';
        update appliedrule;
        Test.startTest();
        try{
            MA_DS_DeliverManagerSummaries.deliverManagerSummaries(listOfPAckagesDistribution[0].id);
        }
        catch (exception e){
             
        }
    	Test.stopTest();
    }

    @isTest
    public static void test_DeliverManagerSummaryError2(){
        
        MA_DS_Package_Distribution__c packagesDistribution = [Select Id,MA_DS_Status__c FROM MA_DS_Package_Distribution__c LIMIT 1];
        packagesDistribution.MA_DS_Integration_Status__c = 'Sending Manager Summaries';
        update packagesDistribution;
        
        Test.startTest();
        try{
            MA_DS_DeliverManagerSummaries.deliverManagerSummaries(packagesDistribution.id);
        }
        catch (exception e){
            
        }
        Test.stopTest();
    }
    
    /* @isTest
    public static void test_DeliverManagerSummaryError3(){
        
        MA_DS_Package_Distribution__c listOfPAckagesDistribution = [Select Id,MA_DS_Status__c FROM MA_DS_Package_Distribution__c LIMIT 1];
        listOfPAckagesDistribution.MA_DS_Integration_Status__c = 'Sending Manager Summaries';
       // update listOfPAckagesDistribution;
        
        MA_DS_Applied_Rule__c appliedrule = [Select Id,MA_DS_Rule_Type__c from MA_DS_Applied_Rule__c
                                                                          WHERE  MA_DS_Package_Distribution__c =: listOfPAckagesDistribution.Id LIMIT 1];
        //appliedrule.MA_DS_Rule_Type__c = 'Package Distribution Rule';
        appliedrule.MA_DS_Template_Document_Type__c = 'Package Document';
       // update appliedrule;
       
        MA_DS_Template__c template = [SELECT Id FROM MA_DS_Template__c limit 1];
        template.MA_DS_Template_Document_Type__c = 'Package Document';
       // update template;
         User maESUser = [Select id from user where Email = :maESName + '@gmail.com' limit 1];
        
        Test.startTest();
        try{
            System.runAs(maESUser){
            MA_DS_DeliverManagerSummaries.deliverManagerSummaries(listOfPAckagesDistribution.id);
            }
        }
        catch (exception e){
            
        }
        Test.stopTest();
    }*/
    
    

}