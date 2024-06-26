/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: Joaquin Arcardini  $
 * $Change:  $
 * $DateTime: 05/10/2009 $
 * $File: ExitInterviewController.cls $
 * $Id:  $
 * $Revision:  $
 */

/*
 * This class will send and exit interview to an employee.
 * @author Joaquin Arcardini
*/
public with sharing class  SendExitInterviewController 
{
	private User employeeToSend;
	private ExitInterview__c exitInterview = new ExitInterview__c();
	public User currentUser{get;set;}
	private Boolean orderByName = true;
	private Boolean orderByNameDesc = false;
	private Boolean orderByDate = false;
	private Boolean orderByDateDesc = false;
	private Boolean orderByManager = false;
	private Boolean orderByManagerDesc = false;
	private Boolean orderByTerminationDate = false;
	private Boolean orderByTerminationDateDesc = false;
	private Boolean employeeAllReadyHaveOne = false;
	private Boolean errorDate = false;
	private List<ExitInterViewCustom> exitInterViewCustom = new List<ExitInterViewCustom>();
	
	//constructor
	public SendExitInterviewController()
	{
		currentUser = [select Id, Title, Profile.Name, LocaleSidKey, LanguageLocaleKey from User where Id =: userInfo.getUserId()];
	}
	
	public ExitInterview__c getExitInterview()
	{
		return exitInterview;
	}
	
	public void setExitInterview(ExitInterview__c value)
	{
		exitInterview = value;
	}
	
	public Boolean getEmployeeAllReadyHaveOne()
	{
		return employeeAllReadyHaveOne;
	}
	
	public Boolean getErrorDate()
	{
		return errorDate;
	}
	
	public List<ExitInterViewCustom> getExitInterViewCustom()
	{
		return exitInterViewCustom;
	}
	
	/**
	* Send an exit interview to the selected employee
    */
	public void sendExitInterView()
	{	
		if(!Schema.sObjectType.ExitInterview__c.isCreateable()){
			ApexPages.addmessage(
			new ApexPages.message(ApexPages.severity.ERROR,'Action aborted due to security violation.'));
		}
		
		employeeAllReadyHaveOne = false;
		User employee = [Select Id, Name, Profile.Name From User Where id =: exitInterview.Employee__c];
		Task newTask = new Task();
		
		if (! getEmployeeAlreadyHaveOne())
		{
			if (checkTerminationDate())
			{
				
				exitInterview.OwnerId = exitInterview.Employee__c;
				exitInterview.Status__c = 'Not Completed';
				exitInterview.Name = employee.Name + ' Exit Interview';
				newTask.Status = 'Not Started';
				newTask.OwnerId = exitInterview.Employee__c;
				newTask.Subject = employee.Name + ' Exit Interview';
				newTask.Description = employee.Name + ' Exit Interview';
			
				insert exitInterview;
				
				newTask.CallDisposition = exitInterview.Id;
				
				exitInterview = new ExitInterview__c();
			}
		}
	}
	
	/**
	* Return all exit interviews order by created date, name or manager
	* @Return List<ExitInterView__c>
	*/
	public List<ExitInterViewCustom> getAllExitInterviews()
	{
		List<ExitInterview__c> exitInterviews;
		
		//if is Employee Representative or 
		if (getIsEmployeeSuccessBusinessPartnerEsAdmin())
		{
			exitInterviews = ExitInterviewWithSharing.getAllExitInterviews(orderByDate, orderByDateDesc, orderByName, orderByNameDesc, orderByManager, orderByTerminationDate, orderByManagerDesc, orderByTerminationDateDesc);
		}
		else
		{
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
		}
		
		exitInterViewCustom = new List<ExitInterViewCustom>();
		
		for (ExitInterview__c ei : exitInterviews )
		{
			ExitInterViewCustom exitInterview = new ExitInterViewCustom(ei);
			exitInterViewCustom.add(exitInterview);
		}
		
		return exitInterViewCustom;
	}
	
	/**
	* Set the order by manager variable to order the exit interview list
	*/
	public void orderByManager()
	{
		exitInterViewCustom = new List<ExitInterViewCustom>();
			
		orderByManager = true; 
		orderByDate = false;
		orderByName = false;
		orderByTerminationDate = false;
		orderByManagerDesc = !orderByManagerDesc;	
	}
	
	/**
	* Set the orderByName variable to order the exit interview list
	*/
	public void orderByName()
	{
		exitInterViewCustom = new List<ExitInterViewCustom>();
			
		orderByDate = false;
		orderByName = true;
		orderByManager = false;
		orderByTerminationDate = false;
		orderByNameDesc = !orderByNameDesc;	
	}
	
	/**
	* Set the orderByDate variable to order the exit interview list
	*/
	public void orderByDate()
	{
		exitInterViewCustom = new List<ExitInterViewCustom>();
		
		orderByDate = true;
		orderByManager = false;
		orderByName = false;
		orderByTerminationDate = false;
		orderByDateDesc = !orderByDateDesc;	
	}
	
	/**
	* Set the orderByTerminationDate variable to order the exit interview list
	*/
	public void orderByTerminationDate()
	{
		exitInterViewCustom = new List<ExitInterViewCustom>();
		
		orderByTerminationDate = true;
		
		orderByDate = false;
		orderByManager = false;
		orderByName = false;
		orderByTerminationDateDesc = !orderByTerminationDateDesc;	
	}
	
	/**
	* Return all exit interview of the logged employee
	* @Return List<ExitInterView__c>
	*/
	public List<ExitInterviewCustom> getAllEmployeeExitIntervies()
	{
		List<ExitInterview__c> exitInterviews;
		
		if (orderByName)
		{
			if (orderByNameDesc)
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.FirstName,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.LastName, Employee__r.Manager__r.Name, Status__c, CreatedDate, TerminationDate__c from ExitInterview__c where Employee__c =: userInfo.getUserId() order by Employee__r.LastName desc, Employee__r.FirstName desc, createdDate desc];
			}
			else
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.FirstName, Employee__r.LastName, Status__c, CreatedDate, TerminationDate__c from ExitInterview__c where Employee__c =: userInfo.getUserId() order by Employee__r.LastName asc, Employee__r.FirstName asc, createdDate asc];
			}		
		}
		
		if (orderByDate)
		{
			if (orderByDateDesc)
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Status__c, CreatedDate, TerminationDate__c from ExitInterview__c where Employee__c =: userInfo.getUserId() order by createdDate desc, Employee__r.LastName desc, Employee__r.FirstName  desc];
			}
			else
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Status__c, CreatedDate, TerminationDate__c from ExitInterview__c where Employee__c =: userInfo.getUserId() order by createdDate asc, Employee__r.LastName asc, Employee__r.FirstName  asc];				
			}
		}
		
		if (orderByManager)
		{
			if (orderByManagerDesc)
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.FirstName, Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c where Employee__c =: userInfo.getUserId()  order by Employee__r.Manager__r.LastName desc, Employee__r.Manager__r.FirstName desc, createdDate desc];		
			}	
			else
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.FirstName,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c where Employee__c =: userInfo.getUserId()  order by Employee__r.Manager__r.LastName asc, Employee__r.Manager__r.FirstName asc, createdDate asc];
			}	
		}
		
		if (orderByTerminationDate)
		{
			if (orderByTerminationDateDesc)
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.FirstName, Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c where Employee__c =: userInfo.getUserId()  order by TerminationDate__c desc,  Employee__r.FirstName desc];		
			}	
			else
			{
				exitInterviews = [Select Id, Employee__c, Employee__r.Name, Employee__r.Manager__r.Name, Status__c, Employee__r.FirstName,  Employee__r.Manager__r.LastName, Employee__r.Manager__r.FirstName , Employee__r.LastName, CreatedDate, TerminationDate__c from ExitInterview__c where Employee__c =: userInfo.getUserId()  order by TerminationDate__c asc,  Employee__r.FirstName asc];
			}	
		}
		
		for (ExitInterview__c ei : exitInterviews )
		{
			ExitInterViewCustom exitInterview = new ExitInterViewCustom(ei);
			exitInterViewCustom.add(exitInterview);
		}
		
		return exitInterViewCustom;
	}
	
	
	/**
	* Return  true if the employee already have one for the day
	* @Return Boolean
	*/
	public Boolean getEmployeeAlreadyHaveOne()
	{
		List<ExitInterview__c> exitInterviewList = [select id, createdDate from ExitInterview__c where Employee__c =: exitInterview.Employee__c ];
		DateTime exitInterViewDate;
		DateTime exitInterViewCompare = System.now();
		
		for (ExitInterview__c eI : exitInterviewList)
		{
			exitInterViewDate = eI.createdDate;
			
			if (exitInterViewDate.Year() == exitInterViewCompare.Year() && exitInterViewDate.Month() == exitInterViewCompare.Month() && exitInterViewDate.Day() == exitInterViewCompare.Day()  )
			{
				employeeAllReadyHaveOne = true;
				return true;	
			}
			
		}
		
		employeeAllReadyHaveOne = false;
		return false;
	}
	
	/**
	* Return  true if the current user is the ESR
	* @Return Boolean
	*/
	public Boolean getIsESR()
	{
		if (currentUser.Profile.Name == Label.System_Administrator_Label ||currentUser.Profile.Name=='systemadministrator') return true;
		//There is no-one with this title. Hence Commenting out ES Representative (ESR)
		//if (currentUser.Title == 'ES Representative (ESR)') return true;
		if (currentUser.Profile.Name == 'ES Admin') return true;
		if (currentUser.Profile.Name == 'Employee Success/Business Partner') return true;
		if (currentUser.Profile.Name == 'ESR') return true;
		if (currentUser.Profile.Name == 'Employee Success Representative') return true;
		return false;
		
	}
	
	/**
	* Return  true if the current user is Employee Success/Business Partner or Es Admin profile
	* @Return Boolean
	*/
	public Boolean getIsEmployeeSuccessBusinessPartnerEsAdmin()
	{
		if (currentUser.Profile.Name == 'Employee Success/Business Partner' || currentUser.Profile.Name == 'ES Admin')
		{
			return true;
		}
		
		return false;	 
	}
	
	/**
	* Return  true if the current user has sys admin profile
	* @Return Boolean
	*/
	public Boolean getIsSysAdmin()
	{
		return (currentUser.Profile.Name == 'System Administrator' ||currentUser.Profile.Name=='systemadministrator');
	}
	
	/**
	* Delete exit interview and return to the current page
	* @Return PageReference the current page
	*/
	public PageReference DeleteExitInterview()
	{
		Id id = System.currentPageReference().getParameters().get('idExitInterview');
		ExitInterview__c exitInterView = [select Id from ExitInterView__c where id =: id];
		
		if(Schema.sObjectType.ExitInterview__c.isDeletable()){
			delete exitInterView;
		}
		
		PageReference retPage = Page.SendExitInterview;
		retPage.setRedirect(true);

		return retPage;
	}
	
	/**
	* Check if the termination date is grater than the hire date
	* @Return Boolean
	*/
	public Boolean checkTerminationDate()
	{
		User employee = [select id, Start_Date__c from User where id =: exitInterview.Employee__c];
		
		if ( exitInterview.TerminationDate__c < employee.Start_Date__c)
		{
			errorDate = true;
			return false;
		}
		
		errorDate = false;
		
		return true;
	}
	
	public class ExitInterViewCustom
	{
		private ExitInterview__c exitInterview;
		private String getDate;
		private String getTerminationDate;
		  
		public ExitInterViewCustom(ExitInterview__c ei)
		{
			exitInterview = ei;
		}	
		
		public ExitInterview__c getExitInterviewCustom()
		{
			return exitInterview;
		}
		
		public void setExitInterview(ExitInterview__c value)
		{
			exitInterview = value;
		}
		
		public String getDate()
		{
			return exitInterview.CreatedDate.format();
		}
		
		public string getTerminationDate()
		{
			if (exitInterview.TerminationDate__c == null) return '';
			return exitInterview.TerminationDate__c.format();
		}
		
		public boolean getIsTerminationDateNull(){
			
			return exitInterview.TerminationDate__c == null;
		}
		
		public boolean getIsManagerFirstNameNull(){
			return exitInterview.Employee__r.Manager__r.FirstName == '';
		}
		
		public boolean getIsManagerLastNameNull(){
			return exitInterview.Employee__r.Manager__r.LastName == '';
		}
	}
	
}