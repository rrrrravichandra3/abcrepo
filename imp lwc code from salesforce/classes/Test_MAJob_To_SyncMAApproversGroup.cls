@isTest(SeeAllData=false)
public class Test_MAJob_To_SyncMAApproversGroup {

    @testSetup static void createTestData() {

        UserRole dummyRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];       
        Profile profile = [Select Id from Profile where name = 'System Administrator'];     

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
              
        System.runAs(sysAdminUser) {

            List<User> userList = new List<User>();
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

            User maApproverUser1 = new User(
                Username = 'maApprover1@community.com.wayfinder',
                ProfileId = profileEmployee.Id,
                UserRoleId = roleMA_ES.id,
                Alias = 'ma1Test',
                Email = 'ma1Test@community.com',
                FederationIdentifier = 'ma1Test@community.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'ma1Test',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            userList.add(maApproverUser1);

            User maApproverUser2 = new User(
                Username = 'maApprover2@community.com.wayfinder',
                ProfileId = profileEmployee.Id,
                UserRoleId = roleMA_ES.id,
                Alias = 'ma2Test',
                Email = 'ma2Test@community.com',
                FederationIdentifier = 'ma2Test@community.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'ma2Test',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            userList.add(maApproverUser2);

            User maApproverUser3 = new User(
                Username = 'maApprover3@community.com.wayfinder',
                ProfileId = profileEmployee.Id,
                UserRoleId = roleMA_ES.id,
                Alias = 'ma3Test',
                Email = 'ma3Test@community.com',
                FederationIdentifier = 'ma3Test@community.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                CommunityNickname = 'ma3Test',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            userList.add(maApproverUser3);

            Database.insert(userList);
            
            PermissionSet maCommunityAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'M_A_Community_Administration' LIMIT 1];

            List<PermissionSetAssignment> permSetAssigmentList = new List<PermissionSetAssignment>();
            PermissionSetAssignment assignmentMaAdminUser = new PermissionSetAssignment(PermissionSetId = maCommunityAdminPS.Id, AssigneeId = maApproverUser.Id);
            permSetAssigmentList.add(assignmentMaAdminUser);
            PermissionSetAssignment assignmentMaAdminUser1 = new PermissionSetAssignment(PermissionSetId = maCommunityAdminPS.Id, AssigneeId = maApproverUser1.Id);
            permSetAssigmentList.add(assignmentMaAdminUser1);
            Database.insert(permSetAssigmentList);

            Group maApproversGroup = new Group();
            maApproversGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'MA_Approvers' LIMIT 1];
            List<GroupMember> groupMemberList = new List<GroupMember>();
            GroupMember newGroupMember = new GroupMember(GroupId = maApproversGroup.Id, UserOrGroupId = maApproverUser.Id);
            groupMemberList.add(newGroupMember);
            GroupMember newGroupMember1 = new GroupMember(GroupId = maApproversGroup.Id, UserOrGroupId = maApproverUser1.Id);
            groupMemberList.add(newGroupMember1);
            Database.insert(groupMemberList);
            
        }
    }

    //Sync members on MA approvers group
    @isTest
    static void addMembersToApproversGroup(){
        User adminUser = [SELECT Id, Name, Email FROM User WHERE Email = 'test@test1.com' LIMIT 1];
        PermissionSet maCommunityAdminPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'M_A_Community_Administration' LIMIT 1];
        PermissionSetAssignment assignmentMaAdminUserToDelete = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId =: maCommunityAdminPS.Id AND Assignee.Email = 'ma1Test@community.com' LIMIT 1];
        Delete assignmentMaAdminUserToDelete;
        User maApproverUserToAdd = [SELECT Id, Name, Email FROM User WHERE Email = 'ma2Test@community.com' LIMIT 1];
        PermissionSetAssignment assignmentMaAdminUserToInsert = new PermissionSetAssignment(PermissionSetId = maCommunityAdminPS.Id, AssigneeId = maApproverUserToAdd.Id);
        Insert assignmentMaAdminUserToInsert;
        Test.StartTest();
            System.runAs(adminUser){
                MAJob_To_SyncMAApproversGroup syncJob = new MAJob_To_SyncMAApproversGroup();
                Database.executeBatch(syncJob);
            }
        Test.StopTest();
        List<GroupMember> groupMemberList = [SELECT Id FROM GroupMember WHERE Group.DeveloperName = 'MA_Approvers'];
        System.assertEquals(true, groupMemberList.size() > 0);
    }

    //Schedule job to sync MA approvers group
    @isTest
    static void scheduleJobToSyncPublicGroup(){
        User adminUser = [SELECT Id, Name, Email FROM User WHERE Email = 'test@test1.com' LIMIT 1];
        Test.StartTest();
            System.runAs(adminUser){
                MAJob_To_SyncMAApproversGroup syncJob = new MAJob_To_SyncMAApproversGroup();
                String interval = '0 0 23 * * ?';
                System.schedule('Sync MA Approvers', interval, syncJob);
            }
        Test.StopTest();
        List<CronTrigger> listJobSchedule = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Sync MA Approvers'];
        System.assertEquals(true, listJobSchedule.size() > 0);
    }
}