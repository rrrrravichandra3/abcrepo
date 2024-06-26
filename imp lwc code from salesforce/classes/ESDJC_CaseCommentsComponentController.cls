public with sharing class ESDJC_CaseCommentsComponentController {
    
    public Id caseId {get; set;}
    public list<CaseComment> getComments(){
            return [Select LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, IsPublished, CreatedDate, CreatedBy.Id, CreatedBy.Name, CommentBody From CaseComment c where ParentId = :caseId order by c.LastModifiedDate desc];
            
    }
     
}