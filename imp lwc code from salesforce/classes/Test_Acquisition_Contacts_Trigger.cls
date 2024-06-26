/**
* @description       : Test class for Acquisition_Contacts_Trigger_Handler
* @author            : Priyanka Kanani
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   17-10-2022   Priyanka Kanani   Initial Version
**/
@isTest(SeeAllData=false)
private class Test_Acquisition_Contacts_Trigger {
    private Static String maESName = 'acqContactTrigger';
    @testSetup 
    static void setupCompanyData() {
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, userProfile.Id, role.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        List<Acquisition_Company__c> listCompany = new List<Acquisition_Company__c> ();
        List<Acquisition_Contacts__c> listAcqContacts = new List<Acquisition_Contacts__c> ();
        List<Contact> listContact = new List<Contact>();
        
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        UserRole portalrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile portaluserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        
        System.runAs(maUser[0]){
            listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, true);
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
        }
        MA_TestUtil.createPortalUser(1, portaluserProfile.Id, portalrole.Id, listContact[0].Id, true);
    }
    
    // Single Record actions
    @isTest static void testSuccessfulContactCreation() {
        List<Acquisition_Contacts__c> acqContactlist = [SELECT Id, Email_Address_Target__c, Time_Zone__c
                                                        FROM Acquisition_Contacts__c];
        List<Acquisition_Provisioning__c> autoCreatedProvisions = [SELECT Id, Name, Acquisition_Contact__c, Offer_Status__c, Rehire_Former_Worker__c
                                                                   FROM Acquisition_Provisioning__c WHERE Acquisition_Contact__c =: acqContactlist[0].Id];
        Assert.areEqual(1, autoCreatedProvisions.size(), 'There should be one Provisioning record.');
        
        List<Acquisition_Compensation__c> autoCreatedCompenesations = [SELECT Id, Name, Acquisition_Contact__c, Status__c FROM Acquisition_Compensation__c WHERE Acquisition_Contact__c =: acqContactlist[0].Id];
        Assert.areEqual(1, autoCreatedCompenesations.size(), 'There should be one Compensation record.');
        
    }
    
    //Bulk Records actions
    @isTest static void testBulkContactUpdate() {
        
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        List<Acquisition_Company__c> listCompany = new List<Acquisition_Company__c> ();
        List<Acquisition_Contacts__c> acqContactlist = new List<Acquisition_Contacts__c> ();
        System.runAs(maESUser){
            listCompany = MA_TestUtil.createAcquisitionCompany(1,false);
            listCompany[0].Acquisition_Company_Name__c = maESName +'bulk';
            insert listCompany;
            acqContactlist = MA_TestUtil.createAcqContact(200, listCompany[0].Id, true);
        }  
        List<Acquisition_Provisioning__c> autoCreatedProvisions = [SELECT Id, Name, Acquisition_Contact__c, Offer_Status__c 
                                                                   FROM Acquisition_Provisioning__c];
        Assert.areEqual(201, autoCreatedProvisions.size(), 'There should be one Provisioning record.');
        
        List<Acquisition_Compensation__c> autoCreatedCompenesations = [SELECT Id, Name, Acquisition_Contact__c, Status__c FROM Acquisition_Compensation__c];
        Assert.areEqual(201, autoCreatedCompenesations.size(), 'There should be one Compensation record.');
        
        List<Acquisition_Contacts__c> queriedContacts = [SELECT Id, Name, Rehire_Former_Worker__c,Time_Zone__c FROM Acquisition_Contacts__c];
        
        for(Integer idx = 0; idx < 190; idx++){
            queriedContacts[idx].Rehire_Former_Worker__c= true;
            queriedContacts[idx].Time_Zone__c= 'Pacific/Pago_Pago';
        }
        Test.StartTest();
        update queriedContacts;
        Test.StopTest();
        
        List<Acquisition_Contacts__c> queriedContactsAfterRehireUpdate = [SELECT Id, Name, Rehire_Former_Worker__c, 
                                                                          (SELECT Id, Name, Offer_Status__c, Rehire_Former_Worker__c FROM Acquisition_Provisioning__r)
                                                                          FROM Acquisition_Contacts__c];
        
        for(Acquisition_Contacts__c aContact : queriedContactsAfterRehireUpdate){
            Assert.areEqual(1, aContact.Acquisition_Provisioning__r.size(), 'Each Contact should have one provision.');
            
            Assert.areEqual(aContact.Rehire_Former_Worker__c, aContact.Acquisition_Provisioning__r[0].Rehire_Former_Worker__c, 'Rehire/Former worker flag should match between Contact and Provision');
        }
    }
    
    @isTest static void test_updateBusinessTitle(){
        List<Acquisition_Contacts__c> acqContactlist = [SELECT Id, Business_Title__c
                                                        FROM Acquisition_Contacts__c];
        acqContactlist[0].Business_Title__c = null;
        
        Test.StartTest();
        update acqContactlist[0];
        Test.StopTest();
    }
    
    @isTest static void test_updateWayfinderUsers(){
        List<Acquisition_Contacts__c> listAcqContacts = [SELECT Id, Business_Title__c, Time_Zone__c
                                                         FROM Acquisition_Contacts__c];
        Map<Id, String> userTimeZoneMap = new Map<Id, String>();
        Map<Id, Boolean> userActivationMap = new Map<Id, Boolean>();
        
        Test.StartTest();
        userTimeZoneMap.put(listAcqContacts[0].Id, 'Asia/Kolkata');
        userActivationMap.put(listAcqContacts[0].Id, false);
        Acquisition_Contacts_Trigger_Handler.updateWayfinderUsers(userTimeZoneMap, userActivationMap);
        Test.StopTest();
    }
    
    @isTest static void test_deactivateUser(){
        List<Acquisition_Contacts__c> listAcqContacts = [SELECT Id, Contact_Status__c, Remove_Community_Access__c,(select Id,Acquisition_Contacts__c from Contacts__r)
                                                         FROM Acquisition_Contacts__c];
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        
        Test.StartTest();
        listAcqContacts[0].Remove_Community_Access__c = true;
        listAcqContacts[0].Contact_Status__c = 'Cancelled';
        System.runAs(maESUser){
            update listAcqContacts[0];
            
        }
        Test.StopTest();
        
        User u = [SELECT ID,IsActive, Email FROM USER WHERE ContactId =: listAcqContacts[0].Contacts__r[0].Id limit 1];
        Assert.areEqual(false, u.IsActive);
    }
    
    public static testMethod void test_updateEmail(){
        List<Acquisition_Contacts__c> listAcqContacts =[SELECT Id, Contact_Status__c, Remove_Community_Access__c
                                                        FROM Acquisition_Contacts__c];
        
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        
        Test.StartTest();
        System.runAs(maESUser){
            try{
                listAcqContacts[0].Email_Address_Target__c = 'testemail_update@test.com';
                update listAcqContacts[0];
            }catch(Exception e){
                system.debug('Exception:' + e);
            }
            
        }
        Test.StopTest();
        
    }  
    
    @isTest static void test_updateMuleExtId(){
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        List<Acquisition_Company__c> listCompany = new List<Acquisition_Company__c> ();
        List<Acquisition_Contacts__c> acqContactlist = new List<Acquisition_Contacts__c> ();
        
        System.runAs(maESUser){
            listCompany = MA_TestUtil.createAcquisitionCompany(1,false);
            listCompany[0].Acquisition_Company_Name__c = maESName +'mule';
            insert listCompany;
            acqContactlist = MA_TestUtil.createAcqContact(1, listCompany[0].Id, false);
            acqContactlist[0].MuleExtId__c ='';
            acqContactlist[0].Email_Address_Target__c ='updatemule@test.com';
            
        }  
        
        Test.StartTest();
        insert acqContactlist;
        Test.StopTest();
    }
    @isTest static void test_updateCountryDivision(){
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        List<Acquisition_Company__c> listCompany = new List<Acquisition_Company__c> ();
        List<Acquisition_Contacts__c> acqContactlist = new List<Acquisition_Contacts__c> ();
        
        System.runAs(maESUser){
            listCompany = MA_TestUtil.createAcquisitionCompany(1,false);
            listCompany[0].Acquisition_Company_Name__c = maESName +'div';
            insert listCompany;
            acqContactlist = MA_TestUtil.createAcqContact(1, listCompany[0].Id, false);
            acqContactlist[0].Workday_Location__c ='';
            acqContactlist[0].Email_Address_Target__c ='updateDivision@test.com';
            
        }  
        Test.StartTest();
        insert acqContactlist;
        Test.StopTest();
    }
    
}