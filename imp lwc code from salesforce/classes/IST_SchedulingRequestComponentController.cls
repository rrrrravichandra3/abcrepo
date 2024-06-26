public with sharing class IST_SchedulingRequestComponentController {

	@AuraEnabled
	public static IST_SchedulingToolConfigurations loadSchedulingConfigurations() {
		IST_SchedulingToolConfigurations configurations = new IST_SchedulingToolConfigurations(); 

		IST_Scheduling_Tool_Settings_Metadata__mdt settingsMetadata = [select Enable_Scheduling_Tool__c, Task_Record_Type__c
        															   from IST_Scheduling_Tool_Settings_Metadata__mdt
        															   where DeveloperName = 'IST_Scheduling_Tool' limit 1];
   
     
     	configurations.toolIsEnabled = settingsMetadata.Enable_Scheduling_Tool__c;
     	configurations.userIsEnabled = IST_Scheduling_Tool_Hierarchy_Settings__c.getInstance().Enable_Scheduling_Tool__c;
		return configurations;
	}

	@AuraEnabled
	public static Task loadExistingSchedulingTask(Id taskId) {
		Task taskToReturn; 

		if (taskId != null) {
			List<Task> tasks = [select Id, WhatId, Status, IST_Interview_Scheduling_Request__c,
								IST_Interview_Scheduling_Request__r.Comments__c,
								IST_Interview_Scheduling_Request__r.Flight__c,
								IST_Interview_Scheduling_Request__r.Flight_From__c,
								IST_Interview_Scheduling_Request__r.Flight_To__c,
								IST_Interview_Scheduling_Request__r.Hotel__c,
								IST_Interview_Scheduling_Request__r.Interview_Type__c 
								from Task where Id = :taskId];
			if (tasks.size() > 0) {
				taskToReturn = tasks[0];
			}
		} else {
			throw new AuraHandledException('You must provide the Task Id');
		}
		return taskToReturn;
	}


	@AuraEnabled
	public static Task loadNewSchedulingTask(Id relatedToId) {
		Task taskToReturn; 

		if (relatedToId != null) {
			IST_Interview_Scheduling_Request__c schedulingRequest = new IST_Interview_Scheduling_Request__c(Flight__c = false);
			taskToReturn = new Task(WhatId = relatedToId, Status = 'Not Started', IST_Interview_Scheduling_Request__r = schedulingRequest);
		} else {
			throw new AuraHandledException('You must provide the Related To Id');
		}
		return taskToReturn;
	}


	@AuraEnabled
	public static Task saveSchedulingTask(Task schedulingTaskToSave) {
		upsert schedulingTaskToSave.IST_Interview_Scheduling_Request__r;
		schedulingTaskToSave.IST_Interview_Scheduling_Request__c = schedulingTaskToSave.IST_Interview_Scheduling_Request__r.Id;
		schedulingTaskToSave.Subject = 'Scheduling Tool';
        schedulingTaskToSave.Description = 'This task was creating using the Scheduling Tool';
        schedulingTaskToSave.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Scheduling Tool').getRecordTypeId();
        schedulingTaskToSave.ActivityDate = Date.today().addDays(2);
		upsert schedulingTaskToSave;
		return schedulingTaskToSave;
	}

	@AuraEnabled
	public static IST_TalentforceInfo loadTalentforceInfoFromTask(Id taskId){
		IST_TalentforceInfo talentforceInfo = new IST_TalentforceInfo(taskId, 'Task');
		return talentforceInfo;

	}

	@AuraEnabled
	public static IST_TalentforceInfo loadTalentforceInfoFromRelated(Id relatedToId){
		IST_TalentforceInfo talentforceInfo = new IST_TalentforceInfo(relatedToId, 'Interview');
		return talentforceInfo;
		
	}

	@AuraEnabled
	public static String getIntvTypePicklistValues(){
		String picklistOptions = '';
		List<Schema.PicklistEntry> ple = IST_Interview_Scheduling_Request__c.Interview_Type__c.getDescribe().getPicklistValues();
		for( Schema.PicklistEntry f : ple){
			picklistOptions = picklistOptions + f.getValue() +',';
		}
		if (picklistOptions != null && picklistOptions.length() > 0) {
		  picklistOptions = picklistOptions.substring(0, picklistOptions.length()-1);
		}
		return picklistOptions;
	}




}