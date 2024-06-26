global class Batch_BackfillDoNotCallReason implements Database.Batchable<sObject>, Database.Stateful{
	
	global Boolean rollBackUpdateOperation;
	global String backfillReason;
	global Date	startDate;
	global Date endDate;
	
	global String successLog = '';
	global String errorLog = '';
	global String ignoreLog = '';
	global Integer iSuccessCounter = 0;
	global Integer iErrorCounter = 0;
	global Integer iIgnoreCounter = 0;
	
	global Integer iScopeCounter = 0;
	global Integer iToUpdateCounter = 0;
	
	global Batch_BackfillDoNotCallReason(Boolean rollBackUpdateOperation, String backfillReason, Date startDate, Date endDate) {
		this.rollBackUpdateOperation = rollBackUpdateOperation;
		this.backfillReason = backfillReason;
		this.startDate = startDate;
		this.endDate = endDate;		
	}
	
	global Database.QueryLocator start(Database.BatchableContext batchableContext) {
		Date startDate = this.startDate;
		Date endDate   = this.endDate;
		
		String query =   'select Id, Name, CreatedDate, ' + 
						 'Do_Not_Call_Reason__c ' +
						 'from Contact ' + 
						 'where Do_Not_Call__c = true ' +
						 'and CreatedDate >= :startDate ' +
						 'and CreatedDate <= :endDate ' +
						 'and Contact.RecordType.DeveloperName = \'Candidate\' ' +
						 'order by CreatedDate asc';
						 
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext batchableContext, List<sObject> scope){
		iScopeCounter += scope.size();
   		List<Contact> doNotCallCandidates = (List<Contact>) scope;
   		List<Contact> recordsToUpdate = new List<Contact>();
   	
		for (Contact c : doNotCallCandidates) {
			if (String.isEmpty(c.Do_Not_Call_Reason__c)) {
				c.Do_Not_Call_Reason__c = this.backfillReason;
				recordsToUpdate.add(c);
			} else {
				ignoreLog += ('\n' + c.Id + '| ' + c.Name + '| ' + c.CreatedDate + '| ignored: Do Not Call Reason is not empty'); 
				iIgnoreCounter++;
			}
		}
		
		Savepoint sp = Database.setSavepoint();
		
		//Allow partial success of the update.
		iToUpdateCounter += recordsToUpdate.size();
		Database.SaveResult[] lst_saveResults = Database.update(recordsToUpdate, false);
		
		for(Integer i = 0; i < lst_saveResults.size(); i++) {
			if(lst_saveResults[i].isSuccess()){
				successLog += ('\n' + recordsToUpdate[i].Id + '| ' + recordsToUpdate[i].Name + '| ' + recordsToUpdate[i].CreatedDate + '| success: ' + lst_saveResults[i].getId()); 
				iSuccessCounter++;
			} else {
				String errors = '';
				for(Database.Error error : lst_saveResults[i].getErrors()) {
					errors += ('| ' +error.getMessage());
				}
				errorLog += ('\n' + recordsToUpdate[i].Id + '| ' + recordsToUpdate[i].Name + '| ' + recordsToUpdate[i].CreatedDate + '| error: ' + errors ); 
				iErrorCounter++;
			}
		}
		
		if (this.rollBackUpdateOperation) {
			Database.rollback(sp);
		}
		
   }

   global void finish(Database.BatchableContext batchableContext){
		
		AsyncApexJob asyncApexJob = [SELECT Id, Status, ExtendedStatus, CreatedDate, CompletedDate, TotalJobItems, NumberOfErrors, JobItemsProcessed, ApexClassId FROM AsyncApexJob WHERE Id =:batchableContext.getJobId()];

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
		mail.setSenderDisplayName('Batch - Batch_BackfillDoNotCallReason');
		mail.setSubject('Batch Process Completed - ' + batchableContext.getJobId());
		
		//Insert Ignored Log as a File in Salesforce.com		
		ContentVersion ignoreLogFile = new ContentVersion();
		ignoreLogFile.versionData = iIgnoreCounter > 0 ? Blob.valueof(ignoreLog) : Blob.valueof('No records were ignored');
        ignoreLogFile.description = 'Ignore log for the Batch_BackfillDoNotCallReason batch execution. Batch Job ' + batchableContext.getJobId() + ' created on ' + asyncApexJob.CreatedDate.format() ;
        ignoreLogFile.title ='Batch_BackfillDoNotCallReason'+ '-' + asyncApexJob.CreatedDate.format('yyyymmddhhmmss') + '-Ignore-' +  + batchableContext.getJobId()+'.txt';
        ignoreLogFile.pathOnClient ='/Batch_BackfillDoNotCallReason'+ '-' + asyncApexJob.CreatedDate.format('yyyymmddhhmmss') + '-Ignore-' +  + batchableContext.getJobId()+'.txt';
        ignoreLogFile.origin = 'H';
        insert ignoreLogFile;
			
		//Insert Success Log as a File in Salesforce.com
		ContentVersion successLogFile = new ContentVersion();
        successLogFile.versionData = iSuccessCounter > 0 ? Blob.valueof(successLog) : Blob.valueof('No records were succesful');
        successLogFile.description = 'Success log for the Batch_BackfillDoNotCallReason batch execution. Batch Job ' + batchableContext.getJobId() + ' created on ' + asyncApexJob.CreatedDate.format() ;
        successLogFile.title ='Batch_BackfillDoNotCallReason'+ '-' + asyncApexJob.CreatedDate.format('yyyymmddhhmmss') + '-Success-' +  + batchableContext.getJobId()+'.txt';
        successLogFile.pathOnClient ='/Batch_BackfillDoNotCallReason'+ '-' + asyncApexJob.CreatedDate.format('yyyymmddhhmmss') + '-Success-' +  + batchableContext.getJobId()+'.txt';
        successLogFile.origin = 'H';
        insert successLogFile;
        
        //Insert Error Log as a File in Salesforce.com
		ContentVersion errorLogFile = new ContentVersion();
        errorLogFile.versionData = iErrorCounter > 0 ? Blob.valueof(errorLog) : Blob.valueof('No records had errors');
        errorLogFile.description = 'Error log for the Batch_BackfillDoNotCallReason batch execution. Batch Job ' + batchableContext.getJobId() + ' created on ' + asyncApexJob.CreatedDate.format() ;
        errorLogFile.title ='Batch_BackfillDoNotCallReason'+ '-' + asyncApexJob.CreatedDate.format('yyyymmddhhmmss') + '-Error-' +  + batchableContext.getJobId()+'.txt';
        errorLogFile.pathOnClient ='/Batch_BackfillDoNotCallReason'+ '-' + asyncApexJob.CreatedDate.format('yyyymmddhhmmss') + '-Error-' +  + batchableContext.getJobId()+'.txt';
        errorLogFile.origin = 'H';
        insert errorLogFile;
        

		mail.setPlainTextBody('The batch process has completed.' + 
							  '\n\nBATCH JOB INFO' +
							  '\nId: ' 						    + asyncApexJob.Id +
							  '\nStatus: ' 					  	+ asyncApexJob.Status +
							  '\nExtended Status: ' 			+ asyncApexJob.ExtendedStatus +
							  '\nCreated Date: ' 				+ asyncApexJob.CreatedDate.format() +
							  '\nCompleted Date: ' 				+ asyncApexJob.CompletedDate.format() +
							  '\nTotal Batches: ' 				+ asyncApexJob.TotalJobItems +
							  '\nFailures: ' 					+ asyncApexJob.NumberOfErrors + 
							  '\nBatches Processed: '       	+ asyncApexJob.JobItemsProcessed +
							  '\nAPEX Batch Class: '       		+ URL.getSalesforceBaseUrl().toExternalForm() +  '/' +asyncApexJob.ApexClassId +
							  '\n\nEXECUTION PARAMETERS' +
							  '\nRollback Update Operation : '  + this.rollBackUpdateOperation +
							  '\nBackfill Reason : '       		+ this.backFillReason +
							  '\nStart Date : '       			+ this.startDate.format() + 
							  '\nEnd Date : '       			+ this.endDate.format() + 
							  '\n\nLOG FILES' +
							  '\nScope : '        		  + iScopeCounter      + ' records.' + 
							  '\nAttempted to update : '  + iToUpdateCounter   + ' records.' + 
							  '\nIgnore: '  			  + iIgnoreCounter     + ' records.' +   
							  '\nSuccess: '   			  + iSuccessCounter    + ' records.' + 
							  '\nError: '     			  + iErrorCounter      + ' records.' + 	
							  '\n\n' + ignoreLogFile.title +
							  '\n' + URL.getSalesforceBaseUrl().toExternalForm() +  '/' + ignoreLogFile.id +
							  '\n\n' + successLogFile.title +
							  '\n' + URL.getSalesforceBaseUrl().toExternalForm() +  '/' + successLogFile.id +
							  '\n\n' + errorLogFile.title +
							  '\n' + URL.getSalesforceBaseUrl().toExternalForm() +  '/' + errorLogFile.id +
							  '\n');
		
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}