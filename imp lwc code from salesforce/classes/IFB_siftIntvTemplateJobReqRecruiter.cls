public class IFB_siftIntvTemplateJobReqRecruiter{
    public Id siftInterviewId {get; set;}
    public String jobReqRecruiter{set; get{
        if(siftInterviewId==null){
            return '';
        }
        List<IFB_Interview__c> interviews = [Select Id, 
                                            Candidate__r.Job_Application_WDR__r.Internal_Candidate__c , 
                                            Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_1__c,
                                            Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_1__r.Name, 
                                            Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_2__c,
                                            Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_2__r.Name, 
                                            Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_1__c, 
                                            Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_1__r.Name,
                                            Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_2__c,
                                            Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_2__r.Name 
                                            FROM IFB_Interview__c 
                                            WHERE Id = :siftInterviewId];
        if(interviews.isEmpty()){
            return '';
        }
        IFB_Interview__c currentIntv = interviews[0];
        Boolean isCandidateInternal = currentIntv.Candidate__r.Job_Application_WDR__r.Internal_Candidate__c;
        String recruiterName='';
        //if candidate is internal, follow this preference order
        // Int Rec 1 , Int Rec 2, Ext Rec 1, Ext Rec 2
        if(isCandidateInternal){
            if(currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_1__c != null){
                recruiterName = currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_1__r.Name;
            }else if(currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_2__c != null){
                recruiterName = currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_2__r.Name;
            }else if(currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_1__c != null){
                recruiterName = currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_1__r.Name;
            }else if(currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_2__c != null){
                recruiterName = currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_2__r.Name;
            }
        }else{
        //if candidate is external, follow this preference order
        // Ext Rec 1 , Ext Rec 2, Int Rec 1, Int Rec 2  
            if(currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_1__c != null){
                recruiterName = currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_1__r.Name;
            }else if(currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_2__c != null){
                recruiterName = currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.External_Recruiter_2__r.Name;
            }else if(currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_1__c != null){
                recruiterName = currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_1__r.Name;
            }else if(currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_2__c != null){
                recruiterName = currentIntv.Candidate__r.Job_Application_WDR__r.Job__r.Internal_Recruiter_2__r.Name;
            }
        }
        return recruiterName;
    }}
}