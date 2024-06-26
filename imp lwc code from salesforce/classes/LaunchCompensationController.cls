public with sharing class LaunchCompensationController {
	public List<RecordType> compRecords = new List<RecordType>();
	public  List<User>		 compUsers 	{get; set;}
	public String currentRecordType {get; set;}
	public String usr {get; set;}
	public List<Compensation__c> compensations {get; set;}
	public String compensationName {get; set;}
	public String compensationCurrency {get; set;}
	public PerformanceReview__c PerformanceReview {get;set;}
 	public String currentUser		{get; set;}
 	public Blob FileRecords{get;set;}
    public String[] LineNo=new String[]{};
    public String userIDs {get; set;}
    public boolean showUsers {get; set;}
    public boolean errors {get;set;}
    private ListID__c usrIDs {get; set;}
	public LaunchCompensationController(){
		Id uIDs = null;
		if (Apexpages.currentPage().getParameters().get('userIDs') != null){
    		 uIDs =	Apexpages.currentPage().getParameters().get('userIDs');
    		 
    		    		
    	}else{
    		if (Apexpages.currentPage().getParameters().get('uIDs') != null){
    			uIDs =	Apexpages.currentPage().getParameters().get('uIDs');
    			showUsers = true;
    		}
    	}
    	
    	if(uIDs!=null){
    		usrIDs = [Select Id, CollectionID__c From ListID__c Where Id =: uIDs];
    		userIDs = usrIDs.CollectionID__c;	
    	}else{
    		userIDs = '';
    	}
    	if (Apexpages.currentPage().getParameters().get('errors') =='true'){
    		 errors =	true;
    	}
		compensations = new List<Compensation__c>();
		compUsers = new List<User>();
		PerformanceReview = new PerformanceReview__c();
	}
	public List<RecordType> getCompRecordTypes(){
		List<String> names = new List<String>();
		names.add('Distribution Record Type');
		names.add('Planning Record Type');
		
		compRecords = [Select r.Name, r.Id, r.Description From RecordType r Where r.Name IN: names Order By r.Name limit 3 ];
		if(Apexpages.currentPage().getParameters().get('RecordID')==null){
			currentRecordType = compRecords[0].Id;
		}
		else{
			currentRecordType=ApexPages.currentPage().getParameters().get('RecordID');
		}
		return compRecords;
	}
	
	public List<SelectOption> getAllRecordTypes(){
		this.getCompRecordTypes();
		List<SelectOption> records = new List<SelectOption>();
		for (RecordType r : compRecords){
			records.add(new SelectOption(r.Id, r.Name));
		}
		return records;
	}
	
	
	public PageReference saveAndContinue(){
		if(!Schema.sObjectType.ListID__c.isUpdateable() 
     		|| !Schema.sObjectType.ListID__c.isCreateable()){
			ApexPages.addmessage(new ApexPages.message(
			   ApexPages.severity.ERROR,'Action aborted due to security violation.'));
		}
		Compensation__c aux;
		
		for(User u : compUsers){
			userIDs += u.Id + ';';
		}	
		if(usrIDs == null){
			usrIDs = new ListID__c();	
		}			
		
	   	usrIDs.CollectionID__c = userIDs;
	   	upsert usrIDs;
		PageReference editPage = new PageReference('/apex/CompensationEdit');
		if(Apexpages.currentPage().getParameters().get('uIDs') != null){
			editPage.getParameters().put('uIDs', usrIDs.Id);
		}else{
			editPage.getParameters().put('userIDs', usrIDs.Id);	
		}
		
		
		editPage.getParameters().put('recordID', currentRecordType);
		editPage.getParameters().put('csv', '1');
		editPage.setRedirect(true);
		return editPage;
	}
	
	public PageReference UploadFile()
     {
     	if(!Schema.sObjectType.ListID__c.isUpdateable() 
     		|| !Schema.sObjectType.ListID__c.isCreateable()){
			ApexPages.addmessage(
			new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation.'));
		}
       PageReference out = new PageReference('/apex/LaunchCompensation');
       out.setRedirect(true);
       if(FileRecords!=null){
       		try{
	       String FileData = FileRecords.toString();
	       List<String> LineNo = FileData.split('\n');
	       compUsers = new List<User>();
	       userIDs = '';
	       List<String> uIDs = new List<String>(); 
	       
	       for(Integer i = 1; i < LineNo.size(); i++){
	          List<String> ActualData = new List<String>();
	          ActualData = LineNo[i].split(',');
	          if(ActualData[0].startsWith('\"')){
	          	userIDs += ActualData[0].substring(1, 7) + ';';	
	          }else{
	          	userIDs += ActualData[0].substring(0, 6) + ';';
	          }
	          
		   }
		   
		   out.setRedirect(true);
		   if(usrIDs == null){
		   	 	usrIDs = new ListID__c();	
		   }
		   
		   usrIDs.CollectionID__c = userIDs;
		   upsert usrIDs;
		   out.getParameters().put('uIDs', usrIDs.Id);
       		}
       		catch(exception e){
       			out.getParameters().put('errors', 'true');
       			out.getParameters().put('recordID', currentRecordType);
       			return out;
       		}
       		
       }
       out.getParameters().put('recordID', currentRecordType);
       return out;
     }
	
}