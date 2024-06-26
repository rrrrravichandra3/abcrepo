@isTest
public class te_profilePhotoController_Test {
    @testSetup static void createTestData() {
        String testName = 'proPhoto';
        UserRole adminrole = talentMP_TestUtil.getUserRoleByType(talentMP_TestUtilValues.TALENTMP_ROLETYPE_NONE);
        profile adminuserProfile = talentMP_TestUtil.getUserProfile(talentMP_TestUtilValues.TALENTMP_SYSADMIN_PROFILE);
        List<User> adminUsers = talentMP_TestUtil.createSystemAdminUser(1,adminuserProfile.Id, adminrole.Id, testName,true );
        List<Contact> listContact;
        System.runAs(adminUsers[0]){
            List<Account> listAccount = talentMP_TestUtil.createAccount(1, true);
            listContact = talentMP_TestUtil.createContact(1, 'emp123', listAccount[0].Id, true);
        }
        UserRole role = talentMP_TestUtil.getUserRoleByName(talentMP_TestUtilValues.TALENTMP_CUSTOMER_USERROLE_NAME);
        profile userProfile = talentMP_TestUtil.getUserProfile(talentMP_TestUtilValues.TALENTMP_COMMUNITY_PORTAL_PROFILE);
        
        List<User> portalUsers = talentMP_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, 'emp123', testName, true);
        
        PermissionSet portalUserPS = [SELECT Id FROM PermissionSet WHERE Name =:talentMP_TestUtilValues.TALENTMP_PERMSET  LIMIT 1];
        talentMP_TestUtil.createPermissionsetAssignment(portalUserPS.Id, portalUsers[0].Id, true);
    }
    
    @isTest
    static void testsetProfilePhoto() {
        User portalUser = [SELECT Id,ContactId FROM User 
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        ConnectApi.Photo result;
        try{
            System.RunAs(portalUser){
                result = te_profilePhotoController.setProfilePhoto('Test');
            }
        }catch(Exception e){
            system.debug('Exception: '+e); 
        }
        
        Assert.areEqual(null, result);
    }
    
}