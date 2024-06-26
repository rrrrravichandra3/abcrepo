global with sharing class IFB_InterviewShareRecalculation implements Database.Batchable<sObject> {
    
    string query = 'select Id, Candidate__c, Interviewer__c from IFB_Interview__c where Interviewer__c != null';
    
    global IFB_InterviewShareRecalculation() 
    {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        IFB_InterviewUtilities.AddInterviewShares(new Map<Id, IFB_Interview__c>((List<IFB_Interview__c>)scope));
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}