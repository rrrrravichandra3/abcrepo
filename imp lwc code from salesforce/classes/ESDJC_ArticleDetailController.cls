/**
* #DreamJobCentral
* @date:        4/25/2013
* @description: Controller for ESDJC_ArticleDetailPage. Shows Article Details and related articles.
**/

public with sharing class ESDJC_ArticleDetailController {
    public boolean hasAccess{get;set;}
    public string sso{get;set;}
    public boolean fromCase{get;set;}
    public string articleId{get;set;}
    public sobject article{get;set;}      
    public list<string> fieldList{get;set;} 
    public list<string> kewordList{get;set;} 
    public list<sobject> relatedArticles{get;set;}
    public boolean showRelated{get;set;}
    public string caseId{get;set;}
    public string title1{get;set;}
    private list<string> paramList;
    public string knoObject{get;set;}
    public String languageFilter{get;set;}
    
    public ESDJC_ArticleDetailController(){
       title1 = 'title';
       hasAccess = true;
       string artid;
       languageFilter= ESDJC_Util.getUserLanguage();
        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('knoParam') )) {
            artid = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('knoParam'));
            artid =  String.escapeSingleQuotes(artid);
        }
        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('articleNo'))) {
            String artNo = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('articleNo'));
            artNo =  String.escapeSingleQuotes(artNo);
            try{
                boolean isFound=false;
                // for updating to 42.0, I can NOT add language in where close unless the value is hard coded, so the work around is removed it from query and then use if condition
                KnowledgeArticleVersion[] articles = [SELECT KnowledgeArticleId, language  FROM KnowledgeArticleVersion WHERE articleNumber = :artNo AND PublishStatus = 'online'];
               for (KnowledgeArticleVersion kav: articles ){
                if (kav.language ==  languageFilter){
                        artid = kav.KnowledgeArticleId;
                        isFound=true;
                        return;
                }
               }
               if (!isFound) hasAccess = false;

            }
            catch(exception e){
                hasAccess = false;
            }
            
        }

        //sso = ESDJC_Util.getSSOURL();
        sso=ESDJC_Util.getSiteURL();
        if(hasAccess){
            if(artid.contains(',')){
                caseId = artid.split(',')[1];
                articleId = artid.split(',')[0];
                fromCase = true;
            }
            else{
            	paramList = artid.split(':');
                articleId = paramList[0];
                fromCase = false;
            }
            showRelated = false;
            viewArticle();           
        }
        
    }
    
    
    /*
    * Get article type and fields from custom setting and query it to show details.Also search for related articles.
    */
    
    public void viewArticle(){
         
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String,String> keyPrefixMap = new Map<String,String>{};
        Set<String> keyPrefixSet = gd.keySet();
        for(String sObj : keyPrefixSet){
           Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
           String tempName = r.getName();
           String tempPrefix = r.getKeyPrefix();
           keyPrefixMap.put(tempPrefix,tempName);
           
        }   
        // Get article type from Id passed to the controller.
        knoObject = keyPrefixMap.get(articleId.subString(0,3)).deleteWhitespace() +'v';
        
        // Get available article types and feilds from custom setting
        Map<String, ESDJC_Article_Types__c > articleTypeMap = ESDJC_Article_Types__c.getAll();
        string fields = articleTypeMap.get(knoObject).Custom_Fields__c;
        if(string.isNotEmpty(fields))
        fields = fields.deleteWhitespace();
        fieldList = new list<string>();
        //fieldList.addAll(fields.split(','));
        for(string s : fields.split(',')){
        	if (!s.startsWith('Attachment')){
        		fieldList.add(s);
        	}
        }        
        string queryString = 'select summary,title,Keywords__c, id,KnowledgeArticleId,(select DataCategoryGroupName, DataCategoryName from DataCategorySelections ) ';
        if(string.isNotEmpty(fields)){
            queryString += ' , ';
        }
        queryString += fields + ' from ' + knoObject +' WHERE KnowledgeArticleId = \'' +articleId +  '\' and IsLatestVersion = true AND PublishStatus=\'online\' AND language =\''+languageFilter+'\'  UPDATE VIEWSTAT'; 
        
        //Fetch article details.
        system.debug('queryString '+queryString);
        article = Database.query(queryString); 
        list<string> catList = new list<string>();
        if(article.getSObjects('DataCategorySelections') !=null)
        for(integer i=0;i<article.getSObjects('DataCategorySelections').size();i++) {
           if(article.getSObjects('DataCategorySelections')[i].get('DataCategoryGroupName') == 'Topic'){
               catList.add((string)article.getSObjects('DataCategorySelections')[i].get('DataCategoryName'));
           }
        }
        
        //Get related articles. (articles with have one of the keywords in title and same article type and same or lower data category.)
        string kewords=string.valueOf(article.get('Keywords__c'));
        string sosl;
        List<List<SObject>> searchList;
        kewordList = new list<string>();
        if(String.isNotEmpty(kewords)){
            integer i=0;
            string searchPhrase = '(';
            for(string s : kewords.split(',')){
                i++;
                searchPhrase += ESDJC_Util.massageSearchString(s).deleteWhitespace() +'*';
                if(i<kewords.split(',').size())
                    searchPhrase += ' OR ';
                
            }
            searchPhrase += ' ) ';
             sosl = 'FIND { ' + searchPhrase  +' } RETURNING ' +knoObject + '(Id, Title,KnowledgeArticleId, UrlName, LastPublishedDate, Summary WHERE KnowledgeArticleId != \''+ article.get('KnowledgeArticleId') + '\' and IsLatestVersion = true AND PublishStatus=\'online\' AND language =\''+languageFilter+'\' ORDER BY LastPublishedDate DESC limit 10 ) ';
             /*
             if(catList.size()>0){
                 sosl += 'WITH DATA CATEGORY ';
                 for(integer j = 0; j<catList.size();j++){
                    sosl += ' Topic__c BELOW ';
                     sosl += catList[j] + '__c';
                     if(j<catList.size()-1)
                         sosl += ' OR ';
                 }
                 
             }  
             */  
             system.debug('-----'+sosl);
             searchList = search.query(sosl);
            
            relatedArticles =  searchList[0];   
            if(relatedArticles.size()>0)
                showRelated = true;    
        }   
         
    }   
}