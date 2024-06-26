@isTest(SeeAllData=false)
public class talentMP_SkillsService_Test {
    @testSetup static void createTestData() {
        String testName = 'skill';
        UserRole adminrole = talentMP_TestUtil.getUserRoleByType(talentMP_TestUtilValues.TALENTMP_ROLETYPE_NONE);
        profile adminuserProfile = talentMP_TestUtil.getUserProfile(talentMP_TestUtilValues.TALENTMP_SYSADMIN_PROFILE);
        List<User> adminUsers = talentMP_TestUtil.createSystemAdminUser(1,adminuserProfile.Id, adminrole.Id, testName, true );
        List<Contact> listContact;
        System.runAs(adminUsers[0]){
            List<Account> listAccount = talentMP_TestUtil.createAccount(1, true);
            listContact = talentMP_TestUtil.createContact(1, 'skill123', listAccount[0].Id, true);
        }
        UserRole role = talentMP_TestUtil.getUserRoleByName(talentMP_TestUtilValues.TALENTMP_CUSTOMER_USERROLE_NAME);
        profile userProfile = talentMP_TestUtil.getUserProfile(talentMP_TestUtilValues.TALENTMP_COMMUNITY_PORTAL_PROFILE);
        
        List<User> portalUsers = talentMP_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, 'skill123', testName, true);
        
        PermissionSet portalUserPS = [SELECT Id FROM PermissionSet WHERE Name =: talentMP_TestUtilValues.TALENTMP_PERMSET LIMIT 1];
        talentMP_TestUtil.createPermissionsetAssignment(portalUserPS.Id, portalUsers[0].Id, true);
        System.runAs(adminUsers[0]){
            Skill__c testSkill = new Skill__c(Name = 'Test Skill', Unique_Skill_Name__c ='Test_Skill');
            insert testSkill;
            
            Skill_Assignment__c testSkillAssignment = new Skill_Assignment__c(
                Skill__c = testSkill.Id,
                Contact__c = portalUsers[0].ContactId
            );
            insert testSkillAssignment;
        }
    }
    
    @isTest
    static void testGetSkillAssignments() {
        User portalUser = [SELECT Id, ContactId, EmployeeNumber FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        
        List<Skill_Assignment__c> result;
        
        Test.startTest();
        System.RunAs(portalUser){
            // Call the method to be tested
            result = talentMP_SkillsService.getSkillAssignments(portalUser.ContactId);
        }
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size(), 'Incorrect number of skill assignments returned');
        System.assertEquals(portalUser.ContactId, result[0].Contact__c, 'Incorrect skill assignment returned');
    }
    
    @isTest
    static void testRemoveSkillAssignments() {
        User portalUser = [SELECT Id, ContactId, EmployeeNumber FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        Skill_Assignment__c testSkillAssignment = [SELECT Skill__c,Contact__c 
                                                   FROM Skill_Assignment__c WHERE Contact__c =: portalUser.ContactId limit 1];
        
        List<String> skillAssignmentIds = new List<String>{ testSkillAssignment.Id };
            
            Test.startTest();
        System.RunAs(portalUser){
            talentMP_SkillsService.removeSkillAssignments(skillAssignmentIds);
        }
        Test.stopTest();
        
        List<Skill_Assignment__c> result = [SELECT Id FROM Skill_Assignment__c WHERE Id = :testSkillAssignment.Id];
        System.assertEquals(0, result.size(), 'Skill assignment was not deleted');
    }
    
    @isTest
    static void testGetSkillsSearchResult() {
        User portalUser = [SELECT Id, ContactId, EmployeeNumber FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        // Test data setup
        String skillName = 'Test Skill Search';
        Skill__c testSkill = new Skill__c(Name = skillName);
        insert testSkill;
        List<Skill__c> result;
        
        Test.startTest();
        System.RunAs(portalUser){
            result = talentMP_SkillsService.getSkillsSearchResult(skillName, new List<String>{ });
        }
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Incorrect number of skills returned');
        System.assertEquals(testSkill.Id, result[0].Id, 'Incorrect skill returned');
        System.assertEquals(skillName, result[0].Name, 'Incorrect skill name returned');
    }
    
    @isTest
    static void testProcessNewSkillAssignments() {
        User portalUser = [SELECT Id, ContactId, EmployeeNumber FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        
        List<String> skillNames = new List<String>{ 'Test Skill', 'Test Skill 1', 'Test Skill 2' };
        List<Id> contactIds = new List<Id>{ portalUser.ContactId };
                
        Test.startTest();
        System.RunAs(portalUser){
            talentMP_SkillsService.processNewSkillAssignments(skillNames, contactIds);
        }
        Test.stopTest();
        
        List<Skill_Assignment__c> result = [SELECT Id FROM Skill_Assignment__c];
        System.assertEquals(4, result.size(), 'Incorrect number of skill assignments created');
    }
}