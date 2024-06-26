@isTest
public with sharing class Test_Utils {
	//Util calss to create reusable test objects
	//You might want to check following easy methods as well.
	//createDefaultJobReq, createDefaultApplication, createDefaultInterview
	
	public static User getUser(String userName) {
        User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name= :userName and u.IsActive=true limit 1];
		return u;
	}
	
	public static  TF2_Department__c createDepartment() {
	    TF2_Department__c dept = new TF2_Department__c(Name = 'Finance', Department_Number__c = 'D_002');
	    insert dept;
	    return dept;
	}
	
	public static Regional_FBP_Lookup__c createRegionalFBPLookup(User approver, User regionalESBP, User GlobalESBP, User fbpOfferApprover) {
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States002', Approver_Name__c = approver.Name, Regional_ESBP__c = regionalESBP.Name, Global_ESBP__c = GlobalESBP.Name,FBP_Offer_Approver__c=fbpOfferApprover.Name);
        insert newLookup;
        return newLookup;
	}
	
	public static ts2__Job__c createJobReq(User recruiter, User manager, TF2_Department__c department, Regional_FBP_Lookup__c regionalFBP) {
	    ts2__Job__c newJob = new ts2__Job__c();
        newJob.ts2__Recruiter__c = recruiter.Id;
        newJob.ts2__Manager__c = manager.Id;
        newJob.ts2__Employment_Type__c = 'Full Time';
        newJob.Region__c = 'AMER';
        newJob.HireType__c = 'Experienced';
        newJob.Grade_Level__c = '9';
        newJob.Exempt_or_Non_Exempt__c = 'Exempt';
        newJob.Department_Name__c = department.Id;
        newJob.Country_of_Employment__c = 'United States';
        newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
        newJob.New_or_Replacement__c = 'Replacement';
        newJob.Reason_Replaced__c = 'Termination';
        newJob.ts2__Localized_Job_Title__c = 'test job';
        newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
        newJob.Name = 'test job';
        newJob.PostingCategory__c = 'Finance';
        newJob.Regional_FBP_Approver__c = regionalFBP.Id;
        newJob.ts2__Business_Unit__c = 'Radian6';
        //newJob.Company_lookup__c = '100 - SFDC, Inc. United States of America';
        //newJob.Region_lookup__c = '412 - Finland';
        newJob.Regional_FBP_Approver__c = regionalFBP.Approver_EID__c;
        
        insert newJob;
        return newJob;
	}
	
	public static Account getCandidatesAccount(){
	    RecordType accountRecordType = [select id,name from RecordType where SObjectType='Account' and name='Candidate'];
		Account account =[Select Id, name from Account Where recordTypeId =: accountRecordType.Id and name='Candidates'];
		return account;
	}
	
	public static Contact createCandidate(Account account, String firstName, String lastName, String email) {
		RecordType contactRecordType = [select id,name from RecordType where SObjectType='Contact' and name='Candidate'];
		Contact candidate = new Contact();
		candidate.RecordTypeId=contactRecordType.Id;
		candidate.AccountId = account.Id;
		candidate.FirstName = firstName;
		candidate.lastName=lastName;
		candidate.email=email;
		candidate.Phone='1111111111';
		candidate.ts2__Text_Resume__c='test123';
		insert candidate;
		return candidate;
	}
	
	public static ts2__application__c createJobApplication (Contact candidate, ts2__Job__c newJob) {
		ts2__application__c applicationInfo = new ts2__application__c();
		applicationInfo.ts2__Candidate_Contact__c = candidate.Id;
		applicationInfo.ts2__Job__c = newJob.Id;
		insert applicationInfo;
		return applicationInfo;
	}
	
	
	public static	ts2__Job__c createDefaultJobReq() {
		User u = Test_Utils.getUser('System Administrator');
		Regional_FBP_Lookup__c fbp = createRegionalFBPLookup(u,u,u,u);
		ts2__Job__c  jobReq = createJobReq (u, u, createDepartment(), fbp);
		insert jobReq;
		return jobReq;
	}

	public static	ts2__application__c createDefaultApplication() {
		User u = Test_Utils.getUser('System Administrator');
		Regional_FBP_Lookup__c fbp = createRegionalFBPLookup(u,u,u,u);
		ts2__Job__c jobReq = createJobReq (u, u, createDepartment(), fbp);
		Contact candidate = createCandidate(getCandidatesAccount(), 'Talented', 'Candidate', 'talented@candidate.com');
		ts2__application__c application = createJobApplication(candidate, jobReq);
		return application;
	}
	
	public static ts2__Interview__c createDefaultInterview() {
		ts2__application__c application = createDefaultApplication();
	    ts2__Interview__c interviewObject = new ts2__Interview__c();
	    interviewObject.ts2__Related_Application__c = application.Id;
	    interviewObject.ts2__Candidate__c = application.ts2__Candidate_Contact__c;
	    interviewObject.ts2__Job__c = application.ts2__Job__c;
	    interviewObject.Interview_Stage__c = 'New';
	    insert interviewObject;
	    return interviewObject;
	}
}