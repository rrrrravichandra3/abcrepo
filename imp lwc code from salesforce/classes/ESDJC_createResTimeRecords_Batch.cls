global class ESDJC_createResTimeRecords_Batch implements Database.Batchable<sObject> {

    global database.querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id, Tier_1_Age__c,Tier_2_Age__c,Tier_3_Age__c,Tier_4_Age__c 
                                            from Case 
                                            WHERE isClosed=True 
                                              AND (Tier_1_Age__c!=null OR Tier_2_Age__c!=null OR Tier_3_Age__c!=null OR Tier_4_Age__c!=null)]);
    }   
    
    global void execute(Database.BatchableContext bc, List<Case> scope) {
        
        //get the case Ids for which a child record of Resolution Time already exists
        Set<Id> caseIdsWithExistingResolutionRecord = new Set<Id>();
        Set<Id> allCaseIds = (new Map<Id, Case>(scope)).keySet();
        List<DJC_Resolution_Time__c> resolutionTimeRecords = [Select Case__c, Tier_1_Age_in_Days__c, Tier_2_Age_in_Days__c, Tier_3_Age_in_Days__c, Tier_4_Age_in_Days__c 
                                                                from DJC_Resolution_Time__c
                                                                where Case__c IN :allCaseIds];
        for(DJC_Resolution_Time__c currRT : resolutionTimeRecords){
            caseIdsWithExistingResolutionRecord.add(currRT.Case__c);
        }
        //Iterate over current batch of cases. If no Resolution Time record exists, create it
        List<DJC_Resolution_Time__c> newRTrecords = new List<DJC_Resolution_Time__c>();
        for(Case currentCase : scope ){
            if(!caseIdsWithExistingResolutionRecord.contains(currentCase.Id)){
                DJC_Resolution_Time__c currentRTrecord = new DJC_Resolution_Time__c();
                currentRTrecord.Case__c = currentCase.Id;
                currentRTrecord.Tier_1_Age_in_Days__c = currentCase.Tier_1_Age__c;
                currentRTrecord.Tier_2_Age_in_Days__c = currentCase.Tier_2_Age__c;
                currentRTrecord.Tier_3_Age_in_Days__c = currentCase.Tier_3_Age__c;
                currentRTrecord.Tier_4_Age_in_Days__c = currentCase.Tier_4_Age__c;
                newRTrecords.add(currentRTrecord);
            }
        }
        //insert these resolution time records
        Database.insert(newRTrecords);
    } 
    
    global void finish(Database.BatchableContext bc) {
    }
         
}