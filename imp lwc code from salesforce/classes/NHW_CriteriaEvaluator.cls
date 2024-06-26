@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public class NHW_CriteriaEvaluator {
    
    public static Boolean evaluateCriteria(Case target, String criteria){
        
        criteria = criteria.trim();
        
        if(criteria == '*' || criteria == 'true'){
            return true;
        }
        
        if(criteria == 'false'){
            return false;
        }

        List<String> conditions = criteria.split('\\|\\|');
        
        for(String condition:conditions){
            condition = condition.trim();
            if(evaluateCondition(target, condition)){
                return true;
            }
        }
        
        return false;
    }
    
    private static Boolean evaluateCondition(Case target, String condition){
        
        if(String.isBlank(condition)){
            return true;
        }
        
        List<String> subconditions = condition.split('\\&\\&');
        
        for(String subcondition:subconditions){
            subcondition = subcondition.trim();
            if(!evaluateSubcondition(target, subcondition)){
                return false;
            }
        }
        
        return true;
    }
    
    private static Boolean evaluateSubcondition(Case target, String subcondition){
        
        if(String.isBlank(subcondition)){
            return true;
        }
        
        String operand = subcondition.contains('==') ? '==' : subcondition.contains('!=') ? '!=' : subcondition.contains('=%') ? '=%' : subcondition.contains('!%') ? '!%' : subcondition.contains('!IN') ? '!IN' : subcondition.contains('=IN') ? '=IN' : '';
        String[] subconditionOperands =  subcondition.split(operand);
        String[] fieldsChain = subconditionOperands[0].trim().split('\\.');
        String value = null;
        SObject o = target;
        
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
            return (value != null && value == subconditionOperands[1].trim()) || (subconditionOperands[1].trim() == 'null' && String.isBlank(value));
        }else if(operand == '!='){
            return ( subconditionOperands[1].trim() != 'null' && value != subconditionOperands[1].trim()) || (!String.isBlank(value) && subconditionOperands[1].trim() == 'null');
        }else if(operand == '=%'){
            return value != null && value.containsIgnoreCase(subconditionOperands[1].trim());
        }else if(operand == '!%'){
            return value == null || !value.containsIgnoreCase(subconditionOperands[1].trim());
        }else if(operand == '!IN'){
            Set<String> options = new Set<String>(subconditionOperands[1].trim().toLowerCase().split('\\|'));
            return value == null || !options.contains(value.toLowerCase());
        }else if(operand == '=IN'){
            Set<String> options = new Set<String>(subconditionOperands[1].toLowerCase().trim().split('\\|'));
            return value != null && options.contains(value.toLowerCase());
        }
        return false;
    }
    
    public static Set<String> getCriteriaDependencies(String criteria){
        
        Set<String> dependencies = new Set<String>();
        
        if(String.isBlank(criteria)){
            return dependencies;
        }
        
        criteria = criteria.trim();
        
        if(criteria == '*'){
            return dependencies;
        }
        
        List<String> conditions = criteria.split('\\|\\|');
        
        for(String condition:conditions){
            
            condition = condition.trim();
            List<String> subconditions = condition.split('\\&\\&');

            for(String subcondition:subconditions){
                
                subcondition = subcondition.trim();               
                String operand = subcondition.contains('==') ? '==' : subcondition.contains('!=') ? '!=' : subcondition.contains('=%') ? '=%' : subcondition.contains('!%') ? '!%' : subcondition.contains('!IN') ? '!IN' : subcondition.contains('=IN') ? '=IN' : '';
                String[] subconditionOperands =  subcondition.split(operand);
                String dependency = subconditionOperands[0].trim();
                dependencies.add(dependency);
            }
        }
        
        return dependencies;
    }
}