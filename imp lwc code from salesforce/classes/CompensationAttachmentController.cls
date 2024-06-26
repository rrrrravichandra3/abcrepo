public with sharing class CompensationAttachmentController {
	public List<Compensation__c> compensations;
	public String compIDs 					{get; set;}
	public boolean error					{get; set;}
	public Blob recordFile 					{get; set;}
	public String recordName				{get; set;}
	public Id currentCompensation 		    {get; set;}
	public boolean showAttach				{get; set;}
	public Attachment attached_file 		{get; set;}
	public List<Attachment> attachedFiles	{get; set;}
	public String fileExtension				{get; set;}
	public List<String> commonFileExtensions{get; set;}
	public Document doc 					{get; set;}
	public String docURL					{get; set;}
	private ListID__c compensationIDs 		{get; set;}
	private Id 	  cIDs				 	    {get; set;}
	public String filePath					{get; set;}
	public String planDetail				{get; set;}
	public List<String> compListIDs			{get; set;}
	
	public CompensationAttachmentController(){
		cIDs = System.currentPageReference().getParameters().get('compIDs');
		this.recordName = System.currentPageReference().getParameters().get('recordName');
		compensationIDs = [Select Id, CollectionID__c, CompPlanDetail__c From ListID__c Where Id =: cIDs]; 
		compIDs = compensationIDs.CollectionID__c;
		this.compListIDs = compIDs.split(';');
		planDetail = compensationIDs.compPlanDetail__c;
		error = false;
		if(System.currentPageReference().getParameters().get('err') != null){
			error = true;
		}
		
		compensations = new List<Compensation__c>();
		
		currentCompensation = null;
		doc = new Document();
		
		this.showAttach = false;
		currentCompensation = System.currentPageReference().getParameters().get('id');
		if (currentCompensation != null && currentCompensation != ''){
			showAttach = true;
		}
		commonFileExtensions = new List<String>();
		commonFileExtensions.add('pdf');
		commonFileExtensions.add('doc');
		commonFileExtensions.add('docx');
		commonFileExtensions.add('txt');
		commonFileExtensions.add('xls');
		commonFileExtensions.add('xlsx');
		
	}
	public List<SelectOption> getAllFileExtension(){
		integer last = commonFileExtensions.size();
		List<SelectOption> records = new List<SelectOption>();
		for (integer i = 0; i < last; i++){
			records.add(new SelectOption('.' + commonFileExtensions[i], commonFileExtensions[i]));
		}
		return records;
	}
	
	public void upsertCompensations(){
		if(!Schema.sObjectType.Compensation__c.isUpdateable()|| 
			!Schema.sObjectType.Compensation__c.isCreateable()){
			ApexPages.addmessage(new ApexPages.message(
			ApexPages.severity.ERROR,'Action aborted due to security violation.'));
		}
		this.compensations = [Select Id From Compensation__c Where Id IN: compListIDs];
		for(Compensation__c c : compensations){
			c.Plan_Details__c = this.planDetail;
		}
		upsert compensations;
		compensations = new List<Compensation__c>();
	}
	
	
	
	
	
	
	public PageReference downloadTemplate(){
		PageReference csvDownload = new PageReference('/apex/CompensationAttachment' );
		if((this.compIDs != null && !this.compIDs.equals('')) && (this.filePath != null && (this.filePath.contains('\\') || this.filePath.contains('/'))) ){
			csvDownload = new PageReference('/apex/CSVDownloadTemplate');
			csvDownload.setRedirect(true);
			csvDownload.getParameters().put('compIDs', 	this.cIDs);
			csvDownload.getParameters().put('path', 	this.filePath);
			csvDownload.getParameters().put('recordName', this.recordName);
			csvDownload.getParameters().put('ext', 		this.fileExtension);
							
		}else{
			csvDownload.getParameters().put('compIDs', cIDs);
			csvDownload.getParameters().put('err', '1');
		}
		return csvDownload;
		
	}
	
	
	
	
	
}