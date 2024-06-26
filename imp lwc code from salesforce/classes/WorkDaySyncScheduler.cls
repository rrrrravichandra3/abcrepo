global class WorkDaySyncScheduler implements Schedulable  {
	
global void execute(SchedulableContext SC) {
		runBatch();
	}
	
	void runBatch() {
		TF2Settings__c configurations = TF2Settings__c.getInstance();
		Integer days = 6;
		if (configurations.WD_Sync_Days__c != null) {
			days =Integer.valueOf(configurations.WD_Sync_Days__c);    
		} 
	}
	
	static testMethod void testSchedule() {
		
	}
	
	
}