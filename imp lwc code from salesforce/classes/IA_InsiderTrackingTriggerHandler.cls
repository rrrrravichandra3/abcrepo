/**
* @author Manish Pal
* @date 01/03/2023
*
* Description Insider Trakcing Trigger
******/
public class IA_InsiderTrackingTriggerHandler {
    public static void assignInternalPermission(List<Insiders_Tracking__c> newList){
        List<string> errorMessages = new List<string>();
        try{
            List<IA_Assign_PS_PG_to_Internal_Candidate__e> events = new List<IA_Assign_PS_PG_to_Internal_Candidate__e>();
            Insiders_App_Config__mdt insidersConfig = IA_Util.InsiderConfigDefaultRec;
            List<String> emailIds =new List<String>();
            for(Insiders_Tracking__c insiderTracking : newList){
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
                    for(Id ids:userids){
                        events.add(new IA_Assign_PS_PG_to_Internal_Candidate__e(User_Ids__c = ids));
                    }
                }
                Database.SaveResult[] saveResultList = Eventbus.publish(events);
            }
        }
        Catch(Exception exp){
            errorMessages.add(IA_Util.buildErrorMessage(UserInfo.getUserEmail(), newList[0].id, 'Internal Candidate Assign permission set or public group', exp.getMessage(), exp.getStackTraceString()));
        }
    }
}