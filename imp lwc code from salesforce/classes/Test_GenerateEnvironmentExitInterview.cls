@isTest
private class Test_GenerateEnvironmentExitInterview {

    static testMethod void unitTest1() {
        Test.startTest();
	    	GenerateEnvironmentExitInterview.genExitInterviewEnvironment();
	    	GenerateEnvironmentExitInterview.getExitInterview();
	    	System.assert(GenerateEnvironmentExitInterview.getExitInterview() != null);
	    	GenerateEnvironmentExitInterview.getExitInterviewCommentContinue();
	    	GenerateEnvironmentExitInterview.getExitInterviewComment();
	    	GenerateEnvironmentExitInterview.insertExitInterview();
	    	GenerateEnvironmentExitInterview.insertExitInterviewNoComments();
    	Test.stopTest();
    }
}