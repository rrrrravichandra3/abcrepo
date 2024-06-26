@isTest
public with sharing class Test_ESDJC_CaseCommentHandler {       
    
    //portal user: adding case comment should reopen a closed case         
    private static testmethod void testCaseStatusOnCaseCommentForPortalUser(){        
        init();        
        User u = ESDJC_TestUtil.getPortalUser('India','EMEA');                  
        Case aCase;
        System.runAs(u){
            Test.startTest();
            aCase = new Case();
            aCase.subject='Testing case comments';
            aCase.origin='Chatter Answers';
            aCase.Type='Separations';
            aCase.status='Closed';
            aCase.contactId= [select ContactId from user where id =:u.id].ContactId;
            insert aCase;
            System.assert(aCase.id!=null);
            List<CaseComment> caseComments = new List<CaseComment>();
            for(Integer i=0;i<1;i++){
                CaseComment cc = new CaseComment();
                cc.parentId = aCase.id;
                cc.CommentBody='testing case comment'+i;
                cc.isPublished=true;
                caseComments.add(cc);
            }
            insert caseComments;
            Test.stopTest();                                  
        }
        Case newCase = [select isClosed from case where id = :aCase.id];
        system.assertEquals(false, newCase.isClosed);                                               
    }
    
    //Concierge: adding case comment should NOT reopen a closed case
    private static testmethod void testCaseStatusOnCaseCommentForConciergeUser(){
        init();                
        User u = ESDJC_TestUtil.getConciergeUser('USA','AMER');        
        Case aCase;            
        System.runAs(u){
            Test.startTest();
            aCase = new Case();
            aCase.subject='Testing case comments';
            aCase.origin='Chatter Answers';
            aCase.Type='Separations';
            aCase.status='Closed';
            aCase.contactId= [select ContactId from user where id =:u.id].ContactId;
            insert aCase;
            System.assert(aCase.id!=null);
            List<CaseComment> caseComments = new List<CaseComment>();
            for(Integer i=0;i<1;i++){
                CaseComment cc = new CaseComment();
                cc.parentId = aCase.id;
                cc.CommentBody='testing case comment'+i;
                cc.isPublished=true;
                caseComments.add(cc);
            }
            insert caseComments;
            Test.stopTest();
        }
        Case newCase = [select isClosed from case where id = :aCase.id];
        system.assertEquals(true, newCase.isClosed);                                                                                                            
    } 
    
    private static testmethod void testCaseStatusUpdateonConciergecomment(){
        init();                
        User u = ESDJC_TestUtil.getConciergeUser('USA','AMER');     
        Case aCase;            
        System.runAs(u){
            ESDJC_Settings__c setting = [select Concierge_API_User_Profile_Id__c from ESDJC_Settings__c];
            setting.Concierge_API_User_Profile_Id__c=u.profileid;
            update setting;
            Test.startTest();
            aCase = new Case();
            aCase.subject='Testing case comments';
            aCase.origin='Chatter Answers';
            aCase.Type='Separations';
            aCase.status='In Progress';
            aCase.contactId= [select ContactId from user where id =:u.id].ContactId;
            insert aCase;
            
            System.assert(aCase.id!=null);
            Case newCase1 = [select status,isClosed from case where id = :aCase.id];
            system.assertEquals('In Progress', newCase1.status);                                                                                                            

            List<CaseComment> caseComments = new List<CaseComment>();
            for(Integer i=0;i<1;i++){
                CaseComment cc = new CaseComment();
                cc.parentId = aCase.id;
                cc.CommentBody='testing case comment'+i;
                cc.isPublished=true;
                caseComments.add(cc);
            }
            insert caseComments;
            Test.stopTest();
        }
        Case newCase = [select status,isClosed from case where id = :aCase.id];
        system.assertEquals('Updated', newCase.status);                                                                                                            
    }
    
    static testmethod void testUpdatePrivateCaseComments(){
        init();                
        User u = ESDJC_TestUtil.getConciergeUser('USA','AMER');        
        Case aCase;            
        System.runAs(u){
            Test.startTest();
            aCase = new Case();
            aCase.subject='Testing case comments';
            aCase.origin='Chatter Answers';
            aCase.Type='Separations';
            aCase.status='Closed';
            aCase.contactId= [select ContactId from user where id =:u.id].ContactId;
            aCase.ESDJC_Supportforce_Case_Number__c = '12345';
            insert aCase;
            System.assert(aCase.id!=null);
            List<CaseComment> caseComments = new List<CaseComment>();
            for(Integer i=0;i<2;i++){
                CaseComment cc = new CaseComment();
                cc.parentId = aCase.id;
                cc.CommentBody='testing case comment'+i;
                cc.isPublished=false;
                caseComments.add(cc);
            }
            insert caseComments;
            Test.stopTest();
        }
        Case newCase = [select isClosed from case where id = :aCase.id];
        system.assertEquals(true, newCase.isClosed);                                                                                                            
    }
    
    static testmethod void testCheckValidationsConsole() {
        Test.startTest();
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        System.runAs(sysAdm) {
            init();
            User portalUser = ESDJC_TestUtil.getPortalUser('US', 'AMER');
            ESDJC_Settings__c settings = new ESDJC_Settings__c();
            settings.SetupOwnerId = sysAdm.Id;
            settings.Portal_User_Profile_Id__c = '00e70000000xEB1';
            settings.Concierge_API_User_Profile_Id__c = '00e0g0000010FNG';
            settings.MoveWorks_API_User_Profile_Id__c = '00e0g0000010FNG';
            settings.djc_Helpdesk_API_User__c = '00e0g0000010FNG';
            settings.Site_URL__c = 'https://www.google.com';
            insert settings;
            
            //create a case
            Case c = new Case(ContactId=portalUser.ContactId, Subject='Test Private Question', Type='Benefits', Description='Test Description', Status='New', Origin='Chatter Answers');
            c.ES_DJC_Topic__c = '401K';
            c.ES_DJC_Sub_Topic__c = 'Change Amount';
            insert c;
            
            // create case comment
            CaseComment cc = new CaseComment(ParentId=c.Id, CommentBody='Test Comment Body');
            insert cc;
            
            System.assertEquals('New', c.Status, 'The Status value is incorrect.');
        }
    }
    
    static testmethod void testPublicCommentValidation(){  
        init();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Warmline'];
        PermissionSetAssignment psa = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id][0];
        User u = ESDJC_TestUtil.getConciergeUser('USA','AMER');
        User runAsUser = [SELECT Id FROM User WHERE Id = :psa.AssigneeId];
        
        Case aCase;            
        System.runAs(runAsUser){
            Test.startTest();
            
            ESDJC_Settings__c settings = new ESDJC_Settings__c();
            settings.SetupOwnerId = runAsUser.Id;
            settings.Portal_User_Profile_Id__c = '00e70000000xEB1';
            settings.Concierge_API_User_Profile_Id__c = '00e0g0000010FNG';
            settings.MoveWorks_API_User_Profile_Id__c = '00e0g0000010FNG';
            settings.djc_Helpdesk_API_User__c = '00e0g0000010FNG';
            settings.Site_URL__c = 'https://www.google.com';
            settings.Run_trigger__c = true;
            insert settings;
            
            aCase = new Case();
            aCase.subject='Testing case comments';
            aCase.origin='Chatter Answers';
            aCase.Type='Separations';
            aCase.status='New';
            aCase.contactId= [select ContactId from user where id =:u.id].ContactId;
            aCase.ESDJC_Supportforce_Case_Number__c = '12345';
            insert aCase;
            System.assert(aCase.id!=null);
            List<CaseComment> caseComments = new List<CaseComment>();
            for(Integer i=0;i<2;i++){
                CaseComment cc = new CaseComment();
                cc.parentId = aCase.id;
                cc.CommentBody='testing case comment'+i;
                cc.isPublished=true;
                caseComments.add(cc);
            }
            insert caseComments;
            Test.stopTest();
        }
        Case newCase = [select isClosed from case where id = :aCase.id];
        system.assertEquals(true, newCase.isClosed);                                                                                                            
    }
    
    private static void init(){
        ESDJC_Settings__c setting = new ESDJC_Settings__c();
        setting.Run_trigger__c = true;
        setting.Valid_SLA_Origins__c='Web,REWS - Web,Chatter Answers,Personal Email,Concierge';
        setting.DJC_Override_Entitlement_Origins__c = 'Phone,Live Agent,Face To Face,Ethics Point,Email,Package Delivery';
        setting.DJC_Override_Entitlement_Types__c = 'Wellness Reimbursement Request,Mail Services';
        setting.Ergo_Locations__c = 'san francisco,new york,chicago,portland,spokane,toronto';
        setting.Site_URL__c = '/site/url';
        setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
        setting.Concierge_API_User_Profile_Id__c = '00e70000000xTNQ';
        setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
        insert setting;
        REWS_Setting__c rewsSetting = new REWS_Setting__c();
        rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
        rewsSetting.Case_Package_Delivery_Record_Type__c = '00Gn0000000JH8YEAW';
        insert  rewsSetting;
    }
}