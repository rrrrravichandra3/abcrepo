/**
 * @author Angel Abrego <aabrego@salesforce.com>
 * @description Tests remainder (email) that is sent to the interviewer(s) 
 * before the Interview.
 */
@isTest
private class IFBTest_InterviewerNotification {
  
  // There should be an email template in english (en) to remind the interviewer
  // about the interview
  @isTest static void testEmailTemplateExists_en() {
    String templateName       = 'SIFT_Interviewer_Reminder_en';
    String templateFolderName = 'SIFT_Email_Templates';

    List<EmailTemplate> res = [select Id 
                                from EmailTemplate 
                                where DeveloperName      = :templateName
                                and Folder.DeveloperName = :templateFolderName];

    System.assertEquals(1, res.size(), 'Email template not found');
  }

}