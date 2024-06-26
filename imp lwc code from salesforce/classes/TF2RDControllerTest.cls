@isTest

class TF2RDControllerTest {

    static testmethod void offerInsertTest1() {
    	TF2RDController controller = new TF2RDController();
    	PageReference result = controller.getResource();
    	PageReference errorPage = new PageReference('/FileNotFound');
    	System.assertEquals(errorPage.getUrl(), result.getUrl());
    	
    	RecordType accountRecordType = [select id,name from RecordType where SObjectType='Account' and name='Candidate'];
		Account account =[Select Id, name from Account Where recordTypeId =: accountRecordType.Id and name='Candidates'];
		RecordType contactRecordType = [select id,name from RecordType where SObjectType='Contact' and name='Candidate'];
		Contact candidate = new Contact();
		candidate.RecordTypeId=contactRecordType.Id;
		candidate.AccountId = account.Id;
    	candidate.FirstName = 'CandidateFirst';
    	candidate.LastName = 'CandidateLast';
		candidate.email='test@sfdc.com';
		candidate.Phone='18001234123';
		insert candidate;

		Attachment attach1 = new Attachment();
		attach1.parentId=candidate.Id;
		attach1.Name='Resume_CandidateFirstCandidateLast';
		attach1.isPrivate = false;
		attach1.body = Blob.valueof('This is a test resume');
		insert attach1;

        User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
        TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
        insert dept;
        Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', 
            Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name,FBP_Offer_Approver__c=u.Name);
        Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', 
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
        List<ts2__Job__c>jList = new List<ts2__Job__c>();
        jList.add(newJob);
        insert jList;
        
        //ts2__Application__c app = new ts2__Application__c();
        // app.ts2__Job__c = newJob.Id;
        //app.ts2__Candidate_Contact__c=candidate;
        
        ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id);
        offer1.ts2__Candidate__c = candidate.Id;
        List<ts2__Offer__c>oList = new List<ts2__Offer__c>();
        oList.add(offer1);
        insert oList;
        
        Test.startTest();
        
        ts2__Offer__c offerCheck = [select id, Regional_FBP_Approver__c, Regional_ESBP__c, CurrencyIsoCode, Corporate_Currency_Multiplier__c,Location__c, Resume_Link__c from ts2__Offer__c where Id = :offer1.Id];
        System.assertNotEquals(null, offerCheck.Resume_Link__c, 'Checking for a Non-Null Resume Token field');
 
  
     	PageReference tokenPage = new PageReference(offerCheck.Resume_Link__c);
     	Test.setCurrentPage(tokenPage);
     	controller = new TF2RDController();
     	result = controller.getResource();
	    PageReference  correctPage = new PageReference('/servlet/servlet.FileDownload?file='+attach1.Id);
    	System.assertEquals(correctPage.getUrl(), result.getUrl());
        
        Test.stopTest();
    }
    
}