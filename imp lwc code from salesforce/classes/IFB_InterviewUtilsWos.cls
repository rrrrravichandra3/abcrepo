public without sharing class IFB_InterviewUtilsWos {

	public  Map<Id, Set<Id>> feedbackSubmittedInterviewersByRecruit;
	public  Map<Id, Set<Id>> feedbackSubmittedInterviewsByRecruit;

	public IFB_InterviewUtilsWos(){}

	/**
	 * 'without sharing' note: Not all users might have access to the ts2__Job__c records
	 *                          but regardless of that, people can capture the job requisition
	 *                          number in the interview record and the system should query the 
	 *                          job requisitions and try to find a match.
	 */

	public Map<Id, Set<Id>> populateFeedbackSubmittedInfoByRecruit(List<IFB_Interview__c> interviews) {
		
		if (feedbackSubmittedInterviewersByRecruit == null || feedbackSubmittedInterviewsByRecruit == null) {
			feedbackSubmittedInterviewersByRecruit = new Map<Id, Set<Id>>();
			feedbackSubmittedInterviewsByRecruit = new Map<Id, Set<Id>>();

			Set<Id> recruits = new Set<Id>();
			for (IFB_Interview__c interview : interviews) {
				if (interview.Candidate__c != null) {
					recruits.add(interview.Candidate__c);	
				}			
			}

			List<IFB_Interview__c> otherRecruitInterviews = [select Id, Name, Candidate__c,
									 Interviewer__c, 
									 Interviewer2__c, 
									 Interviewer3__c,
									 Interviewer4__c,
									 Interviewer5__c
									 from IFB_Interview__c 
									 where Candidate__c in :recruits
									 and Status__c = 'Feedback submitted'
									 and Id not in :interviews];

			List<IFB_Interview__c> allRecruitInterviews = new List<IFB_Interview__c>();
			allRecruitInterviews.addAll(otherRecruitInterviews);
			
			for (IFB_Interview__c interview : interviews) {
				if (interview.Status__c == 'Feedback submitted'){
					allRecruitInterviews.add(interview);
				}			
			}
			
			for (IFB_Interview__c interview : allRecruitInterviews) {
				if (interview.Candidate__c != null) {
					if (!feedbackSubmittedInterviewersByRecruit.containsKey(interview.Candidate__c)) {
						feedbackSubmittedInterviewersByRecruit.put(interview.Candidate__c, new Set<Id>());
					}

					if (!feedbackSubmittedInterviewsByRecruit.containsKey(interview.Candidate__c)) {
						feedbackSubmittedInterviewsByRecruit.put(interview.Candidate__c, new Set<Id>());
					}

					feedbackSubmittedInterviewsByRecruit.get(interview.Candidate__c).add(interview.Id);

					if (interview.Interviewer__c != null) {
						feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer__c);	
					}
					if (interview.Interviewer2__c != null) {
						feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer2__c);	
					}
					if (interview.Interviewer3__c != null) {
						feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer3__c);	
					}
					if (interview.Interviewer4__c != null) {
						feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer4__c);	
					}
					if (interview.Interviewer5__c != null) {
						feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer5__c);	
					}
				}		
			}

		}
		return feedbackSubmittedInterviewersByRecruit;
	}

	public Map<Id, Set<Id>> getFeedbackSubmittedInterviewsByRecruit(List<IFB_Interview__c> interviews) {
		
		if (feedbackSubmittedInterviewersByRecruit == null) {
			feedbackSubmittedInterviewersByRecruit = new Map<Id, Set<Id>>(); 

			Set<Id> recruits = new Set<Id>();
			for (IFB_Interview__c interview : interviews) {
				if (interview.Candidate__c != null) {
					recruits.add(interview.Candidate__c);	
				}			
			}

			List<IFB_Interview__c> otherRecruitInterviews = [select Id, Name, Candidate__c,
									 Interviewer__c, 
									 Interviewer2__c, 
									 Interviewer3__c,
									 Interviewer4__c,
									 Interviewer5__c
									 from IFB_Interview__c 
									 where Candidate__c in :recruits
									 and Status__c = 'Feedback submitted'
									 and Id not in :interviews];

			List<IFB_Interview__c> allRecruitInterviews = new List<IFB_Interview__c>();
			allRecruitInterviews.addAll(otherRecruitInterviews);
			
			for (IFB_Interview__c interview : interviews) {
				if (interview.Status__c == 'Feedback submitted'){
					allRecruitInterviews.add(interview);
				}			
			}
			
			for (IFB_Interview__c interview : allRecruitInterviews) {
				if (!feedbackSubmittedInterviewersByRecruit.containsKey(interview.Candidate__c)) {
					feedbackSubmittedInterviewersByRecruit.put(interview.Candidate__c, new Set<Id>());
				}

				if (interview.Interviewer__c != null) {
					feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer__c);	
				}
				if (interview.Interviewer2__c != null) {
					feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer2__c);	
				}
				if (interview.Interviewer3__c != null) {
					feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer3__c);	
				}
				if (interview.Interviewer4__c != null) {
					feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer4__c);	
				}
				if (interview.Interviewer5__c != null) {
					feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c).add(interview.Interviewer5__c);	
				}		
			}

		}
		return feedbackSubmittedInterviewersByRecruit;
	}

	public IFB_Interview__Share interviewInterviewerEditShare(Id interviewId, Id interviewerId) {
		IFB_Interview__Share interviewShare = new IFB_Interview__Share();
		interviewShare.AccessLevel = 'Edit';
		interviewShare.ParentId = interviewId;
        interviewShare.RowCause = Schema.IFB_Interview__Share.RowCause.Interviewer__c;
        interviewShare.UserOrGroupId = interviewerId;

        return interviewShare;
	}

	public IFB_Interview__Share interviewInterviewerReadShare(Id interviewId, Id interviewerId) {
		IFB_Interview__Share interviewShare = new IFB_Interview__Share();
		interviewShare.AccessLevel = 'Read';
		interviewShare.ParentId = interviewId;
        interviewShare.RowCause = Schema.IFB_Interview__Share.RowCause.Feedback_Submitted__c;
        interviewShare.UserOrGroupId = interviewerId;

        return interviewShare;
	}

	public IFB_Interview__Share interviewOtherInterviewerReadShare(Id interviewId, Id interviewerId) {
		IFB_Interview__Share interviewShare = new IFB_Interview__Share();
		interviewShare.AccessLevel = 'Read';
		interviewShare.ParentId = interviewId;
        interviewShare.RowCause = Schema.IFB_Interview__Share.RowCause.Panel_Interviewer__c;
        interviewShare.UserOrGroupId = interviewerId;

        return interviewShare;
	}

	public IFB_Interview_Candidate__Share interviewCandidateInterviewerReadShare(Id interviewCandidateId, Id interviewerId) {
		IFB_Interview_Candidate__Share interviewCandidateShare = new IFB_Interview_Candidate__Share();
		interviewCandidateShare.AccessLevel = 'Read';
		interviewCandidateShare.ParentId = interviewCandidateId;
        interviewCandidateShare.RowCause = Schema.IFB_Interview_Candidate__Share.RowCause.Interviewer__c;
        interviewCandidateShare.UserOrGroupId = interviewerId;
		
		return interviewCandidateShare;
	}

}