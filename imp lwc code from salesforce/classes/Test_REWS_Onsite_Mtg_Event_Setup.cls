@IsTest
public class Test_REWS_Onsite_Mtg_Event_Setup {

    public static testMethod void amerHQBuildingTest(){
        
        User portalUser = ESDJC_TestUtil.getPortalUser('USA','Americas - USA');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_AMER');
        }
        DJC_Wellness_Provider__c emeaProvider;        
        system.runAs(portalUser){
            PageReference pageRef = new PageReference('/apex/REWS_LandingPage');
            Test.setCurrentPage(pageRef);
            
            REWS_Controller rewsController = new REWS_Controller();
			rewsController.RequestFormType = 'OnsiteMeetingHQ';
            
            rewsController.newCase.Description = 'Description';
            rewsController.newCase.REWS_Number_of_Guests__c = 5;
            rewsController.newCase.REWS_Date_and_Time_of_Event__c = System.today() + 5;
            rewsController.newCase.REWS_Markers__c = false;
            rewsController.newCase.REWS_Flipchart__c = false;
            rewsController.newCase.REWS_Easel__c = false;
            rewsController.newCase.REWS_Do_you_need_catering__c = 'false';
            rewsController.newCase.REWS_Event_Contact__c = portalUser.ContactId;
            rewsController.newCase.REWS_Event_Start_Time__c = '8:30 AM';
            rewsController.newCase.REWS_Event_End_Time__c = '9:30 AM';
            rewsController.newCase.REWS_What_do_you_need__c = 'What do you need';
			rewsController.newCase.REWS_Catered__c = false;
            rewsController.requestSubject = 'test';

            PageReference result = rewsController.saveCase();
            System.assertEquals(null, result);
            System.assertEquals(1, ApexPages.getMessages().size());
            System.assertEquals('Building', ApexPages.getMessages().get(0).getComponentLabel());
            System.assertEquals('Value is required', ApexPages.getMessages().get(0).getSummary());
        }        
    }
    
    public static testMethod void amerNonHQBuildingTest(){
        
        User portalUser = ESDJC_TestUtil.getPortalUser('USA','Americas - Latin America');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_AMER');
        }
        DJC_Wellness_Provider__c emeaProvider;        
        system.runAs(portalUser){
            PageReference pageRef = new PageReference('/apex/REWS_LandingPage');
            Test.setCurrentPage(pageRef);
            
            REWS_Controller rewsController = new REWS_Controller();
			rewsController.RequestFormType = 'OnsiteMeetingNonHQ';
            
            rewsController.newCase.Description = 'Description';
            rewsController.newCase.REWS_Number_of_Guests__c = 5;
            rewsController.newCase.REWS_Date_and_Time_of_Event__c = System.today() + 5;
            rewsController.newCase.REWS_Markers__c = false;
            rewsController.newCase.REWS_Flipchart__c = false;
            rewsController.newCase.REWS_Easel__c = false;
            rewsController.newCase.REWS_Do_you_need_catering__c = 'false';
            rewsController.newCase.REWS_Event_Contact__c = portalUser.ContactId;
            rewsController.newCase.REWS_Event_Start_Time__c = '8:30 AM';
            rewsController.newCase.REWS_Event_End_Time__c = '9:30 AM';
            rewsController.newCase.REWS_What_do_you_need__c = 'What do you need';
			rewsController.newCase.REWS_Catered__c = false;
            rewsController.requestSubject = 'test';

            PageReference result = rewsController.saveCase();
            System.assertEquals(null, result);
            System.assertEquals(1, ApexPages.getMessages().size());
            System.assertEquals('Building', ApexPages.getMessages().get(0).getComponentLabel());
            System.assertEquals('Value is required', ApexPages.getMessages().get(0).getSummary());
        }        
    }
    
    public static testMethod void emeaBuildingTest(){
        
        User portalUser = ESDJC_TestUtil.getPortalUser('France','EMEA - All Countries');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_EMEA');
        }
        DJC_Wellness_Provider__c emeaProvider;        
        system.runAs(portalUser){
            PageReference pageRef = new PageReference('/apex/REWS_LandingPage');
            Test.setCurrentPage(pageRef);
            
            REWS_Controller rewsController = new REWS_Controller();
			rewsController.RequestFormType = 'OnsiteMeetingEMEA';
            
            rewsController.newCase.Description = 'Description';
            rewsController.newCase.REWS_Number_of_Guests__c = 5;
            rewsController.newCase.REWS_Date_and_Time_of_Event__c = System.today() + 5;
            rewsController.newCase.REWS_Markers__c = false;
            rewsController.newCase.REWS_Flipchart__c = false;
            rewsController.newCase.REWS_Easel__c = false;
            rewsController.newCase.REWS_Do_you_need_catering__c = 'false';
            rewsController.newCase.REWS_Event_Contact__c = portalUser.ContactId;
            rewsController.newCase.REWS_Event_Start_Time__c = '8:30 AM';
            rewsController.newCase.REWS_Event_End_Time__c = '9:30 AM';
            rewsController.newCase.REWS_What_do_you_need__c = 'What do you need';
			rewsController.newCase.REWS_Catered__c = false;
            rewsController.newCase.REWS_Location__c = 'Room location';
            rewsController.requestSubject = 'test';

            PageReference result = rewsController.saveCase();
            System.assertEquals(null, result);
            System.assertEquals(1, ApexPages.getMessages().size());
            System.assertEquals('Building', ApexPages.getMessages().get(0).getComponentLabel());
            System.assertEquals('Value is required', ApexPages.getMessages().get(0).getSummary());
        }        
    }
    
        public static testMethod void amerHQsetupTypeTest(){
        ESDJC_TestUtil.init();
        User portalUser = ESDJC_TestUtil.getPortalUser('USA','Americas - USA');
        user currentUser = [select id from user where id =:UserInfo.getUserId() ];
        system.runAs(currentUser){
            ESDJC_TestUtil.assignPermission(portalUser.id,'ES_DJC_Employee_AMER');
        }
        DJC_Wellness_Provider__c emeaProvider;        
        system.runAs(portalUser){
            PageReference pageRef = new PageReference('/apex/REWS_LandingPage');
            Test.setCurrentPage(pageRef);
            Test.startTest();
            REWS_Controller rewsController = new REWS_Controller();
			rewsController.RequestFormType = 'OnsiteMeetingHQ';
            
            rewsController.newCase.Description = 'Description';
            rewsController.newCase.REWS_Number_of_Guests__c = 5;
            rewsController.newCase.REWS_Date_and_Time_of_Event__c = System.today() + 5;
            rewsController.newCase.REWS_Markers__c = false;
            rewsController.newCase.REWS_Flipchart__c = false;
            rewsController.newCase.REWS_Easel__c = false;
            rewsController.newCase.REWS_Do_you_need_catering__c = 'false';
            rewsController.newCase.REWS_Event_Contact__c = portalUser.ContactId;
            rewsController.newCase.REWS_Event_Start_Time__c = '8:30 AM';
            rewsController.newCase.REWS_Event_End_Time__c = '9:30 AM';
            rewsController.newCase.REWS_What_do_you_need__c = 'What do you need';
			rewsController.newCase.REWS_Catered__c = false;
            rewsController.requestSubject = 'test';
            rewsController.newCase.REWS_Building__c = '50 Fremont';
            rewsController.newCase.REWS_Issue_Location_Building__c = '50 Fremont';
            rewsController.newCase.REWS_What_do_you_need__c = 'Setup';
            rewsController.newCase.REWS_Setup_requested__c = 'Other';
            PageReference result = rewsController.saveCase();
            System.assertEquals(null, result);
            System.debug('debug_msg'+ ApexPages.getMessages());
            System.assertEquals(1, ApexPages.getMessages().size());
            rewsController.setupdescription = 'recliners, lazyboys';
            result = rewsController.saveCase();
            Test.stopTest();
            case[] c = [select id from case];
            System.assertEquals(1, c.size());
            
        }        
    }

}