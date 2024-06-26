/**
 * @description       : Class used by "IA_SendEmailToCandidate" Process.
 * @author            : lolivera@salesforce.com
 * @last modified on  : 09-30-2021
 * 
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   07-30-2021   lolivera@salesforce.com              Initial Version
 * 1.1   09-30-2021   lolivera@salesforce.com              Bug fix for empty values on Custom Settings
 **/
public with sharing class IA_JobApplicationPlacement {  
    @InvocableMethod
    public static void sendCandidateHireNotificationToVolunteer(List<id> jobAppIds) {
        try {
            // Retrieve all Candidate Contact IDs to query related ServiceAppointment
            List<WDR_Application__c> jobAppList = [SELECT Candidate__r.Candidate_Contact__c FROM WDR_Application__c WHERE Id IN :jobAppIds];
            Set<Id> candidateContactIds = new Set<Id>();
            for (WDR_Application__c jobApp : jobAppList) {
                candidateContactIds.add(jobApp.Candidate__r.Candidate_Contact__c);
            }
            

            // Prepare email data
            EmailTemplate emailTemplate = [SELECT Id, Subject, Description, Markup, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'Insider_Volunteer_Live_Hire_Notification'];
            List<Messaging.Email> emailsToSend = new List<Messaging.Email>();

            IA_Program_Admin__c cs = IA_Program_Admin__c.getValues('HireEmailCC');

            List<String> ccEmails = new List<String>();
            if (!String.isBlank(cs.EmailsToCC__c)) {
                ccEmails = cs.EmailsToCC__c.split(',');
            }

            // Retrieve ServiceAppointment, check if it is in 'Completed' status to send email notification
            List<ServiceAppointment> saList = [SELECT Status, SchedStartTime, Candidate_Name__c, ContactId, Insider_Volunteer__r.RelatedRecordId, Email FROM ServiceAppointment 
                                               WHERE ContactId IN :candidateContactIds];
            OrgWideEmailAddress senderAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'insiders@salesforce.com' LIMIT 1];


            for (ServiceAppointment sa : saList) {
                if(sa.Status == 'Completed' && sa.SchedStartTime.date().daysBetween(system.now().date())<=90) {
                    List<String> emailAddress = new List<String>();
                    emailAddress.add(sa.Email);
					Messaging.SingleEmailMessage mail;
                    if(!test.isRunningTest()){
						 mail = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, sa.Id);    
                    }else{
                         mail = new Messaging.SingleEmailMessage();
                    }
                    mail.setSubject('Welcome ' + sa.Candidate_Name__c + ' Inside!');
                    mail.setOrgWideEmailAddressId(senderAddress.Id);
                    mail.setToAddresses(emailAddress);
                    if(ccEmails.size() > 0) {
                        mail.setCcAddresses(ccEmails);
                    }

                    emailsToSend.add(mail);
                }
            }
            Messaging.sendEmail(emailsToSend);

        } catch(Exception ex) {
            List<String> errorMessages = new List<String>();
            errorMessages.add(ex.getMessage());
            IA_Util.sendExceptionMail(errorMessages);
        }   
    }
}