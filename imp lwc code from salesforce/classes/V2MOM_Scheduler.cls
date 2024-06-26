global class V2MOM_Scheduler implements Schedulable{
    List<User> users = new List<User>();
    global void execute(SchedulableContext SC){
       
       set<String> userIds = new set<String>();
       set<String> v2momOwnerIds = new set<String>();
       
       //add all v2momns owners to v2momOwnerIds
       
       for(V2MOM__c v : [Select Id, OwnerId from V2MOM__c order by createdDate desc limit 1000]){
            v2momOwnerIds.add(v.OwnerId);
       }
       
       //add all users whose start date is more than 90 days old but less than 96
       for(User u: [select Id, Email, Name, Exclude_from_Emails__c, Start_Date__c from User order by createdDate desc limit 1000]){ 
            if(u.start_Date__C!=null){
	            integer dateDiff = 0;
	            Date UserCreated = u.Start_Date__c;
	            dateDiff = UserCreated.daysBetween(System.today());
	            
	            if(dateDiff >= 90 && dateDiff<=96 && !v2momOwnerIds.contains(u.Id) && !u.Exclude_from_Emails__c){
	                userIds.add(u.Id); 
	                users.add(u); 
	            }
            }
       }
       if(userIds.size()>0){
       		MassSendEmailBatchImpl batch = new MassSendEmailBatchImpl(userIds, users);
       		Database.executeBatch(batch);
       }
   }
   
   //Static methods
   public static testMethod void test_V2MOM_Scheduler() { 
       GenerateEnvironmentTest.genV2MOMPrioritize();
       System.assert(GenerateEnvironmentTest.v2momIndividual != null);
       System.assert(GenerateEnvironmentTest.v2momDepartment != null);
       System.assert(GenerateEnvironmentTest.v2momOnboarding != null);
       
       GenerateEnvironmentTest.employeeStandard.Start_Date__c=System.today();
       //update GenerateEnvironmentTest.employeeStandard;
       Test.StartTest();
       V2MOM_Scheduler controller = new V2MOM_Scheduler();
       Set<String> userToSend = new Set<String>{GenerateEnvironmentTest.employeeStandard.Id};
       List<User> userToSendList = new List<User>{GenerateEnvironmentTest.employeeStandard};
	   controller.execute(null);
       MassSendEmailBatchImpl batch = new MassSendEmailBatchImpl(userToSend, userToSendList);
       Database.executeBatch(batch);
       Test.StopTest();
   }

}