public with sharing class InterviewFeedbackExtension {
    
    public Interview_Feedback__c interviewfeedback {get; set;}
    private Id candidateId {get; set;}
    public boolean int1_flag {get; set;}
    public boolean int2_flag {get; set;}
    public boolean int3_flag {get; set;}
    private ts2extams__Custom_stage_2__c int1 { get; set; }
    private ts2extams__Custom_stage_3__c int2 { get; set; }
    private ts2extams__Custom_stage_4__c int3 { get; set; }
    private Id returnId {get; set;}
    public String jobName {get; set;}
    
    public InterviewFeedbackExtension() {
        int1_flag = False;
        int2_flag = False;
        int3_flag = False;
        
        
        if ( Interview_Feedback__c.Candidate__c.getDescribe().isCreateable() && Interview_Feedback__c.Interview_1__c.getDescribe().isCreateable() && Interview_Feedback__c.Interview_2__c.getDescribe().isCreateable() 
             && Interview_Feedback__c.Interview_3__c.getDescribe().isCreateable() && Interview_Feedback__c.Interviewer_User__c.getDescribe().isCreateable() && Interview_Feedback__c.Hiring_Recommendation__c.getDescribe().isCreateable() 
             && Interview_Feedback__c.Additional_Notes__c.getDescribe().isCreateable() ){
        
            interviewfeedback = new Interview_Feedback__c();

            if ( ApexPages.currentPage().getParameters().get('Interview1') != null && ApexPages.currentPage().getParameters().get('Interview1') != '' ){
                returnId = ApexPages.currentPage().getParameters().get('Interview1');
                int1 = [ select ts2extams__Contact__c, ts2extams__Job__r.Name, ts2extams__Contact__r.EmployeeNumber__c from ts2extams__Custom_stage_2__c where Id = : returnId limit 1 ];
                interviewfeedback.Interview_1__c = returnId;
                interviewfeedback.Candidate__c = int1.ts2extams__Contact__c;
                interviewfeedback.Legacy__c = true;
                jobName = int1.ts2extams__Job__r.Name;
                if ( int1.ts2extams__Contact__r.EmployeeNumber__c != null )
                	interviewfeedback.Internal_Employee__c = true;
                int1_flag = true;
                
            }
            if ( ApexPages.currentPage().getParameters().get('Interview2') != null && ApexPages.currentPage().getParameters().get('Interview2') != '' ){
                returnId = ApexPages.currentPage().getParameters().get('Interview2');
                int2 = [ select ts2extams__Contact__c, ts2extams__Job__r.Name, ts2extams__Contact__r.EmployeeNumber__c from ts2extams__Custom_stage_3__c where Id = : returnId limit 1 ];        
                interviewfeedback.Interview_2__c = returnId;
                interviewfeedback.Candidate__c = int2.ts2extams__Contact__c;    
                interviewfeedback.Legacy__c = true;                 
                jobName = int2.ts2extams__Job__r.Name;  
                if ( int2.ts2extams__Contact__r.EmployeeNumber__c != null )
                	interviewfeedback.Internal_Employee__c = true;                        
                int2_flag = true;
            }           
            if ( ApexPages.currentPage().getParameters().get('Interview3') != null && ApexPages.currentPage().getParameters().get('Interview3') != '' ){
                returnId = ApexPages.currentPage().getParameters().get('Interview3');    
                int3 = [ select ts2extams__Contact__c, ts2extams__Job__r.Name, ts2extams__Contact__r.EmployeeNumber__c from ts2extams__Custom_stage_4__c where Id = : returnId limit 1 ];                        
                interviewfeedback.Interview_3__c = returnId;
                interviewfeedback.Candidate__c = int3.ts2extams__Contact__c;
                interviewfeedback.Legacy__c = true;                
                jobName = int3.ts2extams__Job__r.Name;  
                if ( int3.ts2extams__Contact__r.EmployeeNumber__c != null )
                	interviewfeedback.Internal_Employee__c = true;                                
                int3_flag = true;
            }

        } else  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You do not have the appropriate permissions to access to Interview Feedback. Please contact a System Administrator.'));                
        }           
    }   

    public PageReference Save(){

        PageReference pageRef = new PageReference('');
        
        if ( interviewfeedback.Interviewer_User__c == null ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please enter the Interviewer for the Interview Feedback.'));
        } else {
            try {
                if ( interviewfeedback.Candidate__c != null && interviewfeedback.Interviewer_User__c != null ){
                    insert interviewfeedback;
                    pageRef = new PageReference('/'+returnId);
                    pageRef.setRedirect(true);
                    return pageRef;
                }
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }   
        }
                            
        return null;
        
        
    }
    
    public PageReference Cancel(){
        PageReference pageRef = new PageReference('/'+returnId);            
        return pageRef;
    }   
}