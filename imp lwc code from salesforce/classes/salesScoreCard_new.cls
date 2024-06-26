public with sharing class salesScoreCard_new {

	public Id prId {get{return apexPages.currentPage().getParameters().get('prId');}set;}
	private String managerRating{get; set;} 
	private Map<String,String> tempMap = new Map<String,String>();
	public List<qualitativeMeasurements> qualitativeMeasurementList {
		get{
			if(qualitativeMeasurementList==null){
			
			//Get the user of the performance review
			User tempUser = getCurrentUser();
			set<string> actorsSet = new Set<string>{tempUser.Id,tempUser.ReviewManager__c};
			
			//Get the performance review with the salesScorecard
			String currentReviewId = currentReviewHolder.Id;
			
			noSharingMethods = new salesUtils();
			noSharingMethods.setCompetencyReviewMap(prId);
			salesUtils aux = new salesUtils();
			qualitativeMeasurementList = new List<qualitativeMeasurements>();
			qualitativeMeasurements qualitativeMeasureItem = new qualitativeMeasurements();
			List<CompetencyGroupMember__c> compGroupMembers = [select m.Weight__c, 
														  m.Competency__r.Name, 
														  m.Competency__r.Description__c, 
														  m.Competency__c,
														  (Select Id, 
														  		  Rating__c,
														  		  Comment__c, 
														  		  Reviewer__r.name,
														  		  Reviewer__c 
														   From  R00N700000027PLREA2 
														   Where Reviewer__c in :actorsSet 
														   AND   performanceReview__c =:currentReviewId limit 5) 
												   From CompetencyGroupMember__c m 
												   Where m.CompetencyGroup__c =: currentReviewHolder.CompetencyGroup__c Order By m.Competency__r.Name limit 5];
			//R00N700000027PLREA2 is the CompetencyReview object
			for(CompetencyGroupMember__c cgMember : compGroupMembers){
				
				qualitativeMeasureItem = new qualitativeMeasurements();
				qualitativeMeasureItem.compGMember = cgMember.Id;
				qualitativeMeasureItem.competency = cgMember.Competency__r;
				
				for(CompetencyReview__c creview:cgMember.R00N700000027PLREA2){
										
					if(creview.Reviewer__c==tempUser.Id){
						qualitativeMeasureItem.employeeComment = creview;
						qualitativeMeasureItem.isEmployeeComment = noSharingMethods.existReview(creview.Reviewer__c, cgMember.Id);
						
					}else if(creview.Reviewer__c==tempUser.ReviewManager__c){
						qualitativeMeasureItem.managerComment = creview;
						qualitativeMeasureItem.isManagerComment = noSharingMethods.existReview(creview.Reviewer__c, cgMember.Id);
					}
				}
				qualitativeMeasurementList.add(qualitativeMeasureItem);
			}
		}
		return qualitativeMeasurementList;}
	set;}
	public salesUtils noSharingMethods {get;set;}
	public Boolean doAction {get;set;}
	public Boolean isTest {get;set;}
	public String actualStatus	{get;set;}
	public Boolean isSaving {get;set;} //Used to display a message when users save changes.
	public Boolean isSubmitting {get;set;} //Used to display a message when users submmit the sales scorecard.
	public salesScoreCard_new(){
		
	}
	public salesScorecard__c currentScoreCard {get;set;}
	public salesScorecard__c getScorecard(){
		if(currentScoreCard==null){
			if(currentReviewHolder.salesScorecard__r.size() > 0){
				currentScoreCard = currentReviewHolder.salesScorecard__r[0];
				managerRating = currentScoreCard.managerOverallRating__c;
			}
		}
		return currentScoreCard;
	}
	
	public void test(){
		isTest = true;
	}

	public boolean getShowAssessmentCompleted(){
		return (getIsStatusManagerAssess() && getIsManager());
		
	}
	
	//Return the user of the Performance Review
	public User getCurrentUser(){
		//return [Select id,name,title,division,manager__r.name,CompetencyGroupCode__c  from User where id in (Select employee__c From PerformanceReview__c where id=:prId)];
		return [Select id,name,title,division, Manager__c, ReviewManager__r.name,Profile.Id, CompetencyGroupCode__c,salesEmployee__c from User u where id in (Select employee__c From PerformanceReview__c where id=:prId)];
	}
	public boolean getHasValues(){
		return quantitativeMeasureList.size()!=0;
	}
	
	public PerformanceReview__c currentReviewHolder {
		get{
			if(currentReviewHolder==null){
				//currentReviewHolder = [Select name,LastModifiedById,performancereviewperiod__r.name,status__c,(Select id,comment__c from calibrationComments__r),employee__c,PreviousStatus__c,rating__c,(Select s.quantitativeMeasureRating__c, s.rating__c, s.ramp__c, s.qualitativeMeasureRating__c, s.qualitative_MeasurementsSelfRating__c, s.prev_quota__c, s.accomplishmentComment__c, s.remainderComment__c, s.prev_newBussinesCloseRate__c, s.prev_attainment__c, s.prev_aePipelineGeneration__c, s.prev_addBussinesCloseRate__c, s.prev_acvNewBussines__c, s.prev_TotalCloseRate__c, s.prev_ServiceCloudBalance__c, s.prev_SalesCloudBalance__c, s.prev_CustomCloudBalance__c, s.prev_ACVAttainment__c, s.performanceReview__c, s.percentile_quota__c, s.percentile_newBussinesCloseRate__c, s.percentile_attainment__c, s.percentile_aePipelineGeneration__c, s.percentile_addBussinesCloseRate__c, s.percentile_acvNewBussines__c, s.percentile_TotalCloseRate__c, s.percentile_ServiceCloudBalance__c, s.percentile_SalesCloudBalance__c, s.percentile_CustomCloudBalance__c, s.percentile_ACVAttainment__c, s.hiringPlanEmployeeRating__c, s.hiringPlanManagerRating__c , s.developTalentEmployeeRating__c, s.developTalentManagerRating__c, s.overallPerformancePreviousPeriodRating__c, s.overallRating__c, s.overall_QuantitativeManagerComment__c, s.overall_QuantitativeManagerRating__c , s.employeeOverallRating__c, s.managerOverallRating__c, s.current_quota__c, s.current_newBussinesCloseRate__c, s.current_attainment__c, s.current_aePipelineGeneration__c, s.current_addBussinesCloseRate__c, s.current_acvNewBussines__c, s.current_TotalCloseRate__c, s.current_ServiceCloudBalance__c, s.current_SalesCloudBalance__c, s.current_CustomCloudBalance__c, s.current_ACVAttainment__c, s.calibrationComments__c, s.SystemModstamp, s.Name, s.MayEdit, s.LastModifiedDate, s.LastModifiedById, s.IsLocked, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.quantitativeSelfRating__c ,s.quantitativeSelfComment__c, s.offRamp__c From salesScorecard__r s limit 1) From PerformanceReview__c where id=:prId];
				//currentReviewHolder = [Select name,LastModifiedById,performancereviewperiod__r.name,status__c,employee__c,Employee__r.Name, PreviousStatus__c,rating__c,EmailComment__c,(Select s.quantitativeMeasureRating__c, s.rating__c, s.ramp__c, s.qualitativeMeasureRating__c, s.qualitative_MeasurementsSelfRating__c, s.prev_quota__c, s.accomplishmentComment__c, s.remainderComment__c, s.prev_newBussinesCloseRate__c, s.prev_attainment__c, s.prev_aePipelineGeneration__c, s.prev_addBussinesCloseRate__c, s.prev_acvNewBussines__c, s.prev_TotalCloseRate__c, s.prev_ServiceCloudBalance__c, s.prev_SalesCloudBalance__c, s.prev_CustomCloudBalance__c, s.prev_ACVAttainment__c, s.performanceReview__c, s.percentile_quota__c, s.percentile_newBussinesCloseRate__c, s.percentile_attainment__c, s.percentile_aePipelineGeneration__c, s.percentile_addBussinesCloseRate__c, s.percentile_acvNewBussines__c, s.percentile_TotalCloseRate__c, s.percentile_ServiceCloudBalance__c, s.percentile_SalesCloudBalance__c, s.percentile_CustomCloudBalance__c, s.percentile_ACVAttainment__c, s.hiringPlanEmployeeRating__c, s.hiringPlanManagerRating__c , s.developTalentEmployeeRating__c, s.developTalentManagerRating__c, s.overallPerformancePreviousPeriodRating__c, s.overallRating__c, s.overall_QuantitativeManagerComment__c, s.overall_QuantitativeManagerRating__c , s.employeeOverallRating__c, s.managerOverallRating__c, s.current_quota__c, s.current_newBussinesCloseRate__c, s.current_attainment__c, s.current_aePipelineGeneration__c, s.current_addBussinesCloseRate__c, s.current_acvNewBussines__c, s.current_TotalCloseRate__c, s.current_ServiceCloudBalance__c, s.current_SalesCloudBalance__c, s.current_CustomCloudBalance__c, s.current_ACVAttainment__c, s.calibrationComments__c, s.SystemModstamp, s.Name, s.MayEdit, s.LastModifiedDate, s.LastModifiedById, s.IsLocked, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.quantitativeSelfRating__c ,s.quantitativeSelfComment__c, s.offRamp__c From salesScorecard__r s limit 1) From PerformanceReview__c where id=:prId];
				
				
				currentReviewHolder = [Select name,
											  performancereviewperiod__r.name,
											  employee__c,
											  Employee__r.Name,
											  Manager__c, 
											  EmailComment__c,
											  LastModifiedById,
											  PreviousStatus__c, CompetencyGroup__c,
											  rating__c, status__c,
											 (Select s.Id, s.Name, s.rating__c,							  					       
						  					        s.accomplishmentComment__c, 
						  					        s.calibrationComments__c, 
						  					        s.employeeOverallRating__c, 
						  					        s.hiringPlanEmployeeRating__c, 
						  					        s.hiringPlanManagerRating__c , 
						  					        s.developTalentEmployeeRating__c, 
						  					        s.developTalentManagerRating__c, 
						  					        s.managerOverallRating__c,s.RetentionRisk__c, 
					  					        	s.offRamp__c,s.HighPotencial__c, s.ManagerOverallFinalRating__c,	
					  					        	s.overallPerformancePreviousPeriodRating__c, 
					  					        	s.overallRating__c, s.KeyRoleIncumbent__c, 
						  					        s.overall_QuantitativeManagerComment__c, 
						  					        s.overall_QuantitativeManagerRating__c , 
						  					        s.qualitativeMeasureRating__c, 
						  					        s.qualitative_MeasurementsSelfRating__c, 
						  					        s.quantitativeMeasureRating__c,
						  					        s.quantitativeSelfRating__c ,
						  					        s.quantitativeSelfComment__c, 
						  					        s.performanceReview__c, 
						  					        s.remainderComment__c 
											  From salesScorecard__r s limit 1) 
										From PerformanceReview__c where id=:prId];
			}

			
			return currentReviewHolder;}set;}  
	
	public PerformanceReview__c getcurrentReview(){
		if(currentReviewHolder==null){
			//currentReviewHolder = [Select name,LastModifiedById,performancereviewperiod__r.name,status__c,(Select id,comment__c from calibrationComments__r),employee__c,PreviousStatus__c,rating__c,(Select s.quantitativeMeasureRating__c, s.rating__c, s.ramp__c, s.qualitativeMeasureRating__c, s.qualitative_MeasurementsSelfRating__c, s.prev_quota__c, s.accomplishmentComment__c, s.remainderComment__c, s.prev_newBussinesCloseRate__c, s.prev_attainment__c, s.prev_aePipelineGeneration__c, s.prev_addBussinesCloseRate__c, s.prev_acvNewBussines__c, s.prev_TotalCloseRate__c, s.prev_ServiceCloudBalance__c, s.prev_SalesCloudBalance__c, s.prev_CustomCloudBalance__c, s.prev_ACVAttainment__c, s.performanceReview__c, s.percentile_quota__c, s.percentile_newBussinesCloseRate__c, s.percentile_attainment__c, s.percentile_aePipelineGeneration__c, s.percentile_addBussinesCloseRate__c, s.percentile_acvNewBussines__c, s.percentile_TotalCloseRate__c, s.percentile_ServiceCloudBalance__c, s.percentile_SalesCloudBalance__c, s.percentile_CustomCloudBalance__c, s.percentile_ACVAttainment__c, s.hiringPlanEmployeeRating__c, s.hiringPlanManagerRating__c , s.developTalentEmployeeRating__c, s.developTalentManagerRating__c, s.overallPerformancePreviousPeriodRating__c, s.overallRating__c, s.overall_QuantitativeManagerComment__c, s.overall_QuantitativeManagerRating__c , s.employeeOverallRating__c, s.managerOverallRating__c, s.current_quota__c, s.current_newBussinesCloseRate__c, s.current_attainment__c, s.current_aePipelineGeneration__c, s.current_addBussinesCloseRate__c, s.current_acvNewBussines__c, s.current_TotalCloseRate__c, s.current_ServiceCloudBalance__c, s.current_SalesCloudBalance__c, s.current_CustomCloudBalance__c, s.current_ACVAttainment__c, s.calibrationComments__c, s.SystemModstamp, s.Name, s.MayEdit, s.LastModifiedDate, s.LastModifiedById, s.IsLocked, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.quantitativeSelfRating__c ,s.quantitativeSelfComment__c, s.offRamp__c From salesScorecard__r s limit 1) From PerformanceReview__c where id=:prId];
			//currentReviewHolder = [Select name,LastModifiedById,performancereviewperiod__r.name,status__c,employee__c,Employee__r.Name, PreviousStatus__c,rating__c,EmailComment__c,(Select s.quantitativeMeasureRating__c, s.rating__c, s.ramp__c, s.qualitativeMeasureRating__c, s.qualitative_MeasurementsSelfRating__c, s.prev_quota__c, s.accomplishmentComment__c, s.remainderComment__c, s.prev_newBussinesCloseRate__c, s.prev_attainment__c, s.prev_aePipelineGeneration__c, s.prev_addBussinesCloseRate__c, s.prev_acvNewBussines__c, s.prev_TotalCloseRate__c, s.prev_ServiceCloudBalance__c, s.prev_SalesCloudBalance__c, s.prev_CustomCloudBalance__c, s.prev_ACVAttainment__c, s.performanceReview__c, s.percentile_quota__c, s.percentile_newBussinesCloseRate__c, s.percentile_attainment__c, s.percentile_aePipelineGeneration__c, s.percentile_addBussinesCloseRate__c, s.percentile_acvNewBussines__c, s.percentile_TotalCloseRate__c, s.percentile_ServiceCloudBalance__c, s.percentile_SalesCloudBalance__c, s.percentile_CustomCloudBalance__c, s.percentile_ACVAttainment__c, s.hiringPlanEmployeeRating__c, s.hiringPlanManagerRating__c , s.developTalentEmployeeRating__c, s.developTalentManagerRating__c, s.overallPerformancePreviousPeriodRating__c, s.overallRating__c, s.overall_QuantitativeManagerComment__c, s.overall_QuantitativeManagerRating__c , s.employeeOverallRating__c, s.managerOverallRating__c, s.current_quota__c, s.current_newBussinesCloseRate__c, s.current_attainment__c, s.current_aePipelineGeneration__c, s.current_addBussinesCloseRate__c, s.current_acvNewBussines__c, s.current_TotalCloseRate__c, s.current_ServiceCloudBalance__c, s.current_SalesCloudBalance__c, s.current_CustomCloudBalance__c, s.current_ACVAttainment__c, s.calibrationComments__c, s.SystemModstamp, s.Name, s.MayEdit, s.LastModifiedDate, s.LastModifiedById, s.IsLocked, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.quantitativeSelfRating__c ,s.quantitativeSelfComment__c, s.offRamp__c From salesScorecard__r s limit 1) From PerformanceReview__c where id=:prId];
			
			
			currentReviewHolder = [Select name,
										  performancereviewperiod__r.name,
										  employee__c,
										  Employee__r.Name,
										  Manager__c, 
										  EmailComment__c,
										  LastModifiedById,
										  PreviousStatus__c,
										  rating__c, status__c,
										 (Select s.Id, s.Name, s.rating__c,							  					       
					  					        s.accomplishmentComment__c, 
					  					        s.calibrationComments__c, 
					  					        s.employeeOverallRating__c, 
					  					        s.hiringPlanEmployeeRating__c, 
					  					        s.hiringPlanManagerRating__c , 
					  					        s.developTalentEmployeeRating__c, 
					  					        s.developTalentManagerRating__c, 
					  					        s.managerOverallRating__c,s.RetentionRisk__c, 
					  					        s.offRamp__c,s.HighPotencial__c, s.ManagerOverallFinalRating__c,	 
					  					        s.overallPerformancePreviousPeriodRating__c, 
					  					        s.overallRating__c, s.KeyRoleIncumbent__c,
					  					        s.overall_QuantitativeManagerComment__c, 
					  					        s.overall_QuantitativeManagerRating__c , 
					  					        s.qualitativeMeasureRating__c, 
					  					        s.qualitative_MeasurementsSelfRating__c, 
					  					        s.quantitativeMeasureRating__c,
					  					        s.quantitativeSelfRating__c ,
					  					        s.quantitativeSelfComment__c, 
					  					        s.performanceReview__c, 
					  					        s.remainderComment__c 
										  From salesScorecard__r s limit 1) 
									From PerformanceReview__c where id=:prId];
		}
		actualStatus = currentReviewHolder.Status__c;
		return currentReviewHolder;
	}
	
	public List<Quantitative_Measure_Value__c> quantitativeMeasureList{
		get{
			if(quantitativeMeasureList==null){
				quantitativeMeasureList = [Select q.x76_Percentile_Value__c, 
												q.Quantitative_Measure__r.category__c, 
												q.Quantitative_Measure__r.Name, 
												q.Quantitative_Measure__c, 
												q.Previous_Value__c, 
												q.Performance_Review__c, 
												q.Name, 
												q.Actual_Value__c 
											From Quantitative_Measure_Value__c q
											Where q.Performance_Review__c=:prId
											Order by q.Quantitative_Measure__r.position__c ];
			}
			return quantitativeMeasureList;
		}set;
	}
	
	public list<ratingOption> getRatingPicklist(){
		list<ratingOption> optionList = new list<ratingOption>();
		optionList.add(new ratingOption(null,'--None--'));
		optionList.add(new ratingOption(double.valueOf('0'),'0 - Too New To Rate'));
		optionList.add(new ratingOption(double.valueOf('1'),'1 - Unsatisfactory'));
		optionList.add(new ratingOption(double.valueOf('2'),'2 - Improvement Desired'));
		optionList.add(new ratingOption(double.valueOf('3'),'3 - Meets Expectations'));
		optionList.add(new ratingOption(double.valueOf('4'),'4 - Exceeds Expectations'));
		optionList.add(new ratingOption(double.valueOf('5'),'5 - Exceptional'));
		optionList.add(new ratingOption(double.valueOf('-1'),'N/A'));
		
		return optionList;
	}

	/*
	Return true if the user of the current review is
	a Manager and is also Sales Employee. (Manager ScoreCard)
	This is used to see the Team Management Section
	*/
	public Boolean getIsRevUsrManagerAndSalesEmp() {
		Profile p = [Select id,name From Profile Where Name=:'Manager'];
		
		if(getCurrentUser().Profile.Id == p.Id){
			return true;
		}
		return false;
	}
	/*
	Returns true if  the employee of the performance review has Manager Profile.
	*/
	public boolean getIsEmployee_Manager(){
		PerformanceReview__c perf = currentReviewHolder;
		String empId = perf.Employee__c;
		Profile p = [Select id, name From Profile Where Name =: 'Manager'];
		User reviewEmployee = [Select u.Id, u.ProfileId From User u Where u.Id =: empId];
		return p.id == reviewEmployee.ProfileId;		
	}
	
	/*
	Returns true if the logged user is the employee of the performance review.
	*/
	public Boolean getIsEmployee(){
		return (UserInfo.getUserId()==getCurrentUser().Id);
	}
	/* 
	Returns true if the logged user is Sys Admin OR ESBP and NOT Employee or Manager of the review at the same time
	*/
	public boolean getEmployeeSuccessCanEditComments(){
		return getIsAdminOrEmployeeSuccess() && (!getIsManager() && !getIsEmployee());
	}
	/*
	Returns true if the logged user is the manager of the performance review.
	*/
	public Boolean getIsManager(){
		//return (UserInfo.getUserId()==getCurrentUser().Manager__c);
		return (UserInfo.getUserId()==getCurrentUser().ReviewManager__c);
	}
	
	public Boolean getIsAdmin(){
		Profile p = [Select id, name From Profile Where Name =: Label.System_Administrator_label]; 
		Profile systemAdmin = [Select id, name From Profile Where Name =: 'systemadministrator'];
		return (UserInfo.getProfileId() == p.id || UserInfo.getProfileId() == systemAdmin.id); 
	}
	
	/*
	Returns true if the profile of the logged user is Employee Success - Standard w/Cases.
	*/
	public Boolean getIsEmployeeSuccessSC() {
		Profile p = [Select id,name From Profile Where Name=:'Employee Success - Standard w/ Cases'];
		return (UserInfo.getProfileId()==p.id); 
	}
	
	/*
	Returns true if the profile of the logged user is Employee Success/Business Partner.
	*/
	public Boolean getIsESBP(){
		Profile p = [Select id,name From Profile Where Name=:'Employee Success/Business Partner'];
		return (UserInfo.getProfileId()==p.id); 
	}
	/*
	Returns true if the status is manager assessment and profile is manager or system administrator; Or if completed and profile is employee, manager or system administrator
	*/
	public boolean getCanSeeManagerRatings(){
		if ( ((getIsStatusManagerAssess() || getIsStatusRating() || getIsStatusReviewDiscussion() || getIsStatusCalibration() || getIsStatusCreated() || getIsStatusEmpSelfAssess() ) && (getISAdmin() || getIsManager() || getIsESBP())) || (getIsStatusComplete() || getIsStatusEmpApp()) ){
			return true;
		}
		return false;
	} 
	
	/*
	Returns true if the profile of the logged user is a SysAdmin, Employee Success standard or Business Partner.
	*/
	public Boolean getIsAdminOrEmployeeSuccess(){
		return (getIsAdmin() || getIsEmployeeSuccessSC() || getIsESBP());
	}		

	public Map<String,String> getStatusMap(){
		
		tempMap.put('Created','Employee Self Assessment');
		tempMap.put('Employee Self Assessment','Manager Assessment');
		tempMap.put('Manager Assessment','Calibration');
		//tempMap.put('Calibration','Manager Approval');
		//Now "Manager Approval" change to "Calibration Review" status
		tempMap.put('Calibration','Calibration Review');
		//tempMap.put('Manager Approval','Employee Approval');
		//Add new Status "Review Discussion" in this status the calibration comments and pre-calibrated ratings should be hidden
		tempMap.put('Calibration Review', 'Review Discussion');
		tempMap.put('Review Discussion','Employee Approval');
		tempMap.put('Employee Approval','Complete');
		return tempMap;
	}
	
	public PageReference statusValidation(){
		getcurrentReview();
		if (this.actualStatus.equals('Created') && this.getIsEmployee()){
			PageReference ref = new PageReference('/apex/salesScoreCard_New?prId='+prId);
			ref.setRedirect(true);
			return ref;	
		}
			
		return null;
	}
	
	public String getNextStatus(){
		getStatusMap();
		String status = this.currentReviewHolder.Status__c;
		this.actualStatus = tempMap.get(status);
		return actualStatus;
	}
	
	private Map<string,Id> getPerformanceEditability(){
		 Map<string,Id> tempMap = new Map<string,Id>();
		 tempMap.put('Created',getCurrentUser().Id);
		 tempMap.put('Employee Self Assessment',getCurrentUser().Id);
		 //tempMap.put('Manager Assessment',getCurrentUser().Manager__c);
		 tempMap.put('Manager Assessment',getCurrentUser().ReviewManager__c);
		 //tempMap.put('Manager Approval',getCurrentUser().Manager__c);
		 tempMap.put('Manager Approval',getCurrentUser().ReviewManager__c);
		 tempMap.put('Calibration Review',getCurrentUser().ReviewManager__c);
		 //tempMap.put('Employee Approval',getCurrentUser().Id);
		 return tempMap;
	}
	public Boolean getRenderEditionControls(){
		Map<string,Id> statusIdMap = getPerformanceEditability();
		return (statusIdMap.get(currentReviewHolder.status__c) == UserInfo.getUserId());
	}
	
	
	/*
	Return true if the current status is Employee Self Assessment
	*/
	public Boolean getIsStatusEmpSelfAssess() {
		if(currentReviewHolder.status__c != 'Employee Self Assessment'){
			return false;
		}
		return true;
	}
	/*
	Return true if the current status is Review Discussion
	*/
	public Boolean getIsStatusReviewDiscussion(){
		return currentReviewHolder.Status__c.equals('Review Discussion');
	}
	
	public Boolean getIsStatusCalibration() {
		if(currentReviewHolder.status__c != 'Calibration'){
			return false;
		}
		return true;
	}
	/*
	Return true if the current status is Employee Approval
	*/
	public Boolean getIsStatusEmpApp() {
		if(currentReviewHolder.status__c != 'Employee Approval'){
			return false;
		}
		return true;
	}
	
	/*
	Return true if the current status is Manager Assessment
	*/
	public Boolean getIsStatusManagerAssess() {
		if(currentReviewHolder.status__c != 'Manager Assessment'){
			return false;
		}
		return true;
	}
	
	/**
	Return true if the current status is Calibration Review
	*/
	public Boolean getIsStatusRating() {
		if(currentReviewHolder.status__c != 'Calibration Review'){
			return false;
		}
		return true;
	}
	
	/**
	Return true if the current status is Complete
	*/
	public Boolean getIsStatusComplete() {	
		if(currentReviewHolder.status__c != 'Complete'){
			return false;
		}
		return true;
	}
	
	/**
	Return true if the current status is Created
	*/
	public Boolean getIsStatusCreated() {	
		if(currentReviewHolder.status__c != 'Created'){
			return false;
		}
		return true;
	}

	public PageReference reload(){
		PageReference aux = new PageReference('/apex/salesScoreCard_New?prId='+prId);
		aux.setRedirect(true);
		return aux;
	}


	public without sharing class qualitativeMeasurements{
		public Competency__c  competency {get;set;}
		public CompetencyReview__c employeeComment {get;set;}
		public CompetencyReview__c managerComment {get;set;}
		public Boolean isEmployeeComment {get;set;}
		public Boolean isManagerComment {get;set;}
		public Id compGMember {get;set;}
		
		public 	qualitativeMeasurements(){
			competency = new Competency__c();
			employeeComment = new CompetencyReview__c();
			managerComment = new CompetencyReview__c();
			isEmployeeComment = false;
			isManagerComment = false;
		}			
	}
	public class ratingOption{
		public double value {get;set;}
		public string description {get;set;}
		
		public ratingOption(Double val,String des){
			value = val;
			description = des;
		}
	}
	public without sharing class salesUtils{
		public Map<Id,List<CompetencyReview__c>> CompetencyReviewMap{get;set;}
		public salesUtils(){
			CompetencyReviewMap = new Map<Id,List<CompetencyReview__c>>();
		}
		public void setCompetencyReviewMap(Id prId){
			List<CompetencyGroupMember__c> cgmList = [Select Id ,(select cr.id,cr.Reviewer__c,cr.Reviewer__r.Name From R00N700000027PLREA2 cr Where cr.PerformanceReview__c =: prId limit 5) From CompetencyGroupMember__c where CompetencyGroup__c in (select  p.CompetencyGroup__c from PerformanceReview__c p where p.id=:prId)];
			for(CompetencyGroupMember__c cGroupMember :cgmList){
				this.CompetencyReviewMap.put(cGroupMember.Id,cGroupMember.R00N700000027PLREA2);		
			}
		}			
		public boolean existReview(Id reviewerId,Id cgm){
			boolean exist = false;
			for(CompetencyReview__c comp:this.CompetencyReviewMap.get(cgm)){
				exist = (comp.Reviewer__c == reviewerId);
			}
			return exist;
		}		
				
	}
}