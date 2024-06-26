/*
 * Security Risk Assesment based on the 'Security Risk Item' records that belong to the same 'Security Risk' record AND
 * with the information of the 'Security Risk' record itself.  See: SecurityRiskCheck.cls
 */
public with sharing class SecurityRiskAssessment {
	
	/* INNER types */
	//Ordered from Lowest to Highest risk. Ordinals: [0, 1, 2, 3]
	//Marked as private as it's only used by the STATIC and INSTANCE methods in this class
	private enum SecurityRiskLevel {NO_RISK, LOW_RISK, MEDIUM_RISK, HIGH_RISK}
	
	public enum MatchType {EMAIL_MATCH, NAME_MATCH, OTHER_MATCH}
	
	/* INSTANCE properties and methods */
	//securityRiskId: Id of the 'Security Risk' record. 
	//				  Even if ther is no match in the 'Security Risk' record itself, it is used to group
	//				  all the 'Security Risk Item' records that belong to the same parent record.
	private Id securityRiskId 	{get; set;} 
	
	private Boolean isEmailMatch {get; set;}
	private Boolean isNameMatch  {get; set;}
	private Boolean isOtherMatch {get; set;}
	
	private SecurityRiskLevel riskLevel {get; set;}
	
	//Constructor is private. All instances of this class are  created indirectly by the 'addSecurityRiskMatch' method
	private SecurityRiskAssessment(){
		this.isEmailMatch = false;
		this.isNameMatch  = false;
		this.isOtherMatch = false;
	}
	
	//For a single Security Risk Assesment, detetermines the 'Risk Level' based on the conditions that matched.		
	private SecurityRiskLevel getSecurityRiskLevel() {
		
  		if (this.isEmailMatch || (this.isNameMatch && this.isOtherMatch)) {
  		 	this.riskLevel	= SecurityRiskLevel.HIGH_RISK;
  		} else if (this.isNameMatch){
  			this.riskLevel	= SecurityRiskLevel.MEDIUM_RISK;	
  		} else if (this.isOtherMatch){
  			this.riskLevel	= SecurityRiskLevel.LOW_RISK;	
  		} else {
  			this.riskLevel	= SecurityRiskLevel.NO_RISK;
  		}
  		return this.riskLevel;
	}
	
	/* STATIC properties and methods */
	private static Map<Id, SecurityRiskAssessment> map_securityRiskAssesments = new Map<Id, SecurityRiskAssessment>();
	
   /* Method used to indicate that match between an Candidate and a 'Security Risk' or 'Security Risk Item' 
    * record has happened 
    *
	* @param securityRiskId Id of the 'Security Risk' record that matched OR 
						    Id of the 'Security Risk' record that is the parent of the 'Security Risk Item' record that matched
	* @param securityMatchType Indicates what kind of match was done: Email, Name or Other (see enum: SecurityRiskAssessment.MatchType)
	*/	
	public static void addSecurityRiskMatch(Id securityRiskId, MatchType securityMatchType) {
		if (map_securityRiskAssesments.containsKey(securityRiskId) == false) {
			SecurityRiskAssessment sra = new SecurityRiskAssessment();
			sra.securityRiskId = securityRiskId;
			map_securityRiskAssesments.put(sra.securityRiskId, sra);
		} 
		
		//Set the right boolean flag, depending on the type of match
		if (securityMatchType == MatchType.EMAIL_MATCH) {
			map_securityRiskAssesments.get(securityRiskId).isEmailMatch = true;
		} else if (securityMatchType == MatchType.NAME_MATCH) {
			map_securityRiskAssesments.get(securityRiskId).isNameMatch = true;
		} else if (securityMatchType == MatchType.OTHER_MATCH) {
			map_securityRiskAssesments.get(securityRiskId).isOtherMatch = true;
		}	
	}
	
   /* Based on all the information collected using the 'addSecurityRiskMatch' method,
    * we return the overall 'Security Risk Level' of the candidate.
	*
	* There could be multiple matches on multiple 'Security Risk' and 'Security Risk Item' records,
	* but we need to consider the following;
	* 1) A Securiy Risk Assesments is done for each group of records that share the same 'Security Risk' id
	* 2) The Securiy Risk Assesments with the highest risk, will determine the overall 'Security Risk Level' of the candidate.
	*/		
	public static String getHighestSecurityRiskLevel() {
		
		SecurityRiskLevel highestSecurityRiskLevel = SecurityRiskLevel.NO_RISK; //.ordinal() is zero
		String highestSecurityRiskLevelString = null;
			
		//We use the ordinal property of the enumeration entries to compare security risk assesments and get the one with the highest risk.
		for (SecurityRiskAssessment sra : map_securityRiskAssesments.values()) {
			if (sra.getSecurityRiskLevel().ordinal() > highestSecurityRiskLevel.ordinal()) {
				highestSecurityRiskLevel = sra.getSecurityRiskLevel();
			}
		}
		
		if (highestSecurityRiskLevel == SecurityRiskLevel.HIGH_RISK) {
			highestSecurityRiskLevelString = 'High';
		} else if (highestSecurityRiskLevel == SecurityRiskLevel.MEDIUM_RISK) {
			highestSecurityRiskLevelString = 'Medium';
		} else if (highestSecurityRiskLevel == SecurityRiskLevel.LOW_RISK) {
			highestSecurityRiskLevelString = 'Low';
		} else if (highestSecurityRiskLevel == SecurityRiskLevel.NO_RISK) {
			highestSecurityRiskLevelString = null;
		}						
		return highestSecurityRiskLevelString;
	}
	
   /*
    * Cleans up the collection of security risk "matches" that were added using 'addSecurityRiskMatch' method
    * This needs to be done before moving to a new Candidate.
	*/
	public static void resetSecurityRiskMatchCollection(){
		map_securityRiskAssesments = null;
		map_securityRiskAssesments = new Map<Id, SecurityRiskAssessment>();			
	}	

}