@isTest(SeeAllData=false)
public class Test_MA_MyInfoUpdatesListViewCtrl {

    @testSetup static void createTestData() {

         UserRole dummyRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];       
        Profile profile = [Select Id from Profile where name = 'System Administrator' Limit 1];     

        User sysAdminUser = new User(
            UserRoleId = dummyRole.Id,
            ProfileId = profile.Id,
            Username = 'testsysadminuser11@test.com',
            Alias = 'test1',
            Email='test@test11.com',
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
                Hire_Reason__c = 'Hire Acquisition',
                Acquisition_Company__c = accCompany.id,
                Employee_ID_Target__c = '123456',
                Email_Address_Target__c = 'test@community.com'
            
            );
            Database.insert(accContact);

            Acquisition_Compensation__c acqCompensation = new Acquisition_Compensation__c(
                Acquisition_Contact__c = accContact.id
            );
            Database.insert(acqCompensation);
            
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
	
            System.runAs(portalUser){
            MA_My_Info_Updates__c myInfoChange1 = new MA_My_Info_Updates__c(Field_Name__c = 'Last_Name_Legal__c', New_Value__c = 'Test123', Object_API_Name__c = 'Acquisition_Contacts__c', Record_Id__c = acqContactRecord.Id);
            listMyInfoUpdates.add(myInfoChange1);
            MA_My_Info_Updates__c myInfoChange2 = new MA_My_Info_Updates__c(Field_Name__c = 'Car_Allowance_Amount__c', New_Value__c = '100', Object_API_Name__c = 'Acquisition_Compensation__c', Record_Id__c = acqCompensationRecord.Id);
            listMyInfoUpdates.add(myInfoChange2);
            MA_My_Info_Updates__c myInfoChange3 = new MA_My_Info_Updates__c(Field_Name__c = 'Relocation_Assistance__c', New_Value__c = 'False', Object_API_Name__c = 'Acquisition_Compensation__c', Record_Id__c = acqCompensationRecord.Id);
            listMyInfoUpdates.add(myInfoChange3);
            MA_My_Info_Updates__c myInfoChange4 = new MA_My_Info_Updates__c(Field_Name__c = 'Stock_Grant_Date__c', New_Value__c = '2020-1-1 12:0:0', Object_API_Name__c = 'Acquisition_Compensation__c', Record_Id__c = acqCompensationRecord.Id);
            listMyInfoUpdates.add(myInfoChange4);
            Database.insert(listMyInfoUpdates); 
            }
        }
    }

    //MA Admin User Approves Changes
    @isTest 
    static void maAdminApprovesChanges(){
        List<MA_My_Info_Updates__c> myInfoUpdateList = new List<MA_My_Info_Updates__c>();
        myInfoUpdateList = [SELECT Id FROM MA_My_Info_Updates__c];
        User maAdminUser = [SELECT Id, Name, Email FROM User WHERE Email = 'maTest@community.com' LIMIT 1];
        Test.StartTest();
            System.runAs(maAdminUser){    
                PageReference pageRef = Page.MA_MyInfoUpdateListView;
                Test.setCurrentPage(pageRef); 
                ApexPages.StandardSetController controller = new ApexPages.StandardSetController(myInfoUpdateList);
                controller.setSelected(myInfoUpdateList);
                MA_MyInfoUpdatesListViewCtrl extension = new MA_MyInfoUpdatesListViewCtrl(controller);
                extension.isApproving = true;
                extension.massApproveFlowProcess();
                MA_MyInfoUpdatesListViewCtrl.navigateToListView();
            }
        Test.StopTest();
        System.assertEquals(4, myInfoUpdateList.size());
    }

    //MA Admin User Rejects Changes
    @isTest 
    static void maAdminRejectsChanges(){
        List<MA_My_Info_Updates__c> myInfoUpdateList = new List<MA_My_Info_Updates__c>();
        myInfoUpdateList = [SELECT Id FROM MA_My_Info_Updates__c];
        User maAdminUser = [SELECT Id, Name, Email FROM User WHERE Email = 'maTest@community.com' LIMIT 1];
        Test.StartTest();
            System.runAs(maAdminUser){    
                PageReference pageRef = Page.MA_MyInfoUpdateListViewReject;
                Test.setCurrentPage(pageRef); 
                ApexPages.StandardSetController controller = new ApexPages.StandardSetController(myInfoUpdateList);
                controller.setSelected(myInfoUpdateList);
                MA_MyInfoUpdatesListViewCtrl extension = new MA_MyInfoUpdatesListViewCtrl(controller);
                extension.isApproving = false;
                extension.approverComments = 'test comments';
                extension.massRejectFlowProcess();
                MA_MyInfoUpdatesListViewCtrl.navigateToListView();
            }
        Test.StopTest();
        System.assertEquals(4, myInfoUpdateList.size());
    }

    //No Records for submmiting
    @isTest 
    static void maAdminNoRecordsForApprove(){
        List<MA_My_Info_Updates__c> myInfoUpdateList = new List<MA_My_Info_Updates__c>();
        myInfoUpdateList = [SELECT Id, Status__c FROM MA_My_Info_Updates__c];
        for(MA_My_Info_Updates__c myInfo : myInfoUpdateList){
            myInfo.Status__c = 'Accepted';
        }
        Update myInfoUpdateList;
        User maAdminUser = [SELECT Id, Name, Email FROM User WHERE Email = 'maTest@community.com' LIMIT 1];
        Test.StartTest();
            System.runAs(maAdminUser){    
                PageReference pageRef = Page.MA_MyInfoUpdateListView;
                Test.setCurrentPage(pageRef); 
                ApexPages.StandardSetController controller = new ApexPages.StandardSetController(myInfoUpdateList);
                controller.setSelected(myInfoUpdateList);
                MA_MyInfoUpdatesListViewCtrl extension = new MA_MyInfoUpdatesListViewCtrl(controller);
            }
        Test.StopTest();
        System.assertEquals(4, myInfoUpdateList.size());
    }
}