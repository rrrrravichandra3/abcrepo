public with sharing class IFB_PanelInterviewController {

    // Name of the parameters we are expecting in the querystring
    // For security purposes, avoiding complete/full names.
    public static final String QUERYSTRING_RECORDTYPE_ID = 'recTypeId';
    public static final String QUERYSTRING_RECRUIT_ID = 'recruId';
    public static final String QUERYSTRING_RETURL = 'retURL';
    public static final String QUERYSTRING_HIRINGMANAGER_ID = 'hiringManagerId';
    public static final String QUERYSTRING_RECRUITER_ID = 'recruiterId';    

    //Hold the query string parameters values
    public Id recordTypeId {get; set;}
    public Id recruitId    {get; set;}    
    public Id hiringManagerId   {get;set;}
    public Id recruiterId   {get;set;}
    public String retURL {get;set;}

	public IFB_Interview__c interview  {get; set;}

    // List of interviewer fields.
    @TestVisible private Set<String> interviewFields = new Set<String>{'Interviewer__c', 'Interviewer2__c', 'Interviewer3__c', 'Interviewer4__c', 'Interviewer5__c',
                                                                      'Interviewer6__c', 'Interviewer7__c', 'Interviewer8__c', 'Interviewer9__c', 'Interviewer10__c'};

    public IFB_PanelInterviewController() {
        this.recordTypeId = (Id)ApexPages.currentPage().getParameters().get(QUERYSTRING_RECORDTYPE_ID);
        this.recruitId = (Id)ApexPages.currentPage().getParameters().get(QUERYSTRING_RECRUIT_ID);
        this.retURL = ApexPages.currentPage().getParameters().get(QUERYSTRING_RETURL);
        this.hiringManagerId = (Id)ApexPages.currentPage().getParameters().get(QUERYSTRING_HIRINGMANAGER_ID);
        this.recruiterId = (Id)ApexPages.currentPage().getParameters().get(QUERYSTRING_RECRUITER_ID);

        this.interview = new IFB_Interview__c();        
        this.interview.Hiring_Manager__c = hiringManagerId;
        this.interview.RecordTypeId = recordTypeId;
        this.interview.Candidate__c = recruitId;
        this.interview.Recruiter__c = recruiterId;
    }

    // Returns a new "clone" (deep cloned record) of the "interview" on each call.
    // Populates the main interviewer field (Interviewer__c) with the indicated interviewer field of the "interview" record.
    // All the other interviewer fields in the clone are cleared out.
    @TestVisible private IFB_Interview__c generateInterviewForInterviewer(String interviewField) {

        IFB_Interview__c clonedInterview = null;

        if (this.interviewFields.contains(interviewField) == true) {
            // Important: We do DEEP CLONE of the record.
            // We don't need to preserve id, timestamps or autonumbers (irrelevant because record has not been inserted yet) 
            // "interview" record is an in-memory record what is not intended to be inserted. It is used to hold
            // the values captured by the user in the form. It serves a the template for cloning process.
            clonedInterview = this.interview.clone(false, true, false, false);
            
            // On the cloned record we clear out all the Interviewer fields.
            // TODO: Validate that the value that we get from "interview" field is not null
            clonedInterview.Interviewer__c  = (Id)this.interview.get(interviewField);
            clonedInterview.Interviewer2__c = null;
            clonedInterview.Interviewer3__c = null;
            clonedInterview.Interviewer4__c = null;
            clonedInterview.Interviewer5__c = null;
            clonedInterview.Interviewer6__c = null;
            clonedInterview.Interviewer7__c = null;
            clonedInterview.Interviewer8__c = null;
            clonedInterview.Interviewer9__c = null;
            clonedInterview.Interviewer10__c = null;             
        } 
        
        return clonedInterview;
    }

    // Creates a separte Interview record for each fo the Interviewers
    private Boolean createMultipleInterviewRecords() {
        List<IFB_Interview__c> interviewsToInsert = new List<IFB_Interview__c>();
        
        // This auxiliar variable is used to hold reference to cloned Interview records.
        IFB_Interview__c interviewerInterview;

        for (String interviewerField : this.interviewFields) {
             if (this.interview.get(interviewerField) != null) {       
                interviewerInterview = null;
                interviewerInterview = this.generateInterviewForInterviewer(interviewerField);
                if (interviewerInterview != null) {
                    interviewsToInsert.add(interviewerInterview);    
                }  
            }
        }

        if (interviewsToInsert.size() == 0) {
            interviewsToInsert.add(this.interview);
        }

        insert interviewsToInsert;
        return true;
    }

    public ApexPages.PageReference save() {
        PageReference pr = null;
        if (this.createMultipleInterviewRecords() == true) {
            pr = new PageReference(this.retURL);

        }      
        return pr; 
    }

    public ApexPages.PageReference cancel() {
        PageReference pr;
        if(this.recruitId != null) {
            // Delete the "SIFT Recruit" in progress records
            IFB_SIFTInProgressRecords inProgressHelper = new IFB_SIFTInProgressRecords(); 
            inProgressHelper.deleteInProgressSIFTRecruit(this.recruitId);
        }

        pr = new PageReference(this.retURL);
        return pr; 
    }

}