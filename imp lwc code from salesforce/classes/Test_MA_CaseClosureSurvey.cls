/**
* Test Class for MA_KnowledgeArticlePubController
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         31-10-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=true)
public class Test_MA_CaseClosureSurvey {
    private Static String maESName = 'caseclosureSurvey';
    
    public static testMethod void test_updateCompanyTaskEnroller(){
        UserRole adminrole = MA_TestUtil.getUserRoleByType(MA_TestUtilityValues.MA_ROLETYPE_NONE);
        profile adminuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_SYSADMIN_PROFILE);
        List<User> adminUsers = MA_TestUtil.createSystemAdminUser(1,adminuserProfile.Id, adminrole.Id,true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        List<Case> listCase = new List<Case>();
        
        System.runAs(adminUsers[0]){
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
            listCase = MA_TestUtil.createCase(1, listContact[0].Id, maESName, true);
            Map<Id, Id> caseIdToContactIdMap = new Map<Id, Id>();
            Map<Id, String> contactIdToCommunityURLMap = new Map<Id, String>();
            
            caseIdToContactIdMap.put(listCase[0].Id,listCase[0].contactId);
            contactIdToCommunityURLMap.put(listCase[0].contactId,'https://pfdev5-peopleforce.cs46.force.com/MA/');
            
            Test.StartTest();
            try{
                System.runAs(adminUsers[0]){
                    MA_CaseClosureSurvey.createCaseClosureSurvey(caseIdToContactIdMap, contactIdToCommunityURLMap);
                } 
            }catch(exception e){
                System.debug('Exception: ' + e.getMessage());
            }
            Test.StopTest(); 
            
        }
    }
}