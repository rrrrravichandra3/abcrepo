public with sharing class SecurityRiskCheck {
	public Contact candidate {get; private set;}
	public static final Integer MAX_FIND_CHARACTERS_BEFORE_LOGICAL_OPERATORS_ARE_REMOVED = 4000;

	//This regex will match the following characters commonly found in Phone numbers:
	// +, (, ), - and any 1 or more consecutive spaces.
	//So we can support matches of phone numbers with or without formmating
	//See: https://help.salesforce.com/apex/HTViewSolution?id=000181563&language=en_US
	private static final String REGEX_PHONE_SYMBOLS = '[+]|[(]|[)]|[-]|[ ]*';
	
    public SecurityRiskCheck(ApexPages.StandardController stdController) {
    	
        this.candidate = [select Security_Risk_Level__c, Last_Security_Risk_assessment__c, Is_Security_Risk_false_positive__c, 
        				 Name, FirstName, LastName, Preferred_First_Name__c, Preferred_Last_Name__c, NameKanji__c, NameKana__c,
        				 Email, Secondary_Email__c, 
        				  MobilePhone, Phone, 
        				 MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, 
        				 OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry,  
        				 LastModifiedDate 
        				 from Contact 
        				 where Id =:stdController.getId()];

    }
    
    public Boolean getThereAreMessages(){
    	return ApexPages.hasMessages();
	}

    public PageReference checkSecurityRisk() {   	
		List<Contact> lst_candidates = new List<Contact>();
		lst_candidates.add(candidate);
		 
		//We know that in the context of the 'SecurityRiskPage' page only ONE candidate gets proccessed.		
   		verify(lst_candidates);	
   		
   		try {		
   			
   			update lst_candidates;
   								
   		} catch(Exception e){
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Unable to update the candidate record with the latest "Security Risk Level".'));
   			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Latest Risk Level: ' + (candidate.Security_Risk_Level__c != null ? candidate.Security_Risk_Level__c : 'No Risk Level (null)') ));
   			ApexPages.addMessages(e);
   		}	    	       	
    	return null;
    }
        
    public static void verify(List<Contact> lst_candidates) {
		
		List<String> lst_findClauses = new List<String>();
		Integer findClausesIndex = 0;
		lst_findClauses.add('');
		
		for (Contact candidate : lst_candidates) {
			String singleCandidateFindClause = candidateFindClause(candidate);
			
			//Concatenate all FIND clauses for the Candidates until we reach the 4000 characters limit.
			//https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_find.htm
			//
			//"If SearchQuery is longer than 4,000 characters, any logical operators are removed. 
			//For example, the AND operator in a statement with a SearchQuery that’s 4,001 characters will 
			//default to the OR operator, which could return more results than expected."
			if (singleCandidateFindClause.length() < MAX_FIND_CHARACTERS_BEFORE_LOGICAL_OPERATORS_ARE_REMOVED) {
				if ((lst_findClauses[findClausesIndex].length() + ' OR '.length() + singleCandidateFindClause.length()) > MAX_FIND_CHARACTERS_BEFORE_LOGICAL_OPERATORS_ARE_REMOVED ) {			
					lst_findClauses.add(singleCandidateFindClause);
					findClausesIndex++;
				} else {
					
					if (lst_findClauses[findClausesIndex] == '') {
						lst_findClauses[findClausesIndex] = singleCandidateFindClause;
					} else {
						lst_findClauses[findClausesIndex] = lst_findClauses[findClausesIndex]  + ' OR ' + singleCandidateFindClause;
					}
					
				}
			}
		}	
		
		List<Security_Risk__c> lst_securityRisks = new List<Security_Risk__c>();
		List<Security_Risk_Item__c> lst_securityRiskItems = new List<Security_Risk_Item__c>();
		
		for (String findClause : lst_findClauses) {
			//Look at 'Security Risk' object sharing rules: All 'Security Risk' records are shared (Read Only) with 'All Internal Users'
			//In APEX, there is no need for the user to have Tab access to the 'Security Risk' and 'Security Risk Item' objects for this search clause (SOSL) to work.
			
			List<List<SObject>> searchList = [FIND :findClause IN ALL FIELDS RETURNING 
											 Security_Risk__c (Id, Name, First_Name__c, Last_Name__c, Email__c, Inactive__c), 
											 Security_Risk_Item__c (Id, Name, Security_Risk__c, Security_Risk__r.Inactive__c,  Type__c, Value__c)];
							
			lst_securityRisks.addAll((List<Security_Risk__c>)searchList[0]);
			lst_securityRiskItems.addAll((List<Security_Risk_Item__c>)searchList[1]);
		}
		
		for (Contact candidate : lst_candidates) {						   	
			
			//1.- Email match
			for (Security_Risk__c securityRisk : lst_securityRisks) {
				if (securityRisk.Inactive__c == false && securityRisk.Email__c != null) {
					if (candidate.Email == securityRisk.Email__c || candidate.Secondary_Email__c == securityRisk.Email__c) {
						SecurityRiskAssessment.addSecurityRiskMatch(securityRisk.Id, SecurityRiskAssessment.MatchType.EMAIL_MATCH);
						break;
					}
				}
			}
			
			for (Security_Risk_Item__c securityRiskItem : lst_securityRiskItems) {
				if (securityRiskItem.Security_Risk__r.Inactive__c == false && securityRiskItem.Type__c  == 'Email') {
					if (candidate.Email == securityRiskItem.Value__c || candidate.Secondary_Email__c == securityRiskItem.Value__c ) {
						SecurityRiskAssessment.addSecurityRiskMatch(securityRiskItem.Security_Risk__c, SecurityRiskAssessment.MatchType.EMAIL_MATCH);
						break;
					}
				}
			}
			
			//If the 'Security Risk Level' is not 'High' already, we continue with our assessment.
			if (SecurityRiskAssessment.getHighestSecurityRiskLevel() != 'High') {		

				//2.-Name match
				//Check on 'Security Risk' records.
				for (Security_Risk__c securityRisk : lst_securityRisks) {
					
					String securityRiskCandidateName = (securityRisk.First_Name__c != null ? securityRisk.First_Name__c : '') + ' ' +
													   (securityRisk.Last_Name__c  != null ? securityRisk.Last_Name__c  : '');
					
					securityRiskCandidateName = securityRiskCandidateName.trim();	 
					
					if (securityRisk.Inactive__c == false && String.isEmpty(securityRiskCandidateName) == false) {					
						if ((candidate.FirstName == securityRisk.First_Name__c && candidate.LastName == securityRisk.Last_Name__c) ||
							(candidate.Preferred_First_Name__c == securityRisk.First_Name__c && candidate.Preferred_Last_Name__c == securityRisk.Last_Name__c) ||
							(candidate.NameKanji__c == securityRiskCandidateName) ||
							(candidate.NameKana__c == securityRiskCandidateName)) {

							SecurityRiskAssessment.addSecurityRiskMatch(securityRisk.Id, SecurityRiskAssessment.MatchType.NAME_MATCH);
						}
					}
				}
				
				
				//Check on 'Security Risk Item' records.
				for (Security_Risk_Item__c securityRiskItem : lst_securityRiskItems) {
					if (securityRiskItem.Security_Risk__r.Inactive__c == false && securityRiskItem.Type__c  == 'Name') {
							
						String candidateName = candidate.FirstName + ' ' + candidate.LastName; //We get candidate's 'Name' without the salutation.
						String candidatePreferredName = candidate.Preferred_First_Name__c + ' ' + candidate.Preferred_Last_Name__c;

						if (candidateName == securityRiskItem.Value__c || 
							candidatePreferredName == securityRiskItem.Value__c ||
							candidate.NameKanji__c == securityRiskItem.Value__c ||
							candidate.NameKana__c == securityRiskItem.Value__c ) {
	
							SecurityRiskAssessment.addSecurityRiskMatch(securityRiskItem.Security_Risk__c, SecurityRiskAssessment.MatchType.NAME_MATCH);
						}
					}
				} 
				
				
				//3.- Other element match (different than Email and Name)
				//Check on 'Security Risk Item' records (We don't check 'Security Risk' records, because those only include 'Name' information)
				for (Security_Risk_Item__c securityRiskItem : lst_securityRiskItems) {
					if (securityRiskItem.Security_Risk__r.Inactive__c == false) {
						
						if (securityRiskItem.Type__c  == 'Phone') {
							
							//Remove all symbols from the 'Candidate' phones
							String candidatePhoneHome ;
							String candidatePhoneMobile = candidate.MobilePhone != null ? candidate.MobilePhone.replaceAll(REGEX_PHONE_SYMBOLS, '') : null;
							String candidatePhone = candidate.Phone != null ? candidate.Phone.replaceAll(REGEX_PHONE_SYMBOLS, '') : null;
							
							//Remove all symbols from the 'Security Risk Item' phone
							//NOTE: We actually expect the 'Phone' in the 'Security Risk Item'object not to include any symbols. 
							//		Otherwise, SOSL search won't find a record and we won't be able to reach this point in the first place.
							String riskPhone = securityRiskItem.Value__c != null ? securityRiskItem.Value__c.replaceAll(REGEX_PHONE_SYMBOLS, '') : null;
							
							if (riskPhone != null) {
								if ((candidatePhoneHome != null && (candidatePhoneHome == riskPhone) )||
									(candidatePhoneMobile != null && (candidatePhoneMobile == riskPhone) )||
									(candidatePhone != null && (candidatePhone == riskPhone) )) {

										SecurityRiskAssessment.addSecurityRiskMatch(securityRiskItem.Security_Risk__c, SecurityRiskAssessment.MatchType.OTHER_MATCH);
								}
							}						
							
						}
						
						//If the 'Security Risk Level' is not 'High' already, we continue with our assessment(addresses).
						if (SecurityRiskAssessment.getHighestSecurityRiskLevel() != 'High') {	
							if (securityRiskItem.Type__c  == 'Address') {
								
								String candidateMailingAddress = (candidate.MailingStreet      != null ? (candidate.MailingStreet     + ' ' )  : '')  +
																 (candidate.MailingCity        != null ? (candidate.MailingCity       + ', ')  : '')  +
																 (candidate.MailingState  	   != null ? (candidate.MailingState      + ' ' )  : '')  + 
																 (candidate.MailingPostalCode  != null ? (candidate.MailingPostalCode + ' ' )  : '')  + 
																 (candidate.MailingCountry     != null ? (candidate.MailingCountry          )  : '');
								
								candidateMailingAddress = candidateMailingAddress.trim();
								candidateMailingAddress = candidateMailingAddress.removeEnd(',');
															 
								String candidateOtherAddress = (candidate.OtherStreet      != null ? (candidate.OtherStreet     + ' ' )  : '')  +
															   (candidate.OtherCity        != null ? (candidate.OtherCity       + ', ')  : '')  +
															   (candidate.OtherState  	   != null ? (candidate.OtherState      + ' ' )  : '')  + 
															   (candidate.OtherPostalCode  != null ? (candidate.OtherPostalCode + ' ' )  : '')  + 
															   (candidate.OtherCountry     != null ? (candidate.OtherCountry          )  : '');
								
								candidateOtherAddress = candidateOtherAddress.trim();
								candidateOtherAddress = candidateOtherAddress.removeEnd(',');
								
								if ((String.isEmpty(candidateMailingAddress) == false && candidateMailingAddress == securityRiskItem.Value__c) ||
								    (String.isEmpty(candidateOtherAddress)   == false && candidateOtherAddress == securityRiskItem.Value__c  ) ){
									
									SecurityRiskAssessment.addSecurityRiskMatch(securityRiskItem.Security_Risk__c, SecurityRiskAssessment.MatchType.OTHER_MATCH);
								}
							}
						}													
					}
				}
				 		
			} //SecurityRiskAssessment.getHighestSecurityRiskLevel() != 'High'
			
			candidate.Security_Risk_Level__c =  SecurityRiskAssessment.getHighestSecurityRiskLevel();		
	  		candidate.Last_Security_Risk_assessment__c = DateTime.now();
	  		
	  		//We clean up the matches collection, so we can start fresh with the next candidate in the loop. 
	  		SecurityRiskAssessment.resetSecurityRiskMatchCollection();
	  		
		}// lst_candidates iteration loop
    	return;										   							     	
    }
    
    private static String candidateFindClause(Contact candidate) {
    	 
    	//Name
    	String findClause = candidate.Name;
    	findClause = candidate.FirstName == null ? findClause : (findClause + ' OR ' + candidate.FirstName);
    	findClause = candidate.LastName == null ? findClause : (findClause + ' OR ' + candidate.LastName);
    	findClause = candidate.Preferred_First_Name__c == null ? findClause : (findClause + ' OR ' + candidate.Preferred_First_Name__c);
    	findClause = candidate.Preferred_Last_Name__c == null ? findClause : (findClause + ' OR ' + candidate.Preferred_Last_Name__c);
		findClause = candidate.NameKanji__c == null ? findClause : (findClause + ' OR ' + candidate.NameKanji__c);
 		findClause = candidate.NameKana__c == null ? findClause : (findClause + ' OR ' + candidate.NameKana__c);
		

		//Email
		findClause = candidate.Email == null ? findClause : (findClause + ' OR ' + candidate.Email);
		findClause = candidate.Secondary_Email__c == null ? findClause : (findClause + ' OR ' + candidate.Secondary_Email__c);
		
		
		
		//Phone
		//In order to do the search we remove all symbols from the candidate phones.
		//For this to work, the 'Value' field in the 'Security Risk Item' object, when the 'Type' is 'Phone' MUST not include any symbols.
		findClause = candidate.MobilePhone == null ? findClause : (findClause + ' OR ' + candidate.MobilePhone.replaceAll(REGEX_PHONE_SYMBOLS, ''));
		findClause = candidate.Phone == null ? findClause : (findClause + ' OR ' + candidate.Phone.replaceAll(REGEX_PHONE_SYMBOLS, ''));
		
		
		
		//Address
		findClause = candidate.MailingStreet == null ? findClause : (findClause + ' OR ' + candidate.MailingStreet);
		findClause = candidate.MailingCity == null ? findClause : (findClause + ' OR ' + candidate.MailingCity);
		findClause = candidate.MailingState == null ? findClause : (findClause + ' OR ' + candidate.MailingState);
		findClause = candidate.MailingPostalCode == null ? findClause : (findClause + ' OR ' + candidate.MailingPostalCode);
		findClause = candidate.MailingCountry == null ? findClause : (findClause + ' OR ' + candidate.MailingCountry);
		
		findClause = candidate.OtherStreet == null ? findClause : (findClause + ' OR ' + candidate.OtherStreet);
		findClause = candidate.OtherCity == null ? findClause : (findClause + ' OR ' + candidate.OtherCity);
		findClause = candidate.OtherState == null ? findClause : (findClause + ' OR ' + candidate.OtherState);
		findClause = candidate.OtherPostalCode == null ? findClause : (findClause + ' OR ' + candidate.OtherPostalCode);
		findClause = candidate.OtherCountry == null ? findClause : (findClause + ' OR ' + candidate.OtherCountry);

    	return findClause;
    
    }
}