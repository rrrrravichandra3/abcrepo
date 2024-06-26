/**
 * @author VenkateswaraReddy Komireddy
 * @date 28/09/2022
 *
 * Description Assign Public group and permission set to Internal Candidate 
******/

public with sharing class IA_InternalAssignPermsetAndGroup {
    @testvisible
    static List<String> errorMessages;
    public static void assignPermissionSetandGroup(List<Insiders_Tracking__c> newRecords) {
        try{
            Insiders_App_Config__mdt insidersConfig = IA_Util.InsiderConfigDefaultRec;
            errorMessages = new List<string>();
            List<String> emailIds =new List<String>();
            for(Insiders_Tracking__c insiderTracking : newRecords){
                if(insiderTracking.Internal_Candidate__c  && insiderTracking.Invitation_Email_Sent__c){
                	emailIds.add(insiderTracking.Candidate_Email__c);
                }
            }
            if(!emailIds.isEmpty()){
				map<string,user> mapUser =new map<string,user>();
                List<id> userids=new List<id>();
                List<user> lstUsers=[select id,name,email from user where email IN : emailIds and isActive= :true and 
                                     Profile.name != :insidersConfig.Candidate_Profile__c And userType='Standard'];
                for(user u : lstUsers){
                    userids.add(u.id);
                }
                
                if(userids.size()>0){
                	IA_InternalCandidateFuture.assignGroupAndPermset(userids);
                }
            }
        }
        Catch(Exception exp){
            errorMessages.add(IA_Util.buildErrorMessage(UserInfo.getUserEmail(), newRecords[0].Name, 'Internal Candidate Assign permission set or public group', exp.getMessage(), exp.getStackTraceString()));
        }
        finally {
            IA_Util.notifyErrors(errorMessages);
        } 
    }
}