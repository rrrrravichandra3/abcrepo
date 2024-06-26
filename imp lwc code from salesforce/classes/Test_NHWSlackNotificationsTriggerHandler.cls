@isTest
public class Test_NHWSlackNotificationsTriggerHandler  {
    
    @testSetup
    public static void insertCase() {
        Contact HiringMgerContact = new Contact();
        HiringMgerContact.FirstName = UserInfo.getFirstName();
        HiringMgerContact.LastName = UserInfo.getLastName();
        HiringMgerContact.Email = UserInfo.getUserEmail();
        HiringMgerContact.recordtypeid = NHW_Util.getEmployeeContactRecordTypeId();
        insert HiringMgerContact; 
        List<Case> cases = new List<Case>();        
        for(Integer i=0;i<10;i++) {
            Case c = new Case();          
            c.First_Name__c = 'Test';
            c.Last_Name__c = 'New Hire '+i;
            c.NH_Personal_Email__c = i+'test123@email.com';  
            c.Manager_s_Email__c = UserInfo.getUserEmail();
            c.Manager_Name__c =HiringMgerContact.id;
            c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Hire Process').getRecordTypeId();
            c.origin = 'NHW';
            c.status = 'Closed';
            c.NHW_Start_Date__c = Date.today().addDays(38);
            c.Subject = 'New Hire Preboarding Request for ' + c.First_Name__c + ' ' + c.Last_Name__c;
            cases.add(c);
        }
        insert cases;
    }
    
    @isTest
    public static void Validate_Auth() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        PF_Slack_Taskhub_API_Service service = new PF_Slack_Taskhub_API_Service('NHW',null,null);
        HttpResponse response = service.authCallout();       
        Test.stopTest();
        System.assert(response!=null);
    }
    
    @isTest
    public static void Validate_SendRequest_FTE() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        Case c = [Select id from Case limit 1];
        List<Id> ids = new List<id>();
        ids.add(c.id);
        PF_Slack_Taskhub_API_Service service = new PF_Slack_Taskhub_API_Service('NHW',ids,new PF_TaskHub_Activity_Type_HM_Contact_NH());
        HttpResponse response = service.sendReqToTaskHubAPI(ids);
        Test.stopTest();
        System.assert(response!=null);
    }
    
    @isTest
    public static void Validate_SendRequest_Contractor() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Case c = [Select id from Case limit 1];
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Hire Process - Onboarding').getRecordTypeId();
        c.Contractor_Hire_Reason__c = 'Standard';
        c.Resource_Type__c = 'Intern';
        c.NHW_Employee_Type__c = 'Contractor';
        update c;
        Test.startTest();
        List<Id> ids = new List<id>();
        ids.add(c.id);
        PF_Slack_Taskhub_API_Service service = new PF_Slack_Taskhub_API_Service('NHW',ids,new PF_TaskHub_Activity_Type_HM_Contact_NH());
        HttpResponse response = service.sendReqToTaskHubAPI(ids);
        Test.stopTest();
        System.assert(response!=null);    
    }
    
    @isTest
    public static void Validate_Builder_FTE() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        Case c = [Select id from Case limit 1];
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Hire Process - Onboarding').getRecordTypeId();
        c.Contractor_Hire_Reason__c = 'Standard';
        c.Resource_Type__c = 'Intern';
        c.NHW_Employee_Type__c = 'Contractor';
        update c;
        List<Id> ids = new List<id>();
        ids.add(c.id);
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',ids,new PF_TaskHub_Activity_Type_HM_Complete_NHW());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==1);
        
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    
    @isTest
    public static void Validate_Builder_Contractor() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        Case c = [Select id from Case limit 1];
        List<Id> ids = new List<id>();
        ids.add(c.id);
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',ids,new PF_TaskHub_Activity_Type_HM_Contact_NH());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==1);
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    
    @isTest
    public static void Validate_BuilderBulk() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        List<Case> c = [Select id from Case limit 10];
        List<Id> ids = new List<id>();
        for(Case cc:c) {
            ids.add(cc.id);
        }
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',ids,new PF_TaskHub_Activity_Type_HM_Contact_NH());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==c.size());
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    
    @isTest
    public static void Validate_EmptyIds() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        PF_Slack_Taskhub_API_Service service = new PF_Slack_Taskhub_API_Service('NHW',null,null);
        HttpResponse response = service.sendReqToTaskhubAPI(null);       
        Test.stopTest();
        System.assert(response==null);
    }
}