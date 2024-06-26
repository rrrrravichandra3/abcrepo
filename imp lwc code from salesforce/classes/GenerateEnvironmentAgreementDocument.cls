/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: Mauricio Bustamante  $
 * $Change:  $
 * $DateTime: 01/05/2010 $
 * $File: AgreementDocumentController.cls $
 * $Id:  $
 * $Revision:  $
 */
public class GenerateEnvironmentAgreementDocument {
	private static AgreementDocument__c theAgreementDocument;
	private static Document theDocument;
	private static AgreementDocument__c the2ndAgreementDocument;
	private static Document the2ndDocument;
	private static String the1stID;
	private static String the2ndID;
	public AgreementDocument__c getAgreement(){
		return theAgreementDocument;
	}
	public  String getId1(){
		return the1stID;	
	}
	public string getId2(){
		return the2ndID;
	}
	
	public static  AgreementDocument__c getAgreementDocument(){
		return theAgreementDocument;
	}
	public static Document getDocument(){
		return theDocument;
	}
	public static void genEnviroment(){
		createAgreementAndDoc();
		
	}
	private static void createAgreementAndDoc(){
		theAgreementDocument = new AgreementDocument__c();
		theAgreementDocument.Name='testAgreement';
		theAgreementDocument.Active__c=false;
		the2ndAgreementDocument = new AgreementDocument__c();
		the2ndAgreementDocument.name='2ndTestAgreement';
		theDocument= new Document();
		theDocument.Name='testAgreementDoc.html';
		theDocument.body=Blob.valueOf('asd');
		theDocument.FolderId= [select id from folder f where f.developerName='Agreement_documents'].id;
		the2ndDocument= new Document();
		the2ndDocument.FolderId=theDocument.FolderId;
		the2ndDocument.body=Blob.valueOf('123');
		the2ndDocument.Name='2ndTestAgreementDoc';
		theAgreementDocument.DocumentId__c=theDocument.Id;
		the1stID=theAgreementDocument.Id;
		the2ndID=the2ndDocument.Id;
		insert theDocument;
		insert the2ndDocument;
		insert the2ndAgreementDocument;
		insert theAgreementDocument;
		
	}
	
	
}