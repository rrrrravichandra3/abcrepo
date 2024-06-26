@isTest
private class IFBTest_PanelInterviewController {
  
  
  @isTest static void interviewWithoutinterviewer() {
    User interviewer;
    IFB_Interview_Candidate__c recruit;
    PermissionSetAssignment psaInterviewer;
    User currUser = new User(Id = UserInfo.getUserId());
    
      System.runAs(currUser){
      List<sObject> recordsToInsert = new List<sObject>();
      PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'IFB_Recruiting_Interviewer'];    
      interviewer = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
      insert interviewer;
      recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
      recruit.OwnerId = interviewer.Id;
      psaInterviewer = new PermissionSetAssignment(AssigneeId = interviewer.id, PermissionSetId = ps.Id );
      recordsToInsert.clear();
      recordsToInsert.add(psaInterviewer);
      recordsToInsert.add(recruit);
      insert recordsToInsert;
     }

      System.runAs(interviewer){
      Test.startTest();
      Id siftInterviewRecordTypeId = Schema.SObjectType.IFB_Interview__c.getRecordTypeInfosByName().get('Sales - 1st stage interview (HM phone screen/onsite, chrono/panel)').getRecordTypeId();
        PageReference pageRef = Page.IFB_PanelInterview;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('recruId',recruit.Id);
            ApexPages.currentPage().getParameters().put('recTypeId',siftInterviewRecordTypeId);
            ApexPages.currentPage().getParameters().put('retURL', recruit.Id);
            IFB_PanelInterviewController cont = new IFB_PanelInterviewController();
            cont.save();
            cont.cancel();
            List<IFB_Interview__c> lstNewInterview = new List<IFB_Interview__c>([Select id from IFB_Interview__c where Candidate__c =: recruit.Id]);
            System.assertEquals(lstNewInterview.size(),1);
    Test.stopTest();
    }
            
  }
  
    @isTest static void interviewWithInterviewer() {
    User interviewer;
    IFB_Interview_Candidate__c recruit;
    PermissionSetAssignment psaInterviewer;
    User currUser = new User(Id = UserInfo.getUserId());
    
      System.runAs(currUser){
      List<sObject> recordsToInsert = new List<sObject>();
      PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'IFB_Recruiting_Interviewer'];    
      interviewer = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
      insert interviewer;
      recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
      recruit.OwnerId = interviewer.Id;
      psaInterviewer = new PermissionSetAssignment(AssigneeId = interviewer.id, PermissionSetId = ps.Id );
      recordsToInsert.clear();
      recordsToInsert.add(psaInterviewer);
      recordsToInsert.add(recruit);
      insert recordsToInsert;
     }

      System.runAs(interviewer){
      Test.startTest();
      Id siftInterviewRecordTypeId = Schema.SObjectType.IFB_Interview__c.getRecordTypeInfosByName().get('Sales - 1st stage interview (HM phone screen/onsite, chrono/panel)').getRecordTypeId();
      Set<String> setinterviewers = new Set<String>{'Interviewer__c'};
        PageReference pageRef = Page.IFB_PanelInterview;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('recruId',recruit.Id);
            ApexPages.currentPage().getParameters().put('recTypeId',siftInterviewRecordTypeId);
            ApexPages.currentPage().getParameters().put('retURL', recruit.Id);
            IFB_PanelInterviewController cont = new IFB_PanelInterviewController();
            cont.interviewFields = setinterviewers;
            cont.generateInterviewForInterviewer('Interviewer__c');    
            List<IFB_Interview__c> lstNewInterview = new List<IFB_Interview__c>([Select id from IFB_Interview__c where Candidate__c =: recruit.Id]);
            System.assertEquals(lstNewInterview.size(),0);       
            Test.stopTest();
        }
            
  }
  
  @isTest static void interviewWithoutRecruit() {
    User interviewer;
    IFB_Interview_Candidate__c recruit;
    PermissionSetAssignment psaInterviewer;
    User currUser = new User(Id = UserInfo.getUserId());
    
      System.runAs(currUser){
      List<sObject> recordsToInsert = new List<sObject>();
      PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = 'IFB_Recruiting_Interviewer'];    
      interviewer = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
      insert interviewer;
      recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
      recruit.OwnerId = interviewer.Id;
      psaInterviewer = new PermissionSetAssignment(AssigneeId = interviewer.id, PermissionSetId = ps.Id );
      recordsToInsert.clear();
      recordsToInsert.add(psaInterviewer);
      recordsToInsert.add(recruit);
      insert recordsToInsert;
     }

      System.runAs(interviewer){
      Test.startTest();
      Id siftInterviewRecordTypeId = Schema.SObjectType.IFB_Interview__c.getRecordTypeInfosByName().get('Sales - 1st stage interview (HM phone screen/onsite, chrono/panel)').getRecordTypeId();
        PageReference pageRef = Page.IFB_PanelInterview;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('recTypeId',siftInterviewRecordTypeId);
            ApexPages.currentPage().getParameters().put('retURL', '/' + IFB_ObjectDescribe.getObjectPrefix('IFB_Interview__c') + '/o');
            IFB_PanelInterviewController cont = new IFB_PanelInterviewController();
            cont.cancel();
            List<IFB_Interview__c> lstNewInterview = new List<IFB_Interview__c>([Select id from IFB_Interview__c where Candidate__c =: recruit.Id]);
            System.assertEquals(lstNewInterview.size(),0);
    Test.stopTest();
    }
            
  }  
  
}