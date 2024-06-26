/**
*W-11822445-<Build> Single Community - Knowledge Article URL
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         01-10-2022      Ashutosh Belwal         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public without sharing class MA_CommunitySSOController {
    
    private static final String DEFAULT_SSO = Label.MA_Default_SSO_Provider;
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Genrates authenticated sso url for login
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    String                DESCRIPTION (Data type String, SSO Id From URL)
    * @param    String                DESCRIPTION (Data type String, SstartUrl post authentication url)
    * @param    String                DESCRIPTION (Data type String, communityUrl)
    * @return   String                DESCRIPTION (returns login url of IDP)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static String generateSSOUrl(String ssoId, String startUrl, String communityUrl){
       
        if(String.IsBlank(ssoId)){
            ssoId = getSSOIdByName(DEFAULT_SSO);
        }
        
        return Auth.AuthConfiguration.getSamlSsoUrl(communityUrl, startUrl, ssoId);

    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Generate the sso url for survey pages
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    String                DESCRIPTION (Data type String,InvitationId From URL)
    * @param    String                DESCRIPTION (Data type String, SstartUrl post authentication url)
    * @param    String                DESCRIPTION (Data type String, communityUrl)
    * @return   String                DESCRIPTION (returns login url of IDP)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static String getSSOUrlFromInvitation(String InvitationId, String startUrl, String communityUrl){

        SurveyInvitation objInvite =[SELECT Id, Contact.Acquisition_Contacts__r.Acquisition_Company__r.SSO_Config_Name__c 
                                    FROM SurveyInvitation  
                                    WHERE Id =:InvitationId];
        
        String ssoName = objInvite.Contact?.Acquisition_Contacts__r?.Acquisition_Company__r?.SSO_Config_Name__c;
        

        return generateSSOUrl(getSSOIdByName(ssoName) , startUrl, communityUrl);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Return SSO Id from Name
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    String                DESCRIPTION (Data type String, SSO Name)
    * @return   String                DESCRIPTION (SSO Id)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Id getSSOIdByName(String ssoName){
        return  [SELECT DeveloperName, Id 
                FROM SamlSsoConfig 
                WHERE DeveloperName =: ssoName].Id;
    }
}