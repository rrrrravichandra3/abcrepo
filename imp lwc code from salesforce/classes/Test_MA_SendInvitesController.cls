/**
* Test Class for MA_CommunityEventInviteHelper ,MA_CommunityEventInvitesMessaging ,MA_CommunityEventSendInvites, MA_SendInvitesController 
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         08-11-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class Test_MA_SendInvitesController {
    private Static String maESName = 'sendinviteController';
    
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
        List<MA_Community_Events__c> listCommunityEvent = [SELECT Id, Acquisition_Company__c, Name, Event_Invite_Status__c
                                                           FROM MA_Community_Events__c 
                                                           WHERE Name =:maESName+0];
        Acquisition_Contacts__c acqContact = [SELECT Id,Acquisition_Company__c FROM Acquisition_Contacts__c WHERE Name =:maESName];
        MA_Community_Event_Attendee__c comEventAttendee = new MA_Community_Event_Attendee__c(
            Acquisition_Contacts__c = acqContact.Id,
            Community_Event__c = listCommunityEvent[0].Id,
            Key_Identifier__c =String.valueOf(listCommunityEvent[0].Id) + String.valueOf(acqContact.Id),
            RSVP__c = 'Yes');
        
        Test.StartTest();
        upsert comEventAttendee;
        MA_CommunityEventSendInvites.testJobEnqueued = true;
        MA_SendInvitesController.executeEventInviteSender(listCommunityEvent[0].Id);
        Test.StopTest();
        
        List<MA_Community_Event_Attendee__c> eventAttendee = [SELECT Id FROM MA_Community_Event_Attendee__c WHERE Community_Event__c=:listCommunityEvent[0].Id];
        Assert.areEqual(1, eventAttendee.size(),'Event Attendees should be created'); 
        
    }
    
    public static testMethod void test_enqueueDeleteAttendees(){
        List<MA_Community_Events__c> listCommunityEvent = [SELECT Id, Acquisition_Company__c, Name, Event_Invite_Status__c
                                                           FROM MA_Community_Events__c 
                                                           WHERE Name =:maESName+0];
        Acquisition_Contacts__c acqContact = [SELECT Id,Acquisition_Company__c FROM Acquisition_Contacts__c WHERE Name =:maESName];
        MA_Community_Event_Attendee__c comEventAttendee = new MA_Community_Event_Attendee__c(
            Acquisition_Contacts__c = acqContact.Id,
            Community_Event__c = listCommunityEvent[0].Id);
        Acquisition_Company__c acqCompany = [SELECT Id from Acquisition_Company__c WHERE Acquisition_Company_Name__c ='TestCompany_1' limit 1];
        
        Test.StartTest();
        listCommunityEvent[0].Acquisition_Company__c = acqCompany.Id;
        upsert comEventAttendee;
        upsert listCommunityEvent[0];
        MA_CommunityEventSendInvites.testJobEnqueued = true;
        MA_SendInvitesController.executeEventInviteSender(listCommunityEvent[0].Id);
        Test.StopTest();
        
        List<MA_Community_Event_Attendee__c> eventAttendee = [SELECT Id FROM MA_Community_Event_Attendee__c WHERE Community_Event__c=:listCommunityEvent[0].Id];
        Assert.areEqual(0, eventAttendee.size(),'Event Attendee should be Deleted'); 
    }
    
    /* Methods to cover MA_CommunityEventInviteHelper Class*/
    public static testMethod void test_getEventQueryLocator(){
        
        Test.StartTest();
        MA_CommunityEventInviteHelper.getEventQueryLocator();
        Test.StopTest();
        
    }
    
    public static testMethod void test_getContactListFirstBatch(){
        List<MA_Community_Events__c> listCommunityEvent = [SELECT Id, Acquisition_Company__c, Name, Event_Invite_Status__c
                                                           FROM MA_Community_Events__c 
                                                           WHERE Name =:maESName+0];
        
        Test.StartTest();
        MA_CommunityEventInviteHelper.getContactListFirstBatch(listCommunityEvent[0], 200);
        Test.StopTest();
        
    }
    
    public static testMethod void test_queryMoreContactList(){
        List<MA_Community_Events__c> listCommunityEvent = [SELECT Id, Acquisition_Company__c, Name, Event_Invite_Status__c
                                                           FROM MA_Community_Events__c 
                                                           WHERE Name =:maESName+0];
        
        Test.StartTest();
        MA_CommunityEventInviteHelper.queryMoreContactList(listCommunityEvent[0], listCommunityEvent[0].Id, 200);
        Test.StopTest();
        
    }
}