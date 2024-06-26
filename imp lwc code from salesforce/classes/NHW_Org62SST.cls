/* SST callout to Org62 org.. This class implements NHW_SST interface and use fetchSSTUsers method to extract
	active Gus users.. 
 */


public class NHW_Org62SST implements NHW_SST{

	private static Onboarding_Setting__c onBoardingSetting = Onboarding_Setting__c.getInstance(); 
	public static String accessToken {
		set;
		get{
			if(accessToken == null){
				accessToken = NHW_Util.getAccessToken(onBoardingSetting.Org62_Token_Endpoint__c,onBoardingSetting.JWT_Aud_Endpoint__c,onBoardingSetting.PF_Certificate__c,onBoardingSetting.JWT_User_Name__c,onBoardingSetting.Org62_Consumer_Key__c);
			}
			return accessToken; 
		}

	}

	//implement interface method.. 
	public HttpResponse fetchSSTUsers(String searchStr){
		return NHW_SSTHelper.performSSTCallOut(searchStr,'Org62',accessToken,onBoardingSetting); 
	}
	
}