/**
 * @description       : Class to parse criteria filter
 * @author            : Satyam Kumar
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-24-2021   Satyam Kumar   Initial Version
**/
public class MA_FilterCriteriaParser {
    
    public static Boolean parseEvent(Acquisition_Contacts__c acqContact, MA_Community_Events__c event){
        
        if(String.isBlank(event.Filter_Criteria__c) || event.Filter_Criteria__c.trim() == '*'){
            return true;
        }

        List<String> conditions = event.Filter_Criteria__c.split('\\|\\|');
        
        for(String condition:conditions){
            condition = condition.trim();
            if(evaluateCondition(acqContact, condition)){
                return true;
            }
        }
        
        return false;
    }

    private static Boolean evaluateCondition(Acquisition_Contacts__c acqContact, String condition){
        
        if(String.isBlank(condition)){
            return true;
        }
        
        List<String> subconditions = condition.split('\\&\\&');
        
        for(String subcondition:subconditions){
            subcondition = subcondition.trim();
            if(!evaluateSubcondition(acqContact, subcondition)){
                return false;
            }
        }
        
        return true;
    }
    
    private static Boolean evaluateSubcondition(Acquisition_Contacts__c acqContact, String subcondition){
        
        if(String.isBlank(subcondition)){
            return true;
        }
        
        String operand = subcondition.contains('==') ? '==' : subcondition.contains('!=') ? '!=' : subcondition.contains('=%') ? '=%' : subcondition.contains('!%') ? '!%' : subcondition.contains('!IN') ? '!IN' : subcondition.contains('=IN') ? '=IN' : '';
        String[] subconditionOperands =  subcondition.split(operand);
        String[] fieldsChain = subconditionOperands[0].trim().split('\\.');
        String value = null;
        SObject o = acqContact;
        
        for(Integer i = 0; i < fieldsChain.size() - 1; i++){
            o = o.getSobject(fieldsChain[i]);
            if(o == null){
                break;
            }
        }
        
        if(o != null){
            value = String.valueOf(o.get(fieldsChain[fieldsChain.size() - 1]));
        }

        if(operand == '=='){
            return value != null && value == subconditionOperands[1].trim();
        }else if(operand == '!='){
            return value == null || value != subconditionOperands[1].trim();
        }else if(operand == '=%'){
            return value != null && value.contains(subconditionOperands[1].trim());
        }else if(operand == '!%'){
            return value == null || !value.contains(subconditionOperands[1].trim());
        }else if(operand == '!IN'){
            Set<String> options = new Set<String>(subconditionOperands[1].trim().split('\\|'));
            return value == null || !options.contains(value);
        }else if(operand == '=IN'){
            Set<String> options = new Set<String>(subconditionOperands[1].trim().split('\\|'));
            return value != null && options.contains(value);
        }
        return false;
    }
}