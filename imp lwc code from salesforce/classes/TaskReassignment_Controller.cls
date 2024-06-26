/* We are using the standard controller which brings security model which will prevent users to modify owners of tast not owned by them.And this class access is not global and is controlled by permissions set(Task Reassign Owner)*/

public without sharing class TaskReassignment_Controller {
    
    public string strUserToSearch {get; set;}
    public List<User> lstUser{get; set;}
    public string strSelectedUserId {get; set;}
    public string strSelectedUserName {get; set;}
    public string strUserAvailability {get; set;}
    public Task tsk;
    public Id tskId;
    
    public TaskReassignment_Controller(ApexPages.StandardController controller) {
        this.tskId = controller.getId();
        this.tsk = (Task)controller.getRecord();
    }
    
    public pageReference UpdateOwner(){
        String errorMsgUserUpdate = System.Label.Task_Reassignment_User_Update;
        pageReference pageRef;
        
        if(strSelectedUserId == null || strSelectedUserId == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMsgUserUpdate);
            ApexPages.addMessage(myMsg);
            pageRef = null;
        }
        else{
            tsk.OwnerId = strSelectedUserId;
            update tsk;
            string strRtnURL = '/'+tskId;
            pageRef = new PageReference(strRtnURL );
            pageRef.setRedirect(false);
        }
        return pageRef;  
    }
    
    public PageReference Cancel(){
        PageReference  pgRef;
        string strRtnURL = '/'+tskId;
        pgRef= new PageReference(strRtnURL );
        pgRef.setRedirect(false);
        return pgRef;
    }
    
    public void SearchUsers(){
        String errorMsgUserName = System.Label.Task_Reassignment_String_Search;
        strUserAvailability = '';
        lstUser = new List<User>();
        strUserToSearch = strUserToSearch.trim();
        if(String.isNotEmpty(strUserToSearch) && strUserToSearch.length() > 2){
            string strQuery = 'select Id, name, email from User where Name like ' + '\'%' +strUserToSearch + '%\' limit 1000';
            lstUser = Database.Query(strQuery);
            
            if(lstUser == null || lstUser.size() == 0){
                strUserAvailability = System.Label.Task_Reassignment_No_User_Found;
            }
        }
        else if(String.isNotEmpty(strUserToSearch) && strUserToSearch.length() < 3){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMsgUserName);
            ApexPages.addMessage(myMsg);    
        }
        else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMsgUserName);
            ApexPages.addMessage(myMsg);
        }
    }
}