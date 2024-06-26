public class IA_AssignPGToPortalUserHandler {
    public static set<Id> userId = new set<Id>();
    public static List<GroupMember> listGroupMember =new List<GroupMember>();
    public static void assignPG(Id userId){
        List<GroupMember> gm = [select group.name,group.DeveloperName from GroupMember where UserOrGroupId = :userId];
            if(gm.size()==0){
                Id publicGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Insiders_Candidates' LIMIT 1].Id;
                List<GroupMember> groupMembersToInsert = new List<GroupMember>();
                GroupMember newMember = new GroupMember();
                newMember.UserOrGroupId = userId;
                newMember.GroupId = publicGroupId;
                groupMembersToInsert.add(newMember);
                try{
                     insert groupMembersToInsert;
                }
                catch(exception exc){
                    
                }
            }
    }
}