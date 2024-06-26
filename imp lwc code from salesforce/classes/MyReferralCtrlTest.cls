@isTest
public with sharing class MyReferralCtrlTest {
    static testmethod void coverCode() {
    	MyReferralsCtrl ctrl = new MyReferralsCtrl();
    	ctrl.doSearch();
    	
    	ctrl.getEmailObject().toAddress = ctrl.currentUser.Email;
    	ctrl.getEmailObject().ccAddress = ctrl.currentUser.Email;
    	ctrl.getEmailObject().subject = 'test subject';
    	ctrl.getEmailObject().body = 'test body';
    	ctrl.sendEmail();
    	
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
        newJob.Name = 'test job';
        List<ts2__Job__c>jList = new List<ts2__Job__c>();
        jList.add(newJob);
        insert jList;
        
        ts2__Referral__c ref = new ts2__Referral__c();
        ref.ts2__p_first_name__c = 'Test';
        ref.ts2__p_last_name__c = 'Last';
        ref.ts2__r_email__c = 'reggie.nair@salesforce.com';
        ref.ts2__job_order_id__c = newJob.Id;
        insert ref;
        
        List<ReferralInfo> referrals  = ctrl.getMyReferrals();
        System.assertNotEquals(0, referrals.size(), 'Here is my referral');
        for(ReferralInfo r : referrals){
        	System.debug('+++'+r.prospectName);
        }
       
        
        ctrl.sendEmail();
        
        ctrl.getHeader();
        ctrl.getFooter();
        ctrl.showPopup();
        
        ctrl.getProxyObject().Start_Date__c = Date.today().addDays(-1);
        ctrl.getProxyObject().End_Date__c = Date.today();
        ctrl.doSearch();
    	Test.stopTest();
    	
    }

}