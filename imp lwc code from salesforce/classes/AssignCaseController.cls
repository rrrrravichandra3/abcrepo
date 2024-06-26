/*
 * @Author : Kshitiz Srivastava
 * Gus story W-4903237
 * This class is the controller for Lightning component AssignCase.cmp
 * Corresponding Test Class is Test_AssignCaseController
 * Salesforce classic uses a javascript button "Assign case" (ES_DJC_Assign_Case) and class "ESDJC_CaseWebService"
 * To mimick the behavior in LEX, a quick action "AssignCase" is created and tied to lightning component AssignCase.cmp details of functionality that is being replicated for lex
 */
public with sharing class AssignCaseController {
    
    @AuraEnabled
    public static String reassignCase(Id currentCaseId)
    {
        if(!Schema.Sobjecttype.Case.isUpdateable()){
            throw new AuraHandledException('ERROR: You don\'t have sufficient privileges to update Case');
        }

        if(
            (!Schema.sObjectType.Case.fields.Tier__c.isAccessible()) 
            || 
            (!Schema.sObjectType.Case.fields.Division_Lookup__c.isAccessible())
            ||
            (!Schema.sObjectType.Case.fields.OwnerId.isAccessible())
            ||
            (!Schema.sObjectType.Case.fields.CaseNumber.isAccessible())
          ){
            throw new AuraHandledException('ERROR: You don\'t have sufficient privileges');
        }
       
        Case currCase = [Select Tier__c,Division_Lookup__c from Case where Id=:currentCaseId limit 1]; 
        if(currCase == null){
            throw new AuraHandledException('There was an error retrieving case details');
        }
        //If Tier is Tier 2, throw the error
        else if(currCase.Tier__c == 'Tier 2'){
            throw new AuraHandledException('Tier 2 cases cannot be reassigned');
        }
        else{
            try{
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            
            if ((currCase.Division_Lookup__c!=null) 
                && currCase.Division_Lookup__c.equalsIgnoreCase('Japan')
                &&(currCase.Tier__c!=null) 
                &&(currCase.Tier__c.equalsIgnoreCase('Tier 1'))){
                    dmlOpts.EmailHeader.TriggerUserEmail = true;
                }
            currCase.setOptions(dmlOpts);
            update currCase;
            String successMessage = 'Case reassigned';
            return successMessage;
            }catch(DMLException dml){
                String errorMsg = dml.getDmlMessage(0);
                throw new AuraHandledException(errorMsg);
            }catch(Exception e){
                String errorMessage = e.getMessage();
                throw new AuraHandledException(errorMessage);
            }
        }
        
    }
}