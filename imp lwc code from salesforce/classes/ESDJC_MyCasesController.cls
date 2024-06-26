/**
  #DreamJobCentral
* @date:        5/1/2013
* @description: Controller for ESDJC_CasesHomePage. Show all the cases for logged in user has access using StandardSetController.
**/
public with sharing class ESDJC_MyCasesController {
    public string url{get;set;}
    public string selectedView{get;set;}
    private user currentUser;
    private contact userContact;
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    
    public ESDJC_MyCasesController() {
        size = 20;
        //url=ESDJC_Util.getSSOURL();
        url =ESDJC_Util.getSiteURL();
        selectedView = 'open';
        List<User> users = [SELECT ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        if (!users.isEmpty()) {
            currentUser = users.get(0);
        }
        
        searchCases();
    }

    
    public ApexPages.StandardSetController setController
    {
        get
        {
            if(setController == null)
            {
                List<Case> contactList = new List<Case>();
                return new ApexPages.StandardSetController(contactList);
            }
            else
                return setController;
        }
        set;
    }
    
    /*
    *   create selectlist to select Open, Closed and All cases view.
    */
    public List<SelectOption> getViews() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('open',System.Label.ES_DJC_OpenCases));
        options.add(new SelectOption('closed',System.Label.ES_DJC_ClosedCases));
        options.add(new SelectOption('all',System.Label.ES_DJC_AllCases));
        
        return options;    
    }    
    
    
    public LIST<Case> getCases() {
    
        return null;
    }    
    
    /*
    *   Search cases according to selected view.
    */
    public void searchCases()
    {
        list<string> closedStaus = new list<string>{'Closed','Closed - Duplicate'};
        List<Case> caseList = new List<Case>();
        string queryString = 'select id,CaseNumber,ContactId,Subject,Status,Priority,LastModifiedDate, type from case where ContactId =  \'' +currentUser.ContactId + '\'  ';        
        
        if(selectedView == 'open'){
            queryString += 'and status != \'Closed\' and  status != \'Closed - Duplicate\'' ;
        
        }
        else if(selectedView == 'closed'){
            queryString += 'and ( status = \'Closed\'  or status = \'Closed - Duplicate\')' ;
        
        }
        
        queryString += ' and status != \'Not a Case\' order by CaseNumber DESC'; 
        
        caseList = Database.query(queryString);
        if(caseList.size()>0){
            renderTable = true;
            setController = new ApexPages.StandardSetController(caseList); 
            setController.setPageSize(size);
            
            noOfRecords = setController.getResultSize();
        }
        else{
            renderTable = false;
            setController = new ApexPages.StandardSetController(new list<case>()); 
            setController.setPageSize(size);
            noOfRecords = setController.getResultSize();
        }
    } 
    
    public List<Case> searchResults
    {
        get
        {
            return (List<Case>)setController.getRecords();
        }
        set;
    } 
    public void next()
    {
        setController.Next();
    }
   
    public void previous()
    {
        setController.Previous();
    }
    
    public void first() {
        setController.first();
    }
  
    public void last() {
        setController.last();
    }
    
    public Boolean getHasNext()
    {
        if(setController==null)
            return false;
        return setcontroller.getHasNext();
    }
 
    public Boolean getHasPrevious()
    {
        if(setController==null)
            return false;       
        return setcontroller.getHasPrevious();
    } 
    public Boolean renderTable
    {
        get
        {
            if(renderTable == null)
                return false;
            return renderTable;
        }
        set;
    } 
    public Integer pageNumber {
        get {
            return setcontroller.getPageNumber();
        }
        set;
    } 
}