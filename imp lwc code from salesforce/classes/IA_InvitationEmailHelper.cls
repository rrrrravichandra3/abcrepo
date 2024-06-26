/*
 * @author Lucas Olivera
 * @date 05/19/2022
 *
 * @description Helper class used in Invitation Email
 *
 *
 * Modifications Log
 * Ver   Date         Author                          Modification
 * 1.0   05/19/2022   lolivera@salesforce.com         Initial Version
 *
 */
public with sharing class IA_InvitationEmailHelper {
    
    /** get the custom lable data for validate invitaion email */
    Static String INTERVIEW = Label.IA_Stage_Interview;
    Static String OFFER = Label.IA_Stage_Offer;
    Static String SCREEN = Label.IA_Stage_Screen;
    Static String FIRST_INTERVIEW = Label.IA_ApplicationStep_First_Interview;
    Static String ADDITIONAL_INTERVIEWS = Label.IA_ApplicationStep_Additional_Interviews;
    Static String RESCHEDULE_INTERVIEW = Label.IA_ApplicationStep_Reschedule_Interview;
    Static String OFFER_PREPARATION = Label.IA_ApplicationStep_Offer_Preparation;
    Static String OFFER_AMENDMENT = Label.IA_ApplicationStep_Offer_Amendment;
    Static String HIRING_MANAGER_REVIEW = Label.IA_ApplicationStep_Hiring_Manager_Review;
    
    
    /**********************************************************************************************
     * @description               Validates Job Requisition's data to determine whether a Candidate
     *                            is a Futureforce persona or not.
     *
     * @param employmentType     : Job Requisition's Employment Type data
     * @param reqCreationReason  : Job Requisition's Creation Reason data
     *
     * @return Boolean           : If the Candidate is a Futureforce Candidate it will return true,
     *                             it will return false otherwise.
     */
    public static Boolean identifyFutureforcePersona(String employmentType, String reqCreationReason) {
        String INTERN = Label.IA_Type_Intern;
        String PERM_FTE = Label.IA_Type_PERM_FTE;
        String INTERN_CONVERSION = Label.IA_Type_Intern_Conversion;
        String NEW_FUTUREFORCE = Label.IA_ReqCreationReason_New_Futureforce;
        String REPLACEMENT_FUTUREFORCE = Label.IA_ReqCreationReason_Replacement_Futureforce;
        // NOTE: This method will need changes with ES Next changes
        if (employmentType == INTERN && reqCreationReason == NEW_FUTUREFORCE) {
            return true;
        } else if (employmentType == PERM_FTE && (reqCreationReason == NEW_FUTUREFORCE || reqCreationReason == REPLACEMENT_FUTUREFORCE)) {
            return true;
        } 
        // Intern conversion scenario covered with the boomrang check true. removed the 3rd condition
        // This Candidate was not a valid for Futureforce persona
        return false;
    }

    /**********************************************************************************************
     * @description             Validates Candidate Stage and Application Step combo to determine
     *                          if the Invitation Email should be sent or not.
     *
     * @param jobApp          : Job Application record that triggers the Invitation Email Flow.
     *
     * @return Boolean        : Return true if the job application is in a valid state for
     *                          Invitation Email.
     */
    public static boolean validateApplicationIsValidForInvitationEmail(WDR_Application__c jobApp) {
        list<String> FFJobLevels = IA_Util.FFJobLevel;
        list<String> ExternalJobLevels = IA_Util.externalJobLevel;
        // This scenario is Futureforce only
        Boolean futureforcePersona = identifyFutureforcePersona(jobApp.Job__r.Employment_Type__c, jobApp.Job__r.Req_Creation_Reason__c);
        if (futureforcePersona && FFJobLevels.Contains(jobApp.Job__r.Job_Level__c)) {
            // "Futureforce - Australia , Canada, France, Germany, Israel, Switzerland, Spain" should not trigger the invitation email
            // "Futureforce - Australia", "Futureforce - United Kingdom","Futureforce - Ireland" should not trigger the invitation email
            list<String> JobCountries = IA_Util.CandidateCountriesList;
            if (JobCountries.Contains(jobApp.Job__r.Country__c)) {
                return false;
            }
            
            if ((jobApp.Candidate_Stage__c == INTERVIEW && jobApp.Application_Step__c == FIRST_INTERVIEW) || (jobApp.Candidate_Stage__c == OFFER && String.isBlank(jobApp.Application_Step__c))) {
                return true;
            }
            //Consider Futureforce persona and not consider Boomerang condition
            if(validateAllPersonaInvitationEmail(jobApp)){
                return true;
            }
        }
        
        //Consider below conditions Boomerang ==false && External or Internal Persona and valid job level 
        if(!jobApp.Boomerang__c && !futureforcePersona && ExternalJobLevels.Contains(jobApp.Job__r.Job_Level__c)){
            return validateAllPersonaInvitationEmail(jobApp);
        }
        return false;
    }
    
    /****** 
     * @description Validate Application data for all personas
		Scenarios valid for any Candidate persona (Internal,External, Futureforce)
     * *****/
    Public static boolean validateAllPersonaInvitationEmail(WDR_Application__c jobApp){
        // Scenarios valid for any Candidate
        if (jobApp.Candidate_Stage__c == INTERVIEW && (jobApp.Application_Step__c == ADDITIONAL_INTERVIEWS || jobApp.Application_Step__c == RESCHEDULE_INTERVIEW || jobApp.Application_Step__c == OFFER_PREPARATION)) {
            return true;
        }
        if (jobApp.Candidate_Stage__c == OFFER && (String.isBlank(jobApp.Application_Step__c) || jobApp.Application_Step__c == OFFER_AMENDMENT)) {
            return true;
        }
        //It can be both for internal and future force
        if(jobApp.Internal_Candidate__c){
            if(jobApp.Candidate_Stage__c == SCREEN && jobApp.Application_Step__c == HIRING_MANAGER_REVIEW){
                return true;
            }
        } 
        return false;
    }
}