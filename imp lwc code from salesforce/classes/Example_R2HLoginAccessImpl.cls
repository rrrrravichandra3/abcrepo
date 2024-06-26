public class Example_R2HLoginAccessImpl implements R2H_LoginAccessInterface {
    
    public List<Contact> additionalLoginAccessChecks(List<Contact> contacts) {
       List<Contact> eligibleContacts = new List<Contact>();
        for(Contact c:contacts) {
            if(c.name.contains('test')) {
                eligibleContacts.add(c);
                return eligibleContacts;
            }
        }
        
        return eligibleContacts;
    }

}