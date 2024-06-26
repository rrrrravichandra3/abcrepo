/**
 * @description       : Test class for MA_RelatedAcquisitionRecordsController
 * @author            : Satyam Kumar
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-12-2021   Satyam Kumar   Initial Version
 * 2.0   12-10-2023  Priyanka Kanani
**/
@isTest(SeeAllData=false)
public class MA_RelatedAcquisitionRecords_Test {
    private Static String maESName = 'relatedAcqTest';

    @testSetup static void createTestData() {
        
        UserRole esrole = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_ESROLE_NAME);
        profile esuserProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_EMPLOYEE_PROFILE);
        List<User> maUser = MA_TestUtil.createESUser(1, esuserProfile.Id, esrole.Id, true, maESName);
        
        PermissionSet maESPS = [SELECT Id FROM PermissionSet WHERE Name = :MA_TestUtilityValues.MA_ES_PERMSET LIMIT 1];
        MA_TestUtil.createPermissionsetAssignment(maESPS.Id, maUser[0].Id, true);
        
        UserRole role = MA_TestUtil.getUserRoleByName(MA_TestUtilityValues.MA_CUSTOMER_USERROLE_NAME);
        profile userProfile = MA_TestUtil.getUserProfile(MA_TestUtilityValues.MA_COMMUNITY_PORTAL_PROFILE);
        List<Contact> listContact = new List<Contact>();
        List<Acquisition_Contacts__c> listAcqContacts = new List<Acquisition_Contacts__c>();
        
        System.runAs(maUser[0]){
            List<Acquisition_Company__c> listCompany = MA_TestUtil.createAcquisitionCompany(1,true);
            List<Account> listAccount = MA_TestUtil.createAccount(1, listCompany[0].Id, true);
            listAcqContacts = MA_TestUtil.createAcqContact(1, listCompany[0].Id, true);
            listContact = MA_TestUtil.createContact(1, listAccount[0].Id, listAcqContacts[0].Id, true);
        }
        List<User> portalUsers = MA_TestUtil.createPortalUser(1, userProfile.Id, role.Id, listContact[0].Id, false);
        portalUsers[0].IsActive = true;
        insert portalUsers;
        
        Group maApproversGroup = new Group();
        maApproversGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'MA_Approvers' LIMIT 1];
        GroupMember newGroupMember = new GroupMember(GroupId = maApproversGroup.Id, UserOrGroupId = maUser[0].Id);
        Database.insert(newGroupMember);
        
        List<MA_My_Info_Updates__c> listMyInfoUpdates = new List<MA_My_Info_Updates__c>();
        Acquisition_Contacts__c acqContactRecord = [SELECT Id, Name, Last_Name_Legal__c FROM Acquisition_Contacts__c WHERE Id =: listAcqContacts[0].Id LIMIT 1];
        Acquisition_Compensation__c acqCompensationRecord = [SELECT Id, Car_Allowance_Amount__c, Relocation_Assistance__c, Stock_Grant_Date__c FROM Acquisition_Compensation__c LIMIT 1];
        Acquisition_Provisioning__c acqProvisioning = [SELECT Id FROM Acquisition_Provisioning__c LIMIT 1];
        
        System.runAs(portalUsers[0]){
            MA_My_Info_Updates__c myInfoChange1 = new MA_My_Info_Updates__c( Field_Name__c = 'Last_Name_Legal__c', New_Value__c = 'Test123', Object_API_Name__c = 'Acquisition_Contacts__c', Record_Id__c = acqContactRecord.Id);
            listMyInfoUpdates.add(myInfoChange1);
            MA_My_Info_Updates__c myInfoChange2 = new MA_My_Info_Updates__c( Field_Name__c = 'Car_Allowance_Amount__c', New_Value__c = '100', Object_API_Name__c = 'Acquisition_Compensation__c', Record_Id__c = acqCompensationRecord.Id);
            listMyInfoUpdates.add(myInfoChange2); 
            MA_My_Info_Updates__c myInfoChange3 = new MA_My_Info_Updates__c( Field_Name__c = 'Mobile_Notes__c', New_Value__c = 'Change in notes', Object_API_Name__c = 'Acquisition_Provisioning__c', Record_Id__c = acqProvisioning.Id);
            listMyInfoUpdates.add(myInfoChange3);
            Database.insert(listMyInfoUpdates);
        }
    }

    /**
     * Given: A My info update record is submitted for Acquisition Contact update
     * When: is created by portal users
     * Then: M&A ES users should be able to see the related records in record page using LWC
     */
    @isTest 
    static void fetchRelatedRecordsForAcquContactUpdate_MAESUser(){
        List<MA_My_Info_Updates__c> myInfoUpdateList = new List<MA_My_Info_Updates__c>();
        List<MA_RelatedAcquisitionRecordsController.acquisitionWrapper> acquWrapperList = new List<MA_RelatedAcquisitionRecordsController.acquisitionWrapper>();
        
        myInfoUpdateList = [SELECT  Record_Id__c, Object_API_Name__c FROM MA_My_Info_Updates__c where Object_API_Name__c = 'Acquisition_Contacts__c' limit 1];
        System.assert(myInfoUpdateList.size() != 0, 'My info update record not found');
        
		String objectName = myInfoUpdateList[0].Object_API_Name__c;
        String recordId = myInfoUpdateList[0].Record_Id__c;
        
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        Test.StartTest();
        System.runAs(maESUser){    
            acquWrapperList = MA_RelatedAcquisitionRecordsController.getAcquisitionWrapperList(recordId,objectName);
        }
        Test.StopTest();
        System.assert(acquWrapperList.size() == 3, 'Acquisition Contact related records not retrieved correctly');
    }
    
    /**
     * Given: A My info update record is submitted for Acquisition Compensation update
     * When: is created by portal users
     * Then: M&A ES users should be able to see the related records in record page using LWC
     */
    @isTest 
    static void fetchRelatedRecordsForAcquCompensationUpdate_MAESUser(){
        List<MA_My_Info_Updates__c> myInfoUpdateList = new List<MA_My_Info_Updates__c>();
        List<MA_RelatedAcquisitionRecordsController.acquisitionWrapper> acquWrapperList = new List<MA_RelatedAcquisitionRecordsController.acquisitionWrapper>();
        
        myInfoUpdateList = [SELECT  Record_Id__c, Object_API_Name__c FROM MA_My_Info_Updates__c where Object_API_Name__c = 'Acquisition_Compensation__c' limit 1];
        System.assert(myInfoUpdateList.size() != 0, 'My info update record not found');
        
		String objectName = myInfoUpdateList[0].Object_API_Name__c;
        String recordId = myInfoUpdateList[0].Record_Id__c;
        
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        Test.StartTest();
        System.runAs(maESUser){    
            acquWrapperList = MA_RelatedAcquisitionRecordsController.getAcquisitionWrapperList(recordId,objectName);
        }
        Test.StopTest();
        System.assert(acquWrapperList.size() == 3, 'Acquisition Compensation related records not retrieved correctly');
    }
    
    /**
     * Given: A My info update record is submitted for Acquisition Provisioning update
     * When: is created by portal users
     * Then: M&A ES users should be able to see the related records in record page using LWC
     */
    @isTest 
    static void fetchRelatedRecordsForAcquProvisioningUpdate_MAESUser(){
        List<MA_My_Info_Updates__c> myInfoUpdateList = new List<MA_My_Info_Updates__c>();
        List<MA_RelatedAcquisitionRecordsController.acquisitionWrapper> acquWrapperList = new List<MA_RelatedAcquisitionRecordsController.acquisitionWrapper>();
        
        myInfoUpdateList = [SELECT  Record_Id__c, Object_API_Name__c FROM MA_My_Info_Updates__c where Object_API_Name__c = 'Acquisition_Provisioning__c' limit 1];
        System.assert(myInfoUpdateList.size() != 0, 'My info update record not found');
        
		String objectName = myInfoUpdateList[0].Object_API_Name__c;
        String recordId = myInfoUpdateList[0].Record_Id__c;
        
        User maESUser = [Select id from user where Email = :maESName + MA_TestUtilityValues.MA_ES_USER_EMAIL limit 1];
        Test.StartTest();
        System.runAs(maESUser){    
            acquWrapperList = MA_RelatedAcquisitionRecordsController.getAcquisitionWrapperList(recordId,objectName);
        }
        Test.StopTest();
        System.assert(acquWrapperList.size() == 3, 'Acquisition Provisioning related records not retrieved correctly');
    }
}