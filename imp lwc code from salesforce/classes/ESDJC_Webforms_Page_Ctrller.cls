public class ESDJC_Webforms_Page_Ctrller {
    
    
    public string  FieldSetName{get;set;}
    public string  ObjectName{get;set;}
    public string  recordId{get;set;}
    
    public ESDJC_Webforms_Page_Ctrller(){
        
        recordId =ApexPages.currentpage().getParameters().get('recordId');
        ObjectName =ApexPages.currentpage().getParameters().get('ObjectName');
        FieldSetName =ApexPages.currentpage().getParameters().get('FieldSetName');
        
        //Sanitizing user supplied input from parameter as they are directly used in SOQL.
        recordId = String.escapeSingleQuotes(recordId);
        ObjectName =String.escapeSingleQuotes(ObjectName);
        
        if(recordId== null || ObjectName == null || FieldsetName == null){
            throw new ApplicationException('No parameter or incorrect paramname passed - recordId,ObjectName,FieldSetName are mandatory parameters ');
        }
    }
}