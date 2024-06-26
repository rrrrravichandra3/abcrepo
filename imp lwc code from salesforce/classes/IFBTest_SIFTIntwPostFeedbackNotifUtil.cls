public class IFBTest_SIFTIntwPostFeedbackNotifUtil {
	public static void testSendNotificatinos(Boolean isInternalCandidate, Boolean sendToExtRecruiters){
		List<IFB_Interview__c> siftInterviews = createSIFTInterviewsWithNewRecruit(isInternalCandidate, sendToExtRecruiters);
		IFB_SIFTInterviewPostFeedbackNotifCtrlr.sendNotifications(siftInterviews);
	}

	static List<IFB_Interview__c> createSIFTInterviewsWithNewRecruit(Boolean isInternalCandidate, Boolean sendToExtRecruiters) {
		WDR_Application__c testWDApplication= WDR_TestUtils.createWDRApplication();
        testWDApplication.Is_this_a_SIFT_Interview__c = 'Yes';
        testWDApplication.Internal_Candidate__c = isInternalCandidate;
        testWDApplication.SIFT_Group_Lookup__c = [Select Id, Name from SIFT_Group__c where Name =: 'CSG'].Id;
        testWDApplication.SIFT_Position_Lookup__c = [Select Id, Name from SIFT_Position__c where Name =: 'Success Manager'].Id;
        if(isInternalCandidate == true && sendToExtRecruiters == false){
        	testWDApplication.Internal_Recruiter_1__c = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 1].Id;
        	testWDApplication.Internal_Recruiter_2__c = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 1].Id;
        }
        else if(isInternalCandidate == true && sendToExtRecruiters == true){
        	testWDApplication.External_Recruiter_1__c = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 1].Id;
        	testWDApplication.External_Recruiter_2__c = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 1].Id;
        }
        else{
            testWDApplication.External_Recruiter_1__c = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 1].Id;
            testWDApplication.External_Recruiter_2__c = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 1].Id;
        }
        update testWDApplication;
        IFB_SIFTRecruitProvider recProvider = new IFB_SIFTRecruitProvider(testWDApplication.Id);
        IFB_Interview_Candidate__c newRecruit = recProvider.generateNewRecruit();
        List<User> interviewers = [Select Id, Name, Email from User WHERE UserType = 'Standard' and isActive = true LIMIT 5];
        IFB_Interview__c newInterview = createInterviewObj(testWDApplication);
        IFB_NewSIFTInterviewWizardCtrl.createSIFTInterviews((String)testWDApplication.Id,null,newRecruit,newInterview,interviewers);

        List<IFB_Interview__c> createdInterviews = [SELECT Name,Candidate__r.Name, Interviewer__r.Name, Interviewer__r.Id, Interview_Format__c, Scheduled_Interview_Date_only__c, Candidate__c, 
								Status__c, RecordTypeName__c, Interview_Type__r.Name FROM IFB_Interview__c where Interviewer__c in : interviewers];
        return createdInterviews;
    }
	
	static IFB_Interview__c createInterviewObj(WDR_Application__c testWDApplication){   
		IFB_Interview__c newInterview = new IFB_Interview__c();
        List<SIFT_Interview_Type__c> intvTypes = [Select Id, Name from SIFT_Interview_Type__c where SIFT_Group__r.Name = 'CSG' AND Active__c=true];
        newInterview.Interview_Type__c = intvTypes[0].Id;
        newInterview.Interview_Format__c = 'Phone';
        newInterview.Scheduled_Interview_Date__c = Datetime.now();
        newInterview.Time_Zone__c = 'America/Indiana/Indianapolis';
        newInterview.Interview_Start_Time__c = '10:00 AM';
        return newInterview;
    }
}