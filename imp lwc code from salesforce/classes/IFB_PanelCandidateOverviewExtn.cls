/*
* This class can be without sharing
* In the code, we have a custom logic to check if current user should be able to see data of other interviews or not
*/
public without sharing class IFB_PanelCandidateOverviewExtn 
{
    private final Boolean iAmRecruiter;
    private final Boolean iAmManager;
    private final Boolean iAmInterviewer;
    private final Boolean iHaveSubmittedMyFeedback;

    public class InterviewWithEvaluations
    {
        private IFB_Interview__c interview;
        private string interviewType;
        private List<IFB_Interview_Evaluation__c> interviewEvaluations;
        
        public InterviewWithEvaluations(IFB_Interview__c interview)
        {
            this.interview = interview;
            interviewType = loadInterviewType();
        }
        
        public IFB_Interview__c getInterview()
        {
            return interview;
        }
        
        public string getInterviewType() {
            return interviewType;
        }
        
        public string loadInterviewType()
        {
            if(interviewType == null)
            {
                interviewType = interview.Interview_Type__r.Name;
            }
            return interviewType;
        }
        
        public List<IFB_Interview_Evaluation__c> getInterviewEvaluations()
        {
            if(interviewEvaluations == null)
            {
                interviewEvaluations = [select Id, Interview_Question__r.Competency__c, Interview_Question__r.Question__c, Score__c, Rating__c, Comments__c, Interview_Question__r.Sort_Order__c, Interview_Question__r.Japan_Question__c, Interview_Question__r.Japan_Domain__c
                                        from IFB_Interview_Evaluation__c
                                        where Interview__c =: interview.Id
                                        order by Interview_Question__r.Sort_Order__c, Interview_Question__r.Competency__c nulls last];
            }
            return interviewEvaluations;
        }
    }
    
    private IFB_Interview_Candidate__c interviewCandidate;
    private List<InterviewWithEvaluations> allInterviews;
    private Id lastInterviewId;
    private Id interviewCandidateId;
    
    public IFB_PanelCandidateOverviewExtn() {}
    
    public Boolean getHasAccessToInterviewDetails() {
        return (iAmRecruiter || iAmManager || (iAmInterviewer && iHaveSubmittedMyFeedback));
    }


    public IFB_PanelCandidateOverviewExtn(ApexPages.StandardController stdController) 
    {
        interviewCandidate = (IFB_Interview_Candidate__c)stdController.getRecord();
        interviewCandidateId = interviewCandidate.Id;
        
        Boolean iAmManager = false;
        Boolean iHaveSubmittedMyFeedback = false;
        Boolean iAmInterviewer = false;
        
        List<UserRecordAccess> recordAccess = [select RecordId from UserRecordAccess
                                               where hasEditAccess = true
                                               and UserId = :UserInfo.getUserId()
                                               and RecordId = :interviewCandidateId];

        List<GroupMember> memberOfRecruitingGroup = [select Id from GroupMember
                                                     where UserOrGroupId = :UserInfo.getUserId()
                                                     and Group.DeveloperName = 'SIFT_Recruiting'];



        this.iAmRecruiter = (!recordAccess.isEmpty() || !memberOfRecruitingGroup.isEmpty());


        List<IFB_Interview_Candidate__Share> shares = [select RowCause FROM
            IFB_Interview_Candidate__Share WHERE ParentId = :interviewCandidateId AND UserOrGroupId = :UserInfo.getUserId()];

        for(IFB_Interview_Candidate__Share share:shares){
            if(share.RowCause == Schema.IFB_Interview_Candidate__Share.RowCause.Hiring_Manager__c ||
                share.RowCause == Schema.IFB_Interview_Candidate__Share.RowCause.Hiring_Organization__c){
                iAmManager = true;
            }else if(share.RowCause == Schema.IFB_Interview_Candidate__Share.RowCause.Interviewer__c
                || share.RowCause == Schema.IFB_Interview_Candidate__Share.RowCause.Panel_Interviewer__c){
                iAmInterviewer = true;
            }
        }

        if(iAmInterviewer){

            List<IFB_Interview__c> interviews = [select Id, Hiring_Manager__c, Status__c from IFB_Interview__c
                                                 where Candidate__c = :interviewCandidateId
                                                 and (
                                                     Interviewer__c = :UserInfo.getUserId() or
                                                     Interviewer2__c = :UserInfo.getUserId() or
                                                     Interviewer3__c = :UserInfo.getUserId() or
                                                     Interviewer4__c = :UserInfo.getUserId() or
                                                     Interviewer5__c = :UserInfo.getUserId())];

            for(IFB_Interview__c interview:interviews){
                if(interview.Status__c == 'Feedback submitted'){
                    iHaveSubmittedMyFeedback = true;
                    break;
                }
            }
        }
        
        this.iAmManager = iAmManager;
        this.iHaveSubmittedMyFeedback = iHaveSubmittedMyFeedback;
        this.iAmInterviewer = iAmInterviewer;
    }

    private IFB_PanelCandidateOverviewExtn(Id icId)
    {
        interviewCandidateId = icId;
    }
    
    public List<InterviewWithEvaluations> getAllInterviews()
    {
        if(allInterviews == null)
        {
            allInterviews = new List<InterviewWithEvaluations>();

            List<IFB_Interview__c> interviews;

            if(iAmRecruiter || iAmManager){
                interviews = [select Id, Actual_Interview_Date__c, Interviewer__r.Name, Interview_Type__r.Name, Comments__c, Recommendation__c, Overall_Interview_Score__c, Overall_Interview_Rating__c, RecordTypeId, Status__c, Interview_Language__c
                                         from IFB_Interview__c
                                         where Candidate__c =: interviewCandidateId
                                         order by LastModifiedDate desc];
            }else if(iAmInterviewer && iHaveSubmittedMyFeedback){
                interviews = [select Id, Actual_Interview_Date__c, Interviewer__r.Name, Interview_Type__r.Name, Comments__c, Recommendation__c, Overall_Interview_Score__c, Overall_Interview_Rating__c, RecordTypeId, Status__c, Interview_Language__c
                                         from IFB_Interview__c
                                         where Candidate__c =: interviewCandidateId AND Status__c = 'Feedback submitted'
                                         order by LastModifiedDate desc];
            }

            for(IFB_Interview__c interview: interviews){
                allInterviews.add(new InterviewWithEvaluations(interview));   
            }
        }
        return allInterviews;
    }
    
    public boolean getHasInterviews() {
        return getAllInterviews().size() > 0;
    }
    
    public Id getLastInterviewId()
    {
        return getAllInterviews().get(getAllInterviews().size() - 1).Interview.Id;
    }
    
    @RemoteAction
    public static List<InterviewWithEvaluations> getAllInterviewsForId(Id interviewCandidateId) 
    {
        return new IFB_PanelCandidateOverviewExtn(interviewCandidateId).getAllInterviews();
    }
}