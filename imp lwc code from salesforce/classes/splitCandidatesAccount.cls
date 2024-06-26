public class splitCandidatesAccount {
	
	/**
	 * Method to split the candidates accross the accounts. Due to the performance issue,we are
	 * only associating certian number of candidates to account. when it reaches a threshold based on the
	 * on the system configuration, We are spawning a new account and associating the candidates to the new account.
	 * @param candidateList is a list.
	 * @param configurations is a TF2Settings__c.
	 * @param isBatchScript is a boolean.
	 */
	public static void candidatesAccount(List<Contact> candidateList, TF2Settings__c configurations, boolean isBatchScript) {
		// Ideally this only happens for the very first time.
		if (configurations.Recruiting_Account_Id__c == null || configurations.Current_Candidate_Count__c >= configurations.Max_Candidates_Per_Account__c) {
			// creating a new canidate account.
		     createNewCandidateAccount(configurations);
		     // reloading the custom settings.
		     configurations = TF2Settings__c.getInstance();    	
		}
		// Currently the owner's of some of the candidates are inactive. We cannot update the candiate's
		// records with the inactive owner's.
		Map<Id,User> ownerMap = null;
		if (isBatchScript) {
			// loading all the active owner's of the candidates.
			ownerMap = getOwnerDetails(candidateList);
		}
		// reading the current candidate count associated to an account from custom settings.
		Integer currentCount = Integer.valueOf(configurations.Current_Candidate_Count__c);
		List<Contact> candidateAcctAssociationList = new List<Contact>();
		for (Contact CandidateInfo : candidateList) {
			// if the associated candidates reach the threshold number.
			// Creating a new canidate account.
			if (currentCount >= configurations.Max_Candidates_Per_Account__c) {
				createNewCandidateAccount(configurations);
				configurations = TF2Settings__c.getInstance();
				// reseting the current count as we have created a new candidate account.
				currentCount = 0;
			}
			// loading the new accountid to the candidate.
			candidateInfo.AccountId = configurations.Recruiting_Account_Id__c;
			// if this is invoked from the batch script, we have to update the candidates
			// after we have associated to a new account.
			if (isBatchScript) {
				//loading the active owner's of the candidates.
				if(ownerMap != null && !ownerMap.containsKey(candidateInfo.ownerId)) {
					candidateInfo.OwnerId = UserInfo.getUserId();
				}
				// adding the candidates toa list for  update.
				candidateAcctAssociationList.add(candidateInfo);
			}
			currentCount++;
		}
		if (candidateAcctAssociationList != null && candidateAcctAssociationList.size() > 0) {
			update candidateAcctAssociationList;
		}
		// updating the current count in the custom settings.
		configurations.Current_Candidate_Count__c = currentCount;
		update configurations;
	}
	
	/**
	 * Method to create the candidate account and load the account id into the custom settings
	 * and resetting the counts in the custom settings.
	 * @param configurations is TF2Settings__c.
	 */
	
	private static void createNewCandidateAccount(TF2Settings__c configurations) {
		// retrieving the candidate record type from database.
		RecordType candidateRecordType = [select Id, name from RecordType Where name='Candidate' and SObjectType='Account'];
		// Creating the a new candidate account when it reaches the count set in the custom settings.
		// No of candidates tied to a account is defaulted to 5000. This is a configurable number in the
		// custom settings.
		Account candidateAccount = new Account();
		candidateAccount.recordTypeId = candidateRecordType.Id;
		candidateAccount.name = 'Candidates';
		insert candidateAccount;
		// updating the custom settings.
		configurations.Recruiting_Account_Id__c = candidateAccount.Id;
		configurations.Current_Candidate_Count__c = 0;
		update configurations;
		
		
	}
    
    /**
     * Method to load the owner details of all the candidates
     *@param candidateList is a list.
     *@return ownerMap is a map.
     */
    private static Map<Id, User> getOwnerDetails(List<Contact> candidateList) {
    	Map<Id,User> ownerMap = null;
    	Set<Id> ownerIdSet = new Set<Id>();
    	for(Contact candidateInfo : candidateList ) {
    		// loading the ownerId's to a set.
    		if (candidateInfo.ownerId != null) {
    			ownerIdSet.add(candidateInfo.ownerId);
    		}
    	}
    	// Retrieving the owner details that are active in the org.
    	if (ownerIdSet != null && ownerIdSet.size() > 0) {
    		ownerMap = new Map<Id, User>([select id,name from User where Id IN :ownerIdSet AND IsActive=true]);
    	}
    	return ownerMap;
    }
}