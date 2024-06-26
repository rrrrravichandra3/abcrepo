@isTest
public class FileEventTriggerUtilTest {
    
    @isTest static void isCaseObject() {
        Case caseObj = new Case();
        insert caseObj; 
        System.assertEquals(true, FileEventTriggerUtil.isCaseObject(caseObj.Id));
    }
    
    @isTest static void isNotCaseObject() {
        Contact contactObj = new Contact(LastName = 'Test'); 
        insert contactObj; 
        System.assertEquals(false, FileEventTriggerUtil.isCaseObject(contactObj.Id));
    }
    
    @isTest static void getNullForContentDocument(){
        Case caseObj = new Case();
        insert caseObj;         
        System.assertEquals(null, FileEventTriggerUtil.getContentDocumentObj(caseObj.Id));
    }
    
    @isTest static void publishFileEvent(){
        Contact contactObj = new Contact(LastName = 'Test'); 
        insert contactObj; 
        Case caseObj = new Case(ContactId = contactObj.Id);
        insert caseObj; 
        System.assertEquals(true,FileEventTriggerUtil.publishFileEvent('fileId', 'fileName', caseObj.Id, datetime.newInstance(2021, 05, 18, 12, 30, 0)));
    }
    
    @isTest static void noCaseToPublishFileEvent(){
        Case caseObj = new Case();
        System.assertEquals(false,FileEventTriggerUtil.publishFileEvent('fileId', 'fileName', caseObj.Id, datetime.newInstance(2021, 05, 18, 12, 30, 0)));
    }
}