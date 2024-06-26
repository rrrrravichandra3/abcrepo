/*
* ===========================================================================
* Timba Confidential
*
* Timba Surveys
*
* (C) Copyright Timba Software Corp., 2009-2011.
*
* The source code for this program is not published or otherwise divested of
* its trade secrets, irrespective of what has been deposited with the U.S.
* Copyright office.
*
*/
@isTest
private class Test_SetControllerHandler {

	static testMethod void SetControllerHandler(){
		generateSurveyEnviroment.gen();
		Account acc 	= new Account( Name='FooAcc' );
		insert acc;
		List<Contact> contactList = new List<Contact>();
		for (Integer i = 0; i<40; i++){
			Contact tempContact = new Contact();
			tempContact.FirstName = 'Foo FirstName ' + i;
			tempContact.LastName = 'Foo LastName ' + i;
			tempContact.Email = 'foo' + i + '@mail.com';
			contactList.add(tempContact);
		}
		insert contactList;
		Contact contact = new Contact( LastName='FooLast' , FirstName='FooFirst' , Email='foo@mail.com' , AccountId=acc.Id );
		insert contact;

		Test.startTest();
			ApexPages.currentPage().getParameters().put('Page','3');
			SetControllerHandler sch = new SetControllerHandler();
			system.assertNotEquals(sch, null);
			system.assertEquals(sch.pageSize, null);

		 	sch.setQuery('SELECT Id, Name FROM Contact limit 30');
		 	system.assertNotEquals(sch.pageSize, null);

			List<Sobject> result = sch.getQuery();
			system.assertEquals(result.isEmpty(), false);

			system.assertEquals(sch.getRenderPrevious(), false);
			system.assert( sch.getRenderNext() );

			sch.GoNext();
			system.assert( sch.getRenderPrevious() );
			//system.assert( sch.getRenderNext() );

			sch.GoPrevious();
			system.assert( !sch.getRenderPrevious() );
			system.assert( sch.getRenderNext() );

			sch.GoFirst();
			system.assert( !sch.getRenderPrevious() );
			system.assert( sch.getRenderNext() );

			sch.GoLast();
			system.assert( sch.getRenderPrevious() );
			system.assert( !sch.getRenderNext() );

			system.assert( sch.getTotalPages()!=1 );
			sch.getRecordSize();
			sch.getNumericPaginationSet();
			sch.getAlphabeticPaginationSet();
			sch.getPage();
			sch.setPage();

			ApexPages.currentPage().getParameters().put('op','byChar');
			ApexPages.currentPage().getParameters().put('field','Name');
			ApexPages.currentPage().getParameters().put('param','a');
			sch.searchBy();
			ApexPages.currentPage().getParameters().put('op','byWord');
			ApexPages.currentPage().getParameters().put('field','Name');
			ApexPages.currentPage().getParameters().put('param','john');
			sch.searchBy();

			SetControllerHandler sch2 = new SetControllerHandler();
			sch2.setQuery('SELECT Id, Name FROM Contact Where Name Like \'%a\' limit 30');
			ApexPages.currentPage().getParameters().put('op','byWord');
			ApexPages.currentPage().getParameters().put('field','Name');
			ApexPages.currentPage().getParameters().put('param','john');
			sch2.searchBy();

			sch.pageSize = null;
			sch.setQueryList(result);
			system.assert( sch.pageSize!=null );
			sch.refreshList();
		Test.stopTest();
	}

}