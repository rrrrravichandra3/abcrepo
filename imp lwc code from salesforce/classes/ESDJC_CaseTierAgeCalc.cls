public without sharing class ESDJC_CaseTierAgeCalc {

    

    public static void calculateTierAge(List<Case> currentCases){
        
        
        //Prepare map of Case Id to existing Resolution Object record
        Map<Id, DJC_Resolution_Time__c> caseIdToResTimeMap = new Map<Id, DJC_Resolution_Time__c>();
        Map<Id,Case> caseIdToCaseMap = new Map<Id,Case>();
        //Map each case to its case history
        Map<Id,List<CaseHistory>> caseIdToCaseHistoriesMap = new Map<Id, List<CaseHistory>>();

        for(Case c : currentCases){
            //Populate Map caseIdToCaseMap
            caseIdToCaseMap.put(c.Id,c);
            //Populate Map caseIdToResTimeMap
            if(c.Case_Resolution_Times__r.size()>0){
                caseIdToResTimeMap.put(c.Id, c.Case_Resolution_Times__r[0]);
            }else{
                caseIdToResTimeMap.put(c.Id, null);
            }
            //populate Map caseIdToCaseHistoriesMap partially. Just creating keys
            caseIdToCaseHistoriesMap.put(c.Id,new List<CaseHistory>());
        }

        List<CaseHistory> allCaseHistories = [select Id,NewValue,OldValue,CreatedDate,Field,CaseId 
                                                from CaseHistory 
                                                where (field='Tier__c' or field='IsStopped' or field='BusinessHours')
                                                      and caseId in : caseIdToCaseMap.keySet() 
                                                      order by caseId,createdDate ASC];

        for(CaseHistory cH : allCaseHistories){
            (caseIdToCaseHistoriesMap.get(cH.CaseId)).add(cH);
        }

        //Now we have three maps with Case Ids as keys, and Case, Resolution_Time and List of CaseHistories as values
        List<DJC_Resolution_Time__c> resTimeRecordsToBeUpserted = new List<DJC_Resolution_Time__c>();
        for(Id currentCaseId : caseIdToCaseHistoriesMap.keySet()){
            DJC_Resolution_Time__c currentCaseResTimeRecord = ESDJC_CaseTierAgeCalc_helper.calculateTierAgeSingleCase(caseIdToCaseMap.get(currentCaseId),caseIdToCaseHistoriesMap.get(currentCaseId),caseIdToResTimeMap.get(currentCaseId));
            if(currentCaseResTimeRecord != null){
                resTimeRecordsToBeUpserted.add(currentCaseResTimeRecord);
            }
        }

        //Map caseIdToResTimeMap should be updated after the loop
        upsert resTimeRecordsToBeUpserted;

    }

    
    
}