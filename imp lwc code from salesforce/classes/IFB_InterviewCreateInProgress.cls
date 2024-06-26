public with sharing class IFB_InterviewCreateInProgress {
	
	public IFB_RecruitInterviewRollup recruitInterviewRollup;

	public IFB_InterviewCreateInProgress(IFB_RecruitInterviewRollup recruitInterviewRollup) {
		// Manages the collection of "Recruits" that this class will use to include the "Recruit" records
		// that need to be updated. The purpose of this is to let a higher level class to do a 
		// single update to the "Recruit" object.
		this.recruitInterviewRollup = recruitInterviewRollup;
	}

	// This method is to be used in an before update trigger on the "SIFT Interview" object, 
	// to clear out the "Create in progress" interview.
	public void clearOutInProgressInterview(List<IFB_Interview__c> interviews, Boolean updateRecruit) {
		
		for (IFB_Interview__c interview : interviews) {		
		
			//ANY update to the record will clear out the flag.
			interview.Create_in_progress__c = false;
			
			if (this.recruitInterviewRollup != null && updateRecruit == true && interview.Candidate__c != null) {
				IFB_Interview_Candidate__c recruit;
				recruit = this.recruitInterviewRollup.getRecruit(interview);
				if (recruit != null) {
					recruit.Create_in_progress__c = false;	
				}
			}
		}
	}
 
}