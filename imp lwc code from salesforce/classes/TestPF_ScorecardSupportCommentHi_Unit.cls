@isTest
private class TestPF_ScorecardSupportCommentHi_Unit {

    static testMethod void Test_ScorecardSupportCommentHistory() {
    	 
    	GenerateEnvironmentTest3.genScorecardSupport();
    	 
         
       ScorecardSupportComment__c sc = new ScorecardSupportComment__c();
       try{
       	sc.ScorecardSupportReview__c = GenerateEnvironmentTest3.sq1Sup.Id;	
       }catch(Exception e){}
       
       
        
       sc.CommentCS__c = 'Test';
       sc.CommentCSMSalesImpact__c = 'Test';
       sc.CommentForecastAccuracy__c = 'Test';
       sc.CommentRenewalExcellence__c = 'Test';
       sc.CommentRenewals__c = 'Test';
       sc.CommentSalesImpact__c = 'Test';
       sc.CommentSupportInitiatives__c = 'Test';
       sc.CommentTimeOnPlatform__c = 'Test';
       sc.CommentWMCases__c = 'Test';
       sc.CommentWMHC__c = 'Test';
       sc.CommentWMPA__c = 'Test';
       sc.CommentWMSMES__c = 'Test';
       sc.Reviewer__c = GenerateEnvironmentTest3.employeeSupport.Id;
       try{
       	insert sc;	
       }catch(Exception e){}
       
       
       sc.CommentCS__c = 'Test change';
       sc.CommentCSMSalesImpact__c = 'Test change';
       sc.CommentForecastAccuracy__c = 'Test change';
       sc.CommentRenewalExcellence__c = 'Test Change';
       sc.CommentRenewals__c = 'Test Change';
       sc.CommentSalesImpact__c = 'Test Change';
       sc.CommentSupportInitiatives__c = 'Test Change';
       sc.CommentTimeOnPlatform__c = 'Test Change';
       sc.CommentWMCases__c = 'Test Change';
       sc.CommentWMHC__c = 'Test Change';
       sc.CommentWMPA__c = 'Test Change';
       sc.CommentWMSMES__c = 'Test Change';
       try{
       	update sc;	
       }catch(Exception e){}
       
    }
}