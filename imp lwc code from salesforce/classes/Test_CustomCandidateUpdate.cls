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
private class Test_CustomCandidateUpdate {

    static testMethod void applicationTest() {
            User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
		TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
		insert dept;
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', 
			Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name);
		Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', 
			Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name);
		insert newLookup;
		ts2__Job__c newJob = new ts2__Job__c();
		newJob.ts2__Recruiter__c = u.Id;
		newJob.ts2__Manager__c = u.Id;
		newJob.ts2__Employment_Type__c = 'Full Time';
		newJob.Region__c = 'AMER';
		newJob.HireType__c = 'Experienced';
		newJob.Grade_Level__c = '5';
		newJob.Exempt_or_Non_Exempt__c = 'Exempt';
		newJob.Department_Name__c = dept.Id;
		newJob.Country_of_Employment__c = 'United States';
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
		insert candidate;
		
		ts2__application__c application = new ts2__application__c();
		application.ts2__job__c = newJob.id;
		application.ts2__Candidate_Contact__c = candidate.Id;
		application.ts2__PrimaryRecruiter__c = u.Id;
		application.ts2__Stage__c='Application';
		application.ts2__Application_Status__c='new';
		insert application;
		
		Apexpages.currentPage().getParameters().put('jobID', newJob.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('stage', application.ts2__Stage__c);
		
		CustomCandidateUpdate candidateUpdate = new CustomCandidateUpdate(new ApexPages.StandardController(candidate));
		candidateUpdate.selectedReason='test';
		candidateUpdate.getRejectReasons();
		candidateUpdate.reject();
		ts2__application__c app1 =[select id,ts2__Reject_Reason__c,ts2__Application_Status__c,ts2__Overall_Reject_Reason__c,ts2__Status__c from ts2__application__c where Id =:application.id];
		System.assertEquals (app1.ts2__Overall_Reject_Reason__c ,'test','Issue with reject candidate functionality');
		System.assertEquals (app1.ts2__Application_Status__c ,'Rejected','Issue with reject candidate functionality');
		System.assertEquals (app1.ts2__Status__c ,'Rejected','Issue with reject candidate functionality');
		System.assertEquals (app1.ts2__Reject_Reason__c ,'test','Issue with reject candidate functionality');
		System.debug('ts2__Overall_Reject_Reason__c------------>'+ app1.ts2__Overall_Reject_Reason__c);
		
		
		Apexpages.currentPage().getParameters().put('stage', 'RejectSelectedCandidate');
		CustomCandidateUpdate candidateUpdate2 = new CustomCandidateUpdate(new ApexPages.StandardController(candidate));
		candidateUpdate2.selectedReason='test';
		candidateUpdate2.reject();
		
		
		CustomCandidateUpdate candidateUpdate1 = new CustomCandidateUpdate(new ApexPages.StandardController(candidate));
		candidateUpdate1.selectedReason='--None--';
		candidateUpdate1.reject();
		System.debug('Messages------------>'+ Apexpages.hasMessages());
		System.assert(Apexpages.hasMessages());
    }
    
    static testMethod void submittalTest() {
            User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
		TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
		insert dept;
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', 
			Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name);
		Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', 
			Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name);
		insert newLookup;
		ts2__Job__c newJob = new ts2__Job__c();
		newJob.ts2__Recruiter__c = u.Id;
		newJob.ts2__Manager__c = u.Id;
		newJob.ts2__Employment_Type__c = 'Full Time';
		newJob.Region__c = 'AMER';
		newJob.HireType__c = 'Experienced';
		newJob.Grade_Level__c = '5';
		newJob.Exempt_or_Non_Exempt__c = 'Exempt';
		newJob.Department_Name__c = dept.Id;
		newJob.Country_of_Employment__c = 'United States';
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
		insert candidate;
		
		ts2__application__c application = new ts2__application__c();
		application.ts2__job__c = newJob.id;
		application.ts2__Candidate_Contact__c = candidate.Id;
		application.ts2__PrimaryRecruiter__c = u.Id;
		application.ts2__Stage__c='Application';
		application.ts2__Application_Status__c='new';
		insert application;
		
		ts2__submittal__c submittal = new ts2__submittal__c();
		submittal.ts2__Candidate__c= candidate.Id;
		submittal.ts2__Job__c = newJob.id;
		submittal.ts2__Related_Application__c=application.Id;
		insert submittal;
		application.ts2__Stage__c='Submittal';
		update application;
		
		Apexpages.currentPage().getParameters().put('jobID', newJob.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('stage', 'Submittal');
		
		CustomCandidateUpdate candidateUpdate = new CustomCandidateUpdate(new ApexPages.StandardController(candidate));
		candidateUpdate.selectedReason='test';
		candidateUpdate.getRejectReasons();
		candidateUpdate.reject();
		ts2__application__c app1 =[select id,ts2__Reject_Reason__c,ts2__Application_Status__c,ts2__Overall_Reject_Reason__c,ts2__Status__c from ts2__application__c where Id =:application.id];
		ts2__submittal__c sub1 = [select id,ts2__Reject_Reason__c,ts2__Status__c from ts2__submittal__c where Id=: submittal.Id];
		System.assertEquals (app1.ts2__Overall_Reject_Reason__c ,'test','Issue with reject candidate functionality');
		System.assertEquals (app1.ts2__Application_Status__c ,'Rejected','Issue with reject candidate functionality');
		System.assertEquals (sub1.ts2__Status__c ,'Rejected','Issue with reject candidate functionality');
		System.assertEquals (sub1.ts2__Reject_Reason__c ,'test','Issue with reject candidate functionality');
		System.debug('ts2__Overall_Reject_Reason__c------------>'+ app1.ts2__Overall_Reject_Reason__c);
    } 
    
    static testMethod void interviewTest() {
            User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
		TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
		insert dept;
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', 
			Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name);
		Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', 
			Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name);
		insert newLookup;
		ts2__Job__c newJob = new ts2__Job__c();
		newJob.ts2__Recruiter__c = u.Id;
		newJob.ts2__Manager__c = u.Id;
		newJob.ts2__Employment_Type__c = 'Full Time';
		newJob.Region__c = 'AMER';
		newJob.HireType__c = 'Experienced';
		newJob.Grade_Level__c = '5';
		newJob.Exempt_or_Non_Exempt__c = 'Exempt';
		newJob.Department_Name__c = dept.Id;
		newJob.Country_of_Employment__c = 'United States';
		newJob.New_or_Replacement__c = 'Replacement';
		newJob.Reason_Replaced__c = 'Termination';
		newJob.ts2__Localized_Job_Title__c = 'test job';
		newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
		newJob.Name = 'test job';
		newJob.TF2_Location__c='Dusseldorf, Germany';
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
		insert candidate;
		
		ts2__application__c application = new ts2__application__c();
		application.ts2__job__c = newJob.id;
		application.ts2__Candidate_Contact__c = candidate.Id;
		application.ts2__PrimaryRecruiter__c = u.Id;
		application.ts2__Stage__c='Application';
		application.ts2__Application_Status__c='new';
		insert application;
		
		ts2__submittal__c submittal = new ts2__submittal__c();
		submittal.ts2__Candidate__c= candidate.Id;
		submittal.ts2__Job__c = newJob.id;
		submittal.ts2__Related_Application__c=application.Id;
		insert submittal;
		
		ts2__interview__c interview = new ts2__Interview__c();
		interview.ts2__Candidate__c= candidate.id;
		interview.ts2__HiringManager__c= u.Id;
		interview.ts2__Job__c = newJob.id;
		interview.ts2__Related_Application__c=application.Id;
		insert interview;
		application.ts2__Stage__c='Interview';
		update application;
		
		Apexpages.currentPage().getParameters().put('jobID', newJob.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('stage', 'Interview');
		
		CustomCandidateUpdate candidateUpdate = new CustomCandidateUpdate(new ApexPages.StandardController(candidate));
		candidateUpdate.selectedReason='test';
		candidateUpdate.getRejectReasons();
		candidateUpdate.reject();
		ts2__application__c app1 =[select id,ts2__Reject_Reason__c,ts2__Application_Status__c,ts2__Overall_Reject_Reason__c,ts2__Status__c from ts2__application__c where Id =:application.id];
		ts2__interview__c int12 = [select id,ts2__Reject_Reason__c,ts2__Status__c from ts2__interview__c where Id=: interview.Id];
		System.assertEquals (app1.ts2__Overall_Reject_Reason__c ,'test','Issue with reject candidate functionality');
		System.assertEquals (app1.ts2__Application_Status__c ,'Rejected','Issue with reject candidate functionality');
		System.assertEquals (int12.ts2__Status__c ,'Rejected','Issue with reject candidate functionality');
		System.assertEquals (int12.ts2__Reject_Reason__c ,'test','Issue with reject candidate functionality');
		System.debug('ts2__Overall_Reject_Reason__c------------>'+ app1.ts2__Overall_Reject_Reason__c);
    }           
    static testMethod void offerTest() {
            User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
		TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
		insert dept;
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', 
			Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name);
		Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', 
			Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name);
		insert newLookup;
		ts2__Job__c newJob = new ts2__Job__c();
		newJob.ts2__Recruiter__c = u.Id;
		newJob.ts2__Manager__c = u.Id;
		newJob.ts2__Employment_Type__c = 'Full Time';
		newJob.Region__c = 'AMER';
		newJob.HireType__c = 'Experienced';
		newJob.Grade_Level__c = '5';
		newJob.Exempt_or_Non_Exempt__c = 'Exempt';
		newJob.Department_Name__c = dept.Id;
		newJob.Country_of_Employment__c = 'United States';
		newJob.New_or_Replacement__c = 'Replacement';
		newJob.Reason_Replaced__c = 'Termination';
		newJob.ts2__Localized_Job_Title__c = 'test job';
		newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
		newJob.Name = 'test job';
		newJob.TF2_Location__c='Dusseldorf, Germany';
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
		insert candidate;
		
		ts2__application__c application = new ts2__application__c();
		application.ts2__job__c = newJob.id;
		application.ts2__Candidate_Contact__c = candidate.Id;
		application.ts2__PrimaryRecruiter__c = u.Id;
		application.ts2__Stage__c='Application';
		application.ts2__Application_Status__c='new';
		insert application;
		
		ts2__submittal__c submittal = new ts2__submittal__c();
		submittal.ts2__Candidate__c= candidate.Id;
		submittal.ts2__Job__c = newJob.id;
		submittal.ts2__Related_Application__c=application.Id;
		insert submittal;
		
		ts2__Offer__c offer1 = new ts2__Offer__c();
		offer1.Location__c= 'San Francisco, CA';
		offer1.ts2__Job__c = newJob.Id;
		offer1.ts2__Candidate__c=candidate.id;
		offer1.ts2__Related_Application__c=application.id;
		offer1.OfferStatus__c='Approved';
		offer1.Agency_Fee__c= 10;
		offer1.Draw__c='123';
		offer1.ts2__Salary__c =200;
		offer1.ts2__Mileage__c =200;
		offer1.ts2__Meals__c =200;
		offer1.ts2__Hourly__c =200;
		offer1.ts2__Bonus__c =200;
		offer1.Variable__c ='123';
		offer1.Variable_Type__c ='Commission';
		offer1.Target_Variable_Amount__c =200;
		offer1.Stock_Options__c ='200';
		offer1.Requires_Accelerated_Green_Card__c =true;
		offer1.Relocation_Package_Cost__c =200;
		offer1.RSUs__c='123';
		offer1.Quota__c='123';
		offer1.Quota_Currency__c='AUD - Australian Dollar';
		offer1.Quartile__c='2';
		offer1.Non_Standard_Stock__c=true;
		offer1.ImmigrationCost__c=200;
		insert offer1;
		application.ts2__Stage__c='Offer';
		update application;
		
		Apexpages.currentPage().getParameters().put('jobID', newJob.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('stage', 'Offer');
		
		CustomCandidateUpdate candidateUpdate = new CustomCandidateUpdate(new ApexPages.StandardController(candidate));
		candidateUpdate.selectedReason='test';
		candidateUpdate.getRejectReasons();
		candidateUpdate.reject();
		ts2__application__c app1 =[select id,ts2__Reject_Reason__c,ts2__Application_Status__c,ts2__Overall_Reject_Reason__c,ts2__Status__c from ts2__application__c where Id =:application.id];
		ts2__offer__c offer12 = [select id,ts2__Reject_Reason__c,ts2__Status__c from ts2__offer__c where Id=: offer1.Id];
		System.assertEquals (app1.ts2__Overall_Reject_Reason__c ,'test','Issue with reject candidate functionality');
		System.assertEquals (app1.ts2__Application_Status__c ,'Rejected','Issue with reject candidate functionality');
		System.assertEquals (offer12.ts2__Status__c ,'Rejected','Issue with reject candidate functionality');
		System.assertEquals (offer12.ts2__Reject_Reason__c ,'test','Issue with reject candidate functionality');
		System.debug('ts2__Overall_Reject_Reason__c------------>'+ app1.ts2__Overall_Reject_Reason__c);
    }       
}