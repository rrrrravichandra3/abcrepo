public with sharing class IFB_InterviewOps {
	public IFB_InterviewUtils utils;
	public IFB_InterviewUtilsWos utilsWos;

	public IFB_InterviewOps(IFB_InterviewUtils utils, IFB_InterviewUtilsWos utilsWos) {
		this.utils = utils;
		this.utilsWos = utilsWos;	
	}

	public List<IFB_Interview__Share> shareInterviewInterviewerEdit(List<IFB_Interview__c> interviews) {
		
		List<IFB_Interview__Share> interviewShares = new  List<IFB_Interview__Share>();
		for (IFB_Interview__c interview : interviews) {
			if (interview.Interviewer__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerEditShare(interview.Id, interview.Interviewer__c));
			}
			if (interview.Interviewer2__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerEditShare(interview.Id, interview.Interviewer2__c));	
			}
			if (interview.Interviewer3__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerEditShare(interview.Id, interview.Interviewer3__c));
			}
			if (interview.Interviewer4__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerEditShare(interview.Id, interview.Interviewer4__c));	
			}
			if (interview.Interviewer5__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerEditShare(interview.Id, interview.Interviewer5__c));
			}	
		}

		return interviewShares;	
	}

	public List<IFB_Interview__Share> shareInterviewInterviewerRead(List<IFB_Interview__c> interviews) {
		
		List<IFB_Interview__Share> interviewShares = new  List<IFB_Interview__Share>();
		for (IFB_Interview__c interview : interviews) {
			if (interview.Interviewer__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerReadShare(interview.Id, interview.Interviewer__c));
			}
			if (interview.Interviewer2__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerReadShare(interview.Id, interview.Interviewer2__c));	
			}
			if (interview.Interviewer3__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerReadShare(interview.Id, interview.Interviewer3__c));
			}
			if (interview.Interviewer4__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerReadShare(interview.Id, interview.Interviewer4__c));	
			}
			if (interview.Interviewer5__c != null) {
				interviewShares.add(this.utilsWos.interviewInterviewerReadShare(interview.Id, interview.Interviewer5__c));
			}	
		}

		return interviewShares;	
	}

	public List<IFB_Interview__Share> shareInterviewOtherInterviewerRead(List<IFB_Interview__c> interviews) {
		List<IFB_Interview__Share> interviewShares = new  List<IFB_Interview__Share>();
		this.utilsWos.populateFeedbackSubmittedInfoByRecruit(interviews);
		for (IFB_Interview__c interview : interviews) {
			for (Id interviewerId : this.utilsWos.feedbackSubmittedInterviewersByRecruit.get(interview.Candidate__c)) {
				// Exclude interviewers of the current interview in the 'Panel Summary' sharing.
				if (interview.Interviewer__c  != interviewerId &&
					interview.Interviewer2__c != interviewerId &&
					interview.Interviewer3__c != interviewerId &&
					interview.Interviewer4__c != interviewerId &&
					interview.Interviewer5__c != interviewerId) {
					interviewShares.add(this.utilsWos.interviewOtherInterviewerReadShare(interview.Id, interviewerId));
				}
			}
		}

		return interviewShares;	
	}

	public List<IFB_Interview__Share> shareOtherInterviewsInterviewerRead(List<IFB_Interview__c> interviews) {
		List<IFB_Interview__Share> interviewShares = new  List<IFB_Interview__Share>();
		this.utilsWos.populateFeedbackSubmittedInfoByRecruit(interviews);
		for (IFB_Interview__c interview : interviews) {
			for (Id otherInterviewId : this.utilsWos.feedbackSubmittedInterviewsByRecruit.get(interview.Candidate__c)) {
				// Exclude current interview in the 'Panel Summary' sharing.
				if(otherInterviewId != interview.Id) {
					if (interview.Interviewer__c != null) {
						interviewShares.add(this.utilsWos.interviewOtherInterviewerReadShare(otherInterviewId, interview.Interviewer__c));
					}
					if (interview.Interviewer2__c != null) {
						interviewShares.add(this.utilsWos.interviewOtherInterviewerReadShare(otherInterviewId, interview.Interviewer2__c));
					}
					if (interview.Interviewer3__c != null) {
						interviewShares.add(this.utilsWos.interviewOtherInterviewerReadShare(otherInterviewId, interview.Interviewer3__c));
					}
					if (interview.Interviewer4__c != null) {
						interviewShares.add(this.utilsWos.interviewOtherInterviewerReadShare(otherInterviewId, interview.Interviewer4__c));
					}
					if (interview.Interviewer5__c != null) {
						interviewShares.add(this.utilsWos.interviewOtherInterviewerReadShare(otherInterviewId, interview.Interviewer5__c));
					}
				}
			}
		}

		return interviewShares;	
	}

	public List<IFB_Interview_Candidate__Share> shareInterviewCandidateInterviewerRead(List<IFB_Interview__c> interviews) {
		List<IFB_Interview_Candidate__Share> interviewCandidateShares = new  List<IFB_Interview_Candidate__Share>();

		for (IFB_Interview__c interview : interviews) {	
			if (interview.Interviewer__c != null) {
				interviewCandidateShares.add(this.utilsWos.interviewCandidateInterviewerReadShare(interview.Candidate__c, interview.Interviewer__c));
			}
			if (interview.Interviewer2__c != null) {
				interviewCandidateShares.add(this.utilsWos.interviewCandidateInterviewerReadShare(interview.Candidate__c, interview.Interviewer2__c));	
			}
			if (interview.Interviewer3__c != null) {
				interviewCandidateShares.add(this.utilsWos.interviewCandidateInterviewerReadShare(interview.Candidate__c, interview.Interviewer3__c));
			}
			if (interview.Interviewer4__c != null) {
				interviewCandidateShares.add(this.utilsWos.interviewCandidateInterviewerReadShare(interview.Candidate__c, interview.Interviewer4__c));	
			}
			if (interview.Interviewer5__c != null) {
				interviewCandidateShares.add(this.utilsWos.interviewCandidateInterviewerReadShare(interview.Candidate__c, interview.Interviewer5__c));
			}
		}		
		return interviewCandidateShares;	
	}


}