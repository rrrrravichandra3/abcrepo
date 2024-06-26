/**
* #DreamJobCentral
* @date:        5/9/2013
* @description: Controller for ESDJC_AdminContent. Allows user to add/remove content for a country.
*               Thease contents will be shown at community home page according to country of logged in user.
**/
public with sharing class ESDJC_AdminContentController {
    public map<id,set<id>> countryContentMap; 
    public ESDJC_Content__c content1{get;set;}
    public Map<string,list<CountryWrapper> > regionMap{get;set;}
    public ESDJC_AdminContentController(ApexPages.StandardController controller) {
        content1 = [select id,name from ESDJC_Content__c where id=:controller.getRecord().Id];
        countryContentMap = new map<id,set<id>>();
        for(ESDJC_Country__c cc : [select id,Name, (select id,ESDJC_Content__r.id,ESDJC_Content__r.Name from ESDJC_ContryContents__r) from ESDJC_Country__c ]){
            set<id> idSet = new set<id>();
            for(ESDJC_ContryContent__c c : cc.ESDJC_ContryContents__r){
                idSet.add(c.ESDJC_Content__r.id);
            }
            countryContentMap.put(cc.Id,idSet);
        }
        
        getCountries();
    }
   
    /*
    *   Get all the country records along with current contents.
    */
    public void getCountries(){
        regionMap = new Map<string,list<CountryWrapper> >();
       
       for(ESDJC_Region__c r : [select Id,Name, (select id,Name from ESDJC_Countries__r) from ESDJC_Region__c] ){
           
           list<CountryWrapper> cw = new list<CountryWrapper>();
           for(ESDJC_Country__c c : r.ESDJC_Countries__r){
               if(countryContentMap.get(c.Id) !=null && countryContentMap.get(c.Id).contains(content1.Id))
                   cw.add(new CountryWrapper(c.Name,c.Id,true)); 
               else
                   cw.add(new CountryWrapper(c.Name,c.Id,false));        
           }
           regionMap.put(r.Name,cw);        
           
       }
        
    }
    
    public void addContents() {
    	//Note to Prafull. Please add the code here
    }
    
    /*
    * Add or remove content 
    */
    public PageReference addRemoveContents(){
        boolean createContent = true;
        list<ESDJC_ContryContent__c> contentToCreate = new  list<ESDJC_ContryContent__c>();
        
        for(list<CountryWrapper> c : regionMap.values()){
            for(CountryWrapper cc : c ){
               //Check if content is added
                if(cc.isSelected){
                    if(countryContentMap.get(cc.countryId) !=null && countryContentMap.get(cc.countryId).contains(content1.Id) != true){
                        //A country should have maximum 5 contents at a time                       
                        if(countryContentMap.get(cc.countryId).size() > 4){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Country '+ cc.country +' Already has 5 Contents '));
                            createContent = false;
                        }
                        else{
                            contentToCreate.add(new ESDJC_ContryContent__c(ESDJC_Content__c = content1.id, ESDJC_Country__c = cc.countryId)); 
                        }
                    }
                    
                    
                }
                //Check if content is removed
                if(!cc.isSelected){
                    if(countryContentMap.get(cc.countryId) !=null && countryContentMap.get(cc.countryId).contains(content1.Id)){
                        list<ESDJC_ContryContent__c> contentToDelete = new  list<ESDJC_ContryContent__c>();
                        try{
                            contentToDelete= [select id from ESDJC_ContryContent__c where ESDJC_Content__c =: content1.id and ESDJC_Country__c =: cc.countryId];
                        }
                        catch(exception e){
                            system.debug(e);
                        }
                        
                        if(contentToDelete != null)
                        	if (Schema.sObjectType.ESDJC_ContryContent__c.isDeletable()){
                            	delete contentToDelete;
                        	}
                        	else{
                        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You don\'t have sufficient privilages to perform this action. Please Contact your System Administrator'));
        						return null;	
                        	}
                    }
                    
                        
                }
                
            }
        }
               
        if(createContent){
        	if (Schema.sObjectType.ESDJC_ContryContent__c.isCreateable()){
	            if(contentToCreate.size()>0)
	            insert contentToCreate;
	        
	            Pagereference pf = new Pagereference('/'+content1.Id);
	            pf.setRedirect(true);
	            return pf;
        	}
        	else{
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You don\'t have sufficient privilages to perform this action. Please Contact your System Administrator'));
        		return null;
        	}
        }
        else{
            system.debug('added');
            return null;
        }    
    }
    /*
    *Wrapper class for countries.
    */
    public with sharing class CountryWrapper{
        public boolean isSelected{get;set;}
        public string country{get;set;}
        public id countryId{get;set;}
        
        
        public CountryWrapper(string country, id countryId, boolean isSelected){
            this.isSelected = isSelected;
            this.country = country;
            this.countryId = countryId;
        }
    }
    
        

}