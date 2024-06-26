public with sharing class BT_TaskListController {

    @AuraEnabled
    public static List<Tasks> getTasks(){
        String currentUsers = UserInfo.getUserId();
        List<Tasks> tasks = new List<Tasks>();
        Tasks task0 = new Tasks('Offer accepted!', 15, '/support');
        Tasks task1 = new Tasks('Select your equipment', 15, '/equipment');
        Tasks task2 = new Tasks('Submit documents for I-9 verification', 10, 'https://wwww.google.com');
        Tasks task3 = new Tasks('Book your travel for Discovering Salesforce', 30, 'https://wwww.google.com');
        Tasks task4 = new Tasks('Upload a badge photo', 10, 'https://wwww.google.com');
        tasks.add(task0);
        tasks.add(task1);
        tasks.add(task2);
        tasks.add(task3);
        tasks.add(task4);
        return tasks;
    }

    public class Tasks{
        @AuraEnabled public String taskDescription;
        @AuraEnabled public Integer estimatedTimeInMinutes;
        @AuraEnabled public String taskLink;
        public Tasks(String taskDescription, Integer estimatedTimeInMinutes, String taskLink) {
            this.taskDescription = taskDescription;
            this.estimatedTimeInMinutes = estimatedTimeInMinutes;
            this.taskLink = taskLink;
        }
    }
}