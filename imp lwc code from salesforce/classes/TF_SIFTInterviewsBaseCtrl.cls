/* 
 * This class is meant to be used as a base class for a controller extension
 * of a page that display a list of "SIFT Interviews" given the Recruit Id.
 * Super class must set the recruitId in the constructor.
*/

public virtual with sharing class TF_SIFTInterviewsBaseCtrl {

    public final Id recruitId                   {get; set;}
    public IFB_Interview__c[] interviewList     {get; set;}


    public IFB_Interview__c[] getInterviews() {
  
        if (interviewList == null) {
        	if (recruitId != null) {
	        	System.debug('recruitId: ' + recruitId);
	            interviewList = [select Id,
	                            Name, 
	                            RecordType.Name,
	                            Interviewer__c,
	                            Interviewer__r.Name,
	                            Status__c,
	                            Scheduled_Interview_Date__c,
	                            Recommendation__c, 
	                            Comments__c
	                            from IFB_Interview__c
	                            where Candidate__c = :recruitId];
            } else {
            	
            	// This is unlikely, but in case superclass doesn't set the recruitId property, 
    			// return an empty list of SIFT Interviews.
            	interviewList = new List<IFB_Interview__c>();
            }
        }

        System.debug(interviewList);
        return interviewList;
    }

    public Boolean getHasVisualforceMessages() {
    	return (ApexPages.hasMessages());
    }
    
}