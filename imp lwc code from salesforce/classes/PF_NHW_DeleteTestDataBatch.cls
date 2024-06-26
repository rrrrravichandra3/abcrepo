global with sharing class PF_NHW_DeleteTestDataBatch implements Database.Batchable<SObject>, Database.Stateful  {

    private Id userId;
    private List<String> objects;
    private String objectApiName;
    
    public PF_NHW_DeleteTestDataBatch(Id uId) {
        userId = uId;
        objects = new List<String> {'Concierge_Case_Facet__c', 'Case', 'Contact', 'WDR_Application__c', 'WDR_Job__c', 'WDR_Candidate__c'};
        objectApiName = objects.remove(0);
    }

    public PF_NHW_DeleteTestDataBatch(Id uId, List<String> objects) {
        userId = uId;
        objectApiName = objects.remove(0);
    }

    global Database.QueryLocator start(Database.BatchableContext ctx) {
        String queryString;
        if (objectApiName == 'Concierge_Case_Facet__c') {
            List<Case> cases = [SELECT Id FROM Case WHERE CreatedById = :userId LIMIT 50000];
            queryString = 'SELECT Id FROM Concierge_Case_Facet__c WHERE Case__c IN: cases';
        } else {
            queryString = 'SELECT Id FROM ' + objectApiName + ' WHERE CreatedById = :userId';
        }
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext ctx, List<SObject> scope) {
        delete scope;
    }
    global void finish(Database.BatchableContext ctx) {
        if(objects != null && !objects.isEmpty()) {
             Database.executebatch(new PF_NHW_DeleteTestDataBatch(userId, objects));
        }
    }
}