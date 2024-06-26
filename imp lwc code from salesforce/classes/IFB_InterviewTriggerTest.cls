@isTest
// Test Class to test the Interview Trigger
private class IFB_InterviewTriggerTest {

    private static String dummyExistingGroup = 'CSG';
    private static String dummyExistingPosition = 'PA';
    private static String dummyExistingEmail = 'test@example.com';
    private static String technicalRecordTypeName = 'CSG - Technical/First';
    private static String consultingRecordTypeName = 'CSG - Consulting/Second';
    private static String panelRecordTypeName = 'CSG - Panel Interview';
    private static String technicalCategory = 'Technical Question';  
    private static String consultingCategory = 'Consulting Question';  
    private static String panelCategory = 'Panel Question';
    private static String recommendationYes = 'Move Forward/Hire (if final stage)';
    private static String recommendationNo = 'Do Not Move Forward/Do Not Hire';
    private static String statusFeedbackSubmitted = 'Feedback submitted';

    @testSetup static void setup() {
        // Create the users first
        IFB_RecruitingTestDataFactory.createUser('Interviewer', 6);
        List<User> userList = [SELECT Id FROM User WHERE UserName LIKE'INT%@recruitingapp2.com'];
        // Validate the user was created
        System.assertEquals(userList.size(), 6);
    }

    static testmethod void InterviewInsertNonRecommendedTest() {   
        
        List<String> interviewRecordTypeNames = new List<String>{technicalRecordTypeName};
        List<String> positions = new List<String>{dummyExistingPosition};
        List<String> categories = new List<String>{technicalCategory};
        IFB_RecruitingTestDataFactory.createInterviewQuestionCategory(interviewRecordTypeNames, positions, categories);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(technicalCategory, 5);
        
        User interviewUser = [SELECT Id FROM User WHERE UserName='INT0@recruitingapp2.com'];   
        IFB_Interview_Candidate__c ic = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Position__c=dummyExistingPosition, Group__c=dummyExistingGroup, Email__c=dummyExistingEmail,
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic;
               
        Id iRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('CSG - Technical/First').getRecordTypeId();       
        
        Test.startTest();        
        IFB_Interview__c interview = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iRecordTypeId,Interviewer__c=interviewUser.Id, Actual_Interview_Date__c = Date.Today(), Recommendation__c=recommendationNo, Comments__c='No', Status__c=statusFeedbackSubmitted);
        insert interview;
        Test.stopTest();
        
        IFB_Interview_Candidate__c icAfter = [SELECT Id, Rejected__c, First_Screen_Date__c FROM IFB_Interview_Candidate__c WHERE Id =: ic.Id];
        /*
        Removing following assert. W-3512390 - auto reject functionality was removed
        System.assertEquals(icAfter.Rejected__c, true);
        */
        System.assertEquals(icAfter.First_Screen_Date__c, Date.Today());
    }
    
    /**
     * Commenting out this test method to avoid the error below. TODO: Modify postFeedElement method so it doesn't try post if it is a test?
     *
     *IFB_InterviewTriggerTest.InterviewUpdateRecommendedTest -- System.DmlException: Update failed. First exception on row 0 with id a4f190000006IvrAAE; first error: 
     * CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, IFB_InterviewTrigger: execution of AfterUpdate
     * caused by: System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true).
     * Class.ConnectApi.ChatterFeeds.postFeedElement: line 5736, column 1
     * Class.IFB_InterviewUtilities.postInterviewSubmittedComment: line 330, column 1
     * Class.IFB_InterviewUtilities: line 301, column 1
     * Trigger.IFB_InterviewTrigger: line 85, column 1: []
     * Stack trace: Class.IFB_InterviewTriggerTest.InterviewUpdateRecommendedTest: line 80, column 1
     */
    /*
    static void InterviewUpdateRecommendedTest() {   
        
        List<String> interviewRecordTypeNames = new List<String>{technicalRecordTypeName};
        List<String> positions = new List<String>{dummyExistingPosition};
        List<String> categories = new List<String>{technicalCategory};
        IFB_RecruitingTestDataFactory.createInterviewQuestionCategory(interviewRecordTypeNames, positions, categories);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(technicalCategory, 5);
        
        User interviewUser = [SELECT Id FROM User WHERE UserName='INT0@recruitingapp2.com'];   
        IFB_Interview_Candidate__c ic = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Position__c=dummyExistingPosition, Group__c=dummyExistingGroup, Email__c=dummyExistingEmail,
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic;
        
        IFB_Interview_Candidate__c ic1 = new IFB_Interview_Candidate__c(First_Name__c='New1', Last_Name__c='Candidate1', Position__c=dummyExistingPosition, Group__c=dummyExistingGroup, Email__c=dummyExistingEmail,
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic1;
               
        Id iRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('CSG - Technical/First').getRecordTypeId();       
        IFB_Interview__c interview = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iRecordTypeId,Interviewer__c=interviewUser.Id, Actual_Interview_Date__c = Date.Today(), Recommendation__c=recommendationNo, Comments__c='No');
        insert interview; 
        
        Test.startTest();  
        
        interview.Recommendation__c = recommendationYes;
        interview.Comments__c = 'Yes';
        // Swop Candidate
        interview.Overall_Interview_Score__c = 3;
        interview.Candidate__c = ic1.Id;
        interview.Status__c=statusFeedbackSubmitted;
        update interview;           
        Test.stopTest();
        
        IFB_Interview_Candidate__c icAfter = [SELECT Id, Passed_Technical__c, First_Screen_Date__c FROM IFB_Interview_Candidate__c WHERE Id =: ic1.Id];
        System.assertEquals(icAfter.Id, ic1.Id);
        System.assertEquals(icAfter.Passed_Technical__c, true);
    }*/
    
    static testmethod void InterviewDeleteConsultingTest() {   
        
        List<String> interviewRecordTypeNames = new List<String>{consultingRecordTypeName};
        List<String> positions = new List<String>{dummyExistingPosition};
        List<String> categories = new List<String>{consultingCategory};
        IFB_RecruitingTestDataFactory.createInterviewQuestionCategory(interviewRecordTypeNames, positions, categories);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(consultingCategory, 5);
        
        User interviewUser = [SELECT Id FROM User WHERE UserName='INT0@recruitingapp2.com'];   
        IFB_Interview_Candidate__c ic = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Position__c=dummyExistingPosition, Group__c=dummyExistingGroup, Email__c=dummyExistingEmail,
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic;
               
        Id iRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('CSG - Consulting/Second').getRecordTypeId();       
        
        Test.startTest();        
        IFB_Interview__c interview = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iRecordTypeId,Interviewer__c=interviewUser.Id, Actual_Interview_Date__c = Date.Today(), Recommendation__c=recommendationYes, Comments__c='Yes', Status__c=statusFeedbackSubmitted);
        insert interview;
        IFB_Interview_Candidate__c icAfter = [SELECT Id, Passed_Consulting__c, First_Screen_Date__c FROM IFB_Interview_Candidate__c WHERE Id =: ic.Id];
        System.assertEquals(icAfter.Passed_Consulting__c, true);
        // Test Delete
        delete interview;
        List<IFB_Interview__c> interviewList = [SELECT Id FROM IFB_Interview__c WHERE ID =: interview.Id];
        System.assertEquals(interviewList.size(), 0);
        // Test undelete
        undelete interview;
        interviewList = [SELECT Id FROM IFB_Interview__c WHERE ID =: interview.Id];
        System.assertEquals(interviewList.size(), 1);
        Test.stopTest();
    }
    
    static testmethod void InterviewPanelInsertTest() {   
        List<String> interviewRecordTypeNames = new List<String>{panelRecordTypeName};
        List<String> positions = new List<String>{dummyExistingPosition};
        List<String> categories = new List<String>{panelCategory};
        IFB_RecruitingTestDataFactory.createInterviewQuestionCategory(interviewRecordTypeNames, positions, categories);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(panelCategory, 5);
        
        List<User> userList = [SELECT Id FROM User WHERE UserName LIKE'INT%@recruitingapp2.com']; 
        IFB_Interview_Candidate__c ic = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Position__c=dummyExistingPosition, Group__c=dummyExistingGroup, Email__c=dummyExistingEmail,
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic;
               
        Id iRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('CSG - Panel Interview').getRecordTypeId();       
        IFB_Interview__c interview = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iRecordTypeId,Interviewer__c=userList[0].Id, Interviewer2__c=userList[1].Id,
                                                  Interviewer3__c=userList[2].Id, Interviewer4__c=userList[3].Id, Interviewer5__c=userList[4].Id,
                                                  Actual_Interview_Date__c = Date.Today());
        
        Test.startTest();  
        insert interview;           
        Test.stopTest();
        
        IFB_Interview_Candidate__c icAfter = [SELECT Id, First_Screen_Date__c FROM IFB_Interview_Candidate__c WHERE Id =: ic.Id];
        System.assertEquals(icAfter.First_Screen_Date__c, Date.Today());    
    }
    
    static testmethod void InterviewPanelUpdateTest() {   
        List<String> interviewRecordTypeNames = new List<String>{panelRecordTypeName, technicalRecordTypeName};
        List<String> positions = new List<String>{dummyExistingPosition, dummyExistingPosition};
        List<String> categories = new List<String>{panelCategory, technicalCategory};
        IFB_RecruitingTestDataFactory.createInterviewQuestionCategory(interviewRecordTypeNames, positions, categories);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(panelCategory, 5);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(technicalCategory, 5);
        
        List<User> userList = [SELECT Id FROM User WHERE UserName LIKE'INT%@recruitingapp2.com']; 
        IFB_Interview_Candidate__c ic = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Position__c=dummyExistingPosition,  Group__c=dummyExistingGroup, Email__c=dummyExistingEmail,
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic;
               
        Id iRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('CSG - Panel Interview').getRecordTypeId();       
        Id iTechnicalRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('CSG - Technical/First').getRecordTypeId(); 
        List<IFB_Interview__c> interviewList = new List<IFB_Interview__c>();
        IFB_Interview__c interview = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iTechnicalRecordTypeId,Interviewer__c=userList[5].Id);
        interviewList.add(interview);
        IFB_Interview__c interview1 = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iRecordTypeId,Interviewer__c=userList[0].Id, Interviewer2__c=userList[1].Id,
                                                  Interviewer3__c=userList[2].Id, Interviewer4__c=userList[3].Id, Interviewer5__c=userList[4].Id);
        interviewList.add(interview1);                                          
        insert interviewList;
        
        Test.startTest();  
        interview1.Interviewer__c = userList[5].Id;
        interview1.Interviewer2__c = null;
        interview1.Interviewer3__c = null;  
        interview1.Interviewer4__c = null;  
        interview1.Interviewer5__c = null;  
        update interview1;
        Test.stopTest(); 
        
        // Validate Results
        interview1 = [SELECT ID, Interviewer__c, Interviewer2__c, Interviewer3__c, Interviewer4__c, Interviewer5__c FROM IFB_Interview__c WHERE Id =: interview.Id];
        System.assertEquals(interview1.Interviewer__c, userList[5].Id);
    }
    
     static testmethod void InterviewPanelDeleteTest() {   
        List<String> interviewRecordTypeNames = new List<String>{panelRecordTypeName, technicalRecordTypeName};
        List<String> positions = new List<String>{dummyExistingPosition, dummyExistingPosition};
        List<String> categories = new List<String>{panelCategory, technicalCategory};
        IFB_RecruitingTestDataFactory.createInterviewQuestionCategory(interviewRecordTypeNames, positions, categories);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(panelCategory, 5);
        IFB_RecruitingTestDataFactory.createInterviewQuestions(technicalCategory, 5);
        
        List<User> userList = [SELECT Id FROM User WHERE UserName LIKE'INT%@recruitingapp2.com']; 
        IFB_Interview_Candidate__c ic = new IFB_Interview_Candidate__c(First_Name__c='Candidate0', Last_Name__c='Recruit0', Position__c=dummyExistingPosition, Group__c=dummyExistingGroup, Email__c=dummyExistingEmail,
                                                                Region__c='AMER', Zone__c='AMER East',City__c ='New York', State__c='N/A');
        insert ic;
               
        Id iRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('CSG - Panel Interview').getRecordTypeId();       
        Id iTechnicalRecordTypeId = Schema.getGlobalDescribe().get('IFB_Interview__c').getDescribe().getRecordTypeInfosByName().get('CSG - Technical/First').getRecordTypeId(); 
        List<IFB_Interview__c> interviewList = new List<IFB_Interview__c>();
        IFB_Interview__c interview = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iTechnicalRecordTypeId,Interviewer__c=userList[5].Id);
        interviewList.add(interview);
        IFB_Interview__c interview1 = new IFB_Interview__c(Candidate__c= ic.Id, RecordTypeId=iRecordTypeId,Interviewer__c=userList[0].Id, Interviewer2__c=userList[1].Id,
                                                  Interviewer3__c=userList[2].Id, Interviewer4__c=userList[3].Id, Interviewer5__c=userList[4].Id);
        interviewList.add(interview1);                                          
        insert interviewList; 
        Test.startTest();  
        delete interview1;          
        Test.stopTest();
        
        interviewList = [SELECT Id, RecordTypeId from IFB_Interview__c WHERE Candidate__c =: ic.Id];
        System.assertEquals(interviewList.size(), 1);
        System.assertEquals(interviewList[0].RecordTypeId, iTechnicalRecordTypeId);    
    }
    
}