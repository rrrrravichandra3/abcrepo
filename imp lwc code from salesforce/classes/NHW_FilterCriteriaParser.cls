@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public class NHW_FilterCriteriaParser {
    
    public static Boolean parseProvisioning(Case provisioningCase, NHW_Provisioning__c provisioning){
        
        if(String.isBlank(provisioning.Filter_Criteria__c)){
            return false;
        }

        //Skipping prov recs with olf filter criteria format.
         if(provisioning.Filter_Criteria__c.startsWith('##')){
            return false;
        }       
 
        if(provisioning.Filter_Criteria__c.trim() == '*'){
            return true;
        }

        List<String> conditions = provisioning.Filter_Criteria__c.split('\\|\\|');
        
        for(String condition:conditions){
            condition = condition.trim();
            if(evaluateCondition(provisioningCase, condition)){
                return true;
            }
        }
        
        return false;
    }

    private static Boolean evaluateCondition(Case provisioningCase, String condition){
        
        if(String.isBlank(condition)){
            return true;
        }
        
        List<String> subconditions = condition.split('\\&\\&');
        
        for(String subcondition:subconditions){
            subcondition = subcondition.trim();
            if(!evaluateSubcondition(provisioningCase, subcondition)){
                return false;
            }
        }
        
        return true;
    }
    
    private static Boolean evaluateSubcondition(Case provisioningCase, String subcondition){
        
        if(String.isBlank(subcondition)){
            return true;
        }
        
        String operand = subcondition.contains('==') ? '==' : subcondition.contains('!=') ? '!=' : subcondition.contains('=%') ? '=%' : subcondition.contains('!%') ? '!%' : subcondition.contains('!IN') ? '!IN' : subcondition.contains('=IN') ? '=IN' : '';
        String[] subconditionOperands =  subcondition.split(operand);
        String[] fieldsChain = subconditionOperands[0].trim().split('\\.');
        String value = null;
        SObject o = provisioningCase;
        
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