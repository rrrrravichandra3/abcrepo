public class NHW_SupportforceService {

	private static Onboarding_Setting__c onBoardingSetting = Onboarding_Setting__c.getInstance(); 
	public static String accessToken {
		set;
		get{
			if(accessToken == null){
				try{
					accessToken = NHW_Util.getAccessToken(onBoardingSetting.Supportforce_Token_Enpdoint__c,onBoardingSetting.JWT_Aud_Endpoint__c,onBoardingSetting.PF_Certificate__c,onBoardingSetting.Supportforce_JWT_Username__c,onBoardingSetting.Supportforce_Consumer_Key__c);
					} catch(Exception e){}
				
			}
			return accessToken; 
		}

	}


	public static void createSupportforceContact(String sfContactJson){
		try{
			NHW_Util.performCallOut(onBoardingSetting.Supportforce_Contact_Creation_URL__c, accessToken, 'POST', sfContactJson);
		} catch(Exception e){}
	}


}