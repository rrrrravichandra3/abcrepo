public with sharing class ESDJC_ContactHandler {
    
    public static void updateStatusIfPortalUserIsNotFound(Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        List<Id> contactIds = new List<Id>();
        
        Id employeeRTId = ESDJC_Util.getEmployeeRecordTypeId();
        
        for (Contact c : newMap.values()) {
            if (c.RecordTypeId == employeeRTId && c.ES_DJC_Record_Status__c == 'Updated')
                contactIds.add(c.Id);
        }
        
        Set<Id> contactsWithPortalUsers = new Set<Id>();
        
        if (!contactIds.isEmpty()) {
            //Check if portal user exists for the contacts
            for (User u : [select ContactId from User where ContactId IN :contactIds]) {
                contactsWithPortalUsers.add(u.ContactId);
            }
        }
        
        //Iterate through contacts and update record status if portal user does
        //not exist for the contact
        for (Id contactId : contactIds) {
            //if (!contactsWithPortalUsers.contains(contactId) && newMap.get(contactId) != null)
                //newMap.get(contactId).ES_DJC_Record_Status__c = 'New';
        }
    }

}