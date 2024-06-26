@istest(SeeAllData=false)
public with sharing class ESDJC_PackageHandlerTriggerTest {
	private static Contact amerContact;
	
	private static void init(){
		amerContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco')[0];		
	}

	public static testmethod void testCloseParentStatus(){
		init();
		Test.startTest();
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Package Delivery');
		nameValuePair.put('Subject','package case');
		nameValuePair.put('type','Mail Services');				
		nameValuePair.put('Status','New');
		nameValuePair.put('REWS_Received_Location__c','ReceivedLocation-Landmark');
		nameValuePair.put('REWS_Carrier__c','testCarrier');
		nameValuePair.put('recordtypeId',getRecordTypeFromName('All REWS Package Management'));		
		nameValuePair.put('ContactId', amerContact.id);
		Case c = createCase(nameValuePair);
		
		//create 1st package
		REWS_Package_Delivery__c package1 = new REWS_Package_Delivery__c(Case__c = c.id, REWS_Tracking_Number__c = 'tracking123', REWS_Status__c = 'In Progress');
		REWS_PackageHandler.isExecuted=false;
		insert package1;
		System.assert([select status from case where id = :c.id].status!='Closed');
		
		//create 2nd package
		REWS_Package_Delivery__c package2 = new REWS_Package_Delivery__c(Case__c = c.id, REWS_Tracking_Number__c = 'tracking123', REWS_Status__c = 'In Progress');
		REWS_PackageHandler.isExecuted=false;
		insert package2;
		System.assert([select status from case where id = :c.id].status!='Closed');
		
		//Update first package
		package1.REWS_Status__c = 'Mail Folder';
		REWS_PackageHandler.isExecuted=false;
		update package1;
		System.assert([select status from case where id = :c.id].status!='Closed');
		System.assert([select count() from CaseComment where parentid = :c.id limit 1] == 0);
		
		//Update 2nd package
		package2.REWS_Status__c = 'Direct Deliver';
		REWS_PackageHandler.isExecuted=false;
		update package2;
		//Case should now be closed with Casecomment
		System.assert([select status from case where id = :c.id].status == 'Closed');
		system.debug([select status from case where id = :c.id].status);
		CaseComment comment = [select CommentBody from CaseComment where parentid = :c.id limit 1];
		
		System.assert(comment.CommentBody.contains('ReceivedLocation-Landmark'));
		System.assert(comment.CommentBody.contains('testCarrier'));
		Test.stopTest();		
	}

	public static testmethod void testCloseParentStatusWithoutMailFolder(){
		init();
		Test.startTest();
		Map<String,String> nameValuePair = new Map<String, String>();
		nameValuePair.put('Origin','Package Delivery');
		nameValuePair.put('Subject','package case');
		nameValuePair.put('type','Mail Services');				
		nameValuePair.put('Status','New');
		nameValuePair.put('REWS_Received_Location__c','ReceivedLocation-Landmark');
		nameValuePair.put('REWS_Carrier__c','testCarrier');
		nameValuePair.put('recordtypeId',getRecordTypeFromName('All REWS Package Management'));		
		nameValuePair.put('ContactId', amerContact.id);
		Case c = createCase(nameValuePair);
		
		//create 1st package
		REWS_Package_Delivery__c package1 = new REWS_Package_Delivery__c(Case__c = c.id, REWS_Tracking_Number__c = 'tracking123', REWS_Status__c = 'In Progress');
		REWS_PackageHandler.isExecuted=false;
		insert package1;
		System.assert([select status from case where id = :c.id].status!='Closed');
		
		//create 2nd package
		REWS_Package_Delivery__c package2 = new REWS_Package_Delivery__c(Case__c = c.id, REWS_Tracking_Number__c = 'tracking123', REWS_Status__c = 'In Progress');
		REWS_PackageHandler.isExecuted=false;
		insert package2;
		System.assert([select status from case where id = :c.id].status!='Closed');
		
		//Update first package
		package1.REWS_Status__c = 'Owner Pick-up';
		REWS_PackageHandler.isExecuted=false;
		update package1;
		System.assert([select status from case where id = :c.id].status!='Closed');
		System.assert([select count() from CaseComment where parentid = :c.id limit 1] == 0);
		
		//Update 2nd package
		package2.REWS_Status__c = 'Direct Deliver';
		REWS_PackageHandler.isExecuted=false;
		update package2;
		//Case should now be closed with Casecomment
		System.assert([select status from case where id = :c.id].status == 'Closed');
		system.debug([select status from case where id = :c.id].status);
		integer commentCount = [select count() from CaseComment where parentid = :c.id limit 1];		
		System.assert(commentCount == 0);
		Test.stopTest();		
	}


	private static id getRecordTypeFromName(String recTypeName){
		return [select id from recordType where name = :recTypeName limit 1].id;
	}

	private static case createCase(Map<String,String> nameValPair){
		Case c = new Case();
		if ((nameValPair!=null)&&(nameValPair.size()>0)){
			for (String key: nameValPair.keySet()){
				String value= nameValPair.get(key);
				c.put(key, value);
			}
			insert c;
			Case newCase = [select status,owner.name, recordtype.Name, priority,ES_DJC_Case_Re_open_Date__c,type, Tier__c from case where id = :c.id];
			return newCase;					
		}
		return null;		
	}
}