@isTest
public class Test_Ergo_Standing_Desk_Ergotron_Request {
    static testmethod void testStandingDeskCaseSaveForChicago() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA','Chicago');
            
            //Create a case
            System.runAs(portalUser) {
                createErgoCaseWithOutPhotosOfDeskArea();
            }
        }
    }
    
    static testmethod void testStandingDeskCaseSaveForToronto() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('Canada', 'Americas - Canada','Toronto');
            
            //Create a case
            System.runAs(portalUser) {
                createErgoCaseWithOutPhotosOfDeskArea();
            }
        }
    }
    
    
    private static void createErgoCaseWithOutPhotosOfDeskArea() {
        Ergo_Standing_Desk_Ergotron_Request controller = new Ergo_Standing_Desk_Ergotron_Request();
        
        controller.newCase.REWS_Building__c = 'Sf - One Cal';
        controller.newCase.REWS_Floor__c = 1;
        controller.newCase.REWS_Cube_Number__c = '1';
        
        String testBlobString = 'abcd';
        Blob testBlob = Blob.valueOf(testBlobString);
        
        controller.Attach1 = testBlob;
        controller.FileName1 = 'Test';
        controller.Attach9 = testBlob;
        controller.FileName9 = 'Test2';
        
        controller.save();
        
        List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId, Type, ES_DJC_Topic__c from Case];
        System.assertEquals(1, cases.size());
        System.assertEquals('DJC_Ergo_All_Ergo_cases_AMER', cases[0].RecordType.DeveloperName);
        System.assertEquals('Ergo - Web', cases[0].Origin);
        System.assertEquals('Stand Desk Attachment (Ergotron) Request', cases[0].Type);
        System.assertEquals('Stand Desk Attachment (Ergotron) Request', cases[0].ES_DJC_Topic__c);
        System.assert(((String)cases[0].OwnerId).startsWith('00G'));
        
    }
    
    static testmethod void testStandingDeskCaseSaveForIndy() {
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
    
    static testmethod void testStandingDeskCaseSaveForQuebec() {
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
        Ergo_Standing_Desk_Ergotron_Request controller = new Ergo_Standing_Desk_Ergotron_Request();
        
        controller.newCase.REWS_Building__c = 'Sf - One Cal';
        controller.newCase.REWS_Floor__c = 1;
        controller.newCase.REWS_Cube_Number__c = '1';
        
        String testBlobString = 'abcd';
        Blob testBlob = Blob.valueOf(testBlobString);
        
        controller.Attach1 = testBlob;
        controller.FileName1 = 'Test';
        controller.Attach2 = testBlob;
        controller.FileName2 = 'Test2';
        
        controller.save();
        
        List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId, Type, ES_DJC_Topic__c from Case];
        System.assertEquals(1, cases.size());
        System.assertEquals('DJC_Ergo_All_Ergo_cases_AMER', cases[0].RecordType.DeveloperName);
        System.assertEquals('Ergo - Web', cases[0].Origin);
        System.assertEquals('Stand Desk Attachment (Ergotron) Request', cases[0].Type);
        System.assertEquals('Stand Desk Attachment (Ergotron) Request', cases[0].ES_DJC_Topic__c);
        System.assert(((String)cases[0].OwnerId).startsWith('00G'));
        
    }
    
    static testmethod void testStandingDeskValidationErrors() {
        User sysAdm = ESDJC_TestUtil.getSysAdminUser();
        
        User portalUser = null;
        System.runAs(sysAdm) {
            init();
            portalUser = ESDJC_TestUtil.getPortalUser('US', 'Americas - USA');
            
            //Create a case
            System.runAs(portalUser) {
                Ergo_Standing_Desk_Ergotron_Request controller = new Ergo_Standing_Desk_Ergotron_Request();
                
                controller.save();
                
                List<Case> cases = [select Id, RecordType.DeveloperName, Origin, OwnerId from Case];
                System.assertEquals(0, cases.size());
            }
        }
    }
    
    private static void init() {
        ESDJC_Settings__c setting = new ESDJC_Settings__c();
        setting.Run_trigger__c = true;
        setting.Site_URL__c = '/site/url';
        setting.Portal_User_Profile_Id__c = '00e70000000xEB1';
        setting.Concierge_API_User_Profile_Id__c = '00en0000000HgEa';
        setting.djc_Helpdesk_API_User__c = '00570000002SpX4AAK';
        setting.Valid_SLA_Origins__c='Web,REWS - Web,Chatter Answers,Personal Email,Concierge';
        setting.Ergo_Locations__c = 'san francisco,new york,chicago,portland,spokane,toronto';
        insert setting;
        REWS_Setting__c rewsSetting = new REWS_Setting__c();
        rewsSetting.Mail_services_queue_Id__c = '00Gn0000000JH8YEAW';
        rewsSetting.REWS_Case_Record_Type_Amer_Non_HQ__c = [select Id from RecordType where Sobjecttype = 'Case' and DeveloperName='All_REWS_cases_AMER_NonHQ'].Id;
        rewsSetting.REWS_Case_Record_Type_Amer_HQ__c = [select Id from RecordType where Sobjecttype = 'Case' and DeveloperName='All_REWS_cases_AMER_HQ'].Id;
        rewsSetting.Ergo_Case_Record_Type_AMER__c = [select Id from RecordType where Sobjecttype='Case' and DeveloperName='DJC_Ergo_All_Ergo_cases_AMER'].Id;
        insert  rewsSetting;
    }
}