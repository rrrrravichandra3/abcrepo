@isTest
public class MA_DS_ApplyRulesTest {
    @testSetup
    public static void MS_DS_TestSetupMethod(){
        Acquisition_Company__c acqCompany = MA_DS_TestUtility.createAcqCompanies();
        insert acqCompany;
        
        List<Acquisition_Contacts__c> AcqContacts = MA_DS_TestUtility.createAcqContacts(acqCompany.Id,1);
        AcqContacts[0].Employment_Package__c ='Not Started';
        AcqContacts[0].MA_DS_Manager_Summary_Stage__c ='Not Started';
        AcqContacts[0].Office_Address_Country__c ='India';
        AcqContacts[0].Office_Address_State_Province__c = 'Karnataka'; 
        AcqContacts[0].Executive__c = false;
        AcqContacts[0].Confirmed_On__c = datetime.ValueofGmt('2023-05-02 02:43:00');
        AcqContacts[0].Contractor_End_Date__c = system.Today()+10;
        AcqContacts[0].MA_DS_No_Offer__c =  false; 
        AcqContacts[0].MA_DS_Offer_Declined__c = false;
        system.debug('AcqContacts[0].Confirmed_On__c'+AcqContacts[0].Confirmed_On__c);
        insert AcqContacts;
        
        Acquisition_Compensation__c acompen = new Acquisition_Compensation__c();
		acompen.Car_Allowance_Amount__c = 11;
        acompen.Acquisition_Contact__c = AcqContacts[0].id;
        insert acompen;
        
        List<MA_DS_Package__c> masterPackages = MA_DS_TestUtility.getMasterPackages();
        masterPackages[0].MA_DS_Acquisition_Company__c = acqCompany.id;
        insert masterPackages;
        
        MA_DS_Package_Distribution__c packageDistribution = MA_DS_TestUtility.createPackageDistribution(masterPackages[0].Id);
        packageDistribution.MA_DS_Status__c = 'In Definition';
        insert packageDistribution;
        
        List<MA_DS_Template__c> masterTemplates = MA_DS_TestUtility.getMasterTemplates();
        insert masterTemplates;
        
        List<MA_DS_In_Use_Template__c> inUseMasterTemplates = MA_DS_TestUtility.getInUseMasterTemplates(masterPackages, masterTemplates);
        insert inUseMasterTemplates;
    }
    
    @isTest
    public static void addProcessRulesTestMethod(){
        List<MA_DS_Package_Distribution__c> listOfPAckagesDistribution = [Select id from MA_DS_Package_Distribution__c LIMIT 1];
        Test.startTest();
        try{
            MA_DS_ApplyRules.applyRules(listOfPAckagesDistribution[0].id);
        }
        catch (exception e){
             
        }
        
    	Test.stopTest();
    }
}