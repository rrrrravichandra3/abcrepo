/* SST callout to GUS org.. This class implements NHW_SST interface and use fetchSSTUsers method to extract
	active Gus users.. 
*/

public class NHW_GusSST implements NHW_SST {

	private static Onboarding_Setting__c onBoardingSetting = Onboarding_Setting__c.getInstance(); 
  	public static String accessToken {
      set;
    get{
      if(accessToken == null){
        accessToken = NHW_Util.getAccessToken(onBoardingSetting.GUS_Token_Endpoint__c,onBoardingSetting.JWT_Aud_Endpoint__c,onBoardingSetting.PF_Certificate__c,onBoardingSetting.GUS_JWT_UserName__c,onBoardingSetting.Gus_Consumer_Key__c);
      }
      return accessToken; 
    }

  }

	//implement interface method.. 
	public HttpResponse fetchSSTUsers(String searchStr){
		return NHW_SSTHelper.performSSTCallOut(searchStr,'GUS',accessToken,onBoardingSetting); 
	}

}