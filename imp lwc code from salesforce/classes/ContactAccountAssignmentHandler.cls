public with sharing class ContactAccountAssignmentHandler {
    
    
    public static List<SObject> filterRecords(list<Contact> newList, list<Contact> oldList, map<Id, Contact> oldMap) {
        List<Contact> filterList = new List<Contact>();
        
        if(ContactAccountAssignmentHelper.empIDFieldName == null) {
            return filterList;
        }
        
        List<Contact> lstNewContacts = newList;
        Map<Id, Contact> mapOfOldContacts =oldMap;
        List<Contact> filteredList = ContactAccountAssignmentHelper.filterbyRecordType(lstNewContacts);
        for(Contact objContact : filteredList) {
            if(objContact.Status__c == 'Active' && String.isNotBlank((String)objContact.get(ContactAccountAssignmentHelper.empIDFieldName))) {//Only execute if the Contact is Active and has an Employee Id
                if(Trigger.isInsert) {
                    filterList.add(objContact);    
                }
                else {
                    /*For Before Update Context, execute in the following scenarios
                    *Employee Id is changed
                    *Contact is changed from Inactive to Active
                    */ 
                    filterUpdateRecords(objContact,filterList,mapOfOldContacts);
                }
            }    
        } 
        return filterList;    
    }
    
    public static void filterUpdateRecords(Contact objContact,List<Contact> filterList,Map<Id, Contact> mapOfOldContacts) {
        Contact objOldContact = mapOfOldContacts.get(objContact.Id);
        if(objOldContact != null && (objContact.get(ContactAccountAssignmentHelper.empIDFieldName)  != objOldContact.get(ContactAccountAssignmentHelper.empIDFieldName)  || 
                                     (objContact.Status__c == 'Active' && objOldContact.Status__c != 'Active'))) {
                                         filterList.add(objContact);
                                     }
    }
    

    
    
    public static void beforeUpdate(list<Contact> newList, list<Contact> oldList, map<Id, Contact> oldMap) {
        ContactAccountAssignmentHelper.assignAccountToContact((List<Contact>)filterRecords(newList,oldList,oldMap));
    }
    
    public static void beforeInsert(list<Contact> newList) {
        ContactAccountAssignmentHelper.assignAccountToContact((List<Contact>)filterRecords(newList,null,null));
        
    }
    
}