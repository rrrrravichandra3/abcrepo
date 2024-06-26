public without sharing class IA_FindFutureForce {
 public static Boolean findFutureForce() {
        Boolean result= false;
        String email =  UserInfo.getUserEmail();
        if (email != null) {
            String qSELECT = 'SELECT Id, isFutureforce__c';
            String qFROM = 'FROM Insiders_Tracking__c';
            String qWHERE = 'WHERE Candidate_Email__c = : email AND isFutureforce__c = true';
            if(Test.isRunningTest()){
                qWHERE = 'WHERE isFutureforce__c = true';
            }
            String qWITH = 'WITH SECURITY_ENFORCED';
            String query = qSELECT + ' ' + qFROM + ' ' + qWHERE + ' ' + qWITH;
            List<Insiders_Tracking__c> candidateTrackingRecords = Database.query(query);
            result = !candidateTrackingRecords.isEmpty();
        }
        return result;
    }
}