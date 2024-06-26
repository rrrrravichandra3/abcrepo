/**
 * @description       : Class used by "Insiders Invitation Email Flow" Flow. Sends notification emails for
 *                      External Recruiter 1 and 2 on Job Requisition
 * @author            : lolivera@salesforce.com
 * @last modified on  : 03-29-2022
 *
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-29-2022   lolivera@salesforce.com              Initial Version
 * 2.0   07-29-2022   m.pal@salesforce.com                 Updated Version : Added cc email address for Ext Cordinator 1/2
 * 3.0   08-30-2022   m.pal@salesforce.com                 Updated Version : Added logic to update Recruiter email checkbox in IVT record after email sent
 **/
public without sharing class IA_RecruiterNotification {

    //public variable for updating IVT record from IA_Send_Invitation_Email_TriggerHandler when email sent
    public static List<Insiders_Tracking__c> trackingRecordsToUpsert = new List<Insiders_Tracking__c>();
    public static boolean isEmailSent = false;

    //Send Recruiter email notification 
    /**
     * @description : Sends notification emails for External Recruiter 1 and 2 on Job Requisition.
     *
     * @param jobAppIds List of Ids of WDR_Application__c records for which emails need to be sent.
     * @return A map where the key is the Id of the job application and the value is a Boolean indicating whether an email was successfully sent for that job application.
     */
    public static map<Id, Boolean> sendRecruiterNotification(List<Id> jobAppIds) {
		map<Id, Boolean> mapRecruiterEmailSent =new map<Id, Boolean>();
        try {
            // Get Job Requisition Data
            List<WDR_Application__c> jobAppsWithJobReqData = [SELECT Candidate__r.Candidate_Contact__c, Candidate__c, Internal_Candidate__c,
                                                              Job__r.External_Recruiter_1__r.Email, Job__r.External_Recruiter_2__r.Email,
                                                              Job__r.Recruitment_Coordinator_1__r.Email, Job__r.Recruitment_Coordinator_2__r.Email,
                                                              Job__r.Internal_Recruiter_1__r.Email, Job__r.Internal_Recruiter_2__r.Email, Job__r.Internal_Recruitment_Coordinator_1__r.Email,
                                                              Job__r.Internal_Recruitment_Coordinator_2__r.Email FROM WDR_Application__c WHERE Id  IN :jobAppIds ];
            
            // Prepare email data
            EmailTemplate extRecruiter1EmailTemplate = [SELECT Id, Subject, Description, Markup, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'Insiders_Ext_Recruiter1_Notification'];
            
            
            List<Messaging.Email> emailsToSend = new List<Messaging.Email>();
            
            OrgWideEmailAddress senderAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'insiders@salesforce.com' LIMIT 1];
            
            // Send Email to Recruiters and Cordinator in cc if they exist
            for (WDR_Application__c jobApp : jobAppsWithJobReqData) {
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(extRecruiter1EmailTemplate.Id, null, jobApp.Id);
               	mail.setOrgWideEmailAddressId(senderAddress.Id);
                map<string,list<string>> mapSenderDetails;
                //Removed condition for Internal & External as in WD4S no specific recruiters for Internal/External
                mapSenderDetails = externallRecruiterNotification(jobApp);
                if(mapSenderDetails.containsKey('SendToAddress') && !mapSenderDetails.get('SendToAddress').isEmpty()){
                    mail.setToAddresses(mapSenderDetails.get('SendToAddress'));
                    if(mapSenderDetails.containsKey('SendCCAddress') && !mapSenderDetails.get('SendCCAddress').isEmpty()){
                    	mail.setccAddresses(mapSenderDetails.get('SendCCAddress')); 
                    }
                    if(mapSenderDetails.get('SendToAddress') != null){
                    	emailsToSend.add(mail);
						mapRecruiterEmailSent.put(jobApp.id, true);
                    }
                }
            }
            // Send emails
            if (emailsToSend.size() > 0){
                Messaging.sendEmail(emailsToSend);
            }
        } catch (Exception ex) {
            List<String> errorMessages = new List<String>();
            errorMessages.add(ex.getMessage());
            IA_Util.sendExceptionMail(errorMessages);
        }
		return mapRecruiterEmailSent;
    }
    /**
     * @description  : This method verifies the existence of external recruiters and recruitment coordinators, and prepares the email data for sending notifications.
     *
     * @param jobApplication The WDR_Application__c record for which the notification email needs to be sent.
     * @return A map containing the 'SendToAddress' and 'SendCCAddress' lists of email addresses for external recruiters and coordinators.
     */
    //Verify external recruiters and recruiter coordinates exist or not
    public static map<string,list<string>> externallRecruiterNotification(WDR_Application__c jobApplication) {
        map<string,list<string>> mapOfExternalsenderDetails = new map<string,list<string>>();
        List<String> emailAddressExtRecruiter = new List<String>();
        List<String> ccemailAddressExtRC = new List<String>();
        if (!String.isBlank(jobApplication.Job__r.External_Recruiter_1__r.Email) || !String.isBlank(jobApplication.Job__r.External_Recruiter_2__r.Email)) {
            if(!String.isBlank(jobApplication.Job__r.External_Recruiter_1__r.Email)){
                emailAddressExtRecruiter.add(jobApplication.Job__r.External_Recruiter_1__r.Email);  
            }
            if(!String.isBlank(jobApplication.Job__r.External_Recruiter_2__r.Email)){
                emailAddressExtRecruiter.add(jobApplication.Job__r.External_Recruiter_2__r.Email);   
            }
            if(!String.isBlank(jobApplication.Job__r.Recruitment_Coordinator_1__r.Email)){
                ccemailAddressExtRC.add(jobApplication.Job__r.Recruitment_Coordinator_1__r.Email);   
            }
            if(!String.isBlank(jobApplication.Job__r.Recruitment_Coordinator_2__r.Email)){
                ccemailAddressExtRC.add(jobApplication.Job__r.Recruitment_Coordinator_2__r.Email);   
            }
            
            if(!emailAddressExtRecruiter.isEmpty()){
                mapOfExternalsenderDetails.put('SendToAddress',emailAddressExtRecruiter);
            }
            if(!ccemailAddressExtRC.isEmpty()){
                mapOfExternalsenderDetails.put('SendCCAddress',ccemailAddressExtRC);
            }
        }
        //Condition to check when Both PR1 & PR2 are blank
        //Send email to RC1 & RC2 in "to" section of email
        else{
            if(!String.isBlank(jobApplication.Job__r.Recruitment_Coordinator_1__r.Email)){
                emailAddressExtRecruiter.add(jobApplication.Job__r.Recruitment_Coordinator_1__r.Email);   
            }
            if(!String.isBlank(jobApplication.Job__r.Recruitment_Coordinator_2__r.Email)){
                emailAddressExtRecruiter.add(jobApplication.Job__r.Recruitment_Coordinator_2__r.Email);   
            }
            if(!emailAddressExtRecruiter.isEmpty()){
                mapOfExternalsenderDetails.put('SendToAddress',emailAddressExtRecruiter);
            }
        }
        
        return mapOfExternalsenderDetails;
    }
    /**
     * @description  : This method verifies the existence of internal recruiters and internal recruitment coordinators, and prepares the email data for sending notifications.
     *
     * @param jobApplication The WDR_Application__c record for which the notification email needs to be sent.
     * @return A map containing the 'SendToAddress' and 'SendCCAddress' lists of email addresses for internal recruiters and coordinators.
     */
    //verify Send Email to internal Recruiters and  internal Cordinator in cc if they exist or not
    public static map<string,list<string>> internalRecruiterNotification(WDR_Application__c jobApplication) {
        String recruiter1 = jobApplication.Job__r.Internal_Recruiter_1__r.Email;
        String recruiter2 = jobApplication.Job__r.Internal_Recruiter_2__r.Email;
        String recruiterCordinator1 = jobApplication.Job__r.Internal_Recruitment_Coordinator_1__r.Email;
        String recruiterCordinator2 = jobApplication.Job__r.Internal_Recruitment_Coordinator_2__r.Email;
        String externalRec1 = jobApplication.Job__r.External_Recruiter_1__r.Email;
        String externalRec2 = jobApplication.Job__r.External_Recruiter_2__r.Email;
        
        map<string,list<string>> mapOfsenderDetails = new map<string,list<string>>();
        List<String> internalToaddress= new List<String>();
        List<String> internalCCaddress= new List<String>();
        //if all internal recruiter and all recruitercordinators are available
        if (!String.isBlank(recruiter1) && !String.isBlank(recruiter2) && !String.isBlank(recruiterCordinator1) && !String.isBlank(recruiterCordinator2)) {
			internalToaddress.add(recruiter1);
            internalToaddress.add(recruiter2);
            internalCCaddress.add(recruiterCordinator1);
            internalCCaddress.add(recruiterCordinator2);
        }
        //if all internal recruiter and all recruitercordinators are not available then send notification to External recruiters
        else if (String.isBlank(Recruiter1) && String.isBlank(Recruiter2) && String.isBlank(RecruiterCordinator1) && String.isBlank(RecruiterCordinator2)) {
            if(!String.isBlank(externalRec1)){
            	internalToaddress.add(externalRec1);
            }
            if(!String.isBlank(externalRec2)){
            	internalToaddress.add(externalRec2);
            }
        }
        //If all Internal recruiters are not available send notification to recruiter cordinators
        else if (String.isBlank(Recruiter1) && String.isBlank(Recruiter2) && (!String.isBlank(RecruiterCordinator1) || !String.isBlank(RecruiterCordinator2))) {
        	if(!String.isBlank(recruiterCordinator1)){
                internalToaddress.add(recruiterCordinator1);
            }
            if(!String.isBlank(recruiterCordinator2)){
                internalToaddress.add(recruiterCordinator2);
            }
        }
        //If all Internal recruiters are available send notification to recruiters and coordinators not available
        else if ((!String.isBlank(Recruiter1) || !String.isBlank(Recruiter2)) && String.isBlank(RecruiterCordinator1) && String.isBlank(RecruiterCordinator2)) {
        	if(!String.isBlank(Recruiter1)){
                internalToaddress.add(Recruiter1);
            }
            if(!String.isBlank(Recruiter2)){
                internalToaddress.add(Recruiter2);
            }
        }
        //recruiter or recruiter coordinators any one available send notification
        else if ((!String.isBlank(Recruiter1) || !String.isBlank(Recruiter2)) && (!String.isBlank(RecruiterCordinator1) || !String.isBlank(RecruiterCordinator2))) {
        	if(!String.isBlank(recruiter1)){
            	internalToaddress.add(recruiter1);
            }
            if(!String.isBlank(recruiter2)){
            	internalToaddress.add(recruiter2);
            }
            if(!String.isBlank(recruiterCordinator1)){
            	internalCCaddress.add(recruiterCordinator1);
            }
            if(!String.isBlank(recruiterCordinator2)){
            	internalCCaddress.add(recruiterCordinator2);
            }
        }
        
        if(!internalToaddress.isEmpty()){
        	mapOfsenderDetails.put('SendToAddress',internalToaddress);
        }
        if(!internalCCaddress.isEmpty()){
        	mapOfsenderDetails.put('SendCCAddress',internalCCaddress);
        }
        return mapOfsenderDetails;
    }
}