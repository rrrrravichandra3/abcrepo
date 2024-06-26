public with sharing class ESDJC_ErrorController {
    public string supportEmail{get;set;}
    public String ssoURL{get;set;}
	public String url_redirect{get;set;}
	
    
    public ESDJC_ErrorController(){
        ESDJC_Settings__c supp = ESDJC_Settings__c.getInstance();
        supportEmail = supp.Support_Email__c;    
        ssoURL = ESDJC_Util.getSSOURL();
		List<String> url_split =ssoURL.split('services/auth',-1);
		if(url_split!=null && url_split.size()>0){
			url_redirect= url_split[0]+'?startURL='+ssoURL;
			
		}
    
    }
           
}