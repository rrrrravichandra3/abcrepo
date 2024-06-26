/**
* Test Class for MA_AcquisitionContact_Handler
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         04-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class Test_MA_AcquisitionContact_Handler {
    private Static String maESName = 'AcqconHandler';
    
	@testSetup
    static void setuptestdata(){
        
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
        	List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, true);
        	listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = false;
        insert portalUsers;

    } 
    
    public static testMethod void test_executeCompanyTaskEnroller(){
        List<Acquisition_Contacts__c> listAcqContacts = [SELECT Id
                                                         FROM Acquisition_Contacts__c];
        // Prepare the invocation parameters
        
        MA_AcquisitionContact_Handler.ContactAqcParameter parameter = new MA_AcquisitionContact_Handler.ContactAqcParameter();
        parameter.acquistionId = listAcqContacts[0].Id;
        parameter.activateUser = true;
        
        List<MA_AcquisitionContact_Handler.ContactAqcParameter> acqparameters = new List<MA_AcquisitionContact_Handler.ContactAqcParameter>{parameter};
        Test.StartTest();
        MA_AcquisitionContact_Handler.deactivateMAUsers(acqparameters);
        Test.StopTest();
        
         // Verify that the user was activated
        User updatedUser = [SELECT IsActive FROM User WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL];
        Assert.areEqual(true, updatedUser.IsActive, 'User should be activated');
    
        
    }
}