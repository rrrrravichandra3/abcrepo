public with sharing class TaskHandler {
	
	
	public static void appendRecruiterNameToTask( List<Task> taskList ){
		
		Id scheduleInterviwer = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Schedule Interview').getRecordTypeId();
		Id other = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Other').getRecordTypeId();
		
		for(Task task:taskList){
			if ( (task.RecordTypeId == scheduleInterviwer || task.RecordTypeId == other)  
                                      && task.Subject.startsWith('Reschedule - {') == false) {
				task.Subject = 'Created By: ' + UserInfo.getName() + ' - ' + task.Subject;
			}	
		}		
		
	}
	
	/*
  	*
  	* 01-05-2017 Apuroop Gadde
  	*Append reschedule to the subject of task , if the task is a reschuduled task W-3601620
  	*
  	*/
  	public static void appendRescheduleToTaskSubject(List<Task> taskList){
  		for(Task task:taskList) {
    		if(task.Type == 'Rescheduled' && task.Subject.startsWith('Reschedule - {') == false) {
    	   		task.Subject = 'Reschedule - {'+ task.Subject + '}';
      	  	}
      	}
  	}

	
}