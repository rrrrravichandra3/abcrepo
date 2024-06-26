public with sharing class CandidateExtController {
     public Contact candidate;
     public Id candidateId{get;set;}
     public String viewAllURL {get; set;}
     public String attachFileURL{get; set;}
     public List<Attachment> attachmentList {get; set;}
     public CandidateExtController(ApexPages.StandardController controller) {
     	candidate = (Contact)controller.getRecord();
 		candidateId = ApexPages.currentPage().getParameters().get('ID');
	
     	if (candidateId != null) {
     	    attachmentList =loadAttachments(candidateId);
     	}
     	viewAllURL ='/ui/content/ViewAllNotesPage?id='+candidateId+'&retURL='+ candidateId;
     	attachFileURL='/p/attach/NoteAttach?pid='+candidateId+'&retURL='+candidateId;
     	
     }  
     
     private List<Attachment> loadAttachments(Id candidateId) {
     	return [Select ParentId, OwnerId,Name,LastModifiedDate,LastModifiedById,IsPrivate,Id,Description,CreatedById,ContentType,BodyLength From Attachment where ParentId =: candidateId ];
     }
     
      
      
      public PageReference deleteAttachment() {
          String attachmentId =  ApexPages.currentPage().getParameters().get('attachmentId');
          
          if (attachmentId != null) {
              Attachment deleteAttachment = null;
              for(Attachment attachmentInfo : attachmentList) {
                  if (((String)attachmentInfo.Id).equalsIgnoreCase(attachmentId)) {
                      deleteAttachment = attachmentInfo; 	
                  }	
              }	
              if (deleteAttachment != null) {
                  delete deleteAttachment;	
                  attachmentList =loadAttachments(candidateId);
              }
          }	
          
          return null;	
      }
      
      
}