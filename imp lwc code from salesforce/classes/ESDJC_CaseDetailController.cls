/**
* #DreamJobCentral
* @date:        4/26/2013
* @description: Controller for ESDJC_CaseDetailPage. Show case details inculding case comments, attachments and attached Articles.
*               Also allow to add new comments and attachments.
**/
public with sharing class ESDJC_CaseDetailController {
    public string url{get;set;}
    public string cm{get;set;}
    public case currentCase{get;set;}
    public string fileName{get;set;}
    public boolean showFile{get;set;}
    public boolean showComment{get;set;}
    public transient blob file{get;set;}
    public boolean showIsReferenceTo {get;set;}
    public String inReferenceTo {get;set;}
    
    public ESDJC_CaseDetailController(ApexPages.StandardController controller) {
        //url=ESDJC_Util.getSSOURL();
        showIsReferenceTo = false;
        url=ESDJC_Util.getSiteURL();
        if (Schema.sObjectType.CaseComment.isCreateable()){
            showComment = true;    
        }
        else{
            showComment = false;
        }
        
        if (Schema.sObjectType.Attachment.isCreateable()){
            showFile = true;    
        }
        else{
            showFile = false;
        }
        
        Id caseId = controller.getRecord().Id;
        currentCase = [select id,Contactid,ES_DJC_Description__c,In_Reference_To__c,In_Reference_To__r.Name,recordtype.DeveloperName,CaseNumber, Status, ES_DJC_Title__c, Origin,Type, ES_DJC_Topic__c, ES_DJC_Sub_Topic__c,Subject,Description,OwnerId,Priority from Case where id =: caseId];
        
        if(currentCase.recordtype.DeveloperName.equals('ES_DJC_Employee_Relations_Case_Type_Amer') || currentCase.recordtype.DeveloperName.equals('ES_DJC_Employee_Relations_Case_Type_APAC') || currentCase.recordtype.DeveloperName.equals('ES_DJC_Employee_Relations_Case_Type_EMEA') || currentCase.recordtype.DeveloperName.equals('Employee_Relations_Case_Type_Japan')){
            showIsReferenceTo=true;
            inReferenceTo = (currentCase.In_Reference_To__c!=null)? currentCase.In_Reference_To__r.Name : null;
            
        }
    }
    
    /*
    ** Redirect to home page if case contact is not same as user contact
    */
    public PageReference redirectToHomePageIfNotUserCase() {
    	User u = [select ContactId from User where Id=:UserInfo.getUserId()];
    	if (u.ContactId != null && currentCase.ContactId != u.ContactId) {
    		return Page.ESDJC_CasesHomePage;
    	}
    	return null;
    }
    /*
    *   Show existing attachements. 
    */
    public list<Attachment> getAttachments(){
        List<Attachment> attList;
        try{
            attList = [select id,Name,LastModifiedDate from Attachment where ParentId =:currentCase.id ];
        }
        catch(exception e){
            
        }
        
        return attList;
    }
    
    /*
    *   Show articles attached to case. 
    */
    public list< ArticleWrapper > getArticles(){
        List< ArticleWrapper > artList = new list<ArticleWrapper>();
        List<id> knoId = new List<id>();
        map<id,CaseArticle> idMap = new map<id,CaseArticle>();
            for( CaseArticle c:[select id,CreatedDate,SystemModstamp,KnowledgeArticleId from CaseArticle where CaseId =:currentCase.id ]){
                knoId.add(c.KnowledgeArticleId);
                idMap.put(c.KnowledgeArticleId,c);
            }
            
            if(knoId.size()>0){
              for(KnowledgeArticleVersion ko :  [select id,Title,KnowledgeArticleId,LastPublishedDate from KnowledgeArticleVersion where KnowledgeArticleId in :idMap.keySet() and IsLatestVersion = true and PublishStatus = 'Online']){
                  
                  artList.add(new ArticleWrapper(idMap.get(ko.KnowledgeArticleId),ko));
                      
                      
              }
            }
        
        return artList;
    }
    
    /*
    *   view existing attachement. 
    */
    public PageReference view() {
        
        
        return (new ApexPages.StandardController(new Attachment(id =ApexPages.currentPage().getParameters().get('attId') ))).view();
    }
   
   /*
    *   Create new attachements. 
    */
    public PageReference uploadFile(){
        
        if(file ==null || fileName==null){
            return null;
        }
       
       if (Schema.sObjectType.Attachment.isCreateable()){
           try{
                Attachment att =  new Attachment(body = file, ParentId =currentCase.id,Name=fileName );
                file = null;
                fileName = null;
                insert att;
            } 
            catch(exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You don\'t have sufficient privilages to perform this action. Please Contact your System Administrator'));
                return null;
            }
            return null;
       }
       else{
           file = null;
           fileName = null;
           
           return null;
       }     
    }
    
    /*
    *   Add new Comment. 
    */
    public PageReference addComment(){
        CaseComment cs = new CaseComment(CommentBody = cm,ParentId =currentCase.id );
        cm = null;
        if (Schema.sObjectType.CaseComment.isCreateable()){
            //insert cs;
             Database.DMLOptions dlo = new Database.DMLOptions(); 
            dlo.EmailHeader.triggerUserEmail = true; 
            database.insert( cs, dlo);
        }
        return null;
    }
    
    /*
    *   Show Existing Comment. 
    */
    public list<CaseComment> getComments(){
            return [Select LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, IsPublished, CreatedDate, CreatedBy.Id, CreatedBy.Name, CommentBody,parent.owner.name From CaseComment c where ParentId = :currentCase.id order by c.LastModifiedDate desc];
            
    }
    
    /*
    *   Wrapper to show articles attached to case. 
    */ 
    public with sharing Class ArticleWrapper{
        public CaseArticle ca{get;set;}
        public KnowledgeArticleVersion ko{get;set;}
        
        public ArticleWrapper(CaseArticle ca,KnowledgeArticleVersion ko){
            this.ca=ca;
            this.ko=ko;
        
        }
        
    }
}