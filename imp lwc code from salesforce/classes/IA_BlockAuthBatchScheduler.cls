/**
 * @description       : Batch job to remove access to Insider users in defined stages
 * @author            : vchokkula@salesforce.com
 * @last modified on  : 02-03-2021
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-17-2020   Vinod Chokkula                       Scheduler job for IA_BlockAUthBatch
**/
public with sharing class IA_BlockAuthBatchScheduler implements Schedulable{
/*
@description : Implements a scheduled batch job
@params : SC SchedulableContext
*/
    public void execute(SchedulableContext sc) {
        database.executebatch(new IA_BlockAuthBatch());
    }
}