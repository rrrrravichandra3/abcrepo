/**
* #DreamJobCentral
* @date:        07/25/2013
* @description: Controller for ESDJC_UnauthorizedError page. When timeout occurs we need to redirect user to login page. 
**/


public class ESDJC_UnauthorizedErrorController{
	
	public String ssoURL{get;set;}
	public String url_redirect{get;set;}
	
	public ESDJC_UnauthorizedErrorController(){
		ssoURL = ESDJC_Util.getSSOURL();
		List<String> url_split =ssoURL.split('services/auth',-1);
		if(url_split!=null && url_split.size()>0){
			url_redirect= url_split[0]+'?startURL='+ssoURL;
			
		}
		
	}
	
	public PageReference redirectLoginPage(){
		PageReference pg;
		  if(url_redirect!=null){
			 pg = new PageReference(url_redirect);
			 return pg;
		}
		return null;
	}
}