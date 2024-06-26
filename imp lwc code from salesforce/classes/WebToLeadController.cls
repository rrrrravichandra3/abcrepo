public class WebToLeadController{

    public string baseUrl { get; private set;}
    public string webtoleadUrl { get; private set; }
    public Id orgId { get; private set; }
    
    public WebToLeadController(){
        baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        
        Boolean isSandboxFlag = runningInASandbox();
        
        if ( isSandboxFlag )
            webtoleadUrl = TF2Settings__c.getInstance().WebToLead_Sandbox_URL__c;
        else
            webtoleadUrl = TF2Settings__c.getInstance().WebToLead_Prod_URL__c;
            
        orgId = runningOrgId();
    }

    public static Boolean runningInASandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static Id runningOrgId(){
        return [SELECT Id FROM Organization LIMIT 1].Id;    
    }

    public static string getnameKanaID(){
        return leadFieldID('NameKana__c');
    }

    public static string getnameKanjiID(){
        return leadFieldID('NameKanji__c');
    }

    /*
    *   Method to read the field ID stored in custom setting "LeadObjectFieldIDs__c"
    *   Record name of the custom setting should be the API name of the field
    */
    private static String leadFieldID(String fieldAPIName){
        LeadObjectFieldIDs__c tempLead = LeadObjectFieldIDs__c.getInstance(fieldAPIName);
        String fieldId = '';
        if((tempLead!=null)&&(tempLead.ID__c!=null)){
            fieldId = tempLead.ID__c;
        }
        return fieldId;
    }

}