/**
 * W-9965293
 * Utility class for the MA_CommunitySSOJITHandler
 * 
 * Version    Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0       15/11/2021      Chakshu Malhotra        Class created to hold utility methods, to help in JIT provisioning logic for SSO users.
 * v2.0       03-02-2022      Chakshu Malhotra        W-10449458 : Added logic to publish auto-enrol platform events to enrol contacts for community events.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public with sharing class MA_CommunitySSOJITHandlerUtil {

    private static final String CONTACT_RECORD_TYPE_MA = 'MA';
    private static final String COMMUNITY_URL_SUFFIX_LOGIN = 'login';

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used for retrieving the Acquisition Contact based on the user's federation identifier.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    federationId 	   			   DESCRIPTION (Data type String, Federation Identifier of the user using SSO to login to MA)
    * @return   List<Acquisition_Contacts__c>  DESCRIPTION (return List of Acquisition_Contacts__c)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<Acquisition_Contacts__c> getAcquisitionContacts(String federationId) {
        return [SELECT First_Name_Legal__c, Contact_Status__c, Last_Name_Legal__c, Email_Address_Target__c, Acquisition_Company__c, 
                Remove_Community_Access__c, Time_Zone__c 
                FROM Acquisition_Contacts__c 
                WHERE Email_Address_Target__c = :federationId];
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to populate & return Contact based on the Acquisition contact details & Account.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acquisitionContact          DESCRIPTION (Data type Acquisition_Contacts__c, Acquisition contact)
    * @param    account 	   			    DESCRIPTION (Data type Account, Acquisition company account)
    * @param    communityId 	   	        DESCRIPTION (Data Id String, MA community identifier)
    * @return   Contact                     DESCRIPTION (return Contact)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static Contact getContact(Acquisition_Contacts__c acquisitionContact, Account account, Id communityId) {
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.Acquisition_Contacts__c = acquisitionContact.Id;
        contact.LastName = acquisitionContact.Last_Name_Legal__c;
        contact.FirstName = acquisitionContact.First_Name_Legal__c;
        contact.Email = acquisitionContact.Email_Address_Target__c;

        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CONTACT_RECORD_TYPE_MA).getRecordTypeId();

        if(!String.isEmpty(communityId)) {
            contact.M_A_Community_URL__c = Network.getLoginUrl(communityId).removeEnd(COMMUNITY_URL_SUFFIX_LOGIN);
        }

        return contact;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * W-10449458 : Method to publish auto enrolment platform events if valid execution.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContacts 	DESCRIPTION (Data type List<Acquisition_Contacts__c>, List of Acquisition Contact records)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void publishAutoEnrolmentEvents(List<Acquisition_Contacts__c> acqContacts) {
        Map<Id, Acquisition_Contacts__c> acqContactMap = new Map<Id, Acquisition_Contacts__c> {acqContacts[0].Id => acqContacts[0]};
        MA_AutoEnrolmentHelper.publishAutoEnrolmentPlatformEvents(acqContactMap, MA_AutoEnrolmentHelper.EnrolmentSource.USER_CREATION);
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * This method is used to populate & return User based on the contact details & federation identifier.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    usr                 DESCRIPTION (Data type User, User record to be populated)
    * @param    contact             DESCRIPTION (Data type Contact, Contact record for the Acquisition contact)
    * @param    federationId 	    DESCRIPTION (Data Id String, Federation Identifier of the user)
    * @param    ssoConfig 	        DESCRIPTION (Data Id MA_Community_SSO_Config__mdt, SSO config custom metadata for the company)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void populateUser(User usr, Contact contact, String federationId, MA_Community_SSO_Config__mdt ssoConfig) {
        usr.UserRoleId = null;
        usr.Email = federationId;
        usr.ContactId = contact.Id;
        usr.LastName = contact.LastName;
        usr.FirstName = contact.FirstName;
        usr.profileId =  ssoConfig.ProfileId__c;
        usr.FederationIdentifier = federationId;
        usr.Username = federationId + Label.MA_Community_Username_Suffix;
        usr.alias = CONTACT_RECORD_TYPE_MA + string.valueof(Math.abs(Crypto.getRandomLong())).substring(0,6);

        // W-9965293
        // User TimeZoneSidKey set to Acquisition Contact's timezone instead of running admin user's timezone.
        usr.TimeZoneSidKey = contact.Acquisition_Contacts__r.Time_Zone__c;

        
        //Default Locale, Language, Email settings based on running admin user.
        User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id = :UserInfo.getUserId()];
        usr.LocaleSidKey = currentUser.LocaleSidKey;                            
        usr.EmailEncodingKey = currentUser.EmailEncodingKey;
        usr.LanguageLocaleKey = currentUser.LanguageLocaleKey;
    }
}