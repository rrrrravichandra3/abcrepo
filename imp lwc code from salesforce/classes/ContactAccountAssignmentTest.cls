@isTest
public class ContactAccountAssignmentTest {

    //Static Variables
    public static Id idEmployeeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId();
    public static Id idEmployeeContactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId();
    public static String strAccountPrefix = 'salesforce.com';
    
    @testSetup
    static void setup() {
        
        Contact_Account_Assignment__c settings = new Contact_Account_Assignment__c(Contact_Employee_Id_Field_Name__c='Employee_ID__c',Account_Prefix__c = 'salesforce.com',Ignore_Employee_Ids__c = 'TBD',Account_Record_Type__c = 'Employee',Contact_Record_Types_to_Process__c = 'Employee');
        insert settings;
    }
    
    static void insertBulkContacts() {
        Contact_Account_Assignment__c settings =  Contact_Account_Assignment__c.getOrgDefaults();
        List<Contact> bulkContacts = new List<Contact>();
        for(Integer i = 0 ; i < 200 ; i++) {
            Contact c = new Contact(LastName='Tester'+i,Status__c = 'Active',recordtypeid = idEmployeeContactRecordType);
            if(i < 50) {
               c.put(settings.Contact_Employee_Id_Field_Name__c,'TBD');
            } else {
               c.put(settings.Contact_Employee_Id_Field_Name__c,String.valueOf(Math.floor(Math.random() * 1000000).intValue()));
            }
            bulkContacts.add(c);
        }
        insert bulkContacts;
    }
    
    /*
    *     @author         ronak bandwal
    *     @date           18 Aug 2023
    *     @description    Test Method to validate Bulk Contact AccountId assignment with Accounts Creation
    */
    @isTest
    public static void testBulkContactAccountAssignment() {
        Integer intEmpId = 0;
        Integer intAccountKey = 0;
        Contact_Account_Assignment__c settings =  Contact_Account_Assignment__c.getOrgDefaults();
        ContactAccountAssignmentHelper.strExecute = 'N';
        ContactAccountAssignmentHelper.createAccounts = false;
        ContactAccountAssignmentHelper.intDivFactor = 1000;

        // Load the test contacts 
        insertBulkContacts();
        //Query for the records and assert if the account has been assigned correctly
        String query = 'Select Id,AccountId,'+settings.Contact_Employee_Id_Field_Name__c+' from Contact';
        List<Contact> lstContacts = Database.query(query);
        //Validate that Accounts have not been assigned as strCreateAccounts was false
        for(Contact objContact : lstContacts) {
            system.assertEquals(objContact.AccountId, null,'Incorrect Account Assignment');
        }
        //Now individually call ContactAssignmentHelper
        ContactAccountAssignmentHelper.strExecute = 'Y';
        ContactAccountAssignmentHelper.createAccounts = true;
        lstContacts = ContactAccountAssignmentHelper.assignAccountToContact(lstContacts);
        update lstContacts;
        //requery
        query = 'Select Id,AccountId,Account.Name,'+settings.Contact_Employee_Id_Field_Name__c+' from Contact';
        lstContacts = Database.query(query);
        //Loop through the TBD Contacts and validate if their Accounts have been assigned correctly
        for(Contact objContact :  lstContacts) {
            if(objContact.get(settings.Contact_Employee_Id_Field_Name__c) == 'TBD') {
                system.assertEquals(String.isBlank(objContact.AccountId), true, 'Incorrect Account Assignment'); 
            }
            else {
                intEmpId = Integer.valueOf(objContact.get(settings.Contact_Employee_Id_Field_Name__c));
                intAccountKey = intEmpId - math.mod(intEmpId, ContactAccountAssignmentHelper.intDivFactor);
                system.assertEquals(objContact.Account.Name == strAccountPrefix + ' ' +intAccountKey, true, 'Incorrect Account Assignment');
            }
        }  
    }

    /*
    *     @author         ronak bandwal
    *     @date           18 Aug 2023
    *     @description    Test Method to validate single Contact AccountId assignment with Accounts already existing        
    *     @param          
    *     @return         
    */
    @isTest
    public static void testContactAccountAssignmentSingleWithAccountsExisting() {
        //Create an Account
        Account objAccount = new Account(Name = strAccountPrefix +' '+'100000', RecordTypeId = idEmployeeAccountRecordType);
        insert objAccount;
		Contact_Account_Assignment__c settings =  Contact_Account_Assignment__c.getOrgDefaults();
        ContactAccountAssignmentHelper.createAccounts = true;
        ContactAccountAssignmentHelper.intDivFactor = 100;

        //Create Contacts
        List<Contact> lstContacts = new List<Contact>();
        Contact c1 = new Contact(LastName = 'Test', Status__c = 'Active',recordtypeid = idEmployeeContactRecordType);
        c1.put(settings.Contact_Employee_Id_Field_Name__c,'TBD');
        lstContacts.add(c1);
        Contact c2 = new Contact(LastName = 'Testing', Status__c = 'Active',recordtypeid = idEmployeeContactRecordType);
        c2.put(settings.Contact_Employee_Id_Field_Name__c,'100001');
        lstContacts.add(c2);

        insert lstContacts;

        //update the employee id of the first contact
        lstContacts[0].put(settings.Contact_Employee_Id_Field_Name__c,'100096');
        update lstContacts[0];

        //Query for the records and assert if the account has been assigned correctly
        String query = 'Select Id,AccountId,Account.Name,'+settings.Contact_Employee_Id_Field_Name__c+' from Contact';
        List<Contact>  lstTobeCheckedContacts = Database.query(query);

        for(Contact objContact : lstTobeCheckedContacts) {
            system.assertEquals(objContact.Account.Name, strAccountPrefix +' '+'100000','Incorrect Account Assignment');     
        }


    }

    /*
    *     @author         ronak bandwal
    *     @date           18 Aug 2023
    *     @description    Test Method to validate Bulk Contact AccountId assignment with update
    */
    @isTest
    public static void testContactAccountAssignmentBulkUpdate() {
        Integer intEmpId = 0;
        Integer intAccountKey = 0;
        Contact_Account_Assignment__c settings =  Contact_Account_Assignment__c.getOrgDefaults();
        ContactAccountAssignmentHelper.createAccounts = true;
        ContactAccountAssignmentHelper.intDivFactor = 100;
        // Load the test contacts
        insertBulkContacts();
        
        //Query for the records and assert if the account has been assigned correctly
        String query = 'Select Id,AccountId,Account.Name,'+settings.Contact_Employee_Id_Field_Name__c+' from Contact';
        List<Contact> lstContacts = Database.query(query);
        // Verify that all data has been created
        System.assertEquals(lstContacts.size() > 0, true, 'Contacts not created successfully');
        for(Contact objContact :  lstContacts) {
            if(objContact.get(settings.Contact_Employee_Id_Field_Name__c) == 'TBD') {
                system.assertEquals(String.isBlank(objContact.AccountId), true, 'Incorrect Account Assignment when Employee Id is TBD'); 
            }
            else {
                intEmpId = Integer.valueOf(objContact.get(settings.Contact_Employee_Id_Field_Name__c));
                intAccountKey = intEmpId - math.mod(intEmpId, ContactAccountAssignmentHelper.intDivFactor);
                system.assertEquals(objContact.Account.Name == strAccountPrefix + ' '+intAccountKey, true, 'Incorrect Account Assignment');
            }                          
        }
        //Now lets update the Employee Id from TBD to a value and see if the Accounts get updated
        //Query for TBD Contacts
        query = 'Select Id,AccountId,Account.Name,'+settings.Contact_Employee_Id_Field_Name__c+' from Contact where ' +settings.Contact_Employee_Id_Field_Name__c+ '= \'TBD\'';
        List<Contact> lstTBDContacts = Database.query(query);
        Set<Id> setTBDContactIds = new Set<Id>();
        Integer intStartNum = 100000;
        for(Contact objContact :  lstTBDContacts) {
            if(objContact.get(settings.Contact_Employee_Id_Field_Name__c) == 'TBD') {
                objContact.put(settings.Contact_Employee_Id_Field_Name__c,String.valueOf(intStartNum));
                intStartNum = intStartNum + 41;
                setTBDContactIds.add(objContact.Id);
            }    
        }
        update lstTBDContacts;
        
        //Requery for the Contacts 
        query = 'Select Id, AccountId, Account.Name,'+settings.Contact_Employee_Id_Field_Name__c+ ' from Contact where Id IN :setTBDContactIds';
        lstTBDContacts = Database.query(query);
        
        //Loop through the TBD Contacts and validate if their Accounts have been assigned correctly
        for(Contact objContact :  lstTBDContacts) {
             intEmpId = Integer.valueOf(objContact.get(settings.Contact_Employee_Id_Field_Name__c));
             intAccountKey = intEmpId - math.mod(intEmpId, ContactAccountAssignmentHelper.intDivFactor);
             system.assertEquals(objContact.Account.Name == strAccountPrefix + ' '+intAccountKey, true, 'Incorrect Account Assignment');
        }   
    }
    
    /*
    *     @author         ronak bandwal
    *     @date           2 Nov 2023
    *     @description    Test Method to validate Batch job to clean up existing contacts
    */
    @isTest
    public static void testBatchJobContactAccountAssignment() {
        Integer intEmpId = 0;
        Integer intAccountKey = 0;
        Contact_Account_Assignment__c settings =  Contact_Account_Assignment__c.getOrgDefaults();
        ContactAccountAssignmentHelper.strExecute = 'N';
        ContactAccountAssignmentHelper.createAccounts = false;
        ContactAccountAssignmentHelper.intDivFactor = 1000;

        // Load the test contacts
        insertBulkContacts();
        //Query for the records and assert if the account has been assigned correctly
        String query = 'Select Id,AccountId,'+settings.Contact_Employee_Id_Field_Name__c+' from Contact';
        List<Contact> lstContacts = Database.query(query);
        //Validate that Accounts have not been assigned as strCreateAccounts was false
        for(Contact objContact : lstContacts) {
            system.assertEquals(objContact.AccountId, null,'Incorrect Account Assignment');
        }
        
        
         //Now individually call ContactAssignmentHelper
        ContactAccountAssignmentHelper.strExecute = 'Y';
        ContactAccountAssignmentHelper.createAccounts = true;
        
          Test.startTest();
            ContactAccountAssignmentHandlerBatch obj = new ContactAccountAssignmentHandlerBatch();
            DataBase.executeBatch(obj); 
        Test.stopTest();
        
		query = 'Select Id,AccountId,Account.Name,'+settings.Contact_Employee_Id_Field_Name__c+' from Contact';
        lstContacts = Database.query(query);        
        //loop through contacts and validate account assignment via batch
        for(Contact objContact :  lstContacts) {
            if(objContact.get(settings.Contact_Employee_Id_Field_Name__c) == 'TBD') {
                system.assertEquals(String.isBlank(objContact.AccountId), true, 'Incorrect Account Assignment'); 
            }
            else {
                intEmpId = Integer.valueOf(objContact.get(settings.Contact_Employee_Id_Field_Name__c));
                intAccountKey = intEmpId - math.mod(intEmpId, ContactAccountAssignmentHelper.intDivFactor);
                system.assertEquals(objContact.Account.Name == strAccountPrefix + ' ' +intAccountKey, true, 'Incorrect Account Assignment');
            }
        }         
    }
}