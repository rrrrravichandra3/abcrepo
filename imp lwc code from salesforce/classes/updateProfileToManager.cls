public class updateProfileToManager implements Queueable {

    Set<Id> newHiringManagerIds {get;set;}
    Id managerProfileId {get;set;}
    Set<String> recruiterPermsetNames {get;set;}

    public updateProfileToManager(Set<Id> newHiringManagerIds,Id managerProfileId, Set<String> recruiterPermsetNames){
        this.newHiringManagerIds = newHiringManagerIds;
        this.managerProfileId = managerProfileId;
        this.recruiterPermsetNames = recruiterPermsetNames;
    }
    public void execute(QueueableContext context) {
        if((newHiringManagerIds.size()>0) && (managerProfileId!=null)){
            //remove users that have all the recruiter permission sets
            //Store the Ids of recruiter Permsets
            List<PermissionSet> recruiterPermSets = [Select Id, Name, Label from PermissionSet where Name IN :recruiterPermsetNames];
            Set<Id> recruiterPermSetIds = new Set<Id>();
            for(PermissionSet currPermSet : recruiterPermSets){
                recruiterPermSetIds.add(currPermSet.Id);
            }
            //For given users, retrieve the permsets already assigned to them
            List<PermissionSetAssignment>  existingPermSetAssignments = [select Id, AssigneeId, PermissionSetId 
                                                                         from PermissionSetAssignment 
                                                                         where (AssigneeId IN :newHiringManagerIds)];
            //Create a map. Key => UserId, Value => Set of Permission Set Ids assigned to them
            Map<Id, Set<Id>> userIdToAssignedPermSetIdsMap = new Map<Id, Set<Id>>();
            for(PermissionSetAssignment currAssignment : existingPermSetAssignments){
                if(!(userIdToAssignedPermSetIdsMap.containsKey(currAssignment.AssigneeId))) {
                    userIdToAssignedPermSetIdsMap.put(currAssignment.AssigneeId, new Set<Id>());
                }
                (userIdToAssignedPermSetIdsMap.get(currAssignment.AssigneeId)).add(currAssignment.PermissionSetId);
            }
            //remove the users that have all the recruiter perm sets
            Set<Id> hmWithoutRecruiterPermSet = new Set<Id>();
            for(Id currentUserId : newHiringManagerIds){
                if ((userIdToAssignedPermSetIdsMap.containsKey(currentUserId)) && (!((userIdToAssignedPermSetIdsMap.get(currentUserId)).containsAll(recruiterPermSetIds)))){
                    hmWithoutRecruiterPermSet.add(currentUserId);
                }
            }
            //change the profiles 
            if(hmWithoutRecruiterPermSet.size()>0){
                List<User> hiringManagers = [Select Id, People_Manager__c, profileId from User where Id IN :hmWithoutRecruiterPermSet];
                List<User> usersToBeUpdated = new List<User>();
                for(User currUser : hiringManagers){
                    if((currUser.profileId == managerProfileId   &&  currUser.People_Manager__c == true)){
                        continue;
                    }
                    if(currUser.profileId != managerProfileId) {currUser.profileId = managerProfileId;}
                    if(currUser.People_Manager__c != true) {currUser.People_Manager__c = true;}
                    usersToBeUpdated.add(currUser);
                }
                if(usersToBeUpdated.size()>0){
                  Database.update(usersToBeUpdated,false);
                }
            }

        }
    }
}