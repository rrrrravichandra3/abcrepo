/*
* This class needs to be without sharing as lot of behind the scene operations are performed, which require to access all records
* Apex sharing is performed after all the behind the scene operations are performed
*/
global without sharing class IFB_InterviewUtilities 
{
    public static final String STATUS_FEEDBACK_SUBMITTED = 'Feedback submitted';
    public static final String RECOMMENDATION_YES = 'Move Forward/Hire (if final stage)';
    public static final String RECOMMENDATION_NO = 'Do Not Move Forward/Do Not Hire';
    public static final Map<Id, SIFT_Interview_Type__c> interviewTypeIdToRecordMap = new Map<Id,SIFT_Interview_Type__c>([Select Id, Name, SIFT_Group__c, SIFT_Group__r.Name from SIFT_Interview_Type__c]);

    // Get a Map of RecordType for a given object
    public static Map<Id, RecordType> GetRecordTypes(string sObjectName)
    {
        return new Map<Id, RecordType>([select Id, Name, DeveloperName from RecordType where SObjectType =: sObjectname]);
    }
    
    public static void createInterviewEvaluations(List<IFB_Interview__c> interviews, Set<Id> candidateIds)
    {
        Map<String, List<IFB_Interview_Question__c>> questionCache = new Map<String, List<IFB_Interview_Question__c>>();
        List<IFB_Interview_Evaluation__c> interviewEvaluations = new List<IFB_Interview_Evaluation__c>();
        
        Map<Id, IFB_Interview_Candidate__c> positions = new Map<Id, IFB_Interview_Candidate__c>(
            [select Id, SIFT_Position__r.Name from IFB_Interview_Candidate__c where id in :candidateIds]);
    
        for(IFB_Interview__c interview: interviews)
        {
            String position = positions.get(interview.Candidate__c).SIFT_Position__r.Name;
            String interviewType = interviewTypeIdToRecordMap.get(interview.Interview_Type__c).Name;
            String questionCacheKey = position + interviewType;
            
            List<IFB_Interview_Question__c> questions = questionCache.get(questionCacheKey);
            if (questions == null)
            {
                questions = IFB_InterviewQuestionUtilities.getActiveQuestions(position, interviewType);
                questionCache.put(questionCacheKey, questions);
            }
            
            addEvaluationsForInterview(interviewEvaluations, interview, questions);
        }
        
        if(interviewEvaluations.Size() > 0)
        {
            insert interviewEvaluations;
        }
    }

    private static void addEvaluationsForInterview(List<IFB_Interview_Evaluation__c> interviewEvaluations, IFB_Interview__c interview, List<IFB_Interview_Question__c> questions)
    {
        for(IFB_Interview_Question__c question: questions)
        {
            IFB_Interview_Evaluation__c evaluation = new IFB_Interview_Evaluation__c
            (
                Interview__c = interview.Id, 
                Interview_Question__c = question.Id
            );
            interviewEvaluations.add(evaluation);
        }
    }

    public static void RollupInterviewScores(Set<Id> candidateIds)
    {
        Map<Id,IFB_Interview_Candidate__c> candidates = new Map<Id,IFB_Interview_Candidate__c>();
        decimal averageConsultingScore = 0;
        decimal averageTechnicalScore = 0;
        Id lastCandidateId = null;
        IFB_Interview_Candidate__c candidate;
        for(AggregateResult ar: [select Candidate__c, Interview_Type__c, avg(Overall_Interview_Score__c) AverageScore
                                from IFB_Interview__c
                                where Candidate__c in: candidateIds and Interview_Type__r.Id != null
                                group by Candidate__c, Interview_Type__c
                                order by Candidate__c, Interview_Type__c])
        {
            Id currentCandidateId = (Id)ar.get('Candidate__c');
            Id currnetInterviewTypeId = (Id)ar.get('Interview_Type__c');

            String interviewTypeName = interviewTypeIdToRecordMap.get(currnetInterviewTypeId).Name;
            decimal averageScore = (decimal)ar.get('AverageScore');
            if(lastCandidateId != currentCandidateId)
            {
                averageConsultingScore = 0;
                averageTechnicalScore = 0;
                lastCandidateId = currentCandidateId;
                candidates.put(currentCandidateId, new IFB_Interview_Candidate__c(Id = currentCandidateId));
            }

            if(interviewTypeName == 'CSG - Consulting/Second')
            {
                averageConsultingScore = averageScore;
            }
            else if(interviewTypeName == 'CSG - Technical/First')
            {
                averageTechnicalScore = averageScore;
            }
            candidates.get(currentCandidateId).Consulting_Interview_Score__c = averageConsultingScore;
            candidates.get(currentCandidateId).Technical_Interview_Score__c = averageTechnicalScore;
        }

        // Find candidates without any interviews (rare)
        for(Id cId: candidateIds)
        {
            if(!candidates.containsKey(cId))
            {
                candidates.put(cId, new IFB_Interview_Candidate__c(Id = cId, Consulting_Interview_Score__c = 0.0, Technical_Interview_Score__c = 0.0));
            }    
        }

        if(candidates.keySet().size() > 0)
        {
            update candidates.values();
        }
    }
 
    public static void UpdateCandidateStatus(Set<IFB_Interview__c> interviews)
    {
        Map<Id, IFB_Interview_Candidate__c> candidatesMap = new Map<Id, IFB_Interview_Candidate__c>();
        for(IFB_Interview__c intv: interviews)
        {
            if( (intv.Recommendation__c != null) && (intv.Status__c == STATUS_FEEDBACK_SUBMITTED) )
            {
                String interviewType = interviewTypeIdToRecordMap.get(intv.Interview_Type__c).Name;
                IFB_Interview_Candidate__c candidate = candidatesMap.containsKey(intv.Candidate__c) ? candidatesMap.get(intv.Candidate__c) :
                                                    new IFB_Interview_Candidate__c(Id = intv.Candidate__c);
                if(intv.Recommendation__c == RECOMMENDATION_YES && interviewType == 'CSG - Consulting/Second')
                {
                    candidate.Passed_Consulting__c = true;
                }
                else if(intv.Recommendation__c == RECOMMENDATION_YES && interviewType == 'CSG - Technical/First')
                {
                    candidate.Passed_Technical__c = true;
                }
                candidatesMap.put(candidate.Id, candidate);
            }
        }

        if(!candidatesMap.isEmpty())
        {
            update candidatesMap.values();
        }
    }

    public static void AddInterviewShares(Map<Id, IFB_Interview__c> interviewMap)
    {
        List<IFB_Interview__Share> newInterviewShares = new List<IFB_Interview__Share>();
        List<IFB_Interview__Share> oldInterviewShares = [select Id from IFB_Interview__Share
                                                    where ParentId in: interviewMap.keySet() 
                                                    and RowCause =: Schema.IFB_Interview__Share.RowCause.Interviewer__c];
        List<IFB_Interview__Share> oldPanelInterviewShares = new List<IFB_Interview__Share>();                                            
        Map<Id, List<Id>> candidateToPanelInterviewerMap = new Map<Id, List<Id>>();   
        Map<Id, IFB_Interview__c> relatedInterviewMap = new Map<Id, IFB_Interview__c>();  
        Set<Id> candidateID = new Set<Id>();   
        Set<Id> panelInterviewIDs = new Set<Id>();                                    

        for(IFB_Interview__c iv: interviewMap.values())
        {
            if(iv.Interviewer__c != null)
            {
                newInterviewShares.add(new IFB_Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.IFB_Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer__c));                                            
            }
            candidateID.add(iv.Candidate__c);
        }

        // Handle panel Interviewers
        for (IFB_Interview__c iv: [SELECT Id, Candidate__c, Interviewer__c, Interviewer2__c, Interviewer3__c, Interviewer4__c, Interviewer5__c From IFB_Interview__c Where Candidate__c IN:candidateID AND RecordTypeName__c='Panel Interview'])
        {
            List<Id> panelInterviewers = new List<Id>();
            if(iv.Interviewer__c != null)
                panelInterviewers.add(iv.Interviewer__c);
            
            if(iv.Interviewer2__c != null)
            {
                newInterviewShares.add(new IFB_Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.IFB_Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer2__c));
                panelInterviewers.add(iv.Interviewer2__c);
            }    
            if(iv.Interviewer3__c != null)
            {
                newInterviewShares.add(new IFB_Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.IFB_Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer3__c));
                panelInterviewers.add(iv.Interviewer3__c);
            } 
            if(iv.Interviewer4__c != null)
            {
                newInterviewShares.add(new IFB_Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.IFB_Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer4__c));
                panelInterviewers.add(iv.Interviewer4__c);
            } 
            if(iv.Interviewer5__c != null)
            {
                newInterviewShares.add(new IFB_Interview__Share(AccessLevel = 'Edit', ParentId = iv.Id, 
                                                            RowCause = Schema.IFB_Interview__Share.RowCause.Interviewer__c, UserOrGroupId = iv.Interviewer5__c));
                panelInterviewers.add(iv.Interviewer5__c);
            } 
            
            // Add the candidates that has panel Interviews
            candidateToPanelInterviewerMap.put(iv.Candidate__c, panelInterviewers);
            panelInterviewIDs.add(iv.Id);
        }
        
        // Check whether have any panel interview, if yes select the related interviews
        if (!candidateToPanelInterviewerMap.isEmpty())
        {
            relatedInterviewMap = new Map<Id, IFB_Interview__c>([SELECT Id, Candidate__c from IFB_Interview__c where Candidate__c In: candidateToPanelInterviewerMap.keySet() AND Id Not In:panelInterviewIDs]);    
            // Select old Panel Interview Shares
            if (!relatedInterviewMap.isEmpty())   
            {
                oldPanelInterviewShares = [select Id from IFB_Interview__Share
                                           where ParentId in: relatedInterviewMap.keySet() 
                                           and RowCause =: Schema.IFB_Interview__Share.RowCause.Panel_Interviewer__c];
                // Loop through the relatedIDs
                for (IFB_Interview__c iv: relatedInterviewMap.values())
                {
                    // Loop through the Panel Interviewers and add them
                    for (Id panelInterviewer: candidateToPanelInterviewerMap.get(iv.Candidate__c))
                    {
                        newInterviewShares.add(new IFB_Interview__Share(AccessLevel = 'Read', ParentId = iv.Id, 
                                                            RowCause = Schema.IFB_Interview__Share.RowCause.Panel_Interviewer__c, UserOrGroupId = panelInterviewer));    
                    }
                }                          
            }
        }

        if (!oldPanelInterviewShares.isEmpty())
            delete oldPanelInterviewShares;
        delete oldInterviewShares;
        insert newInterviewShares;
    }
    
    public static void RemovePanelInterviewShares(Map<Id, IFB_Interview__c> interviewMap)
    {
        List<IFB_Interview__Share> oldPanelInterviewShares = new List<IFB_Interview__Share>();                                            
        Map<Id, List<Id>> candidateToPanelInterviewerMap = new Map<Id, List<Id>>();   
        Map<Id, IFB_Interview__c> relatedInterviewMap = new Map<Id, IFB_Interview__c>();                                         

        // Handle panel Interviewers
        for (IFB_Interview__c iv: [SELECT Id, Candidate__c, Interviewer__c, Interviewer2__c, Interviewer3__c, Interviewer4__c, Interviewer5__c From IFB_Interview__c Where Id IN:interviewMap.keySet() AND RecordTypeName__c='Panel Interview'])
        {
            List<Id> panelInterviewers = new List<Id>();
            if(iv.Interviewer__c != null)
                panelInterviewers.add(iv.Interviewer__c);
            
            if(iv.Interviewer2__c != null)
            {
                panelInterviewers.add(iv.Interviewer2__c);
            }    
            if(iv.Interviewer3__c != null)
            {
                panelInterviewers.add(iv.Interviewer3__c);
            } 
            if(iv.Interviewer4__c != null)
            {
                panelInterviewers.add(iv.Interviewer4__c);
            } 
            if(iv.Interviewer5__c != null)
            {
                panelInterviewers.add(iv.Interviewer5__c);
            } 
            
            // Add the candidates that has panel Interviews
            candidateToPanelInterviewerMap.put(iv.Candidate__c, panelInterviewers);
        }
        
        // Check whether have any panel interview, if yes select the related interviews
        if (!candidateToPanelInterviewerMap.isEmpty())
        {
            relatedInterviewMap = new Map<Id, IFB_Interview__c>([SELECT Id, Candidate__c from IFB_Interview__c where Candidate__c In: candidateToPanelInterviewerMap.keySet() AND Id Not In:interviewMap.keySet()]);    
            // Select old Panel Interview Shares
            if (!relatedInterviewMap.isEmpty())   
            {
                oldPanelInterviewShares = [select Id from IFB_Interview__Share
                                           where ParentId in: relatedInterviewMap.keySet() 
                                           and RowCause =: Schema.IFB_Interview__Share.RowCause.Panel_Interviewer__c];               
            }
        }

        if (!oldPanelInterviewShares.isEmpty())
            delete oldPanelInterviewShares;
    }

    public static String sanitizeAndreplacePipeWithNewLine(String additionalQuestions) {
      if(additionalQuestions.contains('|')) {
        additionalQuestions = additionalQuestions.remove('\n');
        additionalQuestions = additionalQuestions.replace('|', '\n');
      }
      return additionalQuestions;
    }

    /* method to create Job Req and Job App shares with Interviewers when Interview is created 
    and when interviewer is updated
    */
    @future
    public static void addJobReqJobAppShares(List<Id> InterviewList,Map<Id,Id> newToOldInterviewerMap){
        List<WDR_Job__Share> jobReqstoShare = new List<WDR_Job__Share>();
        List<WDR_Application__Share> jobAppstoShare = new List<WDR_Application__Share>();

        Map<IFB_Interview__c,Id> interviewToJobReqMap = new  Map<IFB_Interview__c,Id>();
        Map<IFB_Interview__c,Id> interviewToJobAppMap = new  Map<IFB_Interview__c,Id>();
        
        //Maps to hold oldInterviewers and ParentId
        Map<Id,Id> jobReqShareRemovalMap = new Map<Id,Id>();
        Map<Id,Id> jobAppShareRemovalMap = new Map<Id,Id>();
       //get job app and job reqs of new/updated interviews
       try{
        Map<Id,IFB_Interview__c> interviewMap = new Map<id,IFB_Interview__c> ([Select Id,Interviewer__c,Candidate__r.Job_Application_WDR__r.Job__c,Candidate__c,Candidate__r.Job_Application_WDR__c from IFB_Interview__c where id=:InterviewList]);
        for(Id iv: interviewMap.keyset()){
            // iterate over interviews to create interviewtoJobApp and interviewtoJobreq maps
            if( iv!=null
                && interviewMap.get(iv).Candidate__c!=null
                && interviewMap.get(iv).Candidate__r.Job_Application_WDR__c!=null
                &&interviewMap.get(iv).Candidate__r.Job_Application_WDR__r.Job__c!=null) 
                {
                    interviewToJobReqMap.put(interviewMap.get(iv),interviewMap.get(iv).Candidate__r.Job_Application_WDR__r.Job__c);
                    interviewToJobAppMap.put(interviewMap.get(iv),interviewMap.get(iv).Candidate__r.Job_Application_WDR__c);
                    //if interviewer is updated to existing interviews add old interviewer and recordid to a map
                    if(newToOldInterviewerMap.get(interviewMap.get(iv).Interviewer__c)!=null){
                        jobReqShareRemovalMap.put(newToOldInterviewerMap.get(interviewMap.get(iv).Interviewer__c),interviewMap.get(iv).Candidate__r.Job_Application_WDR__r.Job__c);
                        jobAppShareRemovalMap.put(newToOldInterviewerMap.get(interviewMap.get(iv).Interviewer__c),interviewMap.get(iv).Candidate__r.Job_Application_WDR__c);
                        //to check and delete job req and Job app share records of old interviewer
                        deleteShareRecords(jobReqShareRemovalMap,jobAppShareRemovalMap,null);
                    }
                }
        }
        //to insert JobRequisition, Job Application and Recruit shares
        if(interviewToJobReqMap.size()>0){
           
            for(IFB_Interview__c iv: interviewToJobReqMap.keyset()){       
                jobReqstoShare.add(new WDR_Job__Share(AccessLevel = 'Read', ParentId = interviewToJobReqMap.get(iv), 
                RowCause = Schema.WDR_Job__Share.RowCause.Interviewer__c, UserOrGroupId = iv.interviewer__c));
                
            }
        }
            if(interviewToJobAppMap.size()>0){ 
                for(IFB_Interview__c iv: interviewToJobAppMap.keyset()){
                
                jobAppstoShare.add(new WDR_Application__Share(AccessLevel = 'Read', ParentId = interviewToJobAppMap.get(iv), 
                RowCause = Schema.WDR_Job__Share.RowCause.Interviewer__c, UserOrGroupId = iv.interviewer__c));
                
            }
        }
           
            if(!jobReqstoShare.isEmpty()){
                insert jobReqstoShare;
            }
            if(!jobAppstoShare.isEmpty()){
                insert jobAppstoShare;
            }   
        }
        catch(Exception e){
            PF_Logger.log('SIFT','ERROR',e.getMessage(), 'Error while inserting Job Req and Job App share records',e.getStackTraceString(), 'IFB_InterviewUtilities');
            NHW_Util.insertNHWLogs();
        }
       
    }
    //to Delete JobRequisition, Job Application shares when inteviewer is updated or removed
    // to check before delete, if there are any other interviews with old interviewer under same Job Req/Job App
    public static void deleteShareRecords (Map<Id,Id> jobReqShareRemovalMap,Map<Id,Id> jobAppShareRemovalMap,List<Id> interviewIds)
    {
        List<WDR_Job__Share> jobReqSharesToDelete = new List<WDR_Job__Share>();
        List<WDR_Application__Share> jobAppSharesToDelete = new List<WDR_Application__Share>();
        try{
        
        if(!jobReqShareRemovalMap.isEmpty()){
            //Map to hold job with list of Interviewers
            Map<id,List<Id>> jobtoInterviewersMap = new Map<id,List<Id>>();
            List<Id> jobReqs = jobReqShareRemovalMap.values();
            String queryString = 'SELECT Id,interviewer__c,Candidate__r.Job_Application_WDR__r.Job__c FROM IFB_Interview__c WHERE Candidate__r.Job_Application_WDR__r.Job__c IN :jobReqs' ;
            //to exclude those interviews if invoked by deleteJobReqJobAppShares method(before delete context)
            if(interviewIds!=null){
                queryString+=' AND Id NOT IN : interviewIds';
            }
            List<IFB_Interview__c> interviews = Database.query(queryString);
            for(IFB_Interview__c interview : interviews){
                if(!jobtoInterviewersMap.containsKey(interview.Candidate__r.Job_Application_WDR__r.Job__c)){
                    jobtoInterviewersMap.put(interview.Candidate__r.Job_Application_WDR__r.Job__c,new List<Id>{Interview.interviewer__c});
                    
                }
                else{
                    jobtoInterviewersMap.get(interview.Candidate__r.Job_Application_WDR__r.Job__c).add(Interview.interviewer__c);
                   
                }

            }
            // for all the job shares of old interviewers
           for(WDR_Job__Share js: [Select id,ParentId,UserOrGroupId from WDR_Job__Share where UserOrGroupId = :jobReqShareRemovalMap.keyset() and RowCause = :Schema.WDR_Job__Share.RowCause.Interviewer__c])
           {
              
               if(js.ParentId == jobReqShareRemovalMap.get(js.UserOrGroupId) ){
                   // check if job has any existing interviews
                   // check if oldinterviewer is part of any existing interviews
                   if(jobtoInterviewersMap.get(js.ParentId)==null ||!jobtoInterviewersMap.get(js.ParentId).contains(js.UserOrGroupId)){
                    jobReqSharesToDelete.add(js);
                   }

               }
           }
        }
        if(!jobAppShareRemovalMap.isEmpty()){
             //Map to hold job app with list of Interviewers
            Map<id,List<Id>> apptoInterviewersMap = new Map<id,List<Id>>();
            List<Id> jobApps = jobReqShareRemovalMap.values();
            String queryString = 'SELECT Id,interviewer__c,Candidate__r.Job_Application_WDR__c FROM IFB_Interview__c WHERE Candidate__r.Job_Application_WDR__c IN :jobApps' ;
            //to exclude interviews if invoked by deleteJobReqJobAppShares method 
            if(interviewIds!=null){
                queryString+=' AND Id NOT IN : interviewIds';
            }
            List<IFB_Interview__c> interviews = Database.query(queryString);
            for(IFB_Interview__c interview : interviews){
                if(!apptoInterviewersMap.containsKey(interview.Candidate__r.Job_Application_WDR__c)){
                    apptoInterviewersMap.put(interview.Candidate__r.Job_Application_WDR__c,new List<Id>{interview.interviewer__c});
                }
                else{
                    apptoInterviewersMap.get(interview.Candidate__r.Job_Application_WDR__c).add(interview.interviewer__c);
                }

            }
            //for all the job app shares of old Interviewers
            for(WDR_Application__Share js: [Select id,ParentId,UserOrGroupId from WDR_Application__Share where UserOrGroupId = :jobAppShareRemovalMap.keyset() and RowCause = :Schema.WDR_Job__Share.RowCause.Interviewer__c])
            {
                //get job app shares of corresponding job app 
                if(js.ParentId == jobAppShareRemovalMap.get(js.UserOrGroupId)){
                    // check if job app has any existing interviews
                    // check if oldinterviewer is part of any existing interviews
                    if(apptoInterviewersMap.get(js.ParentId) == null || !apptoInterviewersMap.get(js.ParentId).contains(js.UserOrGroupId)){
                    jobAppSharesToDelete.add(js);
                    }
                }
            }
         }
        
       
            if(!jobReqSharesToDelete.isEmpty()){
                delete jobReqSharesToDelete;
            }
            if(!jobAppSharesToDelete.isEmpty()){
                delete jobAppSharesToDelete;
            }
        }
    
        catch(Exception e){
            PF_Logger.log('SIFT','ERROR',e.getMessage(), 'Error while deleting JobReq and JobApp share records',e.getStackTraceString(), 'IFB_InterviewUtilities');
            NHW_Util.insertNHWLogs();
        }
        
    }

    //BEFORE DELETE
    public static void deleteJobReqJobAppShares(List<Id> deletedInterviewList){
        Map<Id,Id> jobReqShareRemovalMap = new Map<Id,Id>();
        Map<Id,Id> jobAppShareRemovalMap = new Map<Id,Id>();
        //to check and delete job req and Job app shares of old interviewer
        for(IFB_Interview__c interview: [Select Id,Interviewer__c,Candidate__r.Job_Application_WDR__r.Job__c,Candidate__c,Candidate__r.Job_Application_WDR__c from IFB_Interview__c where id=:deletedInterviewList]){
            
            jobReqShareRemovalMap.put(interview.Interviewer__c,interview.Candidate__r.Job_Application_WDR__r.Job__c);
            jobAppShareRemovalMap.put(interview.Interviewer__c,interview.Candidate__r.Job_Application_WDR__c);
            deleteShareRecords(jobReqShareRemovalMap,jobAppShareRemovalMap,deletedInterviewList);
        }
    }
}