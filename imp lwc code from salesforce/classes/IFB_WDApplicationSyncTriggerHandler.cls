/**
* @author Apuroop Gadde
* @date 06-22-2017
* @group TriggerHandlers
* @description Trigger handler for the WDR_Application object that handles the trigger events on Integration sync from the SIFT side 
*/
public with sharing class IFB_WDApplicationSyncTriggerHandler implements WDR_CommonTriggerHandler{
    /**
* @description Constructor for the class
**/
    public IFB_WDApplicationSyncTriggerHandler() {
    }
    
    /**
* @description Method to propogate changes to SIFT objects on the before insert event of the WDR_Application object 
**/
    public void beforeInsert() {
        this.updateRecruiters(Trigger.new);
    }
    
    /**
* @description Method to propogate changes to SIFT objects on the after insert event of the WDR_Application object 
**/
    public void afterInsert() {
        System.enqueueJob(new IFB_WDShareAppsWithHM(Trigger.newMap.keySet(),true));

    }
    
    /**
* @description Method to propogate changes to SIFT objects on the before update event of the WDR_Application object 
**/
    public void beforeUpdate() {
        this.updateGroupAndPosition(Trigger.newMap,Trigger.oldMap);
    }
    
    /**
* @description Method to propogate changes to SIFT objects on the after update event of the WDR_Application object 
**/
    public void afterUpdate() {
        this.kickOffRelatedRecruitsUpdate();
        this.updateHMAccessIfJobChanged();
        this.kickOffRelatedInterviewsUpdate();
    }
    
    /**
* @description Method to propogate changes to SIFT objects on the before delete event of the WDR_Application object
**/
    public void beforeDelete() {
        
    }
    
    /**
* @description Method to propogate changes to SIFT objects on the after delete event of the WDR_Application object
**/
    public void afterDelete() {
        
    }
    
    /**
* @description Method to propogate changes to SIFT objects on the after undelete event of the WDR_Application object
**/
    public void afterUnDelete() {
    }
    
    /**
* @description Method to kickoff the update of related recruits update.
**/
    private void kickOffRelatedRecruitsUpdate() {
        Set<Id> uniqueApplicationIds = new Set<Id>();
        List<Id> idsOfApplicationswithRecruitFieldsChange = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(Trigger.newMap,Trigger.oldMap,
                                                                                                         WDR_Application__c.sObjectType,IFB_Interview_Candidate__c.sObjectType); 
        
        uniqueApplicationIds.addAll(idsOfApplicationswithRecruitFieldsChange);
        for(Id appId : uniqueApplicationIds) {
            if(Trigger.oldMap.get(appId).get('Candidate_Stage__c') != null 
               && (IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Offer_Status__c').contains((String)Trigger.oldMap.get(appId).get('Candidate_Stage__c')) == true 
                   || IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Candidate_Stages__c').contains((String)Trigger.oldMap.get(appId).get('Candidate_Stage__c')) == true) 
               && Trigger.oldMap.get(appId).get('Candidate_Stage__c') == Trigger.newMap.get(appId).get('Candidate_Stage__c')) {
                   uniqueApplicationIds.remove(appId);
               }
        }
        if(uniqueApplicationIds.size() != 0) {
            System.enqueueJob(new IFB_WDApplicationToSIFTRecruit(uniqueApplicationIds,WDR_Application__c.sObjectType));
        }        
    }
    
    /**
* @description This method is to update Hiring manager access to Applications if the job on the application changes.
**/
    private void updateHMAccessIfJobChanged() {
        Map<Id,SObject> applicationsWithJobChanges = new Map<Id,Sobject>(); 
        for(Id appId : Trigger.newMap.keySet()) {
            if(Trigger.newMap.get(appId).get('Job__c') != Trigger.oldMap.get(appId).get('Job__c')) {
                applicationsWithJobChanges.put(appId,Trigger.newMap.get(appId));
            }
        }
        if(applicationsWithJobChanges.size() != 0) {
            System.enqueueJob(new IFB_WDShareAppsWithHM(applicationsWithJobChanges.keySet(),false));
        }
        
    }

    /**
    * @description Method to kickoff the update of related interviews update.
    **/
    private void kickOffRelatedInterviewsUpdate() {
        SET<Id> uniqueJobIds = new Set<Id>();
        List<Id> idsOfJobswithSIFTInterviewFieldsChange = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(Trigger.newMap,Trigger.oldMap,
                                                                WDR_Application__c.sObjectType,IFB_Interview__c.sObjectType);
        uniqueJobIds.addAll(idsOfJobswithSIFTInterviewFieldsChange);
        if(uniqueJobIds.size()!=0){
           System.enqueueJob(new IFB_WDApplicationToSIFTInterview(uniqueJobIds));
        }
    }

    /**
    * @description Method to populate recruiters on Job App
    **/
    public void updateRecruiters(List<sObject> newList){
        Set<Id> jobIds = new Set<Id>();
        List<WDR_Application__c> jobApplicationList = new List<WDR_Application__c>();
        Map<Id,WDR_Job__c> jobRequisitionMap = new Map<Id,WDR_Job__c>();

        for(sObject obj : newList){

            jobApplicationList.add((WDR_Application__c)obj);

        }

        for(WDR_Application__c jobapplication : jobApplicationList){

            jobIds.add(jobapplication.Job__c);

        }

        for(WDR_Job__c jobrequisition : [   Select Id,External_Recruiter_1__c,External_Recruiter_2__c,Internal_Recruiter_1__c,Internal_Recruiter_2__c,SIFT_Group__c,SIFT_Position__c
                                            from WDR_Job__c where Id IN : jobIds]){

            jobRequisitionMap.put(jobrequisition.Id,jobrequisition);

        }

        for(WDR_Application__c application : jobApplicationList){
            if(jobRequisitionMap.get(application.Job__c) != NULL){
                application.External_Recruiter_1__c = jobRequisitionMap.get(application.Job__c).External_Recruiter_1__c;
                application.External_Recruiter_2__c = jobRequisitionMap.get(application.Job__c).External_Recruiter_2__c;
                application.Internal_Recruiter_1__c = jobRequisitionMap.get(application.Job__c).Internal_Recruiter_1__c;
                application.Internal_Recruiter_2__c = jobRequisitionMap.get(application.Job__c).Internal_Recruiter_2__c;
                  if((application.Is_this_a_SIFT_Interview__c == 'Yes' || (application.Candidate_Stage__c == 'Technical Assessment' || application.Candidate_Stage__c == 'Assessment')) && application.SIFT_Group_Lookup__c==null && application.SIFT_Position_Lookup__c==null){
                    if (jobRequisitionMap.get(application.Job__c).SIFT_Group__c!=null) {
                        application.SIFT_Group_Lookup__c = jobRequisitionMap.get(application.Job__c).SIFT_Group__c;
                    }
                    if(jobRequisitionMap.get(application.Job__c).SIFT_Position__c!=null){
                        application.SIFT_Position_Lookup__c = jobRequisitionMap.get(application.Job__c).SIFT_Position__c;
                    } 
                      
                }

            }
        }

    }

    /**
    * @description Method to populate Group and Position on Job App
    **/
     
    public  void updateGroupAndPosition(Map<id,sObject> newMap,Map<Id,sObject> oldMap){

         Set<Id> jobIds = new Set<Id>();
         List<WDR_Application__c> jobApplicationList = new List<WDR_Application__c>();
         List<WDR_Application__c> jobApplicationListToUpdate = new List<WDR_Application__c>();
         Map<Id,WDR_Job__c> jobRequisitionMap = new Map<Id,WDR_Job__c>();
        for(sObject obj : newMap.values()){
            jobApplicationList.add((WDR_Application__c)obj);
        }

         for(WDR_Application__c jobapplication : jobApplicationList){
             WDR_Application__c oldJobApplication = (WDR_Application__c)oldMap.get(jobapplication.Id);
             if((jobapplication.Is_this_a_SIFT_Interview__c == 'Yes' && oldJobApplication.Is_this_a_SIFT_Interview__c != jobapplication.Is_this_a_SIFT_Interview__c) || 
                ((jobapplication.Candidate_Stage__c == 'Technical Assessment' || jobapplication.Candidate_Stage__c == 'Assessment') && oldJobApplication.Candidate_Stage__c != jobapplication.Candidate_Stage__c )){
                 jobIds.add(jobapplication.Job__c);
                jobApplicationListToUpdate.add(jobapplication);
             }
         }
        if(!jobIds.isEmpty()){
          for(WDR_Job__c jobrequisition : [ Select Id,SIFT_Group__c,SIFT_Position__c from WDR_Job__c where Id IN : jobIds]){
                jobRequisitionMap.put(jobrequisition.Id,jobrequisition);
            }

         for(WDR_Application__c application : jobApplicationListToUpdate){
             if(jobRequisitionMap.get(application.Job__c) != NULL){
                 if((application.Is_this_a_SIFT_Interview__c == 'Yes' || (application.Candidate_Stage__c == 'Technical Assessment' || application.Candidate_Stage__c == 'Assessment'))&& application.SIFT_Group_Lookup__c ==null && application.SIFT_Position__c==null){
                        if(jobRequisitionMap.get(application.Job__c).SIFT_Group__c!=null){
                            application.SIFT_Group_Lookup__c = jobRequisitionMap.get(application.Job__c).SIFT_Group__c;
                        }
                        if(jobRequisitionMap.get(application.Job__c).SIFT_Position__c!=null){
                            application.SIFT_Position_Lookup__c = jobRequisitionMap.get(application.Job__c).SIFT_Position__c;
                        }
                 }
             }
         }
        }
    }

}