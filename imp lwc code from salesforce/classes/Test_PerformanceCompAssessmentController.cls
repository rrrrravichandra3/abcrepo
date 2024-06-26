@isTest
private class Test_PerformanceCompAssessmentController {

    static testMethod void test1() {
        
       test.startTest();
        //PerformanceCompAssessmentController.isTestClass = true;
        String performanceId = [Select Id From PerformanceReview__c limit 1][0].Id;
        System.currentPageReference().getParameters().put('id', performanceId);
        System.assertEquals(System.currentPageReference().getParameters().get('id'), performanceId);
        PerformanceCompAssessmentController pcac = new PerformanceCompAssessmentController();
        
        PerformanceReview__c testPerf = pcac.getPerformanceReviewWithoutSharing(performanceId);
        pcac.setPerformanceReviewParam(performanceId);
        
        pcac.constructor(); 
        List<PerformanceCompAssessmentController.Competency> testCompetencies = new List<PerformanceCompAssessmentController.Competency>();
        List<CompetencyGroupMember__c> compGroup = [Select Id, Name,
                                                     Weight__c,
                                                     Competency__r.Name,
                                                     Competency__r.Description__c,
                                                     Competency__c
                                              From CompetencyGroupMember__c
                                              Where CompetencyGroup__c =: testPerf.CompetencyGroup__c];
        Map<Id, CompetencyReview__c> competenciesReview = pcac.getCompetencyReviewWithoutSharingMap(testPerf, compGroup);
        PerformanceCompAssessmentController.CompetencyUtil competencyUtil = new PerformanceCompAssessmentController.CompetencyUtil();
        List<CompetencyReview__c> competenciesList = competencyUtil.getCompetencyReviewListWithSharing(testPerf, compGroup);                                     
        for(CompetencyGroupMember__c competencyGroup: compGroup){
        	PerformanceCompAssessmentController.Competency competency = new PerformanceCompAssessmentController.Competency(competencyGroup, testPerf);
        	competency.getIsComplete();
        	competency.setHistory(competenciesList);
        	competency.getRatingReview();
        	competency.getShowHistory();
        	competency.getCurrentUserId();
        	
        	competency.setCurrentUserId(userInfo.getUserId());
        	competency.setRating(2);
        	competency.setUserProfile(userInfo.getProfileId());
        	CompetencyGroupMember__c comGroup = competency.getCompetency();
        	competency.setCompetency(comGroup);
       		competency.getHistoryFormatted();
       		competency.getHistory();
       		competency.getRating();
       		competency.getWeight();
        	
        	testCompetencies.add(competency);
        	CompetencyReview__c review = competenciesReview.get(competencyGroup.Competency__c);                    
            if (review != null){   
               competency.setReview(review); 
            }
        }
        
        pcac.setCompetencies(testCompetencies);                                      
       	pcac.save();
       	competenciesReview = competencyUtil.getCompetencyReviewWithSharingMap(testPerf, compGroup);
       	competencyUtil.getCompetencyReviewListWithSharing(testPerf, compGroup);
       	
       	pcac.getCompetencyReviewListWithoutSharing(testPerf, compGroup);
       	pcac.saveContinue();
       	pcac.getShowReviewEdit();
       	pcac.getIsManager();
       	pcac.getIsEmployee();
       	pcac.getIsSysAdminProfile();
       	pcac.getIsMngr();
       	pcac.getIsMngrInAssmnt();
       	pcac.getIsEmplMngr2ndMngrOr3PtInAssmnt();
       
        test.stopTest();
        
        
     
    }
    
    static testMethod void test2(){
    	test.startTest();
    		String performanceId = [Select Id From PerformanceReview__c limit 1][0].Id;
        	System.currentPageReference().getParameters().put('id', performanceId);
        	PerformanceCompAssessmentController pcac = new PerformanceCompAssessmentController();
        
        	PerformanceReview__c testPerf = pcac.getPerformanceReviewWithoutSharing(performanceId);
        	pcac.setPerformanceReviewParam(performanceId);
        
        	pcac.constructor();
        	
        	pcac.getRatingSelectOptions();
        	pcac.getPerformanceReview();
        	pcac.getCurrentUserId();
        	pcac.setCurrentUserId(userInfo.getUserId());
        	pcac.getLabelPreviousCompetency();
        	pcac.getLabelNextCompetency();
        	pcac.getCompetencies();
        	pcac.getCompetencyWeight();
        	
        	
        	
        	CompetencyReview__c testCompetency = new CompetencyReview__c();
        	
        	
        	testCompetency.PerformanceReview__c = performanceId;
        	testCompetency.Reviewer__c = testPerf.Manager__c;
        	testCompetency.CreatedDate = date.newInstance(2011,1,1);
       		testCompetency.LastModifiedDate = date.newInstance(2011,1,1);
       		System.assertEquals(testCompetency.PerformanceReview__c, performanceId);
       		upsert testCompetency;
       		
       		PerformanceCompAssessmentCOntroller.CompetencyReviewDate crDate = new PerformanceCompAssessmentCOntroller.CompetencyReviewDate(testCompetency);
       		crDate.getCompetencyReview();
       		crDate.setCompetencyReview(testCompetency);
       		
       		crDate.getCreatedDate();
       		crDate.getLastModifiedDate();
       		crDate.getReviewerName();
       		crDate.setCreatedDate('2011-01-01');
       		      		
       		
    	test.stopTest();
    }
    
    
}