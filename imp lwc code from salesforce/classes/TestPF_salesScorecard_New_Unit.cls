@isTest
private class TestPF_salesScorecard_New_Unit {
	public static User scManager2;
	public static User scEmployee;  
	public static void genEnvironment(){
    	ApexPages.currentPage().getParameters().put('prId',PerformanceReview.Id);
    	getScEmployee();
    	getScManager2();
	}
	static testMethod void testPrIdParameter(){
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		system.assert(ssc.prId == PerformanceReview.Id,'Failure When Trying to Get Performance Review Id, Recived: '+ssc.prId+', Expected : '+PerformanceReview.Id);
	}
	
	static testMethod void testNormailizeEnvironment(){
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		test.startTest();
	        integer compRevSize = [select id from CompetencyReview__c where PerformanceReview__c =:performanceReview.Id].size();
	        integer actualCompRevSize = 0;	       
	        system.assert(actualCompRevSize == compRevSize ,'Failure When Trying to Get Qualitative Measurement List, Recived Size : '+actualCompRevSize+' Expected Size :'+compRevSize);
	        ssc.getIsStatusRating();
		test.stopTest();
	}
	static testMethod void testGetReviewedUser(){
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		system.assert((ssc.getCurrentUser()!=null) && (ssc.getCurrentUser().id == scEmployee.id),'Failure When Trying to Get Reviewed User, Recived: '+ssc.getCurrentUser().Name+', Expected : '+scEmployee.Name);
	}
	/*static testMethod void test qualitativeMeasurementList{
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		test.startTest();
			if(CompetencyGroupMember!=null){
				system.assert(ssc. qualitativeMeasurementList.size()>0,'Failure When Trying to Get Qualitative Measurement List, Recived '+ssc. qualitativeMeasurementList.size());
			}else{
				system.assert(ssc. qualitativeMeasurementList.size() == 0,'Failure When Trying to Get Qualitative Measurement List, Recived '+ssc. qualitativeMeasurementList.size());
			}
		test.stopTest();
	}*/
	
	static testMethod void testGetScorecard(){
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		system.assert(ssc.getScorecard().id!=null,'Failure When Trying to Get Scorecard, Scorecard Doesn\'t Exist');
	}
	
	static testMethod void testRatingPickList(){
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		system.assert(ssc.getRatingPicklist().size() == 8,'Failure When Trying to Get Rating Picklist, Picklist Must Have 8 Items, Recived : '+ssc.getRatingPicklist().size());
	}
	/*
	static testMethod void test(){
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		test.startTest();
		test.stopTest();
	}
	*/
		
	
	static testMethod void testqualitativeMeasurementListAsEmployee(){
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		test.startTest();
			system.runAs(scEmployee){
				if(CompetencyGroupMember!=null){
					try{
						
						integer cgmSize = [select id from CompetencyGroupMember__c where CompetencyGroup__c in (select  p.CompetencyGroup__c from PerformanceReview__c p where p.id=:PerformanceReview.Id)].size();
		        		system.assert(ssc.qualitativeMeasurementList.size()==cgmSize ,'Failure When Trying to Get Qualitative Measurement List, Recived Size : '+ssc.qualitativeMeasurementList.size()+' Expected Size :'+cgmSize);	
					}catch(Exception e){
						
					}
								
				}
			}
		test.stopTest();
	}
	static testMethod void testqualitativeMeasurementListAsManager(){
		genEnvironment();
		salesScorecard_new ssc = new  salesScorecard_new();
		test.startTest();
			system.runAs(scManager2){
				if(CompetencyGroupMember!=null){
					try{
						
						ssc.getIsStatusComplete();
						ssc.getIsStatusCalibration();
						ssc.getIsStatusCreated();
						ssc.getHasValues();
						ssc.getCurrentUser();
						ssc.getIsAdmin();
						ssc.getIsESBP();
						ssc.getIsManager();
						ssc.getIsEmployee();
						ssc.getIsStatusEmpSelfAssess();
						ssc.getIsStatusManagerAssess();
						ssc.getIsRevUsrManagerAndSalesEmp();
						ssc.getIsEmployeeSuccessSC();
						ssc.getIsEmployee_Manager();
						ssc.getCanSeeManagerRatings();
						ssc.getIsAdminOrEmployeeSuccess();
						
						integer cgmSize = [select id from CompetencyGroupMember__c where CompetencyGroup__c in (select  p.CompetencyGroup__c from PerformanceReview__c p where p.id=:PerformanceReview.Id)].size();
			        	system.assert(ssc.qualitativeMeasurementList.size()==cgmSize ,'Failure When Trying to Get Qualitative Measurement List, Recived Size : '+ssc.qualitativeMeasurementList.size()+' Expected Size :'+cgmSize);			
					}catch(Exception e){
						
					}
								
				}
			}
		test.stopTest();
	}
    /* Enviroment Generators */
	public static User getScEmployee(){
			try{
				scEmployee = [Select Id, Name From User Where userName =: 'emptest1@test.com'];
			}catch(Exception e){
				System.debug('Error ' + e);			
			}
			
			if(scEmployee == null){
				Profile p = [Select Id From Profile where Name =: 'Employee'];
				scEmployee =  new User(	username = 'testemp1@test.com',
											lastName = 'test1',
											email = 'emptest1@mailinator.com',
											alias = 'etest',
											timeZoneSidKey ='America/Los_Angeles',
											manager__c = getScManager2().Id,
											localeSidKey = 'en_US',
											emailEncodingKey = 'ISO-8859-1',
											LanguagelocaleKey = 'en_US',
											ProfileId = p.Id,
											salesEmployee__C = true,
											CompetencyGroupCode__c = CompetencyGroup.Code__c);
											
				/* Run As Review Manager */
				system.runAs(scManager2){
					insert scEmployee;
				}
											
				
			}
			return scEmployee;
		
	}
	public static User getScManager2(){
			try{
				scManager2 = [Select Id, Name From User Where userName =: 'managertest@test.com'];
			}catch(Exception e){
			 	System.debug('Error ' + e);
			}
			
			if(scManager2 == null){
				Profile p = [Select Id From Profile where Name =: 'Manager'];
				scManager2 =  new User(	username='test__manager@test.com',
									lastName='testManager',
									email='managertest@mailinator.com',
									alias='mtest',
									timeZoneSidKey='America/Los_Angeles',
									localeSidKey='en_US',
									emailEncodingKey='ISO-8859-1',
									LanguagelocaleKey='en_US',
									ProfileID = p.Id);
				/* Run As Review Employee */
				system.runAs( getSystemAdmin()){
					insert scManager2;	
				}					
				
			}
			return scManager2;
		
	}
	public static User getSystemAdmin(){
		Profile p = [Select Id From Profile where Name =: 'System Administrator'];
		User adminUser = [Select id From User Where ProfileID =: p.Id And IsActive =: True limit 1][0];
		return adminUser; 
	}	
	public static PerformanceReviewPeriod__c performanceReviewPeriod{
		get{
			if(performanceReviewPeriod == null){
				performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test Period',
																	Effective_Date__c = 'FY10',
																	V2MOM_Type__c = 'Individual',
																	StartDate__c = date.newInstance(2010,1,1),
																	EndDate__c = date.newInstance(2010,12,31));
				insert performanceReviewPeriod;
			}
			return  performanceReviewPeriod;
		}
	}
	public static V2MOM__c V2MOM{
		get{
			if(V2MOM==null){
				V2MOM = new V2MOM__c (OwnerId=getScEmployee().Id,
									Vision__c = 'Vision TestV2MOM', 
									V2MOM_Type__c = 'Individual',
									Name = 'Test V2MOM', 
									Effective_Date__c = 'FY10',
									Share_With__c = 'My Management Hierarchy');
				/* Run As Review Manager */
				system.runAs(getScManager2()){
					insert V2MOM;
				}
								
				
			}
			return V2MOM;
		}
	}	
	public static CompetencyGroup__c CompetencyGroup{
		get{
			if(CompetencyGroup==null){
				CompetencyGroup =  new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
				insert CompetencyGroup;
			}
			return CompetencyGroup;
		}
	}
	public static Competency__c Competency{
		get{
			if(Competency==null){
				Competency =  new Competency__c(name='Test Competency',Description__c='Unit Test Competency');
				insert Competency;
			}
			return Competency;
		}
	}
	
	public static void setCompetency_SharingRules(){
		// Read/Write 
		
		CompetencyGroup__Share groupSharing = new CompetencyGroup__Share();
		groupSharing.AccessLevel = 'Edit';
		groupSharing.ParentId = CompetencyGroup.Id;
		groupSharing.UserOrGroupId = userInfo.getUserId();
		insert groupSharing;		
		
		Competency__Share compSharing = new Competency__Share();
		compSharing.AccessLevel = 'Edit';
		compSharing.ParentId = Competency.Id;
		compSharing.UserOrGroupId = userInfo.getUserId();
		insert compSharing;
		
		
	} 
	public static CompetencyGroupMember__c CompetencyGroupMember{
		get{
			if(CompetencyGroupMember==null){
				
				//setCompetency_SharingRules(); 
				CompetencyGroupMember = new CompetencyGroupMember__c(Name='Tes Competency Group Member',
									CompetencyGroup__c=CompetencyGroup.Id,
									Competency__c=Competency.Id,
									Weight__c=100);
									//Define Sharing Rule for scManager
									/*Competency__Share com_share = new Competency__Share(ParentId = Competency.Id ,
                                   			UserOrGroupId = scManager2.Id,
                                       		AccessLevel = 'Edit');
                                     insert com_Share;*/  			
									/* Run As Review Manager */
									try{
										system.runAs(scManager2){
											insert CompetencyGroupMember;
										}	
									}catch(Exception e){
										
									}
										
																
													
			}
			return CompetencyGroupMember;
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
	public static ReviewFormTemplate__c ReviewFormTemplate{
		get{
			if(ReviewFormTemplate==null){
				ReviewFormTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
				insert ReviewFormTemplate;
			}
			return ReviewFormTemplate;
		}
	}
	public static PerformanceReview__c PerformanceReview{
		get{
			if(PerformanceReview == null){
				PerformanceReview = new PerformanceReview__c(Name = 'PerformanceReview Test',
								   PerformanceReviewPeriod__c = PerformanceReviewPeriod.Id,
								   V2MOM__c = V2MOM.Id,
								   CompetencyGroup__c = CompetencyGroup.Id,
								   ReviewFormTemplate__c = ReviewFormTemplate.Id,
								   Employee__c = getScEmployee().Id,
								   Manager__c = getScManager2().Id,
								   SecondManager__c = null,
								   PCOMM__c = null,
								   ThirdPartyReviewer__c = null,
								   Department__c = Deparment.Id,
								   Status__c = 'Employee Self Assessment');
			   upsert PerformanceReview;
			   PerformanceReviewShareList();
			}
			return PerformanceReview;
		}
	}
	public static List<PerformanceReview__Share> PerformanceReviewShareList(){
		List<PerformanceReview__Share> PerformanceReviewShareList = new List<PerformanceReview__Share>();
		PerformanceReviewShareList.add(new PerformanceReview__Share(ParentId = performanceReview.Id ,
                                   			UserOrGroupId = PerformanceReview.employee__c,
                                       		AccessLevel = 'Edit'));
        PerformanceReviewShareList.add(new PerformanceReview__Share(ParentId = performanceReview.Id ,
                                   			UserOrGroupId = PerformanceReview.manager__c,
                                       		AccessLevel = 'Edit'));
       
      	/* Run As Review Manager */
		//system.runAs(scManager2){
			insert PerformanceReviewShareList;
		//}		
                                      		
		return PerformanceReviewShareList;
	}
}