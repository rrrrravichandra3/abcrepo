/**
 * @description       :
 * @author            : Urvish Shah (ushah)
 * @group             :
 * @last modified on  : 06-16-2022
 * @last modified by  : Urvish Shah (ushah)
 **/
global class CEMCI_LinkedInCleanupBatch implements Database.Batchable<AggregateResult> {
  global Boolean confidential = true;

  global Iterable<AggregateResult> start(Database.BatchableContext bc) {
    String query =
      'SELECT LinkedIn_Substring__c, COUNT(Id) cnt FROM Lead WHERE isconverted = false and LinkedIn_Substring__c != null AND Awaiting_Lead_De_duplication__c = false AND confidential__c = ' +
      confidential +
      ' GROUP BY LinkedIn_Substring__c HAVING count(Id)>1 LIMIT 400';
    return new AggregateResultIterable(query);
  }
  // The batch job executes and operates on one batch of records
  global void execute(Database.BatchableContext bc, List<sObject> scope) {
    List<Lead> leadsToUpdatelist = new List<Lead>();
    List<String> linkedInSubStringList = new List<String>();

    for (sObject sObj : scope) {
      AggregateResult ar = (AggregateResult) sObj;
      linkedInSubStringList.add(String.valueOf(ar.get('LinkedIn_Substring__c')));
    }

    for (Lead lead : [
      SELECT Id, LinkedIn_Substring__c, Awaiting_Lead_De_duplication__c
      FROM Lead
      WHERE LinkedIn_Substring__c IN :linkedInSubStringList
    ]) {
      leadsToUpdatelist.add(new Lead(Id = lead.Id, Awaiting_Lead_De_duplication__c = true));
    }

    update leadsToUpdatelist;
  }
  // The batch job finishes
  global void finish(Database.BatchableContext bc) {
    AggregateResult[] ar = [
      SELECT LinkedIn_Substring__c, COUNT(Id) cnt
      FROM Lead
      WHERE
        isconverted = FALSE
        AND LinkedIn_Substring__c != NULL
        AND Awaiting_Lead_De_duplication__c = FALSE
        AND confidential__c = :confidential
      GROUP BY LinkedIn_Substring__c
      HAVING count(Id) > 1
      LIMIT 2
    ];

    if (!ar.isEmpty()) {
      CEMCI_LinkedInCleanupBatch batchable = new CEMCI_LinkedInCleanupBatch();
      batchable.confidential = confidential;
      Database.executeBatch(batchable, 20);
    } else if (confidential == true) {
      CEMCI_LinkedInCleanupBatch batchable = new CEMCI_LinkedInCleanupBatch();
      batchable.confidential = false;
      Database.executeBatch(batchable, 20);
    }
  }
}