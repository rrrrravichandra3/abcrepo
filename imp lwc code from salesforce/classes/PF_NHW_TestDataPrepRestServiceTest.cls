@isTest
public class PF_NHW_TestDataPrepRestServiceTest {
	@isTest
	public static void validateCreateData() {
		insert new Account(Name=System.Label.NHW_Data_Prep_Account_Detail);
		WDR_Candidate__c candidate = PF_NHW_TestDataPrepUtil.createWDRCandidateObject();
		WDR_Job__c job = PF_NHW_TestDataPrepUtil.createWDRJobObject();
		WDR_Application__c application = PF_NHW_TestDataPrepUtil.createWDRAppObject();
		Boolean closePreboardingCase = false;

		String wDRData = PF_NHW_TestDataPrepRestService.createData(candidate, job, application, closePreboardingCase);
		Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(wDRData);

		Map<String, Object> wDRCandObj = (Map<String, Object>)result.get('candidate');
		Map<String, Object> wDRJobObj = (Map<String, Object>)result.get('job');
		Map<String, Object> wDRAppObj = (Map<String, Object>)result.get('application');

		System.assertEquals(wDRCandObj.get('First_Name__c'), candidate.First_Name__c);
		System.assertEquals(wDRJobObj.get('Job_Title__c'), job.Job_Title__c);
		System.assertEquals(wDRAppObj.get('Start_Date__c'), String.ValueOf(application.Start_Date__c));
	}
}