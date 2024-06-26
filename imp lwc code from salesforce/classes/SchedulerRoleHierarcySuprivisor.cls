global class SchedulerRoleHierarcySuprivisor implements Schedulable{
	

	/*
	*execute method of a Scheduler. 
	*This method executes the BatchRoleHierarcySupervisor batch job. 
	*/
	global void execute(SchedulableContext SC) {

        Database.executeBatch(new BatchRoleHierarcySupervisor(), 150);  
    }
}