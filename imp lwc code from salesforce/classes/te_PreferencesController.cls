/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : Urvish Shah (ushah)
**/
public with sharing class te_PreferencesController {
   
    @AuraEnabled
    public static te_Preferences__c getPreferences(){
        Contact con;
        List<te_Preferences__c> preferences;
        te_Preferences__c preference;
        try {
            String userId = UserInfo.getUserId();
            User usr = [SELECT Id, EmployeeNumber FROM User WHERE Id =: userId];
            String workerId = usr.EmployeeNumber;
            if(workerId != null){
                 con = [SELECT Id, Talent_Experience_Preference__c, ES_DJC_Work_Location__c
                        FROM Contact
                        WHERE EmployeeNumber__c =: workerId];

                preferences = [SELECT Id, First_Login_Complete__c,Pathway__c,Preferred_Work_Location__c, Open_to_Relocation__c, Relocation_Country__c FROM te_Preferences__c WHERE Id =: con.Talent_Experience_Preference__c LIMIT 1];
            }
            if(preferences.size() == 0){
                preference = createPreferenceObject(con);
            }else{
                preference = preferences[0];
            }

        return preference;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static te_Preferences__c updatePreferences(te_Preferences__c preferences){
        try {
            update preferences;
            return preferences;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description getContactStages : Contact stages will be returned to UI to be used as dearch filters
     * @return   return List<String>
     * All Picklist values of Candidate_Stage__c field
     */
    @Auraenabled(cacheable=true)
    public static List<String> getWorkLocations() {
        List<String> pickListValuesList = new List<String>();
        for (Schema.PicklistEntry pickListVal : te_Preferences__c.Preferred_Work_Location__c.getDescribe().getPicklistValues()) {
        pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    @Auraenabled(cacheable=true)
    public static List<String> getRelocationOptions() {
        List<String> pickListValuesList = new List<String>();
        for (Schema.PicklistEntry pickListVal : te_Preferences__c.Relocation_Country__c.getDescribe().getPicklistValues()) {
        pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    public static te_Preferences__c createPreferenceObject(Contact con){
        te_Preferences__c preference = new te_Preferences__c();
        preference.Preferred_Work_Location__c = con.ES_DJC_Work_Location__c;
        insert preference;

        con.Talent_Experience_Preference__c = preference.Id;

        update con;

        return preference;
    }
    

}