@isTest
private class TestPF_UserListPaginationController {

    static testMethod void Test_CompenationEditController() {
    	Test.startTest();
    		ListID__c listUserIDs = new ListID__c();
    		String Id = userInfo.getUserId();
    		String collection = Id + ';';
    		listUserIDs.CollectionID__c = collection;
    		insert listUserIDs;
    		System.currentPageReference().getParameters().put('uIDs', listUserIDs.Id);
    		UserListPaginationController usrPagination = new UserListPaginationController();
    		
    		usrPagination.next();
    		usrPagination.previous();
    		usrPagination.cancel();
    	Test.stopTest();
    }
}