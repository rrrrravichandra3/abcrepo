/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_ApplicationModifications {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
        TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
        insert dept;
        Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', 
        Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name,FBP_Offer_Approver__c=u.Name);
        insert newLookup;
        ts2__Job__c newJob = new ts2__Job__c();
        newJob.ts2__Recruiter__c = u.Id;
        newJob.ts2__Manager__c = u.Id;
        newJob.ts2__Employment_Type__c = 'Full Time';
        newJob.Region__c = 'AMER';
        newJob.HireType__c = 'Experienced';
        newJob.Grade_Level__c = '9';
        newJob.Exempt_or_Non_Exempt__c = 'Exempt';
        newJob.Department_Name__c = dept.Id;
        newJob.Country_of_Employment__c = 'United States';
        newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
        newJob.New_or_Replacement__c = 'Replacement';
        newJob.Reason_Replaced__c = 'Termination';
        newJob.ts2__Localized_Job_Title__c = 'test job';
        newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
        newJob.Name = 'test job';
        insert newJob;
        
        RecordType accountRecordType = [select id,name from RecordType where SObjectType='Account' and name='Candidate'];
		Account account =[Select Id, name from Account Where recordTypeId =: accountRecordType.Id and name='Candidates'];
		RecordType contactRecordType = [select id,name from RecordType where SObjectType='Contact' and name='Candidate'];
		Contact candidate = new Contact();
		candidate.RecordTypeId=contactRecordType.Id;
		candidate.AccountId = account.Id;
		candidate.FirstName = 'Test FS';
		candidate.lastName='Test Ls';
		candidate.email='a@b.com';
		candidate.Phone='1111111111';
		candidate.ts2__Text_Resume__c='test123';
		insert candidate;
		
		ts2__application__c applicationInfo = new ts2__application__c();
		applicationInfo.ts2__Candidate_Contact__c = candidate.Id;
		applicationInfo.ts2__Job__c = newJob.Id;
		insert applicationInfo;
		
		ts2__application__c app = [select id, name , resume__c from ts2__application__c where Id =:applicationInfo.Id];
		System.assert(app.resume__c != null);
		
		System.assertEquals(candidate.ts2__Text_Resume__c,app.resume__c, 'Resume are not configured properly');
                
        candidate.ts2__Text_Resume__c='test123456123';
        update candidate;
        ts2__application__c app1 = [select id, name , resume__c from ts2__application__c where Id =:applicationInfo.Id];
		System.assert(app1.resume__c != null);
		
		System.assertEquals(candidate.ts2__Text_Resume__c,app1.resume__c, 'Resume are not configured properly');
                        
        Test.stopTest();
        
    }
}