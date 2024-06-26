global class CEMCI_DuplicateContactCleanupSchedule implements Schedulable{ 
    
	@ReadOnly 
	global void execute (SchedulableContext sc){ 
        
        List<String> duplicateEmails = new List<String>();
        
        try{
            Confidential_WD_Candidate_Fields__mdt batchSetting = [Select Custom_Soql__c, List_of_Fields__c, batch_size__c  from Confidential_WD_Candidate_Fields__mdt where DeveloperName='ContactDupeCleanup'];
            if(batchSetting != null){
                String queryStr = batchSetting.Custom_Soql__c;
                
                for(AggregateResult ar : Database.query(queryStr)){ 
                    duplicateEmails.add(String.valueof(ar.get('email')).tolowercase());
                } 
                
                if(duplicateEmails.size() > 0){
                    CEMCI_DuplicateContactCleanupBatch cleanup = new CEMCI_DuplicateContactCleanupBatch(duplicateEmails,sc.getTriggerId(),batchSetting.List_of_Fields__c); 
                    Database.executeBatch(cleanup,Integer.valueOf(batchSetting.batch_size__c)); 
                }
                else{
                    System.abortJob(sc.getTriggerId());
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setToAddresses(new List<String>{'asreekumar@salesforce.com'});
                    msg.setSubject('CEMCI_DuplicateContactCleanupSchedule Execution Complete');
                    msg.setPlainTextBody('CEMCI_DuplicateContactCleanupSchedule finished processing');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg}); 
                }
            }
    	}
        catch(Exception e){
            PF_Logger.log('CEMCI','ERROR',e.getMessage(),e.getTypeName(), e.getLineNumber()
            +' Error during Contact cleanup' + ' UserId '+ UserInfo.getUserId(), 'CEMCI_DuplicateContactCleanupSchedule');
            
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
}