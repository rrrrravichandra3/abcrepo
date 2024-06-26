@isTest
private class FilteredJobsCtrlTest {
    static testmethod void checkFilteredJobs() {
    	FilteredJobsCtrl ctrl = new FilteredJobsCtrl();
    	ctrl.getJobSite();
    	
    	Test.startTest();
    	
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
        newJob.PostingCategory__c ='sales';
        newJob.Name = 'test job';
        newJob.Job_Code__c='123';
        newJob.ts2__Localized_Job_Description__c='Description Description Description';
        newJob.Confidential__c = false;
        newJob.DoNotShare__c = false;
        newJob.ts2__Post_Job__c = true;
        List<ts2__Job__c>jList = new List<ts2__Job__c>();
        jList.add(newJob);
        insert jList;
        
        ctrl.cancel();
        ctrl.first();
        ctrl.next();
        ctrl.previous();
        ctrl.last();
        
    	System.assertNotEquals(0, ctrl.getJobs().size(), 'Jobs with no parameters');
  	
     	PageReference tokenPage = new PageReference('/FilteredJobs?location=CASF&category=sales');
     	Test.setCurrentPage(tokenPage);
     	//ctrl = new TF2RDController();
		for(JobInfo ji : ctrl.getJobs()){
			System.debug('+++'+ji.name);
		}    	
    	Test.stopTest();
    	
    }
    
    
    static testmethod void checkFilteredJobs1() {
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
        newJob.PostingCategory__c ='sales';
        newJob.Exempt_or_Non_Exempt__c = 'Exempt';
        newJob.Department_Name__c = dept.Id;
        newJob.Country_of_Employment__c = 'United States';
        newJob.TF2_Location__c='San Francisco, CA; Herndon, VA';
        newJob.New_or_Replacement__c = 'Replacement';
        newJob.Reason_Replaced__c = 'Termination';
        newJob.ts2__Localized_Job_Title__c = 'test job';
        newJob.ts2__Estimated_Start_Date__c = Date.Today().addDays(5);
        newJob.Name = 'test job';
        newJob.Job_Code__c='123';
        newJob.ts2__Business_Unit__c = 'radian6';
        newJob.ts2__Localized_Job_Description__c='Description Description Description';
        newJob.Confidential__c = false;
        newJob.DoNotShare__c = false;
        newJob.ts2__Post_Job__c = true;
        List<ts2__Job__c>jList = new List<ts2__Job__c>();
        jList.add(newJob);
        insert jList;
        
        Apexpages.currentPage().getParameters().put('category', 'sales');
		Apexpages.currentPage().getParameters().put('location', 'CASF');
		Apexpages.currentPage().getParameters().put('division', 'radian6');
		Apexpages.currentPage().getParameters().put('country', 'US');
		FilteredJobsCtrl ctrl = new FilteredJobsCtrl();
		ctrl.gridSortField ='Name';
		ctrl.sortOrder ='ASC';
		ctrl.doSort4Grid();
			
		System.assertNotEquals(0, ctrl.getJobs().size(), 'Jobs with no parameters');
    }
}