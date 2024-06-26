public without sharing class PB_CommSignInService {
    
    @AuraEnabled
    public static user createUser(String inputUserEmail, Contact userContact) {
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
            WHERE name = 'Insiders App Candidate'
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
* User user  = NHW_Community_SignInService.getContacts('test@test.com');
*/
    public static List<Contact> getContacts(string inputUserEmail) {
        String userEmail = String.escapeSingleQuotes(inputUserEmail);
        List<Contact> contactsWithEmail = new List<Contact>();
        contactsWithEmail = [
            SELECT Id, firstname, lastname, email
            FROM contact
            WHERE email = :String.escapeSingleQuotes(userEmail)
            AND recordtype.name = 'WDR Candidate'
            ORDER BY lastmodifieddate
            DESC
        ];
        
        return contactsWithEmail;
    }
    
    public static List<Contact> getEligibleContacts(List<Contact> contacts) {
        if (contacts.size() > 0) {
            List<Contact> eligibleContactsWithEmail = additionalLoginAccessChecks(contacts);
            return eligibleContactsWithEmail;
        }
        return contacts;
    }
    
    public static List<Contact> additionalLoginAccessChecks(List<Contact> contacts) {
        List<Contact> eligibleContacts = new List<Contact>();
        List<WDR_Application__c> currentAplication = additionalApplicationStageCheck(contacts[0].Email);
       
        if(currentAplication.size()>0) {
            eligibleContacts.add(contacts[0]);
        }
        
        return eligibleContacts;
    }
    
    public static List<WDR_Application__c> additionalApplicationStageCheck(String associatedUserEmail) {
        List<WDR_Application__c> currentAplication = [Select Candidate_Stage__c from WDR_Application__c where 
                                                      Internal_Candidate__c = False 
                                                      AND Candidate_Email__c =:associatedUserEmail
                                                      AND Candidate_Stage__c = 'Placement' AND Start_Date__c > TODAY ORDER BY lastmodifieddate DESC];
        return currentAplication;
    }
    
/*******************************************************************************************************
* @description Queries User object with the email provided by the user
* @param userEmail : the email input from the user to login
* @return List of Users
*/
    public static List<User> getUser(String inputUserEmail) {
        String userEmail = String.escapeSingleQuotes(inputUserEmail);
        return [
            SELECT Id, Email, firstname, lastname
            FROM User
            WHERE email = :String.escapeSingleQuotes(userEmail) AND Profile.name = 'Insiders App Candidate'
        ];
    }
    
}