/**
* Controller class for Filter Criteria LWC Component
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         08-12-2021      Ashutosh Belwal         Initial Version
* v2.0         07-08-2022      Ashutosh Belwal         Added logic to create custom logics for filter criteria
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public class MA_ManageFilterCriteria{
    public class FilterCriteriaException extends Exception {}

    private static final Set<String> IGNORE_AC_FIELDS = new Set<String>{'Acquisition_Company_Name__c', 'Acquisition_Company__c'};
	/**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Genrates map of field as api name and schema of field as value
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    objectName		 	   	    DESCRIPTION (Data type String, Object Name)
    * @return   String                      DESCRIPTION (returns serialized response containing map of fields and schema)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    
    @AuraEnabled(cacheable=true)
    public static String getFieldsSchema(String objectName){
        try {
            SObjectType acqContact = Schema.getGlobalDescribe().get(objectName);
            DescribeSObjectResult describe = acqContact.getDescribe();
            Map<String,Schema.SObjectField> mfields = describe.fields.getMap();
            
            Map<String , FieldSchema> sObjectDetailsMap = new Map<String , FieldSchema>();
            for(String s : mfields.keySet()){
                Schema.DescribeFieldResult fieldDescribe = mfields.get(s).getDescribe();
                if(fieldDescribe.isFilterable()){
                    FieldSchema obj 	= new FieldSchema();
                    obj.fieldApiName 	= String.valueOf(mfields.get(s));
                    obj.fieldLabel 	 	= String.valueOf(fieldDescribe.getLabel());
                    obj.fieldDataType  	= String.valueOf(fieldDescribe.getType());
                    
                    if(!IGNORE_AC_FIELDS.contains(obj.fieldApiName)){
                        if(obj.fieldDataType == 'PICKLIST'){
                            Map<String, String> options = new Map<String, String>();
                            for( Schema.PicklistEntry f : fieldDescribe.getPicklistValues())
                            { 
                                if(!(obj.fieldApiName == 'Contact_Status__c' && f.getValue() == 'Cancelled')){
                                    options.put(f.getValue() , f.getLabel());
                                }
                            }
                            obj.picklistValues = options;
                        }
                        sObjectDetailsMap.put(String.valueOf(mfields.get(s)) , obj);
                    }
                }
                
            }
            return JSON.serialize(sObjectDetailsMap) ;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * 
    * Wrapper class for formating sobject field schema
    * 
    */
    private class FieldSchema{
        public String fieldApiName;
        public String fieldLabel;
        public String fieldDataType;
        public Map<String, String> picklistValues;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * To update the sObject record
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId		 	   	    DESCRIPTION (Data type Id, recordId)
    * @param    criteria		 	   	    DESCRIPTION (Data type String, Json string of filter criteria)
    * @param    queryString		 	   	    DESCRIPTION (Data type String, SOQL Query String)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled
    public static void updateFilterCriteriaJSON(Id recordId, String criteria, String queryString){
        String objectName = recordId.getSObjectType().getDescribe().getName();

        try {
           
            List<sObject> lstTestRecord = database.query(queryString+' LIMIT 1');
            

            sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject() ;
            sObj.put('Id', recordId);
            sObj.put('Filter_Criteria_JSON__c', criteria);
            if(objectName == 'Acquisition_Company_Task__c'){
              sObj.put('Criteria_Last_Modified_Date__c', system.now());
            }
            sObj.put('Filter_Criteria_Query__c', queryString);
            
            update sObj;
           
        }catch(QueryException e){
            if(e.getMessage().containsIgnoreCase('invalid ID')){
                throw new AuraHandledException(System.Label.MA_Invalid_Id_Error);
            }else{
                throw new AuraHandledException(System.Label.MA_Invalid_Filter_Criteria);
            }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * To Retrieve the sObject record information
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    recordId		 	   	    DESCRIPTION (Data type Id, recordId)
    * @return   sObjectRecord		 	   	DESCRIPTION (Data type sObject, sObject record Information(Ex Community Event))
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static sObject getRecordDetails(Id recordId){
        try{
            String objectName = recordId.getSObjectType().getDescribe().getName();
            sObject sObjectRecord = database.query('SELECT Id, Filter_Criteria_JSON__c, Acquisition_Company__c  FROM '+objectName+' WHERE Id =: recordId LIMIT 1');
            return sObjectRecord;
        }catch (Exception e) {            
            throw new AuraHandledException(e.getMessage());
        }
    }
}