@isTest
private class TestPF_PerformanceReviewYearEnd_Unit {
	static testmethod void performanceReviewYearEndController(){

		GenerateEnvironmentTest1.genPerformanceReviewYearEnd2();
		String yearEndId = GenerateEnvironmentTest1.PRYearEnd.Id;
		
		System.currentPageReference().getParameters().put('id', yearEndId);
		
		Test.startTest(); 
		
			PerformanceReviewYearEnd testYearEnd = new PerformanceReviewYearEnd();
		
			Id currentUserId = userInfo.getUserId();
			Pagereference pageRef = testYearEnd.setMethodsReviews();
			
			System.assert(testYearEnd.methods != null);
			
			System.assertEquals(yearEndId, testYearEnd.getCurrentReview().Id);
			
			testYearEnd.setNextStatus(testYearEnd.getCurrentReview(), 'Employee Self Assessment');
			System.assertEquals(testYearEnd.getCurrentReview().Status__c, 'Employee Self Assessment');
			
				
		Test.stopTest();
	}
}