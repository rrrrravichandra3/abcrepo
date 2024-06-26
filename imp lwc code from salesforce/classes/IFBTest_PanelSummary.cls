@isTest
private class IFBTest_PanelSummary {
    
    private static final String STATUS_FEEDBACK_SUBMITTED = 'Feedback submitted';
    private static final String RECOMMENDATION_YES = 'Move Forward/Hire (if final stage)';

    // If the interviewer has submitted her/his feedback on at least one interview of a given recruit, 
    // then she/he has access to the the Panel Summary (PDF) of that recruit. (W-3422883)
    @isTest static void interviewerAccessFeedbackSubmitted() {
        final String ASSERTION_FEEDBACK_SUBMITTED_INTERVIEWER_SHOULD_HAVE_ACCESS = 'The interviewer has submitted their feedback for at least one interview, but she/he has not access to the Panel Summary.';
        final String ASSERTION_INTERVIEWER_NO_ACCESS_TO_READ_RECRUIT_OBJECT = 'The interviewer does not have access to read the Recruit object. We can not test his access to the Panel Interview PDF';
        final String ASSERTION_INTERVIEWER_NO_ACCESS_TO_READ_RECRUIT_RECORD = 'The interviewer does not have access to read the Recruit record. We can not test his access to the Panel Interview PDF';

        // Setting up data as the user running the test (System Administrator). Mixed DML operations are allowed.
        // Inserting records from different sObject types in single DML transactions (as long as relationship allows)
        User recruiter;
        User hiringManager;
        User interviewer;   

        IFB_Interview_Candidate__c recruit;
        List<IFB_Interview__c> interviews;
        PermissionSetAssignment recruiterPermissionSetAssignment;
        GroupMember recruiterGroupMember;

        System.runAs(new User(Id=UserInfo.getUserId())) {
            List<sObject> recordsToInsert = new List<sObject>();

            // Users
            recruiter = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
            hiringManager = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
            interviewer = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);

            // Recruit
            recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
            
            recordsToInsert.clear();
            recordsToInsert.add(recruiter);
            recordsToInsert.add(hiringManager);
            recordsToInsert.add(interviewer);
            recordsToInsert.add(recruit);
            insert recordsToInsert;

            // Interviewer participating in multiple interviews of the same recruit
            recordsToInsert.clear();
            interviews = new List<sObject>();
            IFB_Interview__c interview;
            for (Integer i = 1; i <= 5; i ++) {
                interview = IFBTestData_Interview.getInterview(null, IFBTestData_Interview.Option.SALES_FIRST, recruit, interviewer, null, null, null, null, null);
                
                // Setup data as follows: the interviewer has submitted feedback on one of the interviews he is participating.
                if (i == 1) {
                    interview.Status__c = STATUS_FEEDBACK_SUBMITTED;
                    interview.Recommendation__c = RECOMMENDATION_YES;
                    interview.Comments__c = 'Yes';
                } else {
                    interview.Status__c = 'New';
                }
                interviews.add(interview);  
            }
    
            recruiterPermissionSetAssignment = IFBTestData_PermissionSetAssignment.getPermmissionSetAssignment(null,
                                                                                                               IFBTestData_PermissionSetAssignment.Option.RECRUITER,
                                                                                                               recruiter);
            
            recruiterGroupMember = IFBTestData_GroupMember.getGroupMember(null, 
                                                                          IFBTestData_GroupMember.Option.SIFT_RECRUITING,
                                                                          recruiter);
            recordsToInsert.clear();
            recordsToInsert.add(recruiterPermissionSetAssignment);
            recordsToInsert.add(recruiterGroupMember);
            insert recordsToInsert;

            // 'SIFT - Interviewer' permission set assignment happens in a future call. We make sure that the future call is completed before we run our
            //  assertions as interviewer.
            Test.startTest();
                insert interviews;
            Test.stopTest();
        }
        
        // Running test as interviewer.
        // NOTE: We instantiate the standardController after the Test.stopTest(); instruction, so future calls are complete 
        // and interviewer has the right permission set assigned to him. (He should be able to Read the Recruit record before instantiating the standardController)
        System.runAs(interviewer) {

            PageReference pageRef = Page.IFB_PanelCandidateOverview;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController standardController = new ApexPages.standardController(recruit);
            IFB_PanelCandidateOverviewExtn extensionController = new IFB_PanelCandidateOverviewExtn(standardController);

            System.assertEquals(true, Schema.sObjectType.IFB_Interview_Candidate__c.isAccessible(),ASSERTION_INTERVIEWER_NO_ACCESS_TO_READ_RECRUIT_OBJECT);
            System.assertEquals(1, [select Id from IFB_Interview_Candidate__c where Id = :recruit.Id].size(), ASSERTION_INTERVIEWER_NO_ACCESS_TO_READ_RECRUIT_RECORD);
            System.assertEquals(true, extensionController.getHasAccessToInterviewDetails(), ASSERTION_FEEDBACK_SUBMITTED_INTERVIEWER_SHOULD_HAVE_ACCESS);
        }
    }
    
}