public class IFB_RecruitInterviewRollup {
	
	// Collection of "Recruit" records to be updated.
	// The idea is NOT to update the "Recruit" records directly on
	// the Interview trigger handlers, but to let those "SIFT Interview"
	// handlers to add to this collection and a higher level class 
	// to to call the method that updates the "Recruit" object in 
	// a SINGLE DML operation.
	public  Map<Id, IFB_Interview_Candidate__c> recruitsToUpdate;


	// Collection of all the "SIFT Interview" records that caused the
	// Recuit record to be updated.  It is being used in this class
	// to know which "SIFT Interview" records to mark with errors
	// in case that the update to the "Recruit" object fails
	public  Map<Id, Set<Id>> interviewsByRecruit;


	// Map "SIFT Interview" records with their corresponding "Id"
	// This is to avoid duplicate "SIFT Interview" records when
	// adding errors.
	public  Map<Id, IFB_Interview__c> interviewMap;

	public IFB_RecruitInterviewRollup() {
		this.recruitsToUpdate = new Map<Id, IFB_Interview_Candidate__c>();
		this.interviewMap = new Map<Id, IFB_Interview__c>();
		this.interviewsByRecruit = new Map<Id, Set<Id>>();
	}

	// Given a "SIFT Interview" return the instance of the "Recruit" that
	// can be used by the "SIFT Interview" trigger handlers to set the right values.
	public IFB_Interview_Candidate__c getRecruit(IFB_Interview__c interview) {
		IFB_Interview_Candidate__c recruit;

		if (interview.Candidate__c != null) {
			if (!this.recruitsToUpdate.containsKey(interview.Candidate__c)) {
				recruit = new IFB_Interview_Candidate__c();
				recruit.Id = interview.Candidate__c;
				this.recruitsToUpdate.put(recruit.Id, recruit);
			} else {
				recruit = this.recruitsToUpdate.get(interview.Candidate__c);
			}

			// Keep track of which "SIFT Interview" requested the update to the "Recruit"
			// so we can error out the "SIFT Interview" records in case the "Recruit" operation fails
			if (!this.interviewsByRecruit.containsKey(recruit.Id)) {
				this.interviewsByRecruit.put(recruit.Id, new Set<Id>{interview.Id});
			} else {
				this.interviewsByRecruit.get(recruit.Id).add(interview.Id);
			}
		}	
		return recruit;
	}

	// This method should be called by the client, to update the "Recruit" object in a single
	// DML operation.
	public void updateRecruits() {
		Integer i = 0;
		for (Database.SaveResult sr : Database.update(this.recruitsToUpdate.values(), false)) {
			if (!sr.isSuccess()) {
				Id recruitId = recruitsToUpdate.values()[i].id;
				if (interviewsByRecruit.containsKey(recruitId)) {
					for (Id interviewId : interviewsByRecruit.get(recruitId)) {
						if (this.interviewMap.containsKey(interviewId)) {
							IFB_Interview__c interview = this.interviewMap.get(interviewId);
							String error = '';
							if (sr.getErrors().size() > 0) {
								error = sr.getErrors()[0].getMessage();
							}
							interview.addError('We could not update the Recruit. ' + error);
						}
					}
				}
			}
			i++;
		}
	}
}