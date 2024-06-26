@isTest
private class TestPF_PerformanceReviewHistory_Unit {

    static testMethod void testController() {
        test.startTest();
        	PerformanceReviewHistoryController prhController = new PerformanceReviewHistoryController();
        	prhController.perfId = userInfo.getUserId(); 
        	PerformanceReview__History perf = [Select CreatedDate, Field, OldValue, NewValue From PerformanceReview__History][0];
       
        	PerformanceReviewHistoryController.PerformanceReviewHistoryDate prhDate = new PerformanceReviewHistoryController.PerformanceReviewHistoryDate(perf); 
        	prhDate.getPerformanceReviewHistory();
        	prhDate.getCreatedDate();
        	prhDate.getStatus();
        test.stopTest();
    }
}