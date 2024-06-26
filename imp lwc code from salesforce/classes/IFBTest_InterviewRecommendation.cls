@isTest
private class IFBTest_InterviewRecommendation{

	private static String recommendationNo = 'Do Not Move Forward/Do Not Hire';

	//When an interviewer gives a negative recommendation, candidate is not auto-rejected
    @isTest static void InterviewInsertNonRecommendedTest(){
		User interviewer;
		IFB_Interview_Candidate__c recruit;
		IFB_Interview__c interview;
        //create recruit, intervie, interviewer records as sys admin
		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<sObject> recordsToInsert = new List<sObject>();

			interviewer = IFBTestData_User.getUser(null, IFBTestData_User.Option.EMPLOYEE, null, null);
			recruit = IFBTestData_Recruit.getRecruit(null, IFBTestData_Recruit.Option.SALES_EBU, null);
			recordsToInsert.add(interviewer);
			recordsToInsert.add(recruit);
			insert recordsToInsert;

			interview = new IFB_Interview__c();
			interview = IFBTestData_Interview.getInterview(interview, IFBTestData_Interview.Option.CSG_PANEL, recruit, interviewer, null, null, null, null, null);

			recordsToInsert.clear();
			recordsToInsert.add(interview);
			insert recordsToInsert;
		}

		// Run test as interviewers.
		// update recommendation
		DateTime actualInterviewDate = DateTime.now().addDays(6);
		System.runAs(interviewer) {
			Test.startTest();
				interview.Recommendation__c = recommendationNo;
                interview.Comments__c = 'No';
				update interview;
	       	Test.stopTest();
		}

		recruit = [select Id, Rejected__c from IFB_Interview_Candidate__c where Id = : recruit.Id];
		//Assert that candidate is not rejected
        System.assertEquals(recruit.Rejected__c, false);
        

	}
}