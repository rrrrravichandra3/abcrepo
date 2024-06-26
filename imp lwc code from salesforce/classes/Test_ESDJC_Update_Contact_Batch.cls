@isTest(SeeAllData=true)
public with sharing class Test_ESDJC_Update_Contact_Batch {
	static testMethod void testBatchJobExecution() {		
		List<Attachment> attachments = [SELECT Id,Name,ParentId FROM Attachment WHERE ParentId = 'a3LQ00000004PnA' AND Name LIKE '%ESDJC%' AND Name LIKE '%User Batch Result.csv%' LIMIT 1];
		if(attachments.size() > 0){
			Attachment anAttachment = 	attachments.get(0);
			ESDJC_Integration_Log__c log = [SELECT DJC_Update_Contact_Batch_Job_Finish_Time__c,DJC_Update_Contact_Batch_Job_Start_Time__c,DJC_Update_Contact_Job_Status__c FROM ESDJC_Integration_Log__c WHERE id = :anAttachment.ParentId];
			log.DJC_Update_Contact_Batch_Job_Start_Time__c = null;
			log.DJC_Update_Contact_Batch_Job_Finish_Time__c = null;
			log.DJC_Update_Contact_Job_Status__c = null;
			update log;
			
  			Test.StartTest();
   			ESDJC_Update_Contact_Batch updateContact = new ESDJC_Update_Contact_Batch(log);
   			ID batchprocessid = Database.executeBatch(updateContact);
   			Test.StopTest();
   			
			log = [SELECT DJC_Update_Contact_Batch_Job_Finish_Time__c,DJC_Update_Contact_Batch_Job_Start_Time__c,DJC_Update_Contact_Job_Status__c FROM ESDJC_Integration_Log__c WHERE id = :anAttachment.ParentId];
   			System.assertNotEquals(null, log.DJC_Update_Contact_Batch_Job_Start_Time__c);
   			System.assertNotEquals(null, log.DJC_Update_Contact_Batch_Job_Finish_Time__c);
   			System.assertNotEquals(null, log.DJC_Update_Contact_Job_Status__c);
		}
	}
}