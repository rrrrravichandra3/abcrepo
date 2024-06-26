/**
 * 
 * Version    Date            Author                  Description
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0       11/29/2023      Ashutosh Belwal        This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
 * ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
global class PB_CommunitySSOJitHandler implements Auth.SamlJitHandler {
    
    private class JitException extends Exception {}
    
    private static final String NO_CONTACT_ERROR = Label.PB_NO_CONTACT_ERROR;
    private static final String MULTIPLE_CONTACT_ERROR = Label.PB_Multiple_Contacts_Error;
    private static final String SSO_SETTING_ERROR = Label.PB_SSO_SETTING_ERROR;
    private static final String PROFILE_ERROR = Label.PB_PROFILE_ERROR;
    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        String employeeId = attributes.get('UserName');
        User usr = new User();
        handleJIT(usr, communityId, federationIdentifier, employeeId);
        system.debug('@@@@'+usr);
        return usr;
        
    }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        // logic to update user here
    }
    
    private void handleJIT(User usr, Id communityId, String federationIdentifier, String employeeId) {
        //federationIdentifier = employeeId;// need to remove after sf11 implementation
        if(communityId != null) {
            Contact objContact = handleContact( federationIdentifier );
            PB_SSO_Config__mdt ssoSetting =  PB_CommunitySSOJitHandlerUtil.getSsoSetting();
            
            if(ssoSetting == null){
                throw new JitException( SSO_SETTING_ERROR );
            }
            
            Profile objProfile = PB_CommunitySSOJitHandlerUtil.getProfile( ssoSetting.Community_Profile_Name__c );
            
            if(objProfile == null){
                throw new JitException( PROFILE_ERROR );
            }
            
            PB_CommunitySSOJitHandlerUtil.populateUser(usr, objContact, federationIdentifier, objProfile.Id, ssoSetting);
        }
        
    }
    
    private Contact handleContact(String federationIdentifier) { 
        
        Contact contact;
        List<Contact> lstContacts = PB_CommunitySSOJitHandlerUtil.getContact( federationIdentifier );
        
        if(lstContacts.size() == 0) {
            throw new JitException( NO_CONTACT_ERROR );
        }else if(lstContacts.size() > 1) {
            throw new JitException( MULTIPLE_CONTACT_ERROR );
        }else {
            contact = lstContacts[0];
        }
        
        
        return contact;
    }
    
}