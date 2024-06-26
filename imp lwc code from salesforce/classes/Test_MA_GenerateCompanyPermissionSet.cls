/**
* Test Class for MA_GenerateCompanyPermissionSet
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         31-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_GenerateCompanyPermissionSet {
    private Static String maESName = 'generatecompanyPer';
    @testSetup 
    static void setupCompanytaskData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,false);
            listCompany[0].Permission_Sets_Created__c = false;
            listCompany[0].Acquisition_Company_Name__c = 'M_A';
            listCompany[0].Name = 'MA';
            listCompany[0].Category_API_Name__c = 'Organization.All.M_A';
            insert listCompany[0];
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            listAcqContacts[0].Background_Check__c = 'In Process';
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
            
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
        /* DataCategoryGroup dcatGroup = new DataCategoryGroup(
            DeveloperName = 'Organization',
            SobjectType = 'Acquisition_Company__c' // Replace with your relevant object type
        );
        insert dcatGroup;
        DataCategory dcat = new DataCategory(
            Name = 'All',
            DataCategoryGroupName = 'Organization'
        );
        insert dcat;
        // Add a child Data Category
        DataCategory childDcat = new DataCategory(
            Name = 'M_A',
            DataCategoryGroupName = 'Organization',
            ParentId = dcat.Id
        );
        insert childDcat;*/
    }
    public static testMethod void sendNotificationsTest() {
        
        User maESUser = [SELECT id FROM User WHERE Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Acquisition_Company__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        
        Test.StartTest();
        try{
            MA_GenerateCompanyPermissionSet.setupContentSharingPermissions(acqContact.Acquisition_Company__c);
        }catch(exception e){
            System.debug('Exception '+e);
        }
        
        Test.StopTest();  
        
    }
    public static testMethod void sendNotificationsTest_Exception() {
        
        User maESUser = [SELECT id FROM User WHERE Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
 		Acquisition_Contacts__c acqContact = [SELECT Id, Name, Acquisition_Company__c 
                                                         FROM Acquisition_Contacts__c 
                                                         WHERE Name =:maESName limit 1];
        
        Test.StartTest();
        try{
            System.runAs(maESUser){
                MA_GenerateCompanyPermissionSet.setupContentSharingPermissions(acqContact.Acquisition_Company__c);
            } 
        }catch(exception e){
            System.debug('Exception '+e);
        }
        Test.StopTest();  
        
    }
  
}