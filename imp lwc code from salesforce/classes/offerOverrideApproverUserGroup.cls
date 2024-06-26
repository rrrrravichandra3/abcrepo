public class offerOverrideApproverUserGroup implements Queueable {
    
    private Id approverId {get; set;}

    public offerOverrideApproverUserGroup(Id approverId){
    	this.approverId = approverId;
    }

    public class OfferApproverOverrideGroupAdditionException extends Exception{}

	public void execute(QueueableContext context) {
        //get the names of all the public groups from custom setting Tf2 Settings.Offer_Override_Approver_Group_Names__c
        Set<String> groupNames = new Set<String>();
        groupNames.addAll(getApproverGroupNames());
        //retrieve the IDs of the groups stored in custom setting
        Set<Id> approverGroupIDs = new Set<Id>();
        List<Group> allGroups = [SELECT Id,Name,DeveloperName FROM Group WHERE DeveloperName IN :groupNames];
        for(Group currentGroup : allGroups){
        	approverGroupIDs.add(currentGroup.Id);
        }
        //remove the names of group that approver is already a part of
        List<GroupMember> existingGroupMembership = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId = :approverId AND GroupId IN :approverGroupIDs];
        for(GroupMember currentMembership : existingGroupMembership){
        	approverGroupIDs.remove(currentMembership.GroupId);
        }
        //Create group membership records that need to be created
        List<GroupMember> membershipToBeCreated = new List<GroupMember>();
        for(Id currentGroupId : approverGroupIDs){
        	GroupMember newMembership = new GroupMember();
        	newMembership.GroupId = currentGroupId;
        	newMembership.UserOrGroupId = approverId;
        	membershipToBeCreated.add(newMembership);
        }
        //insert membership
        Database.SaveResult[] lsr = Database.insert(membershipToBeCreated,false);
        
        Boolean throwExceptionFlag = false;
        String errorMessage = 'Could not add the approver to one or more groups : ';
        for (Database.SaveResult sr : lsr){
            if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()){
                    throwExceptionFlag = true;
                    errorMessage = errorMessage + '; '+ err.getMessage();
                }
            }
        }

        if(throwExceptionFlag == true){
            throw new OfferApproverOverrideGroupAdditionException(errorMessage);
        }

	}

	private Set<String> getApproverGroupNames(){
		Set<String> groupNames = new Set<String>();
		//get comma seperated Names from custom setting
        TF2Settings__c  cstmSetting = TF2Settings__c.getOrgDefaults();
        String groupNamesConcatenated = cstmSetting.Offer_Override_Approver_Group_Names__c;
        //Split the custom setting record into Strings of permset names
        if(!String.isBlank(groupNamesConcatenated)){
            List<String> allGroupNames = groupNamesConcatenated.split(',');
            for(String currentGroupName : allGroupNames){
                groupNames.add(currentGroupName);
            }
        }
        return groupNames;
	}
}