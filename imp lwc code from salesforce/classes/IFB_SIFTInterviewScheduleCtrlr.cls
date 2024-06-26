public with sharing class IFB_SIFTInterviewScheduleCtrlr {
    
    @InvocableMethod
	public static void sendNotifications(List<WDR_Application__c> jobApplications){
        //Iterate over WDR_Application__c to get WDR_Job
        List<Id> jobReqIds = new List<Id>();
        for(WDR_Application__c app:jobApplications){
            jobReqIds.add(app.Job__c);
        }

        List<String> emailRecipientIds = new List<String>();

        if(!jobReqIds.isEmpty()){
            Map<ID,WDR_Job__c> jobReqsMap = new Map<Id,WDR_Job__c>([SELECT Id,Recruitment_Coordinator_1__c,Recruitment_Coordinator_2__c from WDR_Job__c where id=:jobReqIds]);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply_recruiting@salesforce.com'];
            for(WDR_Application__c app:jobApplications){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
                
                if(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_1__c != null) {
                    emailRecipientIds.add(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_1__c);
                }
                
                else if(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_2__c != null) {
                    emailRecipientIds.add(jobReqsMap.get(app.Job__c).Recruitment_Coordinator_2__c);
                }
                
                else {
                    IFB_SIFT_Settings_List__c currentSettings = IFB_SIFT_Settings_List__c.getOrgDefaults();
                    emailRecipientIds = currentSettings.SIFT_RC_Ids__c.split(',');
                }
                mail.setToAddresses(emailRecipientIds);
                mail.setSubject('Peopleforce SIFT Record is ready for '+app.Candidate_Name__c);
                String body = 'The application record for '+app.Candidate_Name__c +' has been created in Peopleforce. Please use this link to create the SIFT interview when you are ready.\n\n'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/IFB_NewSIFTInterviewWizard?id=' + app.Id+'\n\nThank You!';
                mail.setPlainTextBody(body);
                mail.setWhatId(app.Id);
                mail.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.Email[] { mail } );
            }
        }
    }
}