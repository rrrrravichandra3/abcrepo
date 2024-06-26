/* SST callout to Supportforce org.. This class implements NHW_SST interface and use fetchSSTUsers method to extract
	active Gus users.. 
 */


public class NHW_SupportforceSST implements NHW_SST {
	private static Onboarding_Setting__c onBoardingSetting = Onboarding_Setting__c.getInstance(); 
	public static String accessToken {
		set;
		get{
			if(accessToken == null){
				accessToken = NHW_Util.getAccessToken(onBoardingSetting.Supportforce_Token_Enpdoint__c,onBoardingSetting.JWT_Aud_Endpoint__c,onBoardingSetting.PF_Certificate__c,onBoardingSetting.Supportforce_JWT_Username__c,onBoardingSetting.Supportforce_Consumer_Key__c);
			}
			return accessToken; 
		}

	}

	//implement interface method.. 
	public HttpResponse fetchSSTUsers(String searchStr){
		return NHW_SSTHelper.performSSTCallOut(searchStr,'Supportforce',accessToken,onBoardingSetting); 
	}


}