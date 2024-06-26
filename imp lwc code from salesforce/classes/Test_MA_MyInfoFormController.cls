@isTest(SeeAllData=false)
public class Test_MA_MyInfoFormController {

    @testSetup static void createTestData() {

        UserRole dummyRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];       
        Profile profile = [Select Id from Profile where name = 'System Administrator' limit 1];     

        User sysAdminUser = new User(
            UserRoleId = dummyRole.Id,
            ProfileId = profile.Id,
            Username = 'testsysadminuser77687@test.com',
            Alias = 'test1',
            Email='test@test1.com',
            EmailEncodingKey='UTF-8',
            Firstname='Sys',
            Lastname='Admin User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(sysAdminUser);
            
        User portalUser = new User();
        Contact contact = new Contact();
              
        System.runAs(sysAdminUser) {
        
            //Create acquisition company
            Acquisition_Company__c accCompany = new Acquisition_Company__c(
                
                Acquisition_Company_Name__c = 'MA',
                Name = 'MA',
                Status__c = 'Pre-Diligence'
            
            );
            
            Database.insert(accCompany);
            
            //Create account
            Account account = new Account(
            
                Name = 'MA',
                Acquisition_Companies__c = accCompany.id,
                OwnerId = sysAdminUser.Id
            
            );
            Database.insert(account);
            
            Acquisition_Contacts__c accContact = new Acquisition_Contacts__c(
            
                Name = 'Test Community',
                Contact_Status__c = 'New',
                Hire_Reason__c = 'New Hire',
                Acquisition_Company__c = accCompany.id,
                Employee_ID_Target__c = '123456',
                Email_Address_Target__c = 'test@community.com'
            
            );
            Database.insert(accContact);

            Acquisition_Compensation__c acqCompensation = new Acquisition_Compensation__c(
                Acquisition_Contact__c = accContact.id
            );
            Database.insert(acqCompensation);

            Acquisition_Provisioning__c acqProvisioning = new Acquisition_Provisioning__c(
                Acquisition_Contact__c = accContact.id
            );
            Database.insert(acqProvisioning);
            
            //Create contact
            contact = new Contact(
                FirstName = 'Community',
                Lastname = 'Contact',
                AccountId = account.Id,
                Email = 'test@community.com',
                Acquisition_Contacts__c = accContact.Id
            );
            Database.insert(contact);
            
            //Create users
            List<User> userList = new List<User>();
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name ='M&A Community Portal Custom' Limit 1];
            UserRole portalRole = [SELECT Id FROM UserRole WHERE Name = 'MA Customer User' Limit 1];
            portalUser = new User(
                Username = 'test7686portal@community.com.wayfinder',
                ContactId = contact.Id,
                ProfileId = portalProfile.Id,
                UserRoleId = portalRole.id,
                Alias = 'test123',
                Email = 'test@community.com',
                FederationIdentifier = 'test@community.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            userList.add(portalUser);

            Profile profileEmployee = [SELECT Id FROM Profile WHERE Name ='Employee' Limit 1];
            UserRole roleMA_ES = [SELECT Id FROM UserRole WHERE Name = 'M&A ES' Limit 1];
            User maApproverUser = new User(
                Username = 'maApprover@community.com.wayfinder',
                ProfileId = profileEmployee.Id,
                UserRoleId = roleMA_ES.id,
                Alias = 'maTest',
                Email = 'maTest@community.com',
                FederationIdentifier = 'maTest@community.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'maTest',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            userList.add(maApproverUser);
            Database.insert(userList);
            
            PermissionSet maCommunityAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'M_A_Community_Administration' LIMIT 1];

            PermissionSetAssignment assignmentMaAdminUser = new PermissionSetAssignment(PermissionSetId = maCommunityAdminPS.Id, AssigneeId = maApproverUser.Id);
            Database.insert(assignmentMaAdminUser);

            Group maApproversGroup = new Group();
            maApproversGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'MA_Approvers' LIMIT 1];
            GroupMember newGroupMember = new GroupMember(GroupId = maApproversGroup.Id, UserOrGroupId = maApproverUser.Id);
            Database.insert(newGroupMember);
            
            List<MA_My_Info_Updates__c> listMyInfoUpdates = new List<MA_My_Info_Updates__c>();
            Acquisition_Contacts__c acqContactRecord = [SELECT Id, Name, Last_Name_Legal__c FROM Acquisition_Contacts__c WHERE Name = 'Test Community' LIMIT 1];
            Acquisition_Compensation__c acqCompensationRecord = [SELECT Id, Car_Allowance_Amount__c, Relocation_Assistance__c, Stock_Grant_Date__c FROM Acquisition_Compensation__c LIMIT 1];
            Acquisition_Provisioning__c acqprovisioningRecord = [SELECT Id, Acquisition_Contact__c FROM Acquisition_Provisioning__c LIMIT 1];

                MA_My_Info_Updates__c myInfoChange1 = new MA_My_Info_Updates__c(Field_Name__c = 'Last_Name_Legal__c', New_Value__c = 'Test123', Object_API_Name__c = 'Acquisition_Contacts__c', Record_Id__c = acqContactRecord.Id, Acquisition_Provisioning__c = acqprovisioningRecord.Id);
                listMyInfoUpdates.add(myInfoChange1);
                MA_My_Info_Updates__c myInfoChange2 = new MA_My_Info_Updates__c(Field_Name__c = 'Car_Allowance_Amount__c', New_Value__c = '100', Object_API_Name__c = 'Acquisition_Compensation__c', Record_Id__c = acqCompensationRecord.Id, Acquisition_Provisioning__c = acqprovisioningRecord.Id);
                listMyInfoUpdates.add(myInfoChange2);
                MA_My_Info_Updates__c myInfoChange3 = new MA_My_Info_Updates__c(Field_Name__c = 'Relocation_Assistance__c', New_Value__c = 'False', Object_API_Name__c = 'Acquisition_Compensation__c', Record_Id__c = acqCompensationRecord.Id, Acquisition_Provisioning__c = acqprovisioningRecord.Id);
                listMyInfoUpdates.add(myInfoChange3);
                MA_My_Info_Updates__c myInfoChange4 = new MA_My_Info_Updates__c(Field_Name__c = 'Stock_Grant_Date__c', New_Value__c = '2020-1-1 12:0:0', Object_API_Name__c = 'Acquisition_Compensation__c', Record_Id__c = acqCompensationRecord.Id, Acquisition_Provisioning__c = acqprovisioningRecord.Id);
                listMyInfoUpdates.add(myInfoChange4);
                Database.insert(listMyInfoUpdates); 
            

            List<MA_My_Info_Section__c> listInfoSections = new List<MA_My_Info_Section__c>();
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();

            Schema.SObjectType SObjectTypeAqcContact = GlobalDescribeMap.get('Acquisition_Contacts__c');
            Schema.DescribeSObjectResult DescribeSObjectResultAcqContact = SObjectTypeAqcContact.getDescribe();
            for(Schema.FieldSet fieldset:DescribeSObjectResultAcqContact.FieldSets.getMap().values()) {               
                MA_My_Info_Section__c sectionContact = new MA_My_Info_Section__c();
                sectionContact.Name = fieldset.getName();
                sectionContact.Company__c = 'MA';
                sectionContact.Editable_Fields__c = fieldset.getName();
                sectionContact.Field_Set_Name__c = fieldset.getName();
                sectionContact.Object__c = 'Acquisition_Contacts__c';
                sectionContact.Section_Label__c = fieldset.getName();
                sectionContact.Sort_Order__c = 1;
                listInfoSections.add(sectionContact);
                break;
            }

            Schema.SObjectType SObjectTypeAqcCompensation = GlobalDescribeMap.get('Acquisition_Compensation__c');
            Schema.DescribeSObjectResult DescribeSObjectResultAcqCompensation = SObjectTypeAqcCompensation.getDescribe();
            for(Schema.FieldSet fieldset:DescribeSObjectResultAcqCompensation.FieldSets.getMap().values()) {               
                MA_My_Info_Section__c sectionCompesantion = new MA_My_Info_Section__c();
                sectionCompesantion.Name = fieldset.getName();
                sectionCompesantion.Company__c = 'MA';
                sectionCompesantion.Editable_Fields__c = '*';
                sectionCompesantion.Field_Set_Name__c = fieldset.getName();
                sectionCompesantion.Object__c = 'Acquisition_Compensation__c';
                sectionCompesantion.Section_Label__c = fieldset.getName();
                sectionCompesantion.Sort_Order__c = 2;
                listInfoSections.add(sectionCompesantion);
                break;
            }

            Schema.SObjectType SObjectTypeAqcProvisioning = GlobalDescribeMap.get('Acquisition_Provisioning__c');
            Schema.DescribeSObjectResult DescribeSObjectResultAcqProvisioning = SObjectTypeAqcProvisioning.getDescribe();
            for(Schema.FieldSet fieldset:DescribeSObjectResultAcqProvisioning.FieldSets.getMap().values()) {               
                MA_My_Info_Section__c sectionProvisioning = new MA_My_Info_Section__c();
                sectionProvisioning.Name = fieldset.getName();
                sectionProvisioning.Company__c = 'MA';
                sectionProvisioning.Editable_Fields__c = '*';
                sectionProvisioning.Field_Set_Name__c = fieldset.getName();
                sectionProvisioning.Object__c = 'Acquisition_Provisioning__c';
                sectionProvisioning.Section_Label__c = fieldset.getName();
                sectionProvisioning.Sort_Order__c = 3;
                listInfoSections.add(sectionProvisioning);
                break;
            }

            Schema.SObjectType SObjectTypeAqcCompany = GlobalDescribeMap.get('Acquisition_Company__c');
            Schema.DescribeSObjectResult DescribeSObjectResultAcqCompany = SObjectTypeAqcCompany.getDescribe();
            for(Schema.FieldSet fieldset:DescribeSObjectResultAcqCompany.FieldSets.getMap().values()) {               
                MA_My_Info_Section__c sectionCompany = new MA_My_Info_Section__c();
                sectionCompany.Name = fieldset.getName();
                sectionCompany.Company__c = 'MA';
                sectionCompany.Editable_Fields__c = '*';
                sectionCompany.Field_Set_Name__c = fieldset.getName();
                sectionCompany.Object__c = 'Acquisition_Company__c';
                sectionCompany.Section_Label__c = fieldset.getName();
                sectionCompany.Sort_Order__c = 4;
                listInfoSections.add(sectionCompany);
                break;
            }
            Insert listInfoSections;

            MA_MyInfo_Customizations__c customizeRenderSection = new MA_MyInfo_Customizations__c();
            customizeRenderSection.Community_Name__c = 'MA';
            customizeRenderSection.Name = 'MA';
            customizeRenderSection.Render_Confirm_Button__c = true;
            customizeRenderSection.Render_Edit_Button__c = true;
            Insert customizeRenderSection;

            List<MA_MyInfoFormComponents__c> listComponentsSettings = new List<MA_MyInfoFormComponents__c>();
            listComponentsSettings.add(new MA_MyInfoFormComponents__c(Name = 'Default', Component_Name__c = 'c:MA_InputText'));
            listComponentsSettings.add(new MA_MyInfoFormComponents__c(Name = 'ENCRYPTEDSTRING', Component_Name__c = 'c:MA_InputEncrypted'));
            listComponentsSettings.add(new MA_MyInfoFormComponents__c(Name = 'PICKLIST', Component_Name__c = 'c:MA_InputSelect'));
            listComponentsSettings.add(new MA_MyInfoFormComponents__c(Name = 'STRING', Component_Name__c = 'c:MA_InputText'));
            Insert listComponentsSettings;
        }
    }

    @isTest 
    static void portalUserSeeMyInfo(){
        User portalUser = [SELECT Id, Name, Email FROM User WHERE Email = 'test@community.com'];
        String resultMyInfo;
        Test.StartTest();
            System.runAs(portalUser){
                resultMyInfo = MA_MyInfoFormController.getSections();
                String valueDate = MA_MyInfoFormController.getDisplayValue(Schema.DisplayType.DATE, 'test');
            }
        Test.StopTest(); 
        System.assertEquals(true, resultMyInfo != null);
    }

    @isTest 
    static void portalUseComfirmSection(){
        User portalUser = [SELECT Id, Name, Email FROM User WHERE Email = 'test@community.com'];
        MA_My_Info_Updates__c myInfoChange1 = new MA_My_Info_Updates__c(Field_Name__c = 'Last_Name_Legal__c', New_Value__c = 'Test123', Object_API_Name__c = 'Acquisition_Contacts__c', Record_Id__c = '0000001');
        String myInfoString = JSON.serialize(myInfoChange1);
        List<String> recordsToInsert = new List<String>();
        recordsToInsert.add(myInfoString);
        String lastConfirmDate;
        String lastStatus;
        Test.StartTest();
            System.runAs(portalUser){
                MA_MyInfoFormController.insertApprovalRecords(recordsToInsert);
                lastConfirmDate = MA_MyInfoFormController.getLastConfirmDate(true);
            }
        Test.StopTest(); 
        System.assertEquals(true, lastConfirmDate != null);
    }

    @isTest 
    static void getlastStatusMyInfoChange(){
        User adminUser = [SELECT Id, Name, Email FROM User WHERE Email = 'test@test1.com'];
        String lastStatus;
        Test.StartTest();
            System.runAs(adminUser){
                lastStatus = MA_MyInfoFormController.getStatusChanges();
            }
        Test.StopTest(); 
        System.assertEquals(true, lastStatus != null);
    }
    
    /**
     * Given: There is existing My info update record
     * When: M&A user edits it again in My info section in Community 
     * Then: it should update the existing My info update record
     */
    @isTest 
    static void canUpdateExistingApprovalRecord_CommunityUser(){
        User communityUser = [SELECT Id, Name, Email FROM User WHERE Email = 'test@community.com'];
        String acqContactRecordId = '1234567891234';
        MA_My_Info_Updates__c myInfoChange = new MA_My_Info_Updates__c(Field_Name__c = 'Last_Name_Legal__c', New_Value__c = 'Test123', Object_API_Name__c = 'Acquisition_Contacts__c', Record_Id__c = acqContactRecordId);
        String myInfoString = JSON.serialize(myInfoChange);
        List<String> myInfoRecordsToInsert = new List<String>();
        List<String>  existingMyInfoChangeList = new List<String>();
        myInfoRecordsToInsert.add(myInfoString);
        String lastConfirmDate;
        String lastStatus;
        
        System.runAs(communityUser){
            MA_MyInfoFormController.insertApprovalRecords(myInfoRecordsToInsert);
        }
        
        for(MA_My_Info_Updates__c existingMyInfoChange : [Select Id, New_Value__c from MA_My_Info_Updates__c where Record_Id__c =: acqContactRecordId]) {
            existingMyInfoChange.New_Value__c = existingMyInfoChange.New_Value__c + 'v2';
            String exitingMyInfoString = JSON.serialize(existingMyInfoChange);
            existingMyInfoChangeList.add(exitingMyInfoString);
        }
        
        System.runAs(communityUser){
            Test.StartTest();
            MA_MyInfoFormController.insertApprovalRecords(existingMyInfoChangeList);
            Test.StopTest(); 
        }
        
        List<MA_My_Info_Updates__c> updatedMyInfoChangeList = [Select Id, New_Value__c from MA_My_Info_Updates__c where Record_Id__c =: acqContactRecordId];
        system.Assert(updatedMyInfoChangeList.size() != 0, 'My Info Updates record not processed');
        system.AssertEquals(1, updatedMyInfoChangeList.size(), 'Duplicate My Info Updates record created');
        system.Assert(updatedMyInfoChangeList[0].New_Value__c.contains('v2'), 'New value not updated correctly in My info updates record');
    }
}