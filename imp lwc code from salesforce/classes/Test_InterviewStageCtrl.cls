@isTest
public with sharing class Test_InterviewStageCtrl {
    static testmethod void coverCode() {
    	ts2__Interview__c interviewObject = Test_Utils.createDefaultInterview();    	
    	ApexPages.standardController controller = new ApexPages.standardController(interviewObject);
    	InterviewStageCtrl ctrl =  new InterviewStageCtrl(controller);
	   	System.assertEquals('New',ctrl.interview.Interview_Stage__c , 'Checking that current interview stage is set correctly while the interview object is created');
	   	System.assertEquals('Phone Interview',ctrl.getNextStage(), 'Checking that next interview stage is set correctly');
	   	System.assertEquals('Phone Interview',ctrl.getNextStageDisplayText(), 'Checking that display text for next interview stage is set correctly');
	   	ctrl.advance();
	   	ctrl.checkCurrentStage();
	   	ctrl.cancel();
    }
}