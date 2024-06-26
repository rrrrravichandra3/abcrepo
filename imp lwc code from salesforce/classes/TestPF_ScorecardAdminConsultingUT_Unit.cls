@isTest
private class TestPF_ScorecardAdminConsultingUT_Unit {
	
	  public static testMethod void execute_ScorecardAdminConsultingUT01() {
	  	   
	  	GenerateEnvironmentTest9.genScorecard();
	  	Scorecard__c scorecard = GenerateEnvironmentTest9.scorecardFY09;
	  	
	  	Test.startTest();	
	  	 
	  	try {
		  	System.currentPageReference().getParameters().put('id', 'FY10');
	        ScorecardAdminConsultingUTController controller = new ScorecardAdminConsultingUTController();	  	
		  	 
		  	controller.getIndividualTargetEmployees();
		  	controller.getIndividualActualEmployees();
		  	controller.getIndividualTargetManagers();
		  	controller.getIndividualActualManagers();
		  	controller.getIndividualActual();
		  	controller.getRatingSelectOptions();
		  	controller.getScorecard();
		  	controller.setRating(5); 
		  	controller.getRating();
		  	controller.getWeight();
		  	controller.getIsEducationProfile();
		  	controller.newChangesReload();
		  	controller.getListSize();
		  	controller.getTotal();
		  	controller.getEffectiveDateSelectOptions();
		  	controller.setEffectiveDate('FY08');
		  	controller.getEffectiveDate();
		  	controller.getUsers();
		  	
			// pagination 
		  	controller.getTotalItemsNumber();
		  	controller.genCntPagination();
		  	controller.nextPage();
		  	controller.prevPage();
		  	controller.lastPage();
		  	controller.firstPage();
		  	controller.getTotalItemsNumber();
		  	controller.getFirstItem();
		  	controller.getLastItem();
		  	controller.getCurrentPagination();
		  	controller.getCntPagination();
		  	controller.getNumberOfItemsToShow();
		  	controller.getFirstRow();
		  	controller.getPrevPageLinkShow();
		  	controller.getNextPageLinkShow();
		  	controller.getNextPageShow();
		  	controller.getJumpPage();
		  	controller.JumpToPage();
		  	controller.getJumpPage();
		  	
		  	controller.genCntPaginationManager();
		  	controller.nextPageManager();
		  	controller.prevPageManager();
		  	controller.lastPageManager();
		  	controller.firstPageManager();
		  	controller.getTotalItemsNumberManager();
		  	controller.getFirstItemManager();
		  	controller.getLastItemManager();
		  	controller.getCurrentPaginationManager();
		  	controller.getCntPaginationManager();
		  	controller.getNumberOfItemsToShowManager();
		  	controller.getFirstRowManager();
		  	controller.getPrevPageLinkShowManager();
		  	controller.getNextPageLinkShowManager();
		  	controller.getNextPageShowManager();
		  	controller.getJumpPageManager();
		  	controller.JumpToPageManager();
		  	controller.getJumpPageManager();
		  	
		  	// profiles 
		  	controller.getIsConsultingProfile();
		  	controller.getIsEducationProfile();
		  	
			controller.getIsSupportProfile();
		  	controller.getIsCSMProfile();
		  	controller.getHaveProfile();
		  	
		  	controller.getHasNetBookings();
		  	controller.getHasBilling();
		  	controller.getHasMarginTarget();
		 
		    User u = GenerateEnvironmentTestUsers.createEmployeeWithManager();
		  	ScorecardAdminConsultingUTController.UserSelect users = new  ScorecardAdminConsultingUTController.UserSelect(u,true);
		  	users.getLastFirstName();
		  	users.getSelected();
		  	users.getUser();
		  	
		  	
		  	// INNER CLASS TOTAL
			ScorecardAdminConsultingUTController.Total innerTotal = controller.getTotal();
			//if(innerTotal != null){
				innerTotal.getQ1IA();
				innerTotal.getQ2IA();
				innerTotal.getQ3IA();
				innerTotal.getQ4IA();
				innerTotal.getAVGQ1Q2IA();
				innerTotal.getAVGQ3Q4IA();
				innerTotal.getRatingQ1Q2IA();
				innerTotal.getRatingQ3Q4IA();
				innerTotal.getWeightQ1Q2IA();
				innerTotal.getWeightQ3Q4IA();
				innerTotal.getQ1IT();
				innerTotal.getQ2IT();
				innerTotal.getQ3IT();
				innerTotal.getQ4IT();
				innerTotal.getAVGQ1Q2IT();
				innerTotal.getAVGQ3Q4IT();
				innerTotal.getRatingQ1Q2IT();
				innerTotal.getRatingQ3Q4IT();
				innerTotal.getWeightQ1Q2IT();
				innerTotal.getWeightQ3Q4IT();
			//}
			
			// INNER CLASS INDIVIDUAL ACTUAL 		
			if(controller.getIndividualActual() != null && controller.getIndividualActual().size() > 0){		
		  		ScorecardAdminConsultingUTController.IndividualActual innerActual = controller.getIndividualActual()[0];
		  		
		  		innerActual.getIndividualActual();
		  		innerActual.getQ1();
		  		innerActual.getQ2();
		  		innerActual.getQ3();
		  		innerActual.getQ4();
		  		innerActual.getRatingQ1Q2();
		  		innerActual.getRatingQ3Q4();
		  		innerActual.getAVGQ1Q2();
		  		innerActual.getAVGQ3Q4();
		  		innerActual.getWeightQ1Q2();
		  		innerActual.getWeightQ3Q4();
		  		innerActual.getQ1Group();
		  		innerActual.getQ2Group();
		  		innerActual.getQ3Group();
		  		innerActual.getQ4Group();
		  		innerActual.getRatingQ1Q2Group();
		  		innerActual.getRatingQ3Q4Group();
		  		innerActual.getAVGQ1Q2Group();
		  		innerActual.getAVGQ3Q4Group();
		  		innerActual.getWeightQ1Q2Group();
		  		innerActual.getWeightQ3Q4Group();
		  		innerActual.GroupValues();	
		  		innerActual.IndividualByTeamName('individual team');
			}
					
			// INNER CLASS INDIVIDUAL TARGET 
			if(controller.getIndividualTargetManagers() != null && controller.getIndividualTargetManagers().size() > 0){		
		  		ScorecardAdminConsultingUTController.IndividualTarget innerTarget = controller.getIndividualTargetManagers()[0];
		  		
		  		innerTarget.getIndividualTargetScorecard();
		  		innerTarget.getLastFirstName();
		  		innerTarget.getEmployeeId();
		  		innerTarget.getQ1();
		  		innerTarget.getQ2();
		  		innerTarget.getQ3();
		  		innerTarget.getQ4();
		  		innerTarget.getRatingQ1Q2();
		  		innerTarget.getRatingQ3Q4();
		  		innerTarget.getAVGQ1Q2();
		  		innerTarget.getAVGQ3Q4();
		  		innerTarget.getWeightQ1Q2();
		  		innerTarget.getWeightQ3Q4();
		  		innerTarget.IndividualByTeamName('individual team');
			}
					
			// Inner Class User Select		
			if(controller.getUsers() != null && controller.getUsers().size() > 0){		
		  		ScorecardAdminConsultingUTController.UserSelect innerUserSelect = controller.getUsers()[0];
		  		
		  		innerUserSelect.getUser();
		  		innerUserSelect.getSelected();
		  		innerUserSelect.setSelected(true);
		  		innerUserSelect.getLastFirstName();	
			}
		} catch (Exception e) {
            System.debug(' ****************** execute_ScorecardAdminConsultingUT01 * ');
            System.debug(e.getMessage());
		}

		Test.stopTest();		
	}
	
	
	public static testMethod void execute_ScorecardAdminConsultingUT02() {
	  	
	  	Test.startTest();
	  	
	  	ScorecardAdminConsultingUTController controller = new ScorecardAdminConsultingUTController();	
        
        Test.stopTest();		  	
	}
	
		
	public static testMethod void execute_ScorecardAdminConsultingUT03() {
	  	
	  	GenerateEnvironmentTest9.genScorecard();
	  	Scorecard__c scorecard = GenerateEnvironmentTest9.scorecardFY09;
	  	User employeeEducation = GenerateEnvironmentTest9.employeeEducation;
	  	
			  	System.currentPageReference().getParameters().put('id', 'FY09');
		        ScorecardAdminConsultingUTController controller = new ScorecardAdminConsultingUTController();	
		        controller.getIsEducationProfile();
		        controller.getHaveProfile();
		        
		        controller.getPrevPageLinkShow();
		  		controller.getPrevPageShow();
		  		controller.getNextPageLinkShow();
		  		controller.getLastItem();
		  		controller.getNextPageShow();
		  		controller.getLastItemManager();
		  		controller.JumpToPage();
		  		controller.getPrevPageLinkShowManager();
		  		controller.getPrevPageShowManager();
		  		controller.getNextPageLinkShowManager();
		  		controller.getNextPageShowManager();	  		
		  		controller.JumpToPage();
		  		
		  		controller.nextPage();
		  		
		  		controller.getPrevPageLinkShow();
		  		controller.getPrevPageShow();
		  		controller.getNextPageLinkShow();
		  		controller.getLastItem();
		  		controller.getNextPageShow();
		  		controller.getLastItemManager();
		  		controller.getPrevPageLinkShowManager();
		  		controller.getPrevPageShowManager();
		  		controller.getNextPageLinkShowManager();
		  		controller.getNextPageShowManager();
		  		controller.JumpToPage();
		  		
		  		controller.setJumpPage(15);
		  		controller.JumpToPage();
		  		controller.getLastItemManager();
		  		
		  		controller.setJumpPage(0);
		  		controller.JumpToPage();
		  		controller.getLastItemManager();
		  		controller.getPrevPageLinkShowManager();

	  	}		  	
	
		
		
	public static testMethod void execute_ScorecardAdminConsultingUT04() {
	  	
	  	GenerateEnvironmentTest9.genScorecard();
	  	Scorecard__c scorecard = GenerateEnvironmentTest9.scorecardFY09;
	  	User employeeSupport = GenerateEnvironmentTest9.employeeSupport;
	  	
	  	//system.RunAs(employeeSupport)
	  	//{
	  		Test.startTest();
		  	
		  	try {
			  		
			  	System.currentPageReference().getParameters().put('id', 'FY09');
		        ScorecardAdminConsultingUTController controller = new ScorecardAdminConsultingUTController();	
		        controller.getIsSupportProfile();
		        controller.getHaveProfile();
		        	        
		        controller.getPrevPageLinkShow();
		  		controller.getPrevPageShow();
		  		controller.getNextPageLinkShow();
		  		controller.getLastItem();
		  		controller.getNextPageShow();
		  		controller.getLastItemManager();
		  		controller.JumpToPage();
		  		controller.getPrevPageLinkShowManager();
		  		controller.getPrevPageShowManager();
		  		controller.getNextPageLinkShowManager();
		  		controller.getNextPageShowManager();
		  		controller.JumpToPageManager();
		  		
		  		controller.nextPageManager();
		  		
		  		controller.getPrevPageLinkShow();
		  		controller.getPrevPageShow();
		  		controller.getNextPageLinkShow();
		  		controller.getLastItem();
		  		controller.getNextPageShow();
		  		controller.getLastItemManager();
		  		controller.getPrevPageLinkShowManager();
		  		controller.getPrevPageShowManager();
		  		controller.getNextPageLinkShowManager();
		  		controller.getNextPageShowManager();
		  		controller.JumpToPageManager();
		  		
		  		controller.setJumpPageManager(15);
		  		controller.getNextPageLinkShowManager();
		  		controller.getNextPageShowManager();
		  		controller.JumpToPageManager();
		  		controller.getLastItemManager();
		  		
		  		controller.setJumpPageManager(0);
		  		controller.getNextPageLinkShowManager();
		  		controller.getNextPageShowManager();
		  		controller.JumpToPageManager();
		  		controller.getLastItemManager();
		  		controller.getPrevPageLinkShowManager();
			} catch (Exception e) {
	            System.debug(' ****************** execute_ScorecardAdminConsultingUT04 * ');
	            System.debug(e.getMessage());
			}
	  		
	        Test.stopTest();
	  	//}		  	
	}
		
		
	public static testMethod void execute_ScorecardAdminConsultingUT05() {
	  	
	  	GenerateEnvironmentTest9.genScorecard();
	  	Scorecard__c scorecard = GenerateEnvironmentTest9.scorecardFY09;
	  	User employeeConsulting = GenerateEnvironmentTest9.employeeConsulting;
	  	
	  	//system.RunAs(employeeConsulting)
	  	//{
	  		Test.startTest();
		  	
		  	try {
			  	System.currentPageReference().getParameters().put('id', 'FY09');
		        ScorecardAdminConsultingUTController controller = new ScorecardAdminConsultingUTController();	
		        controller.getIsConsultingProfile();
		        controller.getHaveProfile();
			} catch (Exception e) {
	            System.debug(' ****************** execute_ScorecardAdminConsultingUT05 * ');
	            System.debug(e.getMessage());
			}
	        
	        Test.stopTest();
	  	//}		  	
	}
	
		
	public static testMethod void execute_ScorecardAdminConsultingUT06() {
	  	
	  	GenerateEnvironmentTest9.genScorecard();
	  	Scorecard__c scorecard = GenerateEnvironmentTest9.scorecardFY09;
	  	User employeeCSM = GenerateEnvironmentTest9.employeeCSM;
	  	
	  	//system.RunAs(employeeCSM)
	  	//{
	  		Test.startTest();
		  	
		  	try {
			  	System.currentPageReference().getParameters().put('id', 'FY09');
		        ScorecardAdminConsultingUTController controller = new ScorecardAdminConsultingUTController();	
		        controller.getIsCSMProfile();
		        controller.getHaveProfile();
		        controller.getEffectiveDateSelectOptions();
			} catch (Exception e) {
	            System.debug(' ****************** execute_ScorecardAdminConsultingUT06 * ');
	            System.debug(e.getMessage());
			}
	        
	        Test.stopTest();
	  	//}		  	
	}
			
	public static testMethod void execute_ScorecardAdminConsultingUT07() {
	  	
	  	GenerateEnvironmentTest9.genScorecard();
	  	Scorecard__c scorecard = GenerateEnvironmentTest9.scorecardFY09;
	  	User managerConsulting = GenerateEnvironmentTest9.managerConsulting;
	  	
	  	//system.RunAs(managerConsulting)
	  	//{
	  		Test.startTest();
		  	
		  	try {
			  	System.currentPageReference().getParameters().put('id', 'FY09');
		        ScorecardAdminConsultingUTController controller = new ScorecardAdminConsultingUTController();	
		        
		        // Inner Class User Select		
				if(controller.getUsers() != null && controller.getUsers().size() > 0){		
			  		ScorecardAdminConsultingUTController.UserSelect innerUserSelect = controller.getUsers()[0];
			  		
			  		innerUserSelect.getUser();
			  		innerUserSelect.getSelected();
			  		innerUserSelect.setSelected(true);
			  		innerUserSelect.getLastFirstName();	
				}
			} catch (Exception e) {
	            System.debug(' ****************** execute_ScorecardAdminConsultingUT07 * ');
	            System.debug(e.getMessage());
			}
			
	        Test.stopTest();
	  	//}		  	
	}
	
	
	public static testMethod void execute_ScorecardAdminConsultingUT08() {
	  	
	  	GenerateEnvironmentTest9.genScorecard();
	  	
	  	Test.startTest();	
	  	
	  	try {
		  	System.currentPageReference().getParameters().put('id', 'FY11');
	        ScorecardAdminConsultingUTController controller = new ScorecardAdminConsultingUTController();	  	
		  	
		  	controller.getIndividualTargetEmployees();
		  	controller.getIndividualActualEmployees();
		  	controller.getIndividualTargetManagers();
		  	controller.getIndividualActualManagers();
		  	controller.getIndividualActual();
		  	controller.getRatingSelectOptions();
		  	controller.getScorecard();
		  	controller.setRating(5); 
		  	controller.getRating();
		  	controller.getWeight();
		  	controller.getIsEducationProfile();
		  	controller.getListSize();
		  	controller.getTotal();
		  	controller.getEffectiveDateSelectOptions();
		  	controller.setEffectiveDate('FY08');
		  	controller.getEffectiveDate();
		  	controller.getUsers();
		  				  	
		  	// INNER CLASS TOTAL
			ScorecardAdminConsultingUTController.Total innerTotal = controller.getTotal();
			if(innerTotal != null){
				innerTotal.getQ1IA();
				innerTotal.getQ2IA();
				innerTotal.getQ3IA();
				innerTotal.getQ4IA();
				innerTotal.getAVGQ1Q2IA();
				innerTotal.getAVGQ3Q4IA();
				innerTotal.getRatingQ1Q2IA();
				innerTotal.getRatingQ3Q4IA();
				innerTotal.getWeightQ1Q2IA();
				innerTotal.getWeightQ3Q4IA();
				innerTotal.getQ1IT();
				innerTotal.getQ2IT();
				innerTotal.getQ3IT();
				innerTotal.getQ4IT();
				innerTotal.getAVGQ1Q2IT();
				innerTotal.getAVGQ3Q4IT();
				innerTotal.getRatingQ1Q2IT();
				innerTotal.getRatingQ3Q4IT();
				innerTotal.getWeightQ1Q2IT();
				innerTotal.getWeightQ3Q4IT();
			}
			
			// INNER CLASS INDIVIDUAL ACTUAL 	
			if(controller.getIndividualActual() != null && controller.getIndividualActual().size() > 0){		
		  		ScorecardAdminConsultingUTController.IndividualActual innerActual = controller.getIndividualActual()[0];
		  		
		  		innerActual.getIndividualActual();
		  		innerActual.getQ1();
		  		innerActual.getQ2();
		  		innerActual.getQ3();
		  		innerActual.getQ4();
		  		innerActual.getRatingQ1Q2();
		  		innerActual.getRatingQ3Q4();
		  		innerActual.getAVGQ1Q2();
		  		innerActual.getAVGQ3Q4();
		  		innerActual.getWeightQ1Q2();
		  		innerActual.getWeightQ3Q4();
		  		innerActual.getQ1Group();
		  		innerActual.getQ2Group();
		  		innerActual.getQ3Group();
		  		innerActual.getQ4Group();
		  		innerActual.getRatingQ1Q2Group();
		  		innerActual.getRatingQ3Q4Group();
		  		innerActual.getAVGQ1Q2Group();
		  		innerActual.getAVGQ3Q4Group();
		  		innerActual.getWeightQ1Q2Group();
		  		innerActual.getWeightQ3Q4Group();
		  		innerActual.GroupValues();	
		  		innerActual.IndividualByTeamName('individual team');
			}
					
			// INNER CLASS INDIVIDUAL TARGET 		
			system.debug('*************** getIndividualTargetManagers ' + controller.getIndividualTargetManagers());	
			if(controller.getIndividualTargetManagers() != null && controller.getIndividualTargetManagers().size() > 0){		
		  		ScorecardAdminConsultingUTController.IndividualTarget innerTarget = controller.getIndividualTargetManagers()[0];
		  		
		  		innerTarget.getIndividualTargetScorecard();
		  		innerTarget.getLastFirstName();
		  		innerTarget.getEmployeeId();
		  		innerTarget.getQ1();
		  		innerTarget.getQ2();
		  		innerTarget.getQ3();
		  		innerTarget.getQ4();
		  		innerTarget.getRatingQ1Q2();
		  		innerTarget.getRatingQ3Q4();
		  		innerTarget.getAVGQ1Q2();
		  		innerTarget.getAVGQ3Q4();
		  		innerTarget.getWeightQ1Q2();
		  		innerTarget.getWeightQ3Q4();
		  		innerTarget.IndividualByTeamName('individual team');
			}
			
			// Inner Class User Select		
			system.debug('*************** getUsers ' + controller.getUsers());	
			if(controller.getUsers() != null && controller.getUsers().size() > 0){		
		  		ScorecardAdminConsultingUTController.UserSelect innerUserSelect = controller.getUsers()[0];
		  		
		  		innerUserSelect.getUser();
		  		innerUserSelect.getSelected();
		  		innerUserSelect.setSelected(true);
		  		innerUserSelect.getLastFirstName();	
			}
		} catch (Exception e) {
            System.debug(' ****************** execute_ScorecardAdminConsultingUT08 * ');
            System.debug(e.getMessage());
		}

		Test.stopTest();		
	}
	
	
}