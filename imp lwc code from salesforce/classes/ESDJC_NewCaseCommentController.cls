public with sharing class   ESDJC_NewCaseCommentController {
    public CaseComment cm{get;set;}
    public case ca{get;set;}
    ApexPages.StandardController cont;
    public ESDJC_NewCaseCommentController(ApexPages.StandardController controller) {
        cont = controller;
        
        cm = (CaseComment)controller.getRecord();
        cm.ParentId = ApexPages.currentPage().getParameters().get('caseId');
        ca = [select id,Subject,Description from Case where id =: ApexPages.currentPage().getParameters().get('caseId') ];
    }
    
    public PageReference save(){
    	if(Schema.sObjectType.CaseComment.isCreateable()){
        	insert cm;
    	} else {
			ESDJC_Util.displayAccessPrivilegeError('Create CaseComment');
    	}
        PageReference pf = new PageReference('/apex/ESDJC_CaseDetailPage?id='+ca.Id);
        pf.setRedirect(true);
        return pf;
    }
    
    public PageReference cancel(){
        PageReference pf = new PageReference('/apex/ESDJC_CaseDetailPage?id='+ca.Id);
        pf.setRedirect(true);
        return pf;
    }
}