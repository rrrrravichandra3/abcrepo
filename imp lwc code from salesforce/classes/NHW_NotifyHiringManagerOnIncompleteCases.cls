/*
 *
 * $Author: Archana Vanam
 * $DateTime: August 21 2014
 * $File: 
 * $Revision: 
 * $Description: As a hiring manager, I want to receive a daily email reminder to complete the NHW (until I've submitted the request), so that I remember to complete it in a timely manner.
 */
global with sharing class NHW_NotifyHiringManagerOnIncompleteCases implements Schedulable {
	
	 global void execute(SchedulableContext sc){
    //call batch job to remind managers if the NHW case is not completed
    //NHW_NotifyHiringManagerBatchable batchObj = new NHW_NotifyHiringManagerBatchable();
    //database.executebatch(batchObj,50);
 }
}