public with sharing class ESDJC_ManageContentController {
    public ESDJC_ContryContent__c content1{get;set;}
    public list<CountryWrapper> addList{get;set;}
    public list<CountryWrapper> removeList{get;set;}
    public ESDJC_Region__c region{get;set;}
    public map<string,list<ESDJC_ContryContent__c>> countryContent{get;set;}
    list< id > countryIdList = new list< id >();
    public map<string,set<Id>> countryContentIdMap;
    
    public ESDJC_ManageContentController(ApexPages.StandardController controller) {
        region = (ESDJC_Region__c)controller.getRecord();
        
        content1 = new ESDJC_ContryContent__c();
        countryContentIdMap = new map<string,set<Id>>();
        addList = new list<CountryWrapper>();
        removeList = new list<CountryWrapper>();
        countryContent = new map<string,list<ESDJC_ContryContent__c>>();
        getcountryContent();
    }
    
    private void getcountryContent(){
    
        for(ESDJC_Country__c cc : [select id,Name, (select id,ESDJC_Content__r.id,ESDJC_Content__r.Name from ESDJC_ContryContents__r) from ESDJC_Country__c where Region__c =: region.Id]){
            
            addList.add(new CountryWrapper(cc.Name,cc.Id));
            removeList.add(new CountryWrapper(cc.Name,cc.Id));
            
            list<ESDJC_ContryContent__c> cList = new list<ESDJC_ContryContent__c>();
            
            set<id> contentIdSet = new set<id>();
            
            for(ESDJC_ContryContent__c c : cc.ESDJC_ContryContents__r){
                cList.add(c);
                contentIdSet.add(c.ESDJC_Content__r.id);
            }
            countryContent.put(cc.Name,cList.deepClone());
            
            countryContentIdMap.put(cc.Name,contentIdSet);
            
        }
    }
    
    public Pagereference addContent(){
	    if(Schema.Sobjecttype.ESDJC_Content__c.isCreateable()){
	        system.debug('------'+content1.ESDJC_Content__c);
	        list<ESDJC_ContryContent__c> contentToCreate = new list<ESDJC_ContryContent__c>();
	        for(CountryWrapper cw : addList){
	            
	            if(cw.isSelected && countryContentIdMap.get(cw.country).contains(content1.ESDJC_Content__c) == false){
	                contentToCreate.add(new ESDJC_ContryContent__c(ESDJC_Content__c = content1.ESDJC_Content__c, ESDJC_Country__c = cw.countryId));    
	            }
	            
	        }
	        
	        if(contentToCreate.size()>0)
	            insert contentToCreate;
    	} else {
				ESDJC_Util.displayAccessPrivilegeError('Create ESDJC_Content__c');
    	}
        
       Pagereference pf = new Pagereference('/ESDJC_ManageContent?id='+region.Id);
        pf.setRedirect(true);
        return pf;
    }
    
    public class CountryWrapper{
        public boolean isSelected{get;set;}
        public string country{get;set;}
        public id countryId{get;set;}
        
        public CountryWrapper(string country, id countryId){
            isSelected = false;
            this.country = country;
            this.countryId = countryId;
        }
        
    }
    
}