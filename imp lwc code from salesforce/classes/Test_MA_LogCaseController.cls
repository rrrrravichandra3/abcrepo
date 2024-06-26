@isTest(SeeAllData=false)
public class Test_MA_LogCaseController {
    private Static String maESName = 'logaCase';
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
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, false);
            listContact[0].M_A_Community_URL__c = 'https://pfdev5-peopleforce.cs46.force.com/MA/';
            insert listContact;
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
        
        UserRole adminrole = MA_TestUtil.getUserRoleByType(MA_TestUtilityValues.MA_ROLETYPE_NONE);
        profile adminuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_SYSADMIN_PROFILE);
        List<User> adminUsers = MA_TestUtil.createSystemAdminUser(1,adminuserProfile.Id, adminrole.Id,true );
        System.runAs(adminUsers[0]){
            List<knowledge__kav> article = MA_TestUtil.createKnowledgeArticle(1, maESName, false);
            article[0].Article_Owner_Group__c = 'Default';
            insert article;
        }
    }
    static testMethod void test_processMessage() {
        knowledge__kav article = [SELECT Id, Title, KnowledgeArticleId FROM knowledge__kav WHERE Title =: maESName limit 1];
        Acquisition_Contacts__c acqContact = [SELECT Id, Name FROM Acquisition_Contacts__c WHERE Name =: maESName limit 1];
        Contact conRecord = [SELECT Id, Acquisition_Contacts__c FROM Contact WHERE Acquisition_Contacts__c =: acqContact.Id limit 1];
        
        PF_MA_Settings__c customSetting = new PF_MA_Settings__c(
            Default_M_A_Queue_Name__c = 'Default'
        );
        insert customSetting;
        List<Case> listCase = MA_TestUtil.createCase(1, conRecord.Id, maESName, false);
        listCase[0].ContactId = conRecord.Id;
        MA_MessageProcessing.testJobEnqueued = true;
        
        Test.StartTest();
        KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
        try{
            MA_LogCaseController.submitCase(listCase[0], article.Id, 'Log a Case', 'articleCase', 'File');
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        Test.StopTest();
        
    }

}