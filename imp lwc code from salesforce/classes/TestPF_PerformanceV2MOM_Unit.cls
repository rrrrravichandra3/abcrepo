@isTest
private class TestPF_PerformanceV2MOM_Unit {
        
    

     static testMethod void test_methods_V2MOMAssessmentControllerUser() {     

        PerformanceReview__c pr = [select Id from PerformanceReview__c limit 1];
        User userId = GenerateEnvironmentTestUsers.createEmployeeWithManager();
         
  	    System.currentPageReference().getParameters().put('id', pr.Id);

  	    
        PerformanceV2MOMAssessmentController perfV2MOMController;
	        
	    try {
	        perfV2MOMController = new PerformanceV2MOMAssessmentController(userId.Id);
			                 
 	        perfV2MOMController.getPerformanceReviewWithoutSharing(pr.Id);
 	        
 	      
	        perfV2MOMController.getIsScorecardProfile();
	        perfV2MOMController.getScorecardReview();
	        perfV2MOMController.getShowExpandAllLink();
	        perfV2MOMController.getRatingSelectOptions();
	        perfV2MOMController.getStatusSelectOptions();
	        perfV2MOMController.getUserId();
	        perfV2MOMController.getv2momTypeToShow();
	        perfV2MOMController.getv2momEffectiveDate();
	        perfV2MOMController.getPerformanceReview();
	        perfV2MOMController.getLabelPreviousMethod();
	        perfV2MOMController.getLabelNextMethod();
	        perfV2MOMController.getMethodWeight();
	        perfV2MOMController.getAllMethods();
	        perfV2MOMController.getMethodsAlone();
	        perfV2MOMController.getIsQ1Q2();
	        perfV2MOMController.getQ1ScorecardWeightSum();
	        perfV2MOMController.getQ2ScorecardWeightSum();
	        perfV2MOMController.getQ3ScorecardWeightSum();
	        perfV2MOMController.getQ4ScorecardWeightSum();
	        perfV2MOMController.getIsEmployee();
	        perfV2MOMController.getSumMethodsWeight();
	        perfV2MOMController.getShowSupportScorecard();
	        perfV2MOMController.getShowReviewScorecard();
	        perfV2MOMController.getShowReviewEdit();
	        perfV2MOMController.getIsSysAdminInMngrAssmnt();
	        perfV2MOMController.getIsManager();
	        perfV2MOMController.getIsEmployee();
	        perfV2MOMController.getIsManagerOrSecondManager();
	        perfV2MOMController.getIsManagerOrSecondManager3P();
	        perfV2MOMController.getIsEducationProfile();
	        perfV2MOMController.getIsConsultingProfile();
	        perfV2MOMController.getIsSupportProfile();
	        perfV2MOMController.getIsCSMProfile();
	        perfV2MOMController.getIsSysAdminProfile();
	        perfV2MOMController.getScorecardViewProfile();
	        perfV2MOMController.getIsEmpl();
	        perfV2MOMController.getIsMngr();
	        perfV2MOMController.getIsEmplInAssmnt();
	        perfV2MOMController.getIsMngrInAssmnt();
	        perfV2MOMController.getIs3PtInAssmnt();
	        perfV2MOMController.getIsEmplMngr2ndMngrOr3PtInAssmnt();
	        perfV2MOMController.getIsMngr2ndMngrOr3PtInAssmnt();
	        perfV2MOMController.getIsSaveMode();
	        perfV2MOMController.getIsSaveScorecardMode();
	        perfV2MOMController.a();
	        perfV2MOMController.getIsPremierUser();
	        perfV2MOMController.getShowCustomerSatisfaction();
	        perfV2MOMController.ShowCustomerSatisfaction();
	        perfV2MOMController.getShowNewCustomerSatisfaction();
	        perfV2MOMController.ShowNewCustomerSatisfaction();
	        perfV2MOMController.getIsCompleteNewCS();
	        perfV2MOMController.ShowWMBA();
	        perfV2MOMController.ShowWMCAA();
	        perfV2MOMController.ShowWMCCP();
	        perfV2MOMController.getShowWMBA();
	        perfV2MOMController.getShowWMCAA();
	        perfV2MOMController.getShowWMCCP();
	        perfV2MOMController.getIsCompleteWMCAA();
	        perfV2MOMController.getIsCompleteWMCCP();
	        perfV2MOMController.getCommentWMCAA();
	        perfV2MOMController.getCommentWMCCP();
	        perfV2MOMController.getNotShowCSMTo3rdParty();
	        
	        perfV2MOMController.getShowCSM();
	        perfV2MOMController.getShowCSMSalesImpact();
	        perfV2MOMController.ShowCSM();
	        perfV2MOMController.ShowCsmSalesImpact();
	        perfV2MOMController.getShowCSMSTI();
	        perfV2MOMController.getShowCSMOE();
	        perfV2MOMController.ShowCSMSTI();
	        perfV2MOMController.ShowCSMOE();
	        perfV2MOMController.getCommentRenewalExcellence();
	        perfV2MOMController.getCommentCSMSalesImpact();
	        perfV2MOMController.getIsCompleteRenewalExcellence();
	        perfV2MOMController.getIsCompleteCSMSalesImpact();
	        perfV2MOMController.getIsCompleteOperationalExcellence();
	        perfV2MOMController.getIsCompleteStrategicInitiatives();
	        perfV2MOMController.getCommentOperationalExcellence();
	        perfV2MOMController.getCommentStrategicInitiatives();
	  
	        perfV2MOMController.getShowRenewals();
	        perfV2MOMController.ShowRenewals();
	        
	        perfV2MOMController.getShowSI();
	        perfV2MOMController.ShowSI();
	        
	        perfV2MOMController.getShowWMCases();
	        perfV2MOMController.showWMCases();
	        
	        perfV2MOMController.getShowWMSMES();
	        perfV2MOMController.ShowWMSMES();
	        
	        perfV2MOMController.getShowWMHC();
	        perfV2MOMController.ShowWMHC();
	        
	        perfV2MOMController.getShowWMPA();
	        perfV2MOMController.ShowWMPA();
	        perfV2MOMController.getIsOldPerformanceReview();
	        perfV2MOMController.getIsV2MOMLocked();
	        perfV2MOMController.getCurrentUser();
	        perfV2MOMController.getShowEditCellQ1Q2();
	        perfV2MOMController.getShowEditCellQ3Q4();
	        perfV2MOMController.cannotSave();
	        perfV2MOMController.getShowWMSO();
	        perfV2MOMController.ShowWMSO();
	        perfV2MOMController.getIsEmplInAssmntOnly();
	        perfV2MOMController.getIsEmplMngr2ndMngr();
	        perfV2MOMController.getIsEmplMngr2ndMngr();
	       
	        
	        perfV2MOMController.getShowForecastAccuracy();
	        perfV2MOMController.getShowTimeOnPlatform();
	        perfV2MOMController.getShowSalesImpact();
	        
	        perfV2MOMController.ShowForecastAccuracy();
	        perfV2MOMController.ShowTimeOnPlatform();
	        perfV2MOMController.ShowSalesImpact();
	        
	        perfV2MOMController.getCommentCS();
	        perfV2MOMController.getCommentRenewals();
	        perfV2MOMController.getCommentWMHC();
	        perfV2MOMController.getCommentWMSMES();
	        perfV2MOMController.getCommentWMCases();
	        perfV2MOMController.getCommentWMPA();
	        perfV2MOMController.getCommentSupportInitiatives();
	        perfV2MOMController.getCommentSalesImpact();
	        perfV2MOMController.getCommentTimeOnPlatform();
	        perfV2MOMController.getCommentForecastAccuracy();
	        
	        perfV2MOMController.getIsCompleteCS();
	        perfV2MOMController.getIsCompleteRenewals();
	        perfV2MOMController.getIsCompleteWMHC();
	        perfV2MOMController.getIsCompleteWMSMES();
	        perfV2MOMController.getIsCompleteWMCases();
	        perfV2MOMController.getIsCompleteWMPA();
	        perfV2MOMController.getIsCompleteSupportInitiatives();
	        perfV2MOMController.getIsCompleteSalesImpact();
	        perfV2MOMController.getIsCompleteTimeOnPlatform();
	        perfV2MOMController.getIsCompleteForecastAccuracy();
	        
	        if(perfV2MOMController.getValues() != null && perfV2MOMController.getValues().size() > 0){
	            perfV2MOMController.getValues()[0].getId();
	            perfV2MOMController.getValues()[0].getName();
	            perfV2MOMController.getValues()[0].getFullName();
	            perfV2MOMController.getValues()[0].getMethods();
	            perfV2MOMController.getValues()[0].getMethodCount();
	            perfV2MOMController.getValues()[0].getTextMethod();
	        }
	        
	        if(perfV2MOMController.getMethods() != null && perfV2MOMController.getMethods().size() > 0){
	            perfV2MOMController.getMethods()[0].setMethod(perfV2MOMController.getMethods()[0].getMethod());
	            perfV2MOMController.getMethods()[0].getRatingReview();
	            perfV2MOMController.getMethods()[0].getRating();
	            perfV2MOMController.getMethods()[0].getStatus();
	            perfV2MOMController.getMethods()[0].getShowHistory();
	            perfV2MOMController.getMethods()[0].getWeight();
	            perfV2MOMController.getMethods()[0].getReview();
	            perfV2MOMController.getMethods()[0].getHistory();
	            perfV2MOMController.getMethods()[0].getHistoryFormatted();
	            perfV2MOMController.getMethods()[0].setObstacles(perfV2MOMController.getMethods()[0].getObstacles());
	            perfV2MOMController.getMethods()[0].setMetrics(perfV2MOMController.getMethods()[0].getMetrics());
	            perfV2MOMController.getMethods()[0].getIsComplete();
	            perfV2MOMController.getMethods()[0].getNameEllipsis();
	            perfV2MOMController.getMethods()[0].setUserId(userId.Id);
	            
		        list<PerformanceV2MOMAssessmentController.MethodReviewDate> mrds = perfV2MOMController.getMethods()[0].getHistoryFormatted();
		        if (mrds.size() > 0){
			        PerformanceV2MOMAssessmentController.MethodReviewDate mrd = mrds.get(0);
			        mrd.setCreatedDate(mrd.getCreatedDate());
			        mrd.setMethodReview(mrd.getMethodReview());
		        }
	        
	        }
	        
	        perfV2MOMController.getWithPrivileges();
	        
	    	PerformanceV2MOMAssessmentController.ScorecardUtil scorecardUtil = new PerformanceV2MOMAssessmentController.ScorecardUtil();  
 			list<ScorecardSupportReview__c> ssrs = scorecardUtil.getScorecardSupportWithSharing(pr);
 			ScorecardSupportReview__c q1 = new ScorecardSupportReview__c();
 			q1.PerformanceReview__c = pr.Id;
 			q1.Name = 'Q1';
 			q1.Reviewer__c = pr.Manager__c;
 			q1.FiscalQuarter__c = 'Q1';
 			q1.CustomerSatisfactionActual__c = 20;
 			q1.CustomerSatisfactionTarget__c = 20;
 			ScorecardSupportReview__c q2 = new ScorecardSupportReview__c();
 			q2.PerformanceReview__c = pr.Id;
 			q2.Name = 'Q2';
 			q2.Reviewer__c = pr.Manager__c;
 			q2.FiscalQuarter__c = 'Q2';
 			q2.CustomerSatisfactionActual__c = 20;
 			q2.CustomerSatisfactionTarget__c = 20;
 			if(ssrs != null){
 				ssrs.add(q1);
 				ssrs.add(q2);	
 			}
 			 
 			// Inner Class ScoreCardReviewSupport
	    	ScoreCardStep1 scoreCardReviewSupport = new ScoreCardStep1(ssrs, pr);
	     
	    	scoreCardReviewSupport.setPerformanceAccessUtil(perfV2MOMController.accessUtil);
	    	System.debug('+ de 0   ' + ssrs.size());
 			if (ssrs.size() > 0){
 				scoreCardReviewSupport.filterValues(ssrs[0]);
		        scoreCardReviewSupport.getId();
		        scoreCardReviewSupport.getScorecardSupportReview();
		        scoreCardReviewSupport.getQuarter('Q1');
		        scoreCardReviewSupport.getQuarter('Q2');
		        scoreCardReviewSupport.getQuarter('Q3');
		        scoreCardReviewSupport.getQuarter('Q4');
		        scoreCardReviewSupport.getSalesImpactRating();
		        scoreCardReviewSupport.getSalesImpactWeight();
		        scoreCardReviewSupport.getTimeOnPlatformRating();
		        scoreCardReviewSupport.getTimeOnPlatformWeight();
		        scoreCardReviewSupport.getForecastAccuracyRating();
		        scoreCardReviewSupport.getForecastAccuracyWeight();
		        
		        scoreCardReviewSupport.getCSMSalesImpactRating();
		        scoreCardReviewSupport.getCSMSalesImpactWeight();
		        scoreCardReviewSupport.getRenewalExcellenceRating();
		        scoreCardReviewSupport.getRenewalExcellenceWeight();
		        scoreCardReviewSupport.getOperationalExcellenceRating();
		        scoreCardReviewSupport.getOperationalExcellenceWeight();
		        scoreCardReviewSupport.getStrategicInitiativesRating();
		        scoreCardReviewSupport.getStrategicInitiativesWeight();
		        scoreCardReviewSupport.getCustomerSatisfactionRating();
		        scoreCardReviewSupport.getCustomerSatisfactionWeight();
		        scoreCardReviewSupport.getIsOldWorkloadManagement();
	        	scoreCardReviewSupport.getIsOld();
		        
		        ScoreCardStep1 scrs = new ScoreCardStep1(ssrs, pr, true);  
		     
		    	scrs.setPerformanceAccessUtil(perfV2MOMController.accessUtil);
	 			if (ssrs.size() > 0)
	 				scrs.filterValues(ssrs[0]);
		        scrs.getId();
		        scrs.getScorecardSupportReview();
		        scrs.getQuarter('Q1');
		        scrs.getQuarter('Q2');
		        scrs.getQuarter('Q3');
		        scrs.getQuarter('Q4');
		        scrs.getSalesImpactRating();
		        scrs.getSalesImpactWeight();
		        scrs.getTimeOnPlatformRating();
		        scrs.getTimeOnPlatformWeight();
		        scrs.getForecastAccuracyRating();
		        scrs.getForecastAccuracyWeight();
	        }

        	perfV2MOMController.saveNew();
        	perfV2MOMController.saveContinueNew();
	        perfV2MOMController.save();
	        perfV2MOMController.saveContinue();
		} catch (Exception e) {
            System.debug(' ****************** test_methods_V2MOMAssessmentControllerUser * ');
            System.debug(e.getMessage());
		}
	        
     }

}