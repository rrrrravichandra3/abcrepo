public class assignHiringManagerPermSets implements Queueable {
	
    Set<Id> newHiringManagerIds {get;set;}
    Set<String> hiringManagerPermSetNames {get;set;}

    public assignHiringManagerPermSets (Set<Id> newHiringManagerIds, Set<String> hiringManagerPermSetNames){
    	this.newHiringManagerIds = newHiringManagerIds;
    	this.hiringManagerPermSetNames = hiringManagerPermSetNames;
    }

	public void execute(QueueableContext context) {
        if(newHiringManagerIds.size()>0 && hiringManagerPermSetNames.size()>0){
            List<PermissionSet> permSets = [Select Id, Name, Label from PermissionSet where Name IN :hiringManagerPermSetNames];

            Set<Id> permsetIDs = new Set<Id>();
            for(PermissionSet currPermSet : permSets){
              permsetIDs.add(currPermSet.Id);
            }
            //Map userToPermSetMap : Key => User Id, Value => Set of Permission Set IDs that need to be assigned to this user
            Map<Id, Set<Id>> userToPermSetMap = new Map<Id, Set<Id>>();
            for(Id currUserId : newHiringManagerIds){
                if(!(userToPermSetMap.containsKey(currUserId))){ 
                  userToPermSetMap.put(currUserId, new Set<Id>());
                }
                (userToPermSetMap.get(currUserId)).addAll(permsetIDs);
            }


            //check if one or more of given permsets are already assigned to any user
            List<PermissionSetAssignment>  existingPermSetAssignments = [select Id, AssigneeId, PermissionSetId 
                                                                         from PermissionSetAssignment 
                                                                         where ((AssigneeId IN :newHiringManagerIds) AND (PermissionSetId IN :permsetIDs))];
            if(existingPermSetAssignments.size()>0){
                for(PermissionSetAssignment currPermSetAssignment : existingPermSetAssignments){
                    //don't need to assign the perm set if a user already has it. Edit the Map userToPermSetMap
                    (userToPermSetMap.get(currPermSetAssignment.AssigneeId)).remove(currPermSetAssignment.PermissionSetId);
                    if((userToPermSetMap.get(currPermSetAssignment.AssigneeId)).size() == 0) {
                        userToPermSetMap.remove(currPermSetAssignment.AssigneeId);
                    }
                }
            }

            //Map userToPermSetMap now represents all the permsetAssignments that need to be created
            List<PermissionSetAssignment> permsetToBeCreated = new List<PermissionSetAssignment>();
            if(userToPermSetMap.size()>0){
                for(Id hiringMngId : userToPermSetMap.keyset()){
                    for(Id currPermsetId : userToPermSetMap.get(hiringMngId)){
                        PermissionSetAssignment hiringMngPermSet = new PermissionSetAssignment();
                        hiringMngPermSet.AssigneeId = hiringMngId;
                        hiringMngPermSet.PermissionSetId = currPermsetId;
                        permsetToBeCreated.add(hiringMngPermSet);
                    }
                }
            }
            if(permsetToBeCreated.size()>0) {
            	Database.insert(permsetToBeCreated,false);
            }
        }
            
	}
}