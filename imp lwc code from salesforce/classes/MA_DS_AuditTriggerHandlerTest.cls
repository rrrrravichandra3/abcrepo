@isTest
public class MA_DS_AuditTriggerHandlerTest {
    private Static String maESName = 'auditTriggerHandler';
    @testSetup
    public static void MS_DS_TestSetupMethod(){
        User adminUsr = MA_DS_TestUtility.getDSAdmin(maESName);
        System.runAs(adminUsr){
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
            //AcqContacts[0].Acquisition_Company__c = null;
            AcqContacts[0].MA_DS_No_Offer__c =  false; 
            AcqContacts[0].MA_DS_Offer_Declined__c = false;
            
            system.debug('AcqContacts[0].Offer_Communicator__c'+AcqContacts[0].Offer_Communicator__c);
            insert AcqContacts;
            
            AcqContacts[0].Offer_Communicator__c = AcqContacts[1].id;
            //update AcqContacts;
            
            Acquisition_Compensation__c acompen = new Acquisition_Compensation__c();
            acompen.Car_Allowance_Amount__c = 11;
            acompen.Acquisition_Contact__c = AcqContacts[0].id;
            insert acompen;
            
            List<MA_DS_Package__c> masterPackages = MA_DS_TestUtility.getMasterPackages();
            masterPackages[0].MA_DS_Acquisition_Company__c = acqCompany.id;
            insert masterPackages;
            MA_DS_Package_Distribution__c packageDistribution = MA_DS_TestUtility.createPackageDistribution(masterPackages[0].Id);
            
            //packageDistribution1.Name = 'Test Distribution1';
            //packageDistribution1.MA_DS_Rules_Sync_Status__c = 'Need Sync - Template Rules';
            packageDistribution.MA_DS_Status__c = 'Ready for Summary';
            packageDistribution.MA_DS_Package_Distribution_Stage__c = 'Ready for Manager Summary Prep';
            packageDistribution.MA_DS_Summary_Required__c = true;
            //packageDistribution.MA_DS_Integration_Status__c = 'Scheduling Manager Summary Delivery';
            //packageDistribution.MA_DS_Total_In_Need_To_Generate_Summary__c = 1;
            insert packageDistribution;
            
            MA_DS_Applied_Rule__c apldRule = new MA_DS_Applied_Rule__c();
            apldRule.MA_DS_Acquisition_Contact__c = AcqContacts[0].Id;
            apldRule.MA_DS_Package_Distribution__c=packageDistribution.Id;
            apldRule.MA_DS_Rule_Type__c  = 'In Use Template Rule';
            apldRule.MA_DS_Template_Document_Type__c = 'Manager Summary';
            apldRule.MA_DS_Need_To_Generate__c = true;
            insert apldRule;
            
            MA_DS_Applied_Rule__c apldRule1 = new MA_DS_Applied_Rule__c();
            apldRule1.MA_DS_Acquisition_Contact__c = AcqContacts[0].Id;
            apldRule1.MA_DS_Package_Distribution__c=packageDistribution.Id;
            apldRule1.MA_DS_Rule_Type__c  = 'Package Distribution Rule';
            apldRule1.MA_DS_Template_Document_Type__c = 'Manager Summary';
            apldRule1.MA_DS_Need_To_Generate__c = true;
            //insert apldRule1;
            
            List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
            insert masterTemplates;
            
            List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
            insert inUseMasterTemplates;
            
            
            MA_DS_Audit__c listOfAudits = new MA_DS_Audit__c();
            listOfAudits.MA_DS_Acquisition_Company__c = acqCompany.id;
            listOfAudits.MA_DS_Audit_Type__c = 'Manager Summary';
            listOfAudits.MA_DS_Status__c = 'In Progress';
            //listOfAudits.MA_DS_Failed_Common_Id__c = '7077z000008odHjAAI';
            insert listOfAudits;
        }
        
    }
    
    @isTest
    public static void addProcessRulesTestMethod(){
        Test.startTest();
        MA_DS_Audit__c listOfAudits = [SELECT MA_DS_Failed_Common_Id__c,MA_DS_Status__c,
                                       MA_DS_Failed_Regenerate_Attempt_Count__c 
                                       FROM  MA_DS_Audit__c LIMIT 1];
        
        listOfAudits.MA_DS_Failed_Common_Id__c = '{"7077z000008ix9UAAQ":[]}';
        listOfAudits.MA_DS_Status__c = 'Regenerate - All Documents';
        listOfAudits.MA_DS_Failed_Regenerate_Attempt_Count__c = 1;
        Update listOfAudits;
        Test.stopTest();
    }
    
    /*@isTest
    public static void addProcessRulesTestMethod1(){
        
        MA_DS_Audit__c listOfAudits = [Select MA_DS_Failed_Common_Id__c,MA_DS_Status__c,MA_DS_Failed_Regenerate_Attempt_Count__c from  MA_DS_Audit__c LIMIT 1];
        
        listOfAudits.MA_DS_Failed_Common_Id__c = '{"7077z000008ix9UAAQ":[]}';
        listOfAudits.MA_DS_Status__c = 'Regenerate - All Documents';
        listOfAudits.MA_DS_Failed_Regenerate_Attempt_Count__c = 4;
        Update listOfAudits;
    }*/
}