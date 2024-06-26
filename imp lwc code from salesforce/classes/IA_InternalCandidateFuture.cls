/**
 * @author VenkateswaraReddy Komireddy
 * @date 28/09/2022
 *
 * Description Assign Public group and permission set to Internal Candidate 
******/

public with sharing class IA_InternalCandidateFuture {
	@testvisible static List<String> errorMessages;
    @future
    public static void assignGroupAndPermset(List<id> userIds) {
        try{
			errorMessages = new List<string>();
            String PermissionsetName = IA_Util.InsiderConfigDefaultRec.Perm_Set__c;
            String PublicGroupName = IA_Util.InsiderConfigDefaultRec.Public_Group__c;
            List<PermissionSetAssignment> userCandidatePerm = new List<PermissionSetAssignment>();
            List<GroupMember> groupMember = new List<GroupMember>();
            if (String.isNotBlank(PermissionsetName)) { 
                userCandidatePerm = [SELECT id,AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.name = :PermissionsetName AND AssigneeId IN: userIds];
            }
            Map<id,PermissionSetAssignment> mapPermAssignUsers = new Map<id,PermissionSetAssignment>();
            for(PermissionSetAssignment permUser : userCandidatePerm) {
                mapPermAssignUsers.put(permUser.AssigneeId,permUser);
            }
            groupMember = [Select id,UserOrGroupId from groupMember where UserOrGroupId IN : userIds and Group.developerName = :PublicGroupName];
            Map<id,groupMember> mapGroupUsers = new Map<id,groupMember>();
            for(groupMember groupUser : groupMember) {
                mapGroupUsers.put(groupUser.UserOrGroupId,groupUser);
            }
            for(Id userid: userIds) {
                if(!mapPermAssignUsers.containsKey(userid) || !mapGroupUsers.containsKey(userid)){
                	AssignPermissionSetAndPublicGroup(userid, PermissionsetName, PublicGroupName);
                }
            }
        } catch(Exception exp) {
            errorMessages.add(IA_Util.buildErrorMessage(
                UserInfo.getUserEmail(),
                userIds[0],
                'Assign PermissionSet or Public group Internal Candidate',
                exp.getMessage(),
                exp.getStackTraceString())
            );
        } finally {
            IA_Util.notifyErrors(errorMessages);
        } 
    }

    public static void AssignPermissionSetAndPublicGroup(Id UserId, String PermissionSetName, String GroupName) {
    	Map<String, Object> inputVarMap = new Map<String, Object>();
    	inputVarMap.put('PermissionSetName', PermissionSetName);
    	inputVarMap.put('GroupName', GroupName);
    	inputVarMap.put('UserId', UserId);
    	Flow.Interview.IA_AutoPermAndPublicGroupAssignment provisionAccessToCandidateFlow;
        provisionAccessToCandidateFlow = new Flow.Interview.IA_AutoPermAndPublicGroupAssignment(inputVarMap);
        provisionAccessToCandidateFlow.start();
    }
}