global class RescheduleController {
	

    webservice static Task cloneReschedule(Id taskId) 
    { 
		Task taskParent = [select Id, Description, Job_Req_Title__c, RecordTypeId, Status, Subject, Type, WhatId, WhoId, Primary_Recruiter__c from Task where Id =: taskId ];
		Task taskToClone = taskParent.clone();
		taskToClone.Type = 'Rescheduled';
		taskToClone.ActivityDate = Date.today();
		if ( taskParent.Status == 'Completed' )
			taskToClone.Status = 'Not Started';

        if(taskToClone.Subject.startsWith('Reschedule - {') == false) { 
            taskToClone.Subject = taskToClone.Subject.split('-')[1]; 
        }		

        insert taskToClone; 
		
		Task taskToReturn = [ select id, WhatId from Task where Id =: taskToClone.Id ];
		
		return 	taskToReturn;
    }

    /*
    * Action method to delete rescheduled task when the user hits the cancel
    * button.
    */

    public PageReference deleteRescheduleTask()
    {
        String returnUrl;
        try 
        {
            Id rescheduleTaskId = ApexPages.currentPage().getParameters().get('taskId');
            Task clonedTask = [select Id, OwnerId, WhatId from Task where Id =: rescheduleTaskId ];
            if(UserInfo.getUserId() == clonedTask.OwnerId) {
                DELETE clonedTask;
            }
            returnUrl = '/'+ clonedTask.WhatId;
        }
        catch(Exception e) {
            returnUrl = '/home/home.jsp' ;
        }
        return new PageReference(returnUrl);
    } 

}