public with sharing class MA_MyCasesController{
    //Keep the class with sharing. Portal user should have read access to cases created by him and its comments and attachments

    private static final String STATUS_UPDATED = Label.MA_Case_Status_Updated;
    private static final String STATUS_REOPENED = Label.MA_Case_Status_Reopened;
    private static final String STATUS_OPEN = Label.MA_Open_Status;
    private static final String STATUS_CLOSED = Label.MA_Closed_Status;
    private static final List<String> CLOSED_STATUS_LIST = Label.MA_Closed_Status_for_Case_Detail.toLowerCase().split(';');

    //Method to retrieve initial list of cases.
    //used by LWC maMyCasesListView
    @AuraEnabled
    public static List<CaseWrapper> getCaseWrapperList(){
        List<Case> maCases = [SELECT Id, CaseNumber, Status, Subject, LastModifiedDate, 
                              (SELECT LastModifiedDate FROM CaseComments ORDER BY LastModifiedDate DESC LIMIT 1)
                              FROM Case
                              WHERE ContactEmail = :UserInfo.getUserEmail()];

        List<CaseWrapper> allCaseWrappers = new List<CaseWrapper>();

        for(Case maCase : maCases) {
            Boolean hasCaseComments = (maCase.CaseComments != null && !maCase.CaseComments.isEmpty());
            Datetime lastModifiedDate = (hasCaseComments && maCase.CaseComments[0].LastModifiedDate > maCase.LastModifiedDate) ? 
            maCase.CaseComments[0].LastModifiedDate : maCase.LastModifiedDate;
            allCaseWrappers.add(new CaseWrapper(maCase.Id, maCase.Subject, maCase.CaseNumber, lastModifiedDate, maCase.Status));
        }

        return allCaseWrappers;
    }

    //Method to retrieve Case comments for a given case.
    //used by LWC maMyCasesComment
    @AuraEnabled
    public static List<CaseCommentWrapper> getCaseCommentWrapperList(String caseId){
        User currentUser= [select Id,timezonesidkey from user where Id =:UserInfo.getUserId()];
        List<CaseComment> allCaseComments = MA_MyCasesQueryAccessor.getCaseComments(caseId);
        List<CaseCommentWrapper> allCaseCommentWrapper = new List<CaseCommentWrapper>();
        for(CaseComment c : allCaseComments){
            String createdDateStringFormat = getDateInStringFormat(c.CreatedDate,currentUser.timezonesidkey);
            Boolean isCurrentUserAuthor = (currentUser.Id == c.CreatedById)?True:False;
            String caseCommentId = String.ValueOf(c.Id);
            allCaseCommentWrapper.add(new CaseCommentWrapper(caseCommentId,c.CommentBody, c.CreatedBy.Name, createdDateStringFormat,isCurrentUserAuthor));
        }
        return allCaseCommentWrapper;
    }

    //Utility method to convert DateTime into string format based on current user's timezone
    public static String getDateInStringFormat(DateTime commentCreatedDateTime,String userTimeZone){
        String createdDateStringFormat =  commentCreatedDateTime.format('dd-MMM-yyyy, hh:mm a', userTimeZone);
        return createdDateStringFormat;
    }

    @AuraEnabled
    public static Case postNewCaseComment(String caseId, String newCaseComment) {
        Case updatedCase = new Case(Id = caseId);
        try {
            insert getCaseComment(caseId, newCaseComment);
            updatedCase.Status = STATUS_UPDATED;
            update updatedCase;
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return updatedCase;
    }

    private static CaseComment getCaseComment(String caseId, String newCaseComment) {
        CaseComment comment = new CaseComment(ParentId = caseId);
        comment.IsPublished = true;
        comment.CommentBody = newCaseComment;
        return comment;
    }

    public class CaseWrapper{
        @AuraEnabled
        public Id caseId;
        @AuraEnabled
        public String CaseNumber;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String Subject;
        @AuraEnabled
        public DateTime lastModifiedDate;


        public CaseWrapper(Id caseId, String subject, String caseNumber, DateTime lastModifiedDate, String status){
            this.caseId = caseId;
            this.Subject = subject;
            this.CaseNumber = caseNumber;
            this.lastModifiedDate = lastModifiedDate;
            this.Status = CLOSED_STATUS_LIST.contains(status.toLowerCase()) ? STATUS_CLOSED : STATUS_OPEN;
        }
    }

    public class CaseCommentWrapper{
        @AuraEnabled
        public String commentId;
        @AuraEnabled
        public String commentBody;
        @AuraEnabled 
        public String commentAuthor;
        @AuraEnabled
        public String commentDate;
        @AuraEnabled
        public Boolean userOwnComment; //Boolean variable to determin if this comment was made by current user. This attribute helps in css assignment

        public CaseCommentWrapper(String commentId, String commentBody, String commentAuthor, String commentDate, Boolean userOwnComment){
            this.commentId = commentId;
            this.commentBody = commentBody;
            this.commentAuthor = commentAuthor;
            this.commentDate = commentDate;
            this.userOwnComment = userOwnComment;
        }

    }
    
    //Method to retrieve Case attachments for a given case.
    //used by LWC maMyCasesDetail
    @AuraEnabled
    public static list<contentversion> getFiles(String caseId) {
        list<id> lstConDocs = new list<id>();
        if(String.isNotBlank(caseId))
        {
            for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId From ContentDocumentLink Where LinkedEntityId =:caseId]) {
                lstConDocs.add(cntLink.ContentDocumentId);
            }
        }
        if(!lstConDocs.isEmpty()) {
            return [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :lstConDocs];
        }
        else {
            return null;
        }
    }

    //Method to retrieve Case attachments for a close case.
    //used by LWC maMyCasesDetail
    @AuraEnabled
    public static Case closeCase(String caseId) {
        List<Case> closeCaseList = new List<Case>();
        try{
            if(String.isNotBlank(caseId)){      
                for(Case c : [Select id, Status From Case WHERE Id =:caseId]){  
                    String caseStatus = System.Label.MA_Closed_Status; 
                    
                    if(String.isNotBlank(caseStatus)){  
                    c.Status = caseStatus;
                    }

                    closeCaseList.add(c); 
                }
                Update closeCaseList;
            } 
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage()); 
        }
        if(!closeCaseList.isEmpty()) {
            return closeCaseList[0];
        }else{
            return null;
        }        
    }

    //Method to reopen closed case.
    //used by LWC maMyCasesDetail
    @AuraEnabled
    public static Case reOpenCase(String caseId) {
        Case reopenedCase = new Case(Id = caseId);
        reopenedCase.Status = STATUS_REOPENED;
        
        try {
            update reopenedCase;
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        
        return reopenedCase;
    }

    @AuraEnabled
    public static void deleteFile(Id recordId){
        try {         
           If(recordId != null){
                Id docId = [SELECT ContentDocumentId from ContentVersion where Id =:recordId].ContentDocumentId;
                ContentDocument contentDocumentToDelete = new ContentDocument();
                if(docId != null){
                    contentDocumentToDelete = [Select id From ContentDocument Where Id =:docId Limit 1];
                }
                
                if(contentDocumentToDelete != null){                   
                    delete contentDocumentToDelete;
                }
           }
        }
        catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}