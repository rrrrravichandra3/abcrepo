@isTest
public with sharing class Test_Ergo_Assessment_Request_Form {
    
    static testmethod void testErgoCaseSaveNonRemote() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
            
            String caseId = null;
            
            //Create a case
            System.runAs(portalUser) {
                Ergo_Assessment_Request_Form controller = new Ergo_Assessment_Request_Form();

                //verify case defaults
                System.assertEquals('1x1', controller.newCase.DJC_Ergo_Assessment_Type__c);
                System.assertEquals('No', controller.newCase.DJC_Ergo_In_Pain__c);
                System.assertEquals('ErgoAssessmentRequestAmer', controller.RequestFormType);
                System.assertEquals('Ergo - Web', controller.newCase.Origin);

                controller.newCase.REWS_Building__c = 'Sf - One Cal';
                controller.newCase.REWS_Floor__c = 1;
                controller.newCase.REWS_Cube_Number__c = '1';
                controller.newCase.DJC_Ergo_Best_Contact__c = '123-456-7890';
                controller.newCase.DJC_Ergo_Desk_Depth__c = '5';
                controller.newCase.Description = 'Test Description';
                
                String testBlobString = 'abcd';
                Blob testBlob = Blob.valueOf(testBlobString);
                
                controller.Attach1 = testBlob;
                controller.FileName1 = 'Test';
                controller.Attach8 = testBlob;
                controller.FileName8 = 'Test2';
                
                controller.save();
                
                List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId from Case];
                System.assertEquals(1, cases.size());
                System.assertEquals('DJC_Ergo_All_Ergo_cases_AMER', cases[0].RecordType.DeveloperName);
                System.assertEquals('Ergo - Web', cases[0].Origin);
                System.assert(((String)cases[0].OwnerId).startsWith('00G'));
            }
        }
    }
    
    static testmethod void testErgoCaseSaveIndy() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA', 'Indianapolis');
            //Create a case
            System.runAs(portalUser) {
                createCaseWithoutOnlineTrainingConfirmation();
            }
        }
    }

    static testmethod void testErgoCaseSaveQuebec() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('Canada', 'Americas - Canada', 'Quebec');                                 
            //Create a case
            System.runAs(portalUser) {
                createCaseWithoutOnlineTrainingConfirmation();
            }
        }
    }
    
    private static void createCaseWithoutOnlineTrainingConfirmation() {
                Ergo_Assessment_Request_Form controller = new Ergo_Assessment_Request_Form();

                //verify case defaults
                System.assertEquals('1x1', controller.newCase.DJC_Ergo_Assessment_Type__c);
                System.assertEquals('No', controller.newCase.DJC_Ergo_In_Pain__c);
                System.assertEquals('ErgoAssessmentRequestAmer', controller.RequestFormType);
                System.assertEquals('Ergo - Web', controller.newCase.Origin);
                
                controller.newCase.REWS_Building__c = 'Sf - One Cal';
                controller.newCase.REWS_Floor__c = 1;
                controller.newCase.REWS_Cube_Number__c = '1';
                controller.newCase.DJC_Ergo_Best_Contact__c = '123-456-7890';
                controller.newCase.DJC_Ergo_Desk_Depth__c = '5';
                controller.newCase.Description = 'Test Description';
                
                String testBlobString = 'abcd';
                Blob testBlob = Blob.valueOf(testBlobString);
                
                controller.Attach1 = testBlob;
                controller.FileName1 = 'Test';

                controller.save();
                
                List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId from Case];
                System.assertEquals(1, cases.size());
                System.assertEquals('DJC_Ergo_All_Ergo_cases_AMER', cases[0].RecordType.DeveloperName);
                System.assertEquals('Ergo - Web', cases[0].Origin);
                System.assert(((String)cases[0].OwnerId).startsWith('00G'));
    }
    
    static testmethod void testErgoCaseSaveEMEA() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('France', 'EMEA - All Countries', 'Paris');
            
            String caseId = null;
            
            //Create a case
            System.runAs(portalUser) {
                Ergo_Assessment_Request_Form controller = new Ergo_Assessment_Request_Form();

                //verify case defaults
                System.assertEquals('Designated Remote Employee', controller.newCase.DJC_Ergo_Assessment_Type__c);
                System.assertEquals('No', controller.newCase.DJC_Ergo_In_Pain__c);
                System.assertEquals('Ergo - Web', controller.newCase.Origin);

                controller.newCase.REWS_Building__c = 'Paris';
                controller.newCase.REWS_Floor__c = 1;
                controller.newCase.REWS_Cube_Number__c = '1';
                controller.newCase.DJC_Ergo_Best_Contact__c = '123-456-7890';
                controller.newCase.DJC_Ergo_Desk_Depth__c = '5';
                controller.newCase.Description = 'Test Description';
                
                String testBlobString = 'abcd';
                Blob testBlob = Blob.valueOf(testBlobString);
                
                controller.Attach1 = testBlob;
                controller.FileName1 = 'Test';
                controller.Attach8 = testBlob;
                controller.FileName8 = 'Test2';
                
                controller.save();
                
                List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId from Case];
                System.assertEquals(1, cases.size());
                System.assertEquals('DJC_Ergo_All_Ergo_cases_AMER', cases[0].RecordType.DeveloperName);
                System.assertEquals('Ergo - Web', cases[0].Origin);
                System.assert(((String)cases[0].OwnerId).startsWith('00G'));
            }
        }
    }
    
    static testmethod void testErgoCaseSaveRemote() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA', 'Remote');
            
            String caseId = null;
            
            //Create a case
            System.runAs(portalUser) {
                Ergo_Assessment_Request_Form controller = new Ergo_Assessment_Request_Form();

                //verify case defaults
                System.assertEquals('Designated Remote Employee', controller.newCase.DJC_Ergo_Assessment_Type__c);
                System.assertEquals('No', controller.newCase.DJC_Ergo_In_Pain__c);
                System.assertEquals('ErgoAssessmentRequestAmer', controller.RequestFormType);
                System.assertEquals('Ergo - Web', controller.newCase.Origin);
                
                controller.newCase.DJC_Ergo_Best_Contact__c = '123-456-7890';
                controller.newCase.DJC_Ergo_In_Pain__c = 'Yes';
                controller.newCase.DJC_Ergo_Pain_Summary__c = 'Test';
                controller.newCase.DJC_Ergo_Desk_Depth__c = '5';
                controller.newCase.Description = 'Test Description';
                
                String testBlobString = 'abcd';
                Blob testBlob = Blob.valueOf(testBlobString);
                
                controller.Attach1 = testBlob;
                controller.FileName1 = 'Test';
                controller.Attach8 = testBlob;
                controller.FileName8 = 'Test2';
                
                controller.save();
                
                List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId from Case];
                System.assertEquals(1, cases.size());
                System.assertEquals('DJC_Ergo_All_Ergo_cases_AMER', cases[0].RecordType.DeveloperName);
                System.assertEquals('Ergo - Web', cases[0].Origin);
                System.assert(((String)cases[0].OwnerId).startsWith('00G'));
            }
        }
    }
    
    static testmethod void testErgoCaseValidationErrorsNonRemote() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
            
            String caseId = null;
            
            //Create a case
            System.runAs(portalUser) {
                Ergo_Assessment_Request_Form controller = new Ergo_Assessment_Request_Form();

                //verify case defaults
                System.assertEquals('1x1', controller.newCase.DJC_Ergo_Assessment_Type__c);
                System.assertEquals('No', controller.newCase.DJC_Ergo_In_Pain__c);
                System.assertEquals('ErgoAssessmentRequestAmer', controller.RequestFormType);
                System.assertEquals('Ergo - Web', controller.newCase.Origin);
                
                controller.save();
                
                List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId from Case];
                System.assertEquals(0, cases.size());
            }
        }
    }
    
    static testmethod void testErgoCaseValidationErrorsRemote() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA', 'Remote');
            
            String caseId = null;
            
            //Create a case
            System.runAs(portalUser) {
                Ergo_Assessment_Request_Form controller = new Ergo_Assessment_Request_Form();

                //verify case defaults
                
                System.assertEquals('Designated Remote Employee', controller.newCase.DJC_Ergo_Assessment_Type__c);
                System.assertEquals('No', controller.newCase.DJC_Ergo_In_Pain__c);
                System.assertEquals('ErgoAssessmentRequestAmer', controller.RequestFormType);
                System.assertEquals('Ergo - Web', controller.newCase.Origin);
                
                controller.save();
                
                List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId from Case];
                System.assertEquals(0, cases.size());
            }
        }
    }
    
    /* Logic tested in this method has been removed according to W-3209854 - Alejandro Chaparro
    static testmethod void testErgoCaseWorkstationRequest() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
            
            Id contactId = [select ContactId from User where Id=:portalUser.Id].ContactId;
            System.assert(contactId != null);
            
            Contact c = new Contact(Id=contactId, ES_DJC_Contact_Country__c='US', ES_DJC_Work_Location__c='San Francisco');
            update c;
            
            String caseId = null;
            
            //Create a case
            System.runAs(portalUser) {
                Test.startTest();
                Test.setCurrentPage(Page.DJC_Ergonomics);
                
                Ergo_Assessment_Request_Form controller = new Ergo_Assessment_Request_Form();

                //verify case defaults
                System.assertEquals('1x1', controller.newCase.DJC_Ergo_Assessment_Type__c);
                System.assertEquals('No', controller.newCase.DJC_Ergo_In_Pain__c);
                System.assertEquals('ErgoAssessmentRequestAmer', controller.RequestFormType);
                System.assertEquals('Ergo - Web', controller.newCase.Origin);
                
                controller.newCase.REWS_Building__c = 'Sf - One Cal';
                controller.newCase.REWS_Floor__c = 1;
                controller.newCase.REWS_Cube_Number__c = '1';
                controller.newCase.DJC_Ergo_Best_Contact__c = '123-456-7890';
                controller.newCase.DJC_Ergo_Desk_Depth__c = '5';
                controller.newCase.Description = 'Test Description';
                controller.newCase.Ergo_Items_Requested__c = 'Monitor Riser';
                
                String testBlobString = 'abcd';
                Blob testBlob = Blob.valueOf(testBlobString);
                
                controller.Attach1 = testBlob;
                controller.FileName1 = 'Test';
                controller.Attach2 = testBlob;
                controller.FileName2 = 'Test2';
                controller.Attach8 = testBlob;
                controller.FileName8 = 'Test3';
                
                controller.save();
                Test.stopTest();
                
                List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId from Case where RecordType.DeveloperName='All_REWS_cases_AMER_HQ'];
                System.assertEquals(1, cases.size());
            }
        }
    }*/
    
    private static void init() {
        ESDJC_Settings__c setting = new ESDJC_Settings__c();
        setting.Run_trigger__c = true;
        setting.Site_URL__c = '/site/url';
        setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
        setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
        setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
        setting.Ergo_Locations__c='san francisco,new york,chicago,portland,spokane,toronto,dublin';
        setting.Valid_SLA_Origins__c='Web,REWS - Web,Chatter Answers,Personal Email,Concierge';
        insert setting;
        REWS_Setting__c rewsSetting = new REWS_Setting__c();
        rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
        rewsSetting.REWS_Case_Record_Type_Amer_Non_HQ__c = [select Id from RecordType where Sobjecttype = 'Case' and DeveloperName='All_REWS_cases_AMER_NonHQ'].Id;
        rewsSetting.REWS_Case_Record_Type_Amer_HQ__c = [select Id from RecordType where Sobjecttype = 'Case' and DeveloperName='All_REWS_cases_AMER_HQ'].Id;
        rewsSetting.Ergo_Case_Record_Type_AMER__c = [select Id from RecordType where Sobjecttype='Case' and DeveloperName='DJC_Ergo_All_Ergo_cases_AMER'].Id;
        insert  rewsSetting;
    }
}