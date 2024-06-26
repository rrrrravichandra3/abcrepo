public with sharing class NHW_Community_PreferencesService {

    public static Id getCandidateContactfromUserId(Id userId) {
        User u = [select id,contactId from User where id =: userId];
        return u.contactId;
    }
    
    
}