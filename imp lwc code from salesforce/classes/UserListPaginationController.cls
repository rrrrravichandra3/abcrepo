public with sharing class UserListPaginationController {
	
	public List<String> userIDs {get; set;}
	public String IDs {get; set;}
	public String empNumbertoRemove{get;set;}
	public ListID__c usrIDs {get; set;} 
	public list<User> notIncludedUsers{get;set;}
    public List<User> AllSearchUsers
    {
        get
        {
            if(con != null)
                return (List<User>)con.getRecords();
            else
                return null ;
        }
        set;}
    
    public User usr {get; set;}
    
    //Controller
    public UserListPaginationController()
    {
    	Id uIDs = null;
    	if (Apexpages.currentPage().getParameters().get('uIDs') != null){
    		uIDs =	Apexpages.currentPage().getParameters().get('uIDs');    		
    	}
    	if(uIds!=null){
    		usrIDs = [Select Id, CollectionID__c From ListID__c Where Id =: uIDs];
    		IDs = usrIDs.CollectionID__c;
    	}
    	
    	userIDs = new List<String>();
    	AllSearchUsers = new List<User>() ;
        usr = new User() ; 
    	if (IDs != null){
    		
    		userIDs = IDs.split(';');
    		
    	}
    	if (userIDs.size() > 0){
    		this.Search();
    	}
        
    }
    
    
     public PageReference Search()
    {   
        if(userIDs.size() > 0)
        {
            con = new ApexPages.StandardSetController(Database.getQueryLocator([select Id , name , email , phone, Department, IsActive, EmployeeNumber from User where EmployeeNumber IN: userIDs and isActive=true]));
 			notIncludedUsers= [select id, name,email, phone, department,isActive, employeeNumber from User where employeeNumber in: userIDs and isActive=false];
            // sets the number of records in each page set
            con.setPageSize(15);
            
        }
        else
        {
            con = null;
        }
        
        return null ;
    }
    
    //Instantiate the StandardSetController
    public ApexPages.StandardSetController con{get; set;}
    
    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext
    {
        get
        {
            return con.getHasNext();
        }
        set;
    }
 
    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious
    {
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
 
    //Page number of the current displaying records
    public Integer pageNumber
    {
        get
        {
            return con.getPageNumber();
        }
        set;
    }

    //Returns the previous page of records
    public void previous()
    {
        con.previous();
    }
 
    //Returns the next page of records
    public void next()
    {
        con.next();
    }
    
    public PageReference cancel(){
    	return con.cancel(); 
    }

}