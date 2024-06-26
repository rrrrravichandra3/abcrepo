@isTest(SeeAllData=false)
public class Test_MA_CompanyConfiVideoController {
    private Static String maESName = 'videoUpload';
    
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
            //insert mapping;
            
            
            MA_Company_Video_Config__mdt config = new MA_Company_Video_Config__mdt(
                Object_Name__c ='Acquisition_Company__c',
                Field_Name__c = 'Acquisition_Companies__c' 
            );
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    public static testMethod void test_getContentVersionList(){
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c, Acquisition_Company__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        user esUser = [Select Id FROM user WHERE Email = :maESName+MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        List<ContentVersion> contentList;
        System.RunAs(esUser){
            MA_Community_Videos__c video = new MA_Community_Videos__c(
                Acquisition_Companies__c= acqContact.Acquisition_Company__c
            );
            insert video;
            contentList = MA_TestUtil.createContentVersion(1, maESName , true);
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=video.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where Id =:contentList[0].Id ].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink; 
        }
        List<ContentVersion> versionList;
        Test.StartTest();
        try{
            versionList = MA_CompanyConfidentialVideoController.getContentVersionList(acqContact.Acquisition_Company__c);
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        Assert.AreEqual(versionList[0].id,contentList[0].Id);
    }
    
    public static testMethod void test_getCompanyVideoRecord(){
        Acquisition_Contacts__c acqContact = [SELECT Id, Name, Background_Check__c, Acquisition_Company__c 
                                              FROM Acquisition_Contacts__c 
                                              WHERE Name =:maESName limit 1];
        user esUser = [Select Id FROM user WHERE Email = :maESName+MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        user portalUser = [Select Id,ContactId FROM user WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        List<ContentVersion> contentList;
        System.RunAs(esUser){
            MA_Community_Videos__c video = new MA_Community_Videos__c(
                Acquisition_Companies__c= acqContact.Acquisition_Company__c
            );
            insert video;
            contentList = MA_TestUtil.createContentVersion(1, maESName , true);
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=video.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where Id =:contentList[0].Id ].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink; 
        }
        List<ContentVersion> versionList;
        Test.StartTest();
        try{
            System.RunAs(portalUser){
                versionList = MA_CompanyConfidentialVideoController.getContentVersionList(null);
            }
        }catch(Exception e){
            System.debug(e);
        }
        Test.StopTest();
        Assert.AreEqual(versionList[0].id,contentList[0].Id);
    }

}