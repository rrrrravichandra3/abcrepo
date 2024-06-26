@isTest(SeeAllData=false)
public class talentMP_CareerPathing_Test {
    @testSetup static void createTestData() {
        String testName = 'careerpath';
        UserRole adminrole = talentMP_TestUtil.getUserRoleByType(talentMP_TestUtilValues.TALENTMP_ROLETYPE_NONE);
        profile adminuserProfile = talentMP_TestUtil.getUserProfile(talentMP_TestUtilValues.TALENTMP_SYSADMIN_PROFILE);
        List<User> adminUsers = talentMP_TestUtil.createSystemAdminUser(1,adminuserProfile.Id, adminrole.Id, testName, true );
        List<Contact> listContact;
        System.runAs(adminUsers[0]){
            List<Job_Group__c> jobGroups = new List<Job_Group__c>();
            for(Integer i = 0; i < 3; i++) {
                jobGroups.add(new Job_Group__c(Name = 'Test Job Group ' + i));
            }
            insert jobGroups;
            
            // Create test Job Families related to the first Job Group
            Id jobGroupId = jobGroups[0].Id;
            List<Job_Family__c> jobFamilies = new List<Job_Family__c>();
            for(Integer i = 0; i < 3; i++) {
                jobFamilies.add(new Job_Family__c(Name = 'Test Job Family ' + i, Job_Group__c = jobGroupId, Job_Family_Reference_ID__c = 'Test_Job_Family_'+i));
            }
            insert jobFamilies;
            
            // Create test Job Profiles related to the first Job Family
            Id jobFamilyId = jobFamilies[0].Id;
            List<Job_Profile__c> jobProfiles = new List<Job_Profile__c>();
            for(Integer i = 0; i < 3; i++) {
                jobProfiles.add(new Job_Profile__c(Name = 'Test Job Profile ' + i, Job_Family__c = jobFamilyId, Job_Code__c = '911'+i, Job_Category__c= 'C', Job_Grade__c= '5'));
            }
            insert jobProfiles;
            List<Account> listAccount = talentMP_TestUtil.createAccount(1, true);
            listContact = talentMP_TestUtil.createContact(2, 'cP123', listAccount[0].Id, false);
            listContact[0].Job_Code__c = jobProfiles[0].Job_Code__c;
            listContact[0].Job_Family__c = 'Accounting';
            listContact[0].Job_Profile__c = 'Core';
            listContact[0].ES_DJC_Grade__c = 'COMP_GRADE_05';
            insert listContact;
        }
        UserRole role = talentMP_TestUtil.getUserRoleByName(talentMP_TestUtilValues.TALENTMP_CUSTOMER_USERROLE_NAME);
        profile userProfile = talentMP_TestUtil.getUserProfile(talentMP_TestUtilValues.TALENTMP_COMMUNITY_PORTAL_PROFILE);
        
        List<User> portalUsers = talentMP_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, 'cP123', testName, true);
        
        PermissionSet portalUserPS = [SELECT Id FROM PermissionSet WHERE Name =: talentMP_TestUtilValues.TALENTMP_PERMSET LIMIT 1];
        talentMP_TestUtil.createPermissionsetAssignment(portalUserPS.Id, portalUsers[0].Id, true);
        
    }
    @isTest
    static void testGetJobGroup() {
        Test.startTest();
        List<Job_Group__c> jobGroups = talentMP_CareerPathing.getJobGroup();
        Test.stopTest();
        // Assertions
        System.assertNotEquals(null, jobGroups);
        System.assertEquals(3, jobGroups.size());
    }
    @isTest
    static void testGetJobFamily() {
        String jobGroupId = [SELECT Id FROM Job_Group__c LIMIT 1].Id;
        // Test execution
        Test.startTest();
        List<Job_Family__c> jobFamilies = talentMP_CareerPathing.getJobFamily(jobGroupId);
        Test.stopTest();
        // Assertions
        System.assertNotEquals(null, jobFamilies);
        System.assertEquals(3, jobFamilies.size());
    }
    @isTest
    static void testGetJobProfile() {
        
        String jobFamilyId = [SELECT Id FROM Job_Family__c LIMIT 1].Id;
        // Test execution
        Test.startTest();
        List<Job_Profile__c> jobProfiles = talentMP_CareerPathing.getJobProfile(jobFamilyId);
        Test.stopTest();
        // Assertions
        System.assertNotEquals(null, jobProfiles);
        System.assertEquals(3, jobProfiles.size());
    }
    @isTest
    static void testGetCareerPaths() {
        User portalUser = [SELECT Id, ContactId, EmployeeNumber FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        
        List<talentMP_CareerPathing.JobProfileDummy> careerPaths;
        // Test execution
        Test.startTest();
        System.RunAs(portalUser){
            try{
                careerPaths = talentMP_CareerPathing.getCareerPaths('9110', '9110');
            }catch(Exception e){
                System.debug('Exception: '+e); 
            }
        }
        
        Test.stopTest();
        // Assertions
        System.assertNotEquals(null, careerPaths);
    }
    
    @isTest
    static void testGetContactJobProfile() {
        User portalUser = [SELECT Id, ContactId, EmployeeNumber FROM User
                           WHERE Email =: talentMP_TestUtilValues.TALENTMP_PORTAL_USER_EMAIL limit 1];
        
        Map<String, List<Job_Profile__c>> contactJobProfiles;
        // Test execution
        Test.startTest();
        System.RunAs(portalUser){
            try{
                contactJobProfiles = talentMP_CareerPathing.getContactJobProfile();  
            }catch(Exception e){
                System.debug('Exception: '+e); 
            }
        }
        Test.stopTest();
        // Assertions
        System.assertNotEquals(null, contactJobProfiles);
        System.assertEquals(2, contactJobProfiles.size());
    }
    
    @isTest
    static void testGetAllJobsLateral() {
        List<talentMP_CareerPathing.JobProfileDummy> jobs = new List<talentMP_CareerPathing.JobProfileDummy>();
        jobs.add(new talentMP_CareerPathing.JobProfileDummy('JC1', 'Job1', 1, 'C'));
        jobs.add(new talentMP_CareerPathing.JobProfileDummy('JC2', 'Job2', 2, 'P'));
        jobs.add(new talentMP_CareerPathing.JobProfileDummy('JC3', 'Job3', 3, 'C'));
        Map<Integer, List<talentMP_CareerPathing.jobProfileDummy>> parentJobMap = new Map<Integer, List<talentMP_CareerPathing.JobProfileDummy>>();
        parentJobMap.put(2, new List<talentMP_CareerPathing.JobProfileDummy>{new talentMP_CareerPathing.JobProfileDummy('JC3', 'Job3', 3, 'C')});
        talentMP_CareerPathing.JobProfileDummy currentJob = new talentMP_CareerPathing.JobProfileDummy('JC1', 'Job1', 1, 'C');
        talentMP_CareerPathing.JobProfileDummy futureLaterJob = new talentMP_CareerPathing.JobProfileDummy('JC2', 'Job2', 2, 'P');
        
        // Test execution
        Test.startTest();
        List<talentMP_CareerPathing.JobProfileDummy> result = talentMP_CareerPathing.getAllJobsLateral(jobs, parentJobMap, currentJob, futureLaterJob);
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result);
        System.assertEquals(3, result.size());
    }
    
    @isTest
    static void testGetAllJobsLateralforTwoParentJob() {
        List<talentMP_CareerPathing.JobProfileDummy> jobs = new List<talentMP_CareerPathing.JobProfileDummy>();
        jobs.add(new talentMP_CareerPathing.JobProfileDummy('JC1', 'Job1', 1, 'C'));
        jobs.add(new talentMP_CareerPathing.JobProfileDummy('JC2', 'Job2', 2, 'P'));
        jobs.add(new talentMP_CareerPathing.JobProfileDummy('JC3', 'Job3', 3, 'P'));
        Map<Integer, List<talentMP_CareerPathing.jobProfileDummy>> parentJobMap = new Map<Integer, List<talentMP_CareerPathing.JobProfileDummy>>();
        parentJobMap.put(2, new List<talentMP_CareerPathing.JobProfileDummy>{new talentMP_CareerPathing.JobProfileDummy('JC3', 'Job3', 3, 'C'), new talentMP_CareerPathing.JobProfileDummy('JC4', 'Job4', 4, 'P')});
        talentMP_CareerPathing.JobProfileDummy currentJob = new talentMP_CareerPathing.JobProfileDummy('JC1', 'Job1', 1, 'C');
        talentMP_CareerPathing.JobProfileDummy futureLaterJob = new talentMP_CareerPathing.JobProfileDummy('JC2', 'Job2', 2, 'P');
        
        // Test execution
        Test.startTest();
        List<talentMP_CareerPathing.JobProfileDummy> result = talentMP_CareerPathing.getAllJobsLateral(jobs, parentJobMap, currentJob, futureLaterJob);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(3, result.size());
    }
    
    @isTest
    static void testGetAllJob() {
        List<talentMP_CareerPathing.JobProfileDummy> jobs = new List<talentMP_CareerPathing.JobProfileDummy>();
        jobs.add(new talentMP_CareerPathing.JobProfileDummy('JC1', 'Job1', 1, 'C'));
        jobs.add(new talentMP_CareerPathing.JobProfileDummy('JC2', 'Job2', 2, 'P'));
        Map<Integer, List<talentMP_CareerPathing.jobProfileDummy>> parentJobMap = new Map<Integer, List<talentMP_CareerPathing.JobProfileDummy>>();
        parentJobMap.put(1, new List<talentMP_CareerPathing.JobProfileDummy>{new talentMP_CareerPathing.JobProfileDummy('JC3', 'Job3', 3, 'C')});
        talentMP_CareerPathing.JobProfileDummy currentJob = new talentMP_CareerPathing.JobProfileDummy('JC1', 'Job1', 1, 'C');
        
        // Test execution
        Test.startTest();
        List<talentMP_CareerPathing.JobProfileDummy> result = talentMP_CareerPathing.getAllJobs(jobs, parentJobMap, currentJob);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetContactJobProfileException() {
        Map<String, List<Job_Profile__c>> contactJobProfiles;
        // Test execution
        Test.startTest();
        try{
            contactJobProfiles = talentMP_CareerPathing.getContactJobProfile();  
        }catch(Exception e){
            System.debug('Exception: '+e); 
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetCareerPathsException() {
        List<talentMP_CareerPathing.JobProfileDummy> careerPaths;
        // Test execution
        Test.startTest();
        try{
            careerPaths = talentMP_CareerPathing.getCareerPaths('currentJobCode', 'futureLateralJobCode');
        }catch(Exception e){
            System.debug('Exception: '+e); 
        }
        Test.stopTest();
    }
    
    
}