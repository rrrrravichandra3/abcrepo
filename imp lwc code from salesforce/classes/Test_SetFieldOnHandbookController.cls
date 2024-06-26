@isTest
private class Test_SetFieldOnHandbookController {

    public static testMethod void myTest() {
    	
    	Employee_Handbook__c employeeHandbook = [Select Id, Name From Employee_Handbook__c Limit 1 ];
    	
    	Pagereference reference = Page.SetFieldOnHandbook;
		reference.getParameters().put('id', employeeHandbook.Id);    	
    	Test.setCurrentPageReference(reference);
    	
    	Test.startTest();
    	
    	SetFieldOnHandbookController setField = new SetFieldOnHandbookController();
    	setField.Save();
	    	
    	Test.stopTest();
    }
}