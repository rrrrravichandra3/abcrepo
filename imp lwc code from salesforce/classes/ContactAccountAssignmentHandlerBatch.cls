@SuppressWarnings('PMD.EmptyStatementBlock')
public with sharing class ContactAccountAssignmentHandlerBatch implements Database.Batchable<sObject> {

   public Database.QueryLocator start(Database.BatchableContext bc){
      Contact_Account_Assignment__c settings = Contact_Account_Assignment__c.getOrgDefaults();
      Set<Id> contactRecordTypesToProcess =  ContactAccountAssignmentHelper.contactRecordTypesToProcess;
      String recordtypeIdstoProcess = '(';
       for(Id i:contactRecordTypesToProcess) {
           recordtypeIdstoProcess+='\''+i+'\' ,';
       }    
      recordtypeIdstoProcess = recordtypeIdstoProcess.removeEnd(',')+')';
      String query = 'select id,recordtypeid,Status__c,'+ settings.Contact_Employee_Id_Field_Name__c+' from contact where recordtypeId in '+recordtypeIdstoProcess;
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext bc, List<Contact> cntList) {
          update ContactAccountAssignmentHelper.assignAccountToContact(ContactAccountAssignmentHelper.filterbyRecordType(cntList));
   }

   public void finish(Database.BatchableContext bc){
		System.debug('Batch Finished');
   }

}