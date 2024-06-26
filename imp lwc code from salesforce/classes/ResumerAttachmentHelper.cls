/*
without sharing class is to be used to update application from external job board
*/
public without sharing class ResumerAttachmentHelper {

	public static String JobName {get; set;}

	//To ensure job applying is still open and accepting application
    public static boolean validateExtJobId( Id jobIdchk ){

    	Id jboardId = [ select Id from ts2__Job_Board_Setup__c where name = 'External' limit 1].Id; 

    	if ( jboardId == null )
    		return false;

    	List<ts2__JobOrderJobBoardAssociation__c> jobchk = [ select Id, ts2__JobOrder__r.Name from ts2__JobOrderJobBoardAssociation__c where ts2__JobBoardSetup__c =: jboardId and Status__c = 'Open' and ts2__JobOrder__c =: jobIdchk];
    	JobName = null;

    	if ( jobchk.size() == 1 )
    		JobName = jobchk[0].ts2__JobOrder__r.Name;

    	if ( jobchk != null && jobchk.size() == 1 )
    		return true;
    	else
			return false;

    }

    //To ensure sourceId is still active and accepting application
    public static boolean validateSourceId( Id sIdchk ){

    	List<ts2__Source__c> sourcechk = [ select Id from ts2__Source__c where Id =: sIdchk and ts2__Active__c = true limit 1 ];

    	if ( sourcechk != null && sourcechk.size() == 1 )
    		return true;
    	else
			return false;    	

    	return true;
    }

	public static PageReference createApplication( String candidateEmail, String docType, Id jobId, Attachment myfile, Id sourceId, String sessionKey ){ 

		Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
		Id applicationId;
		PageReference reference;

        try { 

	        Contact c = [ select Id, firstname, lastname from Contact where email = : candidateEmail and recordtypeId = : candidateRTId limit 1 ];

			datetime d = datetime.now();
            String dateFormat = d.format ('yy-MM-dd');
			String Filename = 'Resume_'+c.firstname+'_'+c.lastname+'_JB_'+dateFormat+'.'+docType;

			List<ts2__Application__c> ExistingApp =[ select Id from ts2__Application__c where ts2__Candidate_Contact__c =: c.Id and ts2__Job__c =: jobId and 
		      										 ts2__Application_Status__c = 'Incomplete' and ts2__Status__c = 'Incomplete' and ts2__App_Status__c = 'Incomplete' ];

	        if ( ExistingApp.size() >= 1  ) { 

	        	applicationId = ExistingApp[0].Id;
		        Attachment a = new Attachment(parentId = c.Id, name=Filename, body = myfile.body);
                insert a;

	        } else { 

		        ts2__Application__c app = new ts2__Application__c();
		        app.ts2__Candidate_Contact__c = c.Id;
		        app.ts2__Job__c = jobId;
		        app.ts2__Application_Status__c = 'Incomplete';
		        app.ts2__Status__c = 'Incomplete';
		        app.ts2__App_Status__c = 'Incomplete';
		        app.ts2__Application_Source__c = sourceId;
		        insert app;
		        Attachment a = new Attachment(parentId = c.Id, name=Filename, body = myfile.body);
                insert a;
				
				applicationId = app.Id;			        
		    }

		    reference=new PageReference('/jobs/ts2__resumeattachment?addTo='+c.Id+'&appId='+applicationId+'&jobId='+jobId+'&sessionKey='+sessionKey);
			        
				return reference;

		} catch (QueryException ex) {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The URL on this page has been modified. Please navigate back to salesforce.com/careers' );
			ApexPages.addMessage( myMsg );
			return null;

		} catch ( Exception ex ) {

			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The system :'+String.valueof(ex) );	            
			ApexPages.addMessage( myMsg );
			return null;
		            
		} 

	}
}