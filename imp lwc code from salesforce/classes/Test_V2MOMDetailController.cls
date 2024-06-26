@isTest private class Test_V2MOMDetailController {
	 
	public static testMethod void execute_methods_V2MOMEdit() {
		
		try{
			GenerateEnvironmentTest.createV2MOMDetailController();	
		}catch(Exception e){}
		
		   
 		 
			try{
				GenerateEnvironmentTest.v2momIndividual.Locked__c = false;
				update GenerateEnvironmentTest.v2momIndividual;
			
				GenerateEnvironmentTest.v2momDepartment.Locked__c = false;
				update GenerateEnvironmentTest.v2momDepartment;	
			}catch(Exception e){
				
			}
			
  
		 
		Test.startTest();
		
			Test.setCurrentPageReference(new PageReference('Page.V2MOMEdit'));
			
			try{
				ApexPages.StandardController stdc = new ApexPages.StandardController( GenerateEnvironmentTest.v2momIndividual);
				System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.Id );
				V2MOMDetailController controller = new V2MOMDetailController(stdc);
				controller.getV2MOMTypes();
				ApexPages.StandardController st = new ApexPages.StandardController(GenerateEnvironmentTest.v2momDepartment);
				System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momDepartment.Id);
				controller = new V2MOMDetailController(st);
				controller.getV2MOMTypes();
			}catch(Exception e){
				
			}
				
			
				
			
			
			
			                      
		                  
			List<V2MOM__c> v2momListSupport = [select name, Share_With__c , OwnerId, status__c, v2mom_Type__c, Effective_Date__c, 
			                    Owner.Name, CreatedBy.Name, CreatedById, LastModifiedBy.Name, CreatedDate,LastModifiedDate,
			                     locked__c , IsLocked, Date_Approved__c, Date_Submitted__c ,  Vision__c, 
			                     (Select Id, Status,CreatedBy.Name From ProcessInstances order by CreatedDate DESC),
			                     
			                     (Select Id, ProcessInstanceId, StepStatus, CreatedDate, Comments, CreatedBy.Name, OriginalActor.Name, Actor.Name, Actor.Id From ProcessSteps 
			                                          order by StepStatus)
			                                        
			                      from V2MOM__c where locked__c = false and Owner.Profile.Name = 'Support Employee' limit 1];
			                      
			                      
			List<V2MOM__c> v2momListAdHoc = [select name, Share_With__c , OwnerId, status__c, v2mom_Type__c, Effective_Date__c, 
			                    Owner.Name, CreatedBy.Name, CreatedById, LastModifiedBy.Name, CreatedDate,LastModifiedDate,
			                     locked__c , IsLocked, Date_Approved__c, Date_Submitted__c ,  Vision__c, 
			                     (Select Id, Status,CreatedBy.Name From ProcessInstances order by CreatedDate DESC),
			                     
			                     (Select Id, ProcessInstanceId, StepStatus, CreatedDate, Comments, CreatedBy.Name, OriginalActor.Name, Actor.Name, Actor.Id From ProcessSteps 
			                                          order by StepStatus)
			                                        
			                      from V2MOM__c where locked__c = false and v2mom_type__c = 'Ad Hoc' limit 1];
			
			
			
			 if (v2momListSupport.size() > 0 ) {
	 			ApexPages.StandardController stdct = new ApexPages.StandardController( v2momListSupport[0]);
				System.currentPageReference().getParameters().put('id', v2momListSupport[0].Id );
				V2MOMDetailController controllerr = new V2MOMDetailController(stdct);
				controllerr.getV2MOMTypes();
			 }
			                     
			
			 if (v2momListAdHoc.size() > 0 ) {
	 			ApexPages.StandardController sst = new ApexPages.StandardController(v2momListAdHoc[0]);
				System.currentPageReference().getParameters().put('id', v2momListAdHoc[0].Id );
				V2MOMDetailController controllert = new V2MOMDetailController(sst);
				controllert.getV2MOMTypes();
			 }
			 
			

		
				
		Test.stopTest();		
	}
	
	public static testMethod void execute_methods_V2MOMEdit2 () {
		V2MOM__c v2mom;
		
	
			List<V2MOM__c> v2momList =  [select name, Share_With__c , OwnerId, status__c, v2mom_Type__c, Effective_Date__c, 
			                    Owner.Name, CreatedBy.Name, CreatedById, LastModifiedBy.Name, CreatedDate,LastModifiedDate,
			                     locked__c , IsLocked, Date_Approved__c, Date_Submitted__c ,  Vision__c, 
			                     (Select Id, Status,CreatedBy.Name From ProcessInstances order by CreatedDate DESC),
			                     
			                     (Select Id, ProcessInstanceId, StepStatus, CreatedDate, Comments, CreatedBy.Name, OriginalActor.Name, Actor.Name, Actor.Id From ProcessSteps 
			                                          order by StepStatus)
			                                        
			                      from V2MOM__c where locked__c = false and Owner.IsActive =  true limit 100];
			                      
			 
			 Boolean found = false;
	 		 
			 for (V2MOM__c currentV2mom : v2momList) {
			 	List<ProcessInstance> prs = currentV2mom.ProcessInstances;
			 	
			 	if (prs.size() > 0 && !found ) {
			 		//This is the v2mom we are looking for
			 		found = true ;
			 		v2mom = currentV2mom;
			 	}
			 }
			 
			 if (v2mom == null)
			 {
			 	v2mom = v2momList[0];
			 	
			 }
		

			User u = [select Id From User where id =: v2mom.OwnerId];
	
			System.runAs(u) {
				Test.startTest();
				
					ApexPages.StandardController std = new ApexPages.StandardController(v2mom);
		
					System.currentPageReference().getParameters().put('id', v2mom.Id);
					
					V2MOMDetailController controller = new V2MOMDetailController(std);
				
					
					controller.getV2MOMTypes();
					controller.getIsSysAdminProfile();
					controller.getIsManager();
					controller.getIsManagerOrSysAdmin();
					controller.EditMode();
					controller.getCreatedDate();
					controller.Save();
					
				
					controller.GoToSavePage();
					controller.Cancel();
					controller.getIsEditMode();
					controller.getWorkItemId();
					controller.getShowRecallButton();
					controller.getShowSubmitButton();
					controller.IsRecalled();
					controller.IsPending();
					controller.IsApproved();
					controller.IsRejected();
					controller.getShortId();
					controller.getRecallId();
					controller.getHasBeenSubmited();
					controller.getV2MOM();
					controller.getProcessInstanceCustom();
					controller.getV2momId();
					controller.CheckPrivileges();
					controller.getShareIndividuals();
					controller.getV2MOMShareWith();
					controller.getXml();
					controller.getIsPendingForApproval();
					controller.getMethodsToPrioritize();
					
					
					
					controller.setMethodsToPrioritize('');
					controller.getValuesToPrioritize();
					controller.getObstaclesToPrioritize();
					controller.setObstaclesToPrioritize('');
					controller.getMetricsToPrioritize();
					controller.setMetricsToPrioritize('');
					controller.getEffectiveDates();
					controller.getThisYear();
					controller.getIsLocked();
					controller.getShowEditButton();
					controller.getModifiedDate();
					controller.FormatDate(System.now());
					controller.SaveWithPriority();
					controller.SaveAndNew();
					controller.SaveAndReturn();
					controller.SaveAndNewV2MOMEdit();
					controller.SaveAndReturnV2MOMEdit();
					controller.SaveV2MOMEdit();
					controller.getShowErrorName();
					controller.getShowErrorEffDate();
					controller.getShowErrorVision();
					controller.getErrName();
					controller.getErrEffDate();
					controller.getErrVision();
					controller.getShowError();
					
					controller.getRecordType();
					controller.getV2MOMRecordTypes();
					controller.getCurrentUser();
					controller.getV2MOMOwnerName();
					controller.getIsFromPR();
					controller.getIdPerformanceReview();
					controller.getShowDelete();  
					
				
					controller.getV2MOMShortId();
					controller.returnNewV2MOMTypes();
					controller.returnNewV2MOMTypesScorecard();
					
					controller.getShowDelete();	
				
					controller.getErrorText();
				//	controller.CancelV2MOMEdit();
					
					List<V2MOMDetailController.ProcessInstanceCustom> innerClassList = controller.getProcessInstanceCustom();
					
					if (innerClassList.size() > 0) {
						V2MOMDetailController.ProcessInstanceCustom innerClass = innerClassList[0];	
						
						innerClass.getStatus();
						
						innerClass.getProcessHistory();
						innerClass.getProcessInstance();
						innerClass.setStatus('Test');
						
						List<V2MOMDetailController.ProcessInstanceHistoryCustom> innerProccessHistoryList = innerClass.getProcessHistory();
						innerProccessHistoryList[0].getIsSubmitedStatus();
						
						
						if (innerProccessHistoryList.size() > 0) {
							innerProccessHistoryList[0].getProcessInstanceHistory();
							innerProccessHistoryList[0].getIsSubmitedStatus();
							
							innerProccessHistoryList[0].getIsRecalledStatus();
							innerProccessHistoryList[0].getIsPendingStatus();
							innerProccessHistoryList[0].getIsSysAdminProfile();
							innerProccessHistoryList[0].getUserCanView();
							innerProccessHistoryList[0].getIsApprovedStatus();
							innerProccessHistoryList[0].getIsRejectedStatus();
							innerProccessHistoryList[0].getStatus();
							innerProccessHistoryList[0].getCreatedDate();
							innerProccessHistoryList[0].FormatDate(System.now());
							
						}
					
					
			
					controller.hasRigth();
					controller.getHasEditRight();
					controller.getV2MOMName();
					controller.getPage();
					controller.getIsShowSharing();
					controller.getDefaultEffectiveDate();
					DateTime now = System.now(); 
					controller.FormatDate(now);
					
				Test.stopTest();
			}
		}		                      
	}	
		
}