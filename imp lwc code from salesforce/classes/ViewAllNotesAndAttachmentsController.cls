public with sharing class ViewAllNotesAndAttachmentsController {
	List<Note> notes { get; set; }
	List<Attachment> attachs { get; set; }
	Id pid;
	String retURL;
	String fromPage;
	List<NotesAndAttachments> notesAndAttachs = new List<NotesAndAttachments>();
	
	
	public ViewAllNotesAndAttachmentsController(){
		attachs = new List<Attachment>();
		
		pid = System.currentPageReference().getParameters().get('pid');
		retURL = System.currentPageReference().getParameters().get('retURL');
		fromPage = System.currentPageReference().getParameters().get('fromPage');
		if(pid != null){
			notes   = [Select n.Title, n.ParentId, n.Parent.Name, n.LastModifiedDate, n.LastModifiedById, n.LastModifiedBy.Name, n.IsPrivate, n.Id, n.CreatedDate, n.CreatedById, n.Body From Note n where n.ParentId =: pid order by CreatedDate desc ];
			attachs = [Select a.ParentId, a.Parent.Name, a.OwnerId, a.Name, a.LastModifiedDate, a.LastModifiedById, a.LastModifiedBy.Name, a.IsPrivate, a.Id, a.CreatedDate, a.CreatedById, a.ContentType, a.BodyLength  From Attachment a where a.ParentId =: pid order by CreatedDate desc];
		
			
			if(notes != null && notes.size() > 0){
				for(Note n : notes){
					NotesAndAttachments note = new NotesAndAttachments(n.Id, n.Title, 'Note', n.Body, n.LastModifiedBy.Name, n.CreatedDate, n.LastModifiedDate);
					notesAndAttachs.add(note);
				}
			}
			if(attachs != null && attachs.size() > 0){
				for(Attachment attach : attachs){
					NotesAndAttachments attachment = new NotesAndAttachments(attach.Id, attach.Name, 'Attachment','',attach.LastModifiedBy.Name, attach.CreatedDate, attach.LastModifiedDate);
					notesAndAttachs.add(attachment);
				}
			}
		}		
		
		notesAndAttachs = sortResult(notesAndAttachs);
	}
	
	/* Return all notes and attachment sorted
	*  @return List<NotesAndAttachments>	
	*/ 
	public PageReference theReturnUrl(){
		PageReference thePag=null;
		if(fromPage=='showView'){
			thePag=new PageReference('/'+getRetUrl());
		}
		return thePag;
	}
	public List<NotesAndAttachments> sortResult (List<NotesAndAttachments> result) {
         Integer n;
         Integer i;
         Integer j;
         n = result.size() - 1;   
         for (i = 1; i <= n; i++) {   
             for (j = n; j >= i ; j--) {
                 if (result.get(j).CreatedDateOriginal >= result.get(j - 1).CreatedDateOriginal) {
                     NotesAndAttachments tempLink;
                     tempLink = result.get(j - 1);
                     result.set(j - 1, result.get(j));
                     result.set(j, tempLink);    
                 }   
             }
         }
         return result;
     }
     
	/*
	*@ Return all notes & attachments
	*/
	public List<NotesAndAttachments> getNotesAndAttachs(){
		return notesAndAttachs;
	}
	
	public boolean getHasNotesAndAttachs(){
		if(notesAndAttachs != null && notesAndAttachs.size() > 0){
			return true;
		}
		return false;
	}
	/*
	*@ Return the feedback url
	*/
	public String getRetURL(){
		String id = retURL.substring(1, retURL.length());
		return id;
	}
	public String getFromPage(){
		return fromPage;
	}
	
	/*
	*@ Return the Name of the parent object
	*/
	public String getParentName(){
		String name;
		if(notes.size() > 0){
			name = notes[0].Parent.Name;
			return name;
		}
		else
		{
			if(attachs.size() > 0){
				name = attachs[0].Parent.Name;
				return name;
			}
		}
		return '';
	}
	
	/*
	*@ Return the parent id
	*/
	public Id getPId(){
		return pid;
	}
	
	/*
	* Create inner class to shows all notes & attachs in the same list
	*/
	public class NotesAndAttachments{
		String id;
		String body;
		String documentType;
		String lastModified;
		String title;
		String createdDate;
		String lastModifiedDate;
		DateTime createdDateOriginal;
		
		
		public NotesAndAttachments(String pid, String pTitle, String ptype, String pbody, String plastModified, DateTime pcreatedDate, DateTime plastModifiedDate){
			id = pid;
			body = pbody;
			documentType = ptype;
			lastModified = plastModified;
			title = pTitle;
			createdDate = String.valueOf(pcreatedDate.format('MM/dd/yyyy'));
			lastModifiedDate = String.valueOf(plastModifiedDate.format('MM/dd/yyyy'));
			createdDateOriginal = pcreatedDate;
		}
		
		/*
		*@ Return file Id
		*/
		public String getId(){
			return id;
		}
		/*
		*@ Return file Description
		*/
		public String getBody(){
			return body;
		}
		/*
		*@ Return file type (Note / Attachment)
		*/
		public String getDocumentType(){
			return documentType;
		}
		/*
		*@ Return Last modified User Name
		*/
		public String getLastModified(){
			return lastModified;
		}
		/*
		*@ Return file Title
		*/
		public String getTitle(){
			return title;
		}
		
		/*
		*@ Return Created Date
		*/
		public String getCreatedDate(){
			return createdDate;
		}
		
		/*
		*@ Return Last Modified Date
		*/
		public String getLastModifiedDate(){
			return lastModifiedDate;
		}
		
		/*
		*@ Return true if the file is a note
		*/
		public boolean getIsNote(){
			if(documentType == 'Note'){
				return true;
			}
			return false;
		}
		/*
		*@ Return true if the file is an attachment
		*/
		public boolean getIsAttach(){
			if(documentType == 'Attachment'){
				return true;
			}
			return false;
		}
		
		public DateTime getCreatedDateOriginal()
		{
			return createdDateOriginal;		
		}
		
		public void setCreatedDateOriginal(DateTime value)
		{
			createdDateOriginal = value;	
		}
	}
}