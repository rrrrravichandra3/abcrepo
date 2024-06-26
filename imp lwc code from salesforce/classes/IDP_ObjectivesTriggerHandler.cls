public with sharing Class IDP_ObjectivesTriggerHandler{
    
    public static void handleAfterInsert(List<IDP_Objective__c> newObjectives, Map<Id,IDP_Objective__c> oldObjectivesMap){
        if(!IDPWebService.isLastSavedDateUpdated){
            handleLastSavedDate(newObjectives,oldObjectivesMap, false);
        }
    }
    
    public static void handleAfterUpdate(List<IDP_Objective__c> newObjectives, Map<Id,IDP_Objective__c> oldObjectivesMap){
        if(!IDPWebService.isLastSavedDateUpdated){
            handleLastSavedDate(newObjectives,oldObjectivesMap, true);        
        }
    }
    
    public static void handleLastSavedDate(List<IDP_Objective__c> newObjectives, Map<Id,IDP_Objective__c> oldObjectivesMap, Boolean isUpdate){

        Set<Id> idpIds = new Set<Id>();

        for(IDP_Objective__c obj : newObjectives){
            if(isUpdate){
                IDP_Objective__c oldobj = oldObjectivesMap.get(obj.Id);
                if(IdpTriggerHandler.hasUserUpdated(obj, oldobj, IdpTriggerHandler.IDP_OBJECT.IDP_OBJECTIVES)){
                    idpIds.add(obj.IDP__c);
                }
            }
            else{
                idpIds.add(obj.IDP__c);
            }
        }

        if(!idpIds.isEmpty()){
            List<IDP__c> idps = IdpTriggerHandler.queryIdp(idpIds);
            IdpTriggerHandler.updateLastSavedOnIdp(idps);
        }
    }
}