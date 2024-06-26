//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
//This class should be configured in single sign on settings in the org to be run by a system admin user.
global with sharing class MA_CommunitySSOJITHandler implements Auth.SamlJitHandler {

    private static final String ACQ_CONTACT_SOBJ_API = 'Acquisition_Contacts__c';
    private static final List<String> ACQ_CONTACT_FIELDS = new List<String> {'First_Name_Legal__c', 'Contact_Status__c', 'Last_Name_Legal__c', 'Email_Address_Target__c', 'Acquisition_Company__c', 'Remove_Community_Access__c', 'Time_Zone__c'};

    private static final String ACCOUNT_SOBJ_API = 'Account';
    private static final List<String> ACCOUNT_FIELDS = new List<String> {'Name'};

    private static final String CONTACT_SOBJ_API = 'Contact';
    private static final List<String> CONTACT_FIELDS = new List<String> {'FirstName','LastName','Email'};

    private static final String CONTACT_STATUS_CANCELLED = 'Cancelled';
    private static final String ACQ_CONTACTS_ACCESS_EXCEPTION = 'The Admin running user does not have sufficient access on Acq Contacts';
    private static final String ACQ_CONTACTS_NA_EXCEPTION = 'Unable to find Acquisition contact available for the given FedId';
    private static final String EXCESS_ACQ_CONTACTS_EXCEPTION = 'More than one Acquisition contact available for the given FedId';
    private static final String COMMUNITY_ACCESS_EXCEPTION = 'You do not have access to the community.';
    private static final String ACCOUNT_NA_EXCEPTION = 'Unable to find account for given fed identifier';
    private static final String ACCOUNT_ACCESS_EXCEPTION = 'The Admin running user does not have sufficient access on Account';
    private static final String SSO_CONFIG_NA_EXCEPTION = 'Unable to find any sso config custom metadata for ';
    
    private class JitException extends Exception {}

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User usr = new User();
        handleJIT(usr, communityId, federationIdentifier);
        return usr;
    }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        //W-9965293 : Updates user timezone details (if any changes) when user already exists.
        User usr = [SELECT Id, TimeZoneSidKey, Contact.Acquisition_Contacts__r.Time_Zone__c FROM User WHERE Id = :userId];
        String acquisitionContactTimezone = usr?.Contact?.Acquisition_Contacts__r?.Time_Zone__c;
        
        if(acquisitionContactTimezone != null && usr.TimeZoneSidKey != acquisitionContactTimezone) {
            usr.TimeZoneSidKey = acquisitionContactTimezone;
            update usr;
        }
    }

    private void handleJIT(User usr, Id communityId, String federationIdentifier) {
        if(communityId != null) {
            Id contactId = handleContact(federationIdentifier, communityId);
            handleUser(usr, contactId, federationIdentifier);
        }
    }
	
    @TestVisible
    private Id handleContact(String federationIdentifier, Id communityId) {        
        //Query Acquisition contact using federation id
        Boolean AcqContactFLSRead = PF_AccessibilityUtils.checkFLS(ACQ_CONTACT_SOBJ_API, PF_AccessibilityUtils.PermissionType.ACCESSIBLE, ACQ_CONTACT_FIELDS);           
        Contact contact;

        if(!AcqContactFLSRead){
            throw new JITException(ACQ_CONTACTS_ACCESS_EXCEPTION);
        }

        List<Acquisition_Contacts__c> acquisitionContacts = MA_CommunitySSOJITHandlerUtil.getAcquisitionContacts(federationIdentifier);

        if(acquisitionContacts.size() == 0) {
            throw new JitException(ACQ_CONTACTS_NA_EXCEPTION);
        }else if(acquisitionContacts.size() > 1) {
            throw new JitException(EXCESS_ACQ_CONTACTS_EXCEPTION);
        }else if (acquisitionContacts[0].Contact_Status__c  == CONTACT_STATUS_CANCELLED || acquisitionContacts[0].Remove_Community_Access__c) {
            throw new JITException(COMMUNITY_ACCESS_EXCEPTION);
        }else {
            Acquisition_Contacts__c acquisitionContact = acquisitionContacts[0];
            List<Account> accounts = [SELECT Id, Name FROM Account WHERE Acquisition_Companies__c = :acquisitionContact.Acquisition_Company__c];

            if(accounts.size() == 0) {
                throw new JITException(ACCOUNT_NA_EXCEPTION);
            }

            contact = MA_CommunitySSOJITHandlerUtil.getContact(acquisitionContact, accounts[0], communityId);
            MA_CommunitySSOJITHandlerUtil.publishAutoEnrolmentEvents(acquisitionContacts);
        }

        insert(contact);
        return contact.Id;
    }

    @TestVisible
    private void handleUser(User usr, Id contactId, String federationIdentifier) {
        Boolean ContactFLSRead = PF_AccessibilityUtils.checkFLS(CONTACT_SOBJ_API, PF_AccessibilityUtils.PermissionType.ACCESSIBLE, CONTACT_FIELDS);
        Boolean AccountFLSRead = PF_AccessibilityUtils.checkFLS(ACCOUNT_SOBJ_API, PF_AccessibilityUtils.PermissionType.ACCESSIBLE, ACCOUNT_FIELDS);
        
        if(!ContactFLSRead){
            throw new JITException(ACQ_CONTACTS_ACCESS_EXCEPTION);
        }
        
        if(!AccountFLSRead){
            throw new JITException(ACCOUNT_ACCESS_EXCEPTION);
        }

        Contact contact = [SELECT Id, FirstName, Lastname, Email, Account.Name, Acquisition_Contacts__r.Time_Zone__c FROM Contact WHERE Id = :contactId];
        List<MA_Community_SSO_Config__mdt> ssoConfigList = [SELECT ProfileId__c FROM MA_Community_SSO_Config__mdt WHERE MA_Company_Name__c = :contact.Account.Name];

        if(ssoConfigList.isEmpty()) {
            throw new JITException(SSO_CONFIG_NA_EXCEPTION + contact.Account.Name);
        }

        MA_CommunitySSOJITHandlerUtil.populateUser(usr, contact, federationIdentifier, ssoConfigList[0]);
        system.debug('usr###'+usr);
    }

}