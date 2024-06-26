public class IAAssignPublicGroupToPortalUserImpl implements IAAssignPublicGroupToPortalUserInterface{
    public static void assignPGToPortalUsers(List<IA_Assign_Public_Group_To_Portal_User__e> listOfPlatformEvents){
        List<IA_Assign_Public_Group_To_Portal_User__e> eventsToUpdate = new List<IA_Assign_Public_Group_To_Portal_User__e>();
        Id publicGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'Insiders_Candidates' LIMIT 1].Id;
        List<GroupMember> groupMembersToInsert = new List<GroupMember>();
        List<PF_Debug_Log__c> pfDebugLogs = new List<PF_Debug_Log__c>();
        Id userId;
        for (IA_Assign_Public_Group_To_Portal_User__e event : listOfPlatformEvents) {
            // Attempt to assign user to the public group
            GroupMember newMember = new GroupMember();
            newMember.UserOrGroupId = event.UserId__c;
            newMember.GroupId = publicGroupId;
            groupMembersToInsert.add(newMember);
            userId = event.UserId__c;
        }
        try {
            List<Database.SaveResult> insertResults = Database.insert(groupMembersToInsert,false);
            for (Integer i = 0; i < insertResults.size(); i++) {	
                if (!insertResults[i].isSuccess()) {
                    PF_Logger.log(
                        'InsiderApp',
                        'ERROR',
                        'Assignment failed for public group' + groupMembersToInsert[i],
                        'Insider public group assignment failed',
                        'Insider public group assignment failed',
                        'IAAssignPublicGroupToPortalUser'
                    );
                    pfDebugLogs.addall(PF_Logger.logs);
                }
                IA_Util.sendExceptionMail(new List<String>{ 'The following userId is having issue with assigning Insider_Candidate public group' + groupMembersToInsert[i]});
            }
            if (!pfDebugLogs.isEmpty() && !test.IsRunningTest()) {
                PF_Logger.createLogs(pfDebugLogs);
            }
            else{
                throw new DMLException('My DML EXCEPTION');
            }
        }
        Catch(Exception e){
            IA_Util.sendExceptionMail(new List<String>{ 'The public group assignment for these users caused an exception' + groupMembersToInsert + '\n' + e.getMessage() + ' Stack Trace:' + e.getStackTraceString() });
            PF_Logger.log(
                'InsiderApp',
                'ERROR',
                'Assignment failed for public group with exception' + groupMembersToInsert,
                'error message' + e.getMessage(),
                'error stack to trace' + e.getStackTraceString(),
                'IAAssignPublicGroupToPortalUser'
            );
            pfDebugLogs.addall(PF_Logger.logs);
            if (!pfDebugLogs.isEmpty() && !test.IsRunningTest()) {
                PF_Logger.createLogs(pfDebugLogs);
            }
        }
    }
}