/* Scheduer to send out emails at 9AM and 2 PM on daily basis. */

global class REWS_Package_Notification_Schedler implements Schedulable {
  
	global void execute(SchedulableContext SC){
		String query = REWS_Setting__c.getInstance().Mail_Services_Daily_Email_SOQL__c;
		REWS_Package_Notification_Batch batch = new REWS_Package_Notification_Batch(query); 
		database.executebatch(batch,Integer.valueOf(REWS_Setting__c.getInstance().Mail_Services_Batch_Scope__c));
	}
}