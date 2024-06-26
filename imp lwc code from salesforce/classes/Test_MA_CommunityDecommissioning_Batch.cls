/**
* Test Class for MA_AcquisitionCompensationShareBatch
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         29-12-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_CommunityDecommissioning_Batch {
    private Static String maESName = 'acqCompShareBatch';
    
    @testSetup 
    static void setupData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(2, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(2,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(2, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(2, listAccount[0].Id, listAcqContacts[0].Id, true);
            
            List<MA_Community_Events__c> listCommunityEvent = MA_TestUtil.createCommunityEvents(listCompany[0].Id, maESName, 1, false);
            listCommunityEvent[0].Last_Processed_Date__c = System.Today();
            insert listCommunityEvent;
            
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    @isTest
    static void testBatch() {
        Acquisition_Company__c company = [SELECT Id,Name FROM Acquisition_Company__c LIMIT 1];  
        try{
            Test.startTest();
            MA_CommunityDecommissioning_Batch batch = new MA_CommunityDecommissioning_Batch(company.Name); 
            Database.executeBatch(batch);
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
    }

}