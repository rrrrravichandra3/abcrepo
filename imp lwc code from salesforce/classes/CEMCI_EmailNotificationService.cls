/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 08-05-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
public with sharing class CEMCI_EmailNotificationService {
  @Auraenabled
  public static Boolean sendEmail(Id jobReqId, List<String> candidatePoolUpdatedStatuses) {
    Boolean emailSent;
    WDR_Job__c jobReq = getJobReq(jobReqId);

    for (String candidateStatus : candidatePoolUpdatedStatuses) {
      emailSent = sendStatusBasedEmail(candidateStatus, jobReq);
    }
    return emailSent;
  }

  private static Boolean sendStatusBasedEmail(String status, WDR_Job__c jobReq) {
    String metadataName = 'CEMCI ' + status;
    String replacedHtmlBody;
    String replacedSubject;
    CEMCI_Notification__mdt emailData;
    String jobLink =
      '<a href="' +
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/lightning/n/manage_candidate_pool_tab?c__recordId=' +
      jobReq.Id +
      '"> here </a>';

    try {
      emailData = [SELECT subject__c, body__c FROM CEMCI_Notification__mdt WHERE label = :metadataName];
    } catch (Exception e) {
      return false;
    }
    replacedHtmlBody = emailData.body__c.replace('{HMName}', jobReq.Hiring_Manager__r.Name);
    replacedHtmlBody = replacedHtmlBody.replace('{RecruiterName}', jobReq.External_Recruiter_1__r.Name);
    replacedHtmlBody = replacedHtmlBody.replace('{JobName}', jobReq.Name);
    replacedHtmlBody = replacedHtmlBody.replace('{JobId}', jobReq.Id);
    replacedHtmlBody = replacedHtmlBody.replace('{JobLink}', jobLink);
    replacedSubject = emailData.subject__c.replace('{JobName}', jobReq.Name);

    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.setUseSignature(false);
    message.setBccSender(false);
    message.setSaveAsActivity(false);

    message.setSubject(replacedSubject);
    message.setHtmlBody(replacedHtmlBody);
    if (status == 'Hiring Manager Review') {
      message.toAddresses = new List<String>{ jobReq.Hiring_Manager__r.email };
    } else {
      message.toAddresses = new List<String>{ jobReq.External_Recruiter_1__r.email };
      if (jobReq.External_Recruiter_2__c != null && jobReq.External_Recruiter_2__r.email != null) {
        message.ccAddresses = new List<String>{ jobReq.External_Recruiter_2__r.email };
      }
    }

    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    if (results[0].success) {
      return true;
    } else {
      return false;
    }
  }

  private static WDR_Job__c getJobReq(Id jobReqId) {
    return [
      SELECT
        Name,
        Hiring_Manager__c,
        Hiring_Manager__r.Name,
        Hiring_Manager__r.email,
        External_Recruiter_1__c,
        External_Recruiter_1__r.Name,
        External_Recruiter_1__r.email,
        External_Recruiter_2__c,
        External_Recruiter_2__r.email
      FROM WDR_Job__c
      WHERE Id = :jobReqId
    ];
  }
}