/*
  Helper class for Assignment Rules unit testing . 
*/

public with sharing class ESDJC_AssignmentHelper {
	
	public static List<Contact> getContacts(Integer count,String division, String workloc){
		
		List<Contact> contacts = new List<Contact>();
		for(Integer i=0;i<count;i++){
			Contact con = new Contact(
				Email='random1'+(Math.random()*1000).intValue()+'@salesforce.com',
				FirstName='TestF'+i,
				LastName='LastNameF'+i,
				ES_DJC_Record_Status__c='New - Completed',
				EmployeeNumber__c='98765'+(Math.random()*1000).intValue()+i,
				Division__c=division,
				ES_DJC_Work_Location__c = (workloc==null)?null : workloc,
				recordTypeId = getRecordTypeId('Contact','Employee'),
				Status__c='Active'
			);
			contacts.add(con);
		}
		insert contacts; 
		return contacts; 
		
	}
 	public static List<Contact> createContactsByDeptDivWorkLoc(Integer count,String division, String Dept,String workloc){
		
		List<Contact> contacts = new List<Contact>();
		for(Integer i=0;i<count;i++){
			Contact con = new Contact(
				Email='random1'+(Math.random()*1000).intValue()+'@salesforce.com', 
				FirstName='TestF'+i,
				LastName='LastNameF'+i,
				ES_DJC_Record_Status__c='New - Completed',
				EmployeeNumber__c='98765'+(Math.random()*1000).intValue()+i,
				Division__c=division,
				Department=dept,
				ES_DJC_Work_Location__c = (workloc==null) ? null : workloc, 
				recordTypeId = getRecordTypeId('Contact','Employee'),
				Status__c='Active'
			);
		  contacts.add(con);

		}
		insert contacts; 
		return contacts; 
		
	} 
	public static List<Contact> createContactsByDeptDivWorkLoc(Integer count,String division, String Dept,String workloc,Date startDate){
		
		List<Contact> contacts = new List<Contact>();
		for(Integer i=0; i<count; i++){
			Contact con = new Contact(
				Email='random1'+(Math.random()*1000).intValue()+'@salesforce.com',
				FirstName='TestF'+i,
				LastName='LastNameF'+i,
				ES_DJC_Record_Status__c='New - Completed', 
	      EmployeeNumber__c='98765'+(Math.random()*1000).intValue()+i,
				Division__c=division,
				Department=dept,
				ES_DJC_Work_Location__c = (workloc==null)?null : workloc,
				recordTypeId = getRecordTypeId('Contact','Employee'),
				Status__c='Active',
				Start_Date__c=startDate
			);
			contacts.add(con);
		}
		insert contacts; 
		return contacts; 
		
	}   
    public static List<Contact> getContacts(Integer count,String division, String workloc, String country){
		
		List<Contact> contacts = new List<Contact>();
		for(Integer i=0;i<count;i++){
			Contact con = new Contact(
				Email='random'+(Math.random()*1000).intValue()+'@salesforce.com',
				FirstName='TestF'+i,
				LastName='LastNameF'+i,
				ES_DJC_Record_Status__c='New - Completed',
				EmployeeNumber__c='89765'+(Math.random()*1000).intValue()+i,
				Division__c=division, 
				ES_DJC_Work_Location__c = (workloc==null)?null : workloc,
				recordTypeId = getRecordTypeId('Contact','Employee'),
				Status__c='Active', 
				ES_DJC_Contact_Country__c = country
			);
			contacts.add(con);
		}
		insert contacts; 
		return contacts; 
		
	}
	
	public static List<Contact> getContacts(Integer count,String division, String workloc, String country, Date startDate){
		
		List<Contact> contacts = new List<Contact>();
		for(Integer i=0;i<count;i++){
			Contact con = new Contact(
				Email='random'+(Math.random()*1000).intValue()+'@salesforce.com',
				FirstName='TestF'+i,
				LastName='LastNameF'+i,
				ES_DJC_Record_Status__c='New - Completed',
				EmployeeNumber__c='89765'+(Math.random()*1000).intValue()+i,
				Division__c=division, 
				ES_DJC_Work_Location__c = (workloc==null)?null : workloc, 
				recordTypeId = getRecordTypeId('Contact','Employee'),
				Status__c='Active',
				ES_DJC_Contact_Country__c = country,
				Start_Date__c=startDate
			);
			contacts.add(con);
		}
		insert contacts; 
		return contacts; 
		
	}
	
	public static List<Contact> getContacts(Integer count,String division, String workloc, String emailDomain, String recordType){
		
		List<Contact> contacts = new List<Contact>();
		for(Integer i=0;i<count;i++){
			Contact con = new Contact(
				Email='random1'+(Math.random()*1000).intValue() + '@' + emailDomain, 
				FirstName='TestF'+i,
				LastName='LastNameF'+i,
				ES_DJC_Record_Status__c='New - Completed',
				EmployeeNumber__c='98765'+(Math.random()*1000).intValue()+i,
				Division__c=division, 
				ES_DJC_Work_Location__c = (workloc==null)?null : workloc,
				recordTypeId = getRecordTypeId('Contact',recordType),
				Status__c='Active'
			);
			contacts.add(con);
		}
		insert contacts; 
		return contacts; 
	}
	
	public static Id getRecordTypeId (String sObjectType, String Name){
		
		Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
                    Schema.SObjectType sobjType = gd.get(sObjectType);
                    Schema.DescribeSObjectResult r = sobjType.getDescribe();
                   
		List<Schema.RecordTypeInfo> recordTypes = r.getRecordTypeInfosByName().values(); 
		for(Schema.RecordTypeInfo s : recordTypes){
			if(s.getName()==Name){
				return s.getRecordTypeId();
			}
		}
		return null;
	}
	
	public static Id getQueueId(String qName){
		
		return [select Id from Group where Type='Queue' and developerName=:qName limit 1].Id; 
	}
	
	

}