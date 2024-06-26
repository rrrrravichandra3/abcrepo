@isTest
public class PF_NHW_EmailConfiguratorTest {
	@isTest
	public static void validateGetComponentConfiguration() {
		PF_NHW_EmailConfigurator emailConfigObj = new PF_NHW_EmailConfigurator();
		String actualEmailHelpText;
		List<PF_NHW_LightningComponentAttribute> expectedListLtngCompAttr = new List<PF_NHW_LightningComponentAttribute>();

		actualEmailHelpText = NH_Settings__c.getOrgDefaults().Contractor_Email_Help_Text__c;
		expectedListLtngCompAttr = emailConfigObj.getComponentConfiguration(new Case(NHW_Employee_Type__c='contractor'));
		System.assertEquals(expectedListLtngCompAttr[0].value, actualEmailHelpText);

		actualEmailHelpText = NH_Settings__c.getOrgDefaults().Relocation_Email_Help_Text__c;
		expectedListLtngCompAttr = emailConfigObj.getComponentConfiguration(new Case(NHW_Employee_Type__c='relocation'));
		System.assertEquals(expectedListLtngCompAttr[0].value, actualEmailHelpText);

		actualEmailHelpText = NH_Settings__c.getOrgDefaults().FTE_Email_Help_Text__c;
		expectedListLtngCompAttr = emailConfigObj.getComponentConfiguration(new Case(NHW_Employee_Type__c='regular employee'));
		System.assertEquals(expectedListLtngCompAttr[0].value, actualEmailHelpText);
	}
}