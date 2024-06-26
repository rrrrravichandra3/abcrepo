@isTest
private class TestPF_V2momPrioritizeController_Unit {

    public static testMethod void execute_V2momPrioritizeControllerNewUI() {
 	
 		try
 		{
        	GenerateEnvironmentTest.genV2MOMPrioritize(); 
           	System.assert(GenerateEnvironmentTest.v2momIndividual != null);
        	System.assert(GenerateEnvironmentTest.v2momDepartment != null);
        	System.assert(GenerateEnvironmentTest.v2momOnboarding != null);
        	System.assert(GenerateEnvironmentTest.v2momOrganization != null);
        	
        	Test.startTest();
         
     
            // UPDATE METHODS -----------------------------------------
            v2momPrioritizeController controller = new v2momPrioritizeController();
             
            String updates = GenerateEnvironmentTest.method3.Id + ',1-' + GenerateEnvironmentTest.method1.Id + ',2-' + GenerateEnvironmentTest.method2.Id + ',3-';
            System.assert(updates != null || updates != '');
            System.currentPageReference().getParameters().put('update', updates);           
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.id);
            controller.UpdateMethods();
    
            // UPDATE VALUES -----------------------------------------
            controller = new v2momPrioritizeController();
            
            updates = GenerateEnvironmentTest.value2.Id + ',1-' + GenerateEnvironmentTest.value1.Id + ',2-';
            System.assert(updates != null || updates != '');
            System.currentPageReference().getParameters().put('update', updates);           
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.id);
            controller.UpdateValues();
            
            // UPDATE OBSTACLES -----------------------------------------
            controller = new v2momPrioritizeController();
            
            updates = GenerateEnvironmentTest.obstacle2.Id + ',1-' + GenerateEnvironmentTest.obstacle1.Id + ',2-';
            System.assert(updates != null || updates != '');
            System.currentPageReference().getParameters().put('update', updates);           
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.id);
            controller.UpdateObstacles();
            
            // UPDATE OBSTACLES -----------------------------------------
            controller = new v2momPrioritizeController();
            
            updates = GenerateEnvironmentTest.measure2.Id + ',1-' + GenerateEnvironmentTest.measure1.Id + ',2-';
            System.assert(updates != null || updates != '');
            System.currentPageReference().getParameters().put('update', updates);           
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.id);
            controller.UpdateMetrics();
            controller.UpdateOnlyMethods();
            controller.UpdateOnlyValues();
            controller.UpdateOnlyObstacles();
            controller.UpdateOnlyMetrics();
            controller.updateAll();
            controller.continuePage();
            controller.continuePageOldUI();
            controller.continuePage();
     
       		Test.stopTest();	
 		}
 		catch(Exception ex)
 		{
 			
 		}
    }
    

    public static testMethod void execute_V2momPrioritizeControllerNewUIAll() {

        GenerateEnvironmentTest.genV2MOMPrioritize(); 
        	
       		test.startTest();
       		
       		System.assert(GenerateEnvironmentTest.v2momIndividual != null);
        	System.assert(GenerateEnvironmentTest.v2momDepartment != null);
        	System.assert(GenerateEnvironmentTest.v2momOnboarding != null);
        	System.assert(GenerateEnvironmentTest.v2momOrganization != null);
       		
            // UPDATE METHODS -----------------------------------------
            v2momPrioritizeController controller = new v2momPrioritizeController();
            
            String updates = GenerateEnvironmentTest.method3.Id + ',1-' + GenerateEnvironmentTest.method1.Id + ',2-' + GenerateEnvironmentTest.method2.Id + ',3-';
            System.assert(updates != null || updates != '');
            System.currentPageReference().getParameters().put('updateMethods', updates);            
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.id);
    
            // UPDATE VALUES -----------------------------------------
            updates = GenerateEnvironmentTest.value2.Id + ',1-' + GenerateEnvironmentTest.value1.Id + ',2-';
            System.assert(updates != null || updates != '');
            System.currentPageReference().getParameters().put('updateValues', updates);         
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.id);
            
            // UPDATE OBSTACLES -----------------------------------------
            updates = GenerateEnvironmentTest.obstacle2.Id + ',1-' + GenerateEnvironmentTest.obstacle1.Id + ',2-';
            System.assert(updates != null || updates != '');
            System.currentPageReference().getParameters().put('updateObstacles', updates);          
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.id);
            
            // UPDATE METRICS -----------------------------------------
            updates = GenerateEnvironmentTest.measure2.Id + ',1-' + GenerateEnvironmentTest.measure1.Id + ',2-';
            System.assert(updates != null || updates != '');
            System.currentPageReference().getParameters().put('updateMetrics', updates);            
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentTest.v2momIndividual.id);
            
            
            controller.UpdateAll();
         	controller.UpdateOnlyMethods();
            controller.UpdateOnlyValues();
            controller.UpdateOnlyObstacles();
            controller.UpdateOnlyMetrics();
            controller.updateAll();
            controller.continuePage();
            controller.continuePageOldUI();
            controller.continuePage();
      
        Test.stopTest();
        
    }
    
    
    public static testMethod void execute_V2momPrioritizeControllerOldUI() {

		try
		{
	        GenerateEnvironmentTest.genV2MOMPrioritize(); 
	        System.assert(GenerateEnvironmentTest.v2momIndividual != null);
        	System.assert(GenerateEnvironmentTest.v2momDepartment != null);
        	System.assert(GenerateEnvironmentTest.v2momOnboarding != null);
        	System.assert(GenerateEnvironmentTest.v2momOrganization != null);
        	
	        Test.startTest();
	        
	      
	            // UPDATE METHODS -----------------------------------------
	            v2momPrioritizeController controller = new v2momPrioritizeController();
	                    
	            String updates = GenerateEnvironmentTest.method3.Id + ',1-' + GenerateEnvironmentTest.method1.Id + ',2-' + GenerateEnvironmentTest.method2.Id + ',3-';
	            System.assert(updates != null || updates != '');
	            System.currentPageReference().getParameters().put('update', updates);           
	            System.currentPageReference().getParameters().put('ev', 'save');
	            System.currentPageReference().getParameters().put('ret', GenerateEnvironmentTest.v2momIndividual.id);
	            controller.UpdateMethodsOldUI();
             	controller.UpdateOnlyMethods();
	            controller.UpdateOnlyValues();
	            controller.UpdateOnlyObstacles();
	            controller.UpdateOnlyMetrics();
	            controller.updateAll();
	            controller.continuePage();
	            controller.continuePageOldUI();
	                     
	            updates = GenerateEnvironmentTest.method3.Id + ',1-' + GenerateEnvironmentTest.method1.Id + ',2-' + GenerateEnvironmentTest.method2.Id + ',3-';
	            System.assert(updates != null || updates != '');
	            System.currentPageReference().getParameters().put('update', updates);           
	            System.currentPageReference().getParameters().put('ev', 'apply');
	            System.currentPageReference().getParameters().put('ret', GenerateEnvironmentTest.v2momIndividual.id);
	            controller.UpdateMethodsOldUI();
	            
	            controller.continuePageOldUI();
	      
	        Test.stopTest();
		}
		catch (Exception ex)
		{
			System.debug(ex);
		}
    }
    
}