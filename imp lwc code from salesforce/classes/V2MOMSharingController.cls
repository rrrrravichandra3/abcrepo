public with sharing class V2MOMSharingController {


     V2MOM__c v2momObject = new V2MOM__c();
     String v2momId;
     String userToAdd;
     List<User> users;
     public String currentSearchTerm = '';
     String usersToAdd;
     Boolean readOnlyAccess;
     User currentUser;
     List<V2MOM__Share> originalShareList;
     Map<Id,V2MOM__Share> originalShareMap = new Map<Id,V2MOM__Share>();
     String v2momShare = '';
     String shareWith;
     
    public V2MOMSharingController()
    {
        
    }
    
    public String getV2momShare(){
 		return v2momShare;	
 	}
 	public void setV2momShare(String s){
 		v2momShare = s;	
 	}

        // selects the values of the v2mom
    public void setV2momId(String id){
    	originalShareMap =  new Map<Id,V2MOM__Share>();
        v2momId = id;
        
        v2momObject = [select Id, OwnerId, Share_With__c from V2MOM__c  where Id =: v2momId];
        
        users = [select Id, Name from User where IsActive = true and Id !=: v2momObject.OwnerId order by Name limit 100 ];
        currentUser = [select Id, Name from User Where Id =: UserInfo.getUserId() ];
        
        originalShareList = [Select v.UserOrGroupId, v.ParentId From V2MOM__Share v Where ParentId =: v2momObject.Id ];
  		
        for (V2MOM__Share v2ms: originalShareList)
        {
            originalShareMap.put(v2ms.UserOrGroupId,v2ms);
            
        }
    }
    
    // returns the v2mom Id
    public String getV2momId(){ 
        return v2momId;
    }
    
    public String getShareWith()
    {
    	return shareWith;
    }
    
    public V2MOM__c getv2momObject()
    {
        return v2momObject; 
    }
    
    public void setv2momObject(V2MOM__c v)
    {
        this.v2momObject = v;
    }
    
    public void SaveShareWith()
    {
        usersToAdd = System.currentPageReference().getParameters().get('usersToAdd');
        shareWith = System.currentPageReference().getParameters().get('shareWith');
        String idv2mom = System.currentPageReference().getParameters().get('id');
        
        v2momObject = [select Id, OwnerId, Share_With__c from V2MOM__c  where Id =: idv2mom];
        
        AddUserToShare();

		v2momObject.Share_With__c = shareWith;
		
        update v2momObject;
    }
    
     public List<SelectOption> getUsers() {

        List<SelectOption> options = new List<SelectOption>();
        
        if (currentSearchTerm != '')
        {
            users =  [select Id, Name from User Where Name like : '%' + currentSearchTerm + '%' and IsActive = true and Id !=: v2momObject.OwnerId order  by Name limit 100 ];
        }
        
        for (User u : users)
        {
            options.add( new SelectOption(u.Id, u.Name));
            
        }
        
        return options;
    } 
    
    public void setUserToAdd(String value)
    {
        userToAdd = value;
    }
    
    public String getUserToAdd()
    {
        return userToAdd;   
    }
    
    public String getCurrentSearchTerm()
    {
        return currentSearchTerm;   
    }
    
    public void setCurrentSearchTerm(String value)
    {
        currentSearchTerm = value;  
    }
    
    public void SearchForUsers()
    {
        
        users = [select Id, Name from User Where Name like : '%' + currentSearchTerm + '%' and IsActive = true and Id !=: v2momObject.OwnerId order  by Name limit 100 ];
		
    }
    
    public void clearSearch()
    {
    	users = [select Id, Name from User where IsActive = true and Id !=: v2momObject.OwnerId order by Name limit 100 ];
    }
    
    public void setUsersToAdd(String value)
    {
        usersToAdd = value;
    }
    
    public String getUsersToAdd()
    {
        return usersToAdd;  
    }
    
    public Boolean getReadOnlyAccess()
    {
        return readOnlyAccess;
    }
    
    public void setReadOnlyAccess(Boolean value)
    {
        readOnlyAccess = value; 
    }
    
    public String getIndividualsUsers()
    {
    	String [] allIndividualsAdded = usersToAdd.split(';');
    	String usersToReturn = '';
    	Boolean firstTime = true;
    	
    	for (String s:allIndividualsAdded)
    	{
    		String individual = s.split(',')[0];
    		
    		if (firstTime)
    		{
    			usersToReturn = individual; 	
    			firstTime = false;
    		}
    		else
    		{
    			usersToReturn = usersToReturn + '; ' + individual;
    		}
    	}
    	
    	return usersToReturn;
    }
    
    public String getShareWithWithSpaces()
    {
    	String [] shareWithGroups = shareWith.split(';');
    	String groups = '';
    	Boolean firstTime = true;
    	
    	for (String s:shareWithGroups )
    	{
    		if (firstTime)
    		{
    			groups = s;
    			firstTime = false;
    		}
    		else
    		{
    			groups = groups + '; ' + s;
    		}
    	}
    	
    	return groups;
    }
    
    public void AddUserToShare()
    {
        List<V2MOM__Share> v2momShareList = new List<V2MOM__Share>();  
        List<String> usersToSplit = usersToAdd.split(';');
        List<Id> userShare = new List<Id>();
        List<User> userList;
        Map<Id, User> userMap = new Map<Id,User>();
        List<V2MOM__Share> sharesToDelete = new List<V2MOM__Share>();
        List<V2MOM__Share> sharesToAdd = new List<V2MOM__Share>();
        
        
        
        users = [select Id, Name from User where IsActive = true and Id !=: v2momObject.OwnerId order by Name limit 100 ];
        currentUser = [select Id, Name from User Where Id =: UserInfo.getUserId() ];
        
        originalShareList = [Select v.UserOrGroupId, v.ParentId From V2MOM__Share v Where ParentId =: v2momObject.Id ];
        
  		
        for (V2MOM__Share v2ms: originalShareList)
        {
            originalShareMap.put(v2ms.UserOrGroupId,v2ms);
            
        }
        
        String accessLevel;
        
        for (String user : usersToSplit)
        {	
        	
            if (usersToAdd != '')
            { 
                List<String> userIdList;
                userIdList = user.split(',');
        
        		try
        		{
	                Id userId = userIdList[1];
	                userShare.add(userId);
        		}
        		catch (Exception ex)
        		{
      
        		}
            }   
        }
   		
        userList = [select Id, Name from User Where id in : userShare];
        
        for (User us:userList)
        {
            userMap.put(us.Id,us);  
        }
       
        for (User u:userList)
        {
            
            V2MOM__Share v2momShare = new V2MOM__Share(ParentId = v2momObject.Id ,
                                                         UserOrGroupId = u.Id,
                                                         AccessLevel = 'Read');
            
        
            
            
            if (originalShareMap.get(u.Id) == null)
            {
            
                v2momShareList.add(v2momShare);
                
                sharesToAdd.add(v2momShare);
            }
 			
        }
        
        
        for (V2MOM__Share v2ms : originalShareList)
        {
            //Check if one is deleted
          
            if (userMap.get(v2ms.UserOrGroupId) == null && IsUserObject(v2ms.UserOrGroupId) && v2ms.UserOrGroupId != v2momObject.OwnerId )
            {
                sharesToDelete.add(v2ms);
            }
            
        }
        
        originalShareList = [Select v.UserOrGroupId, v.ParentId From V2MOM__Share v Where ParentId =: v2momObject.Id ];
        
        originalShareMap = new Map<Id, V2MOM__Share>();
        
        for (V2MOM__Share v2ms: originalShareList)
        {
            originalShareMap.put(v2ms.UserOrGroupId,v2ms);
        }
        
        if (sharesToAdd.size() > 0)
        {
            insert sharesToAdd;
        }
        if (sharesToDelete.size() > 0)
        {
            delete sharesToDelete;
        }
        
    }
    
    public User getUser()
    {
        return currentUser;
    }
    
    public Boolean IsUserObject(Id id) {
        String prefix = getObjectPrefix('User');
        
        String userPrefix = id;
        userPrefix = userPrefix.subString(0,3);
        
        if (prefix == userPrefix){
        	//Is user object
        	return true;
        }
        return false;
    }
    
    /*
	** Get Object Prefix
	* input : User
	* result: 005
	*/
	public String getObjectPrefix (String objectName) {
	    Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    Schema.DescribeSObjectResult descRes = schemaMap.get(objectName).getDescribe();
	    return descRes.getKeyPrefix();
	}
   
}