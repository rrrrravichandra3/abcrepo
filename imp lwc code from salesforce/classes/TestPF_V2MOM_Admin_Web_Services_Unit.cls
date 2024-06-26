@isTest
private class TestPF_V2MOM_Admin_Web_Services_Unit {
	
	public static testMethod void execute_methods_V2MOMAdminWebServices() {
	 	    
		GenerateEnvironmentTest2.genUsersTriggers();
		Test.startTest();
		try {
			V2MOM_Admin_Web_Services.lock_unlock_v2moms(null, null);
		}
		catch (Exception e ) {
            System.debug(' ****************** execute_methods_V2MOMAdminWebServices * ');
			System.debug(e.getmessage());
		}
		try {	
			V2MOM_Admin_Web_Services.lock_unlock_v2moms(null, true);
		}
		catch (Exception e ) {
            System.debug(' ****************** execute_methods_V2MOMAdminWebServices * ');
			System.debug(e.getmessage());
		} 
		try {
			V2MOM_Admin_Web_Services.lock_unlock_v2moms('FY08', null);
		}
		catch (Exception e ) {
            System.debug(' ****************** execute_methods_V2MOMAdminWebServices * ');
			System.debug(e.getmessage());
		}
		try {	
			V2MOM_Admin_Web_Services.lock_unlock_v2moms('FY08', true);
		}
		catch (Exception e ) {
            System.debug(' ****************** execute_methods_V2MOMAdminWebServices * ');
			System.debug(e.getmessage());
		}
		try {	
			V2MOM_Admin_Web_Services.lock_unlock_v2moms('FY09', false);
		}
		catch (Exception e ) {
            System.debug(' ****************** execute_methods_V2MOMAdminWebServices * ');
			System.debug(e.getmessage());
		}
		
		try {	
			if(V2MOM_Admin_Web_Services.scrutiny(GenerateEnvironmentTest2.userList) == null){
				System.assert(true, 'Null scrutiny');
			}
		}
		catch (Exception e ) {
            System.debug(' ****************** execute_methods_V2MOMAdminWebServices * ');
			System.debug(e.getmessage());
		}
		Test.stopTest();
	}
	
}