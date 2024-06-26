public class MA_LogCaseController {
    
    @AuraEnabled
    public static void submitCase(case newCase, Id articleId, String fileContents, String fileName, String contentType) {

        if(newCase != null){
            //Get default Queue name from Custom Settings.
            String defaultMAQueue = PF_MA_Settings__c.getInstance().Default_M_A_Queue_Name__c;
            List<String> queueNameList = new List<String>{defaultMAQueue};
            Map<String, Id> queueNameIdMap = new Map<String, Id>();
            String articleOwnerGroup;
            
            //Get Article Owner Group to find respective Queue
             if(String.isNotBlank(articleId)) {
                 System.debug(articleId +'  *** articleOwnerGroup*** '+[SELECT Article_Owner_Group__c FROM Knowledge__kav WHERE Id =: articleId]);
                 articleOwnerGroup = [SELECT Article_Owner_Group__c FROM Knowledge__kav WHERE Id =: articleId].Article_Owner_Group__c;
                 
            if(String.isNotBlank(articleOwnerGroup)) {
                queueNameList.add(articleOwnerGroup);
            }
  }           
            //Get Queue deatils along with default Queue to avoid repeated query
            for(Group selectedQueues : [SELECT Id, Name FROM Group WHERE  Type = 'Queue' AND NAME IN: queueNameList]) {
                queueNameIdMap.put(selectedQueues.Name, selectedQueues.Id);
            }
            
            //Get Queue Id and assign case to it
            if(queueNameIdMap != null && queueNameIdMap.containsKey(articleOwnerGroup)) {
                newCase.ownerId = queueNameIdMap.get(articleOwnerGroup);
            } else if(queueNameIdMap != null && queueNameIdMap.containsKey(defaultMAQueue)){
                newCase.ownerId = queueNameIdMap.get(defaultMAQueue);
            }
            
            //Get Contact associated to logged in Portal User
            Id contactId = [SELECT contactid FROM User WHERE Id =: Userinfo.getUserid()].contactId;
            if(!Test.isRunningTest())
            newCase.ContactId = contactId;
            newCase.Origin = 'M&A Community';
            Insert newCase; 
			system.debug('newCase*** '+newCase);
            
            //Handle attachment
            if(String.isNotBlank(newCase.Id) && String.isNotBlank(fileContents) && String.isNotBlank(fileName) && String.isNotBlank(contentType)) {
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S';
                conVer.PathOnClient = fileName;
                conVer.Title = fileName; // Display name of the files
                conVer.VersionData = EncodingUtil.base64Decode(fileContents); // converting your binary string to Blob
                insert conVer;
                
                //Get the content document Id from ContentVersion
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                
                //Create ContentDocumentLink
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = conDoc;
                cDe.LinkedEntityId = newCase.Id; // you can use objectId,GroupId etc
                cDe.ShareType = 'I';
                insert cDe;
            }
        }
    }
}