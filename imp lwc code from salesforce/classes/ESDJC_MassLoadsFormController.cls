public with sharing class ESDJC_MassLoadsFormController{
    
    private static ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
    
    private static final String INVALID_DATE_MESSAGE = 'Please select a date no more than 30 days in the past';
    
    @AuraEnabled
    public static Case saveCase(Case massLoadsCase){
        
        if(massLoadsCase.ES_DJC_Report_Request_Due_Date__c < Date.today().addDays(-30)){
            throw new AuraHandledException('ED:' + INVALID_DATE_MESSAGE);
        }
        
        massLoadsCase.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
        massLoadsCase.Subject = 'Mass Workday Update Request for ' + getUser().Contact.Name;
        
        Savepoint s = Database.setSavepoint();
        
        try{
            insert massLoadsCase;
        }catch (DMLException e) {
            Database.rollback(s);
            throw new AuraHandledException('GR:' + e.getdmlMessage(0));
        }
        
        return massLoadsCase;
    }
    
    @AuraEnabled
    public static String getRecordType(){
        
        User user = getUser();
        
        String region = ESDJC_Util.getRegionFromDivision(getUser().contact.Division__c);
        String recordType = null;
        
        if (region == ESDJC_Util.REGION_AMER){
            recordType = settings.All_Cases_Except_ER_AMER_RT__c;
        }else if (region == ESDJC_Util.REGION_APAC){
            recordType = settings.All_Cases_Except_ER_APAC_RT__c;
        }else if (region == ESDJC_Util.REGION_EMEA){
            recordType = settings.All_Cases_Except_ER_EMEA_RT__c;
        }else if (region == ESDJC_Util.REGION_JAPAN){
            recordType = settings.All_Cases_Except_ER_Japan_RT__c;
        }
        return recordType;
    }
    
    private static User getUser(){
        User currentUser = [select username, contactid, contact.Division__c, contact.ES_DJC_Work_Location__c, contact.ES_DJC_Contact_Country__c,
                    contact.DJC_Contact_Floor__c,contact.DJC_Contact_Building__c, contact.DJC_Contact_Cube_Workstation__c, Contact.Name, Contact.recordType.name,
                    Contact.Email, Contact.Phone
                    from user where id = :UserInfo.getUserId()];
        return currentUser;
    }
}