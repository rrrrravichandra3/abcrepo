@isTest(SeeAllData=false)
public class Test_PF_NHW_ProcessHandler {

    private static final String PACKAGE_DELIVERY = 'Package Delivery';

    @TestSetup
    static void makeData(){
        Case ca;
        string emailId= UserInfo.getUserEmail();
        RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1];
        Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email=emailId,RecordTypeId = employeeRT.Id);
        insert con;
        User u = [Select Id, Email From User Where Id =: UserInfo.getUserId()];
        u.Contact = con;
        update u;
        Contact con2 = new Contact(FirstName='TestMailApptest',LastName='TestLasttest',Email=emailId,RecordTypeId = employeeRT.Id, ES_DJC_Is_Manager__c = true);
        insert con2;
        Delegate__c delegate = new Delegate__c(Delegate__c = con.Id,Type__c='New Hire Wizard',Manager__c = con2.Id);
        insert delegate;
        ca = new Case(contactId = con.Id,origin = PACKAGE_DELIVERY,NHW_Page_Number__c=2,Type='Mail Services',ES_DJC_Topic__c=PACKAGE_DELIVERY,NHW_Employee_Type__c='relocation',REWS_Received_Location__c='Landmark',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
        insert ca;
        ca=[Select id,contactId,NHW_Employee_Type__c,CreatedById,RecordTypeId,NHW_Page_Number__c,NHW_Job_Application__r.Job__r.Hiring_Manager__c from Case where id =:ca.Id ];
        PF_NHW_ProcessHandler.CaseProcessInformation caseProcessInfo = PF_NHW_ProcessHandler.getProcessInformation(ca);
        System.assertNotEquals(caseProcessInfo, null);
    }
    private static testMethod void moveCaseBackwardTest() {
        Case ca;
        string emailId= UserInfo.getUserEmail();
        RecordType employeeRT = [Select Id from RecordType where sObjectType='Contact' and Name='Employee' LIMIT 1];
        Contact con = new Contact(FirstName='TestMailApp',LastName='TestLast',Email=emailId,RecordTypeId = employeeRT.Id);
        insert con;
        User u = [Select Id, Email From User Where Id =: UserInfo.getUserId()];
        u.Contact = con;
        update u;
        Contact con2 = new Contact(FirstName='TestMailApptest',LastName='TestLasttest',Email=emailId,RecordTypeId = employeeRT.Id, ES_DJC_Is_Manager__c = true);
        insert con2;
        Delegate__c delegate = new Delegate__c(Delegate__c = con.Id,Type__c='New Hire Wizard',Manager__c = con2.Id);
        insert delegate;
        ca = new Case(contactId = con.Id,origin = PACKAGE_DELIVERY,NHW_Page_Number__c=2,Type='Mail Services',ES_DJC_Topic__c=PACKAGE_DELIVERY,NHW_Employee_Type__c='relocation',REWS_Received_Location__c='Landmark',REWS_Sender__c='Amazon',REWS_Carrier__c='USPS',REWS_Oversized__c=true);
        insert ca;
        ca=[Select id,contactId,NHW_Employee_Type__c,CreatedById,RecordTypeId,NHW_Page_Number__c,NHW_Job_Application__r.Job__r.Hiring_Manager__c from Case where id =:ca.Id ];        
        PF_NHW_ProcessHandler.CaseProcessInformation caseProcessInfo = PF_NHW_ProcessHandler.moveCaseBackward(ca);
        System.assertNotEquals(caseProcessInfo, null);
    }
    private static testMethod void getProcessInformationTest1() {
        Case ca=[Select id,contactId,NHW_Employee_Type__c,CreatedById,RecordTypeId,NHW_Page_Number__c from Case LIMIT 1];
        PF_NHW_ProcessHandler.CaseProcessInformation caseProcessInfo = PF_NHW_ProcessHandler.getProcessInformation('contractor');
        PF_NHW_Process.getNextStep(ca);
        System.assertNotEquals(caseProcessInfo, null);
    }
}