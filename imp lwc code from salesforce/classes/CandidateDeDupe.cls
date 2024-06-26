public class CandidateDeDupe {
	 
	 /**
    /*
   	*Main method to dedupe candidates. Looks for duplicate candidate by email id
    *@param emailIdSet: Set of candidate email ids.  
    * return: void
    **/   
	public static void deDeupCandidates(List<Contact> contactList){
		if(Schema.sObjectType.Contact.isUpdateable()){
			Map<String,List<Contact>> candidateMap = getCandidateMapbyEmailId(contactList);
			system.debug('----Candidate Map'+candidateMap);
			for(String email: candidateMap.keySet()){
				List<Contact> contactSet = candidateMap.get(email);
				if(contactSet.size()>0){
					mergeContactWithParent(contactSet);	
				}
			}
			
		}else{
			system.debug('----Sorry No FLS Access------');
		}
		
	}
	
	/**
	*Method the merges the candidates with the parent candidate Using salesforce MERGE
	*@param parent: Latest contact record
	*@param contactSet: set of contact records
	*return: void
	**/
	private static void mergeContactWithParent(List<Contact> contactSet){
		Iterator<Contact> contactIterator = contactSet.iterator();
		Contact childContact1,childContact2;
		Contact parent =contactIterator.next();		
		Contact clonedParent = parent.clone(true, false);
		while(contactIterator.hasNext()){
			List<Contact> childContactList = new List<Contact>();
			childContactList.add(contactIterator.next());
			if(contactIterator.hasNext()){
				childContactList.add(contactIterator.next());								
			}
			if(Limits.getDMLStatements()<Limits.getLimitDMLStatements()){
				
				try{
					if(isBlankFieldsInParent(clonedParent)){
						shiftFieldValuesToParent(clonedParent, childContactList);
					}
					merge clonedParent childContactList;	
				}catch(DMLException e){
					system.debug('DML Exception'+e);
					system.debug('---Number of DML statements---'+Limits.getDMLStatements());
					system.debug('---LIMIT of DML statements---'+Limits.getLimitDMLStatements());
					system.debug('Problem merging contacts');
					system.debug('Parent Contact'+ parent.id);
					system.debug('Child Contact List'+ childContactList);
					
				}
			}else{
				return;
			}
			 
		}
	}
		
	/**
	*Method to fetch the contact record by email and create a Map with email
	*id as the key and Set of contact record as the value
	*@param emailIdList: List of emailId
	*return : map with email id as the key and Contact record with that email id as the value
	**/
	private static Map<String,List<Contact>> getCandidateMapbyEmailId(List<Contact> contactList){
		
		Map<String,List<Contact>> emailIdContactSetMap = new Map<String,List<Contact>>();
		for(Contact contact:contactList){
			if(emailIdContactSetMap.get(contact.email)==null){
				emailIdContactSetMap.put(contact.email,new List<Contact>());	
			}
			emailIdContactSetMap.get(contact.email).add(contact);
		}
		
		return emailIdContactSetMap;
	}
	
	/**
	*Method to check if any of the contact fields are null
	*@param contact: Contact object that will survive the merge operation
	*return : boolean true if any of the fields listed below is null
	**/	
	 private static boolean isBlankFieldsInParent(Contact contact){
		return ((contact.MobilePhone==null
					|| contact.Referrer_Email__c==null || contact.Referrer_Name__c==null || contact.Referred_By__c==null || contact.MailingCity==null 
					|| contact.MailingCountry==null || contact.MailingStreet==null || contact.MailingPostalCode==null
					|| contact.NameKanji__c==null || contact.NameKana__c==null || contact.Do_Not_Call__c==false || contact.Marketing_Opt_Out__c==false));
	}
	
	/**
	*Method to shift values from the childConctact to parent contact if any of the 
	values listed below is empty
	*@param parent: Contact object that will survive merge operation
	*@param parent: childContactList list of child contacts
	*return : void
	**/
	private static void shiftFieldValuesToParent(Contact parent, List<Contact> childContactList){

		
		if(parent.MobilePhone==null &&(parent.MobilePhone=childContactList.get(0).MobilePhone)==null && childContactList.size()==2){
			parent.MobilePhone=childContactList.get(1).MobilePhone;
		}
		
		if(parent.Referrer_Email__c==null &&(parent.Referrer_Email__c=childContactList.get(0).Referrer_Email__c)==null && childContactList.size()==2){
			parent.Referrer_Email__c=childContactList.get(1).Referrer_Email__c;
		}
		
		if(parent.Referrer_Name__c==null &&(parent.Referrer_Name__c=childContactList.get(0).Referrer_Name__c)==null && childContactList.size()==2){
			parent.Referrer_Name__c=childContactList.get(1).Referrer_Name__c;
		}
		
		if(parent.Referred_By__c==null &&(parent.Referred_By__c=childContactList.get(0).Referred_By__c)==null && childContactList.size()==2){
			parent.Referred_By__c=childContactList.get(1).Referred_By__c;
		}
		
		if(parent.MailingCity==null &&(parent.MailingCity=childContactList.get(0).MailingCity)==null && childContactList.size()==2){
			parent.MailingCity=childContactList.get(1).MailingCity;
		}
		
		if(parent.MailingCountry==null &&(parent.MailingCountry=childContactList.get(0).MailingCountry)==null && childContactList.size()==2){
			parent.MailingCountry=childContactList.get(1).MailingCountry;
		}
		
		if(parent.MailingStreet==null &&(parent.MailingStreet=childContactList.get(0).MailingStreet)==null && childContactList.size()==2){
			parent.MailingStreet=childContactList.get(1).MailingStreet;
		}
		
		if(parent.MailingPostalCode==null &&(parent.MailingPostalCode=childContactList.get(0).MailingPostalCode)==null && childContactList.size()==2){
			parent.MailingPostalCode=childContactList.get(1).MailingPostalCode;
		}
		
		if(parent.NameKana__c==null &&(parent.NameKana__c=childContactList.get(0).NameKana__c)==null && childContactList.size()==2){
			parent.NameKana__c=childContactList.get(1).NameKana__c;
		}
		
		if(parent.NameKanji__c==null && (parent.NameKanji__c=childContactList.get(0).NameKanji__c)==null && childContactList.size()==2){
			parent.NameKanji__c=childContactList.get(1).NameKanji__c;
		}
	
		if(!parent.Do_Not_Call__c){
			parent.Do_Not_Call__c=childContactList.get(0).Do_Not_Call__c;
		}
		if(!parent.Marketing_Opt_Out__c){
			parent.Marketing_Opt_Out__c=childContactList.get(0).Marketing_Opt_Out__c;
		}
		
		if(childContactList.size()==2){
		
			
			if(!parent.Do_Not_Call__c){
				parent.Do_Not_Call__c=childContactList.get(1).Do_Not_Call__c;
			}	
			
			if((!parent.Marketing_Opt_Out__c)){
				parent.Marketing_Opt_Out__c=childContactList.get(1).Marketing_Opt_Out__c;
			}	
			
		}
		
	}
}