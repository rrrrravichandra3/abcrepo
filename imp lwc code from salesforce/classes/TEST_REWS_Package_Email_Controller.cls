@isTest
private class TEST_REWS_Package_Email_Controller {
	
	@isTest static void testAllCustomLabelsAreAvailabele() {
		ESDJC_TestUtil.init();
                Case ca; 
                List<REWS_Package_Delivery__c> packages = new  List<REWS_Package_Delivery__c>(); 
                RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1]; 
                Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email='testmailapp@salesforce.com',RecordTypeId = employeeRT.Id);
                insert con; 
                ca = new Case(contactId = con.Id,origin = 'Package Delivery',Type='Mail Services',ES_DJC_Topic__c='Package Delivery',REWS_Received_Location__c='Landmark',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
                //attach 2 packages..
                insert ca;
                packages.add(new REWS_Package_Delivery__c(REWS_Tracking_Number__c='123455',REWS_Status__c ='In Progress', Case__c=ca.Id));
                packages.add(new REWS_Package_Delivery__c(REWS_Tracking_Number__c='823455',REWS_Status__c ='In Progress', Case__c=ca.Id));
                insert packages;

                REWS_Package_Email_Controller emailController = new REWS_Package_Email_Controller();
                emailController.emailType = 'Oversized';
                emailController.caseId = ca.Id;

                String perishableText = emailController.getPerishableEmailText();
                System.assertNotEquals(null, perishableText);

                String rushedText = emailController.getRushedEmailText();
                System.assertNotEquals(null, rushedText);

                String oversizedFooterText = emailController.getOversizedEmailTextFooter();
                System.assertNotEquals(null, oversizedFooterText);

                String firstText = emailController.getFirstReminderText();
                System.assertNotEquals(null, firstText);

                String secondText = emailController.getSecondReminderText();
                System.assertNotEquals(null, secondText);

                String thirdText = emailController.getThirdReminderText();
                System.assertNotEquals(null, thirdText);

                String forthText = emailController.getForthAndFinalReminderText();
                System.assertNotEquals(null, forthText);

                String dailyText = emailController.getDailyMailText();
                System.assertNotEquals(null, dailyText);
	}
}