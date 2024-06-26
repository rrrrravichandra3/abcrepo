public with sharing  class DJCSendSurveyCntl {
 @AuraEnabled
    public static String sendSurvey(String djcCaseId) {
        return DJC_Survey_Service.sendSurvey(djcCaseId);
 		
    }
}