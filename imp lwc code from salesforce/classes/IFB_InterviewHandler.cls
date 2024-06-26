public with sharing class IFB_InterviewHandler {
    public final String STATUS_NEW = 'New';
    public final String STATUS_FEEDBACK_SUBMITTED = 'Feedback submitted';

    List<IFB_Interview__c> statusToNew = new List<IFB_Interview__c>();
    List<IFB_Interview__c> statusToFeedbackSubmitted = new List<IFB_Interview__c>();

    List<IFB_Interview__Share> interviewSharesToInsert = new List<IFB_Interview__Share>();
    List<IFB_Interview__Share> interviewSharesToDelete = new List<IFB_Interview__Share>();
    List<IFB_Interview_Candidate__Share> interviewCandidateSharesToInsert =  new List<IFB_Interview_Candidate__Share>();
    List<IFB_Interview_Candidate__Share> interviewCandidateSharesToDelete =  new List<IFB_Interview_Candidate__Share>();

    public IFB_InterviewOps ops;
    public IFB_InterviewOpsWos opsWos;
    
    public IFB_InterviewHandler(IFB_InterviewOps ops, IFB_InterviewOpsWos opsWos) {
        this.ops = ops;
        this.opsWos = opsWos;
    }
    

    public void segregateRecordsByStatus(List<IFB_Interview__c> interviews, Map<Id, IFB_Interview__c> oldInterviews) {          
        for (IFB_Interview__c newRecord : interviews) {
            IFB_Interview__c oldRecord = (oldInterviews != null && oldInterviews.containsKey(newRecord.Id)) ? oldInterviews.get(newRecord.Id) : null;
            
            // Interviews that transitioned to the 'New' status
            if (newRecord.Status__c == STATUS_NEW  && (oldRecord == null || oldRecord.Status__c != STATUS_NEW)) {
                statusToNew.add(newRecord);
            }

            // Interviews that transitioned to the 'Feedback submitted' status
            else if (newRecord.Status__c == STATUS_FEEDBACK_SUBMITTED  && (oldRecord == null || oldRecord.Status__c != STATUS_FEEDBACK_SUBMITTED)) {
                statusToFeedbackSubmitted.add(newRecord);
            }           
        }
    }
    
    // W-3438909 - KiranKumar - 12/9/2016 - Added method which will update Scheduled_Interview_Date__c
    public void onInsertUpdateInterview(List<IFB_Interview__c> interviews, Map<Id, IFB_Interview__c> oldInterviews){
        List<IFB_Interview__c> lstUpdate = new  List<IFB_Interview__c>();
        for (IFB_Interview__c newRecord : interviews) {
            IFB_Interview__c oldRecord = (oldInterviews != null && oldInterviews.containsKey(newRecord.Id)) ? oldInterviews.get(newRecord.Id) : null;
            if(newRecord.Scheduled_Interview_Date_only__c != null && oldRecord == null){
                lstUpdate.add(newRecord);     
            }
            
            if(oldRecord != null && newRecord.Scheduled_Interview_Date_only__c != oldRecord.Scheduled_Interview_Date_only__c){
                lstUpdate.add(newRecord);
            }

            // Time Zone
            if(newRecord.Time_Zone__c != null && oldRecord == null){
                lstUpdate.add(newRecord);     
            }
            
            if(oldRecord != null && newRecord.Time_Zone__c != oldRecord.Time_Zone__c){
                lstUpdate.add(newRecord);
            }

            // Interview Start Time
            if(newRecord.Interview_Start_Time__c != null && oldRecord == null){
                lstUpdate.add(newRecord);     
            }
            
            if(oldRecord != null && newRecord.Interview_Start_Time__c != oldRecord.Interview_Start_Time__c){
                lstUpdate.add(newRecord);
            }
        }
        if (lstUpdate.size() > 0){
            updateschedudDateTime(lstUpdate);    
        }
    }
    
    public void updateschedudDateTime(List<IFB_Interview__c> interviews){
        Date schDate;
        //DateTime schTime;
        for (IFB_Interview__c newRecord : interviews) {
            if(newRecord.Scheduled_Interview_Date_only__c != null){
                
                schDate = newRecord.Scheduled_Interview_Date_only__c;
                
                try {

                IFB_IDateTimeGenerator dtGenerator = new IFB_DateTimeGenerator();
                newRecord.Scheduled_Interview_Date__c = dtGenerator.newInstanceTimeZone(schDate.year(),
                                                                                        schDate.month(),
                                                                                        schDate.day(),
                                                                                        newRecord.Interview_Start_Time__c,
                                                                                        newRecord.Time_Zone__c);

                } catch(Exception ex) {
                    if (SIFT_Settings__c.getInstance().Ignore_Interview_Start_Time_Exceptions__c == 'YES') {
                        // In case of any unexpected exception interpreting the Time String/Time Zone, set the time of midnight that day.
                        newRecord.Scheduled_Interview_Date__c = DateTime.newInstance(schDate.year(),schDate.month(),schDate.day());   
                        newRecord.Scheduled_Interview_Date__c = DateTime.newInstance(newRecord.Scheduled_Interview_Date__c.date(), System.Now().time());
                    } else {
                        throw ex;
                    }               
                }
                
                newRecord.Actual_Interview_Date__c = newRecord.Scheduled_Interview_Date__c;

            }
            else{
                newRecord.Scheduled_Interview_Date__c = null;
                newRecord.Actual_Interview_Date__c = null;     
            }
        }
    }
    // W-3438909 - KiranKumar - 12/9/2016 - Added method which will update Scheduled_Interview_Date__c
    

    public void handleStatusToNew() {
        // Remove all 'Panel Interview' access to interview.
        interviewSharesToDelete.addAll(this.opsWos.unshareInterviewOtherInterviewerRead(statusToNew));

        // Remove all 'Interview submitted' access to interview.
        interviewSharesToDelete.addAll(this.opsWos.unshareInterviewInterviewerRead(statusToNew));

        // Remove all 'Interviewer' access to interview.
        interviewSharesToDelete.addAll(this.opsWos.unshareInterviewInterviewerEdit(statusToNew));
        
        // Add 'Interviewer' access to interview.
        interviewSharesToInsert.addAll(this.ops.shareInterviewInterviewerEdit(statusToNew));

        // Grant 'Interviewer' access to recruit.
        interviewCandidateSharesToInsert.addAll(this.ops.shareInterviewCandidateInterviewerRead(statusToNew));

        // TODO: Recalculate 'Panel Interview' access for the current interviewers?
    }

    public void handlesStatusToFeedbackSubmitted() {
        // Remove all 'Interviewer' access to interview.
        interviewSharesToDelete.addAll(this.opsWos.unshareInterviewInterviewerEdit(statusToFeedbackSubmitted));

        // Add 'Interviewer submitted' access to interview.
        interviewSharesToInsert.addAll(this.ops.shareInterviewInterviewerRead(statusToFeedbackSubmitted));

        // Add 'Panel Interview' access for the other interviewers
        interviewSharesToInsert.addAll(this.ops.shareInterviewOtherInterviewerRead(statusToFeedbackSubmitted));

        // Add 'Panel Interview' access for current interviewers
        interviewSharesToInsert.addAll(this.ops.shareOtherInterviewsInterviewerRead(statusToFeedbackSubmitted));    
    }

    public void insertInterviewShares() {
        this.opsWos.insertInterviewShares(interviewSharesToInsert);
    }

    public void deleteInterviewShares() {
        this.opsWos.deleteInterviewShares(interviewSharesToDelete);
    }

    public void insertInterviewCandidateShares() {
        this.opsWos.insertInterviewCandidateShares(interviewCandidateSharesToInsert);
    }

    public void deleteInterviewCandidateShares() {
        this.opsWos.deleteInterviewCandidateShares(interviewCandidateSharesToDelete);
    }
}