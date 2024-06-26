global class WD_Batch_UpdateJobApplications implements Database.Batchable<sObject>,Database.Stateful{

	Integer successfulUpdateCount = 0;
	Map<String, String> failedUpdates = new Map<String, String>();

    global Database.QueryLocator start(Database.BatchableContext BC){        
        String queryString = 'Select Id,SIFT_External_Rec_1_Email_Control_Flag__c,SIFT_External_Rec_2_Email_Control_Flag__c,SIFT_Internal_Rec_1_Email_Control_Flag__c,SIFT_Internal_Rec_2_Email_Control_Flag__c from WDR_Application__c';
        return Database.getQueryLocator(queryString);           
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        List<WDR_Application__c> listJobApplications = new List<WDR_Application__c>();

        for(WDR_Application__c applicaton : (List<WDR_Application__c>) scope){

            applicaton.SIFT_External_Rec_1_Email_Control_Flag__c = true;
            applicaton.SIFT_External_Rec_2_Email_Control_Flag__c = true;	
            applicaton.SIFT_Internal_Rec_1_Email_Control_Flag__c = true;
            applicaton.SIFT_Internal_Rec_2_Email_Control_Flag__c = true;
            listJobApplications.add(applicaton);
            
        }
        
        if(listJobApplications != NULL && listJobApplications.size() > 0){
        
	       	Database.SaveResult[] updateResult = Database.update(listJobApplications, false);

			for(Integer i=0;i<updateResult.size();i++){
	            if(updateResult.get(i).isSuccess()){
	                successfulUpdateCount ++;
	            }
	            else{
	                String failedJobApplicationName = String.ValueOf((scope.get(i)).Id);
	                String errorMessage = '';
	                for(Database.Error err : updateResult.get(i).getErrors()){
	                    errorMessage = errorMessage + ' | ' + err.getMessage();
	                }
	                failedUpdates.put(failedJobApplicationName,errorMessage);
	            }
        	}
    	}
    }	
    
    global void finish(Database.BatchableContext BC){

        List<String> emailIds = new List<String>();
        emailIds.add('ksrivastava@salesforce.com');
        emailIds.add('sashi.singh@salesforce.com');

        String emailIdsFromCustomSetting = IFB_SIFT_Settings_List__c.getInstance('SIFT').IFB_WD_Integration_Downstream_Err_Emails__c;
        if(!String.isEmpty(emailIdsFromCustomSetting)){
            emailIds.addAll(emailIdsFromCustomSetting.split(','));
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(emailIds);
        mail.setSenderDisplayName('JobApplications Update Batch');
        mail.setSubject('Batch WD_Batch_UpdateJobApplications results');

        String message = successfulUpdateCount + ' JobApplications Records updated successfully';

        if(!failedUpdates.isEmpty()){
            message = message + '\nFollowing ' + failedUpdates.size() +' JobApplications Records Failed to Update :\n';
            for(String jobApplicationName : failedUpdates.keySet()){
                message = message +'\n'+jobApplicationName + ' : '+failedUpdates.get(jobApplicationName);
            }
        }

        mail.setPlainTextBody(message);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        
    }
}