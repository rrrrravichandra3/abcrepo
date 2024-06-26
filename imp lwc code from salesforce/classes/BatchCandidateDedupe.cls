global class BatchCandidateDedupe implements Database.Batchable<sObject> {
	//This batch job updates cleans the duplicate candidates based on the email address providided.
	//This is a batch job to be executed one time.
   	private static List<String> emailList = new List<String>();
    	
	private boolean isTest {get; set;}
		
	global BatchCandidateDedupe() {
        this.isTest = false;
	}
	
	global BatchCandidateDedupe(boolean isTest) {
		this.isTest = isTest;
	}	
		
	global Database.QueryLocator start(Database.BatchableContext BC) {
		loadEmailList();
		system.debug('----EmailList Size'+ emailList.size());
		
		return Database.getQueryLocator([ SELECT email,Id, MobilePhone, Referrer_Email__c, Referrer_Name__c, 
		    Referred_By__c, MailingCity, MailingCountry, MailingStreet, MailingPostalCode, NameKana__c, NameKanji__c,Marketing_Opt_Out__c,Do_Not_Call__c, 
		    LastModifiedDate FROM  Contact Where recordType.name='Candidate' and email IN : emailList order by email, LastModifiedDate desc]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Contact> emailIdList = new List<Contact>();
		for (sObject sobj : scope) {
			Contact contact = (Contact)sobj;
			if (contact.email != null) {
			    emailIdList.add(contact);
			}
		}
		
   		System.debug('******* Duplicate Candidates Size:: '+emailIdList.size());
		if (emailIdList.size() > 0) {
			CandidateDeDupe.deDeupCandidates(emailIdList);
		}
	}
	
	global void finish(Database.BatchableContext BC){
		System.debug('---Batch Job Completed---');
   		
	}
	
	private static void loadEmailList(){
		StaticResource sr = [select id,body from StaticResource Where Name = 'EmailId'];
		String contents = sr.body.toString();
		for(String email:contents.split('\n')) {
		
  			if(email!=null){
  				BatchCandidateDedupe.emailList.add(email.trim());	
  			}
  			
		}
		
	}

}