global with sharing class NHW_WDR_SchedulePreBoardingTickets implements Schedulable {
	global void execute(SchedulableContext SC){
		NHW_WDR_PreBoardingTicketsBatch preBoardBatch = new NHW_WDR_PreBoardingTicketsBatch();
		database.executebatch(preBoardBatch,50);
	}
}