@isTest(SeeAllData=false)
public class talentMP_CertificateService_Test {
    @testSetup static void createTestData() {
        String testName = 'certi';
        UserRole adminrole = talentMP_TestUtil.getUserRoleByType(talentMP_TestUtilValues.TALENTMP_ROLETYPE_NONE);
        profile adminuserProfile = talentMP_TestUtil.getUserProfile(talentMP_TestUtilValues.TALENTMP_SYSADMIN_PROFILE);
        List<User> adminUsers = talentMP_TestUtil.createSystemAdminUser(1,adminuserProfile.Id, adminrole.Id, testName, true );
        List<Contact> listContact;
        System.runAs(adminUsers[0]){
            List<Account> listAccount = talentMP_TestUtil.createAccount(1, true);
            listContact = talentMP_TestUtil.createContact(1, 'emp123', listAccount[0].Id, true);
        }
        UserRole role = talentMP_TestUtil.getUserRoleByName(talentMP_TestUtilValues.TALENTMP_CUSTOMER_USERROLE_NAME);
        profile userProfile = talentMP_TestUtil.getUserProfile(talentMP_TestUtilValues.TALENTMP_COMMUNITY_PORTAL_PROFILE);
        
        List<User> portalUsers = talentMP_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, 'emp123', testName, true);
        
        PermissionSet portalUserPS = [SELECT Id FROM PermissionSet WHERE Name =: talentMP_TestUtilValues.TALENTMP_PERMSET LIMIT 1];
        talentMP_TestUtil.createPermissionsetAssignment(portalUserPS.Id, portalUsers[0].Id, true);
        System.runAs(adminUsers[0]){
            Certifications__c testCertification = new Certifications__c(Name = 'Test Certification');
            insert testCertification;
        }
        
    }
    @isTest
    static void testGetCertificatesSearchResult() {
        User portalUser = [SELECT Id,ContactId FROM User 
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        List<Certifications__c> result;
        
        System.RunAs(portalUser){
            result = talentMP_CertificateService.getCertificatesSearchResult('Test', new List<String>{});
        }
        Assert.areNotEqual(null, result);
    }
    
    @isTest
    static void testCreateCertificate() {
        User portalUser = [SELECT Id, ContactId FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        Id certId;
        Test.startTest();
        System.RunAs(portalUser){
            certId = talentMP_CertificateService.createCertificate('SystemAdmin', 'SystemAdmin', 'Base64Data');
        }
        Test.stopTest();
        Assert.areNotEqual(null, certId);
    }
    @isTest
    static void testGetCertificateAssignments() {
        User portalUser = [SELECT Id, ContactId, EmployeeNumber FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        talentMP_CertificateService.CertificationAssignmentWrapper result;
        Test.startTest();
        System.RunAs(portalUser){
            Id certAssignmentId = talentMP_CertificateService.createCertificate('SystemAdmin', 'SystemAdmin', 'Base64Data');
            
            result = talentMP_CertificateService.getCertificateAssignments();
        }
        Test.stopTest();
        Assert.areNotEqual(null, result);
    }
    
    @isTest
    static void testRemoveCertificateAssignments() {
        User portalUser = [SELECT Id,ContactId FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        
        Test.startTest();
        System.RunAs(portalUser){
            Id certAssignmentId = talentMP_CertificateService.createCertificate('SystemAdmin', 'SystemAdmin', 'Base64Data');
            Certification_Assignment__c certAssignment = [SELECT Certifications__c,Contact__c 
                                                          FROM Certification_Assignment__c WHERE Id =: certAssignmentId limit 1];
            talentMP_CertificateService.removeCertificateAssignments(new List<String> {certAssignment.Certifications__c});
        }
        Test.stopTest();
        
        Assert.areEqual(0, [SELECT COUNT() FROM Certification_Assignment__c]);
    }
    
    @isTest
    static void testProcessNewCertificateAssignments() {
        User portalUser = [SELECT Id,ContactId FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        Certifications__c certification = [SELECT Id FROM Certifications__c limit 1];
        
        Test.startTest();
        System.RunAs(portalUser){
            try{
                talentMP_CertificateService.processNewCertificateAssignments(new List<String> {certification.Id});
            }catch(Exception e){
                System.debug('Exception: '+e);
            }
            
        }
        Test.stopTest();
        
        Assert.areEqual(1, [SELECT COUNT() FROM Certification_Assignment__c]);
    }
    
}