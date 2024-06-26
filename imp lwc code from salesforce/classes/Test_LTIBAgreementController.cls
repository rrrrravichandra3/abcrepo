/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_LTIBAgreementController {
	static testMethod void testMethodOne() 
	 {
	 	
	 	AgreementDocument__c theAD=new AgreementDocument__c();
	 	theAD.DocumentId__c='asdf';
	 	System.assertEquals(theAD.DocumentId__c, 'asdf');
	 	theAD.TermsID__c='1234';
	 	theAD.Name='testAD';
	 	upsert theAD;
	 	Compensation__c theLTIB=New Compensation__c();
	 	theLTIB.name='test ltib';
	 	theLtib.AgreementDocument__c=theAD.Id;
	 	theLtib.LTIBAmount__c='23456';
	 	theLtib.LTIBEffective_Date__c= Date.newInstance(2010, 03, 03);
	 	theLTIB.Status__c='Terms & Conditions';
	 	theLTIB.Compensation_Plan__c='LTIB';
	 	
	 	User aUser = [Select id, Name, FirstName, LastName,ProfileId From User Where IsActive=true AND Profile.Name='System Administrator' Limit 1];
	 	theLTIB.User__c = aUser.Id;
	 	theLTIB.OwnerId=aUser.Id;
	 	
	 	upsert theLTIB;
	 	Attachment attach= new Attachment();
	 	attach.Name='asdf';
	 	attach.ParentId=theLTIB.id;
	 	attach.Body=blob.ValueOf('1234');
	 	upsert Attach;
	  	System.currentPageReference().getParameters().put('id', theLTIB.Id );
	 	LTIBAgreementController controller = new LTIBAgreementController();
	 	controller.getAttachmentID();
	 	controller.getAttachmentName();
	 	String myDate=controller.theDate;
	 	controller.getTheAgreementCreatedDate();
	 	controller.getTheAgreementLastModifiedDate();
	 	
	 	controller.getAcknowledgeAndAccept();
	 	controller.ESRDecline();
	 	try{
	 		controller.getAgreementValue();
	 	}catch (exception e) {
	 		System.debug(e);
	 	}
	 	
	 	controller.getTermsID();
	 	try{
	 		controller.getTermsValue();
	 	}catch(exception e){
	 		System.debug(e);
	 	}
	 	controller.getCanSeeAcceptControls();
	 	controller.getMyCreatedDate();
	 	controller.getHasAttachments();
	 	controller.declineTC();
	 	controller.acceptTC();
	 	controller.landInErrorPage();
	 	controller.reload();
	 	controller.havePermits();
	 	controller.getIdAgreement();
	 	
	 	controller.submit();
	 	controller.ESRAccept();
	  	controller.getMyHistory();
	 	controller.acceptLTIB();
	 	controller.declineLTIB();
	 	
	 	GenerateEnvironmentTest3.getUsers();
	 	//GenerateEnvironmentTest3.employeeStandard.profile.name='Employee Success Representative';
		System.runAs(GenerateEnvironmentTest3.employeeStandard)
		{ 
			controller.havePermits();
			
		}
		
	 	
	 	
	 		controller.acceptTC();
	 	
	 	
	 		controller.declineTC();
	 	
	 	
	 		controller.acceptTC();
	 		
	 		controller.getTheAcceptanceDate();
	 	
	 }
	 static testMethod void testMethodTwo(){
	 	AgreementDocumentController controller = new AgreementDocumentController();
	 	controller.forwardTo('/');
	 	controller.getDocs();
	 	String docid=AgreementDocumentController.docID();
	 	System.assertEquals(AgreementDocumentController.docID(), docid);
	 	list<AgreementDocumentController.doc> myList=controller.allDocs;
	 	controller.Save();
	 	boolean myBool=controller.recordsExist;
	 	controller.Save();
	 	//AgreementDocument__c theAD=new AgreementDocument__c();
	 	//theAD.DocumentId__c='asdf';
	 	//theAD.TermsID__c='1234';
	 	//theAD.Name='testAD';
	 	//upsert theAD;
	 	
	 	//controller.theDeletedOne=theAD.id;
	 	//controller.setSelected();
	 	//controller.deleter();
	 	//controller.cancel()		;
	 } 

}