@isTest
public class talentMP_TestUtil {
    public static List<User> createSystemAdminUser(Integer numberOfRecords,String profileId,String dummyRoleId, String testName, Boolean doInsert){
        List<User> sysAdminList = new List<User>();
        for(Integer i = 0; i < numberOfRecords; i++){
            User objUser = new User();
        	objUser.ProfileId = profileId;
            objUser.UserRoleId = dummyRoleId;
        	objUser.Username = testName + 'talentMP_sysadmin'+String.valueOf(i) + talentMP_TestUtilValues.EMAILSUFFIX_TESTUSER;
        	objUser.Alias = 'tmp'+String.valueOf(i);
        	objUser.Email= testName + 'talentMP'+String.valueOf(i) + talentMP_TestUtilValues.EMAILSUFFIX_TESTUSER;
        	objUser.EmailEncodingKey='UTF-8';
        	objUser.Firstname= testName + 'talentMP_Admin_'+String.valueOf(i);
        	objUser.Lastname= testName + 'talentMP_User_'+String.valueOf(i);
        	objUser.LanguageLocaleKey='en_US';
        	objUser.LocaleSidKey='en_US';
        	objUser.TimeZoneSidKey='America/Chicago';
            sysAdminList.add(objUser);
        }
        if(doInsert){
            insert sysAdminList;
        }
        return sysAdminList;
    }
    public static List<User> createPortalUser(Integer numberOfRecords, String profileId, String dummyRoleId, String contactId, String employeeNo, String testName, Boolean doInsert){
        List<User> portalUserList = new List<User>();
        for(Integer i = 0; i < numberOfRecords; i++){
            User objUser = new User();
        	objUser.ProfileId = profileId;
            objUser.UserRoleId = dummyRoleId;
            objUser.ContactId = contactId;
        	objUser.Username = testName + 'portal'+String.valueOf(i)+'@community.com.talentMP';
        	objUser.Alias = 'TMP'+String.valueOf(i);
        	objUser.Email= 'talentMP_'+String.valueOf(i) + talentMP_TestUtilValues.EMAILSUFFIX_PORTALUSER;
            objUser.FederationIdentifier = 'test_'+String.valueOf(i) + talentMP_TestUtilValues.EMAILSUFFIX_PORTALUSER;
        	objUser.EmailEncodingKey='UTF-8';
        	objUser.Firstname= testName + 'talentMP_'+String.valueOf(i);
        	objUser.Lastname= testName +'talentMP_User_'+String.valueOf(i);
            objUser.CommunityNickname = 'test'+String.valueOf(i);
        	objUser.LanguageLocaleKey='en_US';
        	objUser.LocaleSidKey='en_US';
        	objUser.TimeZoneSidKey='America/Los_Angeles';
            objUser.IsActive = true;
            objUser.EmployeeNumber = employeeNo;
            portalUserList.add(objUser);
        }
        if(doInsert){
            insert portalUserList;
        }
        return portalUserList;
    }
    
    public static List<Account> createAccount(Integer numberOfRecords, Boolean doInsert ){
        List<Account> listAccount = new List<Account>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Account account = new Account();
           	account.Name = 'TalentNetwork';
            listAccount.add(account);
        }
        if(doInsert){
            insert listAccount;
        }
        return listAccount;
    }
    
    public static List<Contact> createContact(Integer numberOfRecords, String employeeNo, String accountId, Boolean doInsert ){
        List<Contact> listContact = new List<Contact>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Contact contact = new Contact();
           	contact.FirstName = 'Community';
            contact.Lastname = 'Contact';
            contact.AccountId = accountId;
            contact.EmployeeNumber__c = employeeNo;
            contact.Email = 'talentMP_'+String.valueOf(i) + talentMP_TestUtilValues.EMAILSUFFIX_PORTALUSER;
            listContact.add(contact);
        }
        if(doInsert){
            insert listContact;
        }
        return listContact;
    }
    public static PermissionSetAssignment createPermissionsetAssignment(String permissionSetId, String assigneeId, Boolean doInsert ){
        
        PermissionSetAssignment assignmentUser = new PermissionSetAssignment();
        assignmentUser.PermissionSetId = permissionSetId;
        assignmentUser.AssigneeId = assigneeId;
        
        if(doInsert){
            insert assignmentUser;
        }
        return assignmentUser;
    }
    public static UserRole getUserRoleByType(String roletype){
            return [Select Id From UserRole Where PortalType = :roletype Limit 1];
    }
    public static UserRole getUserRoleByName(String roleName){
            return [Select Id From UserRole Where Name = :roleName Limit 1];
    }
    
    public static profile getUserProfile(String profileName){
        return [Select Id from Profile where name = :profileName];
    }

}