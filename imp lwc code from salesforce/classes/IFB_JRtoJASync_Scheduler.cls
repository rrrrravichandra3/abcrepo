/**
 * @description       : Schedule job to schedule IFB_JRtoJASync_Batch batch
 * @author            : vchokkula@salesforce.com

 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-14-2020   Vinod Chokkula                       Initial version
**/
public with sharing class IFB_JRtoJASync_Scheduler implements Schedulable{
    public void execute(SchedulableContext SC) {
        database.executebatch(new IFB_JRtoJASync_Batch());
    }
}