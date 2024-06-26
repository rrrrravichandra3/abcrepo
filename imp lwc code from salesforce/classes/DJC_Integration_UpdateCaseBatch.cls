/*This Class is used to update cases of claims sent to Workday as part of Integration - DJC_WellnessIntegrationController*/
global without sharing class DJC_Integration_UpdateCaseBatch implements Database.Batchable<sObject> , Database.Stateful {

    	global set<Id> caseIdsToUpdate;
    	global set<Id> caseIdsInScope = new set<id>();
    	public list<string> bodyLines = new list<string>() ;
    	public string subject='';
    	public String csvContent ='';
    	public string caseStatusToUpdate;
    	public string reimbursementType;
    	
    	//get status and reimbursementType as params.
	    global DJC_Integration_UpdateCaseBatch(set<id> caseIdsToUpdate,string status,string reimbursementType){
	        this.caseIdsToUpdate = caseIdsToUpdate;
	        this.caseStatusToUpdate=status;
	        this.reimbursementType=reimbursementType;
	        system.debug(LOGGINGLEVEL.INFO,'caseIdsToUpdate:'+caseIdsToUpdate);
	        system.debug(LOGGINGLEVEL.INFO,'caseStatusToUpdate:'+caseStatusToUpdate);
	        system.debug(LOGGINGLEVEL.INFO,'reimbursementType:'+reimbursementType);
	    }

	    
    	global Database.QueryLocator start(Database.BatchableContext BC){
    		if(caseStatusToUpdate == 'Closed'){//As we are getting ids' from external service we are doubling checking the status before closing them off.
         	  return Database.getQueryLocator([select id,status from case where id in :caseIdsToUpdate]);   			
    		}
    		else{//As the ids are colleted peopleforce controller we re using them straight.
         	  return Database.getQueryLocator([select id,status from case where id in :caseIdsToUpdate]);
   			
    		}
	    }
	    
	    global void execute(Database.BatchableContext BC,  List<case> casesToBeUpdated){
			
			Savepoint sp = Database.setSavepoint();
	    	try{
		        for (Case caseToBeUpdated : casesToBeUpdated) {
		            caseToBeUpdated.Status = caseStatusToUpdate;
		            caseIdsInScope.add(caseToBeUpdated.id);
		        }
		        update casesToBeUpdated;
		        //throw new ApplicationException();

	    	}catch(Exception ex){	    
	    		system.debug(LOGGINGLEVEL.INFO,ex);
	    		Database.rollback(sp); 	    		
	    		bodyLines.add(reimbursementType+' reimbursement batch case status update to '+caseStatusToUpdate+' failed due to the below exception(s). \n');
	    		bodylines.add(String.valueof(ex)+'\n');
	    		if(caseIdsInScope.size()>0){
		    		bodylines.add('Please find the attachment for the case IDs in scope.\n'); 
		    		csvContent = csvContent +string.join(new list<id>(caseIdsInScope),',\n');		    			    			
	    		}else{
  					bodylines.add('No cases picked up in batch.');  		        		    			
	    		}
	    		subject   = 'DJC_Integration_UpdateCaseBatch  - FAILURE ';      	
	    		 
	    	}
	    }
	    	
	    global void finish(Database.BatchableContext BC){
	    	ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
            if(bodylines.size()==0){//No Exception has occured in any of the batches.
  		        if(caseIdsToUpdate.size() > 0){
  		        	bodyLines.add(reimbursementType+' reimbursement batch job is successful.' + ' The cases have been updated to the status: '+caseStatusToUpdate+'\n');  		        	
 					bodylines.add('Please find the attachment for the case IDs in scope.\n'); 
                	csvContent = string.join(new list<id>(caseIdsToUpdate),',\n'); 		        	
  		        }else{//Empty batch run.
  					bodylines.add('No cases picked up in batch.');  		        	
  		        }	    		
	    		subject   = 'DJC_Integration_UpdateCaseBatch';      	
            }

	        sendStatusEmail(BC, subject, settings.DJC_Batchjob_Support_Email__c.split(','), bodyLines,csvContent);		
	    
	    }
	    //TODO:Move this to ESDJCUtil as part Util exception handling refactoring.
	    //Reason being editing ESDJCUtil involves deleting schedulable class run REWS_Package_Notification_Batch and recreating it.
	    //Thereby, all edits on the util need to beconsolidated.
	    public String sendStatusEmail(Database.BatchableContext BC, String subject, String[] toAddresses, String[] bodyLines,String csvContent) {
	
	        if(toAddresses == null || toAddresses.size() == 0 || toAddresses[0] == null || toAddresses[0] == ''){	
	            return '';	
	        }	
	        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, TotalJobItems, CreatedBy.Email  FROM AsyncApexJob WHERE Id =:BC.getJobId()];	
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();	
	        mail.setToAddresses(toAddresses);		
			//Enable custom exception failure subject from  classes invoking the method.As typically handled exceptions give status as -Complete-
			if(subject.tolowercase().contains('fail')){
	        	mail.setSubject(subject);			
			}
			else{
	        	mail.setSubject(subject+ ' - '+a.Status);							
			}
	        String body = '';	
	        for(String line : bodyLines){	
	            body += line + '\n';	
	        }	
	        mail.setPlainTextBody (body);
	        if(!String.isBlank(csvContent)){
				Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
				csvAttachment.setBody(Blob.valueOf(csvContent));
				csvAttachment.setFileName('caseIdsFile.csv');		
				mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});		        	
	        }			

					
		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       

	        return mail.getPlainTextBody();
	    }
		
}