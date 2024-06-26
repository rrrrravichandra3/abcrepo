/*
	Class to provide support for SST functionality. 
 */

public class NHW_SSTHelper {

	public static HTTPResponse performSSTCallOut(String searchString,String targetOrg,String accessToken,Onboarding_Setting__c onBoardingSetting){
		String targetEndpointUrl; 
		HTTPResponse res; 
		if(targetOrg == 'GUS'){
			targetEndpointUrl = onBoardingSetting.GUS_MyDomain_URL__c; 
		} else if(targetOrg == 'Supportforce'){
			targetEndpointUrl = onBoardingSetting.Supportforce_MyDomain_URL__c;
		} else if(targetOrg == 'Org62'){
			targetEndpointUrl = onBoardingSetting.Org62_My_Domain_URL__c; 
		}
		if(searchString == null){
			searchString ='';
		} else{
            searchString = searchString.replaceAll('\\*', '');
			searchString = searchString.replaceAll(' ', '+');
		}

		if(targetEndpointUrl == null){
			return null; 
		}

		targetEndpointUrl = targetEndpointUrl +'/services/data/v55.0/query/?q=';
		if(targetOrg == 'GUS'){
			targetEndpointUrl = targetEndpointUrl + 'SELECT+id,name,username,email+from+user+where+name+like+\'%25'+searchString+'%25\''+'and+Profile.PermissionsApiUserOnly=false+and+isactive=true+and+UserType+=+\'Standard\'+order+by+name+limit+50';
		}
		else{
			targetEndpointUrl = targetEndpointUrl + 'SELECT+id,name,username,email+from+user+where+name+like+\'%25'+searchString+'%25\''+'and+isactive=true+and+UserType+=+\'Standard\'+order+by+name+limit+50';
		}
		System.debug('targetUrl' + targetEndpointUrl);
		try{
			res = NHW_Util.performCallOut(targetEndpointUrl, accessToken, 'GET', null);
		} catch(Exception e){
			System.debug('call out exception');
			//throw exception .. 
			return null; 

		}
        
		return res;

	}


}