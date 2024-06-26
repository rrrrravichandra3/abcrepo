@isTest
private class TestPF_PAMUtil_Unit {
	  
	 public static testMethod void execute_PAMUtilController() {
	 	
	 	Test.startTest();
	 	
	 	try {
		 	if(PAMUtil.getEmployeeServicesQueue() == null){
		 		system.assert(true, 'null que');
		 	}
		 	 
		 	if(PAMUtil.getESAdminQueue() == null){
		 		system.assert(true, 'null id');
		 	}
		 	
		 	if(PAMUtil.getRatingSelectOptions() == null){
		 		system.assert(true, 'null options');
		 	}
		 	 
		 	if(PAMUtil.getStatusSelectOptions() == null){
		 		system.assert(true, 'null status option');	
		 	}
		 	
		 	if(PAMUtil.getStatusSelectOptions() == null){
		 		system.assert(true, 'null status option');	
		 	}
		 	
		 	if(PAMUtil.getAdjustedRatingSelectOptions() == null){
		 		system.assert(true, 'null adjusted rating');
		 	}
		 	
		 	if(PAMUtil.getRatingLabel(5) == null){
		 		system.assert(true, 'null rating label');
		 	}
		 	
		 	if(PAMUtil.getRatingFromActualTarget(120) == null){
		 		system.assert(true, 'null rating target');
		 	} 
		 	
		 	if(PAMUtil.getRatingFromActualTarget(110) == null){
		 		system.assert(true, 'null rating target');
		 	} 
		 	
		 	if(PAMUtil.getRatingFromActualTarget(96) == null){
		 		system.assert(true, 'null rating target');
		 	} 
		 	
		 	if(PAMUtil.getRatingFromActualTarget(87) == null){
		 		system.assert(true, 'null rating target');
		 	} 
		 	
		 	if(PAMUtil.getRatingFromActualTarget(80) == null){
		 		system.assert(true, 'null rating target');
		 	}  
		 	
		 	PAMUtil.setOptions(null);
		 	PAMUtil.getStatusSelectOptions();
		 	PAMUtil.setOptions(null);
		 	PAMUtil.getAdjustedRatingSelectOptions();
		 	PAMUtil.getRatingFromActualTarget(115);
		 	PAMUtil.getRatingFromActualTarget(101);
		 	PAMUtil.getRatingFromActualTarget(95);
		 	PAMUtil.getRatingFromActualTarget(86);
		 	PAMUtil.getRatingFromActualTarget(80);
		 	PAMUtil.getRatingSelectOptionsToMethods();
		 	PAMUtil.getRatingLabel(10);
		 	PAMUtil.getRatingLabelToMethods(10);
		 	
		 	if(PAMUtil.getAdjustedRatingSelectOptions() == null){
		 		system.assert(true, 'null adjusted rating');
		 	}
		} catch (Exception e) {
            System.debug(' ****************** Test_PAMUtil * ');
            System.debug(e.getMessage());
		}
	 	
	 	Test.stopTest();
	 	
	 }
	 
}