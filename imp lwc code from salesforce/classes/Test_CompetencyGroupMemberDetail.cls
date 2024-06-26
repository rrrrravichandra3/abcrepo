@isTest
private class Test_CompetencyGroupMemberDetail {
  
    public static testMethod void execute_methods_CompetencyGroupDetailController_00() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupMemberDetail'));
					
        Test.startTest();
         
        try {
	        CompetencyGroupMember__c competencyGroupMember = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member', 
	                                            'Test CGM', GenerateEnvironmentTest.competency.Id, 
	                                            GenerateEnvironmentTest.competencyGroup.Id, null);
	        
	        ApexPages.StandardController stdController = new ApexPages.StandardController(competencyGroupMember);
	        
	        CompetencyGroupMemberDetailController controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	         
	        controllerFromStd.setCompetencyGroupMember(competencyGroupMember);
	        controllerFromStd.getCompetencyGroupMember();
	        controllerFromStd.getMsg();
	        controllerFromStd.getShowError();
	        controllerFromStd.save();
	        controllerFromStd.cancel();
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupMemberDetail * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();

    }   


    public static testMethod void execute_methods_CompetencyGroupDetailController_01() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupMemberDetail'));
					
        Test.startTest();
        
        try {
        	
	        CompetencyGroupMember__c competencyGroupMember = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member', 
	                                            'Test CGM', GenerateEnvironmentTest.competency.Id, 
	                                            GenerateEnvironmentTest.competencyGroup.Id, -1);
	        
	        ApexPages.StandardController stdController = new ApexPages.StandardController(competencyGroupMember);
	        
	        CompetencyGroupMemberDetailController controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(competencyGroupMember);
	        controllerFromStd.getCompetencyGroupMember();
	        controllerFromStd.getMsg();
	        controllerFromStd.getShowError();
	        controllerFromStd.save();
	        controllerFromStd.cancel();
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupMemberDetail * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();

    }   


    public static testMethod void execute_methods_CompetencyGroupDetailController_02() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupMemberDetail'));
					
        Test.startTest();
        
        try {
        	
	        CompetencyGroupMember__c competencyGroupMember = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member', 
	                                            'Test CGM', GenerateEnvironmentTest.competency.Id, 
	                                            GenerateEnvironmentTest.competencyGroup.Id, null);
	        
	        ApexPages.StandardController stdController = new ApexPages.StandardController(competencyGroupMember);
	        
	        CompetencyGroupMemberDetailController controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(competencyGroupMember);
	        controllerFromStd.getCompetencyGroupMember();
	        controllerFromStd.getMsg();
	        controllerFromStd.getShowError();
	        controllerFromStd.saveAndNew();
	        controllerFromStd.cancel();
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupMemberDetail * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();

    }   

    public static testMethod void execute_methods_CompetencyGroupDetailController_03() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupMemberDetail'));
					
        Test.startTest();
        
        try {
	        CompetencyGroupMember__c competencyGroupMember = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member', 
	                                            'Test CGM', GenerateEnvironmentTest.competency.Id, 
	                                            GenerateEnvironmentTest.competencyGroup.Id, -1);
	        
	        ApexPages.StandardController stdController = new ApexPages.StandardController(competencyGroupMember);
	        
	        CompetencyGroupMemberDetailController controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(competencyGroupMember);
	        controllerFromStd.getCompetencyGroupMember();
	        controllerFromStd.getMsg();
	        controllerFromStd.getShowError();
	        controllerFromStd.saveAndNew();
	        controllerFromStd.cancel();
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupMemberDetail * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();

    }   


    public static testMethod void execute_methods_CompetencyGroupDetailController_04() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupMemberDetail'));
					
        Test.startTest();
        
        try {
	        CompetencyGroupMember__c competencyGroupMember = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member', 
	                                            'Test CGM', GenerateEnvironmentTest.competency.Id, 
	                                            GenerateEnvironmentTest.competencyGroup.Id, 22);
	
			CompetencyGroupMember__c c = new CompetencyGroupMember__c();
			c.Name = 'Test CGM';
			c.CompetencyGroup__c = GenerateEnvironmentTest.competencyGroup.Id;
			c.Competency__c = GenerateEnvironmentTest.competency.Id;
			c.Weight__c = 88;
	        
	        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
	        
	        CompetencyGroupMemberDetailController controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(c);
	        controllerFromStd.saveAndNew();
	
	
			c = new CompetencyGroupMember__c();
			c.Name = 'Test CGM';
			c.CompetencyGroup__c = GenerateEnvironmentTest.competencyGroup.Id;
			c.Competency__c = GenerateEnvironmentTest.competency1.Id;
			c.Weight__c = 88;
	        
	        stdController = new ApexPages.StandardController(c);
	        
	        controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(c);
	        controllerFromStd.saveAndNew();
	
	
			c = new CompetencyGroupMember__c();
			c.Name = 'Test CGM';
			c.CompetencyGroup__c = GenerateEnvironmentTest.competencyGroup.Id;
			c.Competency__c = GenerateEnvironmentTest.competency1.Id;
			c.Weight__c = 58;
	        
	        stdController = new ApexPages.StandardController(c);
	        
	        controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(c);
	        controllerFromStd.saveAndNew();
	
	        controllerFromStd.cancel();
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupMemberDetail * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();

    }   


    public static testMethod void execute_methods_CompetencyGroupDetailController_05() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupMemberDetail'));
					
        Test.startTest();
        
        try {
	        CompetencyGroupMember__c competencyGroupMember = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member', 
	                                            'Test CGM', GenerateEnvironmentTest.competency.Id, 
	                                            GenerateEnvironmentTest.competencyGroup.Id, 22);
	
			CompetencyGroupMember__c c = new CompetencyGroupMember__c();
			c.Name = 'Test CGM';
			c.CompetencyGroup__c = GenerateEnvironmentTest.competencyGroup.Id;
			c.Competency__c = GenerateEnvironmentTest.competency.Id;
			c.Weight__c = 88;
	        
	        ApexPages.StandardController stdController = new ApexPages.StandardController(c);
	        
	        CompetencyGroupMemberDetailController controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(c);
	        controllerFromStd.save();
	
	
			c = new CompetencyGroupMember__c();
			c.Name = 'Test CGM';
			c.CompetencyGroup__c = GenerateEnvironmentTest.competencyGroup.Id;
			c.Competency__c = GenerateEnvironmentTest.competency1.Id;
			c.Weight__c = 88;
	        
	        stdController = new ApexPages.StandardController(c);
	        
	        controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(c);
	        controllerFromStd.save();
	
	
			c = new CompetencyGroupMember__c();
			c.Name = 'Test CGM';
			c.CompetencyGroup__c = GenerateEnvironmentTest.competencyGroup.Id;
			c.Competency__c = GenerateEnvironmentTest.competency1.Id;
			c.Weight__c = 58;
	        
	        stdController = new ApexPages.StandardController(c);
	        
	        controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
	        
	        controllerFromStd.setCompetencyGroupMember(c);
	        controllerFromStd.save();
	
	        controllerFromStd.cancel();
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupMemberDetail * ');
            System.debug(e.getMessage());
        }
	        
        Test.stopTest();

    }   


    public static testMethod void execute_methods_CompetencyGroupDetailController_06() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupMemberDetail'));
		
		System.currentPageReference().getParameters().put('clone', 'yes');
        Test.startTest();
        
        try {
	        CompetencyGroupMember__c competencyGroupMember = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member', 
	                                            'Test CGM', GenerateEnvironmentTest.competency.Id, 
	                                            GenerateEnvironmentTest.competencyGroup.Id, null);
	        
	        ApexPages.StandardController stdController = new ApexPages.StandardController(competencyGroupMember);
	        
	        CompetencyGroupMemberDetailController controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupMemberDetail * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();

    }   


    public static testMethod void execute_methods_CompetencyGroupDetailController_07() {
        
        GenerateEnvironmentTest.genCompGroupTest();
        
        Test.setCurrentPageReference(new PageReference('Page.CompetencyGroupMemberDetail'));
		
		System.currentPageReference().getParameters().put('clone', 'yes');
        Test.startTest();
        
        try {
	        CompetencyGroupMember__c competencyGroupMember = GenerateEnvironmentTest.createCompetencyGroupMember('Test Competency Group Member', 
	                                            'Test CGM', GenerateEnvironmentTest.competency.Id, 
	                                            GenerateEnvironmentTest.competencyGroup.Id, 101);
	        
	        ApexPages.StandardController stdController = new ApexPages.StandardController(competencyGroupMember);
	        
	        CompetencyGroupMemberDetailController controllerFromStd = new CompetencyGroupMemberDetailController(stdController);
		        
        }catch(Exception e){
            System.debug(' ****************** Test_CompetencyGroupMemberDetail * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();

    }   

}