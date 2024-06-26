/**
* Test Class for MA_AcqCompanyTaskProcessor
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         23-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_AcqCompanyTaskSelectEnroller {
    
    private Static String maESName = 'taskSelectController';
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
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    
    public static testMethod void test_updateCompanyTaskEnroller(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName];
        List<Acquisition_Contacts__c> listAcqContact = [SELECT Id, Name, Background_Check__c 
                                                        FROM Acquisition_Contacts__c 
                                                        WHERE Name =:maESName];
        
        List<Contact> contactlist = [SELECT id,name,(select Id from users) FROM Contact where Acquisition_Contacts__c=:listAcqContact[0].Id];
        listComptask[0].Filter_Criteria_Query__c = 'SELECT Id, (SELECT Id FROM Acquisition_Compensation__r ) , (SELECT Id FROM Acquisition_Provisioning__r )  FROM Acquisition_Contacts__c WHERE  Background_Check__c = \'In Process\'  AND Acquisition_Company__c = \''+listComptask[0].Acquisition_Company__c +'\' AND Contact_Status__c != \'Cancelled\'';
        Test.StartTest();
        update listComptask;
        MA_AcqCompanyTaskSelectEnroller.testJobEnqueued = true;
        MA_ProcessChildTasksController.executeCompanyTaskEnroller(listComptask[0].Id);
        Test.StopTest();
        List<Acquisition_Contact_Task__c> acqContask = [SELECT ID, Acquisition_Company_Task__c from Acquisition_Contact_Task__c WHERE Acquisition_Company_Task__c=:listComptask[0].Id];
        Assert.areEqual(1, acqContask.size(), 'Contact Task will be created');   
    }
    
    public static testMethod void test_deleteContactTask(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName];
        List<Acquisition_Contacts__c> listAcqContact = [SELECT Id, Name, Background_Check__c 
                                                        FROM Acquisition_Contacts__c 
                                                        WHERE Name =:maESName];
        List<Contact> contactlist = [SELECT id,name,(select Id from users) FROM Contact where Acquisition_Contacts__c=:listAcqContact[0].Id];
        Test.StartTest();
        MA_AcqCompanyTaskSelectEnroller.testJobEnqueued = true;
        MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig = MA_AcqCompanyTaskEnrollerHelper.getBatchConfig();
        MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful enrolStateful = MA_AcqCompanyTaskEnrollerHelper.getSelectEnrolStateful(listComptask[0], batchConfig);
        enrolStateful.deleteContactTasks = MA_AcqCompanyTaskEnrollerHelper.DeleteContactTasks.COMPANY_MISMATCH;
        MA_AcqCompanyTaskEnroller.getTaskEnrollerStrategy().execute(enrolStateful, MA_AcqCompanyTaskEnroller.TASK_EXECUTION_MODE.SELECT_ENROL);
        Test.StopTest();
        List<Acquisition_Contact_Task__c> acqContask = [SELECT ID, Acquisition_Company_Task__c from Acquisition_Contact_Task__c WHERE Acquisition_Company_Task__c=:listComptask[0].Id];
        Assert.areEqual(0, acqContask.size(), 'Contact Task will be Deleted'); 
    }
    
    public static testMethod void test_MA_ContactTaskPurger(){
        List<Acquisition_Company_Task__c> listComptask = [SELECT Id, Acquisition_Company__c, Subject__c, Status__c, Active__c, Process_Status__c 
                                                          FROM Acquisition_Company_Task__c 
                                                          WHERE Subject__c =:maESName];
        List<Acquisition_Contacts__c> listAcqContact = [SELECT Id, Name, Background_Check__c 
                                                        FROM Acquisition_Contacts__c 
                                                        WHERE Name =:maESName];
        List<Contact> contactlist = [SELECT id,name,(select Id from users) FROM Contact where Acquisition_Contacts__c=:listAcqContact[0].Id];
        listAcqContact[0].Background_Check__c = 'Completed'; 
        update listAcqContact[0];  
        listComptask[0].Filter_Criteria_Query__c = 'SELECT Id, (SELECT Id FROM Acquisition_Compensation__r ) , (SELECT Id FROM Acquisition_Provisioning__r )  FROM Acquisition_Contacts__c WHERE  Background_Check__c = \'In Process\'  AND Acquisition_Company__c = \''+listComptask[0].Acquisition_Company__c +'\' AND Contact_Status__c != \'Cancelled\'';
        Test.StartTest();
        update listComptask;
        MA_AcqCompanyTaskSelectEnroller.testJobEnqueued = true;
        MA_AcqCompanyTaskAutoEnroller.testJobEnqueued = true;
        MA_AcqCompanyTaskEnrolWrapper.TaskEnrollerConfig batchConfig = MA_AcqCompanyTaskEnrollerHelper.getBatchConfig();
        MA_AcqCompanyTaskEnrolWrapper.SelectEnrolStateful enrolStateful = MA_AcqCompanyTaskEnrollerHelper.getSelectEnrolStateful(listComptask[0], batchConfig);
        MA_AcqCompanyTaskEnroller.getTaskEnrollerStrategy().execute(enrolStateful, MA_AcqCompanyTaskEnroller.TASK_EXECUTION_MODE.SELECT_ENROL);
        Test.StopTest();
        List<Acquisition_Contact_Task__c> acqContask = [SELECT ID, Acquisition_Company_Task__c from Acquisition_Contact_Task__c WHERE Acquisition_Company_Task__c=:listComptask[0].Id];
        Assert.areEqual(0, acqContask.size(), 'Contact Task not created'); 
        
    }
    
}