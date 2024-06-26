/* Description: This is the class to test REWS_Controller class. 
 * Author: Sredhar Karukonda
 * Date: 08/05/2016
 */

@isTest
public class Test_REWS_Controller_v2 { 
    public static testMethod void testREWSDivisionAmerHQ(){
      // Set up account, profile, and user
        ESDJC_TestUtil.createSSOIdSetting();
        User u = ESDJC_TestUtil.getPortalUser('United States','Americas - Canada');
        user currentUser = [SELECT id FROM user WHERE id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_Amer');
        }

        ESDJC_TestUtil.createCommunitySetting();
        ESDJC_TestUtil.createRegionRecords();


        List<Profile> profiles = [SELECT Id, Name from Profile where Name ='Customer Portal Manager Custom'];
        if(profiles.isEmpty()){
            System.assert(false, 'Customer Portal Manager Custom profile is not found');
        }else if(profiles.size() > 1){
            System.assert(false, 'More than one Customer Portal Manager Custom profile are found');
        }

        List<User> users = [SELECT Id, Name from User where Name ='#djc Helpdesk API'];
        if(users.isEmpty()){
            System.assert(false, '#djc Helpdesk API user is not found');
        }else if(profiles.size() > 1){
            System.assert(false, 'More than one #djc Helpdesk API user are found');
        }

        String recordTypeIdAmerHQ = Schema.SObjectType.Case.RecordTypeInfosByName.get('All REWS cases - AMER HQ').RecordTypeId;

        REWS_Setting__c setting = new  REWS_Setting__c(REWS_Case_Record_Type_Amer_HQ__c=recordTypeIdAmerHQ);
        insert setting;
        // set values 
        ESDJC_CaseHandler.settings.Portal_User_Profile_Id__c = profiles.get(0).Id;
        ESDJC_CaseHandler.settings.djc_Helpdesk_API_User__c = users.get(0).Id;
       System.runAs(u) {
            // set REWS to be page reference
            PageReference pageRef = Page.REWS_LandingPage;
            Test.setCurrentPageReference(pageRef);
            
            // starting test
            Test.startTest();
            REWS_Controller rewsController = new REWS_Controller();
            rewsController.division = 'AmerHQ';
            String recordtypeName1 = rewsController.getRecordType();
            system.debug('***** recordtypeName1 ' + recordtypeName1 + ' recordTypeIdAmerHQ ' + recordTypeIdAmerHQ);
            System.assertEquals(recordtypeName1,recordTypeIdAmerHQ);
            rewsController.RequestFormType = 'RepairsRequest';
            rewsController.newCase.REWS_Issue_Location_Building__c = 'SF Salesforce East';
            rewsController.requestSubject = 'User subject to description';
            rewsController.newCase.REWS_Issue_Location_Floor__c ='11';
            rewsController.newCase.REWS_Issue_Location_Cube__c='24';
            rewsController.newCase.REWS_What_needs_repair__c='Damaged wall/ceiling';
            rewsController.newCase.REWS_Comments_Repairs_Maintainance_Req__c = 'Maintenance Comment';
            rewsController.saveCase();
            Test.stopTest();
            System.assertNotEquals(null, rewsController.newCase, 'Case should be inserted and case id should not be null');
            Case afterCaseInserted = [SELECT Id, Subject, Description, Type, ES_DJC_Sub_Topic__c, Priority, REWS_What_needs_repair__c, 
                                        REWS_Issue_Location_Building__c, REWS_Issue_Location_Floor__c, REWS_Comments_Repairs_Maintainance_Req__c FROM Case limit 1];

            System.assertEquals('Building Maintenance', afterCaseInserted.Type, 'Case Type should be Building Maintenance');
            System.assertEquals('Repairs / Maintenance / Janitorial Request', afterCaseInserted.Subject, 'Case Type should be Repairs / Maintenance / Janitorial Request');
            System.assertEquals('--None--', afterCaseInserted.ES_DJC_Sub_Topic__c, 'Case Sub topic should be --None--');
            System.assertEquals('Low', afterCaseInserted.Priority, 'Case Primority should be Low');
      }
    }

    public static testMethod void testREWSValidationRepairs(){
      // Set up account, profile, and user
        ESDJC_TestUtil.createSSOIdSetting();
        User u = ESDJC_TestUtil.getPortalUser('United States','Americas - Canada');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_Amer');
        }

        ESDJC_TestUtil.createCommunitySetting();
        ESDJC_TestUtil.createRegionRecords();


        List<Profile> profiles = [SELECT Id, Name from Profile where Name ='Customer Portal Manager Custom'];
        if(profiles.isEmpty()){
            System.assert(false, 'Customer Portal Manager Custom profile is not found');
        }else if(profiles.size() > 1){
            System.assert(false, 'More than one Customer Portal Manager Custom profile are found');
        }

        List<User> users = [SELECT Id, Name from User where Name ='#djc Helpdesk API'];
        if(users.isEmpty()){
            System.assert(false, '#djc Helpdesk API user is not found');
        }else if(profiles.size() > 1){
            System.assert(false, 'More than one #djc Helpdesk API user are found');
        }

        String recordTypeIdAmerHQ = Schema.SObjectType.Case.RecordTypeInfosByName.get('All REWS cases - AMER HQ').RecordTypeId;

        REWS_Setting__c setting = new  REWS_Setting__c(REWS_Case_Record_Type_Amer_HQ__c=recordTypeIdAmerHQ);
        insert setting;
        // set values 
        ESDJC_CaseHandler.settings.Portal_User_Profile_Id__c = profiles.get(0).Id;
        ESDJC_CaseHandler.settings.djc_Helpdesk_API_User__c = users.get(0).Id;
        //ESDJC_CaseHandler.settings.id = 'a3Tn0000000CaffEAC';
    

      System.runAs(u) {
            // set REWS to be page reference
            PageReference pageRef = Page.REWS_LandingPage;
            Test.setCurrentPageReference(pageRef);
            
            // starting test
            Test.startTest();
            REWS_Controller rewsController = new REWS_Controller();
            rewsController.division = 'AmerHQ';
            String recordtypeName1 = rewsController.getRecordType();
            system.debug('***** recordtypeName1 ' + recordtypeName1 + ' recordTypeIdAmerHQ ' + recordTypeIdAmerHQ);
            System.assertEquals(recordtypeName1,recordTypeIdAmerHQ);
            rewsController.RequestFormType = 'RepairsRequest';

            rewsController.saveCase();
            System.assertEquals(3, ApexPages.getMessages().size(), 'THERE SHOULD BE ONLY 3 ERROR MESSAGES' + ApexPages.getMessages());
            for(ApexPages.Message message : ApexPages.getMessages()){
                //System.assert(message.getComponentLabel() + ' : ' + message.getSummary());
                if(message.getComponentLabel() == Schema.sObjectType.Case.fields.REWS_What_needs_repair__c.Label){
                    System.assert(message.getSummary().contains(REWS_Controller.ISSUE_ERROR_MESSAGE), 'Message should say "Please select one issue"');
                }else if(message.getComponentLabel() == Schema.sObjectType.Case.fields.REWS_Issue_Location_Building__c.Label){
                    System.assert(message.getSummary().contains(REWS_Controller.DEFAULT_ERROR_MESSAGE), 'Message should say DEFAULT_ERROR_MESSAGE');
                }else if(message.getComponentLabel() == Schema.sObjectType.Case.fields.REWS_Issue_Location_Floor__c.Label){
                    System.assert(message.getSummary().contains(REWS_Controller.DEFAULT_ERROR_MESSAGE), 'Message should say DEFAULT_ERROR_MESSAGE');
                }else if(message.getComponentLabel() == Schema.sObjectType.Case.fields.REWS_Comments_Repairs_Maintainance_Req__c.Label){
                    System.assert(message.getSummary().contains(REWS_Controller.DEFAULT_ERROR_MESSAGE), 'Message should say DEFAULT_ERROR_MESSAGE');
                }else if(message.getComponentLabel() == null){ // Object Level error does return Component Label as null... Subject Error is on Case Object
                    System.assert(message.getSummary().contains('Subject is required'), 'Message should say Subject is required');
                }else{
                    System.assert(false, message.getComponentLabel());
                }
            }
            Test.stopTest();
      }
    }

    public static testMethod void testREWSValidationRepairsMultiselectIssue(){
      // Set up account, profile, and user
        ESDJC_TestUtil.createSSOIdSetting();
        User u = ESDJC_TestUtil.getPortalUser('United States','Americas - Canada');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission( u.id,'ES_DJC_Employee_Amer');
        }

        ESDJC_TestUtil.createCommunitySetting();
        ESDJC_TestUtil.createRegionRecords();


        List<Profile> profiles = [SELECT Id, Name from Profile where Name ='Customer Portal Manager Custom'];
        if(profiles.isEmpty()){
            System.assert(false, 'Customer Portal Manager Custom profile is not found');
        }else if(profiles.size() > 1){
            System.assert(false, 'More than one Customer Portal Manager Custom profile are found');
        }

        List<User> users = [SELECT Id, Name from User where Name ='#djc Helpdesk API'];
        if(users.isEmpty()){
            System.assert(false, '#djc Helpdesk API user is not found');
        }else if(profiles.size() > 1){
            System.assert(false, 'More than one #djc Helpdesk API user are found');
        }

        String recordTypeIdAmerHQ = Schema.SObjectType.Case.RecordTypeInfosByName.get('All REWS cases - AMER HQ').RecordTypeId;

        REWS_Setting__c setting = new  REWS_Setting__c(REWS_Case_Record_Type_Amer_HQ__c=recordTypeIdAmerHQ);
        insert setting;
        // set values 
        ESDJC_CaseHandler.settings.Portal_User_Profile_Id__c = profiles.get(0).Id;
        ESDJC_CaseHandler.settings.djc_Helpdesk_API_User__c = users.get(0).Id;
        //ESDJC_CaseHandler.settings.id = 'a3Tn0000000CaffEAC';
    

      System.runAs(u) {
            // set REWS to be page reference
            PageReference pageRef = Page.REWS_LandingPage;
            Test.setCurrentPageReference(pageRef);
            
            // starting test
            Test.startTest();
            REWS_Controller rewsController = new REWS_Controller();
            rewsController.division = 'AmerHQ';
            String recordtypeName1 = rewsController.getRecordType();
            system.debug('***** recordtypeName1 ' + recordtypeName1 + ' recordTypeIdAmerHQ ' + recordTypeIdAmerHQ);
            System.assertEquals(recordtypeName1,recordTypeIdAmerHQ);
            rewsController.RequestFormType = 'RepairsRequest';
            rewsController.newCase.REWS_Issue_Location_Building__c = 'SF Salesforce East';
            rewsController.requestSubject = 'User subject to description';
            rewsController.newCase.REWS_Issue_Location_Floor__c ='11';
            rewsController.newCase.REWS_Issue_Location_Cube__c='24';
            rewsController.newCase.REWS_What_needs_repair__c='Damaged wall/ceiling;Elevetors';
            rewsController.newCase.REWS_Comments_Repairs_Maintainance_Req__c = 'Maintenance Comment';
            rewsController.saveCase();
            System.assertEquals(1, ApexPages.getMessages().size(), 'THERE SHOULD BE ONLY 1 ERROR MESSAGES' + ApexPages.getMessages());
            for(ApexPages.Message message : ApexPages.getMessages()){
                //System.assert(message.getComponentLabel() + ' : ' + message.getSummary());
                if(message.getComponentLabel() == Schema.sObjectType.Case.fields.REWS_What_needs_repair__c.Label){
                    System.assert(message.getSummary().contains(REWS_Controller.ISSUE_ERROR_MESSAGE), 'Message should say "Please select one issue"');
                }else{
                    System.assert(false, message.getComponentLabel());
                }
            }
            Test.stopTest();
      }
    }
}