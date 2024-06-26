/**
* Test Class for MA_CommunityEventsTriggerHandler ,MA_CommunityEventsTriggerHelper , MA_CommunityEventsTriggerUtility 
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         07-11-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class Test_MA_CommunityEventEnrolmentService {
    private Static String maESName = 'eventEnrolService';
    
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
    
    public static testMethod void test_autoEnrollCommunityEventService(){
        List<MA_Community_Events__c> listCommunityEvent = [SELECT Id, Acquisition_Company__c, Name, Event_Invite_Status__c
                                                          FROM MA_Community_Events__c 
                                                          WHERE Name =:maESName+0];
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        
        acqContact.Background_Check__c = 'In Process';
        List<MA_Auto_Enrolment_Event__e> testEvents = new List<MA_Auto_Enrolment_Event__e>();
        
        Test.StartTest();
        update acqContact;
        
        try{
            MA_CommunityEventAutoEnroller.testJobEnqueued = true;
            new MA_CommunityEventEnrolmentService().autoEnrol(testEvents);
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        
        List<MA_Community_Events__c> acqComEvent = [SELECT ID, Event_Invite_Status__c  from MA_Community_Events__c WHERE Id=:listCommunityEvent[0].Id];
        Assert.areEqual('Changes Pending', acqComEvent[0].Event_Invite_Status__c); 
        

    }
    public Static testMethod void test_enqueueEventAutoEnrollerJob(){
        List<MA_Community_Events__c> listCommunityEvent = [SELECT Id, Acquisition_Company__c, Name, Event_Invite_Status__c
                                                          FROM MA_Community_Events__c 
                                                          WHERE Name =:maESName+0];
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        List<MA_Auto_Enrolment_Event__e> testEvents = new List<MA_Auto_Enrolment_Event__e>();
        Test.StartTest();
        MA_Auto_Enrolment_Event__e ee = new MA_Auto_Enrolment_Event__e(
            Acquisition_Contact_Ids__c = acqContact.Id,
            Enrolment_Type__c = 'Community_Event',
            Acquisition_Company_Id__c = listCommunityEvent[0].Acquisition_Company__c);
        testEvents.add(ee);
        EventBus.publish(testEvents);
        try{
            MA_CommunityEventAutoEnroller.testJobEnqueued = true;
            Map<Id, Set<String>> compIdToContactIdsMap = new Map<Id, Set<String>>{
                listCommunityEvent[0].Acquisition_Company__c => new Set<String>{acqContact.Id}};
                    
            List<AggregateResult> companyToEventCountAggList = MA_CommunityEventEnrolmentService.getCompanyIdToEventCountAggList(compIdToContactIdsMap.keySet());
              
            MA_CommunityEventAutoEnroller.StatefulQueueable statefulInstance = getEventAutoEnrolStatefulInstance(companyToEventCountAggList, compIdToContactIdsMap);
            MA_CommunityEventAutoEnroller.enqueueEventAutoEnrollerJob(statefulInstance);
            
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        List<Acquisition_Contact_Task__c> acqContask = [SELECT ID, Status__c,Subject__c from Acquisition_Contact_Task__c WHERE Subject__c =:maESName OR Subject__c =:maESName+1];
       	Assert.isNotNull(acqContask.size()); 
    }
    public Static testMethod void test_getcontactList(){
        List<MA_Community_Events__c> listCommunityEvent = [SELECT Id, Acquisition_Company__c, Name, Event_Invite_Status__c
                                                          FROM MA_Community_Events__c 
                                                          WHERE Name =:maESName+0];
        Set<String> acqConIds = new Set<String>{[SELECT Id, Name, Background_Check__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1].Id};
        List<Acquisition_Contacts__c> acqContactList = new List<Acquisition_Contacts__c>();
        Test.StartTest();
        try{
            acqContactList = MA_CommunityEventAutoEnrollerHelper.getContactList(listCommunityEvent[0], acqConIds);
            
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
       	Assert.isNotNull(acqContactList.size()); 
    }
    private static MA_CommunityEventAutoEnroller.StatefulQueueable getEventAutoEnrolStatefulInstance(List<AggregateResult> companyToEventCountAggList, Map<Id, Set<String>> compIdToContactIdsMap) {
        List<MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper> eventWrapperList = new List<MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper>();
        
        for(AggregateResult companyToEventCountAgg : companyToEventCountAggList) {
            MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper eventWrapper = new MA_CommunityEventAutoEnroller.AutoEnrolEventWrapper();
            eventWrapper.currentCount = 0;
            eventWrapper.totalEvents = (Integer)companyToEventCountAgg.get('eventCount');
            eventWrapper.companyId = (Id)companyToEventCountAgg.get('Acquisition_Company__c');
            eventWrapper.acqContactIds = compIdToContactIdsMap.get(eventWrapper.companyId);
            eventWrapper.events = MA_CommunityEventAutoEnrollerHelper.getCommunityEvents(eventWrapper.companyId);
            eventWrapper.totalEvents = eventWrapper.events.size();
            eventWrapperList.add(eventWrapper);
        }

        return MA_CommunityEventEnrolmentService.getEventAutoEnrolStatefulInstance(eventWrapperList);
    }
}