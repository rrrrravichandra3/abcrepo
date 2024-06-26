@isTest
public class PF_NHW_DeleteTestDataBatchTest {
    @isTest
    public static void deleteTestData() {
		insert new Account(Name=System.Label.NHW_Data_Prep_Account_Detail);
		WDR_Candidate__c candidate = PF_NHW_TestDataPrepUtil.createWDRCandidateObject();
		WDR_Job__c job = PF_NHW_TestDataPrepUtil.createWDRJobObject();
		WDR_Application__c application = PF_NHW_TestDataPrepUtil.createWDRAppObject();
		Boolean closePreboardingCase = false;
        PF_NHW_TestDataPrepHandler.createTestData(candidate, job, application, closePreboardingCase);
        Test.startTest();
        PF_NHW_DeleteTestDataBatch deleteTestDataBatch = new PF_NHW_DeleteTestDataBatch(UserInfo.getUserId());
        Id jobId = Database.executeBatch(deleteTestDataBatch);
        System.assertNotEquals(null, jobId, 'Batch job Id is populated');
        Test.stopTest();
    }
}