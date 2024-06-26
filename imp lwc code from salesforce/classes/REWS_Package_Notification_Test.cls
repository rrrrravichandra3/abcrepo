@isTest (seeAllData=false)
public with sharing class REWS_Package_Notification_Test {
	
	
	static testMethod void sendPackageEmailsTest(){
		
		Contact con = (ESDJC_AssignmentHelper.getContacts(1,'Americas - USA','San Francisco'))[0]; 
		 Case c = new Case();
		 c.contactId= con.Id;
		 c.RecordTypeId= ESDJC_AssignmentHelper.getRecordTypeId('case','All REWS Package Management');
		 c.origin = 'Package Delivery';
		 c.Type='Mail Services';
		 c.REWS_Delivery_Location__c='Rincon'; 
		 c.Status='New';
		 c.ES_DJC_Topic__c='Package Delivery'; 
		 c.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
		 insert c;
		 
		 Test.startTest();
		 String query = 'select id,contactId from case where REWS_Is_Email_Sent__c=false and'+  
						 ' REWS_Delivery_Location__c!=null and status not in (\'Closed\',\'Closed - Duplicate\')'+
						 ' and contactId!=null and recordtype.developerName=\'REWS_Package_Management\'';
		REWS_Package_Notification_Batch batch = new REWS_Package_Notification_Batch(query); 
		database.executebatch(batch,100);
		Test.stopTest();
		
		/*Assert emails are sent by checking email sent field */
		
		System.assertEquals(true,[select REWS_Is_Email_Sent__c from Case where id= : c.Id][0].REWS_Is_Email_Sent__c); 
		 
		
	}

}