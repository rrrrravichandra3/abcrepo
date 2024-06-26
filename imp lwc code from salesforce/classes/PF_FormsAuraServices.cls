public with sharing class PF_FormsAuraServices {
    
    private static final String GENERAL_EXCEPTION_MESSAGE = 'Internal System Error';
    
    @AuraEnabled
    public static Map<String, Object> loadFormInitialInformation(String formId, Map<String,Object> parameters){
        PF_FormManager formManager = getFormManager(formId);
        return formManager.getFormInitialInformation(parameters);
    }
    
    @AuraEnabled
    public static CaseCreated submitRequest(String formId, String storeId, Map<String,Object> caseInformation){

        try{ 
            PF_FormManager formManager = getFormManager(formId);
            Id caseId = formManager.createCase(caseInformation, storeId);
            
            Case c = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseId];
            
            return new CaseCreated(c.CaseNumber, c.Id);
        }catch(AuraHandledException ex){
            throw ex;
        }catch(Exception ex){
            System.debug(System.LoggingLevel.ERROR, 'Error on PF_FormsAuraServices:createCase - ' + ex.getMessage() + ', ' + ex.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, 'Stack Trace: ' + ex.getStackTraceString());
            throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
        }
    }

    
    @AuraEnabled
    public static Id createAttachmentsStore(){
        PF_Attachment__c attachment = new PF_Attachment__c();
        INSERT attachment;
        return attachment.Id;
    }
    
    private static PF_FormManager getFormManager(String formId){
        
        String formManagerClassName = getFormManagerName(formId);
        
        try{
            Type t = Type.forName(formManagerClassName);
            return (PF_FormManager)t.newInstance();
        }catch(Exception ex){
            System.debug(System.LoggingLevel.ERROR, 'Error on PF_FormsAuraServices:getFormManager - ' + ex.getMessage());
            throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
        }
    }
    
    private static String getFormManagerName(String formId){
        
        try{
            PF_Form_Configuration__mdt  config = [SELECT Manager_Class_Name__c FROM PF_Form_Configuration__mdt WHERE Id__c = :formId];
            return config.Manager_Class_Name__c;
        }catch(Exception ex){
            System.debug(System.LoggingLevel.ERROR, 'Error on PF_FormsAuraServices:getFormManagerName - ' + ex.getMessage());
            throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
        }
        
    }
    
    private class PicklistOption{
        
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        
        private PicklistOption(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    private class CaseCreated{
        
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String caseId;
        
        private CaseCreated(String caseNumber, String caseId){
            this.caseNumber = caseNumber;
            this.caseId = caseId;
        }
    }
}