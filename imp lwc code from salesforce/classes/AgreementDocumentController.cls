/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: Mauricio Bustamante  $
 * $Change:  $
 * $DateTime: 12/20/2009 $
 * $File: AgreementDocumentController.cls $
 * $Id:  $
 * $Revision:  $
 */
 
/*
 * This class will manage all CRUD operation for AgreementDocument Object
 * @author Mauricio Bustamante
*/
public with sharing class AgreementDocumentController {
	public AgreementDocument__c agree{get;set;}
	public Document doc {get;set;}
	public Document terms{get;set;}
	public String theId{get;set;}	
	public list<Doc> allDocs{get;set;}
	public List<AgreementDocument__c> docs;
	public static String PAGE_OBJECT_LIST='/apex/AgreementDocument';
	public static String PAGE_OBJECT_NEW_INSTANCE = '/apex/AgreementDocument';
	public String theDeletedOne{get;set;}
	public Boolean recordsExist{get{
		return [select name, Active__c,id, documentId__c, CreatedDate from AgreementDocument__c limit 1000].size()>0;
	}set;}
	public AgreementDocumentController (){
			allDocs=new list<Doc>();
			agree = new AgreementDocument__c();
			doc= new Document();
			terms= new Document();
			docs = [select name, Active__c,id, documentId__c, TermsID__c, CreatedDate, AcknowledgeAndAccept__c from AgreementDocument__c Order By CreatedDate desc limit 1000];
			for(AgreementDocument__c theDoc:docs){
				Doc d = new Doc(theDoc);
				allDocs.add(d);
			}
	}
	
    public static String docId(){
    	return [select documentID__c from AgreementDocument__c where active__c=true limit 1].documentID__c;
    }
    public static String termsId(){
    	return [select termsId__c,documentID__c from AgreementDocument__c where active__c=true limit 1].documentID__c;
    }
    /**
	* Save AgreementDocument and Document
    * @return PageReference to reload page with updated changes
    */
	public PageReference Save(){
		if((doc.Body!=null)&&(terms.Body!=null))
		{
			agree.Name=doc.Name;
			terms.Name=doc.Name + '-terms.html';
			doc.Name=doc.Name+'.html';
			doc.FolderId = [select id from folder f where f.developerName='Agreement_documents'].id;
			terms.FolderID=[select id from folder f where f.developerName='Terms_Conditions'].id;
			insert doc;
			insert terms;
			agree.termsID__c=terms.Id;
			agree.DocumentId__c=doc.id;
			insert agree;
			
		}
		return forwardTo(PAGE_OBJECT_LIST);
	}
	/**
	* Create a pageReference from an url in a string
    * @return PageReference
    */
	
	public PageReference forwardTo(String url)
	{
		PageReference page= new Pagereference(url);
		page.setRedirect(true);
		return page;
	}
	/**
	* @return PageReference to reload page when button pressed
    */
		public PageReference cancel()
	{
		return forwardTo(PAGE_OBJECT_LIST);
	}
	 
	public list<AgreementDocument__c> getDocs()
	{
		
	docs = [select name, Active__c,id, documentId__c,TermsID__c, CreatedDate from AgreementDocument__c Order By CreatedDate desc limit 1000];
	for(AgreementDocument__c theDoc:docs){
		Doc d = new Doc(theDoc);
		allDocs.add(d);
	}	
	return docs;
	}
	
	/**
	* Sets active to true in the selected AgreementDocument__c and the previous active one to false.
    * @return PageReference to reload page with updated changes
    */
	
	public PageReference setSelected(){
		if(theid!=''){
			AgreementDocument__c[] agree = [select id, Active__c from AgreementDocument__c where Active__c=true];
			agree[0].Active__c=false;
			update agree;
			AgreementDocument__c[] newDefault = [select id, Active__c from AgreementDocument__c where id=:theId];
			newDefault[0].Active__c=true;
			update newDefault;
		}
	return forwardTo(PAGE_OBJECT_LIST);
		
	}
	/**
	* Deletes the selected AgreementDocument__c
    * @return PageReference to reload page with updated changes
    */
	
	public PageReference deleter() {
		AgreementDocument__c[] comp = [select id, DocumentId__c from AgreementDocument__c c where c.id=:theDeletedOne];
		Document[] doc = [select id from Document d where d.id=:comp[0].DocumentId__c];
		delete doc[0];
		delete comp;
		return forwardTo(PAGE_OBJECT_NEW_INSTANCE);
		
		
		
	}
	/*
	*
	* Inner class to keep the agreementDocument with an accesible date with custom format, and the Document name.
    *
    */
	
	public class Doc
	{
		public String myDate{get;set;}
		public String myDocumentName{get;set;}
		public AgreementDocument__c theAgreement{get;set;}
		public Doc(AgreementDocument__c anAgreement){
			theAgreement=anAgreement;
			myDate=anAgreement.CreatedDate.format('MM/dd/yyyy hh:mm');
			//myDocumentName=[Select name from Document  where id=:anAgreement.DocumentId__c].name;
			myDocumentName = anAgreement.name;
		}
		
	}
}