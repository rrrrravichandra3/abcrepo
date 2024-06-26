/**
* @author Apuroop Gadde
* @date 06-22-2017
* @group TriggerHandlers
* @description Trigger handler for the WDR_Job object that handles the trigger events on Integration sync from the SIFT side 
*/
public with sharing class IFB_WDJobSyncTriggerHandler implements WDR_CommonTriggerHandler{
    /**
    * @description Constructor for the class
    **/
    public IFB_WDJobSyncTriggerHandler() {
    
    }

    /**
    * @description Method to propogate changes to SIFT objects on the before insert event of the WDR_Job object 
    **/
    public void beforeInsert() {

    }

    /**
    * @description Method to propogate changes to SIFT objects on the after insert event of the WDR_Job object 
    **/
    public void afterInsert() {
        System.enqueueJob(new IFB_WDShareJobsAndAppsWithHM(Trigger.newMap,true));
    }

    /**
    * @description Method to propogate changes to SIFT objects on the before update event of the WDR_Job object 
    **/
    public void beforeUpdate(){

    }

    /**
    * @description Method to propogate changes to SIFT objects on the after update event of the WDR_Job object 
    **/
    public void afterUpdate() {
       this.updateRecruiters(Trigger.oldMap,Trigger.newMap);
        this.shareJobsWithHMsIfHMChanged();
        this.kickOffRelatedRecruitsUpdate();
        this.kickOffRelatedInterviewsUpdate();
    }

    /**
    * @description Method to propogate changes to SIFT objects on the before delete event of the WDR_Job object 
    **/
    public void beforeDelete() {
        preventDelete(Trigger.old);
    }

    /**
    * @description Method to propogate changes to SIFT objects on the after delete event of the WDR_Job object
    **/
    public void afterDelete() {
        
    }

    /**
    * @description Method to propogate changes to SIFT objects on the after undelete event of the WDR_Job object
    **/
    public void afterUnDelete() {
    
    }

    /**
    * @description Method to kickoff the update of related recruits update.
    **/
    private void kickOffRelatedRecruitsUpdate() {
        Set<Id> uniqueApplicationIds = new Set<Id>();
        List<Id> idsOfJobswithRecruitFieldsChange = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(Trigger.newMap,Trigger.oldMap,
                                                                WDR_Job__c.sObjectType,IFB_Interview_Candidate__c.sObjectType);  
        List<WDR_Application__c> relatedApplications = [SELECT Id FROM WDR_Application__c WHERE Job__c in :idsOfJobswithRecruitFieldsChange
                                                        AND Candidate_Stage__c NOT IN :IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Offer_Status__c')
                                                        AND Candidate_Stage__c NOT IN :IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Candidate_Stages__c')];
        for(WDR_Application__c relatedApp : relatedApplications) {
            uniqueApplicationIds.add(relatedApp.Id);
        }
        if(uniqueApplicationIds.size() != 0) {
            ID recruitUpdateQueueID = System.enqueueJob(new IFB_WDApplicationToSIFTRecruit(uniqueApplicationIds,WDR_Job__c.sObjectType));
        }
    }

    /**
    * @description Method to kickoff the update of related interviews update.
    **/
    private void kickOffRelatedInterviewsUpdate() {
        SET<Id> uniqueJobIds = new Set<Id>();
        List<Id> idsOfJobswithSIFTInterviewFieldsChange = IFB_WDUtils.getIdsOfSObjectswithFieldsChange(Trigger.newMap,Trigger.oldMap,
                                                                WDR_Job__c.sObjectType,IFB_Interview__c.sObjectType);
        uniqueJobIds.addAll(idsOfJobswithSIFTInterviewFieldsChange);
        System.enqueueJob(new IFB_WDJobToSIFTInterview(uniqueJobIds));
    }

    /**
    * @description Method to share jobs to the updated HMs, if the HM on the job has been updated.
    **/
    private void shareJobsWithHMsIfHMChanged() {
        Map<Id,SObject> jobsWithHMChanges = new Map<Id,Sobject>(); 
        for(Id jobId : Trigger.newMap.keySet()) {
            if(Trigger.newMap.get(jobId).get('Hiring_Manager__c') != Trigger.oldMap.get(jobId).get('Hiring_Manager__c')) {
                jobsWithHMChanges.put(jobId,Trigger.newMap.get(jobId));
            }
        }
        if(jobsWithHMChanges.keySet().size()!= 0) {
            System.enqueueJob(new IFB_WDShareJobsAndAppsWithHM(jobsWithHMChanges,false));
        }
    }

    /** @description method to update recruiters on Wd Job Applications */
    public void updateRecruiters(Map<Id,sObject> oldMap, Map<Id,sObject> newMap){

       // Map<Id,List<WDR_Application__c>> jobRequisitionToApplicationsMap = new Map<Id,List<WDR_Application__c>>();
        Map<Id,WDR_Job__c> requisitionMap = new Map<Id,WDR_Job__c>();
        List<WDR_Application__c> jobApplicationList = new List<WDR_Application__c>();
        /*
        for(WDR_Application__c wdapplication : [Select Id,Job__c,External_Recruiter_1__c,SIFT_Group_Lookup__c,SIFT_Position_Lookup__c,Is_this_a_SIFT_Interview__c,Candidate_Stage__c from WDR_Application__c where Job__c IN : newMap.keySet()]){

            if(!jobRequisitionToApplicationsMap.containskey(wdapplication.Job__c))
                jobRequisitionToApplicationsMap.put(wdapplication.Job__c,new List<WDR_Application__c>());   

            jobRequisitionToApplicationsMap.get(wdapplication.Job__c).add(wdapplication);    

        }*/

        for(sObject obj : newMap.values()){

            WDR_Job__c oldRequisition = (WDR_Job__c)oldMap.get(obj.Id);
            WDR_Job__c newRequisition = (WDR_Job__c)newMap.get(obj.Id);

            if( (oldRequisition.External_Recruiter_1__c != NULL && newRequisition.External_Recruiter_1__c != NULL && oldRequisition.External_Recruiter_1__c != newRequisition.External_Recruiter_1__c) ||
                (oldRequisition.External_Recruiter_1__c == NULL && newRequisition.External_Recruiter_1__c != NULL) ||
                (oldRequisition.External_Recruiter_1__c != NULL && newRequisition.External_Recruiter_1__c == NULL) ||
                (oldRequisition.External_Recruiter_2__c != NULL && newRequisition.External_Recruiter_2__c != NULL && oldRequisition.External_Recruiter_2__c != newRequisition.External_Recruiter_2__c) ||
                (oldRequisition.External_Recruiter_2__c == NULL && newRequisition.External_Recruiter_2__c != NULL) ||
                (oldRequisition.External_Recruiter_2__c != NULL && newRequisition.External_Recruiter_2__c == NULL) ||
                (oldRequisition.Internal_Recruiter_1__c != NULL && newRequisition.Internal_Recruiter_1__c != NULL && oldRequisition.Internal_Recruiter_1__c != newRequisition.Internal_Recruiter_1__c) ||
                (oldRequisition.Internal_Recruiter_1__c == NULL && newRequisition.Internal_Recruiter_1__c != NULL) ||
                (oldRequisition.Internal_Recruiter_1__c != NULL && newRequisition.Internal_Recruiter_1__c == NULL) ||
                (oldRequisition.Internal_Recruiter_2__c != NULL && newRequisition.Internal_Recruiter_2__c != NULL && oldRequisition.Internal_Recruiter_2__c != newRequisition.Internal_Recruiter_2__c) ||
                (oldRequisition.Internal_Recruiter_2__c == NULL && newRequisition.Internal_Recruiter_2__c != NULL) ||
                (oldRequisition.Internal_Recruiter_2__c != NULL && newRequisition.Internal_Recruiter_2__c == NULL) ||
                (newRequisition.SIFT_Group__c != NULL && oldRequisition.SIFT_Group__c != newRequisition.SIFT_Group__c) ||
                (newRequisition.SIFT_Position__c != NULL && oldRequisition.SIFT_Position__c != newRequisition.SIFT_Position__c)
                ){
                    
                    requisitionMap.put(newRequisition.Id,newRequisition);
            }
        }
        //The related Job app Update Logic is moved to Batch class.
		//insert the JRids as  custom setting recs and remove the below.
		List<IFB_JR_Id_For_Sync__c> JRWithUpdatesRecs = new List<IFB_JR_Id_For_Sync__c >();

        try{
            Set<string> ExistingJRIds= IFB_JR_Id_For_Sync__c.getAll().keyset();
            system.debug('ExistingJRIds'+ExistingJRIds);            
            for(Id requisitionId : requisitionMap.keySet()){
                IFB_JR_Id_For_Sync__c  JRWithUpdatesRec = new IFB_JR_Id_For_Sync__c ();
                JRWithUpdatesRec.name = requisitionId;
                if(!ExistingJRIds.contains(requisitionId)){
                   JRWithUpdatesRecs.add(JRWithUpdatesRec);            
                }
       		 }
       	 insert JRWithUpdatesRecs;        
        }catch(Exception ex){
            //Send Email to Eops
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String toAddresses = '';
            system.debug('JRs Inserted'+JRWithUpdatesRecs);
            toAddresses =  IFB_SIFT_Settings_List__c.getOrgDefaults().EmailToCase_Address__c;
                    if(!String.isBlank(toAddresses)){
                        mail.setToAddresses(toAddresses.split(','));
                        mail.setSubject('IFB_WDJobSyncTriggerHandler failed to create Job Req records in Custom Setting ');
                        mail.setPlainTextBody('Exception while inserting Job Req Ids'+ JRWithUpdatesRecs+' in Custom Setting - IFB Job Req Id For Sync' +ex.getMessage()+ ex.getStackTraceString());
                        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
                    }
                
        }
        
        /*

        for(Id requisitionId : requisitionMap.keySet()){

            if(jobRequisitionToApplicationsMap.containsKey(requisitionId)){

                for(WDR_Application__c jobapplication : jobRequisitionToApplicationsMap.get(requisitionId)){

                    jobapplication.External_Recruiter_1__c = requisitionMap.get(requisitionId).External_Recruiter_1__c;
                    jobapplication.External_Recruiter_2__c = requisitionMap.get(requisitionId).External_Recruiter_2__c;
                    jobapplication.Internal_Recruiter_1__c = requisitionMap.get(requisitionId).Internal_Recruiter_1__c;
                    jobapplication.Internal_Recruiter_2__c = requisitionMap.get(requisitionId).Internal_Recruiter_2__c;
                    if(jobapplication.Is_this_a_SIFT_Interview__c=='Yes' && requisitionMap.get(requisitionId).SIFT_Group__c!=null){
                        jobapplication.SIFT_Group_Lookup__c = requisitionMap.get(requisitionId).SIFT_Group__c;
                    } 
                    if(jobapplication.Is_this_a_SIFT_Interview__c=='Yes'&& requisitionMap.get(requisitionId).SIFT_Position__c !=null){
                         jobapplication.SIFT_Position_Lookup__c = requisitionMap.get(requisitionId).SIFT_Position__c;
                    }
                    if(jobapplication.Is_this_a_SIFT_Interview__c!='Yes' && requisitionMap.get(requisitionId).SIFT_Group__c!=null && (jobapplication.Candidate_Stage__c =='Technical Assessment'|| jobapplication.Candidate_Stage__c =='Assessment')){
                        jobapplication.SIFT_Group_Lookup__c = requisitionMap.get(requisitionId).SIFT_Group__c;
                    } 	
                    if(jobapplication.Is_this_a_SIFT_Interview__c!='Yes' && requisitionMap.get(requisitionId).SIFT_Position__c!=null && (jobapplication.Candidate_Stage__c =='Technical Assessment'|| jobapplication.Candidate_Stage__c =='Assessment')){
                        jobapplication.SIFT_Position_Lookup__c = requisitionMap.get(requisitionId).SIFT_Position__c;
                    } 	
                    jobApplicationList.add(jobapplication);

                }
            }
        }

        if(jobApplicationList != NULL && jobApplicationList.size() > 0){
            Database.SaveResult[] updateResult = Database.update(jobApplicationList, false);
            
            for (Database.SaveResult sr : updateResult) {
            
                if (!sr.isSuccess()) {
                    for(Database.Error objErr : sr.getErrors()) {
                        PF_Logger.log('WDR','ERROR',objErr.getMessage(),String.valueof(objErr.getStatusCode()),'Error while updating Recruiter Fields', 'WDR_JobTriggerHandler');
                        NHW_Util.insertNHWLogs();
                    }
                }
            }
        }*/
    }

    //Method to prevent deletion of Job Requistion based on custom permission
    public static void preventDelete(List<WDR_Job__c> oldList){
        if(FeatureManagement.checkPermission('WDR_Not_allowed_to_delete_WD_Job_Requisition')){
            for(WDR_Job__c job : oldList){
                job.addError(System.Label.WDR_Not_allowed_to_delete_WD_Job_Requisition);
            }
        }
    
}
}