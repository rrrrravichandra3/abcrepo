/**
* #DreamJobCentral
* @date:        4/25/2013
* @description: Controller for ESDJC_KnowledgeSearchPage. get SSO url to swith between tabs.
**/
public with sharing class ESDJC_KnowledgeSearchController {
    public string url{get;set;}
    public string currentCat{get;set;}
    public string searchText{get;set;}
    public string searchTextWithoutSpace{get;set;}
    public list<KnowledgeArticleVersion> articleList{get;set;}
    public string category{get;set;}
    public boolean showPopularArticles{get;set;}
    public boolean showSearchResult{get;set;}
    public list<catWrapper> catList{get;set;} 
    public Map<catWrapper,list<catWrapper>> catMap{get;set;}
    public map<KnowledgeArticleVersion,decimal> articleMap{get;set;}
    public Contact userContact{get;set;}
    public user currentUser{get;set;}
    public list<articleWrapper> artilcleWrapperList{get;set;}
    public String languageFilter{get;set;}
        
    public ESDJC_KnowledgeSearchController(){ 
        
        //url=ESDJC_Util.getSSOURL();
        url = ESDJC_Util.getSiteURL();
        languageFilter= ESDJC_Util.getUserLanguage();
        try{
            currentUser = [select ContactId from User where id =: UserInfo.getUserId()];
            userContact = [select ES_DJC_Is_Manager__c from Contact where id =: currentUser.ContactId];
            
        } 
        catch(exception e){
            system.debug('Exception'+e);
            
        } 
        
        getCats(); 
        
        showPopularArticles = true;
        showSearchResult = false;  
        currentCat = 'All';
        
        if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('knoParam')) && ApexPages.currentPage().getParameters().get('knoParam').split(':').size() ==3) {
        	
        	list<string> paramList = ApexPages.currentPage().getParameters().get('knoParam').split(':');
        	if(String.isNotEmpty(paramList[2])){
        		currentCat = paramList[2];	
        	}        	
        	else
        		currentCat = 'All';	
        	
        	searchText = paramList[1];
        	
        	if(String.isNotEmpty(paramList[2]) || String.isNotEmpty(paramList[1])){
        		showPopularArticles = false;
        		
        		showSearchResult = true;  
        		
        		if(String.isNotEmpty(searchText)){
        			searchText = searchText.replace('--',' ' );
        		}
        		searchArticles();	
        	}	
        }
        
	        
        
        
    }
    
    /*
    *   Get data categories from Topic.
    */
    public void getCats() {
        DataCategory [] toplevelCategories;
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','--No Filter--'));
        List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
         
        DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
        p.setSobject('KnowledgeArticleVersion');
        p.setDataCategoryGroupName('Topic');
        pairs.add(p);
        
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult =
        Schema.describeDataCategoryGroupStructures(pairs, false);
        for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            toplevelCategories = singleResult.getTopCategories();  
              
        }
        // Group child categories with top level data categories.
        for(DataCategory category : toplevelCategories){
             catList = new list<catWrapper>();
                for(DataCategory childCat : category.getChildCategories()){   
                    
                    
                    if(childCat.getName() == 'Manager_Resources' && userContact.ES_DJC_Is_Manager__c !=true)
                        break;
                    
                    options.add(new SelectOption(childCat.getName(),'--'+childCat.getLabel().leftPad(5))); 
                    
                    list<catWrapper> cList = new list<catWrapper>();
                    for(DataCategory childCat1 : childCat.getChildCategories()){   
                    	 
                    	if (JapanPermSetUser){
                    		if((childCat1.getName() == 'Pay_and_Benefit_Elections') ||
                    				(childCat1.getName() == 'Flexible_Spending_Account_FSA') ||
                    					(childCat1.getName() == 'On_Call') ||
                    						(childCat1.getName() == 'Non_Cash') ||
                    							(childCat1.getName() == 'Relocations_and_Assignments2'))
                    								continue;
                    				
                    	}else{
                    		if((childCat1.getName() == 'X401K') ||
                    				(childCat1.getName() == 'Cafeteria_Plan') ||
                    					(childCat1.getName() == 'Mortgage_plan') ||
                    						(childCat1.getName() == 'Time_Off_Team_Spirit')){
                    						continue;
                    					}
                    	}

                        
                    	
                        options.add(new SelectOption(childCat1.getName(),'----'+childCat1.getLabel().leftPad(10))); 
                        cList.add(new catWrapper(childCat1.getLabel(),childCat1.getName()));
                    }
                    catList.add(new catWrapper(childCat.getLabel(),childCat.getName(),cList));
                }
        }
        
        
    }    
    
    /*
    *   Search articles according to search text and data category selected.
    */
    public PageReference searchArticles(){
        articleMap = new map<KnowledgeArticleVersion,decimal>(); 
        if(String.isNotEmpty(searchText)){
           searchText = String.escapeSingleQuotes(searchText);
           searchTextWithoutSpace = searchText.replace(' ','--' );
        }
        showPopularArticles = false;
        string queryString = '';
        articleList = new  list<KnowledgeArticleVersion>();
        
        //Search text is not entered. (search knowledge with selected category or its child categories.)
        if(String.isEmpty(searchText) ){
            queryString += 'select id, Title, LastPublishedDate, Summary,KnowledgeArticleId,UrlName from KnowledgeArticleVersion WHERE IsLatestVersion = true AND PublishStatus=\'online\' AND language =\''+languageFilter+'\'' ;
            if(currentCat != null){
                queryString += ' WITH DATA CATEGORY Topic__c ABOVE_OR_BELOW ' + String.escapeSingleQuotes(currentCat) + '__c';
                
            }
            articleList = Database.query(queryString); 
            
        }
        //Search text is  entered. (search knowledge with containing search text and having selected category or its child categories.)
        else{
        	searchText = ESDJC_Util.massageSearchString(searchText);
        	//Sigle quotes escaped for SOQL injection at start of the method
            queryString = 'FIND { ' + searchText  +' }  RETURNING KnowledgeArticleVersion(Id, Title,KnowledgeArticleId, UrlName, LastPublishedDate, Summary WHERE IsLatestVersion = true AND PublishStatus=\'online\' AND language =\''+languageFilter+'\')';
            if(currentCat != null){
                queryString += ' WITH DATA CATEGORY Topic__c ABOVE_OR_BELOW ' + String.escapeSingleQuotes(currentCat) + '__c';
                
            } 
            queryString += ' UPDATE TRACKING';
        
            List<List<SObject>> searchList = search.query(String.escapeSingleQuotes(queryString));
            articleList = (list<KnowledgeArticleVersion>)searchList[0];            
        }
         
        if(articleList.size()>0){
            showSearchResult = true;
        }
        else{
            showSearchResult = false;
        }
        //Get view count.
        map<id,KnowledgeArticleVersion> knoIdMap = new map<id,KnowledgeArticleVersion>();
        artilcleWrapperList = new list<articleWrapper>();
        if(articleList.size()>0)
        {
            for(KnowledgeArticleVersion k : articleList){
                knoIdMap.put(k.KnowledgeArticleId,k);            
            }
            map<id,decimal> viewStatMap = new map<id,decimal>();
            for(KnowledgeArticleViewStat v : [select ViewCount,ParentId from KnowledgeArticleViewStat where Channel = 'Csp' and ParentId in : knoIdMap.keySet()] ){
                //articleMap.put(knoIdMap.get(v.ParentId),v.ViewCount) ;   
            	viewStatMap.put(v.ParentId,v.ViewCount);
            }
            
            for(KnowledgeArticleVersion ar :articleList){
            	system.debug('========'+ar);
            	if(viewStatMap.containsKey(ar.KnowledgeArticleId)){
            		artilcleWrapperList.add(new articleWrapper(ar,viewStatMap.get(ar.KnowledgeArticleId)));
            		
            	}
            	else{
            		artilcleWrapperList.add(new articleWrapper(ar,0));
            	}	
            }
        }
        return  null;
    } 
    
    /*
    *   Wrapper class data categories and css classes.
    */
    public with sharing class catWrapper{
        public string label{get;set;}
        public string value{get;set;}
        public string cl{get;set;}
        
        public list<catWrapper> cList{get;set;}
        
        public catWrapper(string label,string value,list<catWrapper> cList){
            this.label = label;
            this.value = value;
            cl = value+'1';
            this.cList = cList;
        }
        
        public catWrapper(string label,string value){
            this.label = '   '+label;
            this.value = value;
            
            
        }
    
    }
    
    public with sharing class articleWrapper{
    	public 	KnowledgeArticleVersion kno{get;set;}
    	public decimal viewCount{get;set;}
    	
    	public articleWrapper(KnowledgeArticleVersion kno,Decimal viewCount){
    		this.kno = kno;
    		this.viewCount = viewCount;
    	}
    	
    	
    }
    
    	public List<PermissionSetAssignment> PermSetAssignment{
		get{
			if (PermSetAssignment == null){
				PermSetAssignment = new List<PermissionSetAssignment>();
				ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
				List<String> PermSetList = new List<String>{settings.Portal_User_Emea_Permset_Id__c,
        													settings.Portal_User_Amer_Permset_Id__c,
        													settings.Portal_User_Apac_Permset_Id__c,
        													settings.Portal_User_Japan_Permset_Id__c};        			

    			PermSetAssignment = [select id,PermissionSetId 
    									from PermissionSetAssignment 
    									where AssigneeId = :UserInfo.getUserId() and 
    									PermissionSetId IN :PermSetList];
			}
			return PermSetAssignment; 
		}
		set;
	}
    
        public boolean JapanPermSetUser{
    	get{
    		if (JapanPermSetUser == null){
    			JapanPermSetUser = false;
    			ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        		if(settings != null && settings.Portal_User_Japan_Permset_Id__c != null){				    										
    				if ((PermSetAssignment!=null)&& (PermSetAssignment.size() == 1)&&
    						(((String)PermSetAssignment[0].PermissionSetId).contains(settings.Portal_User_Japan_Permset_Id__c) )){
    					JapanPermSetUser = true;
    				}							    			
    			}    		    		
    		}
    		return JapanPermSetUser;
    	}
    	set;
    }    
           
}