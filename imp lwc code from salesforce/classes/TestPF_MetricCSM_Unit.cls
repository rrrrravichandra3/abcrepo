@isTest
private class TestPF_MetricCSM_Unit {
 	  
 	/*   public static testMethod void execute_methods_ScorecardMetricCSM(){
 	   		GenerateEnvironmentTest5.genPerformanceCSM();
 	   		Test.startTest();
 	   		
 	   		test_ScorecardMetricCSMAllUsers(GenerateEnvironmentTest5.PRIndividualQ1Q2CSM);
 	   		System.assert(GenerateEnvironmentTest5.PRIndividualQ1Q2CSM != null);
 	   		Test.stopTest();
 	   }
 	   
	
	  public static void test_ScorecardMetricCSMUser(PerformanceReview__c performanceReviewCSM, Id user) {
	    /*
	    ScorecardSupportComment__c comm = GenerateEnvironmentTest3.createScorecardSupportReviewComment(performanceReviewCSM.Id, performanceReviewCSM.Manager__c, 'Comment', 'Comment', 'Comment', 'Comment', 'Comment', 'Comment', 'Comment', 'Comment', 'Comment', 'Comment');
	    ScorecardMetricCSM controller;
	  
	    try {
	    	
		    System.currentPageReference().getParameters().put('id', performanceReviewCSM.Id);
			System.assertEquals(System.currentPageReference().getParameters().get('id'), performanceReviewCSM.Id);
		  	//controller = new ScorecardMetricCSM();
		  	controller = new ScorecardMetricCSM(user);
		  	
		  	controller.setUserId(user);
		  	controller.UserId();	  	
		  	controller.getv2momType();
		  	controller.getScorecardSupportReview();
		  	controller.setTableType('Test');
		  	controller.getIsQ1Q2();
		  	controller.getIsQ3Q4();
		  	controller.getProjectReviews();
		  	controller.getProjectReview();
		  	controller.saveProjectsReview();
		  	controller.deleteProjectReview();
		  	controller.getTableType();
		  	System.assertEquals(controller.getTableType(), 'Test');
		  	
		  	controller.getIsQ1Q2Only();
		  	controller.getIsQ3Q4Only();
		  	controller.getIsOldCSM();
		  	
		  	controller.saveProjectsReviewWithHideLoading();
			controller.updateProjectReview();
			controller.getIsMngr2ndMngrOrEmplInAssmnt();
			controller.getIsEmployeeInAssmnt();
			controller.getIsEmplInAssmntOnly();
			controller.getIsEmplMngr2ndMngrOr3PtInAssmnt();
			controller.getIsEmplMngr2ndMngr();
			
			
		  	controller.getScorecard();
		  	controller.getCurrentUserId();
		  	controller.getCurrentUserComment();
		  	controller.getUserProfile();
		  	controller.getperformanceR();
		  	
		  	controller.getLabelPreviousMetric();
		  	controller.getLabelNextMetric();
		  	controller.getLabelMetricAvail();
		  	controller.getLabelMetricComment();
		  	controller.getHistoryCommentOperationalExcellence();
		  	controller.getHistoryCommentStrategicInitiatives();
		  	controller.getHistoryCommentCSMSalesImpact(); 
		  	controller.getHasCommentOperationalExcellence();
		  	controller.getHasCommentStrategicInitiatives();
		   	controller.getIsSysAdminProfile();
		  	controller.getIsMngr();
		  	controller.getIsMngrInAssmnt();
		  	controller.getIs3PtInAssmnt();
		  	controller.getIsMngr2ndMngrOr3PtInAssmnt();
	
		  	controller.getScorecardCommentWithoutSharing(performanceReviewCSM);
		  	controller.getRatingSelectOptions();
		  	
		  	//hisComm.getComment();
		  	//hisComm.getCreatedDate();
		  	
        }catch(Exception e){
            System.debug(' ****************** test_ScorecardMetricCSMUser * ');
            System.debug(e.getMessage()); 
        } 
	  	
	  	
	  	try{
		  	List<ScorecardMetricCSM.HistoryComments> hcs = controller.getHistoryCommentRenewalExcellence();
		  	ScorecardMetricCSM.HistoryComments hc;
	  	
		 
		  	hc.getComment();
		  	hc.setComment(hc.getComment());
		  	hc.getCreatedDate();
		  	hc.setCreatedDate('');

		  	hcs = controller.getHistoryCommentCSMSalesImpact();
		 
		  	hc.getComment();
		  	hc.setComment(hc.getComment());
		  	hc.getCreatedDate();
		  	hc.setCreatedDate('');

		  
	  	}catch(Exception e){
	  		System.debug(' NULL comment history ');
	  	}

		try {
			
		  	controller.getHasCommentRenewalExcellence();
		  	controller.getHasCommentCSMSalesImpact();
		  	
	
		  	
		  	List<ScorecardSupportReview__c> scorecardReview = new List<ScorecardSupportReview__c>();
		  	
			ScorecardMetricCSM.ScoreCardReviewSupport scorecardReviewSupport = new ScorecardMetricCSM.ScoreCardReviewSupport(scorecardReview, performanceReviewCSM, controller.getCurrentUserComment());
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
			scorecardReviewSupport = new ScorecardMetricCSM.ScoreCardReviewSupport(scorecardReview, performanceReviewCSM, controller.getCurrentUserComment(), true);
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
			scorecardReviewSupport = new ScorecardMetricCSM.ScoreCardReviewSupport(scorecardReview, performanceReviewCSM, controller.getCurrentUserComment(), false);
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
	
		  	if (GenerateEnvironmentTest5.sQ1CSM != null)
		  		scorecardReview.add(GenerateEnvironmentTest5.sQ1CSM);
		  	if (GenerateEnvironmentTest5.sQ2CSM != null)
		  		scorecardReview.add(GenerateEnvironmentTest5.sQ2CSM);
		  	if (GenerateEnvironmentTest5.sQ3CSM != null)
		  		scorecardReview.add(GenerateEnvironmentTest5.sQ3CSM);
		  	if (GenerateEnvironmentTest5.sQ4CSM != null)
		  		scorecardReview.add(GenerateEnvironmentTest5.sQ4CSM);
	
		  	
			scorecardReviewSupport = new ScorecardMetricCSM.ScoreCardReviewSupport(scorecardReview, performanceReviewCSM, controller.getCurrentUserComment());
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
			scorecardReviewSupport = new ScorecardMetricCSM.ScoreCardReviewSupport(scorecardReview, performanceReviewCSM, controller.getCurrentUserComment(), true);
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
	
			scorecardReviewSupport = new ScorecardMetricCSM.ScoreCardReviewSupport(scorecardReview, performanceReviewCSM, controller.getCurrentUserComment(), false);
		  	test_ScoreCardReviewSupport(scorecardReviewSupport, user);
		  	
       }catch(Exception e){
            System.debug(' ****************** test_ScorecardMetricEducationUser * ');
            System.debug(e.getMessage());
        }
        */
/*	  }
 
	  public static void test_ScoreCardReviewSupport(ScorecardMetricCSM.ScoreCardReviewSupport scorecardReviewSupport, Id user) {
	  	
	  	scorecardReviewSupport.getScorecardSupportReview();
	  	
	  	scorecardReviewSupport.setUserId(user);
	  	System.assertEquals(scorecardReviewSupport.getUserId(), user);
	  	scorecardReviewSupport.getUserId();
	  	scorecardReviewSupport.getId();
	  	scorecardReviewSupport.getScorecardSupportReview();
	  	
	  	scorecardReviewSupport.getQuarter('Q1');
	  	scorecardReviewSupport.getQuarter('Q2');
	  	scorecardReviewSupport.getQuarter('Q3');
	  	scorecardReviewSupport.getQuarter('Q4');
	  	
	  	scorecardReviewSupport.getRenewalExcellenceActualQ1();
	  	scorecardReviewSupport.getRenewalExcellenceActualQ2();
	  	scorecardReviewSupport.getRenewalExcellenceActualQ3();
	  	scorecardReviewSupport.getRenewalExcellenceActualQ4();
	  	
	  	scorecardReviewSupport.getRenewalExcellenceTargetQ1();
	  	scorecardReviewSupport.getRenewalExcellenceTargetQ2();
	  	scorecardReviewSupport.getRenewalExcellenceTargetQ3();
	  	scorecardReviewSupport.getRenewalExcellenceTargetQ4();
	  	
	  	scorecardReviewSupport.getRenewalExcellenceAttainmentQ1();
	  	scorecardReviewSupport.getRenewalExcellenceAttainmentQ2();
	  	scorecardReviewSupport.getRenewalExcellenceAttainmentQ3();
	  	scorecardReviewSupport.getRenewalExcellenceAttainmentQ4();
	  	
	  	scorecardReviewSupport.getYTDActual();
	  	scorecardReviewSupport.getYTDTarget();
	  	scorecardReviewSupport.getYTDAttainment();
	  	scorecardReviewSupport.getCommentCSMSalesImpact();
	  	scorecardReviewSupport.getCommentRenewalExcellence();
	  	
	  	
		scorecardReviewSupport.getRenewalExcellenceRating();
		scorecardReviewSupport.getRenewalExcellenceWeight();
		//scorecardReviewSupport.getCSMSalesImpactActual();
		scorecardReviewSupport.getCSMSIPipeLineContributionActual();
		scorecardReviewSupport.getCSMSIPipeLineContributionTraningActual();
		scorecardReviewSupport.getCSMSIPipeLineContributionConsultingActual();
				
		scorecardReviewSupport.getACVGrowthActualQ1();
		scorecardReviewSupport.getACVGrowthActualQ2();
		scorecardReviewSupport.getACVGrowthActualQ3();
		scorecardReviewSupport.getACVGrowthActualQ4();
		scorecardReviewSupport.getACVGrowthTargetQ1();
		scorecardReviewSupport.getACVGrowthTargetQ2();
		scorecardReviewSupport.getACVGrowthTargetQ3();
		scorecardReviewSupport.getACVGrowthTargetQ4();
		scorecardReviewSupport.getYTDACVGrowthActual();
		scorecardReviewSupport.getYTDACVGrowthTarget();
		scorecardReviewSupport.getACVGrowthAttainmentQ1();
		scorecardReviewSupport.getACVGrowthAttainmentQ2();
		scorecardReviewSupport.getACVGrowthAttainmentQ3();
		scorecardReviewSupport.getACVGrowthAttainmentQ4();
		scorecardReviewSupport.getYTDACVGrowthAttainment();
		scorecardReviewSupport.getPipelineContributionActualQ1();
		scorecardReviewSupport.getPipelineContributionActualQ2();
		scorecardReviewSupport.getPipelineContributionActualQ3();
		scorecardReviewSupport.getPipelineContributionActualQ4();
		scorecardReviewSupport.getPipelineContributionTargetQ1();
		scorecardReviewSupport.getPipelineContributionTargetQ2();
		scorecardReviewSupport.getPipelineContributionTargetQ3();
		scorecardReviewSupport.getPipelineContributionTargetQ4();
		
		scorecardReviewSupport.getYTDPipelineContributionActual();
		scorecardReviewSupport.getYTDPipelineContributionTarget();
		scorecardReviewSupport.getPipelineContributionAttainmentQ1();
		scorecardReviewSupport.getPipelineContributionAttainmentQ2();
		scorecardReviewSupport.getPipelineContributionAttainmentQ3();
		scorecardReviewSupport.getPipelineContributionAttainmentQ4();
		//scorecardReviewSupport.getYTDPipelineContributionAttainment();
		
		scorecardReviewSupport.getCSMSalesImpactRating();
		scorecardReviewSupport.getCSMSalesImpactWeight();
			
	  	scorecardReviewSupport.getOperationalExcellenceActualQ1();
	  	scorecardReviewSupport.getOperationalExcellenceActualQ2();
	  	scorecardReviewSupport.getOperationalExcellenceActualQ3();
	  	scorecardReviewSupport.getOperationalExcellenceActualQ4();
	  	scorecardReviewSupport.getOperationalExcellenceTargetQ1();
	  	scorecardReviewSupport.getOperationalExcellenceTargetQ2();
	  	scorecardReviewSupport.getOperationalExcellenceTargetQ3();
	  	scorecardReviewSupport.getOperationalExcellenceTargetQ4();
	  	scorecardReviewSupport.getOperationalExcellenceAttainmentQ1();
	  	scorecardReviewSupport.getOperationalExcellenceAttainmentQ2();
	  	scorecardReviewSupport.getOperationalExcellenceAttainmentQ3();
	  	scorecardReviewSupport.getOperationalExcellenceAttainmentQ4();
	  	scorecardReviewSupport.getCommentOperationalExcellence();
	  	scorecardReviewSupport.getOperationalExcellenceRating();
	  	scorecardReviewSupport.getOperationalExcellenceWeight();
	  	scorecardReviewSupport.getCommentStrategicInitiatives();
	  	scorecardReviewSupport.getStrategicInitiativesRating();
	  	scorecardReviewSupport.getStrategicInitiativesWeight();
	  	scorecardReviewSupport.getCSMSICSEAmountActual();
	  	
	  	scorecardReviewSupport.getExecutiveRelationshipsActualQ1();
	  	scorecardReviewSupport.getExecutiveRelationshipsActualQ2();
	  	scorecardReviewSupport.getExecutiveRelationshipsActualQ3();
	  	scorecardReviewSupport.getExecutiveRelationshipsActualQ4();
	  	scorecardReviewSupport.getExecutiveRelationshipsTargetQ1();
	  	scorecardReviewSupport.getExecutiveRelationshipsTargetQ2();
	  	scorecardReviewSupport.getExecutiveRelationshipsTargetQ3();
	  	scorecardReviewSupport.getExecutiveRelationshipsTargetQ4();
	  	scorecardReviewSupport.getExecutiveRelationshipsAttainmentQ1();
	  	scorecardReviewSupport.getExecutiveRelationshipsAttainmentQ2();
	  	scorecardReviewSupport.getExecutiveRelationshipsAttainmentQ3();
	  	scorecardReviewSupport.getExecutiveRelationshipsAttainmentQ4();
	
	  	scorecardReviewSupport.getRatingDescription(1);
	  	scorecardReviewSupport.getRatingDescription(2);
	  	scorecardReviewSupport.getRatingDescription(3);
	  	scorecardReviewSupport.getRatingDescription(4);
	  	scorecardReviewSupport.getRatingDescription(5);
	  	
	  
	  }
	  
	  
	  


 
 
    public static void test_ScorecardMetricCSMAllUsers(PerformanceReview__c performanceReviewCSM) {
    	System.assert(performanceReviewCSM != null);
	  	test_ScorecardMetricCSMUser(performanceReviewCSM, performanceReviewCSM.Employee__c);
	  	test_ScorecardMetricCSMUser(performanceReviewCSM, performanceReviewCSM.Manager__c);
	  	test_ScorecardMetricCSMUser(performanceReviewCSM, performanceReviewCSM.secondManager__c);
	  	test_ScorecardMetricCSMUser(performanceReviewCSM, UserInfo.getUserId());
	  }	   

	    
	 */
	 
	  
   

}