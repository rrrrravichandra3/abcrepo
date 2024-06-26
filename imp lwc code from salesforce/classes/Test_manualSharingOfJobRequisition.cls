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
private class Test_manualSharingOfJobRequisition {

    static testMethod void myUnitTest() {
        User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
		TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
		insert dept;
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', Approver_Name__c = u.Name);
		Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', Approver_Name__c = u.Name);
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
		newJob.New_or_Replacement__c = 'New';
		newJob.ts2__Localized_Job_Title__c = 'test job';
		newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
		newJob.Name = 'test job';
		newJob.Confidential__c = false;
		newJob.DoNotShare__c = false;
		insert newJob;
		List<ts2__Job__Share> shareList = [select Id, parentid  from ts2__Job__Share where parentId =:newJob.Id AND RowCause =: 'Manual' ];
		System.Assert(shareList != null);
		
		List<User> userList =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 2];
		ts2__Job__c newJob1 = new ts2__Job__c();
		newJob1.ts2__Recruiter__c = u.Id;
		newJob1.ts2__Manager__c = u.Id;
		newJob1.ts2__Employment_Type__c = 'Full Time';
		newJob1.Region__c = 'AMER';
		newJob1.HireType__c = 'Experienced';
		newJob1.Grade_Level__c = '5';
		newJob1.Exempt_or_Non_Exempt__c = 'Exempt';
		newJob1.Department_Name__c = dept.Id;
		newJob1.Country_of_Employment__c = 'United States';
		newJob1.New_or_Replacement__c = 'New';
		newJob1.ts2__Localized_Job_Title__c = 'test job';
		newJob1.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
		newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
		newJob1.Name = 'test job';
		newJob1.Confidential__c = false;
		newJob1.DoNotShare__c = true;
		newJob1.ts2__Manager__c = userList.get(0).id;
		newJob1.ts2__Recruiter__c = userList.get(1).id;
		newJob1.Regional_FBP_Approver__c = userList.get(0).Id;
		insert newJob1;
		List<ts2__Job__Share> shareList1 = [select Id, parentid  from ts2__Job__Share where parentId =:newJob1.Id AND RowCause =: 'Manual' ];
		System.Assert(shareList1 != null);
		System.Assert(shareList1.size() != 3);
		
		newJob1.ts2__Manager__c = userList.get(1).id;
		newJob1.ts2__Recruiter__c = userList.get(0).id;
		update newJob1;
		List<ts2__Job__Share> shareList2 = [select Id, parentid  from ts2__Job__Share where parentId =:newJob1.Id AND RowCause =: 'Manual' ];
		System.Assert(shareList2 != null);
		System.Assert(shareList2.size() != 3);
		
		newJob1.DoNotShare__c= true;
		newJob1.Confidential__c = true;
		newJob1.Regional_FBP_Approver__c=userList.get(0).id;
		update newJob1;
		System.Assert(shareList2 != null);
		System.Assert(shareList2.size() != 3);
		
		newJob1.Regional_FBP_Approver__c=userList.get(1).id;
		update newJob1;
		System.Assert(shareList2 != null);
		System.Assert(shareList2.size() != 3);
		
    }
    
    static testMethod void myUnitTest4() {
    	TF2_Company__c company = new TF2_Company__c();
    	company.Company_Code__c='TEST';
    	company.Name='Test Company';
    	insert company;
    	TF2_Market_Segment__c marketSegment = new TF2_Market_Segment__c();
    	marketSegment.Market_Segment_Code__c='TEST';
    	marketSegment.Name ='Test Market Segment';
    	insert marketSegment;
    	TF2_PCC__c pcc = new TF2_PCC__c();
    	pcc.PCC_Code__c='TEST';
    	pcc.Name='Test PCC';
    	insert pcc;
    	TF2_Region__c region = new TF2_Region__c();
    	region.Region_Code__c='USS';
    	region.Name='Test Region';
    	insert region;
    	
    	User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
		TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
		insert dept;
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', Approver_Name__c = u.Name);
		Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', Approver_Name__c = u.Name);
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
		newJob.New_or_Replacement__c = 'New';
		newJob.ts2__Localized_Job_Title__c = 'test job';
		newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
		newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
		newJob.Name = 'test job';
		newJob.Confidential__c = false;
		newJob.DoNotShare__c = false;
		insert newJob;
		 RecordType accountRecordType = [select id,name from RecordType where SObjectType='Account' and name='Candidate'];
		Account account =[Select Id, name from Account Where recordTypeId =: accountRecordType.Id and name='Candidates'];
		RecordType contactRecordType = [select id,name from RecordType where SObjectType='Contact' and name='Candidate'];
		Contact candidate1 = new Contact();
		candidate1.RecordTypeId=contactRecordType.Id;
		candidate1.AccountId = account.Id;
		candidate1.FirstName = 'Test FS';
		candidate1.lastName='Test Ls';
		candidate1.email='a@b.com';
		candidate1.Phone='1111111111';
		insert candidate1;
    	ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id,ts2__candidate__c=candidate1.Id);
    	insert offer1;
    	
    	newJob.Market_Segment_lookup__c=marketSegment.id;
		newJob.Company_lookup__c=company.id;
		newJob.PCC_lookup__c=pcc.id;
		newJob.Region_lookup__c=region.id;
		newJob.Time_Type__c='Full Time';
		update newJob;
    	ts2__Offer__c currentOffer = [select Id,name,Market_Segment__c,Company__c,PCC__c,Region_Internal__c,Time_Type__c from ts2__offer__c Where Id =:offer1.id];
    	System.Assert(currentOffer.Market_Segment__c == marketSegment.Market_Segment_Code__c);
    	System.Assert(currentOffer.Company__c == company.Company_Code__c);
    	System.Assert(currentOffer.PCC__c == pcc.PCC_Code__c);
    	System.Assert(currentOffer.Region_Internal__c == region.Region_Code__c);
    }
    static testMethod void myUnitTest2() {
    	/*
    	User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
		TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
		insert dept;
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', Approver_Name__c = u.Name);
		Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', Approver_Name__c = u.Name);
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
		newJob.New_or_Replacement__c = 'New';
		newJob.ts2__Localized_Job_Title__c = 'test job';
		newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
		newJob.Name = 'test job';
		newJob.Confidential__c = false;
		newJob.DoNotShare__c = false;
		insert newJob;
		
		newJob.ts2__Status__c = 'Closed';
		newJob.ts2__Closed_Reason__c='Canceled';
		update newJob;
		List<Task> taskList = [select id,OwnerId,WhatId from Task where OwnerId=:u.Id and whatId =:newJob.Id];
		System.assert(taskList != null);
		System.assert(taskList.size() == 1);
		*/
    	
    }
    static testMethod void myUnitTest3() {
    	/*
    	User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
    	User manager =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='Manager' and u.IsActive=true limit 1];
    	User recuiter =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='Employee' and u.IsActive=true limit 1];
		TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_001');
		insert dept;
		Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States001', Approver_Name__c = u.Name);
		Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan001', Approver_Name__c = u.Name);
		insert newLookup;
		ts2__Job__c newJob = new ts2__Job__c();
		newJob.ts2__Recruiter__c = recuiter.Id;
		newJob.ts2__Manager__c = manager.Id;
		newJob.Regional_FBP_Approver__c = u.id;
		newJob.ts2__Employment_Type__c = 'Full Time';
		newJob.Region__c = 'AMER';
		newJob.HireType__c = 'Experienced';
		newJob.Grade_Level__c = '5';
		newJob.Exempt_or_Non_Exempt__c = 'Exempt';
		newJob.Department_Name__c = dept.Id;
		newJob.Country_of_Employment__c = 'United States';
		newJob.New_or_Replacement__c = 'New';
		newJob.ts2__Localized_Job_Title__c = 'test job';
		newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
		newJob.Name = 'test job';
		newJob.Confidential__c = false;
		newJob.DoNotShare__c = true;
		newJob.ts2__Status__c = 'Closed';
		newJob.ts2__Closed_Reason__c='Canceled';
		newJob.OwnerId= recuiter.Id;
		insert newJob;
		
		
		List<Task> taskList = [select id,OwnerId,WhatId from Task where OwnerId=:recuiter.Id and whatId =:newJob.Id];
		System.assert(taskList != null);
		System.assert(taskList.size() == 1);
		*/
    	
    }
}