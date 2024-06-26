global without sharing class NHW_WDR_PreBoardingTicketsBatch implements Database.Batchable<sObject>{
	// Start Method
	global Database.QueryLocator start(Database.BatchableContext BC){
		Date n_days = System.today() + NHW_Util.LAST_N_DAYS; 
			return Database.getQueryLocator([SELECT Auto_Provisioning_Email_Sent__c,Business_Site__c,Candidate_Stage__c,
												Candidate__c,Id,Internal_Candidate__c,Job__c,
												NHW_Create_Preboarding_Case__c,Offer_Status__c,Offer_Type__c,Start_Date__c 
												FROM WDR_Application__c WHERE Start_Date__c <=:n_days AND Start_Date__c>=:System.today() 
												AND NHW_Create_Preboarding_Case__c = false
												AND  Do_Not_Send_NHW__c = false AND Candidate_Stage__c = 'Placement']);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		try{
			update scope; 
		} catch(Exception e){
			//PF_Logger.log('NHW','ERROR',e.getMessage(),e.getTypeName(), e.getLineNumber()+ 'Error while creating pre-boarding ticket from scheduler', 'NHW_PreBoardingTicketsBatch');
			EventBus.publish(
                        new PF_Logging_Channel__e(
                                ApplicationName__c = 'NHW',
                                LogLevel__c = 'ERROR',
                                //Query_Execution_Time__c = Double.valueOf(qryEnd.getTime() - qryStart.getTime()) / 1000,
                                ErrorType__c = e.getTypeName(),
                                Stack_Trace__c = 'NHW_PreBoardingTicketsBatch',
                                Message__c = e.getMessage(),
                                Error__c = e.getLineNumber()+ 'Error while creating pre-boarding ticket from scheduler'
                                )
                        );
		}

		NHW_Util.insertNHWLogs();
	}

	global void finish(Database.BatchableContext BC){
		// Logic to be Executed at finish
	} 

}