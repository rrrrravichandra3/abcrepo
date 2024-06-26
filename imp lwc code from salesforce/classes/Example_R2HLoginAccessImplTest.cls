@istest
public class Example_R2HLoginAccessImplTest {
    
    @testSetup
    static void setup() {
        Contact c = new Contact(LastName = 'test',email = 'test@email.com');
        insert c;
        Contact c2 = new Contact(LastName = 'tst', email = 'tst@email.com');
        insert c2;
    }

    @istest
    static void eligible() {
        Test.startTest();
        List<Contact> contacts = [select id,name from contact];
        Type t = Type.forName('Example_R2HLoginAccessImpl');
        R2H_LoginAccessInterface loginImplClass = (R2H_LoginAccessInterface) t.newInstance();
        List<Contact> eligibleConts = loginImplClass.additionalLoginAccessChecks(contacts);
        Test.stopTest();
        System.assertEquals(1,eligibleConts.size(),'one eligible contact');
        System.assertEquals('test',eligibleConts[0].name,'eligible contact name');
    }
}