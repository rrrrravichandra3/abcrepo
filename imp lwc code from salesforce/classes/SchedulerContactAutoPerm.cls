global class SchedulerContactAutoPerm implements Schedulable{

	global void execute(SchedulableContext SC) {

        Database.executeBatch(new BatachableContactProfileAssignment(), 25);  
    }

}