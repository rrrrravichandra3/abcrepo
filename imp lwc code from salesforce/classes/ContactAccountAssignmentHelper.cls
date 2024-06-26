@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class ContactAccountAssignmentHelper {
    
    @TestVisible private static boolean createAccounts = false;
    @TestVisible private static String strExecute = 'Y';
    @TestVisible private static Integer intDivFactor = 0;
    
    static Contact_Account_Assignment__c settings = Contact_Account_Assignment__c.getOrgDefaults();
    
    public static set<Id> contactRecordTypesToProcess{
        get {
            if (contactRecordTypesToProcess == null ) {
                contactRecordTypesToProcess = new set<Id>();
                if(settings.Contact_Record_Types_to_Process__c!=null) {
                    List<String> recordTypeNames = settings.Contact_Record_Types_to_Process__c.split(',');
                    for(String recordTypeName :recordTypeNames){
                        contactRecordTypesToProcess.add(Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId());
                    }
                }
            } 
            return contactRecordTypesToProcess;
        } set;
    } 
    
    static Id idEmployeeAccountRecordType{
        get {
            if (idEmployeeAccountRecordType == null ) {
                idEmployeeAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(settings.Account_Record_Type__c).getRecordTypeId();
            } 
            return idEmployeeAccountRecordType;
        } set;
    } 
    
    public static String empIDFieldName{
        get {
            if (empIDFieldName == null ) {
                empIDFieldName = settings.Contact_Employee_Id_Field_Name__c;
            } 
            return empIDFieldName;
        } set;
    } 
    
    public static List<Contact> filterbyRecordType(List<Contact> cntList) {
        List<Contact> filteredList = new List<Contact>(); 
        //filter by record type
        for(Contact objContact : cntList) {
            if(contactRecordTypesToProcess.contains(objContact.recordtypeid)) {
                filteredList.add(objContact);
            }
        }
        return filteredList;
    }
    
    /*
*     @author         Ronak Bandwal
*     @date           18th August 2023
*     @description    This Method will assign Account to Contact. If Account does not already
*                     exist, it will create a new Account
*     @param          lstContacts: Contacts for which Account is to be assigned
*     @return         lstContacts with AccountId updated
*/
    public static List<Contact> assignAccountToContact(List<Contact> lstContacts) {
        try {
            if(strExecute == 'Y' && lstContacts.size() > 0) {
                
                String strEmpIdsToIgnore = '';
                
                //Placeholder assignment variables
                String strAccountPrefix = '';
                
                //Variable containing list of employee Ids to bypass
                Set<String> setEmpIdsToIgnore = new Set<String>();
                
                //Set of all the Account Names to which Contacts have to be assigned
                Set<String> setAccountsToQuery = new Set<String>();
                
                //Map of employee Id and corresponding Account Name
                Map<String, String> mapOfEmployeeIdAccountName = new Map<String, String>();
                
                //Map of Account name and its corresponding Id
                Map<String, String> mapOfAccountNameId = new Map<String, String>();
                
                //Determines whether we have to create Accounts if Account does not already exist
                if(!(Test.isRunningTest())) {
                    createAccounts = settings.Create_Accounts__c ;
                    //Integer to determine multiple to split Accounts based on
                    intDivFactor = Integer.valueOf(settings.Employee_Id_Split_Factor__c);
                }    
                strAccountPrefix = settings.Account_Prefix__c ;
                strEmpIdsToIgnore = settings.Ignore_Employee_Ids__c ;
                
                //Comma separated employee ids for which the logic is to be bypassed
                setEmpIdsToIgnore.addAll(strEmpIdsToIgnore.split(','));
                if(intDivFactor <= 0) {
                    return lstContacts;
                }
                
                //build Map to Emp Id to Account Name
                buildMapOfEmpIdToAccountName(lstContacts, setEmpIdsToIgnore, strAccountPrefix, mapOfEmployeeIdAccountName);
                
                if(!mapOfEmployeeIdAccountName.isEmpty()) {
                    //Query all Accounts identified by their name and build a map of the Account Name and its corresponding Id
                    setAccountsToQuery.addAll(mapOfEmployeeIdAccountName.values());
                    
                    //update set of accounts to query
                    updateAccountsToQuerySet(setAccountsToQuery, mapOfAccountNameId);
                    
                    //if setAccountsToQuery still has records, it would mean that these accounts would have to be created first 
                    if(!setAccountsToQuery.isEmpty() && createAccounts) {
                        mapOfAccountNameId = createAccounts(setAccountsToQuery, mapOfAccountNameId);    
                    }
                    
                    //Assign the relevant Account to the Contact
                    assignRelevantAccountToContact(lstContacts,mapOfEmployeeIdAccountName,mapOfAccountNameId);
                }
                
            }    
            
            
        }
        catch(Exception e) {
            System.debug('Error occurred in ContactAccountAssignmentHelper.assignAccountToContact: '+e.getMessage()+ ' StackTrace: '+e.getStackTraceString());
        }    
        
        return lstContacts;
    }
    
    private static void buildMapOfEmpIdToAccountName(List<Contact> lstContacts,Set<String> setEmpIdsToIgnore,String strAccountPrefix,Map<String, String> mapOfEmployeeIdAccountName) {
        for(Contact objContact : lstContacts) {
            if(String.isNotBlank((String)objContact.get(empIDFieldName) ) && !setEmpIdsToIgnore.contains((String)objContact.get(empIDFieldName))) {
                Integer intEmployeeId = Integer.valueOf(objContact.get(ContactAccountAssignmentHelper.empIDFieldName));
                //Range is determined as employeeId - employeeId%intDivFactor
                Integer intEmployeeIdRange = intEmployeeId - math.mod(intEmployeeId,intDivFactor);
                //We create a Map of the Contact's employee Id and what should be their assigned account
                mapOfEmployeeIdAccountName.put((String)objContact.get(empIDFieldName) , strAccountPrefix + ' ' +String.valueOf(intEmployeeIdRange));    
            }
        }
    }   
    
    private static void assignRelevantAccountToContact(List<Contact> lstContacts,Map<String, String> mapOfEmployeeIdAccountName,Map<String, String> mapOfAccountNameId) {
        if(!mapOfAccountNameId.isEmpty()) {
            for(Contact objContact : lstContacts) {
                String strAccountName = mapOfEmployeeIdAccountName.get((String)objContact.get(empIDFieldName) );
                if(mapOfAccountNameId.containsKey(strAccountName)) {
                    objContact.AccountId = mapOfAccountNameId.get(strAccountName);  
                }       
            }
        }
    }
    
    private static void updateAccountsToQuerySet(Set<String> setAccountsToQuery,Map<String, String> mapOfAccountNameId) {
        for(Account objAccount: [Select Id, Name from Account where Name IN :setAccountsToQuery WITH SECURITY_ENFORCED]) {
            mapOfAccountNameId.put(objAccount.Name, objAccount.Id);
            //If the account is found in the query results, remove it from the set indicating that Account already exists
            if(setAccountsToQuery.contains(objAccount.Name)) {
                setAccountsToQuery.remove(objAccount.Name);    
            }    
        }
    }
    
    /*
*     @author         Ronak Bandwal
*     @date           18th Aug 2023
*     @description    This Method will create Accounts based on Employee Id parameters
*     @param          setOfNewAccounts: Set of Account Names to be created
*     @param          mapOfAccountNameId: Map containing Account Name and its corresponding Id
*     @return         mapOfAccountNameId updated with Account Name and corresponding Id
*/
    public static Map<String, String> createAccounts(Set<String> setOfNewAccounts, Map<String, String> mapOfAccountNameId) {
        if (Schema.sObjectType.Contact.isCreateable()) {
            List<Account> lstNewAccounts = new List<Account>();
            for(String strName : setOfNewAccounts) {
                lstNewAccounts.add(new Account(Name = strName, RecordTypeId = idEmployeeAccountRecordType));
            }
            if(!lstNewAccounts.isEmpty()) {
                List<Database.SaveResult> lstResults = Database.insert(lstNewAccounts, false, AccessLevel.User_mode);
                for(Integer i=0;i<lstResults.size();i++){
                    if (lstResults.get(i).isSuccess()){
                        mapOfAccountNameId.put(lstNewAccounts[i].Name, lstResults.get(i).getId());
                    }
                }     
            }
        }
        return mapOfAccountNameId;
    }
}