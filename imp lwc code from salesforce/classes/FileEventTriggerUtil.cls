public class FileEventTriggerUtil {
    public static boolean isCaseObject(Id id){
        return id.getSObjectType() == Case.sObjectType;		
    }
    
    public static ContentDocument getContentDocumentObj(Id id){
        List<ContentDocument> contentDocumentList = [SELECT Id, CreatedDate, FileExtension, Title FROM ContentDocument WHERE Id = :id LIMIT 1];
        
        if(contentDocumentList == null || contentDocumentList.size() < 1){
            System.debug('Unable to find Content document details based on contentDocumentId: ' + id);
            return null;
        }
        return contentDocumentList.get(0);
    }
    
    public static boolean publishFileEvent(String fileId, String fileName, String caseId, Datetime createdOn){
        System.debug('Publishing event for fileId: '+ fileId + ' fileName: '+ fileName+' caseId: '+ caseId);
        List<Case> caseObj = [SELECT ContactId FROM Case WHERE Id = :caseId LIMIT 1];
        
        if(caseObj == null || caseObj.size() < 1){
            System.debug('Unable to find case details based on CaseId: ' + caseId);
            return false;
        }
        
        String contactId = caseObj.get(0).ContactId;
        System.debug('Found ContactId: '+ contactId);
        EApps_File_Platform_Event__e fileEvent = new EApps_File_Platform_Event__e(FileId__c = fileId, FileName__c = fileName, CaseId__c = caseId, ContactId__c = contactId, CreatedOn__c = createdOn);
        
        Database.SaveResult result = EventBus.publish(fileEvent);
        
        // Inspect publishing result for each event
        if (!result.isSuccess()) {
            for(Database.Error err : result.getErrors()) {
                System.debug('Error returned: ' +
                             err.getStatusCode() +
                             ' - ' +
                             err.getMessage());
            }
            return false;
        }
        return true;
    }
}