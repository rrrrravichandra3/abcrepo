/**
* Test Class for MA_MyTasksController
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         1-11-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_MyTasksController {
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
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(2, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            listAcqContacts[0].Background_Check__c = 'In Process';
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
            
            List<Acquisition_Company_Task__c> listCompanytask = MA_TestUtil.createAcquisitionCompanyTask(listCompany[0].Id,1,false);
            listCompanytask[0].Process_Status__c = MA_TestUtilityValues.STATUS_NEW;
            listCompanytask[0].Subject__c = maESName;
            insert listCompanytask;
            
            MA_TestUtil.createAcquisitionContactTask(listCompanytask[0].Id, listAcqContacts[0].Id, 1, true);
            
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
        
    }
    public static testMethod void test_getActivities() {
        Test.StartTest();
        user portalUser = [Select id from user where Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        List<Acquisition_Contact_Task__c> alltask = new List<Acquisition_Contact_Task__c>();
        System.runAs(portalUser){
            alltask = MA_MyTasksController.getActivities();
        }
        Assert.areEqual(alltask.size(),1,'get all task of the user');
        Test.StopTest();
    }
    
    public static testMethod void test_updateTaskStatusCompleted() {
        Test.StartTest();
        user portalUser = [Select id from user where Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        List<Acquisition_Contact_Task__c> alltask = new List<Acquisition_Contact_Task__c>();
        System.runAs(portalUser){
            alltask = MA_MyTasksController.getActivities();
            MA_MyTasksController.updateTaskStatus(alltask[0],true);
        }
        Test.StopTest();
        Acquisition_Contact_Task__c updatedTask = [SELECT Id,Status__c FROM Acquisition_Contact_Task__c WHERE Id = :alltask[0].Id];
        Assert.areEqual(updatedTask.Status__c, 'Completed');
    }
    
    public static testMethod void test_updateTaskStatusInProgress() {
        Test.StartTest();
        user portalUser = [Select id from user where Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        List<Acquisition_Contact_Task__c> alltask = new List<Acquisition_Contact_Task__c>();
        System.runAs(portalUser){
            alltask = MA_MyTasksController.getActivities();
            MA_MyTasksController.updateTaskStatus(alltask[0],false);
        }
        Test.StopTest();
        Acquisition_Contact_Task__c updatedTask = [SELECT Id,Status__c FROM Acquisition_Contact_Task__c WHERE Id = :alltask[0].Id];
        Assert.areEqual(updatedTask.Status__c, 'In Progress');
    }
    
    public static testMethod void test_getOrgDomainUrl() {
        Test.StartTest();
        MA_MyTasksController.getOrgDomainUrl();
        Test.StopTest();
    }
    
}