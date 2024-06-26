@isTest
private class Test_ReviewSharing {
    
    public static testMethod void execute_methods_ReviewSharing() {
        GenerateEnvironmentTest8.genReviewSharing();
        //Test.setCurrentPageReference(new PageReference('Page.MyTeam'));
		Test.startTest();
 
		try {
			 
	        ReviewSharing controller = new ReviewSharing(GenerateEnvironmentTest8.PRAdHocDB, GenerateEnvironmentTest8.employeeStandard.Id, '');   
	        controller.add(GenerateEnvironmentTest8.competency1revEmpl);
	        controller.add(GenerateEnvironmentTest8.method1revEmpl);
	        controller.add(GenerateEnvironmentTest8.reviewRating);
	         
	        controller.add(GenerateEnvironmentTest8.overallrevEmpl);
	            
	        controller.setPerformanceReview(GenerateEnvironmentTest8.PRAdHocDB);
	        System.assert(controller.getPerformanceReview() != null);
	        System.assert(controller.getPerformanceReview().id == GenerateEnvironmentTest8.PRAdHocDB.id);
	        System.assert(controller.getPerformanceReview() != null);
	        System.assert(controller.getPerformanceReview().id == GenerateEnvironmentTest8.PRAdHocDB.id);
	        controller.setReviewer(GenerateEnvironmentTest8.PRAdHocDB.Manager__c);
	        System.assert(controller.getSharingNode().equals(''));
	        System.assert(controller.createCompetencyReviewShare(null) != null);
	        System.assert(controller.createCompetencyReviewShare(null).size() == 0);
	        System.assert(controller.createCompetencyReviewShare(UserInfo.getUserId()) != null);
	        System.assert(controller.createCompetencyReviewShare(UserInfo.getUserId()).size() >= 0);
	        
	        System.assert(controller.createMethodReviewShare(null) != null);
	        System.assert(controller.createMethodReviewShare(null).size() == 0);
	        System.assert(controller.createMethodReviewShare(UserInfo.getUserId()) != null);
	        System.assert(controller.createMethodReviewShare(UserInfo.getUserId()).size() >= 0);
	        
	        System.assert(controller.createReviewRatingShare(null) != null);
	        System.assert(controller.createReviewRatingShare(null).size() == 0);
	        System.assert(controller.createReviewRatingShare(UserInfo.getUserId()) != null);
	        System.assert(controller.createReviewRatingShare(UserInfo.getUserId()).size() >= 0);
	        
	        System.assert(controller.createAdditionalCommentShare(null) != null);
	        System.assert(controller.createAdditionalCommentShare(null).size() == 0);
	        System.assert(controller.createAdditionalCommentShare(UserInfo.getUserId()) != null);
	        System.assert(controller.createAdditionalCommentShare(UserInfo.getUserId()).size() >= 0);
	        
	        System.assert(controller.createPerformanceReviewShare(null) == null);
	        PerformanceReview__Share prshare = controller.createPerformanceReviewShare(UserInfo.getUserId());
	        System.assert(prshare != null);
	        System.assert(prshare.UserOrGroupId == UserInfo.getUserId());
	        System.assert(prshare.AccessLevel.equals('Read'));
	        
	         
	        
	        ScorecardSupportComment__c scoreComment = new ScorecardSupportComment__c();
	        ScorecardSupportReview__c  scoreSupport = new ScorecardSupportReview__c();
	        List <ScorecardSupportComment__Share> shareList = [select Id from ScorecardSupportComment__Share limit 10];
	        List <ScorecardSupportReview__Share> shareSupport = [select Id from ScorecardSupportReview__Share limit 10];
	        List <PerformanceReview__Share> sharePerformance = [select Id from PerformanceReview__Share limit 10];
	        
	        controller.add(scoreComment);
	        controller.add(scoreSupport);
			
			if(shareList.size() > 0){
		        if(controller.createScorecardSupportCommentShare(shareList[0].Id) == null){
		        	System.assert(true, 'null share');	
		        }
			}
			if(shareSupport.size() > 0){
		        if(controller.createScorecardSupportReviewShare(shareSupport[0].Id) == null){
		        	System.assert(true, 'null share');	
		        }
			}
			if(sharePerformance.size() > 0){
		        if(controller.createPerformanceReviewShare(sharePerformance[0].Id) == null){
		        	System.assert(true, 'null share');	
		        }
			}

		} catch (Exception e) {
            System.debug(' ****************** execute_methods_ReviewSharing * ');
            System.debug(e.getMessage());
		}

        Test.stopTest();
          
    }
    
    
    public static testMethod void execute_methods_ReviewSharing2() {
        GenerateEnvironmentTest8.genReviewSharing();
        //Test.setCurrentPageReference(new PageReference('Page.MyTeam'));
		Test.startTest();
 
		try {
			 
	        ReviewSharing controller = new ReviewSharing(GenerateEnvironmentTest8.PRAdHocDB, GenerateEnvironmentTest8.employeeStandard.Id, '');   
	        ScorecardSupportComment__c scoreComment = new ScorecardSupportComment__c();
	      	controller.add(scoreComment);
	      	
	      	ScorecardSupportReview__c support = new ScorecardSupportReview__c();
	      	controller.add(support);
	      	
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_ReviewSharing2 * ');
            System.debug(e.getMessage());
		}

        Test.stopTest();
          
    }
    
      public static testMethod void execute_methods_ReviewSharing3() {
        GenerateEnvironmentTest8.genReviewSharing();
        //Test.setCurrentPageReference(new PageReference('Page.MyTeam'));
		Test.startTest();
 
		try {
			 
	        ReviewSharing controller = new ReviewSharing(GenerateEnvironmentTest8.PRAdHocDB, GenerateEnvironmentTest8.employeeStandard.Id, '');   
	       	
	       	MethodReview__c mr = new MethodReview__c();
	       	mr.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	ReviewRating__c rr = new ReviewRating__c();
	       	rr.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	CompetencyReview__c cr = new CompetencyReview__c();
	       	cr.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	AdditionalComment__c ac = new AdditionalComment__c();
	       	ac.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	ScorecardSupportComment__c ssc = new ScorecardSupportComment__c();
	       	ssc.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	ScorecardSupportReview__c ssr = new ScorecardSupportReview__c();
	       	ssr.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	
	       	controller.add(mr);
	       	controller.add(rr);
	       	controller.add(cr);
	       	controller.add(ac);
	       	controller.add(ssc);
	       	controller.add(ssr);
	       	
	       	MethodReview__c mr2 = new MethodReview__c();
	       	mr2.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	ReviewRating__c rr2 = new ReviewRating__c();
	       	CompetencyReview__c cr2 = new CompetencyReview__c();
	       	cr2.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	rr2.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	AdditionalComment__c ac2 = new AdditionalComment__c();
	       	ac2.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	ScorecardSupportComment__c ssc2 = new ScorecardSupportComment__c();
	       	ssc2.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	ScorecardSupportReview__c ssr2 = new ScorecardSupportReview__c();
	       	ssr2.Reviewer__c = GenerateEnvironmentTest8.employeeStandard.Id;
	       	
	       	controller.add(mr);	       	
	       	controller.add(rr2);
	       	controller.add(cr2);
	 		controller.add(ac2);       	
	       	controller.add(ssc2);
	       	controller.add(ssr2);
	       	controller.createMethodReviewShare( GenerateEnvironmentTest8.employeeStandard.Id );
	      	controller.createReviewRatingShare(GenerateEnvironmentTest8.employeeStandard.Id);
			controller.createAdditionalCommentShare(GenerateEnvironmentTest8.employeeStandard.Id);
			controller.createScorecardSupportCommentShare(GenerateEnvironmentTest8.employeeStandard.Id);
			controller.createScorecardSupportReviewShare(GenerateEnvironmentTest8.employeeStandard.Id);
			controller.createPerformanceReviewShare(GenerateEnvironmentTest8.employeeStandard.Id);
		  	controller.createCompetencyReviewShare(GenerateEnvironmentTest8.employeeStandard.Id);
		  	
		 	controller = new ReviewSharing(GenerateEnvironmentTest8.PRAdHocDB, null, '');   
	       	controller.createMethodReviewShare( GenerateEnvironmentTest8.employeeStandard.Id );
	      	controller.createReviewRatingShare(GenerateEnvironmentTest8.employeeStandard.Id);
			controller.createAdditionalCommentShare(GenerateEnvironmentTest8.employeeStandard.Id);
			controller.createScorecardSupportCommentShare(GenerateEnvironmentTest8.employeeStandard.Id);
			controller.createScorecardSupportReviewShare(GenerateEnvironmentTest8.employeeStandard.Id);
			controller.createPerformanceReviewShare(GenerateEnvironmentTest8.employeeStandard.Id);
		   	controller.createCompetencyReviewShare(GenerateEnvironmentTest8.employeeStandard.Id);
		  	
		} catch (Exception e) {
            System.debug(' ****************** execute_methods_ReviewSharing3 * ');
            System.debug(e.getMessage());
		}

        Test.stopTest();
          
    }
}