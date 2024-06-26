/*
 *
 * $Author: Charu Goyal
 * $DateTime: March 26 2015    
 * $File: 
 * $Revision: 
 * $Description: As a hiring manager, I want to receive an urgent email reminder to complete the NHW (until I've submitted the request), so that I remember to complete it in a timely manner.
 */
global with sharing class NHW_NotifyHMUrgentOnIncompleteCases implements Schedulable {
  
   global void execute(SchedulableContext sc){
    //call batch job to remind managers if the NHW case is not completed
    //NHW_NotifyHiringManagerUrgentBatchable batchObj = new NHW_NotifyHiringManagerUrgentBatchable();
    //database.executebatch(batchObj,50);
 }
}