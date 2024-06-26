@isTest
public class AcceptCaseCtrller_Test {
	@isTest
	public static void validateAcceptCaseCtrller() {
		Contact cont = new Contact();
		cont.LastName = 'Test cont';
		cont.Email = 'test@email.com';
		insert cont;

		List<Case> caseList = new List<Case>();
		for(Integer i=1;i<=5;i++){
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

		List<Id> cIds = new List<Id>();
		for(Case c : caseList){
			cIds.add(c.Id);
		}

		String caseIds = String.join(cIds, ',');

		AcceptCaseCtrller.updateCaseOwner(caseIds);

		caseList = [Select Id, OwnerId from Case where Id in : cIds];

		for(Integer i=1;i<=2;i++){
			System.assertEquals(caseList[i].OwnerId, UserInfo.getUserId());
		}
	}
}