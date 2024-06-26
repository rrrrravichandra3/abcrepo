/**
* Test Class for MA_CaseNotifications
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         23-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_CaseNotifications {
    private static final String CASE_CLOSURE_SURVEY_NAME = Label.MA_CaseClose_Survey_Name;
    private Static String maESName = 'casenotification';
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
            
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
        
        
        System.runAs(portalUsers[0]){
            MA_TestUtil.createCase(1, listContact[0].Id, maESName, true);
        }
        
        
    }
    
    public static testMethod void sendNotificationsTest() {
        
        List<MA_CaseNotifications.NotificationDetail> testRecords = new List<MA_CaseNotifications.NotificationDetail>();
        
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        Case c = [Select Id, CaseNumber, contactId, recordTypeId, MA_Survey_Invitation_Link__c, Status, Subject, ContactEmail from Case Where Subject=:maESName+0]; 
        
        MA_CaseNotifications.NotificationDetail nestedRecord = new MA_CaseNotifications.NotificationDetail();
        nestedRecord.caseId = c.Id;
        nestedRecord.caseNumber= c.CaseNumber;
        nestedRecord.contactId= c.contactId;
        nestedRecord.recordTypeId= c.recordTypeId;
        nestedRecord.communityURL = 'https://pfdev5-peopleforce.cs46.force.com/MA/';
        nestedRecord.messageConfigType = 'MA_WayfinderCaseCreation';
        testRecords.add(nestedRecord);
        
        
        Test.StartTest();
        try{
            System.runAs(maESUser){
                MA_MessageProcessing.testJobEnqueued = true;
                MA_CaseNotifications.sendNotifications(testRecords);
            } 
        }catch(exception e){
            System.debug('Exception: ' + e.getMessage());
        }
        
        Test.StopTest();  
        
    }
    
}