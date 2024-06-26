/**
 * This class contains unit tests for validating the behavior of Apex classes
 *  and triggers.
 * 
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a  production organization to confirm correctness, ensure code
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
private class Test_AgreementDocumentController 
{
	 static testMethod void testSave() 
	 {
		//Create a new terms and Conditions
	    Document agreement;
	    agreement= new Document();
		agreement.Name='testAgreementDoc.html';
		agreement.FolderId= [select id from folder f where f.developerName='Agreement_documents'].id;
		insert agreement;

	    //Create a new Agreement
	    Document termsAndConditions;
	    termsAndConditions = new Document();
	    termsAndConditions.Name='termsAndConditions.html';
	    termsAndConditions.FolderId=[select id from folder f where f.developerName='Agreement_documents'].id;
	    insert termsAndConditions;
	    
	    //Create a new Agreement document   	 	
        AgreementDocumentController controller = new AgreementDocumentcontroller();
		controller.doc.Name='Name of the Agreement';
		controller.doc.Body=Blob.valueOf('Content of the Agreement');
		controller.terms.Name='Name of the Terms and Conditions';
		controller.terms.Body=Blob.valueOf('Content of the terms and Conditions');
		controller.agree.TermsID__c=termsAndConditions.Id;
	    controller.agree.DocumentId__c=agreement.Id;
		controller.save();
		
		controller.getDocs();
	 }
	 
	 static testMethod void testrecordExist(){
	 	AgreementDocumentController controller = new AgreementDocumentcontroller();
	 	controller.doc.Name='asdfasf';
	 	controller.save();
	 	controller.cancel();
	 	Boolean myRecords= controller.recordsExist;
	 }
	 
	 static testMethod void testdocId(){
	 	AgreementDocumentController controller = new AgreementDocumentcontroller();
	 	String theId= AgreementDocumentController.docID();
	 }
	 
	 static testMethod void testsetSelected(){
	    String test='/apex/AgreementDocument';	
	     
	    //Create a new terms and Conditions
	    Document agreement;
	    agreement= new Document();
		agreement.Name='testAgreementDoc.html';
		agreement.FolderId= [select id from folder f where f.developerName='Agreement_documents'].id;
		insert agreement;
	    
	    //Create a new Agreement
	    Document termsAndConditions;
	    termsAndConditions = new Document();
	    termsAndConditions.Name='termsAndConditions.html';
	    termsAndConditions.FolderId=[select id from folder f where f.developerName='Agreement_documents'].id;
	    insert termsAndConditions;
	    
	    AgreementDocument__c agreementDocument;
	    //Create a new Agreement Document
	    agreementDocument = new AgreementDocument__c();
		agreementDocument.Name='testAgreement';
		agreementDocument.Active__c = true;
		agreementDocument.DocumentId__c=agreement.Id;
	    agreementDocument.TermsID__c=termsAndConditions.Id;
	    insert agreementDocument;
	    
	    
	    AgreementDocument__c agreementDocument2;
	    //Create a new Agreement Document
	    agreementDocument2 = new AgreementDocument__c();
		agreementDocument2.Name='testAgreement';
		agreementDocument2.Active__c = true;
		agreementDocument2.DocumentId__c=agreement.Id;
	    agreementDocument2.TermsID__c=termsAndConditions.Id;
	    
	    insert agreementDocument2;
	    
	    AgreementDocumentController controller = new AgreementDocumentcontroller();
	 	controller.theId=agreementDocument2.Id;
	 	controller.setSelected();

	 }
	 
	 static testMethod void testTermsId(){
	    //Create a new terms and Conditions
	    Document agreement;
	    agreement= new Document();
		agreement.Name='testAgreementDoc.html';
		agreement.FolderId= [select id from folder f where f.developerName='Agreement_documents'].id;
		insert agreement;

	    //Create a new Agreement
	    Document termsAndConditions;
	    termsAndConditions = new Document();
	    termsAndConditions.Name='termsAndConditions.html';
	    termsAndConditions.FolderId=[select id from folder f where f.developerName='Agreement_documents'].id;
	    insert termsAndConditions;
	    
	    AgreementDocument__c theAgreementDocument;
	    theAgreementDocument = new AgreementDocument__c();
		theAgreementDocument.Name='testAgreement';
		theAgreementDocument.Active__c=true;
		theAgreementDocument.DocumentId__c=agreement.Id;
		
		insert theAgreementDocument;
	       	 	
        AgreementDocumentController controller = new AgreementDocumentcontroller();
		controller.doc.Name='Name of the Agreement';
		controller.doc.Body=Blob.valueOf('Content of the Agreement');
		controller.terms.Name='Name of the Terms and Conditions';
		controller.agree.Active__c=true;
		controller.terms.Body=Blob.valueOf('Content of the terms and Conditions');
		controller.agree.TermsID__c=termsAndConditions.Id;
	    controller.agree.DocumentId__c=agreement.Id;
		controller.save();
		
		AgreementDocumentController.termsId();
	 }
	
	 static testMethod void testdeleter(){
        //Create a new terms and Conditions
	    Document agreement;
	    agreement= new Document();
		agreement.Name='testAgreementDoc.html';
		agreement.FolderId= [select id from folder f where f.developerName='Agreement_documents'].id;
		insert agreement;

	    //Create a new Agreement
	    Document termsAndConditions;
	    termsAndConditions = new Document();
	    termsAndConditions.Name='termsAndConditions.html';
	    termsAndConditions.FolderId=[select id from folder f where f.developerName='Agreement_documents'].id;
	    insert termsAndConditions;
	    
	    AgreementDocument__c theAgreementDocument;
	    theAgreementDocument = new AgreementDocument__c();
		theAgreementDocument.Name='testAgreement';
		theAgreementDocument.Active__c=false;
		theAgreementDocument.DocumentId__c=agreement.Id;
		
		insert theAgreementDocument;
	    	 	
        AgreementDocumentController controller = new AgreementDocumentcontroller();
		controller.doc.Name='Name of the Agreement';
		controller.doc.Body=Blob.valueOf('Content of the Agreement');
		controller.terms.Name='Name of the Terms and Conditions';
		controller.terms.Body=Blob.valueOf('Content of the terms and Conditions');
		controller.agree.TermsID__c=termsAndConditions.Id;
	    controller.agree.DocumentId__c=agreement.Id;
		controller.save();
		
	 	//GenEnvironment
	 	String id= theAgreementDocument.Id;
	 	
	 	//Save
	 	controller.theDeletedOne=id;
	 	controller.deleter();
	 	}
}