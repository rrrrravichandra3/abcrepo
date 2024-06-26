@isTest
private class Test_ScorecardReviewSupportCSController {
        

      
      public static testMethod void test_scorecardScorecardReviewSupportCSController() {
            User employee = GenerateEnvironmentTestUsers.createEmployeeWithManager();
            PerformanceReview__c pr = [select Id from PerformanceReview__c limit 1];
        	System.currentPageReference().getParameters().put('id', pr.Id);
      
           
            ScorecardReviewSupportCSController controller = new ScorecardReviewSupportCSController();	
         
     
    
            controller.getperformanceR();
            controller.getUserId();
            controller.getScorecard();
          
            
            controller.getLabelMetricAvail();
            controller.getIsQ1Q2();
            controller.getUserProfile();
            controller.getLabelMetricAvail();
            controller.getLabelMetricComment();
            
            controller.getv2momType();
            controller.getCurrentUserId();
            controller.getAdjustedRatingSelectOptions();
            controller.getLabelPreviousMetric();
            controller.getLabelNextMetric();
            controller.getDifferenceView();
            controller.getAdjustedRatingView();
            
            /*
            //Check Comment
            //List<ScorecardReviewSupportCSController.HistoryComments> hcs = controller.getHistoryCommentSupport();
            //ScorecardReviewSupportCSController.HistoryComments hc;
            
            
            //hc = hcs.get(0);
            //hc.getComment();
            //hc.setComment(hc.getComment());
            //hc.getCreatedDate();
            //hc.setCreatedDate('');
           
            
            //controller.getHistoryCommentSupportRenewals();
            //controller.getHistoryCommentSupportInitiatives();
            //controller.getHistoryCommentSupportWMCases();
            //controller.getHistoryCommentSupportWMSMES();
            //controller.getHistoryCommentSupportWMPA();
            //controller.getHistoryCommentSupportWMHC();
            
            controller.getHasCommentCS();
            controller.getHasCommentRenewals();
            controller.getHasCommentSI();
            controller.getHasCommentWMCases();
            controller.getHasCommentWMSMES();
            controller.getHasCommentWMPA();
            controller.getHasCommentWMHC();
        
            controller.getIsMngrInAssmnt();
            controller.getIsSysAdminProfile();
            controller.getIsMngr();
            controller.getIsMngr2ndMngrOr3PtInAssmnt();
    		
            ScorecardReviewSupportCSController.ScoreCardReviewSupport innerClass = controller.getScorecardSupportReview();
            
            innerClass.getUserId();
            innerClass.getId();
            innerClass.getScorecardSupportReview();
            innerClass.getWeightQ1();
            innerClass.getWeightQ2();
            innerClass.getAdjustedRatingQ1();
            innerClass.getAdjustedRatingQ2();
            innerClass.getCalculatedRatingQ1();
            innerClass.getCalculatedRatingQ2();
            innerClass.getRatingDifferenceQ1();
            innerClass.getRatingDifferenceQ2();
            innerClass.getWeightQ1Renewals();
            innerClass.getWeightQ2Renewals();
            innerClass.getAdjustedRatingQ1Renewals();
            innerClass.getAdjustedRatingQ2Renewals();
            innerClass.getCalculatedRatingQ1Renewals();
            innerClass.getCalculatedRatingQ2Renewals();
            innerClass.getRatingDifferenceQ1Renewals();
            innerClass.getRatingDifferenceQ2Renewals();
            innerClass.getCommentRenewals();
            innerClass.getWeightQ1SI();
            innerClass.getWeightQ2SI();
            innerClass.getAdjustedRatingQ1SI();
            innerClass.getAdjustedRatingQ2SI();
            innerClass.getCalculatedRatingQ1SI();
            innerClass.getCalculatedRatingQ2SI();
            innerClass.getRatingDifferenceQ1SI();
            innerClass.getRatingDifferenceQ2SI();
            innerClass.getComment();
            innerClass.getCommentSI();
            innerClass.getWeightQ1WMCases();
            innerClass.getWeightQ2WMCases();
            innerClass.getAdjustedRatingQ1WMCases();
            innerClass.getAdjustedRatingQ2WMCases();
            innerClass.getCalculatedRatingQ1WMCases();
            innerClass.getCalculatedRatingQ2WMCases();
            innerClass.getRatingDifferenceQ1WMCases();
            innerClass.getRatingDifferenceQ2WMCases();
            innerClass.getCommentWMCases();
            innerClass.getWeightQ1WMSMES();
            innerClass.getWeightQ2WMSMES();
            innerClass.getAdjustedRatingQ1WMSMES();
            innerClass.getAdjustedRatingQ2WMSMES();
            innerClass.getCalculatedRatingQ1WMSMES();
            innerClass.getCalculatedRatingQ2WMSMES();
            innerClass.getRatingDifferenceQ1WMSMES();
            innerClass.getRatingDifferenceQ2WMSMES();
            innerClass.getCommentWMSMES();
            innerClass.getWeightQ1WMPA();
            innerClass.getWeightQ2WMPA();
            innerClass.getAdjustedRatingQ1WMPA();
            innerClass.getAdjustedRatingQ2WMPA();
        
            innerClass.getCommentWMPA();
            innerClass.getWeightQ1WMHC();
            innerClass.getWeightQ2WMHC();
            innerClass.getAdjustedRatingQ1WMHC();
            innerClass.getAdjustedRatingQ2WMHC();
            innerClass.getCalculatedRatingQ1WMHC();
            innerClass.getCalculatedRatingQ2WMHC();
            innerClass.getRatingDifferenceQ1WMHC();
            innerClass.getRatingDifferenceQ2WMHC();
            innerClass.getCommentWMHC();
            
            
            innerClass.getWeightQ3();
            innerClass.getWeightQ4();
            innerClass.getAdjustedRatingQ3();
            innerClass.getAdjustedRatingQ4();
            innerClass.getCalculatedRatingQ3();
            innerClass.getCalculatedRatingQ4();
            innerClass.getRatingDifferenceQ3();
            innerClass.getRatingDifferenceQ4();
            innerClass.getWeightQ3Renewals();
            innerClass.getWeightQ4Renewals();
            innerClass.getAdjustedRatingQ3Renewals();
            innerClass.getAdjustedRatingQ4Renewals();
            innerClass.getCalculatedRatingQ3Renewals();
            innerClass.getCalculatedRatingQ4Renewals();
            innerClass.getRatingDifferenceQ3Renewals();
            innerClass.getRatingDifferenceQ4Renewals();
            innerClass.getWeightQ3SI();
            innerClass.getWeightQ4SI();
            innerClass.getAdjustedRatingQ3SI();
            innerClass.getAdjustedRatingQ4SI();
            innerClass.getCalculatedRatingQ3SI();
            innerClass.getCalculatedRatingQ4SI();
            innerClass.getRatingDifferenceQ3SI();
            innerClass.getRatingDifferenceQ4SI();
            innerClass.getWeightQ3WMCases();
            innerClass.getWeightQ4WMCases();
            innerClass.getAdjustedRatingQ3WMCases();
            innerClass.getAdjustedRatingQ4WMCases();
            innerClass.getCalculatedRatingQ3WMCases();
            innerClass.getCalculatedRatingQ4WMCases();
            innerClass.getRatingDifferenceQ3WMCases();
            innerClass.getRatingDifferenceQ4WMCases();
            innerClass.getWeightQ3WMSMES();
            innerClass.getWeightQ4WMSMES();
            innerClass.getAdjustedRatingQ3WMSMES();
            innerClass.getAdjustedRatingQ4WMSMES();
            innerClass.getCalculatedRatingQ3WMSMES();
            innerClass.getCalculatedRatingQ4WMSMES();
            innerClass.getRatingDifferenceQ3WMSMES();
            innerClass.getRatingDifferenceQ4WMSMES();
            innerClass.getWeightQ3WMPA();
            innerClass.getWeightQ4WMPA();
            innerClass.getAdjustedRatingQ3WMPA();
            innerClass.getAdjustedRatingQ4WMPA();
            innerClass.getWeightQ3WMHC();
            innerClass.getWeightQ4WMHC();
            innerClass.getAdjustedRatingQ3WMHC();
            innerClass.getAdjustedRatingQ4WMHC();
            innerClass.getCalculatedRatingQ3WMHC();
            innerClass.getCalculatedRatingQ4WMHC();
            innerClass.getRatingDifferenceQ3WMHC();
            innerClass.getRatingDifferenceQ4WMHC();
            innerClass.setUserId('');
            
            innerClass.getIsOld();
            innerClass.getCustomerSatisfactionActualQ1();
            innerClass.getCustomerSatisfactionActualQ2();
            innerClass.getCustomerSatisfactionActualQ3();
            innerClass.getCustomerSatisfactionActualQ4();
            innerClass.getCustomerSatisfactionTargetQ1();
            innerClass.getCustomerSatisfactionTargetQ2();
            innerClass.getCustomerSatisfactionTargetQ3();
            innerClass.getCustomerSatisfactionTargetQ4();
            innerClass.getCustomerSatisfactionAttainmentQ1();
            innerClass.getCustomerSatisfactionAttainmentQ2();
            innerClass.getCustomerSatisfactionAttainmentQ3();
            innerClass.getCustomerSatisfactionAttainmentQ4();
            
            innerClass.getCustomerSatisfactionRating();
            innerClass.getRatingDescription(1);
            innerClass.getCustomerSatisfactionWeight();
            innerClass.getYTDActual();
            innerClass.getYTDTarget();
            innerClass.getYTDAttainment();
            controller.setUserId('');
            */
             
      }   
}