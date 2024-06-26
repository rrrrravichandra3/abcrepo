@isTest

class TestPF_BtchblRlHrrchyCrtr_Unit {

	static testmethod void roleCreationTest() {
		
		//createUserData();
		
		String theQuery = 'select id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId from User where UserType != \'Guest\' order by LastName limit 10'; //and email like \'%@testorg.com\' limit 200';
		BatchableRoleHierarchyCreator con = new BatchableRoleHierarchyCreator(theQuery);
		Test.startTest();
		database.executeBatch(con);
		Test.stopTest();
		
	}
	
	static testmethod void roleAssignmentTest() {
		
		//createUserData();
		
		String theQuery = 'select id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId from User where UserType != \'Guest\' order by LastName limit 10'; //and email like \'%@testorg.com\' limit 200';
		BatchableRoleHierarchyAssignment con = new BatchableRoleHierarchyAssignment(theQuery);
		Test.startTest();
		database.executeBatch(con);
		Test.stopTest();
		
	}
	
	static testmethod void roleLinkerTest() {
		
		//createUserData();
		
		String theQuery = 'select id, FirstName, LastName, EmployeeNumber, Manager__c, UserRoleId from User where UserType != \'Guest\' order by LastName limit 10'; //and email like \'%@testorg.com\' limit 200';
		BatchableRoleHierarchyLinker con = new BatchableRoleHierarchyLinker(theQuery);
		Test.startTest();
		database.executeBatch(con);
		Test.stopTest();
		
	}
/*	
	private static void createUserData() {
		try {
		Profile prof = [select id from profile where name='Standard User'];
		User u1 = new User(alias = 'standt', email='standarduser11@testorg.com', 
		emailencodingkey='UTF-8', FirstName='First1',lastname='TestingLast1', languagelocalekey='en_US', 
		localesidkey='en_US', profileid = prof.Id, 
		timezonesidkey='America/Los_Angeles', username='stdandarduser11@testorg.com');
		insert u1;
		User u2 = new User(alias = 'standt2', email='standarduser22@testorg.com', 
		emailencodingkey='UTF-8', FirstName='First2',lastname='TestingLast2', languagelocalekey='en_US', 
		localesidkey='en_US', profileid = prof.Id, 
		timezonesidkey='America/Los_Angeles', username='standarduser22@testorg.com', Manager__c = u1.Id);
		insert u2;
		User u3 = new User(alias = 'standt3', email='standarduser33@testorg.com', 
		emailencodingkey='UTF-8', FirstName='First3',lastname='TestingLast3', languagelocalekey='en_US', 
		localesidkey='en_US', profileid = prof.Id, 
		timezonesidkey='America/Los_Angeles', username='standarduser33@testorg.com', Manager__c = u1.Id);
		insert u3;
		User u4 = new User(alias = 'standt4', email='standarduser44@testorg.com', 
		emailencodingkey='UTF-8', FirstName='First4',lastname='TestingLast4', languagelocalekey='en_US', 
		localesidkey='en_US', profileid = prof.Id, 
		timezonesidkey='America/Los_Angeles', username='standarduser44@testorg.com', Manager__c = u3.Id);
		insert u4;
		} catch (Exception e) {
			
		}
	}
*/
}