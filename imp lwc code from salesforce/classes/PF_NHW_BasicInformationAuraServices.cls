public with sharing class PF_NHW_BasicInformationAuraServices {

    @AuraEnabled
    public static Boolean calculateIsExactTarget(Id businessUnitId){
        List<Business_Unit__c> bus = [SELECT Id, Name FROM Business_Unit__c WHERE Id = :businessUnitId];
        
        if(!bus.isEmpty()){
            for(NHW_Exact_Target_BU__c exactTarget: NHW_Exact_Target_BU__c.getall().values()){
                String exactTargetBunit = exactTarget.Business_Unit__c;
                String busName = bus[0].Name;
                if(exactTargetBunit != null && busName != null && exactTargetBunit.substring(0,4) == busName.substring(0,4)){
                    return true;
                }
            }
            return false;
        }
        return null;
    }
    
    @AuraEnabled
    public static String getManagerEmail(Id managerId){
        
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Id = :managerId];
        
        if(!contacts.isEmpty()){
            return contacts[0].Email;
        }
        return null;
    }
    
    @AuraEnabled
    public static map<string,object>  updateDetailsFromCloneHire(String pastCaseId, String currentCaseId, String flowType){
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
            system.debug('flowType'+flowType);
            system.debug('currentCaseId'+currentCaseId);
            Schema.FieldSet FS = Schema.SObjectType.Case.fieldSets.getMap().get(fieldsetname);
            for(Schema.FieldSetMember f : FS.getFields()){
                cloneFields.add(f.getFieldPath());               
            }
            String query = 'Select '+String.join(cloneFields, ',')+ ' FROM Case ' + ' where id=:pastCaseId';
            Case cloneCase = database.query(query);
                        
            System.debug('cloneCase :'+cloneCase);
            //get the current case that is being worked on
            Case provisioningCase;

            if(!String.isBlank(currentCaseId)){
                //Check if currentCaseId is preboardingcase in order to generate Provisioning Case appropriately.
                Case CurrentCase= [select id,RecordTypeId from case where id=:currentCaseId];
                if(CurrentCase.RecordTypeId ==  NHW_Util.getnhwPreBoardCaseRecordTypeId()){
                    provisioningCase = PF_NHW_ProvisioningCaseStore.generateProvisioningCaseFromPreboardingCase(currentCaseId);              
                }else{
                	provisioningCase = PF_NHW_ProvisioningCaseStore.getProvisioningCaseById(currentCaseId);                    
                }
            }else if(!String.isBlank(flowType)){
                provisioningCase = PF_NHW_ProvisioningCaseStore.getEmptyProvisioningCase(PF_NHW_Process.getProcessByName(flowType));
            }
            System.debug('provisioningCase Before :'+provisioningCase);

            //copy the fields from past case to current case
            For(String field:CloneFields){
                provisioningCase.put(field,CloneCase.get(field));
            }
            
            System.debug('provisioningCase After :'+provisioningCase);

            map<string,object> mCaseInfo = new map<string,object>();
            mCaseInfo.put('CASE', provisioningCase);
            mCaseInfo.put('CLONECASEID', CloneCase.ID);
            RETURN mCaseInfo;

        }
        catch(Exception ex){
              system.debug('error:'+ex.getMessage()+ex.getLineNumber());
             throw new AuraHandledException(ex.getMessage()+ex.getLineNumber());
        }
        
    }
}