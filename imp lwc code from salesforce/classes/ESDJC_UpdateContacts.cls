global class ESDJC_UpdateContacts implements Database.Batchable<sObject>{
 
     global ESDJC_UpdateContacts(){
                // Batch Constructor
     }
     
     // Start Method
     global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator([select LanguageLocaleKey, ContactId, Contact.ES_DJC_Portal_User_Language__c from User where isPortalEnabled=true and isActive=true and ContactId!=null and LanguageLocaleKey!=null]);
     }
    
   // Execute Logic
    global void execute(Database.BatchableContext BC, List<sObject>scope){
    	List<Contact> contacts = new List<Contact>();
          for (sObject u : Scope){
          	    User aUser = (User) u;
          	    Contact c = new Contact(Id=aUser.ContactId);          	    
				c.ES_DJC_Portal_User_Language__c = aUser.LanguageLocaleKey;
				contacts.add(c);
			}
			update contacts;
   
    }
   
    global void finish(Database.BatchableContext BC){
         // Logic to be Executed at finish
    }
 }