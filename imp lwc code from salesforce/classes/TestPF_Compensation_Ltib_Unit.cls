@isTest
private class TestPF_Compensation_Ltib_Unit {
	static testmethod void testmethod1(){
		User theUser=[select id, name from User where isActive=true and profile.name='System Administrator' limit 1];
		Compensation__c comp = new Compensation__c();
		comp.Compensation_Plan__c='LTIB';
		comp.User__c=theUser.id;
		comp.Annual_Award_Payment__c='$ 1234 ';
		comp.LTIBAmount__c='$ 234';
		AgreementDocument__c theAD=new AgreementDocument__c();
	 	theAD.DocumentId__c='asdf';
	 	theAD.TermsID__c='1234';
	 	theAD.Name='testAD';
	 	upsert theAD;
	 	comp.AgreementDocument__c=theAD.id;
	 	insert comp;
	}	
	
}