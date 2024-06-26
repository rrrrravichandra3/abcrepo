/**
 * @description       : Criteria parser for MA Acquisition Company Task
 * @author            : Satyam Kumar
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-06-2021   Satyam Kumar   Initial Version
 * 1.1   14-09-2021.  Ashtosh Belwal Enable different datatypes in query
**/
public without sharing class MA_TaskCriteriaParser {/*
    
    public static final Set<String> nonStringDataTypes = MA_Util.nonStringDataTypes;
    public static String getQuery(Id aCompanyId, List<AC_Task_Criteria__c> contactCriterias, List<AP_Task_Criteria__c> provisioningCriterias, List<Acquisition_Compensation_Task_Criteria__c> compensationCriterias){

        String whereClause = '';
        String provQuery = createProvQuery(provisioningCriterias);
        String compQuery = createCompQuery(compensationCriterias);
        String conQuery  = createConQuery(aCompanyId, contactCriterias);
        
        if(provQuery != null && String.isNotBlank(provQuery)) 
        {
            whereClause += ' AND Id IN ('+provQuery+')';
            if (compQuery != null && String.isNotBlank(compQuery)) 
            {
                whereClause += ' AND Id IN ('+compQuery+')';
            }
        } 
        else if(compQuery != null && String.isNotBlank(compQuery))  {
            whereClause += ' AND Id IN ('+compQuery+')';
            if (provQuery != null && String.isNotBlank(provQuery)) {
                whereClause += ' AND Id IN ('+provQuery+')';
            }
        }
        
        conQuery += whereClause;
        return conQuery;
    }
    
    public static String createProvQuery(List<AP_Task_Criteria__c> criterias){
        if(criterias == null ||(criterias != null && criterias.isEmpty())) {
            return null;
        }
        Integer count = 0;
        String query = 'Select Acquisition_Contact__c FROM Acquisition_Provisioning__c WHERE';
        String whereClause = '';
        Map<String, String> mapOfFieldVsDataType = MA_Util.getFieldsAndDataType('Acquisition_Provisioning__c');
        
        for(AP_Task_Criteria__c c : criterias) {
            
            String opperator = '';
            String operatorType = '';
            String dataType = mapOfFieldVsDataType.get(c.Field__c.toLowerCase());
            
            if(c.Operator__c == 'equals') {
                opperator = '=';
            }else if (c.Operator__c == 'does not equal'){
                opperator = '!=';
            }else if (c.Operator__c == 'contains'){
                opperator = 'like';
                operatorType = 'like';
            }else{
                opperator = 'like';
                operatorType = 'Not like';
            }
            
            if(!nonStringDataTypes.contains(dataType)){
                if(operatorType == 'like') {
                    whereClause += ' '+ c.Field__c + ' ' + opperator + ' ' + '\''+'%'+c.Value__c+'%'+'\' AND';
                } else if(operatorType == 'Not like') {
                    whereClause += ' (Not '+ c.Field__c + ' ' + opperator + ' ' + '\''+'%'+c.Value__c+'%'+'\'' + ') AND ';
                } else { 
                    whereClause += ' '+ c.Field__c + ' ' + opperator + ' ' + '\''+c.Value__c+'\' AND';
                }
            }else{
                whereClause += ' '+ c.Field__c + ' ' + opperator +c.Value__c +' AND ';
            }
            
        }
      
        
        query += whereClause.substring(0, whereClause.lastIndexOf('AND'));
        
        return query;
    }
    
    public static String createCompQuery(List<Acquisition_Compensation_Task_Criteria__c> criterias){
        if(criterias == null ||(criterias != null && criterias.isEmpty())) {
            return null;
        }
        
        Map<String, String> mapOfFieldVsDataType = MA_Util.getFieldsAndDataType('Acquisition_Compensation__c');
        String query = 'Select Acquisition_Contact__c FROM Acquisition_Compensation__c WHERE';
        String whereClause = '';
        
        for(Acquisition_Compensation_Task_Criteria__c c : criterias) {
            String opperator = '';
            String operatorType = '';
            String dataType = mapOfFieldVsDataType.get(c.Field__c.toLowerCase());
            
            if(c.Operator__c == 'equals') {
                opperator = '=';
            }else if (c.Operator__c == 'does not equal'){
                opperator = '!=';
            }else if (c.Operator__c == 'contains'){
                opperator = 'like';
                operatorType = 'like';
            }else{
                opperator = 'like';
                operatorType = 'Not like';
            }
            if(!nonStringDataTypes.contains(dataType)){
                if(operatorType == 'like') {
                    whereClause += ' '+ c.Field__c + ' ' + opperator + ' ' + '\''+'%'+c.Value__c+'%'+'\' AND ';
                } else if(operatorType == 'Not like') {
                    whereClause += ' (Not '+ c.Field__c + ' ' + opperator + ' ' + '\''+'%'+c.Value__c+'%'+'\'' + ') AND ';
                } else {
                    whereClause += ' '+ c.Field__c + ' ' + opperator + ' ' + '\''+c.Value__c+'\' AND ';
                }
            }else{
                whereClause += ' '+ c.Field__c + ' ' + opperator +c.Value__c +' AND ';
            }
        }
        
        
        query += whereClause.substring(0, whereClause.lastIndexOf('AND'));
        
        return query;
    }
    
    public static String createConQuery(id aCompanyId, List<AC_Task_Criteria__c> criterias){
        
        Map<String, String> mapOfFieldVsDataType = MA_Util.getFieldsAndDataType('Acquisition_Contacts__c');
        String query = 'Select Id FROM Acquisition_Contacts__c WHERE';
        String whereClause = '';
        
        for(AC_Task_Criteria__c c : criterias) {
            String opperator = '';
            String operatorType = '';
            String dataType = mapOfFieldVsDataType.get(c.Field__c.toLowerCase());
            
            // W-10273529 : Added new operators "less than", "less or equal", "greater than" & "greater or equal".
            if(c.Operator__c == 'equals') {
                opperator = '=';
            }else if(c.Operator__c == 'does not equal') {
                opperator = '!=';
            }else if(c.Operator__c == 'less than') {
                opperator = '<';
            }else if(c.Operator__c == 'less or equal') {
                opperator = '<=';
            }else if(c.Operator__c == 'greater than') {
                opperator = '>';
            }else if(c.Operator__c == 'greater or equal') {
                opperator = '>=';
            }else if(c.Operator__c == 'contains') {
                opperator = 'like';
                operatorType = 'like';
            }else if(c.Operator__c == 'does not contain') {
                opperator = 'like';
                operatorType = 'Not like';
            }

            if(!nonStringDataTypes.contains(dataType)){
                if(operatorType == 'like') {
                    whereClause += ' '+ c.Field__c + ' ' + opperator + ' ' + '\''+'%'+c.Value__c+'%'+'\'' + ' AND ';
                } else if(operatorType == 'Not like') {
                    whereClause += ' (Not '+ c.Field__c + ' ' + opperator + ' ' + '\''+'%'+c.Value__c+'%'+'\'' + ') AND ';
                } else {
                    whereClause += ' '+ c.Field__c + ' ' + opperator + ' ' + '\''+c.Value__c+'\'' + ' AND ';
                }
            }else{
                whereClause += ' '+ c.Field__c + ' ' + opperator +c.Value__c + ' AND ';
            }
        }
        whereClause += ' Acquisition_Company__c = '+'\''+aCompanyId+'\'';
        
        query += whereClause;
        
        return query;
    }
    
      
*/}