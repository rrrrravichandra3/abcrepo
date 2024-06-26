public with sharing class IFB_InterviewRecruitDates {

	public IFB_RecruitInterviewRollup recruitInterviewRollup;

	public IFB_InterviewRecruitDates(IFB_RecruitInterviewRollup recruitInterviewRollup) {
		// Manages the collection of "Recruits" that this class will use to include the "Recruit" records
		// that need to be updated. The purpose of this is to let a higher level class to do a 
		// single update to the "Recruit" object.
		this.recruitInterviewRollup = recruitInterviewRollup;
	}

	// Updates the "First Screen Date" and "Panel Interview Date" on Recruits.
	public void updateDatesOnRecruit(List<IFB_Interview__c> interviews) {

		List<IFB_Interview__c> interviewsActualDateNotNull = new List<IFB_Interview__c>();

		for (IFB_Interview__c interview : interviews) {
			if (interview.Actual_Interview_Date__c != null) {
				interviewsActualDateNotNull.add(interview);
			}
		}

		// Create a collation of all the different recruiters referenced by all the interviews
		Map<Id, IFB_Interview_Candidate__c> recruitMap = new Map<Id, IFB_Interview_Candidate__c>();
		Set<Id> recruitIds = new Set<Id>();
		for(IFB_Interview__c interview: interviewsActualDateNotNull) {
		 	if (interview.Candidate__c != null) {
		 		recruitIds.add(interview.Candidate__c);
		 	}
		}

		// Get the oldest "Actual Interview Date" of all the Interviews, by Recruit.
		Map<Id, DateTime> minActualInterviewDateByRecruit = new Map<Id, DateTime>();
		for (AggregateResult ar : [select Candidate__c, MIN(Actual_Interview_Date__c) minActualIntDate
														  from IFB_Interview__c
														  where Candidate__c = :recruitIds
														  and Actual_interview_date__c != null
														  group by Candidate__c]) {
			
			if (DateTime.valueOf(ar.get('minActualIntDate')) != null) {
				minActualInterviewDateByRecruit.put((Id) ar.get('Candidate__c'), DateTime.valueOf(ar.get('minActualIntDate')));
			}
		}

        for (IFB_Interview__c interview : interviewsActualDateNotNull) {
        	
        	IFB_Interview_Candidate__c recruit;
        	recruit = this.recruitInterviewRollup.getRecruit(interview);
        	if (recruit != null) {

	        	// Update the "First Screen Date" in all cases.
	        	if (minActualInterviewDateByRecruit.containsKey(interview.Candidate__c) == true) {
	        		recruit.First_Screen_Date__c = minActualInterviewDateByRecruit.get(interview.Candidate__c);	
	        	}

	        	// Update the "Panel Interview Date" only for the CSG Panel interview.
	        	String intvTypeName = IFB_InterviewUtilities.interviewTypeIdToRecordMap.get(interview.Interview_Type__c).Name;
	        	if (interview.RecordTypeName__c == 'CSG - Panel Interview' || intvTypeName.equalsIgnoreCase('CSG - Panel Interview')) {	
	        		recruit.Panel_Interview_Date__c = interview.Actual_Interview_Date__c;
	        	}
	        } 
        }

	}

}