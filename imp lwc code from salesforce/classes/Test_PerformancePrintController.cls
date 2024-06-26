@isTest
private class Test_PerformancePrintController {
	  
	public static testMethod void execute_methods_PrintController() {
		
 		GenerateEnvironmentTest2.genPerformanceReviewFlow();
		
		Test.startTest(); 
		   
		 	try
		 	 {
			 	System.debug('IsNull ' + GenerateEnvironmentTest2.PRDepartment );
			
				System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest2.PRDepartment.Id);
				PerformanceReviewPrint print = new PerformanceReviewPrint();
				
				List<PerformanceMethodController> innerMethods = print.getMethods();
				List<Method__c> methods = new List<Method__c>();
				List<MethodReview__c> methodReviews = new List<MethodReview__c>();
				Method__c method = new Method__c();
				List<AdditionalComment__c> summaryComments = new List<AdditionalComment__c>();
				List<ScorecardSupportComment__c> scorecardComments = new List<ScorecardSupportComment__c>();
		
		        PerformanceCompetencyController competency;
		        List<PerformanceCompetencyController> comps; 
		 	 
				
				print.getIsScorecardProfile();
				print.getIsPremierUser();
				print.getIsOldPerformanceReview();
				print.getCommentsHistory();
				print.getPerformanceReview();
				print.getAllMethodWeightSum();
				print.getAvgRatingMethods();
				print.getMethodAndMetricWeight();
				print.getMethodAndMetricWeightShow();
				print.getMetricWeight();
				print.getCompetencyWeight();
				print.getCompetencyWeightShow();
				print.getMethodCalculatedRating();
				print.getMethodCalculatedRatingWithinMethods();
				print.getMetricCalculatedRatingWithinMetrics();
				print.getMethodsAndMetricsCalculatedRating();
				print.getCompetencyCalculatedRating();
				print.getCompetencyCalculatedRatingWithinCompetencies();
				print.getOverallCalculatedRating();
				print.getShowSupportScorecard();
				print.getIsEducationProfile();
				print.getIsEducationProfile();
				print.getIsSupportProfile();
				print.getIsConsultingProfile();
				print.getIsCSMProfile();
				print.getIsSysAdminProfile();
				print.getScorecardViewProfile();
				print.getHaveProfile();
				print.getIsMngr();
				print.getIsMngrInAssmnt();
				print.getIsEmplMngr2ndMngrOr3PtInAssmnt();
				print.getOverallCalcMethodRatingView();
				print.getOverallCalcMetricRatingView();
				print.getOverallCalcCompRatingView();
				print.getOverallRatingView();
				print.getShowOverallRating();
				print.getDisplayCompetencyCalculatedRating();
				print.getDisplayMethodCalculatedWeight();
				print.getDisplayMethodCalculatedRating();
				print.getDisplayMetricCalculatedWeight();
				print.getDisplayMetricCalculatedRating();
				print.getDisplayOverallCalculatedRating();
				print.getDisplayOverallRating();

				print.getHasCommentCS();
				print.getHasCommentRenewals();
				print.getHasCommentSI();
				print.getHasCommentWMCases();
				print.getHasCommentWMSMES();
				print.getHasCommentWMPA();
				print.getHasCommentWMHC();
				print.getHasCommentWMCCP();
				print.getHasCommentWMCAA();
				print.getHasCommentForecastAccuracy();
				print.getHasCommentSalesImpact();
				print.getHasCommentTimeOnPlatform();
				print.getHasCommentCSMSalesImpact();
				print.getHasCommentRenewalExcellence();
				print.getHasCommentOperationalExcellence();
				print.getHasCommentStrategicInitiatives();
				print.getScorecardComments();
				print.getIsApproved();
				print.getScorecardSupport();
				print.getEmployee();
				print.getManager();
				print.getSecondManager();
				print.getPComm();
				print.getReviewFormTemplate();
				print.getPerformanceReviewPeriodStartDate();
				print.getPerformanceReviewPeriodEndDate();
				print.getNameOwner();
				print.getUserProfile();
				print.getIsQuarterV2MOM();
				print.getCompetencies();
				
		Test.stopTest();
		
		 	 }
		 	 catch (Exception ex)
		 	 {
		 	 	System.debug('\n\n\n\n ******** Error in execute_methods_PrintController ********  \n\n\n');
		 	 }
	}
	
}