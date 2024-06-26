@isTest
public with sharing class Test_ESDJC_Util {
	
	public static testMethod void isFoundationDepartmentTest(){
		init();

		System.assert(!ESDJC_Util.isFoundationDepartment('7123-Foundation'), 'Wrong department evaluated as Foundation');
		System.assert(!ESDJC_Util.isFoundationDepartment('Test department'), 'Wrong department evaluated as Foundation');
		System.assert(!ESDJC_Util.isFoundationDepartment('org-Department'), 'Wrong department evaluated as Foundation');

		System.assert(ESDJC_Util.isFoundationDepartment('foun-foundation'), 'Foundation department evaluated as No Foundation');
		System.assert(ESDJC_Util.isFoundationDepartment('Foun-Foundation'), 'Foundation department evaluated as No Foundation');
		System.assert(ESDJC_Util.isFoundationDepartment('FOUN-FOUNDATION'), 'Foundation department evaluated as No Foundation');

		System.assert(ESDJC_Util.isFoundationDepartment('.org-Department'), 'Foundation department evaluated as No Foundation');
		System.assert(ESDJC_Util.isFoundationDepartment('.org-Department'), 'Foundation department evaluated as No Foundation');
		System.assert(ESDJC_Util.isFoundationDepartment('.ORG-DEPARTMENT'), 'Foundation department evaluated as No Foundation');
	}

	private static void init(){

		ESDJC_Settings__c settings = new ESDJC_Settings__c();
		settings.Foundation_Dept_Names__c = 'FOUN-Foundation,.org-Department';
		settings.Site_URL__c = 'https://dreamjobcentral';
        
        INSERT settings;
	}

}