/*
 *
 * $Author: Charu Goyal
 * $DateTime: September 23, 2015    
 * $File: 
 * $Revision: 
 * $Description: 
 */
global with sharing class NHW_RetryPFDebugLogSchedulable implements Schedulable {

   global void execute(SchedulableContext sc){
      List<PF_Debug_Log__c> recordsToProcess = [select id, Application__c, Type__c, Error_Type__c, Error_Message__c,
                    Component__c, Description__c, Running_User__c,
                    NH_Name__c, Callout__c, Processed_for_Retry__c from PF_Debug_Log__c where Processed_for_Retry__c = false LIMIT 50];
      NHW_RetryPFDebugLog batchObj = new NHW_RetryPFDebugLog(recordsToProcess, 0);

      PF_Debug_Log1_Settings__c pfDebugLogSetting = PF_Debug_Log1_Settings__c.getInstance();
      Datetime sysTime = System.now().addSeconds(Integer.valueOf(pfDebugLogSetting.Retry_Interval__c));
      String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
      System.schedule('NHW_RetryPFDebugLog ' + sysTime, chronExpression, batchObj);
 }
}