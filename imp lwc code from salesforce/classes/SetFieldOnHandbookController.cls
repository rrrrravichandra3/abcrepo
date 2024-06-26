/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author Mike Fullmore - 4/2/2009
*/

public with sharing class SetFieldOnHandbookController {
    
    public SetFieldOnHandbookController()
    {
        
    }

    public void Save()
    {
    	if(!Schema.sObjectType.Employee_Handbook__c.isUpdateable()){
    		ApexPages.addmessage(
			new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation.'));
    	}
        Id id = System.currentPageReference().getParameters().get('id');
        Employee_Handbook__c employeeHandbook = [select Id, Status__c From Employee_Handbook__c Where Id =: id ];
        System.debug(employeeHandbook);
        V2MOM_Util.cancelUpdateInHandBook = false;  
        employeeHandbook.Status__c = 'Completed';
        //Here Update filed
        
        update employeeHandbook;

        V2MOM_Util.cancelUpdateInHandBook = true;
        
    }
}