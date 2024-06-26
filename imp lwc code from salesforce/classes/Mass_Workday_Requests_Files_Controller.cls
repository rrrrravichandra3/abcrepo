public class Mass_Workday_Requests_Files_Controller extends BaseDJCController{

    public String caseId{
        get; set;
    }
    
    public Boolean successfulOperation{get; set;} 
    
    public override String getRecordType(){
        return null;
    }
    
    public PageReference saveFiles(){
        
        Case newCase = [SELECT Id, Status FROM Case WHERE Id = :caseId];
        newCase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
        newCase.Status = 'New';
        
        Savepoint s = Database.setSavepoint();
        
        successfulOperation = false;
        
        List<Attachment> attachmentList = new List<Attachment>(); 
        if (attach1 != null){
            Blob b = Attach1;
            Attachment attachment = new Attachment(Name =FileName1,body = b,parentId=caseId,OwnerId = UserInfo.getUserId());
            attachmentList.add(attachment);
        }
        if (attach2 != null){
            Blob b = Attach2;
            Attachment attachment = new Attachment(Name =FileName2,body = b,parentId=caseId,OwnerId = UserInfo.getUserId());
            attachmentList.add(attachment);
        }
        if (attach3 != null){
            Blob b = Attach3;
            Attachment attachment = new Attachment(Name =FileName3,body = b,parentId=caseId,OwnerId = UserInfo.getUserId());
            attachmentList.add(attachment);
        }
        if (attach4 != null){
            Blob b = Attach4;
            Attachment attachment = new Attachment(Name =FileName4,body = b,parentId=caseId,OwnerId = UserInfo.getUserId());
            attachmentList.add(attachment);
        }
        if (attach5 != null){
            Blob b = Attach5;
            Attachment attachment = new Attachment(Name =FileName5,body = b,parentId=caseId,OwnerId = UserInfo.getUserId());
            attachmentList.add(attachment);
        }   
        if (attachmentList.size() > 0){
            try {
                insert attachmentList;
                update newCase;
                successfulOperation = true;
            }catch (DMLException e) {
                Database.rollback(s);                
                throw new AuraHandledException('GR:' + e.getdmlMessage(0));
            }
        }
        
        return null;
    }
}