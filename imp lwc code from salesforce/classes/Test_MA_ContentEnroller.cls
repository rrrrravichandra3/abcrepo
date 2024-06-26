/**
* Test Class for MA_ContentEnroller
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         31-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_ContentEnroller {
    private Static String maESName = 'contentEnroll';
    @testSetup 
    static void setupCompanytaskData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
       
        PermissionSet permissionSet = new PermissionSet(
            Name = 'MA_MA_FTE_Permission',
            Label = 'MA MA FTE Permission'
        );
        insert permissionSet;
        
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
    }
    
    
    public static testMethod void test_contentenroll() {
        User portalUser = [SELECT Id FROM User WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        Acquisition_Company__c company = [SELECT Id from Acquisition_Company__c where Name = 'MA'];
        PermissionSet maFTEPS = [SELECT Id FROM PermissionSet WHERE Name = 'MA_MA_FTE_Permission' LIMIT 1];
        
        Group testGroup = new Group(
            Name = 'MA MA Video Group',
            DeveloperName = 'MA_MA_Video_Group',
            Type = 'Regular'
        );
        insert testGroup;
        
        MA_Knowledge_Article_Permissions__c contentPermission = new MA_Knowledge_Article_Permissions__c();
        contentPermission.Company_Id__c = company.Id;
        contentPermission.Acquistion_Contact_Field_Name__c = 'Contractor__c';
        contentPermission.Name = 'MA_MA_FTE_Permission';
        contentPermission.PermissionSet_Id__c = maFTEPS.Id;
        contentPermission.Public_Group_Id__c = testGroup.Id;
        contentPermission.Data_Category_Name__c = 'Organization.FTE';
        insert contentPermission;
        
        Test.StartTest();
        try{
            System.RunAs(portalUser){
                String notificationBody = 'Test Notification' + company.Id;
                MA_MessageProcessing.initNotificationMessaging('MA_GenerateCompanyPermissionSet', 'NOTIFICATION_TITLE', notificationBody, company.Id, new Set<String> {portalUser.Id}, MA_Messaging.NotificationTargetType.RECORD_ID_TYPE);
                Queueable messagingJob = MA_MessageProcessing.getMessagingJob(MA_MessageProcessing.ExecutionType.NOTIFICATION_JOB);
                MA_ContentEnroller.initContentEnrolment(company, contentPermission.Public_Group_Id__c, new List<MA_Knowledge_Article_Permissions__c>{contentPermission});
                MA_ContentEnroller.processContentEnrolment(messagingJob);  
            }
            
        }catch(exception e){
            System.debug('Exception '+e);
        }
        Test.StopTest();  
    }
    
    public static testMethod void test_getDataCategoryMapException() {
        User maESUser = [SELECT id FROM User WHERE Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
 		Acquisition_Contacts__c acqContact = [SELECT Id, Name, Acquisition_Company__c 
                                                         FROM Acquisition_Contacts__c 
                                                         WHERE Name =:maESName limit 1];
        
        Map<String, String> categoryMap = new Map<String, String>();
        Test.StartTest();
        try{
            System.runAs(maESUser){
                categoryMap = MA_ContentEnrolmentHelper.getDataCategoryMap('Organization.');
            } 
        }catch(exception e){
            System.debug('Exception '+e);
        }
        Test.StopTest();  
        Assert.isNotNull(categoryMap.values());
    }
    
    public static testMethod void test_getEnrolledGroupMembers() {
        User maESUser = [SELECT Id FROM User WHERE Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        User portalUser = [SELECT Id,Contact.Acquisition_Contacts__r.Contractor__c 
                           FROM User 
                           WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
 		Acquisition_Contacts__c acqContact = [SELECT Id, Name, Acquisition_Company__c 
                                                         FROM Acquisition_Contacts__c 
                                                         WHERE Name =:maESName limit 1];
        Group testGroup = new Group(
            Name = 'MA MA Video Group',
            DeveloperName = 'MA_MA_Video_Group',
            Type = 'Regular'
        );
        insert testGroup;
        
         MA_Community_Video_Mapping__c mapping = new MA_Community_Video_Mapping__c(
                Name ='videoMap',
                Public_Group_Id__c = testGroup.Id,
                Company_Id__c = acqContact.Acquisition_Company__c
            );
        insert mapping;
        
        List<GroupMember> members = new List<GroupMember>();
        Test.StartTest();
        try{
            System.runAs(maESUser){
                members = MA_ContentEnrolmentHelper.getEnrolledGroupMembers(portalUser, testGroup.Id, new  Map<String, Id>{'Contractor__c'  =>testGroup.Id});
                MA_ContentEnrolmentHelper.bulkUpsertEnrolledGroupMembers(members);
                MA_ContentEnrolmentHelper.getCompanyContentPublicGroupIds(new Set<Id>{acqContact.Acquisition_Company__c});
            } 
        }catch(exception e){
            System.debug('Exception: '+e);
        }
        Test.StopTest();  
        Assert.isNotNull(members.size());
    }
    
    public static testMethod void test_getallData() {
        User maESUser = [SELECT Id FROM User WHERE Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        User portalUser = [SELECT Id,Contact.Acquisition_Contacts__r.Contractor__c 
                           FROM User 
                           WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
 		Acquisition_Contacts__c acqContact = [SELECT Id, Name, Acquisition_Company__c 
                                                         FROM Acquisition_Contacts__c 
                                                         WHERE Name =:maESName limit 1];
        Group testGroup = new Group(
            Name = 'MA MA Video Group',
            DeveloperName = 'MA_MA_Video_Group',
            Type = 'Regular'
        );
        insert testGroup;
        
        List<GroupMember> members = new List<GroupMember>();
        Test.StartTest();
        try{
            System.runAs(maESUser){
                MA_ContentEnrolmentHelper.isNewAutoEnrollee(false, testGroup.Id, portalUser, new Map<Id, String>{testGroup.Id => 'Contractor__c'});
                MA_ContentEnrolmentHelper.bulkDeleteEnrolledGroupMembers(members);
            } 
        }catch(exception e){
            System.debug('Exception: '+e);
        }
        Test.StopTest();  
        Assert.areEqual(0,members.size());
    }
}