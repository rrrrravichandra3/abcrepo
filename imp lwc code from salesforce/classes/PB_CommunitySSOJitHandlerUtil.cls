/**
 * Utility class for the PB_CommunitySSOJitHandler
 * 
 * Version    Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0       11/28/2023      Ashutosh Belwal        Class created to hold utility methods, to help in JIT provisioning logic for SSO users.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public class PB_CommunitySSOJitHandlerUtil {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to return the exsiting employee contact based on the federeation Id
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    federationId                 DESCRIPTION (Data type String, Workday Employee Id coming In SMAL Request)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Contact> getContact(String federationId) {
        return new List<Contact>([SELECT FirstName, LastName, Email 
                                  FROM Contact 
                                  WHERE EmployeeNumber__c =: federationId]);
    }
    
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to populate & return User based on the contact details & federation identifier.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    usr                 DESCRIPTION (Data type User, User record to be populated)
    * @param    contact             DESCRIPTION (Data type Contact, Contact record for the Acquisition contact)
    * @param    federationId 	    DESCRIPTION (Data Id String, Federation Identifier of the user)
    * @param    profileId 	    	DESCRIPTION (Data Id String, Profile Id of the user)
    * @param    ssoConfig 	        DESCRIPTION (Data Id PB_SSO_Config__mdt, SSO config custom metadata for preboaring community)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void populateUser(User usr, Contact contact, String federationId, Id profileId, PB_SSO_Config__mdt ssoSetting) {
        
        usr.UserRoleId 			 = null;
        usr.Email 				 = contact.Email;
        usr.ContactId 			 = contact.Id;
        usr.LastName 			 = contact.LastName;
        usr.FirstName 			 = contact.FirstName;
        usr.profileId 			 = profileId;
        usr.FederationIdentifier = federationId;
        usr.Username 			 = getUsername(contact.Email, ssoSetting.Username_Suffix__c);
        usr.alias 				 = ESDJC_Util.getNickname(8);
        usr.LocaleSidKey 	 	 = ssoSetting.LocaleSidKey__c;                            
        usr.EmailEncodingKey 	 = ssoSetting.EmailEncodingKey__c;
        usr.LanguageLocaleKey 	 = ssoSetting.LanguageLocaleKey__c;
        usr.TimeZoneSidKey 		 = ssoSetting.TimeZoneSidKey__c;
        
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to return the sso setting stored in custom metadata
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    
    * @return 				Instance of PB_SSO_Config__mdt
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static PB_SSO_Config__mdt getSsoSetting(){
        return PB_SSO_Config__mdt.getInstance('Default');
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to return the Instance of profile based on profile name
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    profileName 	DESCRIPTION (Data type String, Profile Name)
    * @return 					Instance of Profile
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Profile getProfile(String profileName){
        return [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to generate the username for perboarding community
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    email 			DESCRIPTION ( type String, Profile Name)
    * @param    email 			DESCRIPTION ( type String, Profile Name)
    * @return 					Instance of Profile
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String getUsername(String email, String suffix){
        String leftPart = email.substringBefore('@');
        return leftPart+suffix;
    }
}