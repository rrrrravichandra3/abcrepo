@isTest
private class Test_ScorecardReviewSharingManager {
  
	public static testMethod void execute_ScorecardReviewSharingManager() {     
		
		GenerateEnvironmentTest8.genScorecardReviewSharingManager();
		Test.startTest();
		  
		try {
			
			PerformanceReview__c performanceReview = GenerateEnvironmentTest8.PRIndividualQ1Q2;
			ScorecardReview__c sr = new ScorecardReview__c(	Reviewer__c = performanceReview.Manager__c, 
															PerformanceReview__c = performanceReview.Id, 
															OwnerId = performanceReview.Manager__c, 
				 											Comment__c = 'Comment',
															Locked__c = false);
															
			insert sr;
			
			sr.Locked__c = true;
			update sr;
		} catch (Exception e) {
            System.debug(' ****************** execute_ScorecardReviewSharingManager * ');
            System.debug(e.getMessage());
		}
		
		Test.stopTest();				
		
	}
}