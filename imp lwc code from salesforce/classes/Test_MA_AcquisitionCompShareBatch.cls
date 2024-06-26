/**
* Test Class for MA_AcquisitionCompensationShareBatch
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         29-12-2023      priyanka Kanani         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData=false)
public class Test_MA_AcquisitionCompShareBatch {
private Static String maESName = 'acqCompShareBatch';
    
    @testSetup 
    static void setupData() {
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(2, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(2,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            
            List<Acquisition_Contacts__c> listAcqContacts = MA_TestUtil.createAcqContact(2, listCompany[0].Id, false);
            listAcqContacts[0].Name = maESName;
            insert listAcqContacts;
            listContact = MA_TestUtil.createContact(2, listAccount[0].Id, listAcqContacts[0].Id, true);
            
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
    }
    @isTest
    static void testShareInsert() {
        
        Acquisition_Compensation__c comp = [SELECT Id FROM Acquisition_Compensation__c LIMIT 1]; 
        Acquisition_Company__c company = [SELECT Id FROM Acquisition_Company__c LIMIT 1];  
        User portalUser = [Select id from user where Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
        List<User> maESUser = [Select id from user where Email like :maESName+'%'];
        try{
            Test.startTest();
            System.runAs(portalUser){
                MA_AcquisitionCompensationShareBatch batch = new MA_AcquisitionCompensationShareBatch(company.Id, new Set<Id>{maESUser[0].Id}, null, new Map<Id, String>{maESUser[1].Id => 'Edit'}, null, 'SAVE'); 
                Database.executeBatch(batch);
            }
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
        
        List<Acquisition_Compensation__Share> shares = [SELECT Id, RowCause FROM Acquisition_Compensation__Share WHERE ParentId = :comp.Id];
        System.assert(!shares.isEmpty());
        System.assertEquals('From_Company_Sharing__c', shares[0].RowCause);
    }
    
    @isTest 
    static void testShareDelete(){
    
        Acquisition_Compensation__c comp = [SELECT Id,Acquisition_Contact__r.Acquisition_Company__c FROM Acquisition_Compensation__c LIMIT 1];
        Acquisition_Company__c company = [SELECT Id FROM Acquisition_Company__c LIMIT 1]; 
        List<User> maESUser = [Select id from user where Email like :maESName+'%'];
        user portalUser = [Select id from user where Email = :MA_TestUtilityValues.MA_PORTAL_USER_EMAIL limit 1];
       
        insert new Acquisition_Compensation__Share(AccessLevel='Edit', ParentId=comp.Id, 
                                                   UserOrGroupId=maESUser[1].Id, RowCause='From_Company_Sharing__c');
       
        Test.startTest();
        System.runAs(portalUser){
            MA_AcquisitionCompensationShareBatch batch = new MA_AcquisitionCompensationShareBatch(company.Id, new Set<Id>{maESUser[1].Id,maESUser[0].Id}, null, null, maESUser[1].Id, 'DELETE'); 
            Database.executeBatch(batch);     
        }
        Test.stopTest();
        
        List<Acquisition_Compensation__Share> shares = [SELECT Id,RowCause FROM Acquisition_Compensation__Share WHERE ParentId = :comp.Id and RowCause='From_Company_Sharing__c']; 
        System.assert(shares.isEmpty());  
    }
    
    @isTest
    static void testShareDeleteError() {
        
        Acquisition_Compensation__c comp = [SELECT Id FROM Acquisition_Compensation__c LIMIT 1]; 
        Acquisition_Company__c company = [SELECT Id FROM Acquisition_Company__c LIMIT 1];  
        List<User> maESUser = [Select id from user where Email like :maESName+'%'];
        try{
            Test.startTest();
            System.runAs(maESUser[1]){
                MA_AcquisitionCompensationShareBatch batch = new MA_AcquisitionCompensationShareBatch(company.Id, new Set<Id>{maESUser[1].Id,maESUser[0].Id}, null, null, maESUser[1].Id, 'DELETE');
                batch.failedDeleteBatchRecordCount = new Map<String, String>{comp.Id => '1'};
                Database.executeBatch(batch);
            }
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
    }
    
    @isTest
    static void testfailBatchRecordCount() {
        
        Acquisition_Compensation__c comp = [SELECT Id FROM Acquisition_Compensation__c LIMIT 1]; 
        Acquisition_Company__c company = [SELECT Id FROM Acquisition_Company__c LIMIT 1];  
        List<User> maESUser = [Select id from user where Email like :maESName+'%'];
        try{
            Test.startTest();
            System.runAs(maESUser[0]){
                MA_AcquisitionCompensationShareBatch batch = new MA_AcquisitionCompensationShareBatch(company.Id, new Set<Id>{maESUser[0].Id}, null, new Map<Id, String>{maESUser[0].Id => 'Edit'}, null, 'SAVE');
                batch.failedBatchRecordCount = new Map<Id, decimal>{maESUser[0].Id => 1};
                Database.executeBatch(batch);
            }
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception: '+e.getmessage());
        }
    }
}