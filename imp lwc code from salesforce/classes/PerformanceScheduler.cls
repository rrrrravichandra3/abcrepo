global class PerformanceScheduler implements Schedulable {
    
    //Department__c department = new Department__c();
    List<User> users = new List<User>();
    
    //Needed for testing. Change the value with the current date and time before running the test.
    //0(seconds) 25(minutes) 18(hour) 10(day) (month) ? 2011(year) 
    public static String CRON_EXP = '0 10 16 24 02 ? 2012';
    
    global void execute(SchedulableContext sc){ 
        
        List<String> depts = new List<String>();
        
        /* OLD Department */                                                                           
        /*
        for (Department__c dept : [Select Id, Name From Department__c Where Name =: '450 - Sales Dev - SR' OR Name =: '454 - Sales Dev - FS EBR' OR Name=: '455 - Sales Dev - GB EBR' OR Name=: '456 - Sales Dev - MM EBR']){
            depts.add(dept.Name);
        }
        */
        
        for(TF2_Department__c dept : [Select Id, Name From TF2_Department__c Where Ten_Months_Notification__c =: true ]){
            depts.add(dept.Name);
        }
              
        //Select the users with this department.
        users = [ Select u.Id, u.FirstName, u.LastName, 
                         u.username, u.Manager__c, u.start_Date__c,
                         u.Department_Change__c, u.Years_And_Months_Working__c, u.Exclude_from_Emails__c, 
                         u.Manager__r.name, u.Manager__r.email, u.Manager__r.FirstName, u.Manager__r.LastName, u.Manager__r.Username, u.Manager__r.Exclude_from_Emails__c
                         From User u
                         Where u.IsActive = True AND u.Cost_Center__c IN : depts];
                         
                         //Where u.IsActive = True AND u.Department IN : depts];
                
        //If list is not empty
        if(users.size() > 0){
            List<User> usersToSendEmail = new List<User>();
            System.debug(users);
            //Check the difference between Department_Change which is the field that stores the date when the user enters on this department and today.
            //If difference is 10 months put in a list to send the notification.
            for(User u: users){
                if(u.Department_Change__c != null){
                    integer dateDiff = 0;
                    Date UserCreated = u.Department_Change__c;
                    dateDiff = UserCreated.daysBetween(System.today());
                    
                    Integer remainder = math.mod(dateDiff,365);
                    
                    if(remainder >= 300 && remainder <= 306) {
                        //Years between start date and today
                        Integer yy = dateDiff / 365;
                        
                        //Put a string into Years_and_Months_working field 
                        if(yy < 1){
                            u.Years_And_Months_Working__c = '10 months';
                        }else if(yy == 1){
                            u.Years_And_Months_Working__c = '' + yy + ' year and 10 months';
                        }else if( yy > 1){
                            u.Years_And_Months_Working__c = '' + yy + ' years and 10 months';
                        }
                        
                        usersToSendEmail.add(u);
                    }
                }
            }
            try{
                //If there are users to send an email, update the users with their years_and_months_working fields
                //and then call the batch class to send the notification.
                if(usersToSendEmail.size() > 0 ){
                    System.debug(usersToSendEmail);
                    update usersToSendEmail;
                    
                    MassSendEmailNotificationBatchImpl batch = new MassSendEmailNotificationBatchImpl(usersToSendEmail);
                    Database.executeBatch(batch);
                }else{
                    System.debug('There are no users with 10 months in their departments to send a notification.');
                }
                
            }catch(Exception e){
                System.debug(e.getMessage());
            }
            
        } 
    }
}