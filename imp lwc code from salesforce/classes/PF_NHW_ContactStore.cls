public without sharing class PF_NHW_ContactStore{
	static final  String CON_QUERY_DEFAULT_FIELDS = 'Id, RecordTypeId, CW_Work_Order_Status__c, CW_Type__c, CreatedDate';
	public static List<NH_DataMapping__mdt> dataMappings = NHW_Util.getSourceFieldsFromNHDataMappingMDT('Contact', 'Case', 'CW Contact to Case');
	static Id caseRecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
	public static Contact getContactById(Id contactId){
		if(contactId == null){
			return null;
		}else{
			return [Select Id, Name,Email,Phone,
				MailingCity,MailingStreet,MailingCountry,MailingState,MailingPostalCode,Secondary_Email__c
				From Contact 
				Where Id = :contactId];
			}		
	}

	public static List<Contact> getCW_ContactsWithRelatedCases(Set<Id> contractorIds){
		//Query all field stored in MetaData mapping to generate query string.
		//Adding a field mapping will automatically sync
		string conQueryFields = CON_QUERY_DEFAULT_FIELDS;

		Set<String> additionalQueryFields = NHW_Util.getSourceObjectFieldsUsingNHDataMappingMDT(dataMappings);
        
        for(String s : additionalQueryFields){
            conQueryFields += ', '+s;
        }
		// ALL Criteria Should have already been checked in trigger. So this just neeeds to be a simple query for data mapping.
		String query = 'SELECT ' + conQueryFields +
				' , (SELECT Id, IsClosed, NHW_Start_Date__c, NHW_Employee__c FROM EmlpoyeeCases__r WHERE RecordTypeId =:caseRecordTypeId AND Status != \'Closed - Cancelled\''+
				'ORDER BY NHW_Start_Date__c DESC) FROM Contact WHERE Id IN :contractorIds';

		try {
			return Database.query(query);
		}catch(Exception err){
			String Description = 'Error message : '+ err.getMessage()  + '\n'
					+ ' Stack Trace:  : ' + err.getStackTraceString() + '\n'
					+ ' Line Number : ' + err.getLineNumber();
			String ErrorMessage = 'Error message is : '+ err.getMessage() ;
			String ErrorType = 'Error while querying Eligible Contacts for Provisioning in PF_NHW_ContactStore.getCW_ContactsForCaseMapping';
			PF_Logger.log('NHW','ERROR',ErrorMessage,ErrorType,Description,'PF_NHW_ContactStore');
			return null;
		}
	}
}