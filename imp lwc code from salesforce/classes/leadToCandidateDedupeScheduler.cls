global class leadToCandidateDedupeScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		Integer batchSize = ((TF2Settings__c.getOrgDefaults()).Lead_To_Candidate_Dedupe_BatchSize__c).intValue();
		if((batchSize == null) || (batchSize <= 0)){
			batchSize = 50;
		}
		database.executeBatch(new leadToCandidateDedupe(), batchSize);
	}
}