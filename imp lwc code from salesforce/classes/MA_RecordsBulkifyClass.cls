/**
 * MA_RecordsBulkifyClass Class is used to create a list of My_Info_Updates records which goes to flow from Process and send them back to Flow
 * Ver   Date         Author            Modification
 * 1.0   12-07-2021   Sergey Mihalyuk   Initial Version
 */
public with sharing class MA_RecordsBulkifyClass {
    @InvocableMethod(label='Collect Bulkified Records')
    public static List<List<MA_My_Info_Updates__c>> gatherRequests(Request[] requests) {

        Set<Id> myInfosIds = new Set<Id>();

        for (Request request : requests) {
            myInfosIds.add(request.recordId);
        }
        
        List<List<MA_My_Info_Updates__c>> responseColl = new List<List<MA_My_Info_Updates__c>>();
        List<MA_My_Info_Updates__c> responseList = [
            SELECT Id, Mass_Approval__c, Mass_Rejection__c, Status__c, Approver_Comments__c, Field_Label__c, CreatedById
            FROM MA_My_Info_Updates__c WHERE Id IN: myInfosIds
        ];
        
        responseColl.add(responseList);
        
        List<MA_My_Info_Updates__c> emptyList = new List<MA_My_Info_Updates__c>();

        for (Integer i = 0; i < responseList.size() - 1; i++) {
            responseColl.add(emptyList);
        }

        return responseColl;
    }

    public with sharing class Request {
        @InvocableVariable(label='Record Id' required=true)
        public Id recordId;
    }
    
}