/**
 * @description       : Class for getting all application related to Inernal Standard user(IA_SignInService.getInternalCandidateEligibility)
 * @author            : m.pal@salesforce.com
 *
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-29-2022   m.pal@salesforce.com                 Initial version
 */
public class IA_InternalUserSignIn implements IA_LoginInternalInterface{
    public static Set<String> getAllInternalApplication(String internalUserEmail){
        Insiders_App_Config__mdt insidersConfig = IA_Util.InsiderConfigDefaultRec;
        List<String> internalCanStages = IA_Util.eligibleCandidateStagesForInternal;
        Set<String> candidateStages = new Set<String>();
        Boolean loginAllowed = false;
        List<WDR_Application__c> currentAplication = [Select Candidate_Stage__c from WDR_Application__c where Internal_Candidate__c = True AND Candidate_Email__c =:internalUserEmail];
        
        for(WDR_Application__c wd:currentAplication){
            if(String.isNotBlank(wd.Candidate_Stage__c)){
                candidateStages.add(wd.Candidate_Stage__c);
                if(internalCanStages.contains(wd.Candidate_Stage__c) && loginAllowed==false){
                    loginAllowed= true;
                }
            }
        }
        
        //assigning PS & PG to internal candidate
        if(String.isNotBlank(internalUserEmail) && currentAplication.size()>0 && loginAllowed == True){
            map<string,user> mapUser =new map<string,user>();
            List<id> userids=new List<id>();
            List<user> lstUsers=[select id,name,email from user where email =: internalUserEmail and isActive= :true and 
                                 Profile.name != :insidersConfig.Candidate_Profile__c And userType='Standard'];
            for(user u : lstUsers){
                userids.add(u.id);
            }
            
            if(userids.size()>0){
                IA_InternalCandidateFuture.assignGroupAndPermset(userids);
            }
        }
        
        return candidateStages;
    }
}