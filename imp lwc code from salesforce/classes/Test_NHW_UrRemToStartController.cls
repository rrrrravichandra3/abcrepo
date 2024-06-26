@isTest
public with sharing class Test_NHW_UrRemToStartController {

	private static String STANDARD_BU = '0000';
	private static String STANDARD_CC = '1111';

	private static String BU_T_AND_P = '1234';
	private static String BU_FINANCE = '4567';
	private static String BU_IT = '9012';

	private static String CC_T_AND_P = '1472';
	private static String CC_FINANCE = '2583';
	private static String CC_IT = '6914';

	private static String IMAGE_AND_ACCESS_T_AND_P = 'ABC';
	private static String IMAGE_AND_ACCESS_FINANCE = 'DEF';
	private static String IMAGE_AND_ACCESS_IT = 'GHI';

	private static String LAPTOP_T_AND_P = 'Laptop 1';
	private static String LAPTOP_FINANCE = 'Laptop 2';
	private static String LAPTOP_IT = 'Laptop 3';

	private static String WORKSTATION_IMAGE_T_AND_P = 'WI 1';
	private static String WORKSTATION_IMAGE_FINANCE = 'WI 2';
	private static String WORKSTATION_IMAGE_IT = 'WI 3';

	private static String WORKSTATION_T_AND_P = 'W 1';
	private static String WORKSTATION_FINANCE = 'W 2';
	private static String WORKSTATION_IT = 'W 3';



	public static testMethod void testUrgentReminderToStartTAndP(){

		init();

		NHW_UrRemToStartController controller = new NHW_UrRemToStartController();

		controller.costCenter = CC_T_AND_P + '-Cost center T&P';
		controller.businessUnit = BU_T_AND_P + '-Business unit T&P';

		System.assert(!controller.standardEmployee);
		System.assertEquals(IMAGE_AND_ACCESS_T_AND_P, controller.imageAndAccess);
		System.assertEquals(LAPTOP_T_AND_P, controller.laptop);
		System.assertEquals(WORKSTATION_IMAGE_T_AND_P, controller.workstationImage);
		System.assertEquals(WORKSTATION_T_AND_P, controller.workstation);
	}

	public static testMethod void testUrgentReminderToStartFinance(){

		init();

		NHW_UrRemToStartController controller = new NHW_UrRemToStartController();

		controller.costCenter = CC_FINANCE + '-Cost center Finance';
		controller.businessUnit = BU_FINANCE + '-Business unit Finance';

		System.assert(!controller.standardEmployee);
		System.assertEquals(IMAGE_AND_ACCESS_FINANCE, controller.imageAndAccess);
		System.assertEquals(LAPTOP_FINANCE, controller.laptop);
		System.assertEquals(WORKSTATION_IMAGE_FINANCE, controller.workstationImage);
		System.assertEquals(WORKSTATION_FINANCE, controller.workstation);
	}

	public static testMethod void testUrgentReminderToStartIT(){

		init();

		NHW_UrRemToStartController controller = new NHW_UrRemToStartController();

		controller.costCenter = CC_IT + '-Cost center IT';
		controller.businessUnit = BU_IT + '-Business unit IT';

		System.assert(!controller.standardEmployee);
		System.assertEquals(IMAGE_AND_ACCESS_IT, controller.imageAndAccess);
		System.assertEquals(LAPTOP_IT, controller.laptop);
		System.assertEquals(WORKSTATION_IMAGE_IT, controller.workstationImage);
		System.assertEquals(WORKSTATION_IT, controller.workstation);
	}

	public static testMethod void testUrgentReminderToStartStandardEmployee(){

		init();

		NHW_UrRemToStartController controller = new NHW_UrRemToStartController();

		controller.costCenter = STANDARD_CC + '-Cost center standard employee';
		controller.businessUnit = STANDARD_BU + '-Business unit standard employee';

		System.assert(controller.standardEmployee);
		System.assertEquals(null, controller.imageAndAccess);
		System.assertEquals(null, controller.laptop);
		System.assertEquals(null, controller.workstationImage);
		System.assertEquals(null, controller.workstation);
	}

	private static void init(){

		NHW_DP_Cost_Centers__c buTAndP = new NHW_DP_Cost_Centers__c(Name = 'BU-' + BU_T_AND_P, Business_Unit_Id__c = BU_T_AND_P, Profile_Name__c = 'T&P');
		NHW_DP_Cost_Centers__c buFinance = new NHW_DP_Cost_Centers__c(Name = 'BU-' + BU_FINANCE, Business_Unit_Id__c = BU_FINANCE, Profile_Name__c = 'Finance');
		NHW_DP_Cost_Centers__c buIT = new NHW_DP_Cost_Centers__c(Name = 'BU-' + BU_IT, Business_Unit_Id__c = BU_IT, Profile_Name__c = 'IT');

		NHW_DP_Cost_Centers__c ccTAndP = new NHW_DP_Cost_Centers__c(Name = 'CC-' + CC_T_AND_P, Cost_Centers_id__c = CC_T_AND_P, Profile_Name__c = 'T&P');
		NHW_DP_Cost_Centers__c ccFinance = new NHW_DP_Cost_Centers__c(Name = 'CC-' + CC_FINANCE, Cost_Centers_id__c = CC_FINANCE, Profile_Name__c = 'Finance');
		NHW_DP_Cost_Centers__c ccIT = new NHW_DP_Cost_Centers__c(Name = 'CC-' +CC_IT, Cost_Centers_id__c = CC_IT, Profile_Name__c = 'IT');

		List<NHW_DP_Cost_Centers__c> costCenters = new List<NHW_DP_Cost_Centers__c>{buTAndP, buFinance, buIT, ccTAndP, ccFinance, ccIT};

		insert costCenters;

		NHW_Default_Profiles__c profileTAndP = new NHW_Default_Profiles__c(
			Name = 'DP-1',
			Profile_Name__c = 'T&P',
			Image_and_Access__c = IMAGE_AND_ACCESS_T_AND_P,
			Laptop__c = LAPTOP_T_AND_P,
			Workstation_Image__c = WORKSTATION_IMAGE_T_AND_P,
			Workstation__c = WORKSTATION_T_AND_P);

		NHW_Default_Profiles__c profileFinance = new NHW_Default_Profiles__c(
			Name = 'DP-2',
			Profile_Name__c = 'Finance',
			Image_and_Access__c = IMAGE_AND_ACCESS_FINANCE,
			Laptop__c = LAPTOP_FINANCE,
			Workstation_Image__c = WORKSTATION_IMAGE_FINANCE,
			Workstation__c = WORKSTATION_FINANCE);

		NHW_Default_Profiles__c profileIT = new NHW_Default_Profiles__c(
			Name = 'DP-3',
			Profile_Name__c = 'IT',
			Image_and_Access__c = IMAGE_AND_ACCESS_IT,
			Laptop__c = LAPTOP_IT,
			Workstation_Image__c = WORKSTATION_IMAGE_IT,
			Workstation__c = WORKSTATION_IT);

		List<NHW_Default_Profiles__c> profiles = new List<NHW_Default_Profiles__c>{profileTAndP, profileFinance, profileIT};

		insert profiles;
	}
}