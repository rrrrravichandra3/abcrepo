/**
* @author Apuroop Gadde
* @date 07-09-2017
* @group TriggerHandlerUtils
* @description Handles Interview updates when WDR proxy objects are updated.
*/
public class IFB_WDJobToSIFTInterview implements Queueable {
    @TestVisible private Set<Id> listWDJobIds;
    @TestVisible private DateTime syncDateTime;
    @TestVisible private List<IFB_Interview__c> relatedInterviewsToJob;
    @TestVisible private List<IFB_Interview__c> interviewsToBeUpdated ;

    /**
    * @description Constructor that initializes the Ids of jobs 
    * @param inWdJobIds Ids of jobs whose related interviews need to be updated.
    **/ 
    public IFB_WDJobToSIFTInterview(Set<Id> inWdJobIds){
        this.relatedInterviewsToJob = new List<IFB_Interview__c>();
        this.interviewsToBeUpdated = new List<IFB_Interview__c>();
        if(inWdJobIds != null) {
            this.listWDJobIds = inWdJobIds;
        }
        else {
            this.listWDJobIds = new Set<Id>();
        }
    }
    
    /**
    * @description Execute method for Queueable interface
    * @param context QueueableContext
    **/
    public void execute(QueueableContext context) {
        queryRelatedInterviews();
        
        if(relatedInterviewsToJob.size() != 0) {
            updateInterviews();
        }
        
        if(interviewsToBeUpdated.size() != 0) {
            commitInterviewChanges();
        }
    }

    /**
    * @description This method queries the interviews that are related to the jobs that have been updated.
    **/
    private void queryRelatedInterviews() {
        List<IFB_Interview_Candidate__c> relatedRecruitsToJob = [SELECT Id from IFB_Interview_Candidate__c where Job_Application_WDR__c in
                                                                (SELECT Id from WDR_Application__c WHERE Job__c in :listWDJobIds AND 
                                                                Candidate_Stage__c NOT IN :IFB_WDUtils.getValuesForCustomSetting('Post_Placement_Candidate_Stages__c')
                                                                AND Candidate_Stage__c NOT IN :IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Offer_Status__c')
                                                                AND Candidate_Stage__c NOT IN :IFB_WDUtils.getValuesForCustomSetting('WDR_Rejected_Candidate_Stages__c'))];
        relatedInterviewsToJob = [SELECT Id, Candidate__r.Job_Application_WDR__r.Job__c, Candidate__r.Job_Application_WDR__r.Job__r.Hiring_Manager__c,Hiring_Manager__c,
                                  Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_1__c, Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_2__c,
                                  Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_1__c,Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_2__c,Recruiter__c , Candidate__r.Job_Application_WDR__r.Internal_Candidate__c
                                  FROM IFB_Interview__c 
                                  WHERE Candidate__c in :relatedRecruitsToJob
                                  AND Status__c IN :IFB_WDUtils.getValuesForCustomSetting('Interview_Sync_Status__c')];
    }

    /**
    * @description This method updates the fields on interviews from WD Job Requisition ,if they have been updated on the WD Job Req.
    **/
    private void updateInterviews() {
        Boolean areFieldsUpdateable = true;
        for(IFB_Interview__c relatedInterview : relatedInterviewsToJob) {
            /*
            Role: Recruiter
            Permission Set Name: IFB RECRUITER-RECRUITER
            IFB_Interview__c.Recruiter__c -> Is Editable in Permission Set?: NO
            IFB_Interview__c.Hiring_Manager__c -> Is Editable in Permission Set?: NO
            */
            relatedInterview.Hiring_Manager__c = relatedInterview.Candidate__r.Job_Application_WDR__r.Job__r.Hiring_Manager__c;
            relatedInterview.Recruiter__c = IFB_InterviewUtils.getRecruiterforInterview(relatedInterview.Candidate__r.Job_Application_WDR__r.Internal_Candidate__c,relatedInterview.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_1__c,relatedInterview.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_2__c,relatedInterview.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_1__c,relatedInterview.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_2__c);
            interviewsToBeUpdated.add(relatedInterview);
        }
    }

    /**
    * @description Update the interviews to the org and log errors.
    **/
    private void commitInterviewChanges() {
        String interviewUpdateErrors = 'Below are the errors while updating interviews from WDR objects:\n';
        String errorFileDesc = 'Errors that occurred when updating SIFT Interviews through WD Job Integration';   
        String errorFileTitle = 'Errors on SIFT Interviews Update ON WD JOB Integration ' + System.now().format('yyyymmddhhmmss'); 
        Integer noOfErrors = 0;
        List<Database.SaveResult> updateResults = Database.update(interviewsToBeUpdated,false);
        for(Integer i =0;i< interviewsToBeUpdated.size();i++) {
            if(updateResults[i].isSuccess() == false) {
                noOfErrors++;
                interviewUpdateErrors = interviewUpdateErrors + 'Interview with Id :'+ interviewsToBeUpdated[i].Id + ' failed when updating job with id:'+
                                            interviewsToBeUpdated[i].Candidate__r.Job_Application_WDR__r.Job__c;
                interviewUpdateErrors = interviewUpdateErrors + '\n';
                for(Database.Error error : updateResults[i].getErrors()) {
                    interviewUpdateErrors = interviewUpdateErrors + error.getStatusCode()+':'+error.getMessage()+ '\n';
                }
            }
        }
        if(noOfErrors > 0) {
            IFB_WDUtils.mailErrors(interviewUpdateErrors,errorFileDesc,errorFileTitle);
        }
    }
}