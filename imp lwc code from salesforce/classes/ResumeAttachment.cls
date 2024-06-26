public with sharing class ResumeAttachment {
    public Id jobId { get; set; }
    public String email { get; set; }
    public String sessionKey { get; set; }
    public Id sourceId { get; set; }
    public String docType { get; set; }

    public final String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    public final String sessionkeyRegex = '[a-zA-Z0-9]{32}';
    public transient Attachment myfile;
    
    public ResumeAttachment() {

        if ( System.currentPagereference().getParameters().get('email') != null && email == null )
        	email = System.currentPagereference().getParameters().get('email');
        
        if ( System.currentPagereference().getParameters().get('jobId') != null && validateId( System.currentPagereference().getParameters().get('jobId') ) && jobId == null )
        	jobId = System.currentPagereference().getParameters().get('jobId');
        
        if ( System.currentPagereference().getParameters().get('tSource') != null && validateId( System.currentPagereference().getParameters().get('tSource') ) && sourceId == null )
        	sourceId = System.currentPagereference().getParameters().get('tSource');

        if ( System.currentPagereference().getParameters().get('sessionKey') != null && sessionKey == null )        
	        sessionKey = System.currentPagereference().getParameters().get('sessionKey');

    	myfile = new Attachment();            
    }    

    public ApexPages.PageReference init(){

        if ( !validateUserInput( System.currentPagereference().getParameters().get('email'), emailRegex ) ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The system is not able to process your email input.' );
            ApexPages.addMessage( myMsg );
        }

        if ( !validateId( System.currentPagereference().getParameters().get('jobId') ) ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The system is not able to process your jobId input.' );
            ApexPages.addMessage( myMsg );
        } else if ( !ResumerAttachmentHelper.validateExtJobId( System.currentPagereference().getParameters().get('jobId') ) ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The selected job is not currently open.' );                
            ApexPages.addMessage( myMsg );
        }

        if ( !validateId( System.currentPagereference().getParameters().get('tSource') ) ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The system is not able to process your source Id input.' );
            ApexPages.addMessage( myMsg );
        } else if ( !ResumerAttachmentHelper.validateSourceId( System.currentPagereference().getParameters().get('tSource') ) ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The selected source is not currently active.' );                
            ApexPages.addMessage( myMsg );
        }

        if ( !validateUserInput( System.currentPagereference().getParameters().get('sessionKey'), sessionkeyRegex ) ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'The system is not able to process your sessionKey input.' );                
            ApexPages.addMessage( myMsg );
        }

        return null;
    }

    public String getJobTitle(){

    	return ResumerAttachmentHelper.JobName;
    }

    public Boolean validateId(String Idparam) {

    	if ( Idparam == null )
    		return false;

        String id = String.escapeSingleQuotes(Idparam);
        if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id)) {
            return true;
        }
        return false;
	}    

    public boolean validateUserInput(String RegexString, String RegexPattern ) {

    	if ( RegexString == null )
    		return false;
   
        Pattern MyPattern = Pattern.compile(RegexPattern);
        Matcher MyMatcher = MyPattern.matcher(RegexString);
    
        if (MyMatcher.matches()) 
            return true;
        else
            return false;
    }

    public boolean validateAttachment( String tempName ){

    	if ( tempName == null )
    		return false;

		Set<String> a =new Set<String>{'docx', 'doc', 'pdf', 'rtf', 'html', 'txt'};
		boolean found = false;

	    for ( String s : a ){
	        if ( tempName.endsWith( s ) ){ 
	            found = true;
	            docType = s;
	            break;
	        }
	    }		

    	return found;
    }

    Public Attachment getmyfile()
    {
        if ( myfile == null )
    	   myfile = new Attachment(); 
        return myfile;
    }

    
    Public Pagereference Savedoc(){

        init();
        PageReference reference = null;

 		if ( myfile != null && validateAttachment( myfile.name ) && ( myfile.body != null && myfile.body.size() <= 10485760 )  ){ 
            
            reference = ResumerAttachmentHelper.createApplication( email, docType, jobId, myfile, sourceId, sessionKey );

	    } else {

	    	String errorStr = 'Unknown Error has occured.';
	    	if ( myfile.name == null )
	            errorStr = 'Please upload a resume attachment.';
	    	if ( myfile != null && myfile.name != null && !validateAttachment( myfile.name ) )
	            errorStr = 'Please update an acceptable resume type.';
	    	if ( myfile != null &&  myfile.body != null && myfile.body.size() > 10485760 )
	            errorStr = 'This file exceeds the maximum size limit of 10MB.';

            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, errorStr ) );

 	
	    }

        	return reference;
    	
    }   
}