public with sharing class FileContainerController {
	public List<Attachment>	attached_files	{get;set;}
	public Attachment attached_file 		{get;set;}
	public Id		parent_id				{get;set;}
	public boolean	has_attachment			{get;set;}
	public string	message					{get;set;}
	public boolean	isProperty				{get;set;}
	public boolean	isUpSelected			{get;set;}	
	public Boolean	recentlyUploaded		{get;set;}
	public String 	fileID					{get;set;}
	public Boolean 	canAttachFile			{get;set;}
	public FileContainerController(){
		attached_files	= new List<Attachment>();
		attached_file 	= new Attachment();
		if (Apexpages.currentPage().getParameters().get('id') != null){
			parent_id		= Apexpages.currentPage().getParameters().get('id');	
		}else{
			parent_id		= Apexpages.currentPage().getParameters().get('prId');
		}
		
		isProperty		= false;
		fileID = '';
		List<Attachment> attach = new List<Attachment>();
		try{
			attached_files = [Select a.Id, a.Name From Attachment a Where a.ParentId =: parent_id limit 10];
			attach = [Select a.Id, a.Name From Attachment a where a.ParentId =:parent_id limit 1];	
		}catch(Exception e){
			System.debug('Error attached file : ' + e.getMessage());
		}
		
		 
		if(attach.size()>0){
			
			message = attach[0].Name;
			fileID 	= attach[0].Id;
		}
	
		recentlyUploaded = false;
	}
	public PageReference FileURL(){
		String str = '';
		if(fileID != null){
			str = 	'https://' + ApexPages.currentPage().getHeaders().get('Host') 
                	+ '/servlet/servlet.FileDownload?file='  + fileID;
		}
		if (!str.equals('')) {
			PageReference fileDescription = new PageReference(str);
			fileDescription.setRedirect(true); 
			
			return fileDescription;
		}
		return null;
	}
	
	
	public PageReference save_file() {
		
		if(!Schema.sObjectType.Attachment.isCreateable()){
			ApexPages.addmessage(
			new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation.'));
		}
		if(attached_file.name != null){
			
			attached_file.ParentId = parent_id;
			insert attached_file;
			message = attached_file.Name;
			fileID 	= attached_file.Id;
			//use the name of the uploaded file by default
			
			attached_file = new Attachment();
			attached_files = [Select a.Id, a.Name From Attachment a Where a.ParentId =: parent_id limit 10];
			recentlyUploaded = true;
				
		} else {
			message = 'Please select a valid file.';
		}
		return null;
	}
	
	
	public PageReference delete_file() {
		//delete the attach
		if(fileID != null && fileID != ''){
			deleteWithoutSharing aux = new deleteWithoutSharing();
			aux.delete_file(parent_id, fileID);
			attached_file 		= new Attachment();
			attached_files = [Select a.Id, a.Name From Attachment a Where a.ParentId =: parent_id limit 10];
			recentlyUploaded 	= false;
			message 			= '';
			fileID 				= '';	
		}
		 
					
		return null;
	}
	public without sharing class deleteWithoutSharing{
		public void delete_file(String parent_id, String file_id) {
		
			if (file_id != null && file_id != '' && Schema.sObjectType.Attachment.isDeletable()) {
				delete [select id from Attachment where ParentId =: parent_id And id =: file_id];
			}
		}
	}
}