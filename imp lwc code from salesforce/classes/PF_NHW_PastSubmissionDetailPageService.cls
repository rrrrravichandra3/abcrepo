public with sharing class PF_NHW_PastSubmissionDetailPageService extends PF_NHW_ReviewService{
    
    protected override Map<String, Object> getPageConfig(){
        List<ReviewItemGroup> config = new List<ReviewItemGroup>();
        Map<String, Object> pageConfig = new map<string,object>();

        if(flowType != null && flowtype == 'employeeviewandupdate') {
            PF_NHW_Process process = PF_NHW_Process.getProcessByName('employeeviewandupdate');
            provisioningCase.NHW_Page_Number__c = 0;
            provisioningCase.NHW_Page_Number__c = PF_NHW_Process.getNextStep(provisioningCase);

            for(PF_NHW_page page:process.steps){
                if(page.reviewInfo.includedInReview){
                    PF_NHW_PageService service = page.createService();
                    config.add(new ReviewItemGroup(page.reviewInfo.title, page.reviewInfo.icon, service.getReviewList(provisioningCase, process)));
                
                }
            }
            pageConfig.put('REVIEW_ITEMS' , config);
        }else{
            pageConfig = super.getPageConfig();
        }
        if(pageConfig != null){
            pageConfig.put('COMMENTS',getCaseComments());
            pageConfig.put('POSTCOMMENTS',allowCommentPost());
        }
        return pageConfig;
    }

    private Boolean allowCommentPost(){
        Date caseStartDate = this.provisioningCase.NHW_Start_Date__c;

        DateTime dT = System.now();
        Date todayDate = date.newinstance(dT.year(), dT.month(), dT.day());
        Date cutOffDate = todayDate.addDays(1);

        if(caseStartDate<cutOffDate){return false;}
        else{return true;}
    }

    private List<PF_NHW_CustomCaseComment> getCaseComments(){
        
        //Querying the standard object CaseComment records and names of their author
        List<CaseComment> allCaseCommentsFromDatabase = [Select Id, CommentBody, CreatedById, CreatedDate FROM CaseComment WHERE ParentId = :this.provisioningCase.Id AND IsDeleted=false AND IsPublished=true order by CreatedDate desc];
        Set<Id> caseCommentAuthorIds = new Set<Id>();
        for(CaseComment currentComment : allCaseCommentsFromDatabase){
            caseCommentAuthorIds.add(currentComment.CreatedById);
        }
        List<User> commentAuthors = [Select Id, Name FROM User where Id IN :caseCommentAuthorIds];
        Map<Id, String> userIdToNameMap = new Map<Id, String>();
        for(User currentUser:commentAuthors){
            userIdToNameMap.put(currentUser.Id,currentUser.Name);
        }

        //Creating list of custom data structure PF_NHW_CustomCaseComment

        List<PF_NHW_CustomCaseComment> caseCommentsForAuraComponent = new List<PF_NHW_CustomCaseComment>();
        for(CaseComment currentComment : allCaseCommentsFromDatabase){
            caseCommentsForAuraComponent.add(new PF_NHW_CustomCaseComment(userIdToNameMap.get(currentComment.CreatedById),(currentComment.CreatedDate).format('MM/dd/yyyy'),currentComment.CommentBody));
        }

        return caseCommentsForAuraComponent;
    }
    
    public override String processPageInformation(){
        //Method overriden for safety.  So, the logic from PF_NHW_ReviewService is not executed.
        return null;
    }
    
}