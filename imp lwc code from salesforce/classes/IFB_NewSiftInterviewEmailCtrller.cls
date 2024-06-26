//This class is used to send New Sift Interview email to the recruiting coordinators.
public without sharing class IFB_NewSiftInterviewEmailCtrller {
    
    @InvocableMethod
    public static void sendNewSIFTInterviewEmail(List<WDR_Application__c> jobApplications){

        try{
            system.debug(LOGGINGLEVEL.INFO,'jobApplications - '+jobApplications);
            
            //Iterate over WDR_Application__c to get WDR_Job
            List<Id> jobReqIds = new List<Id>();
            List<String> emailRecipientIds  = new List<String>();
            
            for(WDR_Application__c app:jobApplications){
                jobReqIds.add(app.Job__c);
            }
            
            IFB_SIFT_Settings_List__c currentSettings = IFB_SIFT_Settings_List__c.getOrgDefaults();
            
            if(!jobReqIds.isEmpty()){
                Map<ID,WDR_Job__c> jobReqsMap = new Map<Id,WDR_Job__c>([SELECT Id,Recruitment_Coordinator_1__r.email,Recruitment_Coordinator_2__r.email,Internal_Recruitment_Coordinator_1__r.email, Internal_Recruitment_Coordinator_2__r.email   from WDR_Job__c where id=:jobReqIds]);
                
                for(WDR_Application__c app:jobApplications){
                    if(app.Internal_Candidate__c){
                        if(jobReqsMap.get(app.Job__c).Internal_Recruitment_Coordinator_1__c != null) {
                        	emailRecipientIds.add(jobReqsMap.get(app.Job__c).Internal_Recruitment_Coordinator_1__r.email);
                    	}
                    
                    	else if(jobReqsMap.get(app.Job__c).Internal_Recruitment_Coordinator_2__c != null) {
                        
                        	emailRecipientIds.add(jobReqsMap.get(app.Job__c).Internal_Recruitment_Coordinator_2__r.email);
                    	}
                    	else if(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_1__c != null) {
                        	emailRecipientIds.add(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_1__r.email);
                    	}
                    
                    	else if(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_2__c != null) {
                        
                        	emailRecipientIds.add(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_2__r.email);
                    	}
                        else {
                        emailRecipientIds = currentSettings.SIFT_RC_Ids__c.split(',');
                    	}
                    }
                    else {
                    	if(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_1__c != null) {
                        	emailRecipientIds.add(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_1__r.email);
                    	}
                    
                    	else if(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_2__c != null) {
                        
                        	emailRecipientIds.add(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_2__r.email);
                    	}
                        else {
                        emailRecipientIds = currentSettings.SIFT_RC_Ids__c.split(',');
                    	}
                    }
                    
                    
                    
                    string subject = 'Peopleforce SIFT Record is ready for '+app.Candidate_Name__c;
                    String body = 'The application record for '+app.Candidate_Name__c +' has been created in Peopleforce. Please use this link to create the SIFT interview when you are ready.\n\n'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/IFB_NewSIFTInterviewWizard?id=' + app.Id+'\n\nThank You!';
                    
                    system.debug(LOGGINGLEVEL.INFO,'emailRecipientIds'+emailRecipientIds);
                    Map<String, Object> inputVarMap = new Map<String, Object>();
                    inputVarMap.put('emailRecipientIds', emailRecipientIds);
                    inputVarMap.put('body',body);
                    inputVarMap.put('subject', subject);
                    inputVarMap.put('OWEA',currentSettings.Recruiting_OWEA__c);                
                    
                    //Invoke the flow from apex.The flow is set to run in system context.
                    //This is workaround as the email Services in apex runs in user context and RC does not have access to OWEA.
                    Flow.Interview.sendEmailFromOWEA  sendEmailFromOWEAFlow = new  Flow.Interview.sendEmailFromOWEA(inputVarMap);
                    
                    //Bulkification Note : Each Job app creates a flow interview(instance of flow).
                    //However, When multiple flow interviews exist for same flow in a transaction, AND when they have bulkifiable flow elements.(Eg:Email)
                    //Platform automatically bulkfies and executes them in a batch, 
                    // More Info - https://developer.salesforce.com/docs/atlas.en-us.216.0.salesforce_vpm_guide.meta/salesforce_vpm_guide/vpm_admin_bulkification.htm#vpm_admin_bulkification
                    
                    sendEmailFromOWEAFlow.start();                      
                    emailRecipientIds.clear();
  
                }
            }
        }
        catch(Exception ex){
                PF_Logger.log('SIFT','ERROR',ex.getMessage(),'Error while sending email to RC',ex.getStackTraceString(), 'IFB_NewSiftInterviewEmailCtrller');
                NHW_Util.insertNHWLogs();

        }
    }
        
}