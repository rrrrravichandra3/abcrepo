public class ESDJC_CaseTierAgeCalc_Helper{

	private static final String TIER_1 = 'Tier 1';
    private static final String TIER_2 = 'Tier 2';
    private static final String TIER_3 = 'Tier 3';
    private static final String TIER_4 = 'Tier 4';
    private static final Set<String> relevantTiers = new Set<String>{TIER_1, TIER_2, TIER_3, TIER_4};
    private static final Boolean RUNNING = False;
    private static final Boolean PAUSED = True;

	//Method that calculated TTR and updated the Time resolution record in Map caseIdToResTimeMap
	public static DJC_Resolution_Time__c calculateTierAgeSingleCase(Case currCase, List<CaseHistory> caseHistories, DJC_Resolution_Time__c resTimeRecord){
		
		Decimal tier1AgeWithinBH=0, tier2AgeWithinBH=0, tier3AgeWithinBH=0, tier4AgeWithinBH=0; 
    	Decimal tier1PausedWithinBH=0, tier2PausedWithinBH=0, tier3PausedWithinBH=0, tier4pausedWithinBH=0;
    	
    	// Get Tier, isStopped, BusinessHourId at the time of Case Creation
    	String initialTier = getInitialTier(currCase,caseHistories);
    	Boolean initialClockStatus = getInitialClockStatus(currCase,caseHistories);
    	Id initialBusinessHourId = getInitialBussHourId(currCase,caseHistories);

    	// State variables initialized to values when case was created
    	String lastKnownTier = initialTier;
    	Boolean lastKnownClockStatus = initialClockStatus;
    	DateTime previousHistoryTimeStamp = currCase.CreatedDate;
    	Id lastKnownBusinessHourId = initialBusinessHourId;


    	for(CaseHistory currentCaseHistoryRecord : caseHistories){
    		//If caseHistory is on BusinessHour
    		if(currentCaseHistoryRecord.Field == 'BusinessHours'){
    			//TODO : Update state variable lastKnownBusinessHourId as business hours changes
    			//It is tricky - Single change in Business Hour shows two back to back corresponding caseHistories, one with Business hour name in it, another with ID in it. We need Id one
    			if(isValidBusinessHourCaseHistory(currentCaseHistoryRecord)){
    				//business hour changed. Do pause/runtime calculation 
    				if(isRelevantTier(lastKnownTier)){
	    				if(lastKnownClockStatus == PAUSED){
	    					Long pauseTimeInCurrentTier = calculateTimeDifference(lastKnownBusinessHourId,previousHistoryTimeStamp,currentCaseHistoryRecord.CreatedDate);
		    				if(lastKnownTier == TIER_1){tier1PausedWithinBH = tier1PausedWithinBH + pauseTimeInCurrentTier;}
							else if(lastKnownTier == TIER_2){tier2PausedWithinBH = tier2PausedWithinBH + pauseTimeInCurrentTier;}
							else if(lastKnownTier == TIER_3){tier3PausedWithinBH = tier3PausedWithinBH + pauseTimeInCurrentTier;}
							else if(lastKnownTier == TIER_4){tier4PausedWithinBH = tier4PausedWithinBH + pauseTimeInCurrentTier;} 
	    				}else if (lastKnownClockStatus == RUNNING){
	    					Long runTimeInCurrentTier = calculateTimeDifference(lastKnownBusinessHourId,previousHistoryTimeStamp,currentCaseHistoryRecord.CreatedDate);
		    				if(lastKnownTier == TIER_1){tier1AgeWithinBH = tier1AgeWithinBH + runTimeInCurrentTier;}
							else if(lastKnownTier == TIER_2){tier2AgeWithinBH = tier2AgeWithinBH + runTimeInCurrentTier;}
							else if(lastKnownTier == TIER_3){tier3AgeWithinBH = tier3AgeWithinBH + runTimeInCurrentTier;}
							else if(lastKnownTier == TIER_4){tier4AgeWithinBH = tier4AgeWithinBH + runTimeInCurrentTier;}
	    				}
	    			}
	    			//update the business hours state variable
	    			String newBussHourIdString = getNewStatusValue(currentCaseHistoryRecord);
	    			if(newBussHourIdString == null){lastKnownBusinessHourId = null;}
	    			else{lastKnownBusinessHourId = Id.valueOf(newBussHourIdString);}
    			}
    			else{
    				//ignore the business hour case history that stores Names of businesshours
    				continue;
    			}

    		}
    		//If caseHistory is on isStopped
    		else if(currentCaseHistoryRecord.Field == 'isStopped'){
    			//If clock is being paused, it means it was running until now. Calculate Tier runtime
    			if(currentCaseHistoryRecord.NewValue == PAUSED){
    				if(isRelevantTier(lastKnownTier)){
	    				Long runTimeInCurrentTier = calculateTimeDifference(lastKnownBusinessHourId,previousHistoryTimeStamp,currentCaseHistoryRecord.CreatedDate);
	    				if(lastKnownTier == TIER_1){tier1AgeWithinBH = tier1AgeWithinBH + runTimeInCurrentTier;}
						else if(lastKnownTier == TIER_2){tier2AgeWithinBH = tier2AgeWithinBH + runTimeInCurrentTier;}
						else if(lastKnownTier == TIER_3){tier3AgeWithinBH = tier3AgeWithinBH + runTimeInCurrentTier;}
						else if(lastKnownTier == TIER_4){tier4AgeWithinBH = tier4AgeWithinBH + runTimeInCurrentTier;} 
    				}
    				lastKnownClockStatus = PAUSED;
    			}
    			//If clock's new value is "running", it means it was paused until now. Calculate Pause Time
    			else if(currentCaseHistoryRecord.NewValue == RUNNING){
    				if(isRelevantTier(lastKnownTier)){
    					Long pauseTimeInCurrentTier = calculateTimeDifference(lastKnownBusinessHourId,previousHistoryTimeStamp,currentCaseHistoryRecord.CreatedDate);
	    				if(lastKnownTier == TIER_1){tier1PausedWithinBH = tier1PausedWithinBH + pauseTimeInCurrentTier;}
						else if(lastKnownTier == TIER_2){tier2PausedWithinBH = tier2PausedWithinBH + pauseTimeInCurrentTier;}
						else if(lastKnownTier == TIER_3){tier3PausedWithinBH = tier3PausedWithinBH + pauseTimeInCurrentTier;}
						else if(lastKnownTier == TIER_4){tier4PausedWithinBH = tier4PausedWithinBH + pauseTimeInCurrentTier;} 
    				}
    				lastKnownClockStatus = RUNNING;
    			}

    		}
    		//If caseHistory is on Tier__c field
    		else if(currentCaseHistoryRecord.Field == 'Tier__c'){
    			//if last known tier is relevant, 
    				//calculate pause or run time based on last know clock status
    			if(isRelevantTier(lastKnownTier)){
    				if(lastKnownClockStatus == PAUSED){
    					Long pauseTimeInCurrentTier = calculateTimeDifference(lastKnownBusinessHourId,previousHistoryTimeStamp,currentCaseHistoryRecord.CreatedDate);
	    				if(lastKnownTier == TIER_1){tier1PausedWithinBH = tier1PausedWithinBH + pauseTimeInCurrentTier;}
						else if(lastKnownTier == TIER_2){tier2PausedWithinBH = tier2PausedWithinBH + pauseTimeInCurrentTier;}
						else if(lastKnownTier == TIER_3){tier3PausedWithinBH = tier3PausedWithinBH + pauseTimeInCurrentTier;}
						else if(lastKnownTier == TIER_4){tier4PausedWithinBH = tier4PausedWithinBH + pauseTimeInCurrentTier;} 
    				}else if (lastKnownClockStatus == RUNNING){
    					Long runTimeInCurrentTier = calculateTimeDifference(lastKnownBusinessHourId,previousHistoryTimeStamp,currentCaseHistoryRecord.CreatedDate);
	    				if(lastKnownTier == TIER_1){tier1AgeWithinBH = tier1AgeWithinBH + runTimeInCurrentTier;}
						else if(lastKnownTier == TIER_2){tier2AgeWithinBH = tier2AgeWithinBH + runTimeInCurrentTier;}
						else if(lastKnownTier == TIER_3){tier3AgeWithinBH = tier3AgeWithinBH + runTimeInCurrentTier;}
						else if(lastKnownTier == TIER_4){tier4AgeWithinBH = tier4AgeWithinBH + runTimeInCurrentTier;}
    				}
    			}
    		    //update state variablelastknownTier with newer value
    		    lastKnownTier = getNewStatusValue(currentCaseHistoryRecord);

    		}
    		//State variable holding last case history timestamp is always updated
    		previousHistoryTimeStamp = currentCaseHistoryRecord.CreatedDate;
    	}
        
        // All case histories are processed. Now process the very last case history until the this code runs 
        //This will also account if there are no case histories. Process the data from case creation time
    	if(isRelevantTier(lastKnownTier)){
			if(lastKnownClockStatus == PAUSED){
				Long pauseTimeInCurrentTier = calculateTimeDifference(lastKnownBusinessHourId,previousHistoryTimeStamp,System.now());
				if(lastKnownTier == TIER_1){tier1PausedWithinBH = tier1PausedWithinBH + pauseTimeInCurrentTier;}
				else if(lastKnownTier == TIER_2){tier2PausedWithinBH = tier2PausedWithinBH + pauseTimeInCurrentTier;}
				else if(lastKnownTier == TIER_3){tier3PausedWithinBH = tier3PausedWithinBH + pauseTimeInCurrentTier;}
				else if(lastKnownTier == TIER_4){tier4PausedWithinBH = tier4PausedWithinBH + pauseTimeInCurrentTier;} 
			}else if (lastKnownClockStatus == RUNNING){
				Long runTimeInCurrentTier = calculateTimeDifference(lastKnownBusinessHourId,previousHistoryTimeStamp,System.now());
				if(lastKnownTier == TIER_1){tier1AgeWithinBH = tier1AgeWithinBH + runTimeInCurrentTier;}
				else if(lastKnownTier == TIER_2){tier2AgeWithinBH = tier2AgeWithinBH + runTimeInCurrentTier;}
				else if(lastKnownTier == TIER_3){tier3AgeWithinBH = tier3AgeWithinBH + runTimeInCurrentTier;}
				else if(lastKnownTier == TIER_4){tier4AgeWithinBH = tier4AgeWithinBH + runTimeInCurrentTier;}
			}
		}


    	
    	//calculations are done. Update the TTR record
    	if(resTimeRecord == null){
    		resTimeRecord = new DJC_Resolution_Time__c();
    	}
    	resTimeRecord.Case__c = currCase.Id;
    	resTimeRecord.Tier_1_Age_Milliseconds__c = tier1AgeWithinBH;
    	resTimeRecord.Tier_2_Age_Milliseconds__c = tier2AgeWithinBH;
    	resTimeRecord.Tier_3_Age_Milliseconds__c = tier3AgeWithinBH;
    	resTimeRecord.Tier_4_Age_Milliseconds__c = tier4AgeWithinBH;
    	resTimeRecord.Tier_1_Pause_Time_Milliseconds__c = tier1PausedWithinBH;
    	resTimeRecord.Tier_2_Pause_Time_Milliseconds__c = tier2PausedWithinBH;
    	resTimeRecord.Tier_3_Pause_Time_Milliseconds__c = tier3PausedWithinBH;
    	resTimeRecord.Tier_4_Pause_Time_Milliseconds__c = tier4PausedWithinBH;
    	resTimeRecord.Tier_1_Age_in_Days__c = ((((tier1AgeWithinBH/1000)/60)/60)/24) ;
    	resTimeRecord.Tier_2_Age_in_Days__c = ((((tier2AgeWithinBH/1000)/60)/60)/24) ;
    	resTimeRecord.Tier_3_Age_in_Days__c = ((((tier3AgeWithinBH/1000)/60)/60)/24) ;
    	resTimeRecord.Tier_4_Age_in_Days__c = ((((tier4AgeWithinBH/1000)/60)/60)/24) ;
    	resTimeRecord.Tier_1_Pause_Time_in_Days__c = ((((tier1PausedWithinBH/1000)/60)/60)/24) ;
    	resTimeRecord.Tier_2_Pause_Time_in_Days__c = ((((tier2PausedWithinBH/1000)/60)/60)/24) ;
    	resTimeRecord.Tier_3_Pause_Time_in_Days__c = ((((tier3PausedWithinBH/1000)/60)/60)/24) ;
    	resTimeRecord.Tier_4_Pause_Time_in_Days__c = ((((tier4PausedWithinBH/1000)/60)/60)/24) ;
    	return resTimeRecord; 
	}


    //Method to calculate time difference in milliseconds
	public static Long calculateTimeDifference(Id bussHourId, DateTime startTime, DateTime endTime){
		if(bussHourId != null){
			return BusinessHours.diff(bussHourId,startTime, endTime);
		}else{
			return (endTime.getTime() - startTime.getTime());
		}
	}
    

    //returns caseHistory's NewValue in String
	public static String getNewStatusValue(CaseHistory cH){
		String newStatusValue = null;
		if(cH.NewValue!=null){
			newStatusValue = String.ValueOf(cH.NewValue);
		}
		return newStatusValue;
	}

	//returns caseHistory's OldValue in String
	public static String getOldStatusValue(CaseHistory cH){
		String oldStatusValue = null;
		if(cH.OldValue!=null){
			oldStatusValue = String.ValueOf(cH.OldValue);
		}
		return oldStatusValue;
	}
    
    //Determines if a given tier (String) is Tier 1 or Tier 2 or Tier 3 or Tier 4
	public static Boolean isRelevantTier(String tierValue){
		if(tierValue != null  && relevantTiers.contains(tierValue)){
			return True;
		}else{
			return False;
		}
	}
    
    //Method to determine what was the Tier__c value when the case was created. It takes a quick pass through case histories pertaining to field Tier__c
	public static String getInitialTier(Case currCase, List<CaseHistory> caseHistories){
		String tierValueAtCreation = null;
		for(CaseHistory cH : caseHistories){
			//The very first entry is all we need
			if(cH.Field == 'Tier__c'){
				if(cH.OldValue != null && relevantTiers.contains(String.valueOf(cH.OldValue))){
					tierValueAtCreation = String.valueOf(cH.OldValue);
				}
				return tierValueAtCreation;
			}
		}
		//If there were no case histories, it means there were no changes on Tier field
		return currCase.Tier__c;
	}
    
    //Method to determine what was the isStopped value when the case was created. It takes a quick pass through case histories pertaining to field isStopped
	public static Boolean getInitialClockStatus(Case currCase, List<CaseHistory> caseHistories){
		for(CaseHistory cH : caseHistories){
			//The very first entry is all we need
			if(cH.Field == 'isStopped'){
				if(cH.OldValue == True){
					return True;
				}
				else{
					return False;
				}
			}
		}
		//If there were no case histories for clock, then current value is the value at case creation
		return currCase.isStopped;
	}
    
    //Method to determin what was the businessHour value when the case was created. It takes a quick pass through case histories pertaining to field BusinessHours
	public static Id getInitialBussHourId(Case currCase, List<CaseHistory> caseHistories){
		//TODO : calculate business hours at the tie of case creation
		
		for(CaseHistory cH : caseHistories){
			//There are 2 back to back entry for each BusinessHour change. We are interested in first entry that stores id
			if(cH.Field == 'BusinessHours'){
				//if newValue or oldvalue is a valied Id, this is the entry we are interested in. Return the oldValue
				String oldBussHour = getOldStatusValue(cH);
				String newBussHour = getNewStatusValue(cH);
				if(isValidId(oldBussHour) || (isValidId(newBussHour))){
					if(oldBussHour == null){return null;}
					else{return Id.ValueOf(oldBussHour);}
				}
			}
		}
		return currCase.BusinessHoursId; 
	}

	public static Boolean isValidBusinessHourCaseHistory(CaseHistory cH){
		if(cH.Field != 'BusinessHours'){return False;}
		String oldBussHour = getOldStatusValue(cH);
		String newBussHour = getNewStatusValue(cH);
		if(isValidId(oldBussHour) || (isValidId(newBussHour))){
			return True;
		}else{
			return False;
		}
	}
    
    //Method to determine if a given string is a valid Id
    //Returns true is given string is a 15 or 18 digit Id
    //returns false if its null or has any other values
	public static Boolean isValidId(String givenIdString){
		try{
			Id testId = Id.valueOf(givenIdString);
			return True;
		}
		catch(Exception e){
			return False;
		}

	}
}