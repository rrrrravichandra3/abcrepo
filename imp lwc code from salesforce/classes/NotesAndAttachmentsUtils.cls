public class NotesAndAttachmentsUtils {
    
    /**
     * Method to get all the related AMS id's to a candidate.
     * @param candidateIdSet is a Set.
     * @param candidateRelatedIdSet is a set.
     * @param jobMap is a Map.
     */
     
    public static void loadAllCandidateRelatedApplications(Set<Id> candidateIdSet,Set<Id> candidateRelatedIdSet, Map<Id,JobInfo> jobMap) {
        Set<Id> candidateApplicationsStageIdSet = new Set<Id>();
        // loading application Id's.
        loadAllApplicationIdsRelatedtoCandidate(candidateIdSet,jobMap);
        // loading submittal Id's.
        loadAllSubmittalIdsRelatedtoCandidate(candidateIdSet,jobMap);
        // loading interview Id's.
        loadAllInterviewIdsRelatedtoCandidate(candidateIdSet,jobMap);
        // loading offer Id's.
        loadAllOfferIdsRelatedtoCandidate(candidateIdSet,jobMap);
        // loading placement Id's.
        loadAllPlacementIdsRelatedtoCandidate(candidateIdSet,jobMap);
        // loading candidate secure info id's
        candidateRelatedIdSet.addAll(getAllCandidateSecureinfoIdsRelatedtoCandidate(candidateIdSet));
        candidateRelatedIdSet.addAll(jobMap.keySet());
        
    }
    
    
    /**
     * Method to get all application Id's related to the candidate.
     * @param candidateIdSet is a Set.
     * @param jobMap is a Map.
     */
    public static void loadAllApplicationIdsRelatedtoCandidate(Set<Id> candidateIdSet,Map<Id,JobInfo> jobMap){

    }
    
    /**
     * Method to get all submittal Id's related to the candidate.
     * @param candidateIdSet is a Set..
     * @param jobMap is a Map.
     */
    public static void  loadAllSubmittalIdsRelatedtoCandidate(Set<Id> candidateIdSet,Map<Id,JobInfo> jobMap){

    }   
    
    /**
     * Method to get all interview Id's related to the candidate.
     * @param candidateIdSet is a Set..
     * @param jobMap is a Map.
     */
    public static void loadAllInterviewIdsRelatedtoCandidate(Set<Id> candidateIdSet,Map<Id,JobInfo> jobMap){

    }
    
    /**
     * Method to get all offer Id's related to the candidate.
     * @param candidateIdSet is a Set..
     * @param jobMap is a Map.
     */
    public static void  loadAllOfferIdsRelatedtoCandidate(Set<Id> candidateIdSet,Map<Id,JobInfo> jobMap){

    }
    
    /**
     * Method to get all placement Id's related to the candidate.
     * @param candidateIdSet is a Set..
     * @param jobMap is a Map.
     */
    public static void loadAllPlacementIdsRelatedtoCandidate(Set<Id> candidateIdSet,Map<Id,JobInfo> jobMap){

    } 
    
    
    /**
     * Method to get all candidate secure info Id's related to the candidate.
     * @param candidateIdSet is a set.
     * @return placementIdSet is a set.
     */
    public static Set<Id> getAllCandidateSecureinfoIdsRelatedtoCandidate(Set<Id> candidateIdSet){
        Set<Id> candidateSecureInfoIdSet = new Set<Id>();
        for(Candidate_Secure_Info__c candidateSecureInfo : [select Id,name, Candidate__c from Candidate_Secure_Info__c where Candidate__c IN: candidateIdSet ]) {
            candidateSecureInfoIdSet.add(candidateSecureInfo.Id);
        }
        return candidateSecureInfoIdSet;
    } 
    
    /**
     * Method to get the AMS Object prefix and the labels,  load those values into a map.
     * @return Map<String,String>.
     */
    public static Map<String,String> getStageObjectsPrefix() {
        Map<String,String> objectKeyPrefix = new Map<String,String>();
        String ancillaryObjectNames= Constants.AMS_STAGE_OBJECT_NAMES+ Constants.COMMA + Constants.CANDIDATE_TABLE_NAME+ Constants.COMMA + Constants.CANDIDATE_SECURE_INFO_TABLE_NAME;
        Schema.DescribeSObjectResult descResult = null;
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType objectType =null; 
        for (String objectName : ancillaryObjectNames.split(Constants.COMMA)) {
             objectType = globalDescribe.get(objectName);
             descResult = objectType.getDescribe();
             objectKeyPrefix.put(descResult.getKeyPrefix(), descResult.getLabel());
        }
        
        return objectKeyPrefix;
    } 

    /** 
     * Method to get all notes related to candidate and corresponding jobs and stages of applications he or she applied to.
     * @param candidateRelatedIdSet is a set.
     * @return is a list.
     */
    public static List<Note> getAllNotesRelatedToCandidate(Set<Id> candidateRelatedIdSet) {
    	return [Select Title, ParentId, OwnerId,Owner.Name, IsPrivate, Id, CreatedDate, body From Note Where ParentId IN :candidateRelatedIdSet order by CreatedDate desc];
    }                                        
    
    
    /** 
     * Method to get all attachments related to candidate and corresponding jobs and stages of applications he or she applied to.
     * @param candidateRelatedIdSet is a set.
     * @return is a list.
     */
    public static List<Attachment> getAllAttachmentsRelatedToCandidate(Set<Id> candidateRelatedIdSet) {
    	return [Select ParentId, OwnerId,Owner.Name, Name, IsPrivate, Id, CreatedDate, ContentType From Attachment Where ParentId IN :candidateRelatedIdSet order by CreatedDate desc];
    }              

    /** 
     * Method to get all activities related to candidate and corresponding jobs and stages of applications he or she applied to.
     * @param candidateRelatedIdSet is a set.
     * @param candidateIdSet is a set.
     * @return is a list.
     */
    public static List<Task> getAllActivitiesRelatedToCandidate(Set<Id> candidateRelatedIdSet, Set<Id> candidateIdSet) {
    	return [Select WhoId, WhatId, Type, Subject, Status, Priority, OwnerId, Job_Req_Title__c, Interview_Round__c, Id,Description, CreatedDate, CreatedById, CallType, ActivityDate From Task  Where WhoId IN:candidateIdSet OR WhatId IN : candidateRelatedIdSet order by ActivityDate desc];
    } 
    
    /**
     * Method to return the all candidate that match the email addresses.
     * @param emailAddress is a String.
     * @return Set is a candidateIdSet.
     */
    public static Set<Id> getAllCandidatesGivenEmailAddress(String emailAddress) {  
        Set<Id> candidateIdSet = new Set<Id>();
        for(Contact candidate :[Select Id, name, email from Contact where email =:emailAddress and recordType.Name =:Constants.CANDIDATE]) {
        	candidateIdSet.add(candidate.Id);
        }
        return candidateIdSet;
    }
    
    /** 
     * Method to get interview feedback for a candidate.
     * @param candidateIdSet is a set.
     * @return is a list.
     */
    public static List<Interview_Feedback__c> getAllInterviewFeedbacksRelatedToCandidate(Set<Id> candidateIdSet) {
    	return [Select Name, Interviewer_User__r.Title, Interviewer_User__r.Name, Interviewer_User__c, Id, Hiring_Recommendation__c, Candidate__c, Additional_Notes__c,CreatedDate, 
    			Interview_1__c,
    			Interview_2__c,
    			Interview_3__c
    			From Interview_Feedback__c Where  Candidate__c IN : candidateIdSet order by CreatedDate desc];
	}    


}