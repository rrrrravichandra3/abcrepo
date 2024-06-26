@isTest(SeeAllData=true)
public class Test_MA_GenerateCommunityPageUrls {
    private Static String maESName = 'generateComURL';
    
    static testMethod void test_getCompanyList() {
        
        
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        List<knowledge__kav> articles; 
        
        System.runAs(maUser[0]){
            articles = MA_TestUtil.createKnowledgeArticle(1, maESName, false);
            articles[0].Article_Owner_Group__c = 'Default';
            articles[0].UrlName = 'Knowledge-test-1';
            insert articles;
        }
        try{
            MA_GenerateCommunityPageUrls.getCompanyList(articles[0].Id);
        }catch(Exception e){
            system.debug(e);
        }
    }
    
    static testMethod void test_getCompanyList2() {
        
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        List<Acquisition_Company__c> listCompany;
        System.runAs(maUser[0]){
            listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
        }
        
        try{
            MA_GenerateCommunityPageUrls.getCompanyList(listCompany[0].Id);
        }catch(Exception e){
            system.debug(e);
        }
    }
}