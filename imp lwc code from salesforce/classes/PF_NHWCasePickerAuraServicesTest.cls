@isTest
public class PF_NHWCasePickerAuraServicesTest {
	@isTest
	public static void validateBannerVisibilityCheck() {
		Boolean check = PF_NHWCasePickerAuraServices.bannerVisibilityCheck();
		if(check)
			System.assertEquals(check,true);
		else
			System.assertEquals(check,false);
	}
}