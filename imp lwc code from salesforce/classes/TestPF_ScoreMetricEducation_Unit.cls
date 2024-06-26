@isTest
private class TestPF_ScoreMetricEducation_Unit {

    static testMethod void unitTest1() {
        test.startTest();
        	String userId = [Select Id From User][0].Id;
        	
        	PerformanceReview__c p = [SELECT Id, Manager__c, ThirdPartyReviewer__c, PCOMM__c, Name, SecondManager__c, Employee__c, Status__c, PreviousStatus__c, V2MOM__r.V2MOM_Type__c  
                        			  FROM PerformanceReview__c][0];
            ApexPages.currentPage().getParameters().put('Id',p.Id);
            ScorecardMetricEducation scme = new ScorecardMetricEducation(userId);            			  
            scme.getScorecardCommentWithoutSharing(p);
            scme.getCurrentUserComment();
            scme.getCurrentUserId();
            scme.getHistoryCommentForecastAccurancy();
            scme.getHistoryCommentSalesImpact();
            scme.getHistoryCommentTimeOnPlatform();
            scme.getLabelPreviousMetric();
            scme.getHasCommentTimeOnPlatform();
           
            scme.getLabelMetricComment();
            scme.getLabelNextMetric();
            scme.getv2momType();
            
            scme.getHasCommentTimeOnPlatform();           			  
        	
        test.stopTest();
    }
    
    static testMethod void unitTest2(){
    	test.startTest();
    		
    		
    	test.stopTest();
    }
}