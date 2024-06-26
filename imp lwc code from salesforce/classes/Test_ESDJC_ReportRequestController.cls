@isTest
private class Test_ESDJC_ReportRequestController {
	
	static testMethod void yesNoOptionsTest() {	

		User portalUser = ESDJC_TestUtil.getPortalUser('USA','Americas - USA');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_AMER');
        }

        system.runAs(portalUser){
            PageReference pageRef = new PageReference('/apex/ESDJC_ReportRequestPage');
            Test.setCurrentPage(pageRef);
            
            ESDJC_ReportRequestController reportRequestController = new ESDJC_ReportRequestController();
            
            System.assertEquals(2, reportRequestController.yesNoOptions.size());
            System.assertEquals('true', reportRequestController.yesNoOptions.get(0).getValue());
            System.assertEquals('false', reportRequestController.yesNoOptions.get(1).getValue());
            System.assertEquals('Yes', reportRequestController.yesNoOptions.get(0).getLabel());
            System.assertEquals('No', reportRequestController.yesNoOptions.get(1).getLabel());
        }        

	}	

	static testMethod void caseSetupTest(){

		User portalUser = ESDJC_TestUtil.getPortalUser('USA','Americas - USA', 'San Francisco');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_AMER');
        }

        system.runAs(portalUser){

            PageReference pageRef = new PageReference('/apex/ESDJC_ReportRequestPage');
            Test.setCurrentPage(pageRef);
            
            ESDJC_ReportRequestController reportRequestController = new ESDJC_ReportRequestController();

            reportRequestController.newCase.Subject = 'Subject';
            reportRequestController.newCase.ES_DJC_Topic__c = 'Compensation';
            reportRequestController.newCase.ES_DJC_Report_Request_Detail__c = 'ES Data request detail';
            reportRequestController.newCase.ES_DJC_Report_Request_Due_Date__c = Date.today() + 1;
            reportRequestController.newCase.ES_DJC_Report_Request_Frequency__c = 'One-Time Request';

            reportRequestController.saveCase();

            System.assertEquals(reportRequestController.newCase.Type, 'ES Data Request');
            System.assertEquals(reportRequestController.newCase.Origin, 'Employee Success - Web');
            System.assertEquals(reportRequestController.newCase.Tier__c, 'Tier 1');
        }        
	}

	static testMethod void getRecordTypeAmerHQTest(){
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		getRecordTypeTest('USA', 'Americas - USA', 'San Francisco', 'ES_DJC_Employee_AMER', settings.All_Cases_Except_ER_AMER_RT__c);
	}

	static testMethod void getRecordTypeAmerNoHQTest(){
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		getRecordTypeTest('Canada', 'Americas - Canada', null, 'ES_DJC_Employee_AMER', settings.All_Cases_Except_ER_AMER_RT__c);
	}

	static testMethod void getRecordTypeEmeaTest(){
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		getRecordTypeTest('France', 'EMEA - All Countries', null, 'ES_DJC_Employee_EMEA', settings.All_Cases_Except_ER_EMEA_RT__c);
	}

	static testMethod void getRecordTypeApacTest(){
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		getRecordTypeTest('India', 'APAC - All Countries', null, 'ES_DJC_Employee_APAC', settings.All_Cases_Except_ER_APAC_RT__c);
	}

	static testMethod void getRecordTypeJapanTest(){
		ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
		getRecordTypeTest('Japan', 'Japan', null, 'ES_DJC_Employee_Japan', settings.All_Cases_Except_ER_Japan_RT__c);
	}

	private static void getRecordTypeTest(String country, String division, String workLocation, String permission, String expectedRecordType){

		User user;
		if(workLocation != null){
			user = ESDJC_TestUtil.getPortalUser(country, division, workLocation);
		}else{
			user = ESDJC_TestUtil.getPortalUser(country, division);
		}

        user currentUser = [select id from user where id =:UserInfo.getUserId() ];

        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(user.id, permission);
        }

        system.runAs(user){
            PageReference pageRef = new PageReference('/apex/ESDJC_ReportRequestPage');
            Test.setCurrentPage(pageRef);
            
            ESDJC_ReportRequestController reportRequestController = new ESDJC_ReportRequestController();
            System.assertEquals(expectedRecordType, reportRequestController.getRecordType());
        }
	}

	private static testMethod void dueDateValidationTest(){

		User portalUser = ESDJC_TestUtil.getPortalUser('USA','Americas - USA', 'San Francisco');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_AMER');
        }

        system.runAs(portalUser){

            PageReference pageRef = new PageReference('/apex/ESDJC_ReportRequestPage');
            Test.setCurrentPage(pageRef);
            
            ESDJC_ReportRequestController reportRequestController = new ESDJC_ReportRequestController();

            reportRequestController.newCase.Subject = 'Subject';
            reportRequestController.newCase.ES_DJC_Topic__c = 'Compensation';
            reportRequestController.newCase.ES_DJC_Report_Request_Detail__c = 'ES Data Request detail';
            reportRequestController.newCase.ES_DJC_Report_Request_Due_Date__c = Date.today();
            reportRequestController.newCase.ES_DJC_Report_Request_Frequency__c = 'One-Time Request';

			PageReference result = reportRequestController.saveCase();
            System.assertEquals(null, result);
            System.assertEquals(1, ApexPages.getMessages().size());
            System.assertEquals(Label.ES_DJC_ReportRequest_DueDate, ApexPages.getMessages().get(0).getComponentLabel());
            System.assertEquals('Please select a future date', ApexPages.getMessages().get(0).getSummary());
        }        

	}


	@testSetup private static void setupESDJCSettings(){

		RecordType rtAmer = [SELECT Id FROM RecordType WHERE Name = 'All Case Types except ER - AMER'];
		RecordType rtApac = [SELECT Id FROM RecordType WHERE Name = 'All Case Types except ER - APAC'];
		RecordType rtEmea = [SELECT Id FROM RecordType WHERE Name = 'All Case Types except ER - EMEA'];
		RecordType rtJapan = [SELECT Id FROM RecordType WHERE Name = 'All Case Types except ER - Japan'];

		ESDJC_Settings__c settings = new ESDJC_Settings__c();

		settings.All_Cases_Except_ER_AMER_RT__c = rtAmer.Id;
		settings.All_Cases_Except_ER_APAC_RT__c = rtApac.Id;
		settings.All_Cases_Except_ER_EMEA_RT__c = rtEmea.Id;
		settings.All_Cases_Except_ER_Japan_RT__c = rtJapan.Id;
		settings.Site_URL__c = '/site/url';

		insert settings;
	}
}