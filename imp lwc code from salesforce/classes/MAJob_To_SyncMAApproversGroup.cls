global with sharing class MAJob_To_SyncMAApproversGroup implements Database.Batchable<sObject>, Schedulable{

    global database.queryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name '
                       +'FROM PermissionSetAssignment WHERE PermissionSet.Name = \'M_A_Community_Administration\' AND Assignee.UserRole.Name = \'M&A ES\' AND Assignee.IsActive = true';
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(this, 200);
    }

    global void execute(Database.BatchableContext BC, List<PermissionSetAssignment> permSetAssignmentList){
        List<GroupMember> listOfMemberToAdd = new List<GroupMember>();
        List<GroupMember> listOfMemberToRemove = new List<GroupMember>();
        Set<Id> idMembersOfGroup = new Set<Id>();
        Set<Id> idUserWithPermission = new Set<Id>();
        Group maApproversGroup = new Group();
        Map<Id, Id> idUserWithIdMember = new Map<Id, Id>();
        maApproversGroup = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName = 'MA_Approvers' LIMIT 1];
        for(PermissionSetAssignment permSetAssignment : permSetAssignmentList){
            idUserWithPermission.add(permSetAssignment.AssigneeId);
        }
        for(GroupMember groupMemberRecord : [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId =: maApproversGroup.Id]){
            idMembersOfGroup.add(groupMemberRecord.UserOrGroupId);
            idUserWithIdMember.put(groupMemberRecord.UserOrGroupId, groupMemberRecord.Id);
        }
        for(Id idGroupMember : idMembersOfGroup){
            if(idUserWithPermission.contains(idGroupMember)){
                idUserWithPermission.remove(idGroupMember);
            }else{
                GroupMember deleteGroupMember = new GroupMember();
                deleteGroupMember.Id = idUserWithIdMember.get(idGroupMember);
                listOfMemberToRemove.add(deleteGroupMember);
            }
        }
        for(Id idUsers : idUserWithPermission){
            GroupMember newGroupMember = new GroupMember(); 
            newGroupMember.GroupId = maApproversGroup.Id;
            newGroupMember.UserOrGroupId = idUsers;
            listOfMemberToAdd.add(newGroupMember);
        }

        if(listOfMemberToRemove.size() > 0){
            Delete listOfMemberToRemove;
        }

        if(listOfMemberToAdd.size() > 0){
            Insert listOfMemberToAdd;
        }
    }

    global void finish(Database.BatchableContext BC){

    }
}