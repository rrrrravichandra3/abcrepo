public without sharing abstract class PF_FormManager {
	
    protected User currentUser = getCurrentUser();
    
    public Map<String,Object> getFormInitialInformation(Map<String,Object> parameters){
        
        Map<String, Object> initialInformation = new Map<String, Object>();
        initialInformation.put('USER', currentUser);
        
        Map<String, Object> specificInformation = getFormSpecificInformation(parameters);
        if(specificInformation != null && !specificInformation.isEmpty()){
            initialInformation.putAll(specificInformation);
        }
        
        return initialInformation;
    }
    
    protected User getCurrentUser(){
        
        String query = 'SELECT contactid, contact.Division__c, contact.ES_DJC_Work_Location__c, contact.ES_DJC_Contact_Country__c, Contact.Name, Contact.Email, Contact.Phone,Contact.Start_Date__c';
		Id userId = USerInfo.getUserId();

        List<String> userFields = getUserFields();
        
        if(userFields != null && !userFields.isEmpty()){
            for(String field:userFields){
                query += (', ' + field);
            }
        }
        
        query += ' FROM User where id = :userId';
        
		List<User> users = Database.query(query);
        
        if(users.isEmpty()){
			throw new PF_FormsException('User not found');
        }
        
        return users.get(0);
    }
    
    protected void moveAttachmentsToCase(Id caseId, String attachmentsStoreId){
        
        if(caseId != null && attachmentsStoreId != null && !String.isBlank(attachmentsStoreId)){
            Attachment[] attachments = [SELECT Id, name, body, description from Attachment WHERE ParentId = :attachmentsStoreId];
            Attachment[] caseAttachments = new List<Attachment>();
            
            for(Attachment a:attachments){
                caseAttachments.add(new Attachment(name = a.name, body = a.body, parentId = caseId, description = a.description));
            }
            
            INSERT caseAttachments;
        }
    }
    
    protected abstract Map<String,Object> getFormSpecificInformation(Map<String,Object> parameters);
    
    protected abstract List<String> getUserFields();
    
    public abstract Id createCase(Map<String, Object> caseInformation, String attachmentsStoreId);
    
}