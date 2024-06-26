@isTest
public with sharing class Test_ESDJC_EmailMessageWorkflows {

    /**
     * Test if a closed case gets reopened when there is an incoming email
     */
    public static testMethod void testReopenCase() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        System.runAs(sysAdm) {
            init();
            User portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
            
            String caseId = null;
            
            //Create a case
            System.runAs(portalUser) {
                Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers');
                c.ES_DJC_Topic__c = '401K';
                c.ES_DJC_Sub_Topic__c = 'Change Amount';
                
                insert c;
                caseId = c.Id;
            }
            System.assert(caseId != null);
            
            //close case
            update (new Case(Id=caseId, Status='Closed'));
            
            System.assertEquals('Closed', [select Status from Case where Id=:caseId].Status);
            
            Test.startTest();
            //Insert an email message
            EmailMessage em = new EmailMessage(ParentId = caseId, Subject = 'New Email Message', Incoming=true);
            insert em;
            
            //Assert case has reopened
            System.assertEquals('Re-Opened', [select Status from Case where Id=:caseId].Status);
            Test.stopTest();
        }
    }
    
    /**
     * Test if a case status gets updated if its status is 'In Progress' 
     * or 'Waiting for Response'
     */
    public static testMethod void testCaseStatusUpdated() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        System.runAs(sysAdm) {
            init();
            User portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
            
            String caseId = null;
            
            //Create a case
            System.runAs(portalUser) {
                Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers');
                c.ES_DJC_Topic__c = '401K';
                c.ES_DJC_Sub_Topic__c = 'Change Amount';
                
                insert c;
                caseId = c.Id;
            }
            System.assert(caseId != null);
            
            Test.startTest();
            //close case
            update (new Case(Id=caseId, Status='In Progress'));
            System.assertEquals('In Progress', [select Status from Case where Id=:caseId].Status);
            
            //Insert an email message
            EmailMessage em = new EmailMessage(ParentId = caseId, Subject = 'New Email Message', Incoming=true);
            insert em;
            
            //Assert case status
            System.assertEquals('Updated', [select Status from Case where Id=:caseId].Status);
            
            //Change case status to 'Waiting for Response'
            update (new Case(Id=caseId, Status='Waiting for Response'));
            System.assertEquals('Waiting for Response', [select Status from Case where Id=:caseId].Status);
            
            //Create another incoming email message
            EmailMessage em2 = new EmailMessage(ParentId = caseId, Subject = 'New Email Message 2', Incoming=true);
            insert em2;
            
            //Assert case status
            System.assertEquals('Updated', [select Status from Case where Id=:caseId].Status);
            
            Test.stopTest();
        }
    }
    
    private static void init(){
        ESDJC_Settings__c setting = new ESDJC_Settings__c();
        setting.Run_trigger__c = true;
        setting.Site_URL__c = '/site/url';
        setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
        setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
        setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
        setting.Valid_SLA_Origins__c='Employee Success - Web,REWS - Web,Chatter Answers,Email,Concierge Desktop,Concierge Mobile,Article Feedback';
        setting.Ergo_Locations__c = 'san francisco,new york,chicago,portland,spokane,toronto';
        insert setting;
        REWS_Setting__c rewsSetting = new REWS_Setting__c();
        rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
        rewsSetting.Case_Package_Delivery_Record_Type__c = '00Gn0000000JH8YEAW';
        insert  rewsSetting;
    }
}