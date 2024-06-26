/**
 * @author VenkateswaraReddy Komireddy
 * @date 29/04/2022
 *
 * @description : This Implements IA_LoginAfter24HoursInterface to Update Insiders Tracking object CandidateLogin field  
 * @params : qc queuableContext,id userId
 * specific to  Peopleforce
 */
public class IA_LoginAfter24HoursReminderQueuable implements Queueable {
	
    @testvisible static List<String> errorMessages;
    @testvisible private Id userId;
    public IA_LoginAfter24HoursReminderQueuable(Id userId) {
        this.userId = userId;
    }

    public void execute(System.QueueableContext qc) {
        User userRecord;
        errorMessages = new List<string>();
        List<Insiders_Tracking__c> lstInsiderTracking;
        try{
            
            userRecord = [select id,Email,userType,ContactId,Contact.MPA_App__c,LastLoginDate from user where id=:userId];            
            if(userRecord.userType=='Standard'){
                List<String> eligibleStagesforInternal = IA_Util.eligibleCandidateStagesForInternal;
                lstInsiderTracking =[select id,Name,Candidate_Login__c from Insiders_Tracking__c where
                                                            Candidate_Email__c = :userRecord.Email 
                                                            AND WD_Job_Application__r.Candidate_Stage__c IN :eligibleStagesforInternal
                                                            AND Reminder_Email_Sent__c =false];
            }
            else{
                List<String> eligibleStagesforExternal = IA_Util.eligibleCandidateStages;
                lstInsiderTracking =[select id,Name,Candidate_Login__c from Insiders_Tracking__c where
                                                            Candidate_Email__c = :userRecord.Email 
                                                            AND WD_Job_Application__r.Candidate_Stage__c IN :eligibleStagesforExternal
                                                            AND Reminder_Email_Sent__c =false];
            }
            if(!lstInsiderTracking.isEmpty()){                     
                List<Insiders_Tracking__c> updteLstTracking =new List<Insiders_Tracking__c>();
                for(Insiders_Tracking__c tracking :lstInsiderTracking){
                    if(tracking.Candidate_Login__c == null ){
                        tracking.Candidate_Login__c = userRecord.LastLoginDate;
                        updteLstTracking.add(tracking);
                    } 
                }
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, updteLstTracking);

                if(!securityDecision.getRecords().isEmpty()){
                    update securityDecision.getRecords();
                }
            }
        }
        catch(Exception exp){
            errorMessages.add(IA_Util.buildErrorMessage(UserInfo.getUserEmail(),userRecord.Id,'Login After 24 Hours Reminder Email',exp.getMessage(),exp.getStackTraceString()));
        }
        finally{
            IA_Util.notifyErrors(errorMessages);
        }
    }
}