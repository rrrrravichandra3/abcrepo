@isTest

class OfferApproverAssignmentTriggerTest {

    static testmethod void offerInsertTest1() {
        /*      
        Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='standarduser5@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser5@testorg.com', FirstName = 'John');
        User u2 = new User(alias = 'standt', email='standarduser6@testorg.com',
            emailencodingkey='UTF-8', lastname='TEST', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser6@testorg.com', FirstName = 'TEST');
        User u3 = new User(alias = 'standt', email='standarduser7@testorg.com',
            emailencodingkey='UTF-8', lastname='TEST2', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser7@testorg.com', FirstName = 'TEST2');            
        insert u;
        insert u2;
        insert u3;
        */
		
		
		
		
        User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
        TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_899',ECOMM_Level_5__c='Field Sales Quota',ECOMM_Level_4__c='Sales Mgmt',ECOMM_Level_3__c='Non-AE',ECOMM_Level_2__c='Non-AE',ECOMM_Level_1__c='George Hu');
        insert dept;
        Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States899', 
            Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name,FBP_Offer_Approver__c=u.Name);
        Regional_FBP_Lookup__c newLookup2 = new Regional_FBP_Lookup__c(Matrix_ID__c = 'Japan899', 
            Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name,FBP_Offer_Approver__c=u.Name);
        insert newLookup;
        insert newLookup2;
        
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
		candidate.ts2__text_resume__c ='This is test resume note.';
		insert candidate;
		
		Contact candidate1 = new Contact();
		candidate1.RecordTypeId=contactRecordType.Id;
		candidate1.AccountId = account.Id;
		candidate1.FirstName = 'Test FS';
		candidate1.lastName='Test Ls';
		candidate1.email='a@b.com';
		candidate1.Phone='1111111111';
		insert candidate1;
		
		Attachment attach1 = new Attachment();
		attach1.parentId=candidate1.Id;
		attach1.Name='Resume_Test_FS.doc';
		attach1.isPrivate = false;
		attach1.body = Blob.valueof('test');
		insert attach1;
		
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
        newJob.Market_Segment_lookup__c=marketSegment.id;
		newJob.Company_lookup__c=company.id;
		newJob.PCC_lookup__c=pcc.id;
		newJob.Region_lookup__c=region.id;
		newJob.Time_Type__c='Full Time';
        
        ts2__Job__c newJob2 = new ts2__Job__c();
        newJob2.ts2__Recruiter__c = u.Id;
        newJob2.ts2__Manager__c = u.Id;
        newJob2.ts2__Employment_Type__c = 'Full Time';
        newJob2.Region__c = 'Japan';
        newJob2.HireType__c = 'Experienced';
        newJob2.Grade_Level__c = '5';
        newJob2.Exempt_or_Non_Exempt__c = 'Exempt';
        newJob2.Department_Name__c = dept.Id;
        newJob2.Country_of_Employment__c = 'Japan';
        newJob2.TF2_Location__c='Osaka, Japan - å¤§é˜ª, æ—¥æœ¬';
        newJob2.Market_Segment_lookup__c=marketSegment.id;
		newJob2.Company_lookup__c=company.id;
		newJob2.PCC_lookup__c=pcc.id;
		newJob2.Region_lookup__c=region.id;
		newJob2.Time_Type__c='Full Time';
        List<ts2__Job__c>jList = new List<ts2__Job__c>();
        jList.add(newJob);
        
        jList.add(newJob2);
        
        insert jList;
        ts2__Job__c readback = [select id, CurrencyIsoCode from ts2__Job__c where Id = :newJob2.Id];
        System.assertEquals('USD', readback.CurrencyIsoCode,  'Expecting USD since that is tye default currency of the user');
        
        ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id,ts2__candidate__c=candidate.Id);
        
        ts2__Offer__c offer2 = new ts2__Offer__c(ts2__Job__c = newJob2.Id,ts2__candidate__c=candidate1.Id);
        List<ts2__Offer__c>oList = new List<ts2__Offer__c>();
        oList.add(offer1);
        oList.add(offer2); 
        
        Test.startTest();
        insert oList;
        
        ts2__Offer__c offerCheck = [select id, Regional_FBP_Approver__c, Regional_ESBP__c, CurrencyIsoCode, Market_Segment__c,Company__c,PCC__c,Region_Internal__c,Time_Type__c,Corporate_Currency_Multiplier__c,Location__c,resume__c,Highest_Level_ECOMM__c,ES_SVP__c from ts2__Offer__c where Id = :offer1.Id];
        System.assert(offerCheck.resume__c != null);
        System.assertEquals(offerCheck.Regional_FBP_Approver__c, u.id, 'Checking if FBP approver assignment was correct');
        System.assertEquals(offerCheck.Regional_ESBP__c, u.id, 'Checking if Regional ESBP approver assignment was correct');
        //System.assertEquals(offerCheck.Global_ESBP__c, u.id, 'Checking if Global ESBP approver assignment was correct');
        System.assert(offerCheck.Highest_Level_ECOMM__c == null);
        System.assert(offerCheck.ES_SVP__c == null);
		//We set the Country_of_Employment__c to US and verifying that we are getting USD back.
        System.assertEquals('USD', offerCheck.CurrencyIsoCode, 'Checking if Currency Code is correct');
        System.assertEquals(1, offerCheck.Corporate_Currency_Multiplier__c, 'Checking if Corporate Currency Multiplier is correct (UDS)');
	
		//Location of the offer must be the first location of the req
        System.assertEquals('San Francisco, CA', offerCheck.Location__c, 'Checking for Offer Location ');
        
        
    	System.Assert(offerCheck.Market_Segment__c == marketSegment.Market_Segment_Code__c);
    	System.Assert(offerCheck.Company__c == company.Company_Code__c);
    	System.Assert(offerCheck.PCC__c == pcc.PCC_Code__c);
    	System.Assert(offerCheck.Region_Internal__c == region.Region_Code__c);
        
        //Making sure that the currency can be changed on an offer from USD to INR
        offerCheck.CurrencyIsoCode = 'INR';
        update offerCheck;
        offerCheck = [select id, Regional_FBP_Approver__c, Regional_ESBP__c, CurrencyIsoCode, Corporate_Currency_Multiplier__c,Location__c from ts2__Offer__c where Id = :offer1.Id];

		//Making sure that the new currency is INR
        System.assertEquals('INR', offerCheck.CurrencyIsoCode, 'Checking if Currency Code is correct');
        System.assertNotEquals(1, offerCheck.Corporate_Currency_Multiplier__c, 'Checking if Corporate Currency Multiplier is not 1 (USD)');

		/*
		//If you comment out the line  newJob2.Country_of_Employment__c='Japan';;
		//No currency was set to For newJob2. So offer2 to should pick up the default locale currency USD
        offerCheck = [select id, Regional_FBP_Approver__c, Regional_ESBP__c, Global_ESBP__c, CurrencyIsoCode, Corporate_Currency_Multiplier__c from ts2__Offer__c where Id = :offer2.Id];
        System.assertEquals(offerCheck.CurrencyIsoCode, 'USD', 'Checking if Currency Code is correct');
        System.assertEquals(offerCheck.Corporate_Currency_Multiplier__c, 1, 'Checking if Corporate Currency Multiplier is correct (UDS)');
		*/
		
		//Country_of_Employment__c was set to Japan for newJob2. So offer2 to should have the currency JPY
        offerCheck = [select id, Regional_FBP_Approver__c, Regional_ESBP__c,CurrencyIsoCode, Corporate_Currency_Multiplier__c,Location__c from ts2__Offer__c where Id = :offer2.Id];
        System.assertEquals('JPY', offerCheck.CurrencyIsoCode, 'Checking if Currency Code is correct');
        System.assertNotEquals(1, offerCheck.Corporate_Currency_Multiplier__c, 'Checking if Corporate Currency Multiplier is correct (UDS)');

		//Location of the offer must be the location of the req
        System.assertEquals('Osaka, Japan - å¤§é˜ª, æ—¥æœ¬', offerCheck.Location__c, 'Checking for Offer Location ');
        
        Test.stopTest();
        
    }
    
    static testmethod void offerInsertTest2() {
    	User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
    	User manager =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name,Manager__c From User u where u.Profile.Name='Manager' and u.IsActive=true and u.manager__c != null limit 1];
        TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_899',ECOMM_Level_5__c='Field Sales Quota',ECOMM_Level_4__c='Sales Mgmt',ECOMM_Level_3__c='Non-AE',ECOMM_Level_2__c='Non-AE',ECOMM_Level_1__c='George Hu');
        insert dept;
        System.debug('Manager---------->'+ manager.manager__c);
        Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States899', 
            Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name,FBP_Offer_Approver__c=u.Name);
        insert newLookup;    
        Job_Profile__c jobProfile = new Job_Profile__c();
        jobProfile.Name ='Test profile';
        jobProfile.Job_Grade__c='12';
        jobProfile.Job_Code__c='TST121';
        insert jobProfile;
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
		candidate.ts2__text_resume__c ='This is test resume note.';
		insert candidate;   
		 ts2__Job__c newJob = new ts2__Job__c();
        newJob.ts2__Recruiter__c = u.Id;
        newJob.ts2__Manager__c = manager.Id;
        newJob.ts2__Employment_Type__c = 'Full Time';
        newJob.Region__c = 'AMER';
        newJob.HireType__c = 'Experienced';
        newJob.Grade_Level__c = '12';
        newJob.Exempt_or_Non_Exempt__c = 'Exempt';
        newJob.Department_Name__c = dept.Id;
        newJob.Country_of_Employment__c = 'United States';
        newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
        newJob.New_or_Replacement__c = 'Replacement';
        newJob.Reason_Replaced__c = 'Termination';
        newJob.ts2__Localized_Job_Title__c = 'test job';
        newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
        newJob.Name = 'test job';
        newJob.Job_Profile__c = jobProfile.Id;
        insert newJob;
        
        ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id,ts2__candidate__c=candidate.Id);
        insert offer1;
        ts2__Offer__c offerCheck = [select id, Regional_FBP_Approver__c, Regional_ESBP__c,  CurrencyIsoCode, Corporate_Currency_Multiplier__c,Location__c,resume__c,Highest_Level_ECOMM__c,ES_SVP__c from ts2__Offer__c where Id = :offer1.Id];
        System.assert(offerCheck.resume__c != null);
        System.assertEquals(offerCheck.Regional_FBP_Approver__c, u.id, 'Checking if FBP approver assignment was correct');
        System.assertEquals(offerCheck.Regional_ESBP__c, u.id, 'Checking if Regional ESBP approver assignment was correct');
        System.assert(offerCheck.ES_SVP__c != null);
    }
    
    static testmethod void offerInsertTest3() {
    	User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
    	
    	System.runAs(u) {
    		Profile p = [select id from profile where name='Manager'];
            User evpUser = new User(alias = 'standt', email='standarduser5@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser5@testorg.com', FirstName = 'John', Title='EVP,Executive Vice President');
            insert evpUser;
            User vpUser = new User(alias = 'standt1', email='standarduser6@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser6@testorg.com', FirstName = 'John1', Title='VP,Vice President',Manager__c=evpUser.Id);
            insert vpUser;
            
            User secondLevelManager = new User(alias = 'standt2', email='standarduser7@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser7@testorg.com', FirstName = 'John2', Title='Second Level manager',Manager__c=vpUser.Id);
            insert secondLevelManager;
            
            User hiringManager = new User(alias = 'standt3', email='standarduser8@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing3', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser8@testorg.com', FirstName = 'John2', Title='Second Level manager',Manager__c=secondLevelManager.Id);
            insert hiringManager;
            
            TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_899',ECOMM_Level_5__c='Field Sales Quota',ECOMM_Level_4__c='Sales Mgmt',ECOMM_Level_3__c='Non-AE',ECOMM_Level_2__c='Non-AE',ECOMM_Level_1__c='George Hu');
	        insert dept;
	        
	        Job_Profile__c jobProfile = new Job_Profile__c();
	        jobProfile.Name ='Test profile';
	        jobProfile.Job_Grade__c='12';
	        jobProfile.Job_Code__c='TST121';
	        insert jobProfile;
	        Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States899', 
	            Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name,FBP_Offer_Approver__c=u.Name);
	        insert newLookup;    
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
			candidate.ts2__text_resume__c ='This is test resume note.';
			insert candidate;   
			 ts2__Job__c newJob = new ts2__Job__c();
	        newJob.ts2__Recruiter__c = u.Id;
	        newJob.ts2__Manager__c = hiringManager.Id;
	        newJob.ts2__Employment_Type__c = 'Full Time';
	        newJob.Region__c = 'AMER';
	        newJob.HireType__c = 'Experienced';
	        newJob.Grade_Level__c = '12';
	        newJob.Exempt_or_Non_Exempt__c = 'Exempt';
	        newJob.Department_Name__c = dept.Id;
	        newJob.Country_of_Employment__c = 'United States';
	        newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
	        newJob.New_or_Replacement__c = 'Replacement';
	        newJob.Reason_Replaced__c = 'Termination';
	        newJob.ts2__Localized_Job_Title__c = 'test job';
	        newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
	        newJob.Name = 'test job';
	        newJob.Job_Profile__c = jobProfile.Id;
	        insert newJob;
	        ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id,ts2__candidate__c=candidate.Id);
	        insert offer1;
	        ts2__Offer__c offerCheck = [select id, Regional_FBP_Approver__c,Highest_Level_VP__c,Highest_Level_SVP_EVP__c, Regional_ESBP__c, CurrencyIsoCode, Corporate_Currency_Multiplier__c,Location__c,resume__c,Highest_Level_ECOMM__c,ES_SVP__c from ts2__Offer__c where Id = :offer1.Id];
	        System.assert(offerCheck.resume__c != null);
	        System.assertEquals(offerCheck.Regional_FBP_Approver__c, u.id, 'Checking if FBP approver assignment was correct');
	        System.assertEquals(offerCheck.Regional_ESBP__c, u.id, 'Checking if Regional ESBP approver assignment was correct');
	       // System.assertEquals(offerCheck.Global_ESBP__c, u.id, 'Checking if Global ESBP approver assignment was correct');
	        //System.assert(offerCheck.Highest_Level_ECOMM__c != null);
	        System.assert(offerCheck.ES_SVP__c != null);
	        System.assert(offerCheck.Highest_Level_VP__c != null);
	        System.assert(offerCheck.Highest_Level_SVP_EVP__c != null);
	        System.assert(offerCheck.Highest_Level_VP__c == vpUser.ID);
	        System.assert(offerCheck.Highest_Level_SVP_EVP__c == evpUser.Id);
    	}
    }
    
    static testmethod void offerInsertTest4() {
    	User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
    	
    	System.runAs(u) {
    		Profile p = [select id from profile where name='Manager'];
            User evpUser = new User(alias = 'standt', email='standarduser5@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser5@testorg.com', FirstName = 'John', Title='EVP,Executive Vice President');
            insert evpUser;
            User vpUser = new User(alias = 'standt1', email='standarduser6@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser6@testorg.com', FirstName = 'John1', Title='VP,Vice President',Manager__c=evpUser.Id);
            insert vpUser;
            
             User sdUser = new User(alias = 'standt9', email='standarduser9@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing9', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser9@testorg.com', FirstName = 'John9', Title='Senior Director,SD',Manager__c=vpUser.Id);
            insert sdUser;
            
            User secondLevelManager = new User(alias = 'standt2', email='standarduser7@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser7@testorg.com', FirstName = 'John2', Title='Second Level manager',Manager__c=sdUser.Id);
            insert secondLevelManager;
            
            User hiringManager = new User(alias = 'standt3', email='standarduser8@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing3', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser8@testorg.com', FirstName = 'John2', Title='Second Level manager',Manager__c=secondLevelManager.Id);
            insert hiringManager;
            
            TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_899',ECOMM_Level_5__c='Field Sales Quota',ECOMM_Level_4__c='Sales Mgmt',ECOMM_Level_3__c='Non-AE',ECOMM_Level_2__c='Non-AE',ECOMM_Level_1__c='George Hu');
	        insert dept;
	        
	        Job_Profile__c jobProfile = new Job_Profile__c();
	        jobProfile.Name ='Test profile';
	        jobProfile.Job_Grade__c='12';
	        jobProfile.Job_Code__c='TST121';
	        insert jobProfile;
	        
	        Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States899', 
	            Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name,FBP_Offer_Approver__c=u.Name);
	        insert newLookup;    
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
			candidate.ts2__text_resume__c ='This is test resume note.';
			insert candidate;   
			 ts2__Job__c newJob = new ts2__Job__c();
	        newJob.ts2__Recruiter__c = u.Id;
	        newJob.ts2__Manager__c = hiringManager.Id;
	        newJob.ts2__Employment_Type__c = 'Full Time';
	        newJob.Region__c = 'AMER';
	        newJob.HireType__c = 'Experienced';
	        newJob.Grade_Level__c = '12';
	        newJob.Exempt_or_Non_Exempt__c = 'Exempt';
	        newJob.Department_Name__c = dept.Id;
	        newJob.Country_of_Employment__c = 'United States';
	        newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
	        newJob.New_or_Replacement__c = 'Replacement';
	        newJob.Reason_Replaced__c = 'Termination';
	        newJob.ts2__Localized_Job_Title__c = 'test job';
	        newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
	        newJob.Name = 'test job';
	         newJob.Job_Profile__c = jobProfile.Id;
	        insert newJob;
	        ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id,ts2__candidate__c=candidate.Id);
	        insert offer1;
	        ts2__Offer__c offerCheck = [select id, Regional_FBP_Approver__c,Highest_Level_VP__c,Highest_Level_SVP_EVP__c, Regional_ESBP__c, CurrencyIsoCode, Corporate_Currency_Multiplier__c,Location__c,resume__c,Highest_Level_ECOMM__c,ES_SVP__c from ts2__Offer__c where Id = :offer1.Id];
	        System.assert(offerCheck.resume__c != null);
	        System.assertEquals(offerCheck.Regional_FBP_Approver__c, u.id, 'Checking if FBP approver assignment was correct');
	        System.assertEquals(offerCheck.Regional_ESBP__c, u.id, 'Checking if Regional ESBP approver assignment was correct');
	        //System.assertEquals(offerCheck.Global_ESBP__c, u.id, 'Checking if Global ESBP approver assignment was correct');
	        //System.assert(offerCheck.Highest_Level_ECOMM__c != null);
	        System.assert(offerCheck.ES_SVP__c != null);
	        System.assert(offerCheck.Highest_Level_VP__c != null);
	        System.assert(offerCheck.Highest_Level_SVP_EVP__c != null);
	        System.assert(offerCheck.Highest_Level_VP__c == vpUser.ID);
	        System.assert(offerCheck.Highest_Level_SVP_EVP__c == evpUser.Id);
    	}
    }
    
    static testmethod void offerInsertTest5() {
    	User u =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email, u.Name From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
    	
    	System.runAs(u) {
    		Profile p = [select id from profile where name='Manager'];
            User evpUser = new User(alias = 'standt', email='standarduser5@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser5@testorg.com', FirstName = 'John', Title='EVP,Executive Vice President');
            insert evpUser;
            User vpUser = new User(alias = 'standt1', email='standarduser6@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing1', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser6@testorg.com', FirstName = 'John1', Title='VP,Vice President',Manager__c=evpUser.Id);
            insert vpUser;
            
             User sdUser = new User(alias = 'standt9', email='standarduser9@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing9', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser9@testorg.com', FirstName = 'John9', Title='Senior Director,SD',Manager__c=vpUser.Id);
            insert sdUser;
            
            User secondLevelManager = new User(alias = 'standt2', email='standarduser7@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing2', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser7@testorg.com', FirstName = 'John2', Title='Second Level manager',Manager__c=sdUser.Id);
            insert secondLevelManager;
            
            User hiringManager = new User(alias = 'standt3', email='standarduser8@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing3', languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='standarduser8@testorg.com', FirstName = 'John2', Title='Second Level manager',Manager__c=secondLevelManager.Id);
            insert hiringManager;
            
            TF2_Department__c dept = new TF2_Department__c(Name = '001 Test Department', Department_Number__c = 'D_899',ECOMM_Level_5__c='Field Sales Quota',ECOMM_Level_4__c='Sales Mgmt',ECOMM_Level_3__c='Non-AE',ECOMM_Level_2__c='Non-AE',ECOMM_Level_1__c='George Hu');
	        insert dept;
	        
	        Job_Profile__c jobProfile = new Job_Profile__c();
	        jobProfile.Name ='Test profile';
	        jobProfile.Job_Grade__c='0';
	        jobProfile.Job_Code__c='TST121';
	        insert jobProfile;
	        
	        Regional_FBP_Lookup__c newLookup = new Regional_FBP_Lookup__c(Matrix_ID__c = 'United States899', 
	            Approver_Name__c = u.Name, Regional_ESBP__c = u.Name, Global_ESBP__c = u.Name,FBP_Offer_Approver__c=u.Name);
	        insert newLookup;    
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
			candidate.ts2__text_resume__c ='This is test resume note.';
			insert candidate;   
			 ts2__Job__c newJob = new ts2__Job__c();
	        newJob.ts2__Recruiter__c = u.Id;
	        newJob.ts2__Manager__c = hiringManager.Id;
	        newJob.ts2__Employment_Type__c = 'Full Time';
	        newJob.Region__c = 'AMER';
	        newJob.HireType__c = 'Experienced';
	        newJob.Grade_Level__c = '0';
	        newJob.Exempt_or_Non_Exempt__c = 'Exempt';
	        newJob.Department_Name__c = dept.Id;
	        newJob.Country_of_Employment__c = 'United States';
	        newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
	        newJob.New_or_Replacement__c = 'Replacement';
	        newJob.Reason_Replaced__c = 'Termination';
	        newJob.ts2__Localized_Job_Title__c = 'test job';
	        newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
	        newJob.Name = 'test job';
	         newJob.Job_Profile__c = jobProfile.Id;
	        insert newJob;
	        ts2__Offer__c offer1 = new ts2__Offer__c(ts2__Job__c = newJob.Id,ts2__candidate__c=candidate.Id);
	        
	        offer1.ts2__Salary__c=1000.00;
	        offer1.Agency_Fee__c=100.00;
	        offer1.ts2__Bonus__c=1000.00;
	        offer1.ts2__Hourly__c = 10;
	        offer1.ImmigrationCost__c=100;
	        offer1.Relocation_Package_Cost__c=100;
	        offer1.Sign_on_Bonus__c=5000;
	        offer1.Target_Variable_Amount__c=100;
	        offer1.Stock_Options_Value__c=100;
	        offer1.RSUs_Value__c=100;
	        insert offer1;
	        ts2__Offer__c offerCheck = [select id, Regional_FBP_Approver__c,Highest_Level_VP__c,Highest_Level_SVP_EVP__c, Regional_ESBP__c, CurrencyIsoCode, Corporate_Currency_Multiplier__c,Location__c,resume__c,Highest_Level_ECOMM__c,ES_SVP__c from ts2__Offer__c where Id = :offer1.Id];
	        System.assert(offerCheck.resume__c != null);
	        System.assertEquals(offerCheck.Regional_FBP_Approver__c, u.id, 'Checking if FBP approver assignment was correct');
	        System.assertEquals(offerCheck.Regional_ESBP__c, u.id, 'Checking if Regional ESBP approver assignment was correct');
    	}
    }

}