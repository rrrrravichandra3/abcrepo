public with sharing Class IdpTriggerHandler{
    public enum IDP_OBJECT {IDP, IDP_OBJECTIVES, IDP_ACTIONS}
    public static Map<IDP_OBJECT, List<String>> IDP_OBJECT_FIELDS_MAP = new Map<IDP_OBJECT, List<String>>{IDP_OBJECT.IDP => new List<String>{'Career_Interest__c', 'Key_Strengths__c'}, IDP_OBJECT.IDP_OBJECTIVES => new List<String>{'IDP_Objective_Name__c', 'IsDeleted__c'}, IDP_OBJECT.IDP_ACTIONS => new List<String>{'Action__c', 'Status__c','Completed_Date__c', 'Support__c', 'IsDeleted__c'}};
    
    public static void handleLastSavedDate(List<Idp__c> newIdps, Map<Id,Idp__c> oldIdpMap){
        if(!IDPWebService.isLastSavedDateUpdated){
            handleLastSavedDateOnIdp(newIdps, oldIdpMap);
        }
    }

    public static void handleLastSavedDateOnIdp(List<Idp__c> newIdps, Map<Id,Idp__c> oldIdpMap){

        for(Idp__c idp : newIdps){
            Idp__c oldIdp = oldIdpMap.get(idp.Id);
            if(hasUserUpdated(idp, oldIdp, IDP_OBJECT.IDP)){
                idp.Last_Saved_Date__c = System.now();
            }
        }

    }
    
    public static boolean hasUserUpdated(sObject newRecord, sObject oldRecord, IDP_OBJECT objectName){
    
        List<String> fieldNames = IDP_OBJECT_FIELDS_MAP.get(objectName);
    
        for(String fieldName : fieldNames){
            if(checkFieldUpdate(newRecord, oldRecord, fieldName)){
                return true;
            }
        }
        return false;
    }
    
    private static boolean checkFieldUpdate(sObject newRecord, sObject oldRecord, String fieldName){
    
        if(newRecord.get(fieldName) != null && newRecord.get(fieldName) != oldRecord?.get(fieldName)){
            return true;
        }
        return false;
    
    }

    public static List<IDP__c> queryIdp(Set<Id> idpIds){
    
        String query = 'SELECT Id, Last_Saved_Date__c, ' + String.join(IDP_OBJECT_FIELDS_MAP.get(IDP_OBJECT.IDP), ', ') + ' FROM IDP__c WHERE Id in :idpIds WITH SECURITY_ENFORCED';
        List<IDP__c> idps = Database.query(query);
        return idps;
    
    }

    public static void updateLastSavedOnIdp(List<IDP__c> idps){

        try{
            List<IDP__c> idpsToUpdate = new List<IDP__c>();
            for(Idp__c idp : idps){
                idp.Last_Saved_Date__c = System.now();
                idpsToUpdate.add(idp);
            }
            IDPWebService.isLastSavedDateUpdated = true;
            SObjectAccessDecision updateSecurityDecision = Security.stripInaccessible(AccessType.UPDATABLE, idpsToUpdate);
            update updateSecurityDecision.getRecords();
        } catch(exception ex){
            String ErrContext = 'Error on updating Last Saved Date on IDP for User with Id '+ UserInfo.getUserId();
            PF_Logger.log('IDP','ERROR',ex.getMessage(),ErrContext,ex.getStackTraceString(),'IdpTriggerHandler');  
        }

    }
}