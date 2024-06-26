/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: Joaquin Arcardini  $
 * $Change:  $
 * $DateTime: 03/03/2010 $
 * $File: ExitInterviewWithSharing.cls $
 * $Id:  $
 * $Revision:  $
 */

/*
 * This class will manage query against Exit Interview object taking into account sharing rules.
 * @author Joaquin Arcardini
*/
public with sharing class ExitInterviewWithSharing 
{
	/**
	* Return all exit interviews order by created date
	* @Return List<ExitInterView__c>
	*/
	public static List<ExitInterview__c> getAllExitInterviews(Boolean orderByDate, Boolean orderByDateDesc, Boolean orderByName, Boolean orderByNameDesc, Boolean orderByManager, Boolean orderByTerminationDate, Boolean orderByManagerDesc, Boolean orderByTerminationDateDesc )
	{
		List<ExitInterview__c> exitInterviews;
		
		if (orderByName)
		{
			if (orderByNameDesc)
			{
				exitInterviews =  [Select Id, Employee__c, Employee__r.Name, Employee__r.FirstName, Employee__r.LastName, Employee__r.Manager__r.Name, Employee__r.Manager__r.FirstName,Employee__r.Manager__r.LastName, Status__c, CreatedDate, TerminationDate__c from ExitInterview__c order by Employee__r.LastName desc, Employee__r.FirstName desc,  createdDate desc limit 1000];
			}
			else
			{
				exitInterviews =  [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Employee__r.FirstName, Employee__r.LastName, Status__c, CreatedDate, Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName, TerminationDate__c from ExitInterview__c order by Employee__r.LastName asc, Employee__r.FirstName asc, createdDate asc limit 1000];
			}
		}
		
		if (orderByDate)
		{
			if (orderByDateDesc)
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.FirstName, Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c order by createdDate desc, Employee__r.LastName desc, Employee__r.FirstName desc limit 1000];		
			}	
			else
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.FirstName,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c order by createdDate asc, Employee__r.LastName asc, Employee__r.FirstName asc limit 1000];
			}
		}
		
		if (orderByManager)
		{
			if (orderByManagerDesc)
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.FirstName, Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c order by Employee__r.Manager__r.LastName desc, Employee__r.Manager__r.FirstName desc, createdDate desc limit 1000];		
			}	
			else
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.FirstName,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c order by Employee__r.Manager__r.LastName asc, Employee__r.Manager__r.FirstName asc, createdDate asc limit 1000];
			}	
		}
		
		if (orderByTerminationDate)
		{
			if (orderByTerminationDateDesc)
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.FirstName, Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c order by TerminationDate__c desc,  Employee__r.FirstName desc limit 1000];		
			}	
			else
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.FirstName,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c order by TerminationDate__c asc,  Employee__r.FirstName asc limit 1000];
			}	
		}
	
		return exitInterViews;
	}
}