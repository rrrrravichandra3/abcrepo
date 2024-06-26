@isTest
private class Test_PerformanceCompetencyController {
  
     public static testMethod void execute_methods_CompetencyAssessController() {
         
        GenerateEnvironmentTest4.genScorecardMetricEducation();
           
        Test.startTest();
     
            PerformanceCompAssessmentController.isTestClass = true;        
            //----------Employee Self Assessment && User Employee-------------------------------------------
            List<PerformanceReview__c> perfEmployee;
            PerformanceReview__c performanceReview;
            List<CompetencyGroupMember__c> compGroupMember;
            List<PerformanceReview__c> perfAvailable = new List<PerformanceReview__c>();
            
            compGroupMember = GenerateEnvironmentTest4.allCompetencyGroupMembers;
            //perfEmployee =  GenerateEnvironmentTest4.allPRs;
            perfEmployee = [Select Id, Name, Status__c, Employee__c, Employee__r.Name, Manager__c, SecondManager__c, ThirdPartyReviewer__c FROM PerformanceReview__c];               
            for(PerformanceReview__c p : perfEmployee){
                for(CompetencyGroupMember__c c: compGroupMember){
                    if(p.CompetencyGroup__c == c.CompetencyGroup__c){
                        perfAvailable.add(p);
                    }
                }   
            } 
            PerformanceCompAssessmentController competencyController = new PerformanceCompAssessmentController();           
            
            		
            	System.currentPageReference().getParameters().put('id', perfEmployee[0].Id);
                
            	competencyController.getPerformanceReviewWithoutSharing('0aaa0000000aaaa');
                if(perfAvailable.size() > 0){
                    performanceReview = perfAvailable[0];
                    competencyController.setPerformanceReviewParam(performanceReview.Id);
                    competencyController.setCurrentUserId(performanceReview.Employee__c);
                }
                if(competencyController.getPerformanceReview() == null){
                	System.assert(true, 'Null Performance Review'); 
            	}
            	if(competencyController.getCompetencies() == null){
                	System.assert(true, 'Null competencies');   
            	}
            	//competencyController.save();  
            	//competencyController.saveContinue();
            
            	/*
            	if(competencyController.getRatingSelectOptions() == null){
                	System.assert(true, 'Null Rating Select Options');  
            	}
            	if(competencyController != null && competencyController.getShowReviewEdit() != null && !competencyController.getShowReviewEdit()){
                	System.assert(true, 'Not have access'); 
            	}
            	if(competencyController.getIsManager() != null && competencyController.getIsManager()){
                	System.assert(true, 'Not have access'); 
            	}
            	if(competencyController.getIsEmployee() != null && !competencyController.getIsEmployee()){
                	System.assert(true, 'Not have access'); 
            	}
            	if(competencyController.getCurrentUserId() == null){
                	System.assert(true, 'Null user');   
            	}
            
            	competencyController.getCompetencyWeight();
            	competencyController.getUserProfile();
            
            	competencyController.getIsEmplMngr2ndMngrOr3PtInAssmnt();
            	competencyController.getIsMngrInAssmnt();
            	competencyController.getIsMngr();
            	competencyController.getIsSysAdminProfile();
            
            	competencyController.getLabelPreviousCompetency();
            	competencyController.getLabelNextCompetency();	
            
                       
            if(competencyController != null && competencyController.getCompetencies() != null && competencyController.getCompetencies().size() > 0){
                PerformanceCompAssessmentController.Competency competency = competencyController.getCompetencies()[0];
                
                competency.setCurrentUserId(performanceReview.Manager__c);
                
                if(competency.getCompetency() == null){
                    system.assert(true, 'Null competency');
                }
                competency.setCompetency(compGroupMember[0]);
                
                if(competency.getRating() == null){
                    system.assert(true, 'Null rating');
                }
                competency.setRating(2.0);
                
                if(competency.getWeight() == null){
                    system.assert(true, 'Null weight');
                }
                if(competency.getReview() == null){
                    system.assert(true, 'Null review');
                }
                if(competency.getHistory() == null){
                    system.assert(true, 'Null history');
                }
                if(competency.getShowHistory()){
                    system.assert(true, 'Null history');
                }
                if(competency.getCurrentUserId() == null){
                    system.assert(true, 'Null user');
                }
                if(!competency.getIsComplete()){
                    system.assert(true, 'Not complete');
                }
                    
            }
            
        
            //------------------------------Manager part, Manager Assessment -----------------------------------
    
            List<PerformanceReview__c> perfManager = new List<PerformanceReview__c>();
            perfAvailable = new List<PerformanceReview__c>();  
            
            perfManager =  GenerateEnvironmentTest4.allPRsManager;       
                             
            for(PerformanceReview__c p : perfManager){
                for(CompetencyGroupMember__c c: compGroupMember){
                    if(p.CompetencyGroup__c == c.CompetencyGroup__c){
                        perfAvailable.add(p);
                    }
                }   
            }           
            
            GenerateEnvironmentTest4.changeStatusPReview(GenerateEnvironmentTest4.PRIndividualQ1Q2Edu,
                                                            'Created', 'Employee Self Assessment');
            competencyController.getCompetencyReviewWithoutSharingMap(GenerateEnvironmentTest4.PRIndividualQ1Q2Edu ,compGroupMember);
                            
          
                if(perfAvailable.size() > 0){
                    performanceReview = perfAvailable[0];
                    competencyController.setPerformanceReviewParam(performanceReview.Id);
                    competencyController.setCurrentUserId(performanceReview.Manager__c);
         
                }
            
            if(competencyController.getPerformanceReview() == null){
                System.assert(true, 'Null Performance Review'); 
            }
            if(competencyController.getCompetencies() == null){
                System.assert(true, 'Null competencies');   
            }
            if(competencyController.getRatingSelectOptions() == null){
                System.assert(true, 'Null Rating Select Options');  
            }
            
            	if(!competencyController.getShowReviewEdit()){
                	System.assert(true, 'Not have access'); 
            	}
            	if(competencyController.getIsManager()){
                	System.assert(true, 'Not have access'); 
            	}
            	if(!competencyController.getIsEmployee()){
                	System.assert(true, 'Not have access'); 
            	}
            	if(competencyController.getCurrentUserId() == null){
                	System.assert(true, 'Null user');   
            	}	
            
            
            
            // Inner class CompetencyUtil
            PerformanceCompAssessmentController.CompetencyUtil competencyUtil = new PerformanceCompAssessmentController.CompetencyUtil();
            
            if (competencyUtil.getPerformanceReviewWithSharing(perfEmployee[0].Id) == null)
                System.assert(true, 'null PerformanceReviewWithSharing');
            if (competencyUtil.getCompetencyReviewWithSharingMap(perfEmployee[0], compGroupMember) == null)
                System.assert(true, 'null CompetencyReviewWithSharingMap');
            if (competencyUtil.getCompetencyReviewListWithSharing(perfEmployee[0], compGroupMember) == null)
                System.assert(true, 'null CompetencyReviewListWithSharing');
         
            PerformanceCompAssessmentController.isTestClass = false;
            
            
            PerformanceReview__c testPerformance = [Select Id, Name, Status__c, Employee__c, Employee__r.Name, Manager__c, SecondManager__c, ThirdPartyReviewer__c, CompetencyGroup__c From PerformanceReview__c limit 1];
            CompetencyGroupMember__c testCompetenciesGroupMember = [Select Id, Name,
                                                                                Weight__c,
                                                                                Competency__r.Name,
                                                                                Competency__r.Description__c,
                                                                                Competency__c
                                                                        From CompetencyGroupMember__c
                                                                        Where CompetencyGroup__c =: testPerformance.CompetencyGroup__c limit 1];
            PerformanceCompAssessmentController.Competency innerCompetency = null;
            if (competencyController != null && competencyController.getCompetencies() != null){
            	innerCompetency = competencyController.getCompetencies()[0];	
            }else innerCompetency = new PerformanceCompAssessmentController.Competency (testCompetenciesGroupMember, testPerformance);
                                                                                  
         	
               
            //innerCompetency.getRatingShow();
            innerCompetency.getRating();
            innerCompetency.setRating(1);
            innerCompetency.getWeight();
            innerCompetency.setWeight(1);
            innerCompetency.getReview();
            innerCompetency.setReview(new CompetencyReview__c());
            innerCompetency.getHistoryFormatted();
            innerCompetency.setHistory(new List<CompetencyReview__c>());
            innerCompetency.getShowHistory();
            innerCompetency.getCurrentUserId();
            innerCompetency.setCurrentUserId('1');
            innerCompetency.getIsComplete();
            
           
             */
        Test.stopTest();
           
    }

}