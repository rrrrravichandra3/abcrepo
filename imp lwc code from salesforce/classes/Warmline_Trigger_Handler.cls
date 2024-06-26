public with sharing class Warmline_Trigger_Handler {

   public static void sendWarmlineEscalationNotifications(Map<Id, Warmline__c> oldWarmlinesMap,  Map<Id, Warmline__c> newWarmlinesMap){
        
        Set<Id> warmlineCaseIds = new Set<Id>();
        List<String> oldDispositionList = new List<String>();
        List<String> newDispositionList = new List<String>();
        List<Case> warmlineCaseEscalationNotifications = new List<Case>();
        if(oldWarmlinesMap != null){
            for(Id wrmId: oldWarmlinesMap.keySet()){
                
                if(newWarmlinesMap.get(wrmId).Disposition__c != null){
                    newDispositionList = newWarmlinesMap.get(wrmId).Disposition__c.split(';');
                if(oldWarmlinesMap.get(wrmId).Disposition__c != null)
                    oldDispositionList = oldWarmlinesMap.get(wrmId).Disposition__c.split(';');
                    
                if(newWarmlinesMap.get(wrmId).Disposition__c != oldWarmlinesMap.get(wrmId).Disposition__c &&
                   !(oldDispositionList.contains(System.Label.Warmline_Disposition_for_Case_Escalation_to_ER)) &&
                   newDispositionList.contains(System.Label.Warmline_Disposition_for_Case_Escalation_to_ER)){
                        warmlineCaseIds.add(newWarmlinesMap.get(wrmId).Case__c);
                    }
                } 
            }
        }
        else{
            for(Id wrmId : newWarmlinesMap.keySet()){
                if(newWarmlinesMap.get(wrmId).Disposition__c != null){
                    newDispositionList = newWarmlinesMap.get(wrmId).Disposition__c.split(';');
                    
                    if(newDispositionList.contains(System.Label.Warmline_Disposition_for_Case_Escalation_to_ER)){
                        warmlineCaseIds.add(newWarmlinesMap.get(wrmId).Case__c);
                    }
                }
            }
        }
       if(warmlineCaseIds.size() > 0){
           for(Case wrmCase : [Select id, contactId from Case where id IN :warmlineCaseIds]){
            warmlineCaseEscalationNotifications.add(wrmCase);
        }
       
        if(warmlineCaseEscalationNotifications.size() > 0){
                EmailTemplate emailTemplte = ESDJC_Util.getEmailTemplate('Warmline_Case_Escalation_Notification');
                ESDJC_CaseHandler.sendEmails(warmlineCaseEscalationNotifications, emailTemplte.Id);
            }
       }   
    }
    
}