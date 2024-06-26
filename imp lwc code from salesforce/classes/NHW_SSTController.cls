@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class NHW_SSTController {

  public List<user> results{get{
    if(results == null){
      results = new List<User>();
    }
    return results;
  }
  set;} // search results
  public string searchString{get;set;} // search keyword
  public String managerID {get;set;}
  public String empNumber;
  public String email;
  public String targetSSTName {get;set;}
  public String targetSSTUserName {get;set;}
  public String selectedPfUserId{get;set;}
  public Id caseId {get;set;}
  public boolean isContractor {get;set;}
  public String targetObject {get;set;}
  private boolean fetchPFUsers = false;
  public boolean checkForMgmtHierchy{get;set;}

  public class SSTList{
    Id pfUserId;
    String userName;
    String email;
    String role; 
  }

  public NHW_SSTController() {

    searchString = (System.currentPageReference().getParameters().get('lksrch')!=null)? (System.currentPageReference().getParameters().get('lksrch')) : null;
    managerID = (System.currentPageReference().getParameters().get('managerId')!=null)?(System.currentPageReference().getParameters().get('managerId')) : null;
    isContractor = (System.currentPageReference().getParameters().get('isContractor')!=null)?(true) : false;
    caseId = (System.currentPageReference().getParameters().get('caseId')!=null)?(System.currentPageReference().getParameters().get('caseId')) : null;
    targetObject = (System.currentPageReference().getParameters().get('org')!=null)?(System.currentPageReference().getParameters().get('org')) : null;
    User usr;
    System.debug('**' + isContractor + '**tar' + targetObject);
    checkForMgmtHierchy = (!isContractor && targetObject == 'Org62')? true : false; 
    SYstem.debug('***checkM' + checkForMgmtHierchy);
    try{
      if(!isContractor && managerID!=null && caseId!=null){

        usr = [select Id,Name,EmployeeNumber,Email from user where contactId = : managerID limit 1];
        empNumber = usr.EmployeeNumber;
        email = usr.Email;
      }
    } catch (Exception e){
      //ToDo :: 
        //log into pf_Debuglog

    }

  }

  public PageReference updateCase(){
    List<Case> nhwCase;
    boolean isUpdate = false;
    System.debug(fetchPFUsers + '' + targetSSTName + ' ' + targetSSTUserName + ' '+ targetObject );
    if(!fetchPFUsers && caseId!=null && targetSSTUserName!=null && targetSSTName!=null){
      nhwCase = [select Id,NH_SST_User__c,NH_GUS_SST_User__c,NH_Supportforce_SST_User__c from case where Id = : caseId limit 1];
      if(nhwCase!=null && !nhwCase.isEmpty()){
        if( targetObject == 'Org62' && NHW_Util.getSSTUserName(nhwCase[0].NH_SST_User__c)!=targetSSTUserName){
          nhwCase[0].NH_SST_User__c = NHW_Util.formatSSTUserName(targetSSTUserName,targetSSTName);  
          isUpdate = true;
        } else if(targetObject == 'GUS' && NHW_Util.getSSTUserName(nhwCase[0].NH_GUS_SST_User__c)!=targetSSTUserName){
          nhwCase[0].NH_GUS_SST_User__c = NHW_Util.formatSSTUserName(targetSSTUserName,targetSSTName);  
          isUpdate = true;
          } else if(targetObject == 'Supportforce' && NHW_Util.getSSTUserName(nhwCase[0].NH_Supportforce_SST_User__c)!=targetSSTUserName){
            nhwCase[0].NH_Supportforce_SST_User__c = NHW_Util.formatSSTUserName(targetSSTUserName,targetSSTName);
            isUpdate = true;
          }

          System.debug('Is update>>' + isUpdate);
        if(isUpdate && Case.sObjectType.getDescribe().isUpdateable()){
          try {
            Database.update(nhwCase[0], false);
          }  catch (DmlException ex) { 
            system.debug('The following exception has occurred: ' + 
                        ex.getDmlStatusCode(0) + ex.getMessage());
          }
        }        
      }
    }
    return null;
  }

 


  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }

  // prepare the query and issue the search command
  private void runSearch() {
    results = performSearch(searchString);  

  } 

  // run the search and return the records found. 
  public List<user> performSearch(string searchString) {
    List<User> sstUsers = new List<User>();
    if(searchString!=null && searchString.startsWith('*') || searchString.endsWith('*')){
      searchString = searchString.remove('*');
    }
    //Org62 only :: for employee hire, we need empNumber of manager to identify management hierarchy. If not, show only pf users
    if(checkForMgmtHierchy && (empNumber == null || email == null) ){
      fetchPFUsers = true;
    }

    if(!fetchPFUsers){
      if(checkForMgmtHierchy){
        sstUsers = NHW_Org62Service.getSSTUsers(empNumber,email, String.isBlank(searchString) ? searchString : String.escapeSingleQuotes(searchString));
        if(sstUsers != null){
          return sstUsers;
        } else {
          fetchPFUsers = true;
        }
      } else { // for appplications which doesn't involve management hierarchy..  
        sstUsers = NHW_SSTCallOut.getSSTUsers(targetObject, String.isBlank(searchString) ? searchString : String.escapeSingleQuotes(searchString));
        if(sstUsers != null){
          return sstUsers; 
        } else {
          fetchPFUsers = true;
        }
      }
    }

    if(fetchPFUsers){

      String nameCondition = '%';

      if(searchString != '' && searchString != null){
        nameCondition = '%' + searchString + '%';
      }

      return [SELECT id, Email, name, username, employeenumber
        FROM user WHERE isactive = true AND profile.name != 'customer portal manager custom' AND name LIKE :nameCondition limit 50];
    }
    return null;
  }

  
  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }

  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }


}