public with sharing class ESDJC_Integration_Log_Handler {
	public static void processIntegrationUpdates(List<ESDJC_Integration_Log__c> logs) {
		for(ESDJC_Integration_Log__c log : logs){
			if(log.Integration_Start_Time__c != null && log.Integration_Finish_Time__c != null){
				if(log.Integration_Finish_Time__c.getTime() >= log.Integration_Start_Time__c.getTime()){
					if(log.Integration_Status__c != null && log.Integration_Status__c != ''){
						if(log.Integration_Status__c == 'Success' && log.DJC_New_User_Batch_Job_Start_Time__c == null){
							ESDJC_New_User_Batch newUsersBatch = new ESDJC_New_User_Batch(log);
							Database.executeBatch(newUsersBatch);
						}
						if(log.Integration_Status__c == 'Success' && log.DJC_New_User_Batch_Job_Finish_Time__c != null 
									&& log.DJC_Update_User_Batch_Job_Start_Time__c == null){
							ESDJC_Update_User_Batch updateUsersBatch = new ESDJC_Update_User_Batch(log);
							Database.executeBatch(updateUsersBatch);
						}
						if(log.Integration_Status__c == 'Success' && log.DJC_Update_User_Batch_Job_Finish_Time__c!=null 
																	&& log.DJC_New_Contractor_Batch_Job_Start_Time__c == null){
							ESDJC_New_User_Contractor_Batch newContractorsBatch = new ESDJC_New_User_Contractor_Batch(log);
							//Database.executeBatch(newContractorsBatch);
						}
						if(log.Integration_Status__c == 'Success' && log.DJC_New_Contractor_Batch_Job_Finish_Time__c != null 
																	&& log.DJC_Update_Contractor_Batch_Start_Time__c == null){
							ESDJC_Update_Contractor_User_Batch updateContractorsBatch = new ESDJC_Update_Contractor_User_Batch(log);
							//Database.executeBatch(updateContractorsBatch);
						}
						
						/*
						if(log.Integration_Status__c == 'Success' && log.DJC_Update_User_Batch_Job_Finish_Time__c != null && log.DJC_Update_User_Job_Status__c != null && log.DJC_Update_Contact_Batch_Job_Start_Time__c == null){
							ESDJC_Update_Contact_Batch updateContactBatch = new ESDJC_Update_Contact_Batch(log);
							Database.executeBatch(updateContactBatch);
						}*/
					}
				}
			}
		}
	}
}