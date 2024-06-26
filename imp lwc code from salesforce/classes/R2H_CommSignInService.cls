/* @Author Ronak Bandwal 
 * @Description Service Class for Community Login to
 * check eligibility and create users
*/
public without sharing class R2H_CommSignInService {
    
    R2H_Community_Config__mdt communityMDT;
    
    public R2H_CommSignInService(string communityName) {
        communityMDT = [select Community_Name__c , Contact_RecordType__c , LoginAccessImpl_ClassName__c , User_Profile__c from R2H_Community_Config__mdt where Community_Name__c =:communityName];
    }
    
    
    /*******************************************************************************************************
    * @description Create user associated with a candidate contact
    * @param inputUserEmail : the email input from the user to login
    * @param userContact : the candidate contact
    * @return User object
    */
    public user createUser(String inputUserEmail, Contact c) {
        Contact userContact = [select Id,FirstName,LastName,Email from Contact where Id =: c.id];
        String userEmail = String.escapeSingleQuotes(inputUserEmail);
        user newuser = new User();
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        if(!String.isblank(d.getSandboxName())) { //Sandbox
            newuser.Username = userEmail+'.'+d.getSandboxName();
        } else { //PROD
            newuser.Username = userEmail;
        }
        if (userContact.firstName != null) {
            newuser.FirstName = userContact.firstName;
        }
        newuser.LastName = userContact.lastname;
        newuser.Email = userEmail;
        newuser.alias = userContact.firstname.substring(0, 2) + userContact.lastname.substring(0, 2);
        newuser.communitynickname = userContact.firstname.substring(0, 2) + userContact.lastname.substring(0, 2) + String.valueOf(Datetime.now().format('MM-dd HH:mm'));
        newuser.TimeZoneSidKey = 'America/Los_Angeles';
        newuser.LocaleSidKey = 'en_US';
        newuser.EmailEncodingKey = 'ISO-8859-1';
        Id candidateProfileId = [
            SELECT id
            FROM Profile
            WHERE name = :communityMDT.User_Profile__c
        ].Id;
        
        newuser.ProfileId = candidateProfileId;
        newuser.LanguageLocaleKey = 'en_US';
        newuser.ContactID = userContact.id;
        return newUser;
    }
    
    /*******************************************************************************************************
        * @description Queries Contact object with the email provided by the user
        * @param userEmail : the email input from the user to login
        * @return List of Contacts
        * @example
        * User user  = R2H_CommSignInService.getContacts('test@test.com');
    */
    public List<Contact> getContacts(string inputUserEmail) {
        String userEmail = String.escapeSingleQuotes(inputUserEmail);
        List<Contact> contactsWithEmail = new List<Contact>();
        contactsWithEmail = [
            SELECT Id, firstname, lastname, email , name
            FROM contact
            WHERE email = :String.escapeSingleQuotes(userEmail)
            AND recordtype.name = :communityMDT.Contact_RecordType__c
            ORDER BY lastmodifieddate
            DESC
        ];     
        return contactsWithEmail;
    }
    
    
    public List<Contact> getEligibleContacts(List<Contact> contacts) {
        if (contacts.size() > 0) {
            Type t = Type.forName(communityMDT.LoginAccessImpl_ClassName__c);
            R2H_LoginAccessInterface loginImplClass = (R2H_LoginAccessInterface) t.newInstance();
            List<Contact> eligibleContactsWithEmail = loginImplClass.additionalLoginAccessChecks(contacts);
            return eligibleContactsWithEmail;
        }
        return contacts;
    }
    
    /*******************************************************************************************************
    * @description Queries User object with the email provided by the user
    * @param userEmail : the email input from the user to login
    * @return List of Users
    */
    public List<User> getUser(String inputUserEmail) {
        String userEmail = String.escapeSingleQuotes(inputUserEmail);
        return [
            SELECT Id, Email, firstname, lastname
            FROM User
            WHERE email = :String.escapeSingleQuotes(userEmail) AND Profile.name = :communityMDT.User_Profile__c
        ];
    }
}