@isTest
private class TestPF_ReviewRatingSharingManager_Unit {
  
	public static testMethod void execute_ReviewRatingSharingManager() {     
		GenerateEnvironmentTest8.genPerformanceReviewTriggers();
		Test.startTest();
		 
		try {
			PerformanceReview__c pr = GenerateEnvironmentTest8.PRAdHoc;
			ReviewRating__c rr = new ReviewRating__c(	PerformanceReview__c = pr.Id,
														Reviewer__c = pr.Employee__c,
		 												OverallRating__c = 2.0, 
														CalculatedRating__c = 3.0,
														Locked__c = false);
			insert rr;
			
			rr.Locked__c = true;
			update rr;
		} catch (Exception e) {
            System.debug(' ****************** execute_ReviewRatingSharingManager * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();		                  
	}
}