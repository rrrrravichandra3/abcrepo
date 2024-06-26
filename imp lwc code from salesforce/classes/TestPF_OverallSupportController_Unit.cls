@isTest
private class TestPF_OverallSupportController_Unit {

    static testMethod void unitTest1() {
        test.startTest();
        	PerformanceReview__c testPerformance =[	Select 	Id, Status__c, CreatedDate, Employee__c, Manager__c,
        	 												SecondManager__c, PCOMM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c, V2MOM__r.V2MOM_Type__c, ThirdPartyReviewer__c  
        	 										From PerformanceReview__c ][0];
        	OverallSupportController aux = new OverallSupportController(testPerformance);
        	
        	aux.checkManagerNewSupportCommentEntryRequirements();
        	aux.checkManagerSupportCommentEntryRequirements();
        	aux.getAvgQ1Q3();
        	aux.getAvgQ1Q3Renewals();
        	aux.getAvgQ1Q3SI();
        	aux.getAvgQ1Q3WMCases();
        	aux.getAvgQ1Q3WMHC();
        	aux.getAvgQ1Q3WMPA();
        	aux.getAvgQ1Q3WMSMES();
        	aux.getAvgQ2Q4();
        	aux.getAvgQ2Q4Renewals();
        	aux.getAvgQ2Q4SI();
        	aux.getAvgQ2Q4WMCases();
        	aux.getAvgQ2Q4WMHC();
        	aux.getAvgQ2Q4WMPA();
        	aux.getAvgQ2Q4WMSMES();
        	aux.getAvgRatingCSAT();
        	aux.getAvgRatingRenewals();
        	aux.getAvgRatingSI();
        	aux.getAvgRatingSupportMetrics();
        	aux.getAvgRatingWMCases();
        	aux.getAvgRatingWMHC();
        	aux.getAvgRatingWMPA();
        	aux.getAvgRatingWMSMES();
        	aux.getCustomerSatisfactionRatingQ1_Q3();
        	aux.getCustomerSatisfactionRatingQ2_Q4();
        	aux.getIsOld();
        	
        	//get current user
        	String id = userInfo.getUserId();
        	
        	User currentUser = [Select Id, Name, Profile.Name From User Where Id = :id];
        	// gets the profile of the employee to see what kind of scorecard it might have
        	User scorecardTypeProfile = [Select u.Profile.Name, u.ProfileId From User u Where id = :testPerformance.Employee__c];   
    		
    		// access class for permissions
            PerformanceAccessUtil accessUtil = new PerformanceAccessUtil(testPerformance, currentUser, scorecardTypeProfile);
            aux.setPerformanceAccessUtil(accessUtil);	
        	
        	aux.getOverallUtil();
        	aux.getRatingCustomerSatisfaction();
        	aux.getRatingWMCAA();
        	aux.getRatingWMCCP();
        	aux.getWeightCustomerSatisfaction();
        	aux.getWeightQ1Q3();
        	aux.getWeightQ1Q3Renewals();
        	aux.getWeightQ1Q3SI();
        	aux.getWeightQ1Q3WMCases();
        	aux.getWeightQ1Q3WMHC();
        	aux.getWeightQ1Q3WMPA();
        	aux.getWeightQ1Q3WMSMES();
        	aux.getWeightQ2Q4();
        	aux.getWeightQ2Q4Renewals();
        	aux.getWeightQ2Q4SI();
        	aux.getWeightQ2Q4WMCases();
        	aux.getWeightQ2Q4WMHC();
        	aux.getWeightQ2Q4WMPA();
        	aux.getWeightQ2Q4WMSMES();
        	aux.getWeightWMCAA();
        	aux.getWeightWMCCP();
        test.stopTest();
    }
    
    static testMethod void unitTest2() {
    	test.startTest();
    		PerformanceReview__c testPerformance =[	Select 	Id, Status__c, CreatedDate, PremierUser__c, Employee__c, Manager__c,
        	 												SecondManager__c, PCOMM__c, PreviousStatus__c, ReviewRating__r.CalculatedRating__c, V2MOM__r.V2MOM_Type__c, ThirdPartyReviewer__c  
        	 										From PerformanceReview__c ][0];
    		OverallSupportController aux = new OverallSupportController(testPerformance, false);
    		aux = new OverallSupportController(testPerformance, true);
    		Double sumMethodWeight = 2;
    		aux.checkManagerNewSupportDataEntryRequirements(sumMethodWeight);
    		ScorecardSupportReview__c s = GenerateEnvironmentTest5.addScorecardSupportReviewWithDataCSM('Test', testPerformance, 'T1', 1, 2, 3, 4, 5, 6, 7, 8, 2, 10, 11, 12, 1, 14, 15, 16, 17, 18, 4, 20, 21, 22, 23, 24, 3, 3);
    		aux.checkManagerNewSupportDataScorecardEntryRequirements(s, sumMethodWeight);
    		aux.checkManagerNewSupportWeightEntryRequirements(s, sumMethodWeight);
    		aux.checkManagerNewSupportCommentEntryRequirements();
    		
    	test.stopTest();
    }
    
    static testMethod void testOverallUtil(){
    	test.startTest();
    		Id id = [Select Id From PerformanceReview__c][0].Id;
    		OverallSupportController.OverallUtil oUtil = new OverallSupportController.OverallUtil();
    		oUtil.checkScorecards();
    		oUtil.checkScorecardsQ1Q2();
    		oUtil.checkScorecardsQ3Q4();
    		oUtil.getScorecardSupportReviewQ1WithSharing();
    		oUtil.getScorecardSupportReviewQ2WithSharing();
    		oUtil.getScorecardSupportReviewQ3WithSharing();
    		oUtil.getScorecardSupportReviewQ4WithSharing();
    		oUtil.getScorecardSupportReviewQXWithSharing(id);
    	test.stopTest();
    }
}