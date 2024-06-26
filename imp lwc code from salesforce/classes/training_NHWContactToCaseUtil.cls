public with sharing class training_NHWContactToCaseUtil {
    // Contact object is customized to represent Candidate who  applied for a Job.Case object  is customized to represent preboarding and provisioning work  related to the new hire.
    // When a candidate accepts job offer and is hired , preboarding and provisioning cases are created with status as new.
    // When candidate rejects a job offer or is dispositioned , contact status is changed and status on all related cases should be closed cancelled.
    // I want to create a apex class to manage new hire cases based on candidate stage custom field on contact.
    // It should track field change on contact and update case status on related cases.
    // It should have an entry method which will invoke the below three helper methods in the same order.
    // Method 1 to return the list of contacts with  change on given field.
    // Method 2 to retrieve all the  cases related to contact. It should return a map of contact to list of cases.
    // Method 3 to update the cases for a given contact.
    //It should be bulkified.
    //Notes for tomorrow
    //Pivot to CWCaseCreation.

    private static list<contact> getContactsWithChangesOnGivenField(List<Contact> newContacts, List<Contact> oldContacts,string fieldName){
        map<Id,Contact> mNewContacts = new map<Id,Contact>(newContacts);
        map<Id,Contact> mOldContacts = new map<Id,Contact>(oldContacts);
        List<Contact> contactsWithChanges = new List<Contact>();

        for(Contact con : newContacts){
            if(  mOldContacts.containsKey(con.Id) 
                && mOldContacts.get(con.Id).get(FieldName) != Null
                && mNewContacts.get(con.Id).get(FieldName) != Null
                && mNewContacts.get(con.Id).get(FieldName) != mOldContacts.get(con.Id).get(FieldName) 
              ){
                    contactsWithChanges.add(con);
                }

        }
        return contactsWithChanges;
        
	}
    private static map<Id,List<Case>> getCasesRelatedToContact(List<Contact> contacts , string relatedLookupFieldName){
        Map<id,Contact> mContacts = new map<Id,Contact>(contacts);
        Map<id,List<Case>> mContactToCases = new map<Id,List<Case>>();

        String query = 'SELECT Id, status '+ relatedLookupFieldName + ' FROM Case WHERE ' +relatedLookupFieldName + ' in ' + mContacts.keyset();
        List<Case> relatedCases = Database.query(query);

        for(Case c: relatedCases){
            String ContactId = (String)c.get(relatedLookupFieldName);
            if(mContactToCases.containsKey(ContactId)) {
                mContactToCases.get(ContactId).add(c);
            }else{
                mContactToCases.put(ContactId,new List<Case>{c});
            }
            
        }
        return mContactToCases;
    }

    private static void updateCasesWithGivenStatus(List<Case> cases,String Status){
        for(Case c:cases){
            c.status = status;
        }
        update cases;

    }

}