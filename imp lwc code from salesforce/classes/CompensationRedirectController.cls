public with sharing class CompensationRedirectController {
	public Id CompensationID{get;set;}
	public Compensation__c comp;
	public CompensationRedirectController(ApexPages.StandardController stdController){
		CompensationID=System.currentPageReference().getParameters().get('id');
		comp=[select Compensation_Plan__c from Compensation__c where id=:compensationID][0];
	}
	public boolean isLTIB(){
		boolean isltib = false;
		if(comp.Compensation_Plan__c =='LTIB'){
			isltib=true;
		}
		return isltib;
	}
	public pageReference goToProperPage(){
		if(isLTIB()){
			return new PageReference('/apex/ltibAgreement?id='+CompensationID);
		}
		else{
			return new PageReference('/' + CompensationID + '?nooverride=0');
		}
	}
}