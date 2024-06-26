@isTest
public class CaseListViewController_Test {
	@isTest
	public static void validateCaseListViewController() {
		Contact cont = new Contact();
		cont.LastName = 'Test cont';
		cont.Email = 'test@email.com';
		insert cont;
		List<Case> caseList = new List<Case>();
		for(Integer i=1;i<=10;i++){
			Case c = new Case();
			c.ContactId = cont.Id;
			c.Origin = 'Phone';
			c.Subject = 'Test Sub '+i;
			c.Type = 'Test type';
			c.Status = 'New';
			c.PII__c = 'No';
			caseList.add(c);
		}
		insert caseList;
		ApexPages.StandardSetController standardSetCtrl = new ApexPages.StandardSetController(caseList);
		sObject[] selectedCases = caseList;
		standardSetCtrl.setSelected(selectedCases);
		CaseListViewController acptCaseLstViewCtr = new CaseListViewController(standardSetCtrl);

		for(Integer i=1;i<=5;i++){
			System.assertEquals(acptCaseLstViewCtr.selectedCaseIds[i], selectedCases[i].Id);
		}
	}
}