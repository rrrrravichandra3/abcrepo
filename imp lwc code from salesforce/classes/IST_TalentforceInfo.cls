public class IST_TalentforceInfo {
	@AuraEnabled
	public String jobTitle {get; set;}

	@AuraEnabled
	public String candidateSource {get; set;}

	@AuraEnabled
	public String hiringManagerName {get; set;}

	@AuraEnabled
	public String candidateName {get; set;}

	@AuraEnabled
	public String referrerName {get; set;}

	public IST_TalentforceInfo(){
		
	}

	/*
	* Constructor to populate Talentforce fields
	* Parameter objectName decides whether the first paramter (an ID) is that of a task or of an interview object
	* From the Interview ID, it is determined wheter it is Interview1, or Interview2 or Interview3 and then fields are queried
	*/
	public IST_TalentforceInfo(Id taskOrInterviewID, String objectName){
		Id interviewID;
		if(objectName == 'Task'){
			//given ID is that of a task
			//query the task to get whatId
			Task givenTask = [Select whatId from Task where Id = :taskOrInterviewID limit 1];
			if(givenTask != null){
				interviewID = givenTask.WhatId;
			}
		}else if(objectName == 'Interview'){
			interviewID = taskOrInterviewID;
		}

		if(interviewID == null) {return;}

		//retrieve all talentforce records
		/*
		 * Job Title           = Interview -> Job Req.Name
		 * Hiring Manager Name = Interview -> Job Req -> Hiring Manager.Name
		 * Candidate Source    = Interview -> Application -> Candidate.Source__c
		 * Referrer Name       = Interview -> Application -> Referred By.Name
		 * Candidate Name      = Interview -> Candidate.Name
		*/

		String sObjName = interviewId.getSObjectType().getDescribe().getName();

		if(sObjName == 'ts2extams__Custom_stage_2__c'){
			ts2extams__Custom_stage_2__c givenInterview1 = [Select  ts2extams__Job__r.Name, 
															        ts2extams__Job__r.ts2__Manager__r.Name, 
															        ts2extams__Contact__r.Name, 
															        ts2extams__Application__r.Candidate_Source__c,
															        ts2extams__Application__r.ts2__referred_by__r.Name 
															from    ts2extams__Custom_stage_2__c
															where Id = :interviewID
															limit 1];
			if(givenInterview1 != null){
				jobTitle = givenInterview1.ts2extams__Job__r.Name;
				hiringManagerName = givenInterview1.ts2extams__Job__r.ts2__Manager__r.Name;
				candidateName = givenInterview1.ts2extams__Contact__r.Name;
				candidateSource = givenInterview1.ts2extams__Application__r.Candidate_Source__c;
				referrerName = givenInterview1.ts2extams__Application__r.ts2__referred_by__r.Name;
			}
		}
		else if(sObjName == 'ts2extams__Custom_stage_3__c'){
			ts2extams__Custom_stage_3__c givenInterview2 = [Select  ts2extams__Job__r.Name, 
															        ts2extams__Job__r.ts2__Manager__r.Name, 
															        ts2extams__Contact__r.Name, 
															        ts2extams__Application__r.Candidate_Source__c,
															        ts2extams__Application__r.ts2__referred_by__r.Name 
															from    ts2extams__Custom_stage_3__c
															where Id = :interviewID
															limit 1];
			if(givenInterview2 != null){
				jobTitle = givenInterview2.ts2extams__Job__r.Name;
				hiringManagerName = givenInterview2.ts2extams__Job__r.ts2__Manager__r.Name;
				candidateName = givenInterview2.ts2extams__Contact__r.Name;
				candidateSource = givenInterview2.ts2extams__Application__r.Candidate_Source__c;
				referrerName = givenInterview2.ts2extams__Application__r.ts2__referred_by__r.Name;
			}
		}
		else if(sObjName == 'ts2extams__Custom_stage_4__c'){
			ts2extams__Custom_stage_4__c givenInterview3 = [Select  ts2extams__Job__r.Name, 
															        ts2extams__Job__r.ts2__Manager__r.Name, 
															        ts2extams__Contact__r.Name, 
															        ts2extams__Application__r.Candidate_Source__c,
															        ts2extams__Application__r.ts2__referred_by__r.Name 
															from    ts2extams__Custom_stage_4__c
															where Id = :interviewID
															limit 1];
			if(givenInterview3 != null){
				jobTitle = givenInterview3.ts2extams__Job__r.Name;
				hiringManagerName = givenInterview3.ts2extams__Job__r.ts2__Manager__r.Name;
				candidateName = givenInterview3.ts2extams__Contact__r.Name;
				candidateSource = givenInterview3.ts2extams__Application__r.Candidate_Source__c;
				referrerName = givenInterview3.ts2extams__Application__r.ts2__referred_by__r.Name;
			}
		}

	}
}