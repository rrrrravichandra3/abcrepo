global class UserCCAfterInsertUpdateHelper {
  @future
  public static void createUpdateCCRecords(Set<ID> userIds, String triggerType) {
    List<User> users = [Select Manager__c, IsActive, Start_Date__c, Division, ReviewManager__c from user where id in :userIds];
    List<Corporate_Citizenship__c> Corporate_Citizenship = new List<Corporate_Citizenship__c>();
    if(triggerType == 'insert' && users.size() > 0) {
      for(User user : users) {
        Corporate_Citizenship__c CorpCitizen = new Corporate_Citizenship__c();
        CorpCitizen.Employee__c = user.Id;
        CorpCitizen.Manager__c = user.Manager__c;
        CorpCitizen.isActive__c = user.IsActive;
        CorpCitizen.Start_Date__c = user.Start_Date__c;
        Corporate_Citizenship.add(CorpCitizen);
      }
      if(Corporate_Citizenship.size() > 0)
      	System.runAs(GenerateEnvironmentTest.getManager()){
      		Database.insert(Corporate_Citizenship);	
      	}
         
    }
    
    if(triggerType == 'update' && users.size() > 0) {
      map<Id,Corporate_Citizenship__c> mapUserWithCC = new map<Id,Corporate_Citizenship__c>();
      //fetch the cc record where employee is the current user/users
      for (Corporate_Citizenship__c cc:[select Id,Employee__c,
                                               Manager__c,
                                               Start_Date__c,
                                               isActive__c, 
                                               Harassment_and_Descrim_TNG__c, 
                                               Review_Manager__c      
                                       from Corporate_Citizenship__c 
                                       where Employee__c in: userIds]){
            
          mapUserWithCC.put(cc.Employee__c,cc);
      }   
      //update cc record according to below logic
      for (User user : users) {
        Corporate_Citizenship__c CorpCitizen = mapUserWithCC.get(user.Id);
        if(CorpCitizen != null) {
          if(user.Division !=null && user.Division.equalsIgnoreCase('Japan')) {
            CorpCitizen.Harassment_and_Descrim_TNG__c = 'N/A';
          }
          
          if(CorpCitizen.Manager__c != user.Manager__c){
            CorpCitizen.Manager__c = user.Manager__c;
          }
          if(CorpCitizen.Review_Manager__c != user.ReviewManager__c){
            CorpCitizen.Review_Manager__c = user.ReviewManager__c;
          }
          if(CorpCitizen.isActive__c != user.IsActive){
            CorpCitizen.isActive__c = user.IsActive;
          }
          if(CorpCitizen.Start_Date__c != user.Start_Date__c){
            CorpCitizen.Start_Date__c = user.Start_Date__c;
          }
          Corporate_Citizenship.add(CorpCitizen);
        }
      }
      if(Corporate_Citizenship.size() > 0)
        Database.update(Corporate_Citizenship);
    }
  }
}