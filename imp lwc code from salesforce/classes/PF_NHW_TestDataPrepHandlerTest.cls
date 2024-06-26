@isTest
public class PF_NHW_TestDataPrepHandlerTest {
	@isTest
	public static void validateCreateTestData() {
		insert new Account(Name=System.Label.NHW_Data_Prep_Account_Detail);
		WDR_Candidate__c candidate = PF_NHW_TestDataPrepUtil.createWDRCandidateObject();
		WDR_Job__c job = PF_NHW_TestDataPrepUtil.createWDRJobObject();
		WDR_Application__c application = PF_NHW_TestDataPrepUtil.createWDRAppObject();

		Boolean closePreboardingCase = false;

		Id appId = PF_NHW_TestDataPrepHandler.createTestData(candidate, job, application, closePreboardingCase);

		WDR_Application__c expectedApp = [Select Id, Candidate__c, Job__c from WDR_Application__c where Id=:appId];
		Id expectedCand = expectedApp.Candidate__c;
		Id expectedJob = expectedApp.Job__c;
		String expectedCandFName = [Select Id, First_Name__c from WDR_Candidate__c where Id=:expectedCand].First_Name__c;
		String expectedJobTitle = [Select Id, Job_Title__c from WDR_Job__c where Id=:expectedJob].Job_Title__c;

		System.assertEquals(expectedCandFName, 'Test');
		System.assertEquals(expectedJobTitle, 'Test job title');
	}
}