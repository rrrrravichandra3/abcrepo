public with sharing Class IDP_ActionsTriggerHandler{
    
    public static void handleAfterInsert(List<IDP_Action__c> newActions, Map<Id,IDP_Action__c> oldActionsMap){
        if(!IDPWebService.isLastSavedDateUpdated){
            handleLastSavedDate(newActions, oldActionsMap, true);
        }
    }
    
    public static void handleAfterUpdate(List<IDP_Action__c> newActions, Map<Id,IDP_Action__c> oldActionsMap){
        if(!IDPWebService.isLastSavedDateUpdated){
            handleLastSavedDate(newActions, oldActionsMap, false);        
        }
    }
    
    public static void handleLastSavedDate(List<IDP_Action__c> newActions, Map<Id,IDP_Action__c> oldActionsMap, Boolean isInsert){

        Set<Id> objIds = new Set<Id>();

        for(IDP_Action__c action : newActions){
            if(oldActionsMap!=null){
                IDP_Action__c oldAction = oldActionsMap.get(action.Id);
                if(IdpTriggerHandler.hasUserUpdated(action, oldAction, IdpTriggerHandler.IDP_OBJECT.IDP_ACTIONS)){
                    objIds.add(action.IDP_Objective__c);
                }
            }
            else{
                objIds.add(action.IDP_Objective__c);
            }
        }

        if(!objIds.isEmpty()){
            Set<Id> idpIds = new Set<Id>();
            for(IDP_Objective__c objs : [SELECT IDP__c FROM IDP_Objective__c WHERE Id IN :objIds WITH SECURITY_ENFORCED]){
                idpIds.add(objs.IDP__c);
            }
            if(!idpIds.isEmpty()){
                List<IDP__c> idps = IdpTriggerHandler.queryIdp(idpIds);
                IdpTriggerHandler.updateLastSavedOnIdp(idps);
            }
        }
    }
}