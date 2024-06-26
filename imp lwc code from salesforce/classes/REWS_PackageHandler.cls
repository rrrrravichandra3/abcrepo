public with sharing class REWS_PackageHandler{
	
	public static boolean isExecuted = false;
	/*This method updates case status to closed if all related packages are delivered */
	public static void CloseParentStatus(List<REWS_Package_Delivery__c> triggerNewList){
		
		Set<Id> caseIds = new Set<Id>(); // set to store Ids of case records
		Set<Case> CasesWithPackageStatusMailFolder = new Set<Case>();   
		List<Case> markForClosedCases = new List<Case>();// cases oaded 
		//store all case Ids where child package statuses are delivered 
		for(REWS_Package_Delivery__c pack : triggerNewList){
			if(pack.REWS_Status__c!=null && pack.REWS_Status__c != 'In Progress'){
				caseIds.add(pack.Case__c);
			}
		}
		//check related packages for the cases are delivered 
		for(Case c : [select id,status,REWS_Received_Location__c,REWS_Sender__c,REWS_Carrier__c,contact.REWS_Mail_Delivery_Location__c,contact.name,(select id,REWS_Status__c,REWS_Tracking_Number__c from REWS_Package_Delivery__r) from case where id in : caseIds and isClosed = false ]){
			REWS_Package_Delivery__c[] packages = c.REWS_Package_Delivery__r;
			boolean case_with_packages_mail_folder = false;
			boolean case_with_packages_in_progress = false;
			for (REWS_Package_Delivery__c rewsPackage : packages){
				if (rewsPackage.REWS_Status__c == 'Mail Folder'){
					case_with_packages_mail_folder = true;
				}
				if (rewsPackage.REWS_Status__c == 'In Progress'){
					case_with_packages_in_progress = true;
					break;
				}
			}
			if (!case_with_packages_in_progress){
				markForClosedCases.add(c);
				if (case_with_packages_mail_folder){
					CasesWithPackageStatusMailFolder.add(c);
				}
			}									
		}		
		if(markForClosedCases.size()>0){
			for(Case c : markForClosedCases){
				c.status='Closed';
			}
			update markForClosedCases;
		}		
		if (CasesWithPackageStatusMailFolder.size() > 0){
			List<CaseComment> caseComments = new List<CaseComment>();
			for (Case c:CasesWithPackageStatusMailFolder ){
				String commentTemplate = System.Label.REWS_Case_Comment;
				commentTemplate = commentTemplate.replaceAll('<!--ContactName-->',nvl(c.contact.Name,''));
				commentTemplate = commentTemplate.replaceAll('<!--ReceivedLocation-->',nvl(c.REWS_Received_Location__c,''));
				commentTemplate = commentTemplate.replaceAll('<!--located on MailFolderLocation-->',(c.contact.REWS_Mail_Delivery_Location__c==null? '' : 'located on '+c.contact.REWS_Mail_Delivery_Location__c));
				commentTemplate = commentTemplate.replaceAll('<!--sender-->',nvl(c.REWS_Sender__c,''));
				commentTemplate = commentTemplate.replaceAll('<!--carrier-->',nvl(c.REWS_Carrier__c,''));
				commentTemplate = commentTemplate.replaceAll('<!--Tracking Number -->',nvl(c.REWS_Package_Delivery__r.get(0).REWS_Tracking_Number__c,''));
				CaseComment comment = new CaseComment();
				comment.parentId = c.id;
				comment.commentbody = commentTemplate;
				comment.IsPublished = true;
				caseComments.add(comment);												
			}
			if (CaseComments.size() > 0){
				insert CaseComments;
			}			
		}		
	}	
	
	private static String nvl(String obj, String altVal){
		if (obj == null){
			return altVal;
		}else{
			return obj;
		}
	}
	
	/*Send email to contact if parent case has no prior packages */
	 public static void send_PackageEmail(List<REWS_Package_Delivery__c> triggerNewList,Map<Id,REWS_Package_Delivery__c> triggerNewMap){
    	
    	
    	List<case> sendEmails = new List<Case>();
    	Set<Id> caseIds = new Set<Id>(); // set to store Ids of case records  
    	for(REWS_Package_Delivery__c pack: triggerNewList){
    		caseIds.add(pack.Case__c);
    		
    	}
    	/*make sure we send email once per parent record ..so exclude trigger.new packages and check if we have additioanl packages already..if yes, do not send these emails. */
    	for(Case c : [select id,REWS_Oversized__c,REWS_Rushed__c,REWS_Perishable__c,contactId,(select id from REWS_Package_Delivery__r where id not in : triggerNewMap.keySet()) from Case where id in :caseIds ]){
    				if(c.REWS_Package_Delivery__r.size()==0  && (c.REWS_Oversized__c || c.REWS_Rushed__c || c.REWS_Perishable__c)){
    					sendEmails.add(c);
    				}
    	}
    	sendEmails(sendEmails);   
     }
    
    public static void sendEmails(List<Case> sendEmails){
    	
    	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    	EmailTemplate emailT = ESDJC_Util.getEmailTemplate('REWS_Delivery_Email');
    	for(Case c: sendEmails){
    			
    			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    			mail.setTargetObjectId(c.contactId);
    			mail.setTemplateId(emailT.Id);
    			mail.setWhatId(c.Id);
    			mail.OrgWideEmailAddressId=REWS_Setting__c.getInstance().Mail_services_Orgwide_email__c;
    			emails.add(mail);
    		
    	}
    	if(emails.size()>0){
         Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emails);
        
      }
    }
    
    //populates contact field on insert. 
    public static void insertContactFields(List<REWS_Package_Delivery__c> triggerNewList){
    	Map<Id,Id> contactIdMap = new Map<Id,Id>();
    	Set<Id> caseIds = new Set<Id>();
    	for(REWS_Package_Delivery__c pack: triggerNewList){
    	   caseIds.add(pack.case__c);
    	}
    	for(Case c : [select id,contactId from case where id in : caseIds]){
    		contactIdMap.put(c.Id,c.contactId);
    	}
    	for(REWS_Package_Delivery__c pack: triggerNewList){
    		if(contactIdMap.get(pack.Case__c)!=null){
    			pack.contact__c = contactIdMap.get(pack.Case__c);
    		}
    		
    	}
    }
    
    public static void updateContactCount(Map<Id,REWS_Package_Delivery__c> triggerNewMap,Map<Id,REWS_Package_Delivery__c> triggerOldMap){
      	List<Contact> contactList = new List<Contact>();
      	Set<Id> contactSetId = new Set<Id>();
      	Set<Id> contactsWithPendingPackages = new Set<Id>();
      	for(REWS_Package_Delivery__c pkg : triggerNewMap.values()){
      		if(triggerOldMap != null && pkg.Contact__c != null && triggerOldMap.get(pkg.Id).Contact__c != null){
      			if(pkg.Contact__c != triggerOldMap.get(pkg.Id).Contact__c)
      				contactSetId.add(triggerOldMap.get(pkg.Id).Contact__c);
      		}
      		contactSetId.add(pkg.Contact__c);
      	}
      
      	for (AggregateResult ar: [select count(Id) cnt, Contact__c con from REWS_Package_Delivery__c where REWS_Status__c = 'In Progress' and Contact__c in :contactSetId group by Contact__c ]) {
       		contactList.add(new Contact(Id=(Id)ar.get('con'), REWS_Current_Pending_Packages__c=(Decimal)ar.get('cnt')));
       		contactsWithPendingPackages.add((Id)ar.get('con'));
      	}
      	
      	for (Id cId : contactSetId) {
      		if (!contactsWithPendingPackages.contains(cId)) {
      			contactList.add(new Contact(Id=cId, REWS_Current_Pending_Packages__c=0));
      		}
      	}
       
      update contactList;
    }
    
    public static void setPackagesFlagToFalse(Map<Id,Case> triggerNewMap,Map<Id,Case> triggerOldMap){
    	
    	for(Case c : triggerNewMap.values()){
			
			if( (c.recordTypeId==REWS_Setting__c.getInstance().Case_Package_Delivery_Record_Type__c)  && (c.contactId!=triggerOldMap.get(c.Id).contactId) ){
				if(triggerNewMap.get(c.Id).REWS_Is_Email_Sent__c)
					c.REWS_Is_Email_Sent__c = false;
				
			}
		}
    	
    }
   
	// update packages contact if parent case contact is updated    
	public static void updateChildPackagesContact(Map<Id,Case> triggerNewMap,Map<Id,Case> triggerOldMap) {
		
		Map<Id,case> updatedContactCasesMap = new Map<Id,Case>();
		List<Case> sendNewEmailCases= new List<Case>();
		for(Case c : triggerNewMap.values()){
			
			if( (c.recordTypeId==REWS_Setting__c.getInstance().Case_Package_Delivery_Record_Type__c)  && (c.contactId!=triggerOldMap.get(c.Id).contactId) ){
				updatedContactCasesMap.put(c.Id,c);
			}
		}
		
		if(updatedContactCasesMap!=null && updatedContactCasesMap.size()>0){
			List<REWS_Package_Delivery__c> childPackages = [Select Id, Case__c,Case__r.status,Case__r.REWS_Is_Email_Sent__c, Contact__c, REWS_Status__c from REWS_Package_Delivery__c where Case__c IN: updatedContactCasesMap.keySet()];
			
		if(childPackages!=null && childPackages.size()>0){
			for(REWS_Package_Delivery__c childRecord :childPackages) {
		     	childRecord.contact__c = triggerNewMap.get(childRecord.Case__c).ContactId;
		    }
		    
			update childPackages;
			for(Case c : updatedContactCasesMap.values()){
				if( c.REWS_Oversized__c || c.REWS_Rushed__c || c.REWS_Perishable__c){
					sendNewEmailCases.add(c);
				}
			}
			
			sendEmails(sendNewEmailCases);
		}
			
		}
	}
    
    public static void updateParentCurrentLocation(List<REWS_Package_Delivery__c> packages,Map<Id,REWS_Package_Delivery__c> oldMap){
        Map<Id,String> currentLocationMap = new Map<Id,String>();
        for(REWS_Package_Delivery__c pack : packages){
            if(oldMap == null || (pack.REWS_Current_Location__c!=oldMap.get(pack.Id).REWS_Current_Location__c)){
               currentLocationMap.put(pack.Case__c,pack.REWS_Current_Location__c); 
            }
        }
        
        if(!currentLocationMap.isEmpty()){
            //update related parent cases... 
            for(List<Case> cases : [select Id,REWS_Delivery_Location__c from case where id in : currentLocationMap.keySet()]){
                for(Case c : cases){
                    c.REWS_Delivery_Location__c = currentLocationMap.get(c.Id); 
                }
                update cases;
            }
        }
    }
            
   
}