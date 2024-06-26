public class IST_SchedulingToolTaskViewOverrideCtrl {
	private Task task;

    public IST_SchedulingToolTaskViewOverrideCtrl(ApexPages.StandardController stdController) {
    	this.task = (Task)stdController.getRecord();
    }
    
    public pageReference pageRedirect(){       
        PageReference pageToRedirectTo;

        IST_Scheduling_Tool_Settings_Metadata__mdt settingsMetadata = [select Enable_Scheduling_Tool__c, Task_Record_Type__c
        															   from IST_Scheduling_Tool_Settings_Metadata__mdt
        															   where DeveloperName = 'IST_Scheduling_Tool' limit 1];

        if (settingsMetadata.Enable_Scheduling_Tool__c == true && 
        	IST_Scheduling_Tool_Hierarchy_Settings__c.getInstance().Enable_Scheduling_Tool__c  == true &&
        	this.task.RecordType.DeveloperName ==  settingsMetadata.Task_Record_Type__c) {

        	pageToRedirectTo = Page.IST_InterviewSchedulingRequest;
        	pageToRedirectTo.getParameters().put('tId', task.Id);
        } else {
        	pageToRedirectTo = new PageReference('/'+ task.Id); 
        	pageToRedirectTo.getParameters().put('nooverride', '1');
        }

        return pageToRedirectTo;
    }
}