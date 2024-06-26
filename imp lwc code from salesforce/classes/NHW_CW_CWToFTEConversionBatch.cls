/*
* Created by ksrivastava on 05/07/2021
* Created this schedulable batch job as a temporary measure for SSOR
* When a CW is converted to FTE, EI marks it as Internal Candidate. As a result Do_Not_Send_NHW__c is True on WD Job app, which prevents preboarding case creation
* This batch will find appropriate WD JOb Apps, and flip the Do_Not_Send_NHW__c to true
*/


/*
* How to Schedule the job to run every 2 hours (will run at even hours, example 2:00 AM, 4:00 AM, etc)
* Run below Script via anonymous window. Job Id gets stored in custom setting Onboarding Settings
*
* NHW_CW_CWToFTEConversionBatch schClass = new NHW_CW_CWToFTEConversionBatch ();
* String cronExp = '0 0 0/2 1/1 * ? *';
* String jobId = System.schedule('NHW CW To FTE Conversion Job App Update batch', cronExp, schClass);
* Onboarding_Setting__c onboardingSetting = Onboarding_Setting__c.getOrgDefaults();
* onboardingSetting.NHW_CW_CWToFTEConversionBatch_JobId__c = jobId;
* upsert onboardingSetting;
*/


/*
* How to cancel the scheduled job
* Via UI -
*       Setup -> Jobs -> Scheduled Jobs
*       Click Del next to job Name "NHW CW To FTE Conversion Job App Update batch"
* 
* Programmatically (Run below script in anonymous window)-
*       Onboarding_Setting__c onboardingSettings = Onboarding_Setting__c.getOrgDefaults();
*       String jobId = onboardingSettings.NHW_CW_CWToFTEConversionBatch_JobId__c;
*       System.abortJob(jobId);
*       onboardingSettings.NHW_CW_CWToFTEConversionBatch_JobId__c = '';
*       upsert onboardingSettings;         
*/


/*
* Eventually, this batch job will need to be decommissioned. Here are the deprecation Steps
* 1 - Deactivate the scheduled job
* 2 - Delete this class NHW_CW_CWToFTEConversionBatch
* 3 - Delete helper class NHW_CW_CWToFTEConversionBatchService
* 4 - Delete the fields NHW_CW_CWToFTEConversionBatch_Size__c and NHW_CW_CWToFTEConversionBatch_JobId__c from Custom Setting Onboarding_Setting__c
* 5 - Delete the custom setting CW_To_FTE_Conversion_Job_Failed_Records__c and all its records
*/


global with sharing class NHW_CW_CWToFTEConversionBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    
    //Variable to store Contractor Record type's ID. Schema methods are expensive. So calculate it once in constructor, and pass it as parameter to every execute block
    Id contractorContactRecId;
    //Map to store Job App Names that failed to update, slong with Error message
    Map<String, String> failedUpdates = new Map<String, String>();

    global NHW_CW_CWToFTEConversionBatch(){
        contractorContactRecId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contractor').getRecordTypeId();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //Job App that are in Placement Stage, marked as "Internal Candidate", but "Do Not Send NHW" is checked, related WD Candidate has an Employee number
        //keep this order of AND in where clauses. It performs quick checks first, to eliminate records quickly, before moving on to checks that are CPU time intensive
        Database.QueryLocator queryLoc = NHW_CW_CWToFTEConversionBatchService.performStartQuery();
        return queryLoc;
    }

    global void execute(Database.BatchableContext BC, List<WDR_Application__c> scope){
        //Delegate the execute work to helper class. Just accept the data about records that fail the update
        //add that data to Stateful variable failedUpdates, so all of them can be handled at the end - in finish block
        Map<String,String> failedUpdatesThisBatch = NHW_CW_CWToFTEConversionBatchService.performBatchExecute(scope,contractorContactRecId);
        if(failedUpdatesThisBatch==null || failedUpdatesThisBatch.isEmpty()){
            return;
        }else{
            failedUpdates.putAll(failedUpdatesThisBatch);
        }
    }

    global void finish(Database.BatchableContext BC){
        NHW_CW_CWToFTEConversionBatchService.performBatchFinish(failedUpdates);
    }

    //Scheduler's execute method.
    global void execute(SchedulableContext SC){
        NHW_CW_CWToFTEConversionBatch handleFTEConversions = new NHW_CW_CWToFTEConversionBatch();
        //batch size should come from custom setting. Ensure that under all circumstances, it is greater than 0 and max 200
        Integer batchChunkSize;
        try {
            batchChunkSize = (Onboarding_Setting__c.getOrgDefaults().NHW_CW_CWToFTEConversionBatch_Size__c).intValue();
            //if by accident someone left custom setting value as blank, or a negative number, or a number greater than 200, hardocde it to 200
            if((batchChunkSize==null) || (batchChunkSize<=0) ||(batchChunkSize>200)){
                batchChunkSize = 200;
            }
        } catch (Exception e) {
            //if getting it from custom setting somehow fails, set it to hardocded value of 200
            batchChunkSize = 200;
        }
        Database.executeBatch(handleFTEConversions,batchChunkSize);
    }
}