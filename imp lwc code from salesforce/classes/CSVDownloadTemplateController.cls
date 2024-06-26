public with sharing class CSVDownloadTemplateController {
	public String compIDs 					{get; set;}
	public String userIDs					{get; set;}
	public String recordName				{get; set;}
	public String Attachments = '';
	public String filePath					{get; set;}
	public String fileExtension				{get; set;}
	public List<String> listUrl				{get; set;}
	public List<Compensation__c> compensations {get; set;}
	public CSVDownloadTemplateController(){
		String aux = System.currentPageReference().getParameters().get('compIDs');
		this.recordName = System.currentPageReference().getParameters().get('recordName');
		ListID__c ListIDObject = [Select Id, CollectionID__c, CompNamesCollection__c From ListID__c Where Id =: aux];
		compIDs 		= ListIDObject.CollectionID__c;
		userIDs			= ListIDObject.CompNamesCollection__c;
		filePath 		= System.currentPageReference().getParameters().get('path');
		fileExtension 	= System.currentPageReference().getParameters().get('ext');
		
		compensations = new List<Compensation__c>();
		
		listUrl = new List<String>();
	}
	
	
	
	public String getAttachments(){
		
		
		if(compIDs != null && userIDs != null){
			List<String> IDs = compIDs.split(';');
			List<String> uIDs = userIDs.split(';');
			List <User> userlist=[Select ID, name, EmployeeNumber from User u where u.id in: uIDs];
			Map<id, String>NameMap= new map<id, String>();
			Map<id, String>numberMap = new Map<id, string>();
			for(user u:userList){
				NameMap.put(u.id, u.name);
				numberMap.put(u.id,u.EmployeeNumber);
			}
			
			List<String> CompensationsNames = new List<String>();
			List<User> compUsers = [Select u.Name, u.EmployeeNumber From User u Where u.Id IN: uIDs and isActive=true];  
			List<Compensation__c> comps=[Select OwnerId, id, Name from Compensation__c where id IN: IDs];
			for(Compensation__c com : comps){
				
				Attachments += '\n' + com.Id + ',' + nameMap.get(com.ownerID) + ' '+ numberMap.get(com.ownerID) + '-' + this.recordName + fileExtension + ',' + filepath + '\\' + nameMap.get(com.ownerID) + ' '+ numberMap.get(com.ownerID) + '-' + this.recordName + fileExtension+ ','+fileExtension;
				
			}
			//String compName = '';
			//for(User u : compUsers){
			//	compName = u.Name + ' ' + u.EmployeeNumber + '-' + this.recordName;
			//	CompensationsNames.add(compName);
			//}			
			//for(Integer i = 0; i < IDs.size(); i++){
				
			//	Attachments += '\n' + IDs[i] + ',' + CompensationsNames[i] + fileExtension + ',' + filePath +  '\\' + CompensationsNames[i] + fileExtension + ',' + fileExtension;
				
		//	}
			
		}
		return Attachments;
	}
	
	
	
}