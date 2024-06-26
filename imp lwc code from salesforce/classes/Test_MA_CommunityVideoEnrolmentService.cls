@isTest(SeeAllData=false)
public class Test_MA_CommunityVideoEnrolmentService {
    private Static String maESName = 'videoEnrolment';
    
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
            
            MA_Community_Video_Mapping__c mapping = new MA_Community_Video_Mapping__c(
                Name ='videoMap',
                Public_Group_Id__c = testGroup.Id,
                Company_Id__c = listAcqContacts[0].Acquisition_Company__c
            );
            
            insert mapping;
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    
    public static testMethod void test_communityVideoEnroll(){
        
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c, Acquisition_Company__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        User portalUser = [SELECT Id,ContactId,Contact.Acquisition_Contacts__r.Contractor__c
                           FROM User 
                           WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        User esUser = [SELECT Id FROM User WHERE Email = :maESName+MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        
        Group testGroup = new Group(
            Name = 'TestPublicGroup',
            Type = 'Regular'
        );
        insert testGroup;
        GroupMember testGroupMember = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = portalUser.Id
        );
        insert testGroupMember;
        
        System.RunAs(esUser){
            MA_Knowledge_Article_Permissions__c articlepermission = new MA_Knowledge_Article_Permissions__c(
                Name = 'MA_MA_Alias_FTE_Permission',
                Public_Group_Id__c = testGroup.Id,
                Company_Id__c = acqContact.Acquisition_Company__c,
                Acquistion_Contact_Field_Name__c = 'Contractor__c'
            );
            insert articlepermission;
        }
        
        MA_Auto_Enrolment_Event__e testEvent = new MA_Auto_Enrolment_Event__e(
            Acquisition_Company_Id__c = acqContact.Acquisition_Company__c,
            Acquisition_Contact_Ids__c = acqContact.Id
        );
        EventBus.publish(testEvent);
        
        Test.StartTest();
        try{
            MA_ContentAutoEnroller.testJobEnqueued = true;
            new MA_CommunityVideoEnrolmentService().autoEnrol(new List<MA_Auto_Enrolment_Event__e>{testEvent});
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        
        List<GroupMember> acqComEvent = [SELECT Id,UserOrGroupId  from GroupMember WHERE UserOrGroupId=:portalUser.Id];
        Assert.areEqual(portalUser.Id, acqComEvent[0].UserOrGroupId); 
    }
    public static testMethod void test_AutocommunityVideoEnroll(){
        
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c, Acquisition_Company__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        User portalUser = [SELECT Id,ContactId,Contact.Acquisition_Contacts__r.Contractor__c
                           FROM User 
                           WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        User esUser = [Select Id FROM User WHERE Email = :maESName+MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        
        Group testGroup = new Group(
            Name = 'TestPublicGroup',
            Type = 'Regular'
        );
        
        System.RunAs(esUser){
            MA_Knowledge_Article_Permissions__c articlepermission = new MA_Knowledge_Article_Permissions__c(
                Name = 'MA_MA_Alias_FTE_Permission',
                Public_Group_Id__c = testGroup.Id,
                Company_Id__c = acqContact.Acquisition_Company__c,
                Acquistion_Contact_Field_Name__c = 'Contractor__c'
            );
            insert articlepermission;
        }
        MA_Auto_Enrolment_Event__e testEvent = new MA_Auto_Enrolment_Event__e(
            Acquisition_Company_Id__c = acqContact.Acquisition_Company__c,
            Acquisition_Contact_Ids__c = acqContact.Id
        );
        EventBus.publish(testEvent);
        
        Test.StartTest();
        try{
            new MA_CommunityVideoEnrolmentService().autoEnrol(new List<MA_Auto_Enrolment_Event__e>{testEvent});
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        
        List<GroupMember> acqComEvent = [SELECT Id,UserOrGroupId  from GroupMember WHERE UserOrGroupId=:portalUser.Id];
        Assert.areEqual(portalUser.Id, acqComEvent[0].UserOrGroupId); 
    }
    
    public static testMethod void test_purgecommunityVideoEnroll(){
        
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c, Acquisition_Company__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        
        User portalUser = [SELECT Id,ContactId,Contact.Acquisition_Contacts__r.Contractor__c
                           FROM User 
                           WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        User esUser = [Select Id FROM User WHERE Email = :maESName+MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        
        Group testGroup = new Group(
            Name = 'TestPublicGroup',
            Type = 'Regular'
        );
        insert testGroup;
        GroupMember testGroupMember = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = portalUser.Id
        );
        insert testGroupMember;
        
        System.RunAs(esUser){
            MA_Knowledge_Article_Permissions__c articlepermission = new MA_Knowledge_Article_Permissions__c(
                Name = 'MA_MA_Alias_FTE_Permission',
                Public_Group_Id__c = testGroup.Id,
                Company_Id__c = acqContact.Acquisition_Company__c,
                Acquistion_Contact_Field_Name__c = 'Contractor__c'
            );
            insert articlepermission;
            acqContact.Contractor__c = true;
            update acqContact;
        }
        
        MA_Auto_Enrolment_Event__e testEvent = new MA_Auto_Enrolment_Event__e(
            Acquisition_Company_Id__c = acqContact.Acquisition_Company__c,
            Acquisition_Contact_Ids__c = acqContact.Id
        );
        EventBus.publish(testEvent);
        
        Test.StartTest();
        try{
            MA_ContentAutoEnroller.testJobEnqueued = true;
            new MA_CommunityVideoEnrolmentService().autoEnrol(new List<MA_Auto_Enrolment_Event__e>{testEvent});
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
    }
}