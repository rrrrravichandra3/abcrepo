/**
* @author Apuroop Gadde
* @date 07-20-2017
* @group Util Classes
* @description Util class to share Job Reqs and their related application with Hiring Managers listed on the Job Req.
*/

public class IFB_WDShareJobsAndAppsWithHM implements Queueable{
    @testVisible private Map<Id,SObject> mapOfJobs;
    @testVisible private boolean isInsert = false;
    @testVisible private Set<Id> hiringManagers;
    @testVisible private String insertOrDeleteErrors;
    @testVisible private Integer noOfErrors;
    /**
* @description Constructor that initializes the map of jobs that needs to be shared with their respective HMs.
* @param triggerNewMap Map of jobs which need to be shared with the hiring manager.
* @param isInsert boolean flag which says if it is an insert or not.
**/ 
    public IFB_WDShareJobsAndAppsWithHM(Map<Id,SObject> triggerNewMap, boolean isInsert){
        this.hiringManagers = new Set<Id>();
        this.insertOrDeleteErrors = '';
        this.noOfErrors = 0;    
        if(triggerNewMap == null) {
            this.mapOfJobs = new Map<Id,SObject>();
            return;
        }
        this.mapOfJobs = triggerNewMap;
        this.isInsert = isInsert;
    }
    
    /**
* @description Execute method for Queueable interface
* @param context QueueableContext
**/
    public void execute(QueueableContext context) {
        shareJobsAndRelatedApplicationsWithHMs();
        if(noOfErrors != 0) {
            String errorFileDesc = 'Errors that occurred when inserting or deleting Share objects or Permsets for Hiring Manager';   
            String errorFileTitle = 'Errors on inserting or deleting Share Objects and PermSets ' + System.now().format('yyyymmddhhmmss');
            IFB_WDUtils.mailErrors(insertOrDeleteErrors,errorFileDesc,errorFileTitle);
        }
        if(hiringManagers.size() != 0 && Test.isRunningTest() == false) {
            System.enqueueJob(new IFB_WDAssignPermSetsToHMs(hiringManagers));
        }
    }
    
    /**
* @description This method is used to share the jobs and related applications with the hiring manager.
* @param triggerNewMap Map of all the jobs the need to be shared
* @param isInsert Determines if the function is being called from an insert or update trigger.
**/
    private void shareJobsAndRelatedApplicationsWithHMs() {
        if(isInsert == false) {
            deleteExistingSharingsForJobsAndRelatedApplications();
        }
        
        List<WDR_Job__share> sharesForJobs = new List<WDR_Job__share>();
        for(SObject objectToShare : mapOfJobs.values()) {
            WDR_Job__c jobToShare = (WDR_Job__c) objectToShare;
            if(jobToShare.Hiring_Manager__c != null && String.isNotBlank(jobToShare.Hiring_Manager__c)) {
                WDR_Job__share shareForJob = new WDR_Job__share();
                shareForJob.ParentId = jobToShare.Id;
                shareForJob.UserOrGroupId = jobToShare.Hiring_Manager__c;
                shareForJob.AccessLevel = 'Read';
                shareForJob.RowCause = Schema.WDR_Job__share.RowCause.Hiring_Manager__c;
                sharesForJobs.add(shareForJob);
                hiringManagers.add(jobToShare.Hiring_Manager__c);
            }
        }
        
        if(sharesForJobs != null && sharesForJobs.size() != 0) {
            List<Database.SaveResult> jobShareSaveResults = Database.insert(sharesForJobs,false);
            for(Integer i =0;i< jobShareSaveResults.size();i++) {
                if(jobShareSaveResults[i].isSuccess() == false) {
                    noOfErrors++;
                    insertOrDeleteErrors = insertOrDeleteErrors + 'Inserting WD Job Req Share for Job with Id :'+ sharesForJobs[i].ParentId + ' failed with error: \n';
                    for(Database.Error error : jobShareSaveResults[i].getErrors()) {
                        insertOrDeleteErrors = insertOrDeleteErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                    }
                }
            }
        }
        
        //If this is a job insert, no need to check for applications as there will be no applications on there
        if(isInsert == true) {
            return;
        }
        
        List<WDR_Application__share> sharesForApplications = new List<WDR_Application__share>();        
        for(WDR_Application__c relatedApplication : [SELECT Id,Job__r.Hiring_Manager__c FROM WDR_Application__c WHERE Job__c IN : mapOfJobs.keySet()]) {
            sharesForApplications.add(IFB_WDUtils.createShareForApplication(relatedApplication));
        }
        
        if(sharesForApplications != null && sharesForApplications.size() != 0) {
            List<Database.SaveResult> applicationShareSaveResults = Database.insert(sharesForApplications,false);
            for(Integer i =0;i< applicationShareSaveResults.size();i++) {
                if(applicationShareSaveResults[i].isSuccess() == false) {
                    noOfErrors++;
                    insertOrDeleteErrors = insertOrDeleteErrors + 'Inserting WD Job Application share for Application with Id :'+ sharesForApplications[i].ParentId + ' failed with error: \n';
                    for(Database.Error error : applicationShareSaveResults[i].getErrors()) {
                        insertOrDeleteErrors = insertOrDeleteErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                    }
                }
            }            
        } 
    }
    
    /**
* @description Deletes the existing sharing rules on WD Job Requisition and the related WD Job Applications
**/
    private void deleteExistingSharingsForJobsAndRelatedApplications() {
        List<WDR_Job__share> sharesForJobsToBeDeleted = [SELECT Id FROM WDR_Job__share WHERE ParentId IN: mapOfJobs.keySet() 
                                                         AND RowCause = :Schema.WDR_Job__share.RowCause.Hiring_Manager__c];
        if(sharesForJobsToBeDeleted != null && !sharesForJobsToBeDeleted.isEmpty()) {
            List<Database.DeleteResult> jobDeleteResults = Database.delete(sharesForJobsToBeDeleted,false);
            for(Integer i =0;i< jobDeleteResults.size();i++) {
                if(jobDeleteResults[i].isSuccess() == false) {
                    noOfErrors++;
                    insertOrDeleteErrors = insertOrDeleteErrors + 'Deleting WD Job Req share with Id :'+ sharesForJobsToBeDeleted[i].Id + ' failed with error: \n';
                    for(Database.Error error : jobDeleteResults[i].getErrors()) {
                        insertOrDeleteErrors = insertOrDeleteErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                    }
                }
            }  
        }
        List<WDR_Application__share> sharesForApplicationsToBeDeleted = [SELECT Id FROM WDR_Application__share WHERE ParentId 
                                                                         IN (SELECT Id FROM WDR_Application__c WHERE Job__c in :mapOfJobs.keySet() ) 
                                                                         AND RowCause = :Schema.WDR_Application__share.RowCause.Hiring_Manager__c];  
        if(sharesForApplicationsToBeDeleted != null && !sharesForApplicationsToBeDeleted.isEmpty()) {
            List<Database.DeleteResult> applicationDeleteResults = Database.delete(sharesForApplicationsToBeDeleted,false);
            for(Integer i =0;i< applicationDeleteResults.size();i++) {
                if(applicationDeleteResults[i].isSuccess() == false) {
                    noOfErrors++;
                    insertOrDeleteErrors = insertOrDeleteErrors + 'Deleting WD Job Application share with Id :'+ sharesForApplicationsToBeDeleted[i].Id + ' failed with error: \n';
                    for(Database.Error error : applicationDeleteResults[i].getErrors()) {
                        insertOrDeleteErrors = insertOrDeleteErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                    }
                }
            }  
        }
    }
}