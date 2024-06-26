public without sharing class ESDJC_UserSettingController {
	
	public boolean displayPopUp{get;set;}
    public string UserLocale{get;set;}
    public string UserLanguage{get;set;}
	
	public ESDJC_UserSettingController(){
		displayPopUp = false;            
        UserLanguage = UserInfo.getLanguage();
        UserLocale = UserInfo.getLocale();  		
	}
	
	public void displayUserSettings(){
    	displayPopUp = true;
    }
    public void hideUserSettings(){
    	displayPopUp = false;
    }    
        
	public PageReference updateUserSettings(){
		displayPopUp = false;
		Contact c;
		User u = new user(id = UserInfo.getUserId());
		u.LocaleSidKey = UserLocale;
		u.LanguageLocaleKey = UserLanguage;		
		List<User> thisUser = [select ContactId,Contact.ES_DJC_Portal_User_Language__c from User where id=:UserInfo.getUserId() and ContactId!=null];
		if (thisUser.size()>0){
			c = new Contact(id=thisUser[0].ContactId);
			c.ES_DJC_Portal_User_Language__c = UserLanguage;
		}
		SavePoint s = Database.setSavepoint();
		try{
			update u;
			update c;
		}catch(Exception ex){			
			database.rollback(s);
			system.debug(ex);
		}
	    return null;
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