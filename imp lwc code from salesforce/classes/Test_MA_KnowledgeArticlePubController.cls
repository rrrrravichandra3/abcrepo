/**
* Test Class for MA_KnowledgeArticlePubController
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         1-11-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_KnowledgeArticlePubController {
    private Static String maESName = 'knowledgearticlePub';
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
        
        UserRole adminrole = MA_TestUtil.getUserRoleByType(MA_TestUtilityValues.MA_ROLETYPE_NONE);
        profile adminuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_SYSADMIN_PROFILE);
        List<User> adminUsers = MA_TestUtil.createSystemAdminUser(1,adminuserProfile.Id, adminrole.Id,true );
        System.runAs(adminUsers[0]){
            MA_TestUtil.createKnowledgeArticle(1, maESName, true);
        }
    }
    
    static testMethod void test_publishKnowledgeArticle() {
        knowledge__kav article = [SELECT Id, Title, KnowledgeArticleId FROM knowledge__kav WHERE Title =: maESName limit 1];
        Test.startTest();
        try{
            EntitySubscription testSubscription = new EntitySubscription(
                ParentId = article.KnowledgeArticleId,
                SubscriberId = UserInfo.getUserId()
            );
            insert testSubscription;
            MA_KnowledgeArticlePublisherController.publishKnowledgeArticle(article.Id);
        }catch(exception e){
            System.debug(e);
        }
        Test.stopTest();
    } 
    
    static testMethod void test_processMessage() {
        knowledge__kav article = [SELECT Id, Title, KnowledgeArticleId FROM knowledge__kav WHERE Title =: maESName limit 1];
        User portalUser = [Select id from user where Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        Test.startTest();
        try{
            KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
            MA_KnowledgeArticlePublisherController.NotifySubscribers testNotifier = new MA_KnowledgeArticlePublisherController.NotifySubscribers(article.Id, article, portalUser.Id);
            testNotifier.processMessages(testNotifier);
        }catch(exception e){
            System.debug(e);
        }
        Test.stopTest();
    }
}