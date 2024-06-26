/*
*********************************************************
Apex Class Name    : PbCasesController
Created Date       : October 24, 2023
@description       : This is class is used for the Preboarding Site to view and update Cases,
                    as well as view related Files
@author            : Mia de Haan
*********************************************************
*/
public with sharing class PbCasesController {
    /*
    *********************************************************
    @Method Name    : getCases
    @author         : Mia de Haan
    @description    : method to is used to pull a list of Cases
						with Attachments
    @param          :
    @return         : Output - List of Cases
    ********************************************************
    */
    @AuraEnabled(cacheable=false)
    public static List<PbCaseWrapper> getCases() {
        try {
            // Query for Cases
            List<Case> caseList = new List<Case>();
            if (
                Schema.sObjectType.Case.fields.Id.isAccessible() &&
            	Schema.sObjectType.Case.fields.CreatedDate.isAccessible() && 
                Schema.sObjectType.Case.fields.LastModifiedDate.isAccessible() && 
                Schema.sObjectType.Case.fields.Subject.isAccessible() && 
                Schema.sObjectType.Case.fields.CaseNumber.isAccessible() && 
                Schema.sObjectType.Case.fields.Status.isAccessible() && 
                Schema.sObjectType.Case.fields.IsClosed.isAccessible() && 
                Schema.sObjectType.Case.fields.OwnerId.isAccessible() && 
                Schema.sObjectType.Case.fields.Description.isAccessible()
            ){ 
                caseList = [
                    SELECT 
                        Id, 
                        CreatedDate,
                        LastModifiedDate,
                        Subject,
                        CaseNumber,
                        Status,
                        IsClosed,
                        OwnerId,
                        Description,
                        (
                            SELECT 
                                ContentDocumentId, 
                                LinkedEntityId,
                                ContentDocument.Title,
                                ContentDocument.FileExtension 
                            FROM ContentDocumentLinks
                        )
                    FROM Case
                    ORDER BY LastModifiedDate DESC
                    LIMIT 50
                ];
            }
            
            PbCaseWrapper[] caseWrappers = new List<PbCaseWrapper>();  
            for(Case caseRecord : caseList) {
                // Format CreatedDate & LastModifiedDate to MM/dd/YYYY
                PbCaseWrapper c = new PbCaseWrapper();
                c.Id = caseRecord.Id;
                c.CreatedDate = caseRecord.CreatedDate.format('MM/dd/YYYY');
                c.LastModifiedDate = caseRecord.LastModifiedDate.format('MM/dd/YYYY');
                c.Subject = caseRecord.Subject;
                c.CaseNumber = caseRecord.CaseNumber;
                c.Status = caseRecord.Status;
                c.IsClosed = caseRecord.IsClosed;
                c.Description = caseRecord.Description;
                c.ContentDocumentLinks = caseRecord.ContentDocumentLinks;
                c.OwnerId = caseRecord.OwnerId;
                caseWrappers.add(c);
            }
            System.debug('caseWrappers: ' + caseWrappers);
            return caseWrappers;
            
        } catch (QueryException e) {
            // Handle the exception or log an error
            System.debug(e.getMessage());
            return null;
        }
       
    }
    
    /*
    *********************************************************
    @Method Name    : getCaseComments
    @author         : Mia de Haan
    @description    : method to is used get CaseComments
    @param          : recordId
    @return         : 
    ********************************************************
    */
    @AuraEnabled(cacheable=false)
    public static List<PbCaseCommentWrapper> getCaseComments(Id recordId) {
        try {
            // Query for Case Comments
            List<CaseComment> commentsList = new List<CaseComment>();
            if (
                Schema.sObjectType.CaseComment.fields.ParentId.isAccessible() &&
                Schema.sObjectType.CaseComment.fields.CommentBody.isAccessible() &&
                Schema.sObjectType.CaseComment.fields.CreatedById.isAccessible() &&
                Schema.sObjectType.CaseComment.fields.CreatedDate.isAccessible()
            ) {
                commentsList = [
                    SELECT 
                        Id, 
                        ParentId,
                        CommentBody, 
                        CreatedById,
                        CreatedBy.Name,
                        CreatedDate
                    From CaseComment
                    WHERE ParentId = :recordId
                    Order by CreatedDate ASC
                    LIMIT 200
                ];
            }
            
            List<PbCaseCommentWrapper> commentWrappers = new List<PbCaseCommentWrapper>();
        	for (CaseComment comment : commentsList) {
                // Retrieve user details for each CreatedById
                PbCaseCommentWrapper c = new PbCaseCommentWrapper();
                c.Id = comment.Id;
                c.ParentId = comment.ParentId;
                c.CommentBody = comment.CommentBody;
                c.CreatedDate = comment.CreatedDate;
                c.CreatedById = comment.CreatedById;
                c.CreatedByName = comment.CreatedBy.Name;
                commentWrappers.add(c);
            }
    		System.debug('commentWrappers: ' + commentWrappers);
            return commentWrappers;
            
        } catch (QueryException e) {
            // Handle the exception or log an error
            System.debug(e.getMessage());
            return null;
        }
        
    }
    
    /*
    *********************************************************
    @Method Name    : createCaseComment
    @author         : Mia de Haan
    @description    : method to is used to update the Case
    @param          :
    @return         : 
    ********************************************************
    */
    @AuraEnabled
    public static void createCaseComment(Id recordId, String commentBody) {
        try {
            CaseComment newComment = new CaseComment();
            if(
            	Schema.sObjectType.CaseComment.fields.ParentId.isCreateable() &&
                Schema.sObjectType.CaseComment.fields.CommentBody.isCreateable() &&
                Schema.sObjectType.CaseComment.fields.IsPublished.isCreateable()
            ) {
                newComment.ParentId = recordId;
                newcomment.CommentBody = commentBody;
                newcomment.IsPublished = true;
                insert newComment;
            }
        } 
        catch(Exception e){
            System.debug(e.getMessage());
        }
	}
    
}