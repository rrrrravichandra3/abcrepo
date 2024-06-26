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
public class GenerateEnviromentAgreementDocument {
	private static AgreementDocument__c theAgreementDocument;
	private static Document theDocument;
	
	public AgreementDocument__c getAgreementDocument(){
		return theAgreementDocument;
	}
	public Document getDocument(){
		return theDocument;
	}
	public static void genEnviroment(){
		createAgreementAndDoc();
		
	}
	private static String the1stID;
	private static String the2ndID;
	public static String getId1(){
		return the1stID;	
	}
	public static string getId2(){
		return the2ndID;
	}
	private static void createAgreementAndDoc(){
		theAgreementDocument = new AgreementDocument__c();
		theAgreementDocument.Name='testAgreement';
		theAgreementDocument.Active__c=false;
		theDocument= new Document();
		theDocument.Name='testAgreementDoc.html';
		theDocument.FolderId= [select id from folder f where f.developerName='Agreement_documents'].id;
		theAgreementDocument.DocumentId__c=theDocument.Id;
		insert theDocument;
		insert theAgreementDocument;
	}
	@isTest
	static void test(){
		GenerateEnviromentAgreementDocument.createAgreementAndDoc();
		GenerateEnviromentAgreementDocument.getId1();
		GenerateEnviromentAgreementDocument.getId2();
		GenerateEnviromentAgreementDocument controller = new GenerateEnviromentAgreementDocument();
		controller.getAgreementDocument();
		controller.getDocument();
	}
}