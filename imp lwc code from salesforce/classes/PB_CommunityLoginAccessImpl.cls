public without sharing class PB_CommunityLoginAccessImpl implements R2H_LoginAccessInterface {

    public List<Contact> additionalLoginAccessChecks(List<Contact> contacts) {
        
        List<Contact> eligibleContacts = new List<Contact>();

        if(contacts.size()>0) {
            Set<Id> contactIds = new Set<Id>();
            for(Contact c:contacts) {
                contactIds.add(c.id);
            }
            
            List<WDR_Application__c> currentAplications = [Select Candidate_Stage__c,Candidate__r.Candidate_Contact__c from WDR_Application__c where 
                                                          Do_Not_Send_NHW__c = False  //filter internal candidate or conversions
                                                          AND Candidate__r.Candidate_Contact__c IN :contactIds
                                                          AND Candidate_Stage__c = 'Placement' AND (Start_Date__c >= :Date.today().addDays(-3)) AND (Start_Date__c  <= :Date.today().addDays(30)) ORDER BY lastmodifieddate DESC];
            
            if(currentAplications.size()>0) {
                eligibleContacts.add(new Contact(Id=currentAplications[0].Candidate__r.Candidate_Contact__c));
            }
        }
        
        return eligibleContacts;
    }
    
}