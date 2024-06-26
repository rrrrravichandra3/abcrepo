@isTest
private class Test_CompensationRedirectController {

    public static testMethod void myUnitTest() {
    	
    	Compensation__c comp = [Select c.Name, c.Id, c.Compensation_Plan__c From Compensation__c c Where Compensation_Plan__c=:'LTIB' Limit 1][0];
    	
    	if(comp != null){
    		System.currentPageReference().getParameters().put('id', comp.Id);
    		
    		Apexpages.Standardcontroller testController = new Apexpages.Standardcontroller(comp);
    		CompensationRedirectController compRedirect = new CompensationRedirectController(testController);

    		System.assertEquals(comp.Compensation_Plan__c, 'LTIB');
    		System.assert(compRedirect.isLTIB(), True);
    		
    		//Pagereference pageRef = compRedirect.goToProperPage();
    		//System.assert( pageRef != null);
    		
    		Pagereference pageRef = new PageReference('/apex/ltibAgreement?id='+comp.Id);
    		System.assertEquals(pageRef.getURL(),compRedirect.goToProperPage().getUrl());
       	}	
    }
}