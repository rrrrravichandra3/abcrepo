/*
	Batch class which queries for all valid open cases and calculates Tier1 to Tier4 ages. 

*/

global class  ES_DJC_TierAgeBatch implements Database.Batchable<sObject> , Database.Stateful{
	
    global final String soqlQuery; 
    global ES_DJC_TierAgeBatch(String query){
        soqlQuery = query;
    }

	global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(soqlQuery);
	}

	global void execute(Database.BatchableContext BC,  List<Case> scope){
		ESDJC_CaseTierAgeCalc.calculateTierAge(scope);
	}


	global void finish(Database.BatchableContext BC){}

}