@isTest
private class TestPF_SetFieldOnHandbookController_Unit {

    public static testMethod void myTest() {
    
        Employee_Handbook__c employeeHandbook2 = new Employee_Handbook__c();
        insert employeeHandbook2;
        
        Employee_Handbook__c employeeHandbook = [Select Id,Status__c From Employee_Handbook__c limit 1];
        
        Pagereference reference = Page.SetFieldOnHandbook;
        reference.getParameters().put('id', employeeHandbook.Id);       
        Test.setCurrentPageReference(reference);  
        SetFieldOnHandbookController setField = new SetFieldOnHandbookController();
        setField.Save();
            
    }
}