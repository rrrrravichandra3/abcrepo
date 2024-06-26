/*
 * This class allows to work with ESDJC_Case_Settings__mdt
 * @author Alexey Boyko
*/
public class ESDJC_CaseSettingService {

    /**
    * This method is used for getting String value from custom metadata record by setting name
    * @param - String settingName
    * @return type - String
    */
    public static String getStringValue(String settingName) {
        String caseSettingValue;
        List<ESDJC_Case_Settings__mdt> caseSettings = [SELECT ESDJC_Case_Setting_Value__c FROM ESDJC_Case_Settings__mdt WHERE DeveloperName =: settingName];
        if (!caseSettings.isEmpty()) {
            caseSettingValue = caseSettings.get(0).ESDJC_Case_Setting_Value__c;
        }
        return caseSettingValue;
    }
    
    /**
    * This method is used for getting List of values from custom metadata record by setting name
    * @param - String settingName
    * @return type - List<String>
    */
    public static List<String> getListValues(String settingName) {
        return getStringValue(settingName).split(','); 
    }
    
    /**
    * This method is used for getting Set of values from custom metadata record by setting name
    * @param - String settingName
    * @return type - Set<String>
    */
    public static Set<String> getSetValues(String settingName) {
        return new Set<String>(getListValues(settingName));
    }
    
    /**
    * This method is used for getting Boolean value from custom metadata record by setting name
    * @param - String settingName
    * @return type - Boolean
    */
    public static Boolean getBooleanValue(String settingName) {
        return Boolean.valueOf(getStringValue(settingName));
    }
    
    /**
    * This method is used for getting Integer value from custom metadata record by setting name
    * @param String settingName
    * @return type - Integer
    */
    public static Integer getIntegerValue(String settingName) {
        return Integer.valueOf(getStringValue(settingName));
    }

}