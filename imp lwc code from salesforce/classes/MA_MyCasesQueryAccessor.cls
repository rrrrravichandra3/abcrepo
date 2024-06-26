public Without Sharing class MA_MyCasesQueryAccessor
 
{
     //Method to retrieve case comments with name
     public static List<CaseComment> getCaseComments(String caseId){
       
         return [Select Id, ParentId, IsPublished, CommentBody, CreatedById, CreatedBy.Name, CreatedDate, SystemModstamp, LastModifiedDate, LastModifiedById, IsDeleted From CaseComment where ParentId=:caseId ORDER BY CreatedDate ASC];
         
     }

}