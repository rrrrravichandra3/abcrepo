public with sharing class PF_NHWAuraServices {
    
    private static String GENERAL_EXCEPTION_MESSAGE = 'Internal System Error';
    private static String STACK_TRACE = 'Stack Trace: ';
    public static String EMPLOYEEVIEWANDUPDATE_EXCEPTION_MESSAGE = Label.PF_NHW_EmployeeVIewUpdate_Exception_Message ;
    
    @AuraEnabled
    public static Map<String, Object> getPageInitialInformation(String flowType, String caseId, String pageName){
        try{
            PF_NHW_Page page = PF_NHW_Page.getPageNameByName(pageName);
    
            if(page != null){
                PF_NHW_PageService service = page.createService();
                return service.getPageInformation(flowType, caseId);
            }else{
                System.debug(System.LoggingLevel.ERROR, 'Error on PF_NHWAuraServices:getPageInitialInformation - Page misconfigured: ' + pageName);
            }
        }catch(AuraHandledException ex){
            throw ex;
        }catch(Exception ex){
            System.debug(System.LoggingLevel.ERROR, 'Error on PF_NHWAuraServices:getPageInitialInformation - ' + ex.getMessage() + ', ' + ex.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, STACK_TRACE + ex.getStackTraceString());
            if(flowType == 'employeeviewandupdate') {
                throw new AuraHandledException(EMPLOYEEVIEWANDUPDATE_EXCEPTION_MESSAGE);
            } else {
                throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
            }
        }
        throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
    }
    
    @AuraEnabled
    public static String processPageInformation(Map<String, Object> caseInformation, Map<String, Object> additionalInformation, String pageName, Boolean moveForward){
        try{
            Case provisioningCase = (Case)JSON.deserialize(JSON.serialize(caseInformation), Case.class);
            PF_NHW_Page page = PF_NHW_Page.getPageNameByName(pageName);
            
            if(page != null){
                PF_NHW_PageService service = page.createService();
                return service.processInformation(provisioningCase, additionalInformation, moveForward);
            }else{
                System.debug(System.LoggingLevel.ERROR, 'Error on PF_NHWAuraServices:processPageInformation - Page misconfigured: ' + pageName);
            }
        }catch(AuraHandledException ex){
            throw ex;
        }catch(Exception ex){
            System.debug(System.LoggingLevel.ERROR, 'Error on PF_NHWAuraServices:processPageInformation - ' + ex.getMessage() + ', ' + ex.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, STACK_TRACE + ex.getStackTraceString());
            if (ex.getMessage().containsIgnoreCase('STRING_TOO_LONG')) {
                throw new AuraHandledException(System.Label.PF_NHW_String_Too_Long_Exception_Message);
            } else {
                throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
            }
        }
        throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
    }
    
    @AuraEnabled
    public static PF_NHW_ProcessHandler.CaseProcessInformation getProcessStepsInformation(String flowType, String caseId){
        try{
            Case nhwCase = null;
            
            if(!String.isBlank(caseId)){
                nhwCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(caseId);
            }
            
            if(nhwCase != null){
                return PF_NHW_ProcessHandler.getProcessInformation(nhwCase);
            }else if(!String.isBlank(flowType)){
                return PF_NHW_ProcessHandler.getProcessInformation(flowType);
            }
        }catch(AuraHandledException ex){
            throw ex;
        }catch(Exception ex){
            System.debug(System.LoggingLevel.ERROR, 'Error on PF_NHWAuraServices:getProcessStepsInformation - ' + ex.getMessage() + ', ' + ex.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, STACK_TRACE + ex.getStackTraceString());
            throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
        }
        throw new AuraHandledException(GENERAL_EXCEPTION_MESSAGE);
    }
    
    @AuraEnabled
    public static PF_NHW_ProcessHandler.CaseProcessInformation getProcessPreviousStepInformation(String caseId){
        
        Case nhwCase = null;
        
        if(!String.isBlank(caseId)){
            nhwCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(caseId);
        }
        
        if(nhwCase != null){
            try{
                return PF_NHW_ProcessHandler.moveCaseBackward(nhwCase);
            }catch(PF_NHW_PreviousStepNotAllowedException ex){
                //Case is in the first step of the NHW and cannot be moved backward.  Null is returned for the app to navigate toward the landing page.
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public static PF_NHW_LightningComponentConfiguration getComponentConfiguration(Map<String, Object> caseInformation, String componentId){
        Case provisioningCase = (Case)JSON.deserialize(JSON.serialize(caseInformation), Case.class);
        return PF_NHW_LightningComponentsService.getComponentConfiguration(provisioningCase, componentId);
    }

    @AuraEnabled
    public static object  updateDetailsFromCloneHire(String pastCaseId, String currentCaseId, String flowType){
        Savepoint sp = Database.setSavepoint();
        try{
            //get the past case that was selected
            String fieldsetname;
            List<String> cloneFields = new List<String>();
            if(flowtype == PF_NHW_Process.FTE.name){
                fieldsetname ='NHW_FTE_Clone' ;
            }else if(flowtype == PF_NHW_Process.RELOCATION.name){
                fieldsetname ='NHW_Int_Relocation_Clone' ;
            }else{
                fieldsetname ='NHW_Contractor_Clone' ;               
            }
            
            Schema.FieldSet FS = Schema.SObjectType.Case.fieldSets.getMap().get(fieldsetname);
            for(Schema.FieldSetMember f : FS.getFields()){
                cloneFields.add(f.getFieldPath());               
            }
            String query = 'Select '+String.join(cloneFields, ',')+ ' FROM Case ' + ' where id=:pastCaseId';
            Case cloneCase = database.query(query);
                        
            
            //get the current case that is being worked on
            Case provisioningCase;
            if(!String.isBlank(currentCaseId)){
                provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(currentCaseId);
            }else if(!String.isBlank(flowType)){
                provisioningCase = PF_NHW_ProvisioningCaseStore.getEmptyProvisioningCase(PF_NHW_Process.getProcessByName(flowType));
            }
            
            //copy the fields from past case to current case
            For(String field:CloneFields){
                provisioningCase.put(field,CloneCase.get(field));
            }
            try {
                if(Case.sObjectType.getDescribe().isCreateable() && Case.sObjectType.getDescribe().isUpdateable()){
                    Database.upsert(provisioningCase, false);
                }
            }  catch (DmlException ex) { 
                system.debug('The following exception has occurred: ' + 
                             ex.getDmlStatusCode(0) + ex.getMessage());
            }
            //get existing NHW Software Access Provisioning recordds from current case. They will be replaced by cloned case's software access records
            List<NHW_Software_Access_Provisioning__c> existingCaseSoftwareProvisionings = [Select Provisioning_Case__c,Configuration__c,Provisioning_Id__c,Provisioning_name__c,Selected__c from NHW_Software_Access_Provisioning__c Where Provisioning_Case__c=:provisioningCase.Id];
            //Map them using provisioning Name as the key
            Map<String, NHW_Software_Access_Provisioning__c> existingCaseSoftwareProvisioningsMap = new Map<String,NHW_Software_Access_Provisioning__c>();
            for(NHW_Software_Access_Provisioning__c softProv : existingCaseSoftwareProvisionings){
                existingCaseSoftwareProvisioningsMap.put(softProv.Provisioning_name__c, softProv);
            }
            //get NHW Software Access Provisioning records from past case and copy their stats (exclude configuration field) to currentCase provisionings
            List<NHW_Software_Access_Provisioning__c> pastCaseSoftwareProvisionings = [Select Provisioning_Case__c,Configuration__c,Provisioning_Id__c,Provisioning_name__c,Selected__c from NHW_Software_Access_Provisioning__c Where Provisioning_Case__c=:pastCaseId ];
            for(NHW_Software_Access_Provisioning__c pastCaseSoftProv : pastCaseSoftwareProvisionings){
                if(!existingCaseSoftwareProvisioningsMap.containsKey(pastCaseSoftProv.Provisioning_name__c)){
                    existingCaseSoftwareProvisioningsMap.put(pastCaseSoftProv.Provisioning_name__c,new NHW_Software_Access_Provisioning__c());
                }
                NHW_Software_Access_Provisioning__c currentCaseSoftProv = existingCaseSoftwareProvisioningsMap.get(pastCaseSoftProv.Provisioning_name__c);
                currentCaseSoftProv.Provisioning_Case__c = provisioningCase.Id;
                currentCaseSoftProv.Provisioning_Id__c = pastCaseSoftProv.Provisioning_Id__c;
                currentCaseSoftProv.Provisioning_name__c = pastCaseSoftProv.Provisioning_name__c;
                currentCaseSoftProv.Selected__c = pastCaseSoftProv.Selected__c;
            }

            upsert existingCaseSoftwareProvisioningsMap.values();
            
            
            return provisioningCase;
        }
        catch(Exception ex){
             Database.rollback(sp);
             throw new AuraHandledException(ex.getMessage()+ex.getLineNumber());
        }
        
    }
}