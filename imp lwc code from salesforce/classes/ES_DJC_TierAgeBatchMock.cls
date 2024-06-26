global class ES_DJC_TierAgeBatchMock implements Database.Batchable<sObject> , Database.Stateful{
	
	global final String soqlQuery;

	private Test_ESDJC_AssignTierAges_Asserter asserter = new Test_ESDJC_AssignTierAges_Asserter();

    global ES_DJC_TierAgeBatchMock(String query){
        soqlQuery = query;
    }

	global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(soqlQuery);
	}

	global void execute(Database.BatchableContext BC,  List<sObject> scope){
		this.asserter.assertScope(scope);
	}

	global void finish(Database.BatchableContext BC){}
}