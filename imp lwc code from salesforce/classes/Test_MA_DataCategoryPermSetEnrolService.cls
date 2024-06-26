@isTest(SeeAllData=false)
public class Test_MA_DataCategoryPermSetEnrolService {
private Static String maESName = 'dataCategoryPermSet';
    
    @testSetup 
    static void setupData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        
        
        Group testGroup = new Group(
            Name = 'TestPublicGroup',
            Type = 'Regular'
        );
        insert testGroup;
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
            
           /* MA_Community_Video_Mapping__c mapping = new MA_Community_Video_Mapping__c(
                Name ='videoMap',
                Public_Group_Id__c = testGroup.Id,
                Company_Id__c = listAcqContacts[0].Acquisition_Company__c
            );
            
            insert mapping;*/
            MA_Knowledge_Article_Permissions__c articlepermission = new MA_Knowledge_Article_Permissions__c(
             	Acquistion_Contact_Field_Name__c = 'Contractor__c',
                PermissionSet_Id__c = maESPS.Id,
                Company_Id__c = listCompany[0].Id
            );
            
            List<MA_Community_Events__c> listCommunityEvent = MA_TestUtil.createCommunityEvents(listCompany[0].Id, maESName, 1, false);
            listCommunityEvent[0].Last_Processed_Date__c = System.Today();
           // insert listCommunityEvent;
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    
    public static testMethod void test_autoEnrollEvent(){
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
           // MA_CommunityEventAutoEnroller.testJobEnqueued = true;
            new MA_DataCategoryPermSetEnrolmentService().autoEnrol(testEvents);
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        
       // List<MA_Community_Events__c> acqComEvent = [SELECT ID, Event_Invite_Status__c  from MA_Community_Events__c WHERE Id=:listCommunityEvent[0].Id];
       // Assert.areEqual('Changes Pending', acqComEvent[0].Event_Invite_Status__c); 
        

    }
}