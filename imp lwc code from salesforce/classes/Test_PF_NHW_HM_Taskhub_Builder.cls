@isTest
public class Test_PF_NHW_HM_Taskhub_Builder  {
    
    private static String ACTIVITY_TYPE_COMPLETE_NHW = 'nhw-complete-new-hire-wizard-activity';

    @testSetup
    public static void insertCase() {
        Contact HiringMgerContact = new Contact();
        HiringMgerContact.FirstName = UserInfo.getFirstName();
        HiringMgerContact.LastName = UserInfo.getLastName();
        HiringMgerContact.Email = UserInfo.getUserEmail();
        HiringMgerContact.recordtypeid = NHW_Util.getEmployeeContactRecordTypeId();
        insert HiringMgerContact; 
        List<Case> cases = new List<Case>();        
        for(Integer i=0;i<110;i++) {
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
    public static void Validate_Builder_Contact_NH_FTE() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        Case c = [Select id from Case limit 1];
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Hire Process - Onboarding').getRecordTypeId();
        c.Contractor_Hire_Reason__c = 'Standard';
        c.Resource_Type__c = 'Intern';
        c.NHW_Employee_Type__c = 'regular employee';
        update c;
        Slack_Taskhub_Notification__e evt = new Slack_Taskhub_Notification__e(Id__c=c.id,System__c='NHW',Activity_type__c= ACTIVITY_TYPE_COMPLETE_NHW);        
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',new List<Slack_Taskhub_Notification__e>{evt},new PF_TaskHub_Activity_Type_HM_Complete_NHW());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==1);      
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    
    @isTest
    public static void Validate_Builder_CompleteNHW_FTE() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        Case c = [Select id from Case limit 1];
        c.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        c.NHW_Employee_Type__c = 'Regular Employee';
        c.Status = 'Closed';
        update c;
        Slack_Taskhub_Notification__e evt = new Slack_Taskhub_Notification__e(Id__c=c.id,System__c='NHW',Activity_type__c= ACTIVITY_TYPE_COMPLETE_NHW,isComplete__c = false);        
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',new List<Slack_Taskhub_Notification__e>{evt},new PF_TaskHub_Activity_Type_HM_Complete_NHW());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==1);
        System.Assertequals(activities[0].obj.status,'REQUESTED');
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    
    @isTest
    public static void Validate_Builder_CompleteNHWAutoMark_FTE() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        Case c = [Select id from Case limit 1];
        c.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        c.NHW_Employee_Type__c = 'Regular Employee';
        c.Status = 'Closed';
        update c;
        Slack_Taskhub_Notification__e evt = new Slack_Taskhub_Notification__e(Id__c=c.id,System__c='NHW',Activity_type__c= ACTIVITY_TYPE_COMPLETE_NHW,isComplete__c = true);        
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',new List<Slack_Taskhub_Notification__e>{evt},new PF_TaskHub_Activity_Type_HM_Complete_NHW());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==1);
        System.Assertequals(activities[0].obj.status,'COMPLETED');
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    
    @isTest
    public static void Validate_Builder_CompleteNHWAutoMark_Contractor() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        Case c = [Select id from Case limit 1];
        c.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        c.NHW_Employee_Type__c = 'Contractor';
        update c;
        Slack_Taskhub_Notification__e evt = new Slack_Taskhub_Notification__e(Id__c=c.id,System__c='NHW',Activity_type__c= ACTIVITY_TYPE_COMPLETE_NHW,IsComplete__c = true);        
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',new List<Slack_Taskhub_Notification__e>{evt},new PF_TaskHub_Activity_Type_HM_Complete_NHW());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==1);
        System.Assertequals(activities[0].obj.status,'COMPLETED');
        System.Assertequals(activities[0].obj.id,c.id+'-CMNHW');        
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    
    @isTest
    public static void Validate_Builder_RedHot_FTE() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        Case c = [Select id from Case limit 1];
        List<Id> ids = new List<id>();
        Slack_Taskhub_Notification__e evt = new Slack_Taskhub_Notification__e(Id__c=c.id,System__c='NHW',Activity_type__c= 'nhw-red-hot-new-hire-activity');        
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',new List<Slack_Taskhub_Notification__e>{evt},new PF_TaskHub_Activity_Type_HM_RedHot_NH());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==1);
        System.AssertEquals(activities[0].obj.name, 'Red Hot New Hire');
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    
    @isTest
    public static void Validate_BuilderBulk() {
        Test.setMock(HttpCalloutMock.class, new PF_TaskHub_API_HttpCalloutMock());
        Test.startTest();
        List<Case> c = [Select id from Case limit 110];
        List<Slack_Taskhub_Notification__e> evts = new List<Slack_Taskhub_Notification__e>();
        for(Case cc:c) {
            evts.add(new Slack_Taskhub_Notification__e(Id__c=cc.id,System__c='NHW',Activity_type__c= 'nhw-contact-new-hire-activity'));
        }
        PF_TaskHub_Builder_Factory builderFactory = new PF_TaskHub_Builder_Factory();        
        PF_TaskHub_Builder builder = builderFactory.createBuilder('NHW');
        List<PF_Taskhub_Activity> activities =  builder.build('NHW',evts,new PF_TaskHub_Activity_Type_HM_Contact_NH());  
        Test.stopTest();
        System.assert(activities!=null);
        System.assert(activities.size()==c.size());
        System.assertEquals(activities[0].actor.id,UserInfo.getUserEmail());
    }
    

}