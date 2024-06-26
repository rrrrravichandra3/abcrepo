//Calling only from trigger
public class ReferralHandler {

	public static void updateReferralwithRecruiterEmailAndJobPosted(List<ts2__Referral__c> referralList){
		
		Set<Id> JobIdSet = new Set<Id>();
		for ( ts2__Referral__c ref: referralList ) {              
			JobIdSet.add( ref.ts2__job_order_id__c );
		}                  
			
		if ( JobIdSet.size() > 0  ){
			List<ts2__Job__c> jobList = [ select Id, ts2__Recruiter__r.Email,Sourcer__r.Email, ts2__Post_Job__c from ts2__Job__c where Id in : JobIdSet];
			Map<Id, string> jobEmailMap = new Map<Id, string>();
			Map<Id, string> sourcerEmailMap = new Map<Id, string>();
            Map<Id, boolean> jobPostJobMap = new Map<Id, boolean>();
	            
			for ( ts2__Job__c job : jobList ){
                if ( job.ts2__Recruiter__r.Email != null  ) {
					jobEmailMap.put( job.Id, job.ts2__Recruiter__r.Email );
                }
                if ( job.Sourcer__r.Email != null  ) {
                    sourcerEmailMap.put(job.Id, job.Sourcer__r.Email);
				}
                jobPostJobMap.put( job.Id, job.ts2__Post_Job__c );
			}
	
			for ( ts2__Referral__c ref: referralList ) {              
	                ref.Recruiter_Email__c = jobEmailMap.get( ref.ts2__job_order_id__c);
					ref.Sourcers_Email__c = sourcerEmailMap.get(ref.ts2__job_order_id__c);
                	ref.Is_Job_Posted__c = jobPostJobMap.get( ref.ts2__job_order_id__c);
			}  	
		}
	}
	
   /*
	* For each of the inserted or updated "Referral" records, updates the "Referrer Succesful Hires" (Referrer_Successful_Hires__c) field.
	*
	* NOTE: In case of UPDATE, only the "Referral" records that had a change in their "Refferer Contact Lookup" (ts2__r_contact_lookup__c) field are considered.
	*
	* To be used in: BEFORE UPDATE and BEFORE INSERT events in the "Referral" (ts2__Referral__c) object.
	*/
	public static void updateReferrerSuccesfulHires(Map<Id, ts2__Referral__c> map_oldReferrals, List<ts2__Referral__c> lst_newReferrals) {
		
		//Gets the set of referers of this batch. 
		//In case of update. Only consider the referral record that changed their referrer.
		Set<Id> set_ReferrerIds = new Set<Id>();
		for (ts2__Referral__c referral : lst_newReferrals) {
			if ( map_oldReferrals == null || (referral.ts2__r_contact_lookup__c != null && (referral.ts2__r_contact_lookup__c != map_oldReferrals.get(referral.Id).ts2__r_contact_lookup__c)) ){
				set_ReferrerIds.add(referral.ts2__r_contact_lookup__c);
			}	
		}
		
		if (set_ReferrerIds.size() > 0) {
			//Count all the applications that related with the referrers of this batch and have moved to 'Placement' 
			Map<Id, Integer> map_successfulHiresByReferrer = new Map<Id, Integer>();
			for (AggregateResult ar : [select ts2__referred_by__c referrerId, COUNT(Id) countByReferrer
									   from ts2__Application__c
									   where ts2__referred_by__c in :set_ReferrerIds
									   and ts2__Stage__c = 'Placement'
									   group by ts2__referred_by__c]) {
		
				map_successfulHiresByReferrer.put((Id) ar.get('referrerId'), (Integer) ar.get('countByReferrer'));
			}
			
			for (ts2__Referral__c referral : lst_newReferrals) {
				if (map_successfulHiresByReferrer.containsKey(referral.ts2__r_contact_lookup__c) == true){
					referral.Referrer_Successful_Hires__c = map_successfulHiresByReferrer.get(referral.ts2__r_contact_lookup__c);
				} else {
					referral.Referrer_Successful_Hires__c = 0;
				}
			}
		}
	
	}
	
	/*
	 * Copies the value of the "Post Job"(s2__job_order_id__r.ts2__Post_Job__c) field 
	 * to the "Is Job Posted?"(Is_Job_Posted__c) field in the case that 
	 * - Candidate hasn't applied (ts2__applied__c == false) and the email reminder hasn't been sent (Flag_Email_reminder_to_the_Referral__c == false)
	 * - "ts2__applied__c" field transitioned from "true" to "false" OR "Flag_Email_reminder_to_the_Referral__c" field transitioned from "true" to "false"
	 * 
	 * NOTE: A trigger in the "Job Order"(ts2__Job__c) object keeps the "Is Job Posted?"(Is_Job_Posted__c) in sync 
	 * with the "Post Job"(s2__job_order_id__r.ts2__Post_Job__c) field as long as the candidate hasn't applied yet 
	 * (ts2__applied__c == false) and the notification hasn't been sent (Flag_Email_reminder_to_the_Referral__c == false)
	 * 
	 * "Is Job Posted?"(Is_Job_Posted__c) field is used to dequeue a time-dependent action (48 hrs email notification) for a Job that is not posted anymore 
	 * and to requeue it when the Job is posted back. See "Referral hasn't applied yet 48 hrs" workflow rule.
	 * 
	 * This method handler is intented to be user in a BEFORE UPDATE operation
	 */ 
    public static void updateIsJobPostedCheckbox(Map<Id, ts2__Referral__c> map_oldReferrals, Map<Id, ts2__Referral__c>  map_newReferrals) {
    	Set<Id> set_JobId = new Set<Id>();
        Set<Id> set_ReferralId = new Set<Id>();
        
        for (ts2__Referral__c referral : map_newReferrals.values()) {
            Boolean bAppliedTransitionedToFalse;
            Boolean bEmailNotificationFlagTransitionedToFalse;
            Boolean bAppliedAndEmailNotificationFlagAreFalse;
            
            bAppliedTransitionedToFalse = referral.ts2__applied__c == false && map_oldReferrals.get(referral.Id).ts2__applied__c == true;
            bEmailNotificationFlagTransitionedToFalse = referral.Flag_Email_reminder_to_the_Referral__c == false && map_oldReferrals.get(referral.Id).Flag_Email_reminder_to_the_Referral__c == true;
            bAppliedAndEmailNotificationFlagAreFalse = referral.ts2__applied__c == false && referral.Flag_Email_reminder_to_the_Referral__c == false;
      
            if (bAppliedAndEmailNotificationFlagAreFalse && (bAppliedTransitionedToFalse || bEmailNotificationFlagTransitionedToFalse)) {
                if (referral.ts2__job_order_id__c != null) {
                	set_JobId.add(referral.ts2__job_order_id__c);
                    set_ReferralId.add(referral.Id);
                }
            }
        }
        
        if (set_JobId.size() > 0) {
            Map<Id, ts2__Job__c> map_Jobs = new Map<Id, ts2__Job__c>([select Id, ts2__Post_Job__c from ts2__Job__c where Id in :set_JobId]);
            if (map_Jobs.size() > 0) {
                for (Id referralId : set_ReferralId) {
                    ts2__Referral__c referral = map_newReferrals.get(referralId);
                    //Copies from the "Job" record to the "Referral" record.
                    referral.Is_Job_Posted__c = map_Jobs.get(referral.ts2__job_order_id__c).ts2__Post_Job__c;
                }
            }
    	}
    }
}