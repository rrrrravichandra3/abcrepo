public with sharing class PF_NHW_PastSubmissionDetailAuraServices {
	@AuraEnabled
    public static PF_NHW_CustomCaseComment addNewComment(String commentBody, Id provisioningCaseId){
    	CaseComment comm = new CaseComment();
    	comm.CommentBody = commentBody;
    	comm.ParentId = provisioningCaseId;
    	comm.IsPublished = True;
		
    	try {	
			if(CaseComment.sObjectType.getDescribe().isCreateable()){
				Database.insert(comm, false);
			}				
		}  catch (DmlException ex) { 
			system.debug('The following exception has occurred: ' + 
						 ex.getDmlStatusCode(0) + ex.getMessage());
		}

    	return (new PF_NHW_CustomCaseComment(UserInfo.getName(),DateTime.now().format('MM/dd/yyyy'),commentBody));
    }
}