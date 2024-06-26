//Not using "with sharing" as code needs to run in System mode to update user records
public class TF_FutureMethodUtil{

  /*
  * Method to Assign specific permsets to given set of users
  * @param : idOfUsers - Set of Id of users to which the permsets (second parameter) need to be given
  * @param : permSetNames - Set of String denoting Permission Set Names
  */
  @future 
  public static void assignPermSetsToUsers(Set<Id> idOfUsers, Set<String> permSetNames){

        if(idOfUsers.size()>0 && permSetNames.size()>0){
            List<PermissionSet> permSets = [Select Id, Name, Label from PermissionSet where Name IN :permSetNames];

            Set<Id> permsetIDs = new Set<Id>();
            for(PermissionSet currPermSet : permSets){
              permsetIDs.add(currPermSet.Id);
            }
            //Map userToPermSetMap : Key => User Id, Value => Set of Permission Set IDs that need to be assigned to this user
            Map<Id, Set<Id>> userToPermSetMap = new Map<Id, Set<Id>>();
            for(Id currUserId : idOfUsers){
                if(!(userToPermSetMap.containsKey(currUserId))){ 
                  userToPermSetMap.put(currUserId, new Set<Id>());
                }
                for(Id currPermSetID : permsetIDs){
                    (userToPermSetMap.get(currUserId)).add(currPermSetID);
                }
            }


            //check if one or more of given permsets are already assigned to any user
            List<PermissionSetAssignment>  existingPermSetAssignments = [select Id, AssigneeId, PermissionSetId 
                                                                         from PermissionSetAssignment 
                                                                         where ((AssigneeId IN :idOfUsers) AND (PermissionSetId IN :permsetIDs))];
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
            if(permsetToBeCreated.size()>0) {insert permsetToBeCreated;}
        }   
  }

  
  /* Method to update user record (First parameter). Field "People Manager" is checked and Profile is changed to given (second parameter) profile
  * @param : idOfUsers - Set of ID of users for which profile and field "People Manager" needs to be updated
  * @param : profileIdToBeApplied - Id of profile that needs to be assigned to given set of users
  */
  @future
  public static void updateUserProfile(Set<Id> idOfUsers, Id profileIdToBeApplied){
        if(idOfUsers.size()>0  && profileIdToBeApplied!=null){
            List<User> hiringManagers = [Select Id, People_Manager__c, profileId from User where Id IN:idOfUsers];
            List<User> usersToBeUpdated = new List<User>();
            for(User currUser : hiringManagers){
                if((currUser.profileId == profileIdToBeApplied   &&  currUser.People_Manager__c == true)){
                    continue;
                }
                if(currUser.profileId != profileIdToBeApplied) {currUser.profileId = profileIdToBeApplied;}
                if(currUser.People_Manager__c != true) {currUser.People_Manager__c = true;}
                usersToBeUpdated.add(currUser);
            }
            if(usersToBeUpdated.size()>0){
              update usersToBeUpdated;
            }
        }  
  }


}