public without sharing class NHW_TestDataPrepCaseCloser {

    @InvocableMethod(label='Preboarding Case closer' description='Closes a test preboarding case')
    public static void closeCase(List<Case> cases){
        
        List<Id> casesIds = new List<Id>();
        
        for(Case c:cases){
            casesIds.add(c.Id);
        }
        
        List<Case> editableCases = [SELECT Id, Status, PII__c FROM Case WHERE Id IN :casesIds];
        List<Case> casesToUpdate = new List<Case>();
        
        for(Case c:editableCases){
            if(c.Status == 'Sent to Supportforce'){
                c.Status = 'Closed';
                c.PII__c = 'Yes';
                casesToUpdate.add(c);
            }
        }

        if(Case.sObjectType.getDescribe().isUpdateable()){
            try {
                Database.SaveResult[] results = Database.update(casesToUpdate, false);
            }  catch (DmlException ex) { 
              system.debug('The following exception has occurred: ' + 
                          ex.getDmlStatusCode(0) + ex.getMessage());
            }
        }
    }
}