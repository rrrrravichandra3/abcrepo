public without sharing class PB_CommLoginRedirectService {

    @AuraEnabled
    public static String getRedirectURL() {
        Preboarding_Community_Config__c settings = Preboarding_Community_Config__c.getOrgDefaults();
        return settings.SSO_URL__c;
    }
    
}