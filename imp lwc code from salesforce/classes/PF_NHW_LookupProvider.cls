@SuppressWarnings(
    'PMD.CognitiveComplexity'
)
public with sharing class PF_NHW_LookupProvider implements PF_LookupAuraProvider{
    
    public List<PF_AuraLookupOption> getOptions(PF_LookupId lookupId, String searchText, Map<String,String> additionalInformation){

        if(lookupId == PF_LookupId.NHW_BUSINESS_SITE){
            return getBusinessSiteOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_COST_CENTER){
            return getCostCenterOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_HIRING_MANAGER){
            return getHiringManagerOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_HIRING_MANAGER_JOB_APP){
            return getHiringManagerJobAppOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_PCC){
            return getPCCOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_PCC_JOB_APP){
            return getPCCOptionsJobApp(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_DEPARTMENT){
            return getCostCenterOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_BUSINESS_UNIT){
            return getBusinessUnitOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_COMPANY){
            return getCompanyOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_TRAIL_GUIDE){
            return getTrailGuideOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_Recruiter){
            return getHiringManagerJobAppOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_ORG62_USER_TO_CLONE){
            return getOrg62UserToCloneOptions(searchText, additionalInformation);
        }
        else if(lookupId == PF_LookupId.NHW_GUS_USER_TO_CLONE){
            return getGUSUserToCloneOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_SUPPORTFORCE_USER_TO_CLONE){
            return getSupporForceUserToCloneOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_GENERIC_USER_TO_CLONE){
            return getGenericUserToCloneOptions(searchText);
        }
        else if(lookupId == PF_LookupId.NHW_CASE_TO_CLONE){
            return getPastCaseToCloneOptions(searchText,additionalInformation);
        }
        return null;
    }
    
    public PF_AuraLookupOption getOption(PF_LookupId lookupId, String optionId, Map<String,String> additionalInformation){
        
        if(lookupId == PF_LookupId.NHW_BUSINESS_SITE){
            return getBusinessSiteName(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_COST_CENTER){
            return getCostCenterName(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_HIRING_MANAGER){
            return getHiringManagerName(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_HIRING_MANAGER_JOB_APP){
            return getHiringManagerJobAppName(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_PCC){
            return getPCCName(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_PCC_JOB_APP){
            return getPCCNameJobApp(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_DEPARTMENT){
            return getDepartmentName(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_BUSINESS_UNIT){
            return getBusinessUnitName(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_COMPANY){
            return getCompanyName(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_TRAIL_GUIDE){
            return getTrailGuideName(optionId);
        }
        
        else if(lookupId == PF_LookupId.NHW_ORG62_USER_TO_CLONE){
            return getOrg62UserToCloneOption(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_GUS_USER_TO_CLONE){
            return getOrg62UserToCloneOption(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_SUPPORTFORCE_USER_TO_CLONE){
            return getOrg62UserToCloneOption(optionId);
        }
        else if(lookupId == PF_LookupId.NHW_GENERIC_USER_TO_CLONE){
            return getGenericUserToCloneOption(optionId);
        }else if(lookupId == PF_LookupId.NHW_CASE_TO_CLONE){
            return getPastCaseHireName(optionId);
        }
        return null;
    }
    
    private List<PF_AuraLookupOption> getBusinessSiteOptions(String searchText){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(TF2_Business_Site__c bs:[SELECT Id, Name FROM TF2_Business_Site__c WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND Active__c = true ORDER BY Name]){
            result.add(new PF_AuraLookupOption(bs.Id, bs.Name));
        }
        
        return result;
    }
    
    private PF_AuraLookupOption getBusinessSiteName(String idObject){
        List<TF2_Business_Site__c> bss = [SELECT Id, Name FROM TF2_Business_Site__c WHERE Id = :idObject];
        if(!bss.isEmpty()){
            return new PF_AuraLookupOption(bss[0].Id, bss[0].Name);
        }
        return null;
    }
    
    private List<PF_AuraLookupOption> getCostCenterOptions(String searchText){
        
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(TF2_Department__c  cc:[SELECT Id, Name FROM TF2_Department__c WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND Active__c = true ORDER BY Name]){
            result.add(new PF_AuraLookupOption(cc.Id, cc.Name));
        }
        
        return result;
    }
    
    private PF_AuraLookupOption getCostCenterName(String idObject){
        List<TF2_Department__c> ccs = [SELECT Id, Name FROM TF2_Department__c WHERE Id = :idObject];
        if(!ccs.isEmpty()){
            return new PF_AuraLookupOption(ccs[0].Id, ccs[0].Name);
        }
        return null;
    }
    
    /*
* This method is used by NHW to select a contractor or relocation case Hiring Manager.
* In Case, hiring manager is a lookup field to Contact.
* 
* For Job Application, see getHiringManagerJobAppOptions method.  That method queries the
* information from User, since in Job Application the Hiring Manager field is a 
* lookup to User
*/
    private List<PF_AuraLookupOption> getHiringManagerOptions(String searchText){
        
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        for(Contact c:[SELECT Id, Name, Email FROM Contact WHERE Name LIKE :getSearchTextFilterStatement(searchText)
                       AND 
                       (RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee').getRecordTypeId()
                        OR RecordTypeId = :Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contractor').getRecordTypeId())                    
                       ORDER BY Name LIMIT 50]){
                           PF_AuraLookupOption option = new PF_AuraLookupOption(c.Id, c.Name);
                           option.additionalInformation.add(c.Email);
                           result.add(option);
                       }        
        return result;
    }
    
    private PF_AuraLookupOption getHiringManagerName(String idObject){
        List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE Id = :idObject];
        if(!contacts.isEmpty()){
            PF_AuraLookupOption option = new PF_AuraLookupOption(contacts[0].Id, contacts[0].Name);
            option.additionalInformation.add(contacts[0].Email);
            return option;
        }
        return null;
    }
    
    private List<PF_AuraLookupOption> getHiringManagerJobAppOptions(String searchText){
        
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(User u:[SELECT Id, Name, Email FROM User WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND IsActive = true AND IsPortalEnabled = false AND Is_Employee__c = true ORDER BY Name LIMIT 50]){
            PF_AuraLookupOption option = new PF_AuraLookupOption(u.Id, u.Name);
            option.additionalInformation.add(u.Email);
            result.add(option);
        }        
        return result;
    }

    private PF_AuraLookupOption getHiringManagerJobAppName(String idObject){
        List<User> users = [SELECT Id, Name, Email FROM User WHERE Id = :idObject];
        if(!users.isEmpty()){
            PF_AuraLookupOption option = new PF_AuraLookupOption(users[0].Id, users[0].Name);
            option.additionalInformation.add(users[0].Email);
            return option;
        }
        return null;
    }
    
    private static List<PF_AuraLookupOption> getPCCOptions(String searchText){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(TF2_PCC__c pcc:[SELECT Id, Name FROM TF2_PCC__c WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND Active__c = true ORDER BY Name]){
            result.add(new PF_AuraLookupOption(pcc.Name, pcc.Name));
        }
        
        return result;
    }
    
    private PF_AuraLookupOption getPCCName(String idObject){
        List<TF2_PCC__c> pccs = [SELECT Id, Name FROM TF2_PCC__c WHERE Name = :idObject];
        if(!pccs.isEmpty()){
            return new PF_AuraLookupOption(pccs[0].Name, pccs[0].Name);
        }
        return null;
    }
    
    private List<PF_AuraLookupOption> getPCCOptionsJobApp(String searchText){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(TF2_PCC__c pcc:[SELECT Id, Name FROM TF2_PCC__c WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND Active__c = true ORDER BY Name]){
            result.add(new PF_AuraLookupOption(pcc.Id, pcc.Name));
        }
        
        return result;
    }
    
    private PF_AuraLookupOption getPCCNameJobApp(String idObject){
        List<TF2_PCC__c> pccs = [SELECT Id, Name FROM TF2_PCC__c WHERE Id = :idObject];
        if(!pccs.isEmpty()){
            return new PF_AuraLookupOption(pccs[0].Id, pccs[0].Name);
        }
        return null;
    }
    
    private PF_AuraLookupOption getDepartmentName(String idObject){
        List<TF2_Department__c> departments = [SELECT Id, Name FROM TF2_Department__c WHERE Id = :idObject];
        if(!departments.isEmpty()){
            return new PF_AuraLookupOption(departments[0].Id, departments[0].Name);
        }
        return null;
    }
    
    private List<PF_AuraLookupOption> getBusinessUnitOptions(String searchText){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(Business_Unit__c bu:[SELECT Id, Name FROM Business_Unit__c WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND Active__c = true ORDER BY Name]){
            result.add(new PF_AuraLookupOption(bu.Id, bu.Name));
        }
        
        return result;
    }
    
    private static PF_AuraLookupOption getBusinessUnitName(String idObject){
        List<Business_Unit__c> bus = [SELECT Id, Name FROM Business_Unit__c WHERE Id = :idObject];
        if(!bus.isEmpty()){
            return new PF_AuraLookupOption(bus[0].Id, bus[0].Name);
        }
        return null;
    }
    
    private List<PF_AuraLookupOption> getCompanyOptions(String searchText){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(TF2_Company__c company:[SELECT Id, Name FROM TF2_Company__c WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND Active__c = true ORDER BY Name]){
            result.add(new PF_AuraLookupOption(company.Id, company.Name));
        }
        
        return result;
    }
    
    private PF_AuraLookupOption getCompanyName(String idObject){
        List<TF2_Company__c> companies = [SELECT Id, Name FROM TF2_Company__c WHERE Id = :idObject];
        if(!companies.isEmpty()){
            return new PF_AuraLookupOption(companies[0].Id, companies[0].Name);
        }
        return null;
    }
    
    private List<PF_AuraLookupOption> getTrailGuideOptions(String searchText){
        
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(Contact c : [SELECT Id, Name, Title FROM Contact WHERE Name LIKE :getSearchTextFilterStatement(searchText) AND RecordTypeId = :NHW_Util.getEmployeeContactRecordTypeId() ORDER BY Name LIMIT 50]){
            PF_AuraLookupOption option = new PF_AuraLookupOption(c.Id, c.Name);
            option.additionalInformation.add(c.Title);
            result.add(option);
        }
        
        return result;
    }
    
    private PF_AuraLookupOption getTrailGuideName(String idObject){
        Contact c = [SELECT Id, Name, Title FROM Contact WHERE Id = :idObject];
        if(c != null){
            PF_AuraLookupOption option = new PF_AuraLookupOption(c.Id, c.Name);
            option.additionalInformation.add(c.Title);
            return option;
        }
        return null;
    }
    static final String EMAIL_CONST = '; email:';
    private List<PF_AuraLookupOption> getOrg62UserWithMgmtHierarchyToCloneOptions(String searchText, Map<String,String> additionalInformation){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        String empNumber = null;
        String email = null;

        for(User managerUser : [select Id, Name, EmployeeNumber, Email FROM user WHERE contactId = : additionalInformation.get('MANAGER_ID') LIMIT 1]){
            empNumber = managerUser.EmployeeNumber;
            email = managerUser.Email;
        }

        if(empNumber != null && email != null){
            
            List<User> users = NHW_Org62Service.getSSTUsers(empNumber, email, String.isBlank(searchText) ? searchText : String.escapeSingleQuotes(searchText.replaceAll('\\*', '')));
            
            if(users != null){
                for(User u:users){
                    PF_AuraLookupOption option = new PF_AuraLookupOption(NHW_Util.formatSSTUserName(u.Username, u.Name)+ EMAIL_CONST + u.email, u.Name);
                    option.additionalInformation.add(u.Username);
                    option.additionalInformation.add(u.Email);
                    result.add(option);
                }
            }
        }

        return result;
    }

    private List<PF_AuraLookupOption> getOrg62UserNoMgmtHierarchyToCloneOptions(String searchText, Map<String,String> additionalInformation){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        List<User> users = NHW_SSTCallOut.getSSTUsers('Org62', String.isBlank(searchText) ? searchText : String.escapeSingleQuotes(searchText.replaceAll('\\*', '')));
        if(users != null){
            for(User u:users){
                PF_AuraLookupOption option = new PF_AuraLookupOption(NHW_Util.formatSSTUserName(u.Username, u.Name)+ EMAIL_CONST + u.email, u.Name);
                option.additionalInformation.add(u.Username);
                option.additionalInformation.add(u.Email);
                result.add(option);
            }
        }
        return result;
    }
    
    private List<PF_AuraLookupOption> getOrg62UserToCloneOptions(String searchText, Map<String,String> additionalInformation){

        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();

        if(additionalInformation != null){
            PF_NHW_Process process = PF_NHW_Process.getProcessByName(additionalInformation.get('FLOW_TYPE'));
            if(process != null){
                if(process == PF_NHW_Process.CONTRACTOR){
                    //contractor code
                    result.addAll(getOrg62UserNoMgmtHierarchyToCloneOptions(searchText,additionalInformation));
                }else{
                    //FTE and relocation code
                    if(additionalInformation.containsKey('MANAGER_ID')){
                        result.addAll(getOrg62UserWithMgmtHierarchyToCloneOptions(searchText,additionalInformation));
                    }
                }
            }
        }
        if(!result.isEmpty()){
            return result;
        }
        return getPFUserToCloneOptions(searchText);
    }
    
    private PF_AuraLookupOption getOrg62UserToCloneOption(String optionId){
        if(String.isBlank(optionId)){
            return null;
        }
        return new PF_AuraLookupOption(optionId, NHW_Util.getSSTName(optionId));
    }
    
    
    private List<PF_AuraLookupOption> getGUSUserToCloneOptions(String searchText){

        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        List<User> users = NHW_SSTCallOut.getSSTUsers('Gus', String.escapeSingleQuotes(searchText));

        if(users != null){
            for(User u : users){
                PF_AuraLookupOption option = new PF_AuraLookupOption(NHW_Util.formatSSTUserName(u.Username, u.Name), u.Name);
                option.additionalInformation.add(u.Username);
                option.additionalInformation.add(u.Email);
                result.add(option);
            }
        }
        
        if(!result.isEmpty()){
            return result;
        }
        
        return getPFUserToCloneOptions(searchText);
        
    }
    
    private List<PF_AuraLookupOption> getSupporForceUserToCloneOptions(String searchText){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        List<User> users = NHW_SSTCallOut.getSSTUsers('Supportforce', String.escapeSingleQuotes(searchText));
        
        if(users != null){
            for(User u : users){
                PF_AuraLookupOption option = new PF_AuraLookupOption(NHW_Util.formatSSTUserName(u.Username, u.Name) + EMAIL_CONST + u.email, u.Name );                option.additionalInformation.add(u.Username);
                option.additionalInformation.add(u.Email);
                result.add(option);
            }
        }
        
        if(!result.isEmpty()){
            return result;
        }
        
        return getPFUserToCloneOptions(searchText);
    }
    
    
    private List<PF_AuraLookupOption> getGenericUserToCloneOptions(String searchText){
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(User u : [SELECT Id, Name, Email FROM User WHERE IsActive = true AND Profile.Name != 'customer portal manager custom' AND name LIKE :getSearchTextFilterStatement(searchText) ORDER BY Name limit 50]){
            PF_AuraLookupOption option = new PF_AuraLookupOption(u.Name, u.Name);
            option.additionalInformation.add(u.Email);
            result.add(option);
        }

        return result;
    }
    
    private PF_AuraLookupOption getGenericUserToCloneOption(String optionId){
        if(String.isBlank(optionId)){
            return null;
        }
        return new PF_AuraLookupOption(optionId, optionId);
    }
    
    private List<PF_AuraLookupOption> getPFUserToCloneOptions(String searchText){
        
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        
        for(User u : [SELECT Id, Email, Name, Username, Employeenumber FROM User WHERE IsActive = true AND Profile.Name != 'customer portal manager custom' AND name LIKE :getSearchTextFilterStatement(searchText) ORDER BY Name limit 50]){
            PF_AuraLookupOption option = new PF_AuraLookupOption(NHW_Util.formatSSTUserName(u.Username, u.Name)  + '; email:' + u.email, u.Name);
            option.additionalInformation.add(u.Username);
            option.additionalInformation.add(u.Email);
            result.add(option);
        }
        
        return result;
    }
    
    
    private List<PF_AuraLookupOption> getPastCaseToCloneOptions(String searchText,Map<String,String> additionalInformation){
        PF_NHW_Process process = PF_NHW_Process.getProcessByName(additionalInformation.get('FLOW_TYPE'));
        String ProcessName = process.Name;
        //PF_NHW_Process.CONTRACTOR
        List<PF_AuraLookupOption> result = new List<PF_AuraLookupOption>();
        Set<Id> userIds = PF_NHW_SecurityUtil.userIds;

        NH_Settings__c NHSetting = NH_Settings__c.getInstance();
        Integer Last_N_Days=Integer.valueOf(NHSetting.ClonePastHireNumDays__c);
        Last_N_Days = Last_N_Days == null? 90:Last_N_Days; 
        Date limitDate = Date.today().addDays(-Last_N_Days);
        for(Case c : [Select Id, First_Name__c, Last_Name__c,CaseNumber,NHW_Organization__c,Email_Address__c, NHW_Employee__r.FirstName, NHW_Employee__r.LastName, NHW_Employee__r.Name, NHW_Employee__r.Email 
                      from Case 
                      Where (
                                (First_Name__c LIKE :getSearchTextFilterStatement(searchText)) 
                                OR (Last_Name__c LIKE :getSearchTextFilterStatement(searchText)) 
                                OR (NHW_Employee__r.FirstName LIKE :getSearchTextFilterStatement(searchText))
                                OR (NHW_Employee__r.LastName LIKE :getSearchTextFilterStatement(searchText))
                                OR (NHW_Employee__r.Name LIKE :getSearchTextFilterStatement(searchText))
                            )
                         AND Created_with_NHW_2_0__c=true
                         AND RecordTypeId =:NHW_Util.getnhwCaseRecordTypeId()
                         AND (Status = 'Closed' OR Status = 'Sent to Supportforce')
                         AND NHW_Start_Date__c >= :limitDate
                         AND (CreatedById IN :userIds OR LastModifiedById IN :userIds)
                         AND NHW_Employee_Type__c = :ProcessName
                     ]){
           PF_AuraLookupOption option = new PF_AuraLookupOption(c.Id, c.First_Name__c +' '+ c.Last_Name__c);
           option.additionalInformation.add(c.Email_Address__c);
           option.additionalInformation.add('Department - '+ c.NHW_Organization__c);
           result.add(option);
        }
        return result;
    }
    
    private PF_AuraLookupOption getPastCaseHireName(String optionId){
        if(String.isBlank(optionId)){
            return null;
        }
        Case c = [SELECT Id, First_Name__c, Last_Name__c FROM Case WHERE Id = :optionId];
        if(c!= null){
            return new PF_AuraLookupOption(c.Id, c.First_Name__c +' '+ c.Last_Name__c);
        }
        return null;
    }
    
    private static String getSearchTextFilterStatement(String searchText){

        searchText = '%' + searchText + '%';
        searchText = searchText.replaceAll('\\*', '%');
        
        return searchText;
    }
}