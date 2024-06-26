/*
*Apex Class to Handle Insertion/Deletion/Updation of Job Profile Records
*/
public  class JobProfileHandler {
    
    public static void isJobCodeOrBonusPercentChanged( Map<Id,Job_Profile__c> newMap, Map<Id,Job_Profile__c> oldMap ){
        Set<Id> AffectedJProfileIds = new Set<Id>();

        //Record all Job profiles with changes that affect a variable percent on an offer
        for(Job_Profile__c jp:newMap.Values()){
            if( jp.Bonus_Target__c != oldMap.get(jp.Id).Bonus_Target__c ){
                 AffectedJProfileIds.add(jp.Id);
            }
        }
    }
    
}