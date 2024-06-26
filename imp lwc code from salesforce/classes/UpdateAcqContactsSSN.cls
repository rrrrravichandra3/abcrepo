public class UpdateAcqContactsSSN implements Database.Batchable<sObject>, Database.Stateful {

    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, SSN_ID_Number__c, SSNID_Number__c FROM Acquisition_Contacts__c Where SSN_ID_Number__c != \'\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Acquisition_Contacts__c> scope){

        // process each batch of records
        List<Acquisition_Contacts__c> AcqContactUpdateList = new List<Acquisition_Contacts__c>();
        
        for (Acquisition_Contacts__c AC : scope) {
                        
            if(!String.isBlank(AC.SSN_ID_Number__c)){
                
                 AC.SSNID_Number__c = AC.SSN_ID_Number__c;
            }
          
            AcqContactUpdateList.add(AC);

        }

        update AcqContactUpdateList;
    }

    public void finish(Database.BatchableContext bc){

        System.debug(recordsProcessed + ' records processed!');

    }
}