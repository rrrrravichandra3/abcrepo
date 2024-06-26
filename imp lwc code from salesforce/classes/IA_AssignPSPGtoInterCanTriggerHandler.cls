/*
 * @description : Assign PS and PG to Internal canditate
 * @params : events List<IA_Assign_PS_PG_to_Internal_Candidate__e>
*/

public class IA_AssignPSPGtoInterCanTriggerHandler {
public static void processEvents(List<IA_Assign_PS_PG_to_Internal_Candidate__e> events) {
        List<Id> userIds = new List<Id>();
        for(IA_Assign_PS_PG_to_Internal_Candidate__e e: events){
            if(e.User_Ids__c != null){
                userIds.add(e.User_Ids__c);
            }
        }
        if(!userIds.IsEmpty()){
            IA_InternalCandidateFuture.assignGroupAndPermset(userIds);
        }
    }
}