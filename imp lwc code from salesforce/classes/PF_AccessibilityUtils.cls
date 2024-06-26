public class PF_AccessibilityUtils {
    
    public enum PermissionType {ACCESSIBLE, UPDATEABLE, CREATEABLE, DELETABLE}
    
    public static boolean checkFLS(String sobjectName, PermissionType permission, List<String> fieldsToCheck){
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        if (permission == PermissionType.DELETABLE && !schemaMap.get(sobjectName).getDescribe().isDeletable()) {
            return false;
        }
        
        Map<String, Schema.SObjectField> fieldsMap = schemaMap.get(sobjectName).getDescribe().fields.getMap();
        
        for (String fieldToCheck : fieldsToCheck) {
            if(permission == PermissionType.ACCESSIBLE && !fieldsMap.get(fieldToCheck).getDescribe().isAccessible()){
                return false;
            }else if (permission == PermissionType.CREATEABLE && !fieldsMap.get(fieldToCheck).getDescribe().isCreateable()) {
                return false;
            }else if (permission == PermissionType.UPDATEABLE && !fieldsMap.get(fieldToCheck).getDescribe().isUpdateable()) {
                return false;
            }
        }
        return true;
    }
}