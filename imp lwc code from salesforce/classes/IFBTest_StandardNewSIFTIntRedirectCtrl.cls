/**
 * @author Angel Abrego <aabrego@salesfore.com>
 * @date 2017-09-28
 * @description Tests that the right message is returned to the user when they
 *              try to create a new 'SIFT Interview' using the standard 'New'
 *              button
 */
@isTest
private class IFBTest_StandardNewSIFTIntRedirectCtrl {
  
  /**
   * @description Tests that the users are refered to the Interview 1, 2 and 3
   *              records.
   */
  @isTest static void testTalentforceMessage() {
    IFB_SIFT_Settings_List__c settings;
    settings = new IFB_SIFT_Settings_List__c(Name = 'SIFT');
    settings.Refer_to_Talentforce_for_SIFT_Interviews__c = true;
    insert settings;

    Test.setCurrentPage(Page.IFB_StandardNewSIFTInterviewRedirect);
    ApexPages.StandardController sc;
    sc = new ApexPages.StandardController(new IFB_Interview__c());
    IFB_StandardNewSIFTInterviewRedirectCtrl extension;
    extension = new IFB_StandardNewSIFTInterviewRedirectCtrl(sc);

    String title;
    String summary;
    Test.startTest();
      title   = extension.getRedirectMessageTitle();
      summary = extension.getRedirectMessageSummary();
    Test.stopTest();

    System.assertEquals(Label.IFB_NewSIFTIntRedirectTF_title, title);
    System.assertEquals(Label.IFB_NewSIFTIntRedirectTF_summary, summary);
  }

  /**
   * @description Tests that the users are refered to the WD Job Application
   *              records
   */
  @isTest static void testWDRMessage() {
    IFB_SIFT_Settings_List__c settings;
    settings = new IFB_SIFT_Settings_List__c(Name = 'SIFT');
    settings.Refer_to_Talentforce_for_SIFT_Interviews__c = false;
    insert settings;

    Test.setCurrentPage(Page.IFB_StandardNewSIFTInterviewRedirect);
    ApexPages.StandardController sc;
    sc = new ApexPages.StandardController(new IFB_Interview__c());
    IFB_StandardNewSIFTInterviewRedirectCtrl extension;
    extension = new IFB_StandardNewSIFTInterviewRedirectCtrl(sc);

    String title;
    String summary;
    Test.startTest();
      title   = extension.getRedirectMessageTitle();
      summary = extension.getRedirectMessageSummary();
    Test.stopTest();

    System.assertEquals(Label.IFB_NewSIFTIntRedirect_title, title);
    System.assertEquals(Label.IFB_NewSIFTIntRedirect_summary, summary);
  }
  
}