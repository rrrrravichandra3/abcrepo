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
private class Test_ScorecardMetricCSM {
	private static User scEmployee = null;
	private static User scManager2 = null;
	private static User uAdmin = null;
	private static CompetencyGroup__c cgrp = GenerateEnvironmentTest.createCompetencyGroup('test', 'testCode');
    static testMethod void unitTest1() {
		test.startTest();
			
			
			GenerateEnvironmentTest.createCompetencyGroup();
			
			ReviewFormTemplate__c rftpl = GenerateEnvironmentTest.createReviewFromTemplate();
			
			User empl = GenerateEnvironmentTest.getEmployeeStandard();
			User mngr = GenerateEnvironmentTest.getManager(); 
			
			PerformanceReviewPeriod__c prp = GenerateEnvironmentTest.createPRP('Test Performance Review Period', 'FY08', 'Individual', date.newInstance(2011,1,1), date.newInstance(2012,1,1));
			PerformanceReview__c pr = GenerateEnvironmentTest.createPReviewNormal('Test Individual', prp.Id, V2MOM.Id, cgrp.Id, rftpl.Id, empl.Id, mngr.Id, GenerateEnvironmentTEst.getSecondManager().Id, GenerateEnvironmentTest.getPCOMMUser().Id, Deparment.Id);
			System.currentPageReference().getParameters().put('id', pr.Id);
			ScorecardMetricCSM smCSM = new ScorecardMetricCSM();
			String currentUserID = userInfo.getUserId();
			smCSM = new ScorecardMetricCSM(currentUserID);
			smCSM.isPCOMMLikeViewProfile = true;
			smCSm.constructor();
			smCSM.getCurrentUserComment();
			smCSM.getHistoryCommentCSMSalesImpact();
			SMCSM.getHistoryCommentOperationalExcellence();
			smCSM.getHistoryCommentStrategicInitiatives();
			smCSM.getperformanceR();
			smCSM.getProjectReview();
			smCSM.getProjectReviews();
			smCSM.getRatingSelectOptions();
			smCSM.getScorecard();
			smCSM.getScorecardCommentWithoutSharing(pr);
			smCSM.getScorecardSupportReview();
			smCSM.getTableType();
			smCSM.getUserProfile();
			smCSM.getv2momType();
			smCSM.saveProjectsReview();
			smCSM.saveProjectsReviewWithHideLoading();
			smCSM.setUserId(empl.Id);
			smCSM.getCurrentUserId();
			smCSM.getIs3PtInAssmnt();
			smCSM.getIsEmplInAssmntOnly();
			smCSM.getIsEmplMngr2ndMngr();
			smCSM.getIsEmplMngr2ndMngrOr3PtInAssmnt();
			smCSM.getIsEmployeeInAssmnt();
			smCSM.getIsMngr();
			smCSM.getIsMngr2ndMngrOr3PtInAssmnt();
			smCSM.getIsMngr2ndMngrOrEmplInAssmnt();
			smCSM.getIsMngrInAssmnt();
			smCSM.getIsOldCSM();
			smCSM.getIsQ1Q2();
			smCSM.getIsQ1Q2Only();
			smCSM.getIsQ3Q4();
			smCSM.getIsQ3Q4Only();
			smCSM.getIsSysAdminProfile();
			smCSM.getHasCommentRenewalExcellence();
			smCSM.getHasCommentCSMSalesImpact();
			smCSM.getHasCommentOperationalExcellence();
			smCSM.getHasCommentStrategicInitiatives();
			smCSM.updateProjectReview();
			smCSM.getLabelPreviousMetric();
			smCSM.getLabelMetricAvail();
			smCSM.getLabelMetricComment();
			smCSM.getLabelNextMetric();
			smCSM.getHistoryCommentRenewalExcellence();
			
			
			 
		test.stopTest();        
    }
    
     /* Enviroment Generators */
	
	public static V2MOM__c V2MOM{
		get{
			if(V2MOM==null){
				V2MOM = new V2MOM__c (OwnerId = GenerateEnvironmentTest.getEmployeeStandard().Id,
									Vision__c = 'Vision TestV2MOM', 
									V2MOM_Type__c = 'Individual',
									Name = 'Test V2MOM', 
									Effective_Date__c = 'FY08',
									Share_With__c = 'My Management Hierarchy');
				/* Run As Review Manager */
				system.runAs(GenerateEnvironmentTest.getManager()){
					insert V2MOM;
				}
								
				
			}
			return V2MOM;
		}
	}
	
	public static Department__c Deparment{
		get{
			if(Deparment==null){
				Deparment = new Department__c(Name='TestDeparment',ExcludeESBP__c=true);
				insert Deparment;
			}
			return Deparment;
		}
	}
	
	public static testMethod void	testScoreCardReviewSupport(){
		test.startTest();
			GenerateEnvironmentTest.createCompetencyGroup();
			
			ReviewFormTemplate__c rftpl = GenerateEnvironmentTest.createReviewFromTemplate();
			
			User empl = GenerateEnvironmentTest.getEmployeeStandard();
			User mngr = GenerateEnvironmentTest.getManager(); 
			
			PerformanceReviewPeriod__c prp = GenerateEnvironmentTest.createPRP('Test Performance Review Period', 'FY08', 'Individual', date.newInstance(2011,1,1), date.newInstance(2012,1,1));
			PerformanceReview__c pr = GenerateEnvironmentTest.createPReviewNormal('Test Individual', prp.Id, V2MOM.Id, cgrp.Id, rftpl.Id, empl.Id, mngr.Id, GenerateEnvironmentTEst.getSecondManager().Id, GenerateEnvironmentTest.getPCOMMUser().Id, Deparment.Id);
			System.currentPageReference().getParameters().put('id', pr.Id);
			List<ScorecardSupportReview__c> scoreCards = new List<ScorecardSupportReview__c>();
			ScorecardSupportReview__c scSupportReview = GenerateEnvironmentTest.createScorecardSupportReview('Test ScorecardSupportReview', pr.Id, mngr.Id, 'Q1');
			scoreCards.add(scSupportReview);
			ScorecardSupportComment__c scoreComment = GenerateEnvironmentTest.createScorecardSupportReviewComment(	pr.Id, mngr.Id, 
																													'CS comm Q1Q2 employee sup',
																													'renewals comm Q1Q2 employee sup',
																													'WMCases comm Q1Q2 employee sup',
																													'WMSMES comm Q1Q2 employee sup', 
																													'WMHC comm Q1Q2 employee sup',
																													'WMPA comm Q1Q2 employee sup',
																													'supportInitiatives comm Q1Q2 employee sup',
																													'salesImpact comm Q1Q2 employee sup',
																													'timeOnPlatform comm Q1Q2 employee sup',
																													'forecastAccuracy comm Q1Q2 employee sup');
			ScorecardMetricCSM.ScoreCardReviewSupport scrs = new ScorecardMetricCSM.ScoreCardReviewSupport(scoreCards, pr, scoreComment, true);
			
			scrs.getUserId();
			scrs.getRenewalExcellenceActualQ1();
			scrs.getRenewalExcellenceActualQ2();
			scrs.getRenewalExcellenceActualQ3();
			scrs.getRenewalExcellenceActualQ4();
			scrs.getRenewalExcellenceAttainmentQ1();
			scrs.getRenewalExcellenceRating();
			scrs.getRenewalExcellenceTargetQ1();
			scrs.getRenewalExcellenceTargetQ2();
			scrs.getRenewalExcellenceTargetQ3();
			scrs.getRenewalExcellenceTargetQ4();
			scrs.getRenewalExcellenceWeight();
			scrs.getACVGrowthActualQ1();
			scrs.getACVGrowthActualQ2();
			scrs.getACVGrowthActualQ3();
			scrs.getACVGrowthActualQ4();
			scrs.getACVGrowthAttainmentQ1();
			scrs.getACVGrowthAttainmentQ2();
			scrs.getACVGrowthAttainmentQ3();
			scrs.getACVGrowthAttainmentQ4();
			scrs.getACVGrowthTargetQ1();
			scrs.getACVGrowthTargetQ2();
			scrs.getACVGrowthTargetQ3();
			scrs.getACVGrowthTargetQ4();
			scrs.getCommentCSMSalesImpact();
			scrs.getCommentOperationalExcellence();
			scrs.getCommentRenewalExcellence();
			scrs.getCommentStrategicInitiatives();
			scrs.getCSMSalesImpactRating();
			scrs.getCSMSalesImpactWeight();
			scrs.getCSMSICSEAmountActual();
			scrs.getCSMSIPipeLineContributionActual();
			scrs.getCSMSIPipeLineContributionConsultingActual();
			scrs.getCSMSIPipeLineContributionTraningActual();
			scrs.getScorecardSupportReview();
			scrs.getRenewalExcellenceAttainmentQ2();
			scrs.getRenewalExcellenceAttainmentQ3();
			scrs.getRenewalExcellenceAttainmentQ4();
			scrs.getYTDActual();
			scrs.getYTDTarget();
			scrs.getYTDAttainment();
			scrs.getRatingDescription(1);
			scrs.getOperationalExcellenceActualQ1();
			scrs.getOperationalExcellenceActualQ2();
			scrs.getOperationalExcellenceActualQ3();
			scrs.getOperationalExcellenceActualQ4();
			scrs.getOperationalExcellenceTargetQ1();
			scrs.getOperationalExcellenceTargetQ2();
			scrs.getOperationalExcellenceTargetQ3();
			scrs.getOperationalExcellenceTargetQ4();
			scrs.getOperationalExcellenceAttainmentQ1();
			scrs.getOperationalExcellenceAttainmentQ2();
			scrs.getOperationalExcellenceAttainmentQ3();
			scrs.getOperationalExcellenceAttainmentQ4();
			scrs.getOperationalExcellenceRating();
			scrs.getOperationalExcellenceWeight();
			scrs.getStrategicInitiativesRating();
			scrs.getStrategicInitiativesWeight();
			scrs.getYTDACVGrowthActual();
			scrs.getYTDACVGrowthTarget();
			scrs.getYTDACVGrowthAttainment();
			scrs.getPipelineContributionActualQ1();
			scrs.getPipelineContributionActualQ2();
			scrs.getPipelineContributionActualQ3();
			scrs.getPipelineContributionActualQ4();
			scrs.getPipelineContributionTargetQ1();
			scrs.getPipelineContributionTargetQ2();
			scrs.getPipelineContributionTargetQ3();
			scrs.getPipelineContributionTargetQ4();
			scrs.getYTDPipelineContributionActual();
			scrs.getYTDPipelineContributionTarget();
			scrs.getPipelineContributionAttainmentQ1();
			scrs.getPipelineContributionAttainmentQ2();
			scrs.getPipelineContributionAttainmentQ3();
			scrs.getPipelineContributionAttainmentQ4();
			//scrs.getYTDPipelineContributionAttainment();
			scrs.getExecutiveRelationshipsActualQ1();
			scrs.getExecutiveRelationshipsActualQ3();
			scrs.getExecutiveRelationshipsActualQ4();
			scrs.getExecutiveRelationshipsTargetQ1();
			scrs.getExecutiveRelationshipsTargetQ2();
			scrs.getExecutiveRelationshipsTargetQ3();
			scrs.getExecutiveRelationshipsTargetQ4();
			scrs.getExecutiveRelationshipsAttainmentQ1();
			scrs.getExecutiveRelationshipsAttainmentQ2();
			scrs.getExecutiveRelationshipsAttainmentQ3();
			scrs.getExecutiveRelationshipsAttainmentQ4();
			 
		test.stopTest();
	}
	
	public static testMethod void testCommentHistory(){
		test.startTest();
			GenerateEnvironmentTest.createCompetencyGroup();
			
			ReviewFormTemplate__c rftpl = GenerateEnvironmentTest.createReviewFromTemplate();
			
			User empl = GenerateEnvironmentTest.getEmployeeStandard();
			User mngr = GenerateEnvironmentTest.getManager(); 
			
			PerformanceReviewPeriod__c prp = GenerateEnvironmentTest.createPRP('Test Performance Review Period', 'FY08', 'Individual', date.newInstance(2011,1,1), date.newInstance(2012,1,1));
			PerformanceReview__c pr = GenerateEnvironmentTest.createPReviewNormal('Test Individual', prp.Id, V2MOM.Id, cgrp.Id, rftpl.Id, empl.Id, mngr.Id, GenerateEnvironmentTEst.getSecondManager().Id, GenerateEnvironmentTest.getPCOMMUser().Id, Deparment.Id);
			System.currentPageReference().getParameters().put('id', pr.Id);
			List<ScorecardSupportReview__c> scoreCards = new List<ScorecardSupportReview__c>();
			ScorecardSupportReview__c scSupportReview = GenerateEnvironmentTest.createScorecardSupportReview('Test ScorecardSupportReview', pr.Id, mngr.Id, 'Q1');
			scoreCards.add(scSupportReview);
			ScorecardSupportComment__c scoreComment = GenerateEnvironmentTest.createScorecardSupportReviewComment(	pr.Id, mngr.Id, 
																													'CS comm Q1Q2 employee sup',
																													'renewals comm Q1Q2 employee sup',
																													'WMCases comm Q1Q2 employee sup',
																													'WMSMES comm Q1Q2 employee sup', 
																													'WMHC comm Q1Q2 employee sup',
																													'WMPA comm Q1Q2 employee sup',
																													'supportInitiatives comm Q1Q2 employee sup',
																													'salesImpact comm Q1Q2 employee sup',
																													'timeOnPlatform comm Q1Q2 employee sup',
																													'forecastAccuracy comm Q1Q2 employee sup');
			scoreComment.CreatedDate = date.newInstance(2011,1,1);
			ScorecardMetricCSM.HistoryComments histComment = new ScorecardMetricCSM.HistoryComments(scoreComment);
			histComment.getComment();
			histComment.getCreatedDate();
			histComment.setComment(scoreComment);
			histComment.setCreatedDate('2011-07-15');
		test.stopTest();
	}	
}