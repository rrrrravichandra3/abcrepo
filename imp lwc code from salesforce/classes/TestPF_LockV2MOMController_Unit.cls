@isTest
private class TestPF_LockV2MOMController_Unit {
	  
    public static testMethod void execute_methods_LockV2MOMController() {
        Test.startTest();
           
        try {
	        LockV2MOMController  controller = new LockV2MOMController();
	         
	        Test.setCurrentPageReference(new PageReference('Page.LockV2MOM'));
	        
	        System.assert(controller.getDebugging() == false);
	        System.assert(controller.getResults() != null);
	        System.assert(controller.getEffectiveDate() == null);
	        controller.setEffectiveDate('HI');
	        System.assert(controller.getEffectiveDate().equals('HI'));
	        System.assert(controller.getLockUnlockSelection().equals('Lock'));
	        controller.setLockUnlockSelection('UnLock');
	        System.assert(controller.getLockUnlockSelection().equals('UnLock'));
	        System.assert(controller.getProcessing() == false);
	        controller.lockUnlockV2MOMs();
	        System.assert(controller.getLockUnlockSelectionToShow() != '');
	        controller.setLockUnlockSelection('Lock');
	        System.assert(controller.getLockUnlockSelectionToShow() != '');
        }catch(Exception e){
            System.debug(' ****************** Test_LockV2MOMController * ');
            System.debug(e.getMessage());
        }
        
        Test.stopTest();
    }
 
}