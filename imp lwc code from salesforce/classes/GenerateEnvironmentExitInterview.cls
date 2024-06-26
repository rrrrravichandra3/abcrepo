public class GenerateEnvironmentExitInterview 
{

	public static ExitInterview__c exitInterview = new ExitInterview__c() ;
	public static ExitInterviewComment__c exitInterviewComment;
	public static ExitInterviewCommentContinue__c exitInterviewCommentContinue;
	public static User employeeStandard;
    public static User managerStandard;
    
	public static List<User> userList;
	
	public static ExitInterview__c getExitInterview()
	{
		return exitInterview;	
	}
	
	public static ExitInterviewComment__c getExitInterviewComment()
	{
		return exitInterviewComment;
	}
	
	public static ExitInterviewCommentContinue__c getExitInterviewCommentContinue()
	{
		return exitInterviewCommentContinue;
	}
	
	private static void createExitInterview()
	{
		exitInterview.Employee__c = employeeStandard.Id;
		exitInterview.OwnerId = employeeStandard.Id;
		exitInterview.Status__c = 'Not Completed';
	} 
	
	public static void insertExitInterview()
	{
		exitInterview.Employee__c = userInfo.getUserId();
		exitInterview.OwnerId = userInfo.getUserId();
		exitInterview.Status__c = 'Not Completed';
		
		insert exitInterview;
		
		exitInterviewComment = new ExitInterviewComment__c();
		exitInterviewCommentContinue = new ExitInterviewCommentContinue__c();
		
		exitInterviewComment.ExitInterview__c = exitInterview.Id;
		exitInterviewCommentContinue.ExitInterview__c = exitInterview.Id;
		try{
			insert exitInterviewComment;
			insert exitInterviewCommentContinue;		
		}catch(Exception e){
			
		}
	} 
	
	public static void insertExitInterviewNoComments()
	{
		exitInterview.Employee__c = userInfo.getUserId();
		exitInterview.OwnerId = userInfo.getUserId();
		exitInterview.Status__c = 'Not Completed';
		try{
			insert exitInterview;	
		}catch(Exception e){
			
		}
	} 

	public static void genExitInterviewEnvironment()
	{
		getUsers();
		
		createExitInterview();
	}
	public static void getUsers(){
		userList = [select id, username, Profile.Name, CompanyName from User 
												where username=:GenerateEnvironmentTestUsers.ccpcomm 
												or username=:GenerateEnvironmentTestUsers.ccesadmin
												or username=:GenerateEnvironmentTestUsers.ccceo
												or username=:GenerateEnvironmentTestUsers.ccesbp
												
												or username=:GenerateEnvironmentTestUsers.ccstndempl
												or username=:GenerateEnvironmentTestUsers.ccstndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevstndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevstnd2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccstnd2ndmngr
												
												or username=:GenerateEnvironmentTestUsers.ccsup2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevsup2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccsupmngr
												or username=:GenerateEnvironmentTestUsers.ccrevsupmngr
												or username=:GenerateEnvironmentTestUsers.ccsupempl
												
												or username=:GenerateEnvironmentTestUsers.ccedu2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevedu2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccedumngr
												or username=:GenerateEnvironmentTestUsers.ccrevedumngr
												or username=:GenerateEnvironmentTestUsers.cceduempl
												
												or username=:GenerateEnvironmentTestUsers.cccons2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevcons2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccconsmngr
												or username=:GenerateEnvironmentTestUsers.ccrevconsmngr
												or username=:GenerateEnvironmentTestUsers.ccconsempl
												
												or username=:GenerateEnvironmentTestUsers.cccsm2ndmngr
												or username=:GenerateEnvironmentTestUsers.ccrevcsm2ndmngr
												or username=:GenerateEnvironmentTestUsers.cccsmmngr
												or username=:GenerateEnvironmentTestUsers.ccrevcsmmngr
												or username=:GenerateEnvironmentTestUsers.cccsmempl
												or username=:GenerateEnvironmentTestUsers.ccconsempl
												];
												
		
							 					
		//employeeStandard = getUser(GenerateEnvironmentTestUsers.ccstndempl);
		employeeStandard = getEmployeeStandard();
	}
	
  	public static User getUser(String oname)
  	{
        for (User u : userList){
            if (u.username.equals(oname))
            {
                return u;
            }
        }
        return null;
    }
    
    public static User getManager(){
						
		if(managerStandard == null){
			Profile p = [Select Id From Profile where Name =: 'Manager'];
			managerStandard =  new User(	username='test__manager@test.com',
								lastName='testManager',
								email='managertest@mailinator.com',
								alias='mtest',
								timeZoneSidKey='America/Los_Angeles',
								localeSidKey='en_US',
								emailEncodingKey='ISO-8859-1',
								LanguagelocaleKey='en_US',
								ProfileID = p.Id);
			/* Run As Review Employee */
			system.runAs( getSystemAdmin()){
				insert managerStandard;	
			}					
			
		}
		return managerStandard;
		
	}
    
    public static User getEmployeeStandard(){
    	Profile p = [Select Id From Profile where Name =: 'Employee'];
		employeeStandard =  [Select id from User where ProfileId=:p.id limit 1];
		/* Run As Review Manager */
		return employeeStandard;									
    }
    
    public static User getSystemAdmin(){
		Profile p = [Select Id From Profile where Name =: 'System Administrator'];
		User adminUser = [Select id From User Where ProfileID =: p.Id And IsActive =: True limit 1][0];
		return adminUser; 
	}	
    @isTest
    static void test1(){
    	User admin = GenerateEnvironmentExitInterview.getSystemAdmin();
    	//User empStandard = GenerateEnvironmentExitInterview.getEmployeeStandard();
    	GenerateEnvironmentExitInterview.getManager();
    	GenerateEnvironmentExitInterview.getUsers();
    	GenerateEnvironmentExitInterview.getUser('Test');
    	GenerateEnvironmentExitInterview.createExitInterview();
    	GenerateEnvironmentExitInterview.insertExitInterview();
    	GenerateEnvironmentExitInterview.insertExitInterviewNoComments();
    	GenerateEnvironmentExitInterview.genExitInterviewEnvironment();
    }
}