@isTest
// Test Class to test the IFB_PanelCandidateOverviewExtn 
private class IFB_PanelCandidateOverviewExtnTest {

    private static String dummyExistingPosition = 'Dishwasher';
    private static String technicalRecordTypeName = 'Technical Interview';
    private static String consultingRecordTypeName = 'Consulting Interview';
    private static String panelRecordTypeName = 'Panel Interview';
    private static String technicalCategory = 'Technical Question';  
    private static String consultingCategory = 'Consulting Question';  
    private static String panelCategory = 'Panel Question';

    @testSetup static void setup() {
        // Create the users first
        IFB_RecruitingTestDataFactory.createUser('Interviewer', 6);
        List<User> userList = [SELECT Id FROM User WHERE UserName LIKE'INT%@recruitingapp2.com'];
        // Validate the user was created
        System.assertEquals(userList.size(), 6);
    }
   
    static testmethod void PanelCandidateOverviewExtnEmptyConstructorTest() {    
        Test.startTest();  
        IFB_PanelCandidateOverviewExtn pco = new  IFB_PanelCandidateOverviewExtn();
        // Validate Extension Class is Created Correctly
        System.assertNotEquals(null, pco);
        Test.stopTest(); 
    }
   
    static testmethod void IFB_PanelCandidateOverviewExtnTest() {   
        List<String> interviewRecordTypeNames = new List<String>{panelRecordTypeName, technicalRecordTypeName};
        List<String> positions = new List<String>{dummyExistingPosition, dummyExistingPosition};
        List<String> categories = new List<String>{panelCategory, technicalCategory};
        IFB_RecruitingTestDataFactory.createInterviewQuestionCategory(interviewRecordTypeNames, positions, categories);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(panelCategory, 5);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(technicalCategory, 5);
        IFB_RecruitingTestDataFactory.createRatings();
        
        List<User> userList = [SELECT Id FROM User WHERE UserName LIKE'INT%@recruitingapp2.com']; 
        IFB_Interview_Candidate__c ic = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Position__c=dummyExistingPosition,
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic;
               
        Id iRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('Panel Interview').getRecordTypeId();       
        Id iTechnicalRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('Technical Interview').getRecordTypeId(); 
        List<IFB_Interview__c> interviewList = new List<IFB_Interview__c>();
        IFB_Interview__c interview = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iTechnicalRecordTypeId,Interviewer__c=userList[5].Id);
        interviewList.add(interview);
        IFB_Interview__c interview1 = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iRecordTypeId,Interviewer__c=userList[0].Id, Interviewer2__c=userList[1].Id,
                                                  Interviewer3__c=userList[2].Id, Interviewer4__c=userList[3].Id, Interviewer5__c=userList[4].Id);                                         
        // Update seperately to guarantee this will have a later last modified date
        interviewList.add(interview1);
        insert interviewList;
        
        Test.startTest();  
        PageReference page = new PageReference('IFB_PanelCandidateOverview');
        page.getParameters().put('Id', interview.Id);
        Test.setCurrentPage(page);
        ApexPages.StandardController sc = new ApexPages.standardController(ic);
        // Create the Extension
        IFB_PanelCandidateOverviewExtn pco = new  IFB_PanelCandidateOverviewExtn(sc);
        // Validate Extension Class is Created Correctly
        System.assertNotEquals(null, pco);
        // Validate Interviews
        System.assertEquals(pco.getHasInterviews(), true);
        System.assertNotEquals(pco.getLastInterviewId(), null);
        System.assertEquals(pco.getAllInterviews().size(), 2);
        System.assertEquals(pco.getAllInterviews()[0].getInterview().Id, interview.Id);
        System.assertEquals(pco.getAllInterviews()[0].getinterviewType(), technicalRecordTypeName);
        System.assertEquals(pco.getAllInterviews()[0].getinterviewEvaluations().size(), 5);
        Test.stopTest(); 
    }
}