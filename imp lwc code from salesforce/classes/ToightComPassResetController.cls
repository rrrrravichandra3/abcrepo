public with sharing class ToightComPassResetController
{
	public Id contactIdPassedCtrl{get; set;}
    public User regUser{get;set;}
    public void initialize(){
        System.debug('####@'+regUser);
        System.debug('####@'+contactIdPassedCtrl);
        List<User> usersFromContact = [SELECT Name,UserName,Email,Profile.Name FROM User WHERE ContactId = :contactIdPassedCtrl LIMIT 1];
        if(!usersFromContact.isEmpty()){
            regUser = usersFromContact[0];
        }
    }
    

	public String getProfileName()
	{
		String profileName = '';
        if(regUser == null){
            initialize();
        }
		
		if(regUser != null)
		{
			profileName = regUser.Profile.Name;
		}

		return profileName;
	}
    
    public String getUserName(){
         if(regUser == null){
            initialize();
        }
        String username = 'Default Value';
        
        if(regUser != null)
		{
			username = regUser.UserName;
		}

		return username;
    }

	public String getName(){
         if(regUser == null){
            initialize();
        }
        String username = 'Default Value';
        
        if(regUser != null)
		{
			username = regUser.Name;
		}

		return username;
    }
}