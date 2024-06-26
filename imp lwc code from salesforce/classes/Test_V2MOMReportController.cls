@isTest
private class Test_V2MOMReportController {


	public static User employee;
	public static V2MOM__c v2mom;
	public static User manager;
	public static Profile userProfile;
	public static Profile userProfileManager;
	public static User userAux;
	public static List<User> employees;

	public static testMethod void testV2MOMReportController() {

		v2mom = [select Effective_Date__c, V2MOM_Type__c from V2MOM__c limit 1];
		employee = GenerateEnvironmentTestUsers.createEmployeeWithManager();

		System.currentPageReference().getParameters().put('effectiveDate', v2mom.Effective_Date__c);
		System.currentPageReference().getParameters().put('hierarchy', 'MyEntireTeam');
		System.currentPageReference().getParameters().put('v2momType', v2mom.V2MOM_Type__c);



		V2MOMReportController controller = new V2MOMReportController();

		controller.getUsersWithNoV2MOM();
		controller.getEffectiveDate();
		controller.getV2MOMType();
		controller.getPercentNotSubmitted();
		controller.getPercentApproved();
		controller.getPercentNotCreated();
		controller.getPercentPendingApproval();
		controller.getPercentRejected();
		controller.getPercentRequiresReApproval();
		controller.getAllV2MOMByFYAndHierarchy();
		//controller.getUserInHierarchy();
		controller.getNumberV2MOMNotSubmitted();
		controller.getNumberV2MOMNotCreated();
		controller.getNumberV2MOMPendingApproval();
		controller.getNumberV2MOMRejected();
		controller.getNumberV2MOMRequiresReApproval();
		controller.getNumberV2MOMApproved();
		controller.showReport();
		controller.getManagerCurrentUsersCount();
		controller.getCurrentProccessItem();
		controller.getAllEmployessHidden();
		controller.setAllEmployessHidden('');
		controller.getAllEmployessHiddenTwo();
		controller.setAllEmployessHiddenTwo('');
		controller.getCurrentUser();
		controller.getManager();
		controller.getPcomm();
		controller.getSortedBy();
		controller.getHierarchy();
		controller.setUsersWithNoV2MOM(new List<User>());
		controller.getIsPCOMMOrFirstManager();
		


		controller.orderByDepartment();
		controller.orderByStatus();
		controller.orderByManager();
		controller.processDirectReports();
		controller.processOnlyDirectReports();
		controller.processUsersWithoutV2MOM();
		controller.getEmployeesFirstLevel(); 	
		controller.getUserId();
		controller.setUserId(controller.getUserId());
		controller.setV2MOMType('Department');
		controller.getEmployeesAux();
		controller.getEmployeeBelow( GenerateEnvironmentTest.getManager() );
		
    V2MOMReportController.CustomV2MOM v2moms = new V2MOMReportController.CustomV2MOM(v2mom,employee);
    v2moms.getFirstInEmployee();
    v2moms.getV2MOM();
    v2moms.getV2MOMOwner();
    v2moms.setV2MOM(v2mom);
    v2moms.setFirstInEmployee(true);
	
	}
	
	public static testMethod void testV2MOMReportController2() {

		v2mom = [select Effective_Date__c, V2MOM_Type__c from V2MOM__c limit 1];
		employee = GenerateEnvironmentTestUsers.createEmployeeWithManager();

		System.currentPageReference().getParameters().put('effectiveDate', v2mom.Effective_Date__c);
		System.currentPageReference().getParameters().put('hierarchy', 'MyEntireTeam');
		System.currentPageReference().getParameters().put('v2momType', v2mom.V2MOM_Type__c);
		System.currentPageReference().getParameters().put('manager', GenerateEnvironmentTest.getManager().Id );


		V2MOMReportController controller = new V2MOMReportController();

		System.currentPageReference().getParameters().put('effectiveDate', v2mom.Effective_Date__c);
		System.currentPageReference().getParameters().put('hierarchy', 'MyEntireTeam');
		System.currentPageReference().getParameters().put('v2momType', v2mom.V2MOM_Type__c);
		System.currentPageReference().getParameters().put('manager', 'All' );
		System.currentPageReference().getParameters().put('pcomm', GenerateEnvironmentTest.getPCOMMUser().Id );
		User pcomm = GenerateEnvironmentTest.getPCOMMUser();
		pcomm = [select id, profile.name from user where id=:pcomm.Id];
		
		controller = new V2MOMReportController();
		controller.currentUser = pcomm;
		controller.getIsPCOMMOrFirstManager();
		User mngr = GenerateEnvironmentTest.getManager();
		mngr = [select id, name, profile.name from user where id=:mngr.id];
		mngr.Manager__c = null;
		controller.currentUser = mngr;
		controller.getIsPCOMMOrFirstManager();
		mngr.Manager__c = pcomm.Id;
		controller.currentUser = mngr;
		controller.getIsPCOMMOrFirstManager();
		
		employee = [select id, manager__c from user where id=:GenerateEnvironmentTest.getEmployeeStandard().Id];
		List<User> users = new List<User>();
		users.add(employee);
		controller.getEmployeesAux3(employee, employees, 1);
		

		
	}
	
	public static testMethod void testV2MOMReportController3() {

		v2mom = [select Effective_Date__c, V2MOM_Type__c from V2MOM__c limit 1];
		employee = GenerateEnvironmentTestUsers.createEmployeeWithManager();

		System.currentPageReference().getParameters().put('effectiveDate', v2mom.Effective_Date__c);
		System.currentPageReference().getParameters().put('hierarchy', 'MyEntireTeam');
		System.currentPageReference().getParameters().put('v2momType', v2mom.V2MOM_Type__c);
		System.currentPageReference().getParameters().put('manager', GenerateEnvironmentTest.getManager().Id );
		System.currentPageReference().getParameters().put('sortedBy', 'Department');
		

		V2MOMReportController controller = new V2MOMReportController();
		controller.orderByDepartment();
		
		System.currentPageReference().getParameters().put('effectiveDate', v2mom.Effective_Date__c);
		System.currentPageReference().getParameters().put('hierarchy', 'MyEntireTeam');
		System.currentPageReference().getParameters().put('v2momType', v2mom.V2MOM_Type__c);
		System.currentPageReference().getParameters().put('manager', GenerateEnvironmentTest.getManager().Id );
		System.currentPageReference().getParameters().put('sortedBy', 'Status');
		
		controller = new V2MOMReportController();
		controller.orderByStatus();
		
		System.currentPageReference().getParameters().put('effectiveDate', v2mom.Effective_Date__c);
		System.currentPageReference().getParameters().put('hierarchy', 'MyEntireTeam');
		System.currentPageReference().getParameters().put('v2momType', v2mom.V2MOM_Type__c);
		System.currentPageReference().getParameters().put('manager', GenerateEnvironmentTest.getManager().Id );
		System.currentPageReference().getParameters().put('sortedBy', 'Manager');
		
		controller = new V2MOMReportController();
		controller.orderByManager();
		controller.getUserInHierarchy();
		
		System.currentPageReference().getParameters().put('effectiveDate', v2mom.Effective_Date__c);
		System.currentPageReference().getParameters().put('hierarchy', 'MyEntireTeam');
		System.currentPageReference().getParameters().put('v2momType', v2mom.V2MOM_Type__c);
		System.currentPageReference().getParameters().put('sortedBy', 'Manager');
		System.currentPageReference().getParameters().put('pcomm', GenerateEnvironmentTest.getPCOMMUser().Id );
		System.currentPageReference().getParameters().put('allEmployessHidden', GenerateEnvironmentTest.getEmployeeStandard().Id );
		System.currentPageReference().getParameters().put('allEmployessHiddenTwo', GenerateEnvironmentTest.getEmployeeStandard().Id );
		
		
		controller = new V2MOMReportController();
		
		
		User mngr = GenerateEnvironmentTest.getManager();
		mngr = [select id, profile.name, manager__c from user where id=:mngr.Id limit 1];
		controller.currentUser = mngr;
		controller.processDirectReports();
		controller.getUserInHierarchy();
	}
}