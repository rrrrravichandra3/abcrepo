public with sharing class SurveyQuerySelector{
    // Have a static collection of data that you can set in a test
    //   (and later return when the code being tested requests it)
    public static List<Survey> testData = new List<Survey>();

    public List<Survey> query(String surveyName){
        List<Survey> results = [SELECT Id FROM Survey WHERE Name = :surveyName];

        if(Test.isRunningTest()){
            results = SurveyQuerySelector.testData;
        }

        return results;
    }
}