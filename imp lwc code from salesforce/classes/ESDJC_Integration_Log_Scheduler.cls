global class ESDJC_Integration_Log_Scheduler implements Schedulable {
	
	global void execute(SchedulableContext SC){
		
		ESDJC_Integration_Log__c log_record = new ESDJC_Integration_Log__c();
		log_record.Name = String.valueOf(Datetime.now());
		log_record.Integration_Start_Time__c = Datetime.now();
		log_record.Integration_Finish_Time__c = Datetime.now();
		log_record.Integration_Status__c = 'Success';	
		Database.Saveresult s = Database.insert(log_record);
		if (s.isSuccess()){
			update log_record;
		}	
		
	}

}