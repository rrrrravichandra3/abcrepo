/**
* Test Class for MA_CommunityEventInviteSender
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         08-11-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class Test_MA_CommunityEventInviteSender {
    private Static String maESName = 'eventInviteSender';
    
    @testSetup 
    static void setupCommunityEventData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(2,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
            
            List<MA_Community_Events__c> listCommunityEvent = MA_TestUtil.createCommunityEvents(listCompany[0].Id, maESName, 1, false);
            listCommunityEvent[0].Last_Processed_Date__c = System.Today();
            listCommunityEvent[0].Last_Processed_State__c = 'Event_Type__c';
            insert listCommunityEvent;
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    public static testMethod void test_executeEventInviteSender(){
        Test.StartTest();
        MA_CommunityEventSendInvites.testJobEnqueued = true;
        MA_CommunityEventSendInvites.EventInviteSenderConfig batchConfig = MA_CommunityEventInviteHelper.getBatchConfig();
        String cronExp = '0 0 0 ? * *'; // Example: runs every day at midnight
        System.schedule('Test MA_CommunityEventInviteSender Schedule', cronExp, new MA_CommunityEventInviteSender(batchConfig));
        Test.StopTest();
        
        // Verify that the batch job has executed (assuming it processes one event at a time)
        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status = 'Completed'];
        System.assert(!jobs.isEmpty(), 'Batch job should have executed');
        
    }

}