@isTest(SeeAllData=true)
public with sharing class Test_ESDJC_CaseHelpLinkController {
    public static testMethod void testController() {
        PageReference pageRef = Page.ESDJC_CaseArticlesWithURLs;
        Test.setCurrentPage(pageRef);
        Case aCase = ESDJC_TestUtil.createcase();
        ApexPages.StandardController standard = new ApexPages.StandardController(aCase);
        ESDJC_CaseHelpLinkController controller = new ESDJC_CaseHelpLinkController(standard);
        System.assertNotEquals(null, controller.linkedCaseArticles);
    }
}