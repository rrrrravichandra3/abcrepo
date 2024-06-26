@isTest
private class IFB_RecruitingAppGettingStartedCtrlTest {

	public static testMethod void readIETFRFC4180CSVValueTest() {
        IFB_RecruitingAppGettingStartedCtrl ctrl = new IFB_RecruitingAppGettingStartedCtrl();
        ctrl.generateData();
        
        Integer RecruitingScoringCount = [SELECT count() FROM IFB_Recruiting_Scoring__c ];
    	Integer InterviewQuestionCategoryMapCount = [SELECT count() FROM IFB_InterviewQuestionCategoryMap__c ];
    	Integer InterviewQuestionCount = [SELECT count() FROM IFB_Interview_Question__c ];
        
        System.assertEquals(1, RecruitingScoringCount);
        System.assertEquals(16, InterviewQuestionCategoryMapCount);
        System.assertEquals(28, InterviewQuestionCount);        
    }
}