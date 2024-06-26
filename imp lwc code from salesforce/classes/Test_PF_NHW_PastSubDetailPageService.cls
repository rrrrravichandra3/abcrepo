@istest
public class Test_PF_NHW_PastSubDetailPageService {
  @isTest
  static void validatePageConfig() {
    WDR_TestFactory testData = new WDR_TestFactory();
    testdata.createJobApp();
    WDR_candidate__c cand = testdata.getDefaultCandidate();
    WDR_Job__c job = testdata.getDefaultJobReq();
    job.Employment_Type__c = 'Regular';
    cand.Email__c = userinfo.getUserEmail();
    Contact hM = [SELECT id, Email FROM Contact WHERE email = :UserInfo.getUserEmail()];
    hM.email = 'testHM@Email.com';
    Test.startTest();
    update job;
    update hM;
    update cand;
    WDR_Application__c jobApp = testdata.getDefaultJobApp();
    jobApp.Candidate_Stage__c = 'Placement';
    update jobApp;
    Test.stopTest();
    Case c = [SELECT id FROM Case];
    c.NHW_Employee_Type__c = 'Regular Employee';
    update c;
    c = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(c.id);
    PF_NHW_PageService pageService = new PF_NHW_PastSubmissionDetailPageService();
    Map<String, Object> pageInfo = pageService.getPageInformation('employeeviewandupdate', '');
    System.assert(
      ((List<PF_NHW_ReviewService.ReviewItemGroup>) ((Map<String, Object>) pageInfo.get('PAGE_CONFIG'))
          .get('REVIEW_ITEMS'))
        .size() > 0,
      'page config set'
    );
  }
}