public class offerOverrideApproverPermSets implements Queueable {

	private Id approverId {get; set;}

	public offerOverrideApproverPermSets(Id approverId){
		this.approverId = approverId;
	}

    public class OfferApproverOverridePermSetException extends Exception{}

	public void execute(QueueableContext context) {
        // get the names of Permission sets that need to be given to hiring manager.
        Set<String> permsetNames = new Set<String>();
        permsetNames.addAll(getApproverPermSetNames());
        //retrieve IDs of permissions sets to be assigned
        List<PermissionSet> permSets = [Select Id, Name, Label from PermissionSet where Name IN :permSetNames];

        Set<Id> permsetIDs = new Set<Id>();
        for(PermissionSet currPermSet : permSets){
          permsetIDs.add(currPermSet.Id);
        }
        //check if one or more of given permsets are already assigned to any user
        List<PermissionSetAssignment>  existingPermSetAssignments = [select Id, AssigneeId, PermissionSetId 
                                                                         from PermissionSetAssignment 
                                                                         where ((AssigneeId = :approverId) AND (PermissionSetId IN :permsetIDs))];
        if(existingPermSetAssignments.size()>0){
            for(PermissionSetAssignment currPermSetAssignment : existingPermSetAssignments){
                //don't need to assign the perm set if a user already has it.
                permsetIDs.remove(currPermSetAssignment.PermissionSetId);
            }
        }
        //create permsetAssignemnt records that need to be inserted
        List<PermissionSetAssignment> permsetToBeCreated = new List<PermissionSetAssignment>();
        for(Id currPermsetId : permsetIDs){
        	PermissionSetAssignment offerApproverPermSet = new PermissionSetAssignment();
            offerApproverPermSet.AssigneeId = approverId;
            offerApproverPermSet.PermissionSetId = currPermsetId;
            permsetToBeCreated.add(offerApproverPermSet);
        }
        //insert permsets
        Database.SaveResult[] lsr = Database.insert(permsetToBeCreated,false);
        
        Boolean throwExceptionFlag = false;
        String errorMessage = 'Could not assign one or more permission sets to approver : ';
        for (Database.SaveResult sr : lsr){
            if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()){
                    throwExceptionFlag = true;
                    errorMessage = errorMessage + '; '+ err.getMessage();
                }
            }
        }

        if(throwExceptionFlag == true){
            throw new OfferApproverOverridePermSetException(errorMessage);
        }
        
	}

	/* Method to return API names of Perm Sets stored in custom setting "Tf2 Setting"
    * @return permSetDeveloperNamesSet : Set of Strings. Each string is a Permset name
    */
    private Set<String> getApproverPermSetNames(){
        Set<String> permSetDeveloperNamesSet = new Set<String>();
        //get comma seperated Names from custom setting
        TF2Settings__c  cstmSetting = TF2Settings__c.getOrgDefaults();
        String permSetNamesConcatenated = '';
        //Split the custom setting record into Strings of permset names
        if(!String.isBlank(permSetNamesConcatenated)){
            List<String> permSetNames = permSetNamesConcatenated.split(',');
            for(String currentPermSetName : permSetNames){
                permSetDeveloperNamesSet.add(currentPermSetName);
            }
        }
        return permSetDeveloperNamesSet;
    }
}