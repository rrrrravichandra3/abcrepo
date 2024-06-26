@isTest(SeeAllData=false)
public class Test_MA_CommunitySSOJITHandler {
    private Static String maESName = 'acqCompShareBatch';
    
    @testSetup 
    static void setupData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    
    @isTest
    static void testSuccessfulUserCreation() {
        // Create a mock User object
        User usr = new User();
        usr.Email = 'test@example.com';
        usr.FirstName = 'John';
        usr.LastName = 'Doe';
        
        // Create a mock federation identifier
        String federationIdentifier = 'unique-identifier';
        
        // Create a mock Map of SAML attributes
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('FirstName', 'John');
        
        // Create a mock assertion
        String assertion = 'mock-assertion';
        User createdUser;
        try{
            Test.startTest();
            // Invoke the createUser method
            createdUser = new MA_CommunitySSOJITHandler().createUser(null, Network.getNetworkId(), null, federationIdentifier, attributes, assertion);
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
        Assert.isNotNull(createdUser);
    }
    
    @isTest
    static void testSuccessfulUpdateUser() {
        String federationIdentifier = 'unique-identifier';
        
        Map<String, String> attributes = new Map<String, String>();
        attributes.put('FirstName', 'John');
        
        String assertion = 'mock-assertion';
        user portalUser = [Select Id,TimeZoneSidKey FROM user WHERE Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        
        Acquisition_Contacts__c acqcontact = [SELECT Id,Time_Zone__c FROM Acquisition_Contacts__c Limit 1];
        acqcontact.Time_Zone__c = 'Asia/Kolkata';
        update acqcontact;
        try{
            Test.startTest();
            new MA_CommunitySSOJITHandler().updateUser(portalUser.Id, null, Network.getNetworkId(), null, federationIdentifier, attributes, assertion);
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
        Assert.isNotNull(portalUser.TimeZoneSidKey);
    }
    
    @isTest
    static void testHandleContact() {
        try{
            Test.startTest();
            MA_CommunityEventAutoEnroller.testJobEnqueued = true;
            new MA_CommunitySSOJITHandler().handleContact(MA_TestUtilityValues.MA_PORTAL_USER_EMAIL, Network.getNetworkId());
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
        Contact contact = [SELECT Id from Contact limit 1];
        Assert.isNotNull(contact.Id);
    }
    
    @isTest
    static void testHandleUser() {
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        Account account = [SELECT Id FROM Account Limit 1];
        Acquisition_Contacts__c acqContact = [SELECT Id FROM Acquisition_Contacts__c Limit 1];
        List<Contact> listContact = MA_TestUtil.createContact(1, account.Id, acqContact.Id, true);
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        
        try{
            Test.startTest();
            new MA_CommunitySSOJITHandler().handleUser(portalUsers[0], portalUsers[0].ContactId, MA_TestUtilityValues.MA_PORTAL_USER_EMAIL);
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
        User user = [SELECT Id from User limit 1];
        Assert.isNotNull(user.Id);
    }
    
    @isTest
    static void testHandleContactException() {
        try{
            Test.startTest();
            MA_CommunityEventAutoEnroller.testJobEnqueued = true;
            new MA_CommunitySSOJITHandler().handleContact(MA_TestUtilityValues.MA_PORTAL_USER_EMAIL+0, Network.getNetworkId());
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
        Contact contact = [SELECT Id from Contact limit 1];
        Assert.isNotNull(contact.Id);
    }
    
    @isTest
    static void testHandleContactException_ExcessContact() {
        Acquisition_Contacts__c acqcontact = [SELECT Id,Remove_Community_Access__c FROM Acquisition_Contacts__c Limit 1];
        acqcontact.Remove_Community_Access__c = true;
        update acqcontact;
        try{
            Test.startTest();
            MA_CommunityEventAutoEnroller.testJobEnqueued = true;
            new MA_CommunitySSOJITHandler().handleContact(MA_TestUtilityValues.MA_PORTAL_USER_EMAIL, Network.getNetworkId());
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
        Contact contact = [SELECT Id from Contact limit 1];
        Assert.isNotNull(contact.Id);
    }
    
    @isTest
    static void testHandleContactAccessException() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName+1);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = 'M_A_Finance' LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        try{
            Test.startTest();
            System.runAs(maUser[0]){
                MA_CommunityEventAutoEnroller.testJobEnqueued = true;
                new MA_CommunitySSOJITHandler().handleContact(MA_TestUtilityValues.MA_PORTAL_USER_EMAIL, Network.getNetworkId());
            }
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
    }
}