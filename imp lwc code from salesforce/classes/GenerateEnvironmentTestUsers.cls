public class GenerateEnvironmentTestUsers {

		public static String org = '@' + UserInfo.getUserName().split('@')[1]; 
		public static String ccpcomm = 'ccpcomm' + org; 
		public static String ccesadmin = 'ccesadmin' + org;
		public static String ccceo = 'ccceo' + org;
		public static String ccesbp = 'ccesbp' + org;
		public static String ccemptysupempl = 'ccemptysupempl' + org;
		public static String ccconsemplwstndmngr = 'ccconsemplwstndmngr' + org;
		
		public static String ccstndempl = 'ccstndempl' + org;
		public static String ccstndmngr = 'ccstndmngr' + org;
		public static String ccrevstndmngr = 'ccrevstndmngr' + org;
		public static String ccrevstnd2ndmngr = 'ccrevstnd2ndmngr' + org;
		public static String ccstnd2ndmngr = 'ccstnd2ndmngr' + org;
		
		public static String ccsup2ndmngr = 'ccsup2ndmngr' + org;
		public static String ccrevsup2ndmngr = 'ccrevsup2ndmngr' + org;
		public static String ccsupmngr = 'ccsupmngr' + org;
		public static String ccrevsupmngr = 'ccrevsupmngr' + org;
		public static String ccsupempl = 'liarmstrong' + org;
		
		public static String ccedu2ndmngr = 'ccedu2ndmngr' + org;
		public static String ccrevedu2ndmngr = 'ccrevedu2ndmngr' + org;
		public static String ccedumngr = 'ccedumngr' + org;
		public static String ccrevedumngr = 'ccrevedumngr' + org;
		public static String cceduempl = 'cceduempl' + org;
		
		public static String cccons2ndmngr = 'cccons2ndmngr' + org;
		public static String ccrevcons2ndmngr = 'ccrevcons2ndmngr' + org;
		public static String ccconsmngr = 'ccconsmngr' + org;
		public static String ccrevconsmngr = 'ccrevconsmngr' + org;
		public static String ccconsempl = 'ccconsempl' + org;
		
		public static String cccsm2ndmngr = 'cccsm2ndmngr' + org;
		public static String ccrevcsm2ndmngr = 'ccrevcsm2ndmngr' + org;
		public static String cccsmmngr = 'cccsmmngr' + org;
		public static String ccrevcsmmngr = 'ccrevcsmmngr' + org;
		public static String cccsmempl = 'cccsmempl' + org;
		
		
	    public static User employee;
	    public static V2MOM__c v2mom;
	    public static User manager;
	    public static Profile userProfile;
	    public static Profile userProfileManager;
	    public static User userAux;

		
		public static User createEmployeeWithManager(){
	 	
	 	    manager = new User(); 
            manager.Alias = 'Manager'; 
            manager.FirstName = 'Annie'; 
            manager.LastName = 'Lynch'; 
            manager.Email = 'dynorgchart'+manager.Alias+'@mailinator.com'; 
            manager.Username='Annie@peopleforce.com.config3'; 
            manager.CommunityNickname=manager.Alias+'1234'; 
            manager.TimeZoneSidKey='America/Los_Angeles'; 
            manager.LocaleSidKey='en_US'; 
            manager.EmailEncodingKey='ISO-8859-1'; 
            manager.LanguageLocaleKey='en_US'; 
            userProfileManager=[Select id from Profile where Name like 'Manager' limit 1 ]; 
            manager.ProfileId=userProfileManager.Id; 
            insert manager;
	 	
            employee = new User(); 
            employee.Alias = 'A2'; 
            employee.FirstName = 'Annie2'; 
            employee.LastName = 'Lynch2'; 
            employee.Email = 'dynorgchart'+employee.Alias+'@mailinator.com'; 
            employee.Username='Annie2@peopleforce.com.config3'; 
            employee.CommunityNickname=employee.Alias+'1234'; 
            employee.TimeZoneSidKey='America/Los_Angeles'; 
            employee.LocaleSidKey='en_US'; 
            employee.EmailEncodingKey='ISO-8859-1'; 
            employee.LanguageLocaleKey='en_US';
            employee.EmployeeNumber='345345435'; 
            userProfile=[Select id from Profile where Name like 'Employee' limit 1 ]; 
            employee.ProfileId=userProfile.Id; 
             
            insert employee; 
             
            userAux=[Select id from user where Alias Like 'A2' limit 1];
            userAux.managerId=manager.id; 
            update userAux;
		    
		    return employee;
		}
		
	  public static User createManager(){
	 	    manager = new User(); 
            manager.Alias = 'Managername'; 
            manager.FirstName = 'Managername'; 
            manager.LastName = 'Lynch'; 
            manager.Email = 'dynorgchart'+manager.Alias+'@mailinator.com'; 
            manager.Username='manager@peopleforce.com.config3'; 
            manager.CommunityNickname=manager.Alias+'1234'; 
            manager.TimeZoneSidKey='America/Los_Angeles'; 
            manager.LocaleSidKey='en_US'; 
            manager.EmailEncodingKey='ISO-8859-1'; 
            manager.LanguageLocaleKey='en_US'; 
            userProfileManager=[Select id from Profile where Name like 'Manager' limit 1 ]; 
            manager.ProfileId=userProfileManager.Id; 
            insert manager;
	 	    return manager;
		}
		
	    public static User create2ndManager(){
	 	    manager = new User(); 
            manager.Alias = '2ndManager'; 
            manager.FirstName = '2ndManager'; 
            manager.LastName = 'Lynch'; 
            manager.Email = 'dynorgchart'+manager.Alias+'@mailinator.com'; 
            manager.Username='2ndManager@peopleforce.com.config3'; 
            manager.CommunityNickname=manager.Alias+'1234'; 
            manager.TimeZoneSidKey='America/Los_Angeles'; 
            manager.LocaleSidKey='en_US'; 
            manager.EmailEncodingKey='ISO-8859-1'; 
            manager.LanguageLocaleKey='en_US'; 
            userProfileManager=[Select id from Profile where Name like 'Manager' limit 1 ]; 
            manager.ProfileId=userProfileManager.Id; 
            insert manager;
	 	    return manager;
		}
		
	    public static User createPCOMM(){
	 	    manager = new User(); 
            manager.Alias = 'PCOMM'; 
            manager.FirstName = 'test'; 
            manager.LastName = 'PCOMM'; 
            manager.Email = 'dynorgchart'+manager.Alias+'@mailinator.com'; 
            manager.Username='tespcomm@peopleforce.com.config3'; 
            manager.CommunityNickname=manager.Alias+'1234'; 
            manager.TimeZoneSidKey='America/Los_Angeles'; 
            manager.LocaleSidKey='en_US'; 
            manager.EmailEncodingKey='ISO-8859-1'; 
            manager.LanguageLocaleKey='en_US'; 
            userProfileManager=[Select id from Profile where Name like 'PCOMM' limit 1 ]; 
            manager.ProfileId=userProfileManager.Id; 
            insert manager;
	 	    return manager;
		}
		
		
		
		
}