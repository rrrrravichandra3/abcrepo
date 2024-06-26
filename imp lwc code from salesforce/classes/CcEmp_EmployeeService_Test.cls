/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an org are executed whenever Apex code is deployed
* to a production org to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production org. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the org size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class CcEmp_EmployeeService_Test {
    @testSetup
    static void setup() {
        // Create test data
        User user = new User(
            FirstName = 'Test',
            LastName = 'User',
            EmployeeNumber = '12345',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            Username = 'test.user@example.com.careerconnect',
            Email = 'test.user@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert user;
        System.runAs(user){
            PermissionSet ps = [SELECT Id FROM PermissionSet  WHERE Name = 'Career_Connect_Users'];
            PermissionSetAssignment objAssignment = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = user.Id);
            insert objAssignment;
            
            CcEmp_Certifications__c certification = new CcEmp_Certifications__c(
                Name='test'
            );
            insert certification;
            
            CcEmp_Skill__c objSkill = new CcEmp_Skill__c(Name='test');
            insert objSkill;
            CcEmp_Skill_Assignment__c skillAssignment = new CcEmp_Skill_Assignment__c(
                Worker__c = user.Id,
                Skill__c = objSkill.Id
            );
            insert skillAssignment;
        }
    }
    
    @isTest
    static void testGetEmployeeDataFromSession() {
        User objUser = [SELECT Id FROM User WHERE Username = 'test.user@example.com.careerconnect' LIMIT 1];
        System.runAs(objUser){
            // Create a new instance of the service class
            CcEmp_EmployeeService service = new CcEmp_EmployeeService();
            
            // Get the user Id
            Id userId = service.getUserId();
            
            // Get the employee data
            User employee = service.getEmployeeDataFromSession();
            
            // Perform assertions on the employee data
            System.assertEquals(userId, employee.Id);
            System.assertEquals('Test', employee.FirstName);
            // Add any other assertions as needed
        }
    }
    
    @isTest
    static void testGetEmployeeDataWithWorkerId() {
        User objUser = [SELECT Id FROM User WHERE Username = 'test.user@example.com.careerconnect' LIMIT 1];
        System.runAs(objUser){
            // Create a new instance of the service class
            CcEmp_EmployeeService service = new CcEmp_EmployeeService();
            
            // Get the employee data using the worker Id
            User employee = service.getEmployeeDataWithWorkerId('12345');
            
            // Perform assertions on the employee data
            System.assertEquals('Test', employee.FirstName);
            // Add any other assertions as needed
        }
    }
    
    @isTest
    static void testGetEmployeeSkills() {
        User objUser = [SELECT Id FROM User WHERE Username = 'test.user@example.com.careerconnect' LIMIT 1];
        System.runAs(objUser){
            // Create a new instance of the service class
            CcEmp_EmployeeService service = new CcEmp_EmployeeService();
            
            // Get the user Id
            Id userId = service.getUserId();
            
            // Get the employee skills
            List<CcEmp_Skill_Assignment__c> skills = service.getEmployeeSkills(userId);
            
            // Perform assertions on the skills
            System.assertEquals(1, skills.size());
            
        }
    }
    
    @isTest
    static void testGetEmployeeCertifications() {
        User objUser = [SELECT Id FROM User WHERE Username = 'test.user@example.com.careerconnect' LIMIT 1];
        System.runAs(objUser){
            // Create a new instance of the service class
            CcEmp_EmployeeService service = new CcEmp_EmployeeService();
            
            // Get the user Id
            Id userId = service.getUserId();
            
            // Get the employee certifications
            List<CcEmp_Certification_Assignment__c> certifications = service.getEmployeeCertifications(userId);
            
            
            System.assertEquals(0, certifications.size());
            
        }
    }
}