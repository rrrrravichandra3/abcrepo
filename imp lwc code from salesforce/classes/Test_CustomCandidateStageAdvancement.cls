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
 * required to have at least 75% code coverage in order to be deployedfgloiwso9qikpoertl.jkfdl;ikvbg;lijkjjhlokjkjlo., lk,l;l;;ol;;l;lk,l;,l./.,.,lklmk,klklklk,lkklbhgiojghgbhgfcggsaasfdtfggyutgty
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_CustomCandidateStageAdvancement {

    static testMethod void myUnitTest() {
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
		newJob.TF2_Location__c='San Francisco;';
		newJob.Name = 'test job';
		insert newJob;
		
	    RecordType accountRecordType = [select id,name from RecordType where SObjectType='Account' and name='Candidate'];
		Account account =[Select Id, name from Account Where recordTypeId =: accountRecordType.Id and name='Candidates'];
		RecordType contactRecordType = [select id,name from RecordType where SObjectType='Contact' and name='Candidate'];
		Account employeeAccount = new Account();
		employeeAccount.Name ='Salesforce.com';
		insert employeeAccount;
		
		
		Contact candidate = new Contact();
		candidate.RecordTypeId=contactRecordType.Id;
		candidate.AccountId = account.Id;
		candidate.FirstName = 'Test FS';
		candidate.lastName='Test Ls';
		candidate.email='a@b.com';
		candidate.Phone='1111111111';
		insert candidate;
		
		Contact employeeCnt = new Contact();
		employeeCnt.AccountId = employeeAccount.Id;
		employeeCnt.FirstName = 'Test FS';
		employeeCnt.lastName='Test Ls';
		employeeCnt.email='a@salesforce.com';
		employeeCnt.Phone='1111111111';
		insert employeeCnt;
		
		
		ts2__application__c application = new ts2__application__c();
		application.ts2__job__c = newJob.id;
		application.ts2__Candidate_Contact__c = candidate.Id;
		application.ts2__PrimaryRecruiter__c = u.Id;
		application.ts2__Stage__c='Application';
		application.ts2__Application_Status__c='new';
		insert application;
		
	    ts2__Referral__c referral = new ts2__Referral__c();
		referral.ts2__application_lookup__c=application.Id;
		referral.ts2__r_email__c = employeeCnt.FirstName;
		referral.ts2__r_email__c = employeeCnt.email;
		referral.ts2__Job_Order__c = newJob.Id;
		referral.ts2__r_contact_lookup__c = employeeCnt.Id;
		referral.ts2__p_contact_lookup__c =candidate.Id;
		insert referral;
		
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'MOVE');
		
		CustomCandidateStageAdvancement candidateUpdate = new CustomCandidateStageAdvancement();
		candidateUpdate.checkCurrentStage();
		System.assert(!candidateUpdate.isAppInPlacement);
		System.assert((candidateUpdate.getApplicationStatusList().size() != 0));
		System.assert((candidateUpdate.getRejectReasons().size() != 0));
		List<SelectOption> emailFolderList = candidateUpdate.getEmailFolderList();
		System.assert((emailFolderList.size() != 0));
		SelectOption folderSelectionOption = emailFolderList.get(0);
		candidateUpdate.emailFolderId = folderSelectionOption.getValue();
		List<SelectOption> emailTemplateList = candidateUpdate.getEmailTemplateList();
		System.assert((emailTemplateList.size() != 0));
		SelectOption templateSelectionOption = emailTemplateList.get(0);
		candidateUpdate.emailTemplateId = templateSelectionOption.getValue();
		candidateUpdate.getEmailBody();
		candidateUpdate.notifyCandidate = true;
		candidateUpdate.bccEmailAddress='a@b.com';
		candidateUpdate.ccEmailAddress='a@c.com';
		candidateUpdate.selectedStatus ='Placement';
		candidateUpdate.subject ='Test Email';
		if(candidateUpdate.emailBody == null) {
			candidateUpdate.setEmailBody('Hi {!Contact.Name} test {!ts2__application__c.name} Thanks Recruiter');
		}
		candidateUpdate.moveApplication();
		ts2__placement__c placement = [select id, name from ts2__placement__c where ts2__Related_Application__c =:application.Id AND ts2__Employee__c =:candidate.Id];
		ts2__application__c updateApplication = [select id, name,ts2__stage__c from ts2__application__c Where Id =: application.Id];
		System.assert(updateApplication.ts2__stage__c == 'Placement');
		
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'MOVE');
		
		CustomCandidateStageAdvancement candidateUpdatePlacement1 = new CustomCandidateStageAdvancement();
		candidateUpdatePlacement1.checkCurrentStage();
		System.assert(candidateUpdatePlacement1.isAppInPlacement);
		
    }
    
    
    static testMethod void myUnitTest1() {
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
		newJob.TF2_Location__c='San Francisco;';
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
		
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'MOVE');
		
		CustomCandidateStageAdvancement candidateUpdate = new CustomCandidateStageAdvancement();
		candidateUpdate.checkCurrentStage();
		System.assert(!candidateUpdate.isAppInPlacement);
		System.assert((candidateUpdate.getApplicationStatusList().size() != 0));
		System.assert((candidateUpdate.getRejectReasons().size() != 0));
		List<SelectOption> emailFolderList = candidateUpdate.getEmailFolderList();
		System.assert((emailFolderList.size() != 0));
		SelectOption folderSelectionOption = emailFolderList.get(0);
		candidateUpdate.emailFolderId = folderSelectionOption.getValue();
		List<SelectOption> emailTemplateList = candidateUpdate.getEmailTemplateList();
		System.assert((emailTemplateList.size() != 0));
		SelectOption templateSelectionOption = emailTemplateList.get(0);
		candidateUpdate.emailTemplateId = templateSelectionOption.getValue();
		candidateUpdate.getEmailBody();
		//System.assert(candidateUpdate.emailBody != null);
		candidateUpdate.selectedStatus ='Submittal';
		candidateUpdate.subject ='Test Email';
		if(candidateUpdate.emailBody == null) {
			candidateUpdate.setEmailBody('Test');
		}
		candidateUpdate.setEmailBody('Hi {!Contact.Name} test {!ts2__application__c.name} Thanks Recruiter');
		candidateUpdate.moveApplication();
		ts2__submittal__c submittal = [select id, name from ts2__submittal__c where ts2__Related_Application__c =:application.Id AND ts2__Candidate__c =:candidate.Id];
		//ts2__placement__c placement = [select id, name from ts2__placement__c where ts2__Related_Application__c =:application.Id AND ts2__Employee__c =:candidate.Id];
		ts2__application__c updateApplication = [select id, name,ts2__stage__c from ts2__application__c Where Id =: application.Id];
		System.assert(updateApplication.ts2__stage__c == 'Submittal');
		
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'MOVE');
		
		CustomCandidateStageAdvancement candidateUpdateInterview = new CustomCandidateStageAdvancement();
		candidateUpdateInterview.checkCurrentStage();
		System.assert(!candidateUpdateInterview.isAppInPlacement);
		System.assert((candidateUpdateInterview.getApplicationStatusList().size() != 0));
		System.assert((candidateUpdateInterview.getRejectReasons().size() != 0));
		 emailFolderList = candidateUpdateInterview.getEmailFolderList();
		System.assert((emailFolderList.size() != 0));
		folderSelectionOption = emailFolderList.get(0);
		candidateUpdate.emailFolderId = folderSelectionOption.getValue();
		emailTemplateList = candidateUpdateInterview.getEmailTemplateList();
		System.assert((emailTemplateList.size() != 0));
		templateSelectionOption = emailTemplateList.get(0);
		candidateUpdateInterview.emailTemplateId = templateSelectionOption.getValue();
		candidateUpdateInterview.getEmailBody();
		//System.assert(candidateUpdate.emailBody != null);
		candidateUpdateInterview.selectedStatus ='Interview';
		candidateUpdateInterview.subject ='Test Email';
		if(candidateUpdateInterview.emailBody == null) {
			candidateUpdateInterview.setEmailBody('Test');
		}
		candidateUpdate.setEmailBody('Hi {!Contact.Name} test {!ts2__submittal__c.name} Thanks Recruiter');
		candidateUpdateInterview.moveApplication();
		ts2__interview__c interview = [select id, name from ts2__interview__c where ts2__Related_Application__c =:application.Id AND ts2__Candidate__c =:candidate.Id];
		//ts2__placement__c placement = [select id, name from ts2__placement__c where ts2__Related_Application__c =:application.Id AND ts2__Employee__c =:candidate.Id];
		ts2__application__c updateInterviewApplication = [select id, name,ts2__stage__c from ts2__application__c Where Id =: application.Id];
		System.assert(updateInterviewApplication.ts2__stage__c == 'Interview');
		
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'MOVE');
		
		CustomCandidateStageAdvancement candidateUpdateOffer = new CustomCandidateStageAdvancement();
		candidateUpdateOffer.checkCurrentStage();
		System.assert(!candidateUpdateOffer.isAppInPlacement);
		System.assert((candidateUpdateOffer.getApplicationStatusList().size() != 0));
		System.assert((candidateUpdateOffer.getRejectReasons().size() != 0));
		 emailFolderList = candidateUpdateOffer.getEmailFolderList();
		System.assert((emailFolderList.size() != 0));
		folderSelectionOption = emailFolderList.get(0);
		candidateUpdate.emailFolderId = folderSelectionOption.getValue();
		emailTemplateList = candidateUpdateOffer.getEmailTemplateList();
		System.assert((emailTemplateList.size() != 0));
		templateSelectionOption = emailTemplateList.get(0);
		candidateUpdateOffer.emailTemplateId = templateSelectionOption.getValue();
		candidateUpdateOffer.getEmailBody();
		//System.assert(candidateUpdate.emailBody != null);
		candidateUpdateOffer.selectedStatus ='Offer';
		candidateUpdateOffer.subject ='Test Email';
		if(candidateUpdateOffer.emailBody == null) {
			candidateUpdateOffer.setEmailBody('Test');
		}
		candidateUpdate.setEmailBody('Hi {!Contact.Name} test {!ts2__Interview__c.name} Thanks Recruiter');
		candidateUpdateOffer.moveApplication();
		ts2__offer__c offer = [select id, name from ts2__offer__c where ts2__Related_Application__c =:application.Id AND ts2__Candidate__c =:candidate.Id];
		//ts2__placement__c placement = [select id, name from ts2__placement__c where ts2__Related_Application__c =:application.Id AND ts2__Employee__c =:candidate.Id];
		ts2__application__c updateOfferApplication = [select id, name,ts2__stage__c from ts2__application__c Where Id =: application.Id];
		System.assert(updateOfferApplication.ts2__stage__c == 'Offer');
		
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'MOVE');
		
		CustomCandidateStageAdvancement candidateUpdatePlacement = new CustomCandidateStageAdvancement();
		candidateUpdatePlacement.checkCurrentStage();
		System.assert(!candidateUpdatePlacement.isAppInPlacement);
		System.assert((candidateUpdatePlacement.getApplicationStatusList().size() != 0));
		System.assert((candidateUpdatePlacement.getRejectReasons().size() != 0));
		 emailFolderList = candidateUpdatePlacement.getEmailFolderList();
		System.assert((emailFolderList.size() != 0));
		folderSelectionOption = emailFolderList.get(0);
		candidateUpdate.emailFolderId = folderSelectionOption.getValue();
		emailTemplateList = candidateUpdatePlacement.getEmailTemplateList();
		System.assert((emailTemplateList.size() != 0));
		templateSelectionOption = emailTemplateList.get(0);
		candidateUpdatePlacement.emailTemplateId = templateSelectionOption.getValue();
		candidateUpdatePlacement.getEmailBody();
		//System.assert(candidateUpdate.emailBody != null);
		candidateUpdatePlacement.selectedStatus ='Placement';
		candidateUpdatePlacement.subject ='Test Email';
		if(candidateUpdatePlacement.emailBody == null) {
			candidateUpdatePlacement.setEmailBody('Test');
		}
		
		candidateUpdate.setEmailBody('Hi {!Contact.Name} test {!ts2__offer__c.name} {!ts2__job__c.name} Thanks Recruiter');
		candidateUpdatePlacement.moveApplication();
		ts2__placement__c placement = [select id, name from ts2__placement__c where ts2__Related_Application__c =:application.Id AND ts2__Employee__c =:candidate.Id];
		ts2__application__c updatePlacementApplication = [select id, name,ts2__stage__c from ts2__application__c Where Id =: application.Id];
		System.assert(updatePlacementApplication.ts2__stage__c == 'Placement');
		MoveCandidateUtils.processEmailTemplate(candidateUpdate.emailBody,updatePlacementApplication);
    }   
    
    static testMethod void myUnitTest2() {
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
		newJob.TF2_Location__c='San Francisco;';
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
		
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'REJECT');
		
		CustomCandidateStageAdvancement candidateUpdate = new CustomCandidateStageAdvancement();
		candidateUpdate.checkCurrentStage();
		System.assert(!candidateUpdate.isAppInPlacement);
		System.assert((candidateUpdate.getApplicationStatusList().size() != 0));
		List<SelectOption> rejectReasonList = candidateUpdate.getRejectReasons();
		System.assert((rejectReasonList.size() != 0));
		SelectOption rejectSelectionOption = rejectReasonList.get(0);
		String rejectReason = rejectSelectionOption.getValue();
		if (rejectReasonList.size() > 1) {
			rejectSelectionOption = rejectReasonList.get(1);
			rejectReason = rejectSelectionOption.getValue();
		}
		List<SelectOption> emailFolderList = candidateUpdate.getEmailFolderList();
		System.assert((emailFolderList.size() != 0));
		SelectOption folderSelectionOption = emailFolderList.get(0);
		candidateUpdate.emailFolderId = folderSelectionOption.getValue();
		List<SelectOption> emailTemplateList = candidateUpdate.getEmailTemplateList();
		System.assert((emailTemplateList.size() != 0));
		SelectOption templateSelectionOption = emailTemplateList.get(0);
		candidateUpdate.emailTemplateId = templateSelectionOption.getValue();
		candidateUpdate.getEmailBody();
		//System.assert(candidateUpdate.emailBody != null);
		System.debug('rejectSelectionOption.getValue()--------->'+rejectSelectionOption.getValue());
		candidateUpdate.rejectReason=rejectSelectionOption.getValue();
		candidateUpdate.subject ='Test Email';
		if(candidateUpdate.emailBody == null) {
			candidateUpdate.setEmailBody('Test');
		}
		candidateUpdate.rejectApplication();
		ts2__application__c updateApplication = [select id, name,ts2__stage__c,ts2__Overall_Reject_Reason__c,ts2__Application_Status__c from ts2__application__c Where Id =: application.Id];
		System.assert(updateApplication.ts2__Overall_Reject_Reason__c == rejectSelectionOption.getValue());
		System.assert(updateApplication.ts2__Application_Status__c == 'Rejected');
		System.debug('updateApplication.ts2__Overall_Reject_Reason__c--------->'+updateApplication.ts2__Overall_Reject_Reason__c);
		
		
		ts2__Submittal__c submittal= new  ts2__Submittal__c();   
	    submittal.ts2__Status__c = 'New';  
	    submittal.ts2__Candidate__c = candidate.Id;   
	    submittal.ts2__Job__c =newJob.Id;      
	    submittal.ts2__Related_Application__c = application.Id ;    
	    insert submittal;
	        
	    application.ts2__Status__c='Accepted';
		application.ts2__Stage__c = 'Submittal';
		update application;
                
        Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
		Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'REJECT');
		
		CustomCandidateStageAdvancement candidateSubmittalUpdate = new CustomCandidateStageAdvancement();
		candidateSubmittalUpdate.checkCurrentStage();
		System.assert(!candidateSubmittalUpdate.isAppInPlacement);
		System.assert((candidateSubmittalUpdate.getApplicationStatusList().size() != 0));
		rejectReasonList = candidateSubmittalUpdate.getRejectReasons();
		System.assert((rejectReasonList.size() != 0));
		rejectSelectionOption = rejectReasonList.get(0);
		rejectReason = rejectSelectionOption.getValue();
		if (rejectReasonList.size() > 1) {
			rejectSelectionOption = rejectReasonList.get(1);
			rejectReason = rejectSelectionOption.getValue();
		}
		emailFolderList = candidateSubmittalUpdate.getEmailFolderList();
		System.assert((emailFolderList.size() != 0));
		folderSelectionOption = emailFolderList.get(0);
		candidateSubmittalUpdate.emailFolderId = folderSelectionOption.getValue();
		emailTemplateList = candidateSubmittalUpdate.getEmailTemplateList();
		System.assert((emailTemplateList.size() != 0));
		templateSelectionOption = emailTemplateList.get(0);
		candidateSubmittalUpdate.emailTemplateId = templateSelectionOption.getValue();
		candidateSubmittalUpdate.getEmailBody();
		//System.assert(candidateSubmittalUpdate.emailBody != null);
		System.debug('rejectSelectionOption.getValue()--------->'+rejectSelectionOption.getValue());
		candidateSubmittalUpdate.rejectReason=rejectSelectionOption.getValue();
		candidateSubmittalUpdate.subject ='Test Email';
		if(candidateSubmittalUpdate.emailBody == null) {
			candidateSubmittalUpdate.setEmailBody('Test');
		}
		candidateSubmittalUpdate.rejectApplication();
		ts2__application__c updateSubmittalApplication = [select id, name,ts2__stage__c,ts2__Overall_Reject_Reason__c,ts2__Application_Status__c from ts2__application__c Where Id =: application.Id];
		System.assert(updateSubmittalApplication.ts2__Overall_Reject_Reason__c == rejectSelectionOption.getValue());
		System.assert(updateSubmittalApplication.ts2__Application_Status__c == 'Rejected');
		System.debug('updateSubmittalApplication.ts2__Overall_Reject_Reason__c--------->'+updateSubmittalApplication.ts2__Overall_Reject_Reason__c);
		
		ts2__Interview__c interview= new  ts2__Interview__c();   
			        interview.ts2__Status__c = 'New';  
			        interview.ts2__Candidate__c = candidate.Id;   
			        interview.ts2__Job__c =newJob.Id;      
			        interview.ts2__Related_Application__c = application.Id ;    
			        insert interview;

			        application.ts2__Status__c='Accepted';
				application.ts2__Stage__c = 'Interview';
		                update application;
                                Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
				Apexpages.currentPage().getParameters().put('appID', application.Id);
				Apexpages.currentPage().getParameters().put('operation', 'REJECT');
				
				CustomCandidateStageAdvancement candidateInterviewUpdate = new CustomCandidateStageAdvancement();
				candidateInterviewUpdate.checkCurrentStage();
				System.assert(!candidateInterviewUpdate.isAppInPlacement);
				System.assert((candidateInterviewUpdate.getApplicationStatusList().size() != 0));
				rejectReasonList = candidateInterviewUpdate.getRejectReasons();
				System.assert((rejectReasonList.size() != 0));
				rejectSelectionOption = rejectReasonList.get(0);
				rejectReason = rejectSelectionOption.getValue();
				if (rejectReasonList.size() > 1) {
					rejectSelectionOption = rejectReasonList.get(1);
					rejectReason = rejectSelectionOption.getValue();
				}
				emailFolderList = candidateInterviewUpdate.getEmailFolderList();
				System.assert((emailFolderList.size() != 0));
				folderSelectionOption = emailFolderList.get(0);
				candidateInterviewUpdate.emailFolderId = folderSelectionOption.getValue();
				emailTemplateList = candidateInterviewUpdate.getEmailTemplateList();
				System.assert((emailTemplateList.size() != 0));
				templateSelectionOption = emailTemplateList.get(0);
				candidateInterviewUpdate.emailTemplateId = templateSelectionOption.getValue();
				candidateInterviewUpdate.getEmailBody();
				//System.assert(candidateInterviewUpdate.emailBody != null);
				System.debug('rejectSelectionOption.getValue()--------->'+rejectSelectionOption.getValue());
				candidateInterviewUpdate.rejectReason=rejectSelectionOption.getValue();
				candidateInterviewUpdate.subject ='Test Email';
				if(candidateInterviewUpdate.emailBody == null) {
					candidateInterviewUpdate.setEmailBody('Test');
				}
				candidateInterviewUpdate.rejectApplication();
				ts2__application__c updateInterviewApplication = [select id, name,ts2__stage__c,ts2__Overall_Reject_Reason__c,ts2__Application_Status__c from ts2__application__c Where Id =: application.Id];
				System.assert(updateInterviewApplication.ts2__Overall_Reject_Reason__c == rejectSelectionOption.getValue());
				System.assert(updateInterviewApplication.ts2__Application_Status__c == 'Rejected');
		        System.debug('updateInterviewApplication.ts2__Overall_Reject_Reason__c--------->'+updateInterviewApplication.ts2__Overall_Reject_Reason__c);
		        
		     
    }   
    static testMethod void myUnitTest3() {
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
		newJob.TF2_Location__c='San Francisco;';
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
		
		ts2__offer__c offer= new  ts2__offer__c();   
			offer.ts2__Status__c = 'New';  
			offer.ts2__Candidate__c = candidate.Id;   
			offer.ts2__Job__c =newJob.Id;      
			offer.ts2__Related_Application__c = application.Id ;    
			insert offer;

			application.ts2__Status__c='Accepted';
			application.ts2__Stage__c = 'Offer';
			update application;
			Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
			Apexpages.currentPage().getParameters().put('appID', application.Id);
			Apexpages.currentPage().getParameters().put('operation', 'REJECT');

			CustomCandidateStageAdvancement candidateOfferUpdate = new CustomCandidateStageAdvancement();
			candidateOfferUpdate.checkCurrentStage();
			System.assert(!candidateOfferUpdate.isAppInPlacement);
			System.assert((candidateOfferUpdate.getApplicationStatusList().size() != 0));
			List<SelectOption> rejectReasonList = candidateOfferUpdate.getRejectReasons();
			System.assert((rejectReasonList.size() != 0));
			SelectOption rejectSelectionOption = rejectReasonList.get(0);
			String rejectReason = rejectSelectionOption.getValue();
			if (rejectReasonList.size() > 1) {
				rejectSelectionOption = rejectReasonList.get(1);
				rejectReason = rejectSelectionOption.getValue();
			}
			List<SelectOption> emailFolderList = candidateOfferUpdate.getEmailFolderList();
			System.assert((emailFolderList.size() != 0));
			SelectOption folderSelectionOption = emailFolderList.get(0);
			candidateOfferUpdate.emailFolderId = folderSelectionOption.getValue();
			List<SelectOption> emailTemplateList = candidateOfferUpdate.getEmailTemplateList();
			System.assert((emailTemplateList.size() != 0));
			SelectOption templateSelectionOption = emailTemplateList.get(0);
			candidateOfferUpdate.emailTemplateId = templateSelectionOption.getValue();
			candidateOfferUpdate.getEmailBody();
			//System.assert(candidateOfferUpdate.emailBody != null);
			System.debug('rejectSelectionOption.getValue()--------->'+rejectSelectionOption.getValue());
			candidateOfferUpdate.rejectReason=rejectSelectionOption.getValue();
			candidateOfferUpdate.subject ='Test Email';
			if(candidateOfferUpdate.emailBody == null) {
				candidateOfferUpdate.setEmailBody('Test');
			}
			candidateOfferUpdate.rejectApplication();
			ts2__application__c updateOfferApplication = [select id, name,ts2__stage__c,ts2__Overall_Reject_Reason__c,ts2__Application_Status__c from ts2__application__c Where Id =: application.Id];
			System.assert(updateOfferApplication.ts2__Overall_Reject_Reason__c == rejectSelectionOption.getValue());
			System.assert(updateOfferApplication.ts2__Application_Status__c == 'Rejected');
			System.debug('updateOfferApplication.ts2__Overall_Reject_Reason__c--------->'+updateOfferApplication.ts2__Overall_Reject_Reason__c);
    }
    static testMethod void myUnitTest4() {
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
		newJob.TF2_Location__c='San Francisco;';
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
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
	    Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'REJECT');

		CustomCandidateStageAdvancement candidateOfferUpdate = new CustomCandidateStageAdvancement();
		candidateOfferUpdate.checkCurrentStage();
		candidateOfferUpdate.rejectApplication();
		System.assert(Apexpages.hasMessages());
		
		Apexpages.currentPage().getParameters().put('candidateID', candidate.Id);
	    Apexpages.currentPage().getParameters().put('appID', application.Id);
		Apexpages.currentPage().getParameters().put('operation', 'MOVE');

		CustomCandidateStageAdvancement candidateMoveUpdate = new CustomCandidateStageAdvancement();
		candidateMoveUpdate.checkCurrentStage();
		candidateMoveUpdate.rejectApplication();
		System.assert(Apexpages.hasMessages());
    	
    }
    
      
}