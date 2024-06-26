global with sharing class ESDJC_CaseWebService {

    WebService static String reassignCase(String caseId)
    {
        if(Schema.Sobjecttype.Case.isUpdateable()){
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                        
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            
            Case cse = [SELECT Id, Division_Lookup__c, type, Tier__c  FROM Case WHERE Id = :caseId];
            
            if ((cse.Division_Lookup__c!=null) && cse.Division_Lookup__c.equalsIgnoreCase('Japan')&&
                      (cse.Tier__c!=null) && (cse.Tier__c.equalsIgnoreCase('Tier 1'))){
                        dmlOpts.EmailHeader.TriggerUserEmail = true;
                      }
            cse.setOptions(dmlOpts);
            try{
                update cse;
               }
             catch(Exception e){
             	if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
             		return e.getMessage().substring(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION') + 34).trim();
             	}
             	return e.getMessage();
             }
        } else {
            ESDJC_Util.displayAccessPrivilegeError('Update Case');
        }
        
        return 'true';
        
    }
    
}