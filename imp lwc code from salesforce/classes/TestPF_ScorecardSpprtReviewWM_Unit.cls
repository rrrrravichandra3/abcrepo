/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class TestPF_ScorecardSpprtReviewWM_Unit {
  
    static testMethod void execute_methods_ScorecardSupportReviewWM() {
        Test.startTest();
        
         GenerateEnvironmentTest3.genScorecardSupport();
         
         if(GenerateEnvironmentTest3.PRIndividualQ1Q2Sup!=null){
         	System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest3.PRIndividualQ1Q2Sup.Id);	
         }   
		 
	  	 
	  	
		  	ScorecardSupportReviewWM controller = new ScorecardSupportReviewWM();
		  		
		  	if (controller.getperformanceR() == null){
		  		System.assert(false,'Null Performance Review');	  			
		  	}
		  	
		  	String userId = controller.userId();
		  	controller.getIsQ1Q2();
		  	controller.getIsQ3Q4();
		  	controller.getCurrentUserComment();
		  	controller.getIsPremierUser();
		  	controller.getCurrentUserId();
		  	controller.getRatingSelectOptions();
		  	controller.getperformanceR();
		  	controller.getv2momType();
		  	controller.getTableType();
		  	controller.getScorecardSupportReview();
		  	controller.getScorecard();
		  	controller.getUserProfile();
		  	controller.getLabelPreviousMetric();
		  	controller.getLabelNextMetric();
		  	controller.getLabelMetricAvail();
		  	controller.getLabelMetricComment();
		  	controller.getIsSysAdminProfile();
		  	controller.getIsMngr();
		  	controller.getIsMngrInAssmnt();
		  	controller.getIs3PtInAssmnt();
		  	controller.getIsMngr2ndMngrOr3PtInAssmnt();
		  	controller.getHistoryCommentWMCCP();
		  	controller.getHasCommentWMCCP();
		  	controller.getHistoryCommentWMCAA();
		  	controller.getHasCommentWMCAA();
		  	controller.isPCOMMLikeViewProfile = false;
		  	controller.constructor();
		  	List<ScorecardSupportReview__c> scrcds = new List<ScorecardSupportReview__c>();
		  	/*GenerateEnvironmentTest3.sq1Sup.WMCCPActual__c = 3; 
		  	GenerateEnvironmentTest3.sq1Sup.WMCCPTarget__c = 3;
		  	GenerateEnvironmentTest3.sq1Sup.WMCAAActual__c = 3; 
		  	GenerateEnvironmentTest3.sq1Sup.WMCAATarget__c = 3; 
		  	GenerateEnvironmentTest3.sq1Sup.WMBAActual__c = 3; 
		  	GenerateEnvironmentTest3.sq1Sup.WMBATarget__c = 3;  
		  	GenerateEnvironmentTest3.sq1Sup.WMSOActual__c = 3; 
		  	GenerateEnvironmentTest3.sq2Sup.WMSOTarget__c = 3;
		  	GenerateEnvironmentTest3.sq2Sup.WMCCPActual__c = 3; 
		  	GenerateEnvironmentTest3.sq2Sup.WMCCPTarget__c = 3;
		  	GenerateEnvironmentTest3.sq2Sup.WMCAAActual__c = 3; 
		  	GenerateEnvironmentTest3.sq2Sup.WMCAATarget__c = 3; 
		  	GenerateEnvironmentTest3.sq2Sup.WMBAActual__c = 3; 
		  	GenerateEnvironmentTest3.sq2Sup.WMBATarget__c = 3;  
		  	GenerateEnvironmentTest3.sq2Sup.WMSOActual__c = 3; 
		  	GenerateEnvironmentTest3.sq2Sup.WMSOTarget__c = 3;
		  	
		  	GenerateEnvironmentTest3.sq3Sup.WMSOTarget__c = 3;
		  	GenerateEnvironmentTest3.sq3Sup.WMCCPActual__c = 3; 
		  	GenerateEnvironmentTest3.sq3Sup.WMCCPTarget__c = 3;
		  	GenerateEnvironmentTest3.sq3Sup.WMCAAActual__c = 3; 
		  	GenerateEnvironmentTest3.sq3Sup.WMCAATarget__c = 3; 
		  	GenerateEnvironmentTest3.sq3Sup.WMBAActual__c = 3; 
		  	GenerateEnvironmentTest3.sq3Sup.WMBATarget__c = 3;  
		  	GenerateEnvironmentTest3.sq3Sup.WMSOActual__c = 3; 
		  	GenerateEnvironmentTest3.sq3Sup.WMSOTarget__c = 3;
		  	
		  	GenerateEnvironmentTest3.sq4Sup.WMSOTarget__c = 3;
		  	GenerateEnvironmentTest3.sq4Sup.WMCCPActual__c = 3; 
		  	GenerateEnvironmentTest3.sq4Sup.WMCCPTarget__c = 3;
		  	GenerateEnvironmentTest3.sq4Sup.WMCAAActual__c = 3; 
		  	GenerateEnvironmentTest3.sq4Sup.WMCAATarget__c = 3; 
		  	GenerateEnvironmentTest3.sq4Sup.WMBAActual__c = 3; 
		  	GenerateEnvironmentTest3.sq4Sup.WMBATarget__c = 3;  
		  	GenerateEnvironmentTest3.sq4Sup.WMSOActual__c = 3; 
		  	GenerateEnvironmentTest3.sq4Sup.WMSOTarget__c = 3;
		  	
		  	GenerateEnvironmentTest3.sq2Sup.WMCCPRating__c = 2;
		  	GenerateEnvironmentTest3.sq1Sup.WMCCPRating__c = 2;
		  	GenerateEnvironmentTest3.sq2Sup.WMCAARating__c = 2;
		  	GenerateEnvironmentTest3.sq1Sup.WMCAARating__c = 2;
		  	GenerateEnvironmentTest3.sq3Sup.WMCCPRating__c = 2;
		  	GenerateEnvironmentTest3.sq4Sup.WMCCPRating__c = 2;
		  	GenerateEnvironmentTest3.sq3Sup.WMCAARating__c = 2;
		  	GenerateEnvironmentTest3.sq4Sup.WMCAARating__c = 2;
		  	scrcds.add(GenerateEnvironmentTest3.sq1Sup);
		  	scrcds.add(GenerateEnvironmentTest3.sq2Sup);
		  	
		  	GenerateEnvironmentTest3.sscommQ1Q2SuprevMngr.CommentWMCCP__c = 'comment';
		  	GenerateEnvironmentTest3.sscommQ1Q2SuprevMngr.CommentWMCAA__c = 'comment';
		  	*/
		  	PerformanceReview__c performanceTest = [SELECT Id, Manager__c, ThirdPartyReviewer__c, PCOMM__c,Employee__r.Division, Name, SecondManager__c, Employee__c, Status__c, PreviousStatus__c, V2MOM__r.V2MOM_Type__c, PremierUser__c  
                        							FROM PerformanceReview__c limit 1][0];
		  	//ScorecardSupportReviewWM.ScoreCardReviewSupport scorecardSupportWM = new ScorecardSupportReviewWM.ScoreCardReviewSupport(scrcds, GenerateEnvironmentTest3.PRIndividualQ1Q2Sup, GenerateEnvironmentTest3.sscommQ1Q2SuprevMngr);
		  	ScorecardSupportReviewWM.ScoreCardReviewSupport scorecardSupportWM = new ScorecardSupportReviewWM.ScoreCardReviewSupport(scrcds, performanceTest, GenerateEnvironmentTest3.sscommQ1Q2SuprevMngr);
		  	scorecardSupportWM.getUserId();
		  	scorecardSupportWM.getId();
		  	scorecardSupportWM.getScorecardSupportReview();
		  	scorecardSupportWM.getWMCCPActualQ1();
		  	scorecardSupportWM.getWMCCPActualQ2();
		  	scorecardSupportWM.getWMCCPActualQ3();
		  	scorecardSupportWM.getWMCCPActualQ4();
		  	scorecardSupportWM.getWMCCPTargetQ1();
		  	scorecardSupportWM.getWMCCPTargetQ2();
		  	scorecardSupportWM.getWMCCPTargetQ3();
		  	scorecardSupportWM.getWMCCPTargetQ4();
		  	scorecardSupportWM.getWMCCPAttainmentQ1();
		  	scorecardSupportWM.getWMCCPAttainmentQ2();
		  	scorecardSupportWM.getWMCCPAttainmentQ3();
		  	scorecardSupportWM.getWMCCPAttainmentQ4();
		  	scorecardSupportWM.getWMCCPYTDActual();
		  	scorecardSupportWM.getWMCCPYTDTarget();
		  	scorecardSupportWM.getWMCCPYTDAttainment();
		  	scorecardSupportWM.getCommentWMCCP();
		  	scorecardSupportWM.getWMCCPRating();
		  	scorecardSupportWM.getRatingDescription(2);
		  	scorecardSupportWM.getWMCCPWeight();
		  	
		  	scorecardSupportWM.getWMCAAActualQ1();
		  	scorecardSupportWM.getWMCAAActualQ2();
		  	scorecardSupportWM.getWMCAAActualQ3();
		  	scorecardSupportWM.getWMCAAActualQ4();
		  	scorecardSupportWM.getWMCAATargetQ1();
		  	scorecardSupportWM.getWMCAATargetQ2();
		  	scorecardSupportWM.getWMCAATargetQ3();
		  	scorecardSupportWM.getWMCAATargetQ4();
		  	scorecardSupportWM.getWMCAAAttainmentQ1();
		  	scorecardSupportWM.getWMCAAAttainmentQ2();
		  	scorecardSupportWM.getWMCAAAttainmentQ3();
		  	scorecardSupportWM.getWMCAAAttainmentQ4();
		  	scorecardSupportWM.getWMCAARating();
		  	scorecardSupportWM.getWMCAAWeight();
		  	scorecardSupportWM.getWMCAAYTDActual();
		  	scorecardSupportWM.getWMCAAYTDTarget();
		  	scorecardSupportWM.getWMCAAYTDAttainment();
		  	scorecardSupportWM.getCommentWMCAA();
		  	scorecardSupportWM.getWMSOActualQ1();
		  	scorecardSupportWM.getWMSOActualQ2();
		  	scorecardSupportWM.getWMSOActualQ3();
		  	scorecardSupportWM.getWMSOActualQ4();
		  	scorecardSupportWM.getWMSOTargetQ1();
		  	scorecardSupportWM.getWMSOTargetQ2();
		  	scorecardSupportWM.getWMSOTargetQ3();
		  	scorecardSupportWM.getWMSOTargetQ4();
		  	scorecardSupportWM.getWMSOAttainmentQ1();
		  	scorecardSupportWM.getWMSOAttainmentQ2();
		  	scorecardSupportWM.getWMSOAttainmentQ3();
		  	scorecardSupportWM.getWMSOAttainmentQ4();
		  	scorecardSupportWM.getWMSOYTDActual();
		  	scorecardSupportWM.getWMSOYTDTarget();
		  	scorecardSupportWM.getWMSOYTDAttainment();
		  	scorecardSupportWM.getWMBAActualQ1();
		  	scorecardSupportWM.getWMBAActualQ2();
		  	scorecardSupportWM.getWMBAActualQ3();
		  	scorecardSupportWM.getWMBAActualQ4();
		  	scorecardSupportWM.getWMBATargetQ1();
		  	scorecardSupportWM.getWMBATargetQ2();
		  	scorecardSupportWM.getWMBATargetQ3();
		  	scorecardSupportWM.getWMBATargetQ4();
		  	scorecardSupportWM.getWMBAAttainmentQ1();
		  	scorecardSupportWM.getWMBAAttainmentQ2();
		  	scorecardSupportWM.getWMBAAttainmentQ3();  
		  	scorecardSupportWM.getWMBAAttainmentQ4();
		  	scorecardSupportWM.getWMBAYTDActual(); 
		  	scorecardSupportWM.getWMBAYTDTarget();
		  	scorecardSupportWM.getWMBAYTDAttainment();
		  	
		  	ScorecardSupportReviewWM.ScorecardUtil scoreUtil = new ScorecardSupportReviewWM.ScorecardUtil();
		  	scoreUtil.getScorecardCommentWithSharing(performanceTest);
		  	/*ScorecardSupportComment__c c = new ScorecardSupportComment__c (Reviewer__c = userId,
								                PerformanceReview__c = performanceTest.Id);
		  	ScorecardSupportReviewWM.HistoryComments hc = new ScorecardSupportReviewWM.HistoryComments(c);  
		  	//ScorecardSupportReviewWM.HistoryComments hc = new ScorecardSupportReviewWM.HistoryComments(GenerateEnvironmentTest3.sscommQ1Q2SuprevMngr);
		  	hc.getComment();
		  	hc.getCreatedDate();
		  	hc.setCreatedDate('test');*/
		  	//System.debug('scorecarddddddd     ' + hc);
		  	//System.debug('scorecarddddddd  2   ' + GenerateEnvironmentTest3.sq1Sup); 
		  	
		
	  	Test.stopTest();  	
    }
}