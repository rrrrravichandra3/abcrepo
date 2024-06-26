/**
 * @description       : 
 * @author            : Priyanka Kanani
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  : Priyanka Kanani
**/
public with sharing class CcEmp_PagesConfiguration {
        @AuraEnabled(cacheable=true)
        public static List<CcEmp_NavigationItem__mdt> getNavigationItem() {
           return [SELECT Label, DeveloperName, Icon__c, Navigation_Type__c, LWC_Component_Name__c, Section_Description__c,
                  IsLandingPage__c, MenuOrder__c, PageId__c, ParentId__c, isRequired__c
                  FROM CcEmp_NavigationItem__mdt WHERE IsActive__c = true ORDER BY MenuOrder__c];
        }
        
        @AuraEnabled(cacheable=true)
        public static List<CcEmp_Preferences__c> getPreferences(String userId) {
                return [SELECT Id, Onboarding_Completed_Steps__c FROM CcEmp_Preferences__c WHERE User__c = :userId LIMIT 1];
        }

        @AuraEnabled
        public static void savePreference(String userId, String completedSteps) {
                List<CcEmp_Preferences__c> preferences = [SELECT Id,Onboarding_Completed_Steps__c FROM CcEmp_Preferences__c WHERE User__c = :userId LIMIT 1];
                CcEmp_Preferences__c preference;

                 // Check if a preference record exists
                if (preferences.isEmpty()) {
                        // No existing record, create a new one
                        preference = new CcEmp_Preferences__c();
                        preference.User__c = userId;
                } else {
                        // Use the existing record
                        preference = preferences[0];
                }

                preference.Onboarding_Completed_Steps__c = completedSteps;
                upsert preference;
        }


}