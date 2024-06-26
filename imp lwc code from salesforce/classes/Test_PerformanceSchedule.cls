@isTest
private class Test_PerformanceSchedule {
	
	static User testUser;
	static Department__c testDepartment;
	
	public static testMethod void performanceScheduleTest(){
		Test.startTest();

		Integer second, minute, hour, day, month, year;
		
		Datetime dt = System.now();
		year = dt.year();
		month = dt.month();
		day = dt.day();
		if(day < 29){
			day = day + 1;
		}
		hour = dt.hour();
		minute = dt.minute();
		second = dt.second();
		
		String cron = '' + second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ' + '? ' + year;
		 
		//String jobId = System.schedule('testPerformanceSchedulerClass', PerformanceScheduler.CRON_EXP, new PerformanceScheduler());
		
		/*
		String jobId = System.schedule('testPerformanceSchedulerClass', cron , new PerformanceScheduler());
		
		CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		
		//Verify the expressions are the same  
		//System.assertEquals(PerformanceScheduler.CRON_EXP, ct.CronExpression);
		System.assertEquals(cron, ct.CronExpression);
		
		//Verify the job has not run  
		System.assertEquals(0, ct.TimesTriggered);
	
		//Verify the next time the job will run  
		//System.debug('<<<<<<<<<<<<<<<<<<<<<<<<NextFireTime: ' + ct.NextFireTime);
		//System.assertEquals('2011-05-06 00:40:00', String.valueOf(ct.NextFireTime));
		*/
		Test.stopTest();			
	}
	
	public static testMethod void testMassSendEmailNotification(){
		
		List<User> usrList = [Select u.Id, u.FirstName, u.LastName, 
						 	  u.username, u.Manager__c,
						 	  u.Years_And_Months_Working__c, u.Exclude_from_Emails__c, 
						 	  u.Manager__r.name, u.Manager__r.email, u.Manager__r.FirstName, 
						 	  u.Manager__r.LastName, u.Manager__r.Username, u.Manager__r.Exclude_from_Emails__c
						      From User u
						 	  Where u.IsActive = True AND u.Name=:'test employee'];
		
		if(usrList.size() > 0){
			Test.startTest();
			
				User u = usrList[0];
				u.Years_And_Months_Working__c = 'ten months';
				update u;
				 
				MassSendEmailNotificationBatchImpl batch = new MassSendEmailNotificationBatchImpl(usrList);
	   			Database.executeBatch(batch);
   			
   			Test.stopTest(); 
		}				 
		
	}
	
}