public with sharing class ESDJC_CaseHandler {
    
    public static final String CASE_STATUS_WAITING_FOR_RESPONSE = 'Waiting for Response';
    public static final String CASE_RT_ALL_EXPENSE_CASES = 'All_Expense_Cases';
    public static final String CASE_RT_RELOCATIONS = 'Relocations';
    public static final String CASE_RT_ALL_EXCEPT_ER_AMER = 'ES_DJC_All_Case_Types_except_ER_AMER';
    public static final String CASE_RT_ALL_EXCEPT_ER_APAC = 'ES_DJC_All_Case_Types_except_ER_APAC';
    public static final String CASE_RT_ALL_EXCEPT_ER_EMEA = 'ES_DJC_All_Case_Types_except_ER_EMEA';
    public static final String CASE_RT_ALL_EXCEPT_ER_JAPAN = 'All_Case_Types_except_ER_Japan';
    public static final String CASE_RT_ALL_EXPENSE = 'All_Expense_Cases';
    private static final List<String> EXPENSE_CASES_SUPPORTED_DIVISIONS = ESDJC_CaseSettingService.getListValues('Expense_Cases_Supported_Divisions');
    public static final List<String> AUTO_RESPONSE_SUPPORTED_RT_DEV_NAMES = ESDJC_CaseSettingService.getListValues('Auto_Response_Supported_RT_Dev_Names');

    public static boolean stopCasecommentUpdates=false;
    public static integer counter=0;
    public static ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
    public static final Set<String> WHITE_LISTED_CASE_RT_FOR_SURVEY = ESDJC_CaseSettingService.getSetValues('White_Listed_Case_RT_For_Survey');
    static final Id warmlineCaseRecordTypeId = [Select Id From RecordType where sobjecttype = 'Case' and developername='Warmline'].Id;

    private static List<String> EMAIL_DOMAINS_WHITELIST = new List<String>();
    public static  final set<string> FOUNDATION_DEPTS = new set<string>(String.isBlank(settings.Foundation_Dept_Names__c) ? new list<string>() : settings.Foundation_Dept_Names__c.split(','));
    public static  final set<string> FOUNDATION_DEPTS_LOWERCASE= new set<string>();
    
    public static Boolean recursiveCheck = false;
    
    
    static{
        for(String s: new list<string>(FOUNDATION_DEPTS)){
            FOUNDATION_DEPTS_LOWERCASE.add(s.toLowercase());
        }
    }
    static{
        for(ESDJC_Domains_Whitelist__c domain:ESDJC_Domains_Whitelist__c.getall().values()){
            EMAIL_DOMAINS_WHITELIST.add(domain.domain__c);
        }
    }  

    private static User currentUser{
        set;
        get{
            if(currentUser == null ){
                List<User> users =  [select Id,name,UserPermissionsKnowledgeUser,FirstName,LastName,Division,contactId from User where Id = : UserInfo.getUserId() ];
                if(!users.isEmpty()){
                    currentUser = users[0];
                }
            }
            return currentUser; 
        }
    }

    public static boolean hasPrivateCommentTriggerAlreadyRun = false;
    private static Map<id, sobject> validCaseRecordTypes = null;
    private static Map<Id, User> ownerMap = null;

    public static void executeBeforeInserts(List<Case> newCases){
        Map<id,Contact> contacts = getCaseContacts(newCases);
        markFoundationCases(contacts,newCases);
        updateFullPhotoUrl(contacts, newCases);
        setPackageOwner(contacts, newCases);
        updateCaseQuestionType(newCases);
        updateCaseTypeforEmail2Case(newCases);
    }

    public static void updateBusinessHours(List<Case> cases) {
        List<BusinessHours> businessHours= [SELECT Id,Name FROM BusinessHours];
        Map<String, BusinessHours> businessHourMap = new Map<String, BusinessHours> ();
        for(BusinessHours bh : businessHours){
            businessHourMap.put(bh.Name, bh);
        }
        String region;
        for (Case aCase: cases){
            if(aCase.Division_Lookup__c != null){
                region = ESDJC_Util.getRegionFromDivision(aCase.Division_Lookup__c);
                System.debug('REGION FROM DIVISION - ' + region);
                aCase.BusinessHoursId = businessHourMap.get(region).Id;
                System.debug('BUSINESS HOURS ID - ' + aCase.BusinessHoursId);
            }
        }
    }

    //One of the overriden methods can removed WHEN
    //we refactor handler to optimize  queries to use common static vars
    //Invoked from Trigger.insert context.
   public static void markFoundationCases(Map<id,Contact> contacts,list<case> cases){
       for(case c: cases){
           contact con = contacts.get(c.contactId);
           if( con != null && con.department != null
               && FOUNDATION_DEPTS_LOWERCASE.size()>0
               && FOUNDATION_DEPTS_LOWERCASE.contains(contacts.get(c.contactId).department.toLowercase())){
               c.Is_Foundation__c = true;
           }
           else{
               c.Is_Foundation__c = false;
           } 
       }
   }

    //Invoked from Trigger.update context.
   public static void markFoundationCases(map<id,case> contactcasemap,list<case> newcases, map<id,case> oldcasemap){

       //Update foundation flag  only if contact on the case is updated.
       set<id> contactidschanged = new set<id>();       
       for(case c: newcases){
           if(oldcasemap.containskey(c.id) && oldcasemap.get(c.id).ContactId != c.ContactId ){           
               contactidschanged.add(c.contactid); 
           }
       }

        if(contactidschanged.size()>0){
            map<id,contact> contactinfo = new map<id,contact>( [select id,department from contact where id in :contactidschanged]);
            for(case c: newcases){
                contact con = contactinfo.containskey(c.contactid) ? contactinfo.get(c.contactid): null;
                if(con != null && con.department != null
                    && FOUNDATION_DEPTS_LOWERCASE.size()>0
                    && FOUNDATION_DEPTS_LOWERCASE.contains(con.department.toLowercase())){
                    c.Is_Foundation__c = true;
                }
                else{
                    c.Is_Foundation__c = false;
                }
                           
            }
        }

    }
   
    private static void updateFullPhotoUrl(Map<id,Contact> contacts, List<case> cases) {        
        Map<String,Contact> employeeEmail2ContactMap = new Map<String,Contact>();    
        Map<Id,String> contact2employeeNumMap = new Map<Id,String>();    
        for(Contact c: contacts.values()){
            employeeEmail2ContactMap.put(c.Email,c);
            contact2employeeNumMap.put(c.Id, c.EmployeeNumber__c);
        }               
        List<User> users = [SELECT EmployeeNumber, FullPhotoUrl from User WHERE Email IN :employeeEmail2ContactMap.keySet() AND isActive = TRUE];
        Map<String,User> employeeNum2UserMap = new Map<String,User>();
        for(User u: users){
            employeeNum2UserMap.put(u.EmployeeNumber,u);
        }       
        User aUser;
        String empNum;
        for(case c: cases){
            empNum = contact2employeeNumMap.get(c.ContactId);
            aUser = employeeNum2UserMap.get(empNum);
            if(aUser != null && aUser.FullPhotoUrl  != null){
                c.FullPhotoUrl__c = aUser.FullPhotoUrl;
            }
        }           
    }

    private static Map<id, Contact> getCaseContacts(List<Case> Cases){
        List<Id> contactIds = new List<Id>();
        for(case c: cases){
            contactIds.add(c.ContactId);
        }       
        Map<id,Contact> contacts = new Map<id, Contact>([SELECT Id, Name,Division__c,department, Email, EmployeeNumber__c, CurrencyIsoCode from Contact WHERE Id IN :contactIds]);
        return contacts;        

    }


    /*

     * Method to update the case on reassignment.  This allows the 
     * system to keep track of the Tier 1 rep who reassigned the case.
     * @param newRecords the updated cases with new data.
     * @param oldRecords the cases with old data.
     */

     public static void updateCaseReassignmentData(Map<Id, Case> newRecords, Map<Id, Case> oldRecords){

        //loop through all cases.
        for (Id caseId: newRecords.keySet()){
            Case newCase = newRecords.get(caseId);
            Case oldCase = oldRecords.get(caseId);
            //if the case has moved tiers
            if (newCase.Tier__c != oldCase.Tier__c && newCase.Tier__c == 'Tier 2'){
                newCase.ES_DJC_Case_Escalated_By__c = UserInfo.getName();
            }
        }

    }


    /*

     * Method to update all questions status that are associated with 
     * a case if the case gets closed.
     * @param newRecords the updated cases with new data. 
     */
     public static void updateStatusOnClose(List<Case> newRecords){
        //get question IDs where case is closed and has a question
        List<Id> questionIds = new List<Id>();
        for (Case cse: newRecords){
            if (cse.Status == 'Closed' && cse.QuestionId != null){
                questionIds.add(cse.QuestionId);
            }

        }

        //if we have questions then resolve them

        if (questionIds.size() > 0){
            List<Question> questions = [SELECT Id, Status__c FROM Question WHERE Id IN :questionIds];
            for (Question ques: questions){
                ques.Status__c = 'Resolved';
            }
            if(questions.size() > 0){
                if(Schema.Sobjecttype.Question.isUpdateable()){
                    update questions;
                    } else {
                        ESDJC_Util.displayAccessPrivilegeError('Update Question');
                    }
                }
            }       
        }



    //Determines case citations of articles and sets Has_Article_Linked__c 

    public static void caseArticleCheck (List<Case> cases) {

       if(currentUser == null || (currentUser != null && currentUser.UserPermissionsKnowledgeUser == false)){
            return; //Return if the user is not a Knowledge User
        }
        if(!Schema.Sobjecttype.KnowledgeArticleVersion.isQueryable()){
            ESDJC_Util.displayAccessPrivilegeError('Update KnowledgeArticleVersion');
            return;
        }

        Map<String,Case> caseMap = new Map<String,Case>();

        Map<String,Case> noArticlesCase = new Map<String,Case>();

        for(case c: cases){
            caseMap.put(c.Id,c);
            noArticlesCase.put(c.Id,c);
        }

        Map<String,Case> casesWithArticles = new Map<String,Case>();

        Map<String,Case> ArticleCaseBridge = new Map<String,Case>();

        Map<String,String> ArticleCreatedBridge = new Map<String,String>();

        for(CaseArticle ca: [Select KnowledgeArticleId, CaseId, CreatedById from CaseArticle Where CaseId IN : caseMap.keySet()]){
            casesWithArticles.put(ca.CaseId,caseMap.get(ca.CaseId));
            ArticleCreatedBridge.put(ca.KnowledgeArticleId,ca.CreatedById);
            ArticleCaseBridge.put(ca.CreatedById,caseMap.get(ca.CaseId));
            noArticlesCase.remove(ca.CaseId);

        }

        List<Case> SourceCases = new List<Case>();
        List<Case> CitationCases = new List<Case>();

        for(KnowledgeArticleVersion kav: [SELECT SourceId, CreatedById, KnowledgeArticleId, Language FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND KnowledgeArticleId IN : ArticleCreatedBridge.keySet()]){        
            if (kav.Language == 'en_US' || kav.Language == 'ja' ){
                 CitationCases.add(ArticleCaseBridge.get(ArticleCreatedBridge.get(kav.KnowledgeArticleId)));

                if(casesWithArticles.keySet().contains(kav.SourceId)){

                    SourceCases.add(casesWithArticles.get(kav.SourceId));

                     casesWithArticles.remove(kav.SourceId);

                }
            }

        }           
        for(Case c: CitationCases){

            c.Citation__c = true;
        }
        for(Case c: SourceCases){
            c.Known_Vs_New__c = 'New';
            c.Has_Article_Linked__c = true;
        }

        for(Case c: casesWithArticles.values()){
            c.Known_Vs_New__c = 'Known';
            c.Has_Article_Linked__c = true;
        }
        for(Case c: noArticlesCase.values()){

            c.Known_Vs_New__c = 'None';

        }

    }


    // update entitlement Id on case. 

    public static void updateCaseEntitlements(List<Case> newRecords,Map<Id,Case> newRecordsMap,Map<Id, Case> oldRecordsMap) {

        boolean isNewRecords = false; 
        Map<Id,Boolean> isRdyForUpdate = new Map<Id,Boolean>();

        List<Entitlement> execEntitlements = new List<Entitlement>();List<Entitlement> stdEntitlements = new List<Entitlement>();List<Entitlement> termEntitlements = new List<Entitlement>();

        for(Entitlement  e : [select id,Name,slaProcessId,slaProcess.Name from entitlement where Name in ('Executive Entitlement','Standard Entitlement','Termination Case Type Entitlement')]){

            if(e.Name.trim().equals('Executive Entitlement')){

                execEntitlements.add(e);

            }

            else if(e.Name.equals('Standard Entitlement')){

                stdEntitlements.add(e);

            }

            else if(e.Name.equals('Termination Case Type Entitlement')){

                termEntitlements.add(e);

            }

        }       

        if(newRecordsMap==null){ // before insert records . 

            isNewRecords=true;

        }

        else {

            for(Case c : newRecordsMap.values()){ 

                Case old_case = oldRecordsMap.get(c.Id);

                if((c.Type!=old_case.Type) || (c.ES_DJC_Sub_Topic__c!=old_case.ES_DJC_Sub_Topic__c) || (c.ES_DJC_Is_L1_L2__c!=old_case.ES_DJC_Is_L1_L2__c) || (c.ES_DJC_Is_L3_L5__c!=old_case.ES_DJC_Is_L3_L5__c) 

                    || (c.ES_DJC_Executive_Assistant_Flag__c!=old_case.ES_DJC_Executive_Assistant_Flag__c)){

                    isRdyForUpdate.put(c.Id,true);

                }

                else{

                    isRdyForUpdate.put(c.Id,false);

                }

            }

        }

              
        String caseOrigin = settings.DJC_Override_Entitlement_Origins__c;
        String caseType = settings.DJC_Override_Entitlement_Types__c;
        
        if(caseOrigin ==null ||caseType ==null)
        {
           return;
        }
      
        
        Set<String> setOrigins = new Set<String>(caseOrigin.split(','));
        Set<String> setTypes = new Set<String>(caseType.split(','));
        
        for(Case c : newRecords){

            if(c.origin!=null && (setOrigins.contains(c.origin)) || (c.type!= null && (setTypes.contains(c.type)))){

                continue;
            } 
            else{

                if(isNewRecords || isRdyForUpdate.get(c.Id)){

                    if( ( (c.ES_DJC_Sub_Topic__c!=null) && ((c.ES_DJC_Sub_Topic__c.equals('Termination Future Date')) || (c.ES_DJC_Sub_Topic__c.equals('Termination Urgent')))) || ( c.Type!=null && c.Type.equals('Separations'))){

                        c.EntitlementId = (termEntitlements!=null && termEntitlements.size()>0)?termEntitlements[0].Id : null;

                    }

                    else if( ((c.ES_DJC_Is_L1_L2__c!=null) && (c.ES_DJC_Is_L1_L2__c.equals('Yes'))) || ((c.ES_DJC_Is_L3_L5__c!=null) && (c.ES_DJC_Is_L3_L5__c.equals('Yes')) && (c.Division_Lookup__c != null) && (c.Division_Lookup__c.equalsIgnoreCase('Japan')))

                        || ((c.ES_DJC_Executive_Assistant_Flag__c!=null) && (c.ES_DJC_Executive_Assistant_Flag__c.equals('Yes'))) ){


                        c.EntitlementId=(execEntitlements!=null && execEntitlements.size()>0)?execEntitlements[0].Id : null;

                    }

                    else {
                        c.EntitlementId = (stdEntitlements!=null && stdEntitlements.size()>0)?stdEntitlements[0].Id : null;
                    }
                    
                    c.ES_DJC_SLA_Expiration_Status__c = 'Compliant';

                }

            }

        }

    }

    /* populate contact : If an employee refers a candidate(s), then his email address exists in two or more records and hence email to case contacts are not populating . Following method will fix this issue */

    public static void findContact(List<Case> newRecords,Map<Id,Case> newRecordsMap){
        Map<String,Case> orphanContactsMap = new Map<String,Case>();
        Map<Id,Case> checkValidContactMap = new Map<Id,Case>();
        Map<String,Contact> contactLookup = new Map<String,Contact>();
        for(Case c : newRecords){
            if(c.SuppliedEmail!=null && c.contactId!=null){
                if (String.isNotBlank(c.origin) && (c.origin.containsIgnoreCase('Email'))) {
                    continue;
                }
                checkValidContactMap.put(c.contactId,c);
            }
            else if(c.SuppliedEmail!=null && c.contactId==null){
                orphanContactsMap.put(c.SuppliedEmail,c);

            }
        }
        // nullify the contact if it is not employee or contarctor . 
        if(checkValidContactMap.size()>0){
            for(Contact con : [select id,recordType.developerName from contact where id in : checkValidContactMap.keyset()  ] ){
                if(!(con.recordType.developerName=='Employee' || con.recordType.developerName=='Contractor')){
                    checkValidContactMap.get(con.Id).contactId=null;
                }
            }
        }

        // find and attach contacts to orphan cases.  
        if(orphanContactsMap!=null && orphanContactsMap.size()>0){

            for(Contact con : [select id,Division__c,name,email from contact where email in : orphanContactsMap.keyset() and recordtype.developerName='Employee' order by email]){

                if(contactLookup.containsKey(con.email)){

                    contactLookup.remove(con.email); ///we only want to associate contact to case if we have unique contact record associated to employee email id. 

                }
                else{
                    contactLookup.put(con.email,con); 

                }

            }

            for(Case c : orphanContactsMap.values()){
                if(c.SuppliedEmail!=null && contactLookup.get(c.SuppliedEmail)!=null){
                    c.contactId=contactLookup.get(c.SuppliedEmail).Id;

                }

            }
        }
    }

    public static void validateEmailToCaseContacts(List<Case> newRecords){

        if(settings == null || settings.djc_Helpdesk_API_User__c == null || UserInfo.getUserId().equals(settings.djc_Helpdesk_API_User__c)){

            Map<Id, Case> caseIdContact = new Map<Id, Case>();

            for(Case c : newRecords){
                if(c.Origin != null && c.Origin.startsWithIgnoreCase('Email to case')){
                    caseIdContact.put(c.contactId, c);
                }
            }

            for(Contact con : [select id,recordType.developerName from contact where id in : caseIdContact.keyset()] ){
                if(!(con.recordType.developerName == 'Employee' || con.recordType.developerName == 'Contractor' || con.recordType.developerName == 'WDR_Candidate')){
                    caseIdContact.get(con.Id).contactId = null;
                }
            }
        }

    }

    //Validates the contact is not a candidate in case the sender domain is in the whitelist 
    public static void validateContacts(List<Case> newRecords){

        Map<Id,Case> checkValidContactMap = new Map<Id,Case>();
        
        for(Case c : newRecords){
            if(c.SuppliedEmail != null && c.contactId != null && isEmailInWhitelist(c.SuppliedEmail)){
                checkValidContactMap.put(c.contactId,c);
            }
        }

        if(checkValidContactMap.size() > 0){

            for(Contact con : [select id,recordType.developerName from contact where id in : checkValidContactMap.keyset()  ] ){
                if(!(con.recordType.developerName == 'Employee' || con.recordType.developerName == 'Contractor' || con.recordType.developerName == 'WDR_Candidate')){
                    checkValidContactMap.get(con.Id).contactId = null;
                }
            }
        }
    }

    private static Boolean isEmailInWhitelist(String email){

        if(email == null){
            return false;
        }

        for(String domain:EMAIL_DOMAINS_WHITELIST){
            if(email.endsWithIgnoreCase(domain)){
                return true;
            }
        }
        return false;
    }

   
    /*populate MH3-6 fields*/
    public static void populateManagementHierarchies(List<Case> newRecords){

        Map<Case,Id> caseContactMap = new Map<Case,String>();

        Map<String,Contact> empNumberToContactMap = new Map<String,Contact>();

        Set<ID> contactIds  = new Set<ID>();

        Map<String,Id> employeeNumberToContactMap = new Map<String,Id>();

        Set<String> employeeIds = new Set<String>();

        Map<Id,ManagementHierarchy> mgmntHierarchyMap = new Map<Id,ManagementHierarchy>();



        /*insert all the contactIds and In reference-to contacts(if any) to contactIds set*/

        for(Case c : newRecords){

            if(c.In_Reference_To__c!=null && c.contactId!=null){

                contactIds.add(c.In_Reference_To__c);

                contactIds.add(c.contactId);

                caseContactMap.put(c,c.In_Reference_To__c);

            }

            else if(c.In_Reference_To__c==null && c.contactId!=null){

                contactIds.add(c.contactId); 

                caseContactMap.put(c,c.contactId);

            }

        }


        List<Contact> contactsList = [select id,ESDJC_Employee_Id_MH3__c,ESDJC_Employee_Id_MH4__c,ESDJC_Employee_Id_MH5__c,ESDJC_Employee_Id_MH6__c from contact where id in : contactIds];               
        for(Contact con : contactsList){

            if(con.ESDJC_Employee_Id_MH3__c!=null){ 

                employeeIds.add(con.ESDJC_Employee_Id_MH3__c);

            }

            if(con.ESDJC_Employee_Id_MH4__c!=null){

                employeeIds.add(con.ESDJC_Employee_Id_MH4__c);

            }



            if(con.ESDJC_Employee_Id_MH5__c!=null){

                employeeIds.add(con.ESDJC_Employee_Id_MH5__c); 

            }

            if(con.ESDJC_Employee_Id_MH6__c!=null){

                employeeIds.add(con.ESDJC_Employee_Id_MH6__c);

            }

        }


        for(Contact con : [select id,EmployeeNumber__c from contact where EmployeeNumber__c  in : employeeIds]){

            employeeNumberToContactMap.put(con.EmployeeNumber__c,con.Id);

        }

        for(Contact con : contactsList){
            Id mh3,mh4,mh5,mh6;

            mh3 = (employeeNumberToContactMap!=null && employeeNumberToContactMap.get(con.ESDJC_Employee_Id_MH3__c)!=null)? employeeNumberToContactMap.get(con.ESDJC_Employee_Id_MH3__c) : null;

            mh4 = (employeeNumberToContactMap!=null && employeeNumberToContactMap.get(con.ESDJC_Employee_Id_MH4__c)!=null)? employeeNumberToContactMap.get(con.ESDJC_Employee_Id_MH4__c) : null;

            mh5 = (employeeNumberToContactMap!=null && employeeNumberToContactMap.get(con.ESDJC_Employee_Id_MH5__c)!=null)? employeeNumberToContactMap.get(con.ESDJC_Employee_Id_MH5__c) : null;

            mh6 = (employeeNumberToContactMap!=null && employeeNumberToContactMap.get(con.ESDJC_Employee_Id_MH6__c)!=null)? employeeNumberToContactMap.get(con.ESDJC_Employee_Id_MH6__c) : null;

            ManagementHierarchy mgh = new ManagementHierarchy(mh3,mh4,mh5,mh6);

            mgmntHierarchyMap.put(con.Id,mgh);
        }



        for(Case ca : newRecords){
            if(ca.In_Reference_To__c!=null && ca.contactId!=null){

                if(mgmntHierarchyMap!=null && mgmntHierarchyMap.get(ca.In_Reference_To__c)!=null) {

                    if(mgmntHierarchyMap.containsKey(ca.contactId)){
                        ca.ESDJC_Contact_Management_Hierarchy_3__c =  mgmntHierarchyMap.get(ca.contactId).MH3;
                    }                

                    ca.ESDJC_Management_Hierarchy_3__c =  mgmntHierarchyMap.get(ca.In_Reference_To__c).MH3;

                    ca.ESDJC_Management_Hierarchy_4__c =  mgmntHierarchyMap.get(ca.In_Reference_To__c).MH4;

                    ca.ESDJC_Management_Hierarchy_5__c =  mgmntHierarchyMap.get(ca.In_Reference_To__c).MH5;

                    ca.ESDJC_Management_Hierarchy_6__c =  mgmntHierarchyMap.get(ca.In_Reference_To__c).MH6;

                }       

            }

            else if(ca.contactId!=null){

                if(mgmntHierarchyMap!=null &&mgmntHierarchyMap.get(ca.contactId)!=null) {

                    ca.ESDJC_Contact_Management_Hierarchy_3__c =  mgmntHierarchyMap.get(ca.contactId).MH3;

                    ca.ESDJC_Management_Hierarchy_3__c =   mgmntHierarchyMap.get(ca.contactId).MH3;

                    ca.ESDJC_Management_Hierarchy_4__c =  mgmntHierarchyMap.get(ca.contactId).MH4;

                    ca.ESDJC_Management_Hierarchy_5__c =  mgmntHierarchyMap.get(ca.contactId).MH5;

                    ca.ESDJC_Management_Hierarchy_6__c = mgmntHierarchyMap.get(ca.contactId).MH6;

                }

            }

        }

    } 





    public class ManagementHierarchy{

        public ID MH3{get;set;}

        public ID MH4{get;set;}

        public ID MH5{get;set;}

        public ID MH6{get;set;}



        public ManagementHierarchy(ID mh3,ID mh4,ID mh5,ID mh6){

            this.MH3=mh3;

            this.MH4=mh4;

            this.MH5=mh5;

            this.MH6=mh6;

        }

    }

    private static void updateCaseQuestionType(List<Case> newRecords){
        for(Case c : newRecords){
            if ((c.Origin!=null) && c.Origin.equalsIgnoreCase('Chatter Answers')&&(UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c))&&(c.QuestionId==null) &&(c.Question_Type__c==null)) {              
                c.Question_Type__c = 'Private';                                         
            }       
        }
    }

    public static void markdjcCases(List<Case> newRecords){     
        for(Case c : newRecords){
            if (((c.Origin!=null) && (c.Origin!='NHW')) || (c.Origin == null)) {                
                if (!c.ESDJC_djc_case__c){
                    c.ESDJC_djc_case__c = true;
                }                                           
            }       
        }
    }

    public static void updateCaseDescriptionsWithPackageInfo(List<Case> newRecords, Map<Id,Case> oldRecordsMap) {
        List<Case> casesToUpdate = new List<Case>();

        List<RecordType> REWS_record_types = [SELECT Id FROM RecordType WHERE sObjectType='Case' AND isActive=true AND DeveloperName= 'REWS_Package_Management' ];
        Set<String> REWS_record_type_ids = new Set<String>();

        for (RecordType r : REWS_record_types ) {
            REWS_record_type_ids.add(r.Id);
        }

        if (oldRecordsMap == null) {
            for (Case c : newRecords) { //for inserts
                if (REWS_record_type_ids.contains(c.RecordTypeId)) {
                    String carrier = '';
                    String sender= '';

                    if (!String.isBlank(c.REWS_Carrier__c)) {
                        carrier = c.REWS_Carrier__c;
                    }

                    if (!String.isBlank(c.REWS_Sender__c)) {
                        sender = c.REWS_Sender__c;
                    }

                    if (c.Description == null) {
                        c.Description =  'Carrier: '+ carrier + '\n';
                    } else {
                        String [] separate_description_by_carrier = c.Description.split('Carrier:', 2);
                        c.Description = separate_description_by_carrier[0]+ '\n' + 'Carrier:  ' + carrier + '\n';
                    }

                    c.Description += 'Sender: ' + sender + '\n'
                            + 'Location:' + '\n'
                            + 'Pending Package Count: 0';
                    c.Description = c.Description.replaceAll('(\\n\\n)','\n' );
                }
            }
        } else {

            //update the descriptions of the cases
            for (Case c : newRecords) {
                if (REWS_record_type_ids.contains(c.RecordTypeId)){
                    String carrier = '';
                    String sender= '';
                    String location= '';
                    decimal pending_packages= 0;

                    if (!String.isBlank(c.REWS_Carrier__c)) {
                        carrier = c.REWS_Carrier__c;
                    }

                    if (!String.isBlank(c.REWS_Sender__c)) {
                        sender = c.REWS_Sender__c;
                    }

                    if (c.Pending_Package_Count__c > 0) {
                        location = c.REWS_Delivery_Location__c;
                        pending_packages = c.Pending_Package_Count__c;
                    }

                    if (!String.isBlank(c.Description)){
                        String [] separate_description_by_carrier = c.Description.split('Carrier:', 2);
                        c.Description = separate_description_by_carrier[0]+ '\n' + 'Carrier:  ' + carrier + '\n';
                    } else {
                        c.Description = 'Carrier: ' + carrier + '\n';
                    }

                    c.Description += 'Sender: ' + sender + '\n'
                                    + 'Location: '+ location + '\n'
                                    + 'Pending Package Count: ' + pending_packages;
                    c.Description = c.Description.replaceAll('(\\n\\n)','\n' );

                } else {
                    //the case record type is not REWS so we update the description as it was originally
                    if (!String.isBlank(c.Description)){
                        //get the original description
                        String [] separate_description_by_carrier = c.Description.split('Carrier:', 2);
                        c.Description = separate_description_by_carrier[0];
                    }
                }
            }
        }
    }

    public static void updateDescriptions(List<Case> newRecords,Map<Id,Case> oldRecordsMap){

        if(oldRecordsMap==null){

            for(Case c : newRecords){ //for inserts 

                if(c.Description!=null && c.ES_DJC_Description__c==null){  /*copy std to custom */

                    c.ES_DJC_Description__c=c.Description;

                }

                else if(c.Description==null && c.ES_DJC_Description__c!=null){ /*copy custom to std */

                    c.Description = c.ES_DJC_Description__c.stripHtmlTags();

                }

            }

        }

        else{ //for updates

            for(Case c : newRecords){

                if(c.Description!=oldRecordsMap.get(c.Id).Description){

                    c.ES_DJC_Description__c=c.Description;

                }

                else if(c.ES_DJC_Description__c!=oldRecordsMap.get(c.Id).ES_DJC_Description__c){

                    c.Description = c.ES_DJC_Description__c.stripHtmlTags();

                }

            }

        }

    }


    public static void checkEscalations(List<Case> newRecords,Map<Id,Case> newRecordsMap,Map<Id, Case> oldRecordsMap){
        
        String sObjectAPIName = 'Case';

        DJC_Escalation_Rule__mdt[] rules = [select id, (select Field_API_Name__c, Field_Value__c from DJC_Escalation_Rule_Criterias__r)
        from DJC_Escalation_Rule__mdt
        where Object__c =  :sObjectAPIName and 
        Is_Active__c = true];

        for (Case c: newRecords){
            String oldTier = null;
            if (oldRecordsMap!=null){
                oldTier = oldRecordsMap.get(c.id).Tier__c;
            }
            String newTier = newRecordsMap.get(c.id).Tier__c;
            system.debug('oldTier '+oldTier);
            system.debug('newTier '+newTier);
            if (c.ESDJC_SupportForce_Case_Number__c == null) {
                if (oldTier==null) oldTier = 'Tier 1';
                if (newTier==null) newTier = 'Tier 1';
                if ((oldTier != newTier)&&(newTier!='Tier 1')){
                    if(c.Is_Foundation__c){
                        c.addError('.Org Cases cannot be escalated to '+c.Tier__c);
                        continue;//Foundation cases cannot be escalated.
                    }                    
                    boolean match_found = false;
                    for (DJC_Escalation_Rule__mdt rule : rules) {                  
                        DJC_Escalation_Rule_Criteria__mdt[] Criteria = rule.DJC_Escalation_Rule_Criterias__r;
                        for(DJC_Escalation_Rule_Criteria__mdt Criterion : Criteria){
                            String Field = Criterion.Field_API_Name__c;
                            String Value = Criterion.Field_Value__c;
                            if ((newRecordsMap.get(c.id).get(Field)!=null)&&(String.valueOf(newRecordsMap.get(c.id).get(Field)).equalsIgnoreCase(Value))){
                                match_found = true;                 
                                }else{
                                    match_found = false;
                                    break;
                                }               
                            }
                            if (match_found){
                                break;
                            }           
                        }
                        if (!match_found){
                            c.addError('Cases of type ' + c.Type + ' cannot be escalated to '+c.Tier__c);
                        }
                    }
                }
            }   
        }

        public static Map<Id, Case> fetchContactInfoByCase(Map<Id, Case> newMap) {
            if (newMap == null) {
                return new Map<Id, Case>();
            }
            return new Map<Id, Case>([select Id, Contact.ES_DJC_Portal_User_Language__c,Contact.department from Case where Id IN :newMap.keySet()]);
        }

        public static void addCaseCommentsOnAutoClose(Map<Id,Case> newMap, Map<Id,Case> oldMap, Map<Id, Case> contactCaseMap){
            List<CaseComment> caseComments = new List<CaseComment>();
             
            for(Case ca : newMap.values()){ 
                if(ca.ES_DJC_Is_Ready_to_close_case__c){                         
                    if(contactCaseMap!=null && contactCaseMap.size()>0){
                        CaseComment cc = new CaseComment();
                        cc.ParentId= ca.Id;
                        cc.isPublished=true;
                        if((contactCaseMap.get(ca.Id).contact.ES_DJC_Portal_User_Language__c!=null) && (contactCaseMap.get(ca.Id).contact.ES_DJC_Portal_User_Language__c=='ja')){
                            cc.CommentBody=System.Label.ES_DJC_Autoclose_text_ja;
                            ca.ES_DJC_Last_Comment__c=System.Label.ES_DJC_Autoclose_text_ja;
                        }
                        else{
                            cc.CommentBody=System.Label.ES_DJC_Autoclose_text;
                            ca.ES_DJC_Last_Comment__c=System.Label.ES_DJC_Autoclose_text;
                        }
                        caseComments.add(cc);
                    }            
                }
            }

            if(caseComments!=null && caseComments.size()>0){
                stopCasecommentUpdates=true;
                insert caseComments;
            }
        }

    //Update case owner email field
    public static void updateCaseOwnerEmail(List<Case> newCases) {
        if (ownerMap == null || isOwnerChangedByOtherProcess(newCases)) {
            fetchCaseOwnerUserDetails(newCases);
        }
        for (Case c : newCases) {
            if (ownerMap.containsKey(c.OwnerId)) {
                c.ESDJC_Case_Owner_Email__c = ownerMap.get(c.OwnerId).Email;
            }
            else {
                c.ESDJC_Case_Owner_Email__c = null;
            }
        }
    }

    /**
     ** Returns a map of Id to User record for all owners of cases 
     ** that are users
     */
     public static void fetchCaseOwnerUserDetails(List<Case> newCases) {
        ownerMap = new Map<Id, User>();
        Set<Id> userIds = new Set<Id>();

        String userKeyPrefix = Schema.SObjectType.User.getKeyPrefix();
        for (Case c : newCases) {
            String ownerId = c.OwnerId;
            if (ownerId != null && ownerId.startsWith(userKeyPrefix)) {
                userIds.add(c.OwnerId);
            }
        }

        //Query for user's email
        if (!userIds.isEmpty()) {
            ownerMap = new Map<Id, User>([select Id, Email, UserRole.Name from User where Id IN :userIds]);
        }
    }

    //Update supportforce case
    public static void updateSupportforceCases(Map<Id, Case> newMap, Map<Id, Case> oldMap) {        
        //Iterate through new cases
        for (Case c : newMap.values()) {
            if (c.ESDJC_djc_case__c){
                if (c.ESDJC_Supportforce_Case_Number__c != null) {
                    if (oldMap.get(c.Id)!= null && oldMap.get(c.Id).ESDJC_Supportforce_Case_Number__c == null) {
                        //update tier
                        if (c.Type != null) {
                            if (c.Type.equalsIgnoreCase('V2MOM Support'))
                              c.Tier__c = 'Tier 4';
                            else
                              c.Tier__c = 'Tier 3';
                        }
                    }

                    //update case status
                    if (c.Status != null) {
                        if (c.Status.equalsIgnoreCase('New')){
                            c.Status = 'Sent to Supportforce';
                        }
                        if (c.Status.equalsIgnoreCase('Waiting for Response from User'))
                        c.Status = 'Waiting for Response';
                    }
                }
            }   
        }
    }
    
    
    public static void updateWellnessReimbursementCaseStatus(List<Case> newRecords,Map<Id,Case> oldCasesMap) {
        for(Case c : newRecords) {
            if((c.type == 'Wellness Reimbursement Request' || c.type == 'Education Reimbursement Request') && ( (c.status == 'Approved' && oldCasesMap.get(c.Id).Status!='Approved') || (c.status == 'Approved for Partial Payment' && oldCasesMap.get(c.Id).Status!='Approved for Partial Payment')) ) {
                c.DJC_Reimbursement_Case_Approved_On__c = System.now();
            }
        }
        
    }

    public static void updateWellnessReimbursementCaseStatusOnRiskLevel(List<Case> newRecords) {
   
       Boolean isAppZenEnabled = settings.Is_Appzen_GA__c;

       String appZenCaseType = System.Label.AppZen_Case_Type;
       String appZenCaseDivision = System.Label.AppZen_Case_Division;
       String appZenCaseStatus = System.Label.AppZen_Case_Status;
       String appZenCaseRiskLevel = System.Label.AppZen_Risk_Level;
       
       Set<String> caseTypes = new Set<String>();   
       Set<String> caseDivisions = new Set<String>();
       Set<String> caseRiskLevels = new Set<String>(); 
       
       if(isAppZenEnabled){

            for(String str : appZenCaseType.split(',')){
               
               caseTypes.add(str);
           
            }
           
            for(String str : appZenCaseDivision.split(',')){
               
               caseDivisions.add(str);
           
            }
            
            for(String str : appZenCaseRiskLevel.split(',')){
               caseRiskLevels.add(str);
            }
                   
            for(Case c : newRecords) {
            
                String expenseCaseType = c.type;
                String expenseCaseDivision = c.Division__c;
                String expenseCaseStatus = c.Status;
                String expenseCaseRiskLevel = c.Risk_Level__c;
                            
                Boolean isValidCaseType = caseTypes.contains(expenseCaseType);
                Boolean isValidCaseDivision = caseDivisions.contains(expenseCaseDivision);
                Boolean isValidCaseStatus = appZenCaseStatus.equals(expenseCaseStatus);
                Boolean isCaseRiskLevelLow = caseRiskLevels.contains(expenseCaseRiskLevel);
                
                if(isValidCaseType && isValidCaseDivision && isValidCaseStatus) {
                   
                   if(c.Risk_Level__c != null){
                                      
                       if(isCaseRiskLevelLow){
                           
                           c.Status = 'Approved';
                       
                       }
                       else{
                           
                           c.Status = 'On Hold';
                        }                 
                    }            
                }
            } 
        }   
    }

    private static void updateCaseTypeforEmail2Case(List<Case> newRecords){
        for (Case c:newRecords){
            if (c.Origin!=null){
                if(c.Origin.equalsIgnoreCase('Email to Case_Immigration')){
                    c.type = 'Immigration'; 
                }
                else if (c.Origin.equalsIgnoreCase('Email to Case_Mobility')){
                    c.type = 'Relocation & Visas';
                }
                else if (c.Origin.equalsIgnoreCase('Email to Case_GEPS')){
                    c.type = 'ESPP';                   
                }                
                else if (c.Origin.equalsIgnoreCase('Email to Case_Expense EMEA Corp Card')){
                    c.type = 'Expense / Amex';
                    c.ES_DJC_Topic__c = 'Amex';
                    c.ES_DJC_Sub_Topic__c = 'Corporate Card Applications';
                }
                else if (c.Origin.equalsIgnoreCase('Email to Case_Expense Management')){
                    c.type = 'Expense / Amex';
                } 
                else if (c.Origin.equalsIgnoreCase('Email to Case_LOA') || c.Origin.equalsIgnoreCase('Email to Case_EMEA LOA') || 
                            c.Origin.equalsIgnoreCase('Email to Case_APAC LOA') || c.Origin.equalsIgnoreCase('Email to Case_JP LOA')){
                    c.type = 'Benefits';
                }
                else if (c.Origin.equalsIgnoreCase('Email to Case_Term AMER') || c.Origin.equalsIgnoreCase('Email to Case_Term EMEA') || 
                            c.Origin.equalsIgnoreCase('Email to Case_Term APAC') || c.Origin.equalsIgnoreCase('Email to Case_Term JP')){
                    c.type = 'Separations';
                }             
            }
        } 
    }  

    public static void updatePrivateCaseCommentsIfAny(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        //Do not execute if update was called by case comment trigger
        if (!ESDJC_CaseHandler.hasPrivateCommentTriggerAlreadyRun) {
            ESDJC_CaseHandler.hasPrivateCommentTriggerAlreadyRun = true;
            List<CaseComment> caseCommentsToBeInserted = new List<CaseComment>();
            for (Case c : newMap.values()) {
                if (c.ESDJC_Private_Case_Comment__c != null && c.ESDJC_Supportforce_Case_Number__c != null && oldMap != null && oldMap.get(c.Id) != null && oldMap.get(c.Id).ESDJC_Private_Case_Comment__c != c.ESDJC_Private_Case_Comment__c) {
                    //create private case comment 
                    for (String s : c.ESDJC_Private_Case_Comment__c.split('<eom>')) {
                        CaseComment cc = new CaseComment(ParentId=c.Id, CommentBody=s);
                        caseCommentsToBeInserted.add(cc);
                    }
                }
            }
            if(!caseCommentsToBeInserted.isEmpty()) {
                Database.Dmloptions options = new Database.Dmloptions();
                options.EmailHeader.triggerUserEmail = true;
                Database.insert(caseCommentsToBeInserted, options);
            }
        }
    }


    private static void setPackageOwner(Map<id,Contact> contacts, List<case> cases){
        for(Case c : cases){                
            if(c.recordTypeId ==REWS_Setting__c.getInstance().Case_Package_Delivery_Record_Type__c){
                if(c.origin==null){
                    c.origin='Package Delivery';
                }
                
                Contact caseContact = contacts.get(c.ContactId);
                              
                if(c.subject==null){                        
                    if ((caseContact!=null) && (caseContact.Name != null)){ 
                        c.subject=string.format(System.Label.REWS_Package_Delivery_Subject, new String[]{'for '+caseContact.Name});
                        }else{
                            c.subject=string.format(System.Label.REWS_Package_Delivery_Subject,new String[]{''});
                        } 
                    }
                    String division = (currentUser!=null)?(currentUser.division):null;
                    if ((division != null) && (division.equalsIgnoreCase('EMEA - All Countries'))){
                        if(REWS_Setting__c.getInstance().EMEA_Mail_Services_Queue_Id__c != null){
                            c.ownerId = REWS_Setting__c.getInstance().EMEA_Mail_Services_Queue_Id__c;
                        }
                        }else{
                            if(REWS_Setting__c.getInstance().Mail_services_queue_Id__c != null){
                                c.ownerId=REWS_Setting__c.getInstance().Mail_services_queue_Id__c;
                            }
                        }
                    }
                }
            } 


    public static void checkValidationsConsole(List<Case> triggerNew){

        if(!UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c) && !UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c) && !UserInfo.getProfileId().contains(settings.MoveWorks_API_User_Profile_Id__c) && !UserInfo.getUserId().equals(settings.djc_Helpdesk_API_User__c)){ //only console users (and not helpdek api user) 
            Set<Id> validRecordTypeIds = getValidCaseRecordType().keySet();   //exclude NHW and Package mgmnt cases*/           
            Map<Id,boolean> getMapValidations = ESDJC_Util.isValidationsPassed(triggerNew);
            for(Case c : triggerNew){
                if(validRecordTypeIds.contains(c.recordTypeId) && !getMapValidations.get(c.Id)) {
                    List<String> params = new List<String>{c.Status};
                    String errMessage = String.format(System.Label.ES_DJC_Validations_Error_Message, params);
                    c.addError(errMessage);
                }
            }

        }
    }
    
    public static void updateStatusForCasesClosedByEmployees(List<Case> newRecords, Map<id,Case> oldRecordsMap) {
        if ((newRecords == null) || (oldRecordsMap == null)) return;
        if ((UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c))||
                    (UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c))) {
            for (Case newCase : newRecords) {
                Case oldCase = oldRecordsMap.get(newCase.id);
                if (oldCase == null) continue;
                if ((newCase.ESDJC_Supportforce_Case_Id__c==null) && (!oldCase.IsClosed) 
                        && (newCase.status == 'Closed') && (!newCase.First_Response_Flag__c)) {                 
                    newCase.Status = 'Closed By Employee';
                }
            }            
        }
    }

    public static void sendFeedBackEmail(List<Case> newRecords, Map<Id,Case> oldRecordsMap){
        if ((newRecords == null) || (oldRecordsMap == null)){
            return;
        }           
        Set<Contact> surveyContacts = new Set<Contact>();
        Map<Id, Schema.RecordTypeInfo> recordTypeByIdMap = Schema.SObjectType.case.getRecordTypeInfosById();
        Set<Id> newRecordIds = new Set<Id>();
        Set<Id> benefitAndTerminatedCaseIds = new Set<Id>();
        List<caseNotificationEvent__e> caseNotificationEvents = new List<caseNotificationEvent__e>();
        Map<Id,Id> contactIdToClosedCaseIdMap = new Map<Id, Id>();

        //W-3398636 - Exclude cases sent to supportforce   
        List<String> StatusListToExclude = new List<String>();
        Set<String> StatusSetToExclude = new Set<String>();
        StatusListToExclude = (List<String>)((String.ISBLANK(settings.Status_list_to_exclude_for_Survey__c))? StatusListToExclude :settings.Status_list_to_exclude_for_Survey__c.split(','));
        //Make it set collection so that we can check for presence of the element.
        //Null handling - If no statuses are configured to be exclude in custom setting -Then logic excludes none and includes ALL statuses as expected by user.
        StatusSetToExclude = new Set<String>(StatusListToExclude);
        
        for (Case c : newRecords) {
            Case oldCase = oldRecordsMap.get(c.id);

            //We do not want to send surveys for cases closed with a status in the exclusion list.
            //So added those checks as well as moved the supportforce case number check to seperate condition as it was bypassing 
            //status exclusion check.      
            if ((!oldCase.isClosed) && (c.isClosed) && (!c.DJC_Is_Survey_Email_Sent__c) && (c.contactId != null) 
               && !(statusSetToExclude.contains(c.status))
               //For DJC cases transferred to supportforce,We need to check case number and not status as 'Sent to supportforce'
               // as case connector closes the case on successful transfer.
               &&  c.ESDJC_Supportforce_Case_Number__c == null) { 
                    String caseRT = recordTypeByIdMap.get(c.recordtypeId).getDeveloperName();
                    if ((WHITE_LISTED_CASE_RT_FOR_SURVEY.contains(caseRT) && c.type !='Employee Relations') 
                        || (CASE_RT_ALL_EXPENSE.equals(caseRT) && EXPENSE_CASES_SUPPORTED_DIVISIONS.contains(c.Division__c))) {
                        contactIdToClosedCaseIdMap.put(c.contactId, c.id);      
                    }                          
            }
        }
        if (contactIdToClosedCaseIdMap.size()>0) {
            //W-3387246 Make survey email frequency configurable.   
            Integer surveyEmailFrequency = (Integer)(settings.Survey_Email_Frequency__c==null ? 5:settings.Survey_Email_Frequency__c);

            //Added Supportforce Case Number to where condition to skip Cases transfered to Supportforce. -- Sreedhar
            List<Contact> contacts = [select id,name,
                                        (select id,DJC_Is_Survey_Email_Sent__c 
                                        from Cases where isClosed=true and status not in :StatusSetToExclude and ESDJC_Supportforce_Case_Number__c = null 
                                        order by ClosedDate desc limit :surveyEmailFrequency) 
                                     from Contact where id IN :contactIdToClosedCaseIdMap.keySet()];

            List<String> e2cMails = new List<String>();
            for (CSAT_Emails_Exclusion_Settings__c cs : CSAT_Emails_Exclusion_Settings__c.getAll().values()) {
                e2cMails.add(cs.E2C_Email__c);
            }
            
            for(Case c : newRecords){
                newRecordIds.add(c.Id);
            }
            
            for(EmailMessage emsgs : [select Id, ParentId from EmailMessage where ParentId IN :newRecordIds AND ToAddress IN :e2cMails]){
                benefitAndTerminatedCaseIds.add(emsgs.parentId);
            }

            for (Contact aContact: contacts){
                boolean shouldSendSurvey = true;                    
                for (Case c : aContact.cases){
                    if (c.DJC_Is_Survey_Email_Sent__c || benefitAndTerminatedCaseIds.contains(c.Id)){
                        shouldSendSurvey = false;
                        break;                          
                    }
                }
                //If user give 0 as frequency then the intention is not send survey email at all.But SOQL Limit 0 doesnt fetch any recs.So manual override.
                if(surveyEmailFrequency == 0){
                  shouldSendSurvey = false;                 
                }
                if (shouldSendSurvey){
                    caseNotificationEvents.add(new caseNotificationEvent__e(caseId__c =contactIdToClosedCaseIdMap.get(aContact.id),IsSurvey__c = true));
                }else{
                    caseNotificationEvents.add(new caseNotificationEvent__e(caseId__c =contactIdToClosedCaseIdMap.get(aContact.id),IsSurvey__c = false));
                }
            } 
                publishClosedCaseNotificationEvents(caseNotificationEvents);
        }
    }

        /**
* @description Method to create the different tasks for the case Relocations recordtype
* @param the userId from the profile page.
* @return list of workbadge.
* @story W-10082027
**/
    public static void insertTasksForCaseRelocations(List<Case> newCases){    
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Relocations').getRecordTypeId();
        Id taskQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'ES_GOC_Task'].id;
        List<PF_CaseRelocationTasks__mdt> caseRelocationTasks = [SELECT RecordTypeId__c,TaskDescription__c,Task_Order__c FROM PF_CaseRelocationTasks__mdt ORDER BY Task_Order__c ASC ];
        List<task> taskList = new List<task>();
        for (Case c : newCases) {
            if (c.recordTypeId == recordTypeId && caseRelocationTasks.size()>0 && taskQueueId!=null){
                for (PF_CaseRelocationTasks__mdt caseRelocationTask : caseRelocationTasks){
                    if (caseRelocationTask.RecordTypeId__c!=null && caseRelocationTask.TaskDescription__c!=null){
                        taskList.add(taskCreation(c,caseRelocationTask.TaskDescription__c,caseRelocationTask.RecordTypeId__c,taskQueueId));
                    }
                }      
            }
        }
        if (taskList.size()>0){
            Database.SaveResult[] srList = Database.insert(taskList,false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    for (Database.Error objErr : sr.getErrors()) {
                        PF_Logger.log('SCC','ERROR',objErr.getMessage(),String.valueof(objErr.getStatusCode()),' Error during TaskRecordsForRelocation Insert ' + sr.getId() + ' UserId '+ UserInfo.getUserId(), 'Tasks');  
                    }
                }
            }
            if (!PF_Logger.logs.isEmpty()){
                PF_Logger.createLogs(PF_Logger.logs);
            }
        }
    }
    
    /**
* @description Method to create the Tasks based on the relocation case
* @param caseinstance and subject of the taks and the recordtype
* @return return the task creation object.
* @story W-10082027
**/
    public static task taskCreation(Case currentCase,String subject,ID taskRecordTypeId,ID taskQueueId){
        Task tsk = new Task();
        tsk.Subject = subject;
        tsk.Status = 'Not Started';
        tsk.Priority = 'Normal';
        tsk.WhoId = currentCase.ContactId;
        tsk.WhatId = currentCase.ID;
        tsk.OwnerId = taskQueueId;
        tsk.recordTypeId = taskRecordTypeId;
        return tsk;
    }
            

    public static void notifyOnCaseCommentAndUpdateReadyToClose(Map<Id, Case> newCasesMap, Map<Id, Case> oldCasesMap, Map<Id, Case> contactCaseMap) {
        List<Messaging.Singleemailmessage> mails = new List<Messaging.Singleemailmessage>();
        String orgWideEmailAddress = settings.ES_Support_Org_Wide_Email_Id__c;

        if (orgWideEmailAddress == null) {
            system.debug('Org wide email address of ES Support Email-to-Case Box is NOT updated in the custom settings');
            return;
        }
        List<String>excludedRecordTypes = system.label.DJC_Excluded_RecordTypes_For_Email_Notification.split(','); 
        Map<String,String> excludedRecordTypeMap = new Map<String,String>();
        for(String excludedRecordTypeDeveloperName : excludedRecordTypes){
            excludedRecordTypeMap.put(excludedRecordTypeDeveloperName,excludedRecordTypeDeveloperName);
        } 
        Map<Id,RecordType> excludedrecordtypeIds = new map<Id,RecordType>([SELECT Id FROM RecordType WHERE DeveloperName =:excludedRecordTypeMap.keyset()]);

        for (Case c : newCasesMap.values()) {
            if (oldCasesMap != null && oldCasesMap.get(c.Id) != null 
                && c.ESDJC_Supportforce_Case_Number__c == null
                && oldCasesMap.get(c.Id).ES_DJC_Last_Comment__c != c.ES_DJC_Last_Comment__c 
                && c.ContactId != null 
                && (settings.Portal_User_Profile_Id__c == null || !UserInfo.getProfileId().contains(settings.Portal_User_Profile_Id__c))
                && (settings.Concierge_API_User_Profile_Id__c == null || !UserInfo.getProfileId().contains(settings.Concierge_API_User_Profile_Id__c))
                && !excludedrecordtypeIds.containsKey(c.RecordTypeId)) {
                //Uncheck Ready to Close    
                   c.ES_DJC_Is_Ready_to_close_case__c = false;
                if (contactCaseMap != null && contactCaseMap.get(c.Id) != null) {
                    
                    Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();

                    if(c.Type == 'Education Reimbursement Request' || c.Type == 'Wellness Reimbursement Request'){
                        mail.setTemplateId(ESDJC_Util.getEmailTemplate('ES_Concierge_Case_Comment_Notification_No_Button').Id);
                    }else{
                        mail.setTemplateId(ESDJC_Util.getEmailTemplate('ES_Concierge_Case_Comment_Notification').Id);
                    }
                    mail.setTargetObjectId(c.ContactId);
                    mail.setOrgWideEmailAddressId(orgWideEmailAddress);
                    mail.setWhatId(c.Id);
                    mail.setSaveAsActivity(false);
                    mails.add(mail);
                    }
                }
            }
            if (!mails.isEmpty()) {
                Messaging.sendEmail(mails);
            }
        }

    /**
     ** Update case tier if owner was changed manually
     */
     public static void updateTierIfOwnerHasChanged(List<Case> newCases, Map<Id, Case> oldMap) {
        if (newCases != null) {
            if (ownerMap == null || isOwnerChangedByOtherProcess(newCases)) {
                fetchCaseOwnerUserDetails(newCases);
            }
            Map<Case, String> casesToRoleQueueMap = new Map<Case, String>();
            Map<Id, List<Case>> queueIdToCases = new Map<Id, List<Case>>();
            for (Case c : newCases) {
                // Update the tier if any one of the condition is satisfied
                // 1. If it is a case created by a console user, tier will be updated
                //    if one is assigned to user's role 
                //    (Portal user and Concierge user are not considered)
                // 2. If a case's owner has changed (in case of escalation by clicking on Escalate button,
                //    owner is same and tier is different at this point, hence it will fail) 
                //    by manually changing the owner, owner is different, but tier is the same
                //    so, the if condition will pass and assign owner's tier
                // NOTE: In the above cases, owner id should not be null
                // If the case is created through web-to-case, owner is null.

                String profileId = UserInfo.getProfileId();
                if (c.OwnerId != null 
                    && (settings.djc_Helpdesk_API_User__c == null || !UserInfo.getUserId().contains(settings.djc_Helpdesk_API_User__c))
                    && (settings.Portal_User_Profile_Id__c == null || !profileId.contains(settings.Portal_User_Profile_Id__c))
                    && (settings.Concierge_API_User_Profile_Id__c == null || !profileId.contains(settings.Concierge_API_User_Profile_Id__c))
                    && (c.Id == null || (oldMap.containsKey(c.Id) && c.OwnerId != oldMap.get(c.Id).OwnerId
                        && c.Tier__c == oldMap.get(c.Id).Tier__c))) {
                    //If owner is a queue, get the queue names
                    String ownerId = c.OwnerId;
                    if (ownerId.startsWith('005')) {
                        if (ownerMap.containsKey(c.OwnerId) && ownerMap.get(c.OwnerId).UserRole.Name != null) {
                            casesToRoleQueueMap.put(c, ownerMap.get(c.OwnerId).UserRole.Name);
                        } else {
                            c.Tier__c = 'Unknown';
                        }
                    } else {
                        if (!queueIdToCases.containsKey(c.OwnerId)) {
                            queueIdToCases.put(c.OwnerId, new List<Case>());
                        }
                        queueIdToCases.get(c.OwnerId).add(c);
                    }
                }
            }

            if (!queueIdToCases.isEmpty()) {
                //Get queue names
                for (Group g : [select Id, Name from Group where Id IN :queueIdToCases.keySet()]) {
                    for (Case c : queueIdToCases.get(g.Id)) {
                        casesToRoleQueueMap.put(c, g.Name);
                    } 
                }
            }

            if (!casesToRoleQueueMap.isEmpty()) {
                Map<String, Map<String, String>> tierMap = new Map<String, Map<String, String>>();
                for (DJC_Case_Tier_Reporting__mdt c : [select Role_Queue_Name__c, Tier__c, Type__c from DJC_Case_Tier_Reporting__mdt where Role_Queue_Name__c IN :casesToRoleQueueMap.values()]) {
                    system.debug('Tier Reporting is not null');
                    if (!tierMap.containsKey(c.Type__c)) {
                        tierMap.put(c.Type__c, new Map<String, String>());
                    }
                    tierMap.get(c.Type__c).put(c.Role_Queue_Name__c, c.Tier__c);
                }

                for (Case c : casesToRoleQueueMap.keySet()) {
                    String roleOrQueueName = casesToRoleQueueMap.get(c);
                    String ownerId = c.OwnerId;

                    if (ownerId.startsWith('005')) {
                        if (tierMap.containsKey('Role') && tierMap.get('Role').containsKey(roleOrQueueName)) {
                            c.Tier__c = tierMap.get('Role').get(roleOrQueueName);
                            } else {
                            //If tier is not found, update tier to unknown
                            c.Tier__c = 'Unknown';
                        }
                        } else {
                            if (tierMap.containsKey('Queue') && tierMap.get('Queue').containsKey(roleOrQueueName)) {
                                c.Tier__c = tierMap.get('Queue').get(roleOrQueueName);
                                } else {
                            //If tier is not found, update tier to unknown
                            c.Tier__c = 'Unknown';
                        }
                    }
                    String oldTier = (oldMap == null) ? null:oldMap.get(c.id).Tier__c;
                    if (c.Tier__c != null && oldTier != c.Tier__c 
                        && (oldTier == 'Tier 1' || (oldTier == 'Tier 2' && c.Tier__c == 'Tier 3'))) {
                        //Update escalated by
                        c.ES_DJC_Case_Escalated_By__c = UserInfo.getName();
                        c.Status = 'Escalated';
                    }
                }
            }
        }
    }

    private static Map<id, sobject> getValidCaseRecordType(){
        if (validCaseRecordTypes == null){
            String validRTSOQL = 'select id, developername from RecordType where developername in '+ System.Label.ES_DJC_ValidationsCheck_SOQL;
            validCaseRecordTypes = new Map<Id,sObject>(Database.query(validRTSOQL));                                        
        }
        return  validCaseRecordTypes;
    }

    private static boolean isOwnerChangedByOtherProcess(List<Case> newCases) {
        // If the owner was changed by workflows or other process, 
        // then the user record will be missing in owner map
        if (ownerMap != null) {
            for (Case c : newCases) {
                String ownerId = c.OwnerId;
                if (ownerId != null && ownerId.startsWith('005') && !ownerMap.containsKey(ownerId)) {
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    /*Approve all related claims when case status is set to Approved*/

    public static void approveWellnessReimbursementClaims(List<Case> cases,Map<Id,Case> oldCasesMap){
        Set<Id> approvedCaseSet = new Set<Id>();
        Set<Id> casesNotToProcessSet = new Set<Id>();
        List<DJC_Wellness_Reimbursement_Claim__c> updatedClaims = new List<DJC_Wellness_Reimbursement_Claim__c>();
        Map<Id,List<DJC_Wellness_Reimbursement_Claim__c>> caseToClaimsMap = new Map<Id,List<DJC_Wellness_Reimbursement_Claim__c>>();
        for(Case c : cases){
            if((c.type == 'Wellness Reimbursement Request' || c.type == 'Education Reimbursement Request') && c.status == 'Approved' && oldCasesMap.get(c.Id).Status!='Approved'){
                approvedCaseSet.add(c.Id);
            }
        }
        if(!approvedCaseSet.isEmpty()){
            //get all claims related to approved cases .. 
            for(DJC_Wellness_Reimbursement_Claim__c claim : [select Id,DJC_Wellness_Case__c,DJC_Wellness_Request_Status__c from DJC_Wellness_Reimbursement_Claim__c where  DJC_Wellness_Case__c in : approvedCaseSet order by DJC_Wellness_Request_Status__c ]){
                
                if(claim.DJC_Wellness_Request_Status__c == 'Rejected'){//do not process for rejected claims.. 
                    casesNotToProcessSet.add(claim.DJC_Wellness_Case__c);
                }
                if(claim.DJC_Wellness_Request_Status__c != 'Approved'){
                  claim.DJC_Wellness_Request_Status__c = 'Approved';
                  if(caseToClaimsMap.get(claim.DJC_Wellness_Case__c) == null){
                    caseToClaimsMap.put(claim.DJC_Wellness_Case__c,new List<DJC_Wellness_Reimbursement_Claim__c>{claim});
                 } else {
                    List<DJC_Wellness_Reimbursement_Claim__c> claimsHolder = caseToClaimsMap.get(claim.DJC_Wellness_Case__c);
                    claimsHolder.add(claim);
                    caseToClaimsMap.put(claim.DJC_Wellness_Case__c,claimsHolder);
                 }
              } 
            }
            
            //remove entries from map, where keyset is in casesNotToProcessSet.. 
            for(Id caseId : casesNotToProcessSet){
                caseToClaimsMap.remove(caseId);
            }
            //throw error for all cases which have atleast one of the related claim status is Rejected . 
            for(Case c : cases){
                if(casesNotToProcessSet.contains(c.Id)){
                     c.addError(System.Label.DJC_Wellness_Set_Partial_Payment);
                }
            }
            //update claims where related case is not errored out.. 

            for(List<DJC_Wellness_Reimbursement_Claim__c> claims : caseToClaimsMap.values() ){
                updatedClaims.addAll(claims);
            }

            if(!updatedClaims.isEmpty()){
                update updatedClaims; 
            }
        }
    }

    /*Calculate Tier age when case is closed..*/

    public static void calculateTier_1_to_4_Ages(List<Case> cases,Map<Id,Case> oldCaseMap){
        Set<Id> validCaseIds = new Set<Id>();
        ESDJC_TierAgeHelper tHelpInstance = new ESDJC_TierAgeHelper();
        for(Case c : cases){
            if(c.origin!=null && c.status!=oldCaseMap.get(c.Id).status && c.status.contains('Closed') && c.Tier__c!=null && c.Tier__c!='Unknown'){
                validCaseIds.add(c.Id); 
            }
        }
        if(!validCaseIds.isEmpty() && !System.isFuture() && !System.isBatch()){
            ESDJC_TierAgeHelper.updateCaseTierAgesOnClosed(validCaseIds);
        }
    }

    /*Update owner suportgroup field on owner updates..  */
     public static void updateSuportOwnerGroup(List<Case> cases, Map<Id,Case> oldCaseMap){
        List<ESDJC_Owner_Support_Group__c> supportOwnerSettings = ESDJC_Owner_Support_Group__c.getAll().Values(); 
        Map<Id,String> ownerGroupMap = new Map<Id,String>();
         Set<Id> userOwnerSet = new Set<Id>();
         Map<Id,Id> ownerRoleMap = new Map<Id,Id>();
        if(supportOwnerSettings.isEmpty()){
            return; //since the entire logic is data driven, we don't want to process any further. 
        } else {
            for(ESDJC_Owner_Support_Group__c oGroup : supportOwnerSettings){
                if(oGroup.QueueId__c!=null){
                    ownerGroupMap.put(oGroup.QueueId__c,oGroup.Support_Group__c);
                } 
                if(oGroup.RoleId__c!=null){
                     ownerGroupMap.put(oGroup.RoleId__c,oGroup.Support_Group__c);
                }
            }
        }
         for(Case c : cases){
             //if owner is user, then get roleId.. 
             if(c.ownerId!=null && String.valueOf(c.ownerId).startsWith('005')){
                 userOwnerSet.add(c.OwnerId);
             } 
         }
         for(User u : [select Id,userRoleId from User where id in : userOwnerSet]){
             ownerRoleMap.put(u.Id,u.UserRoleId);
         }
         
         for(Case c : cases){
             if(c.ownerId!=null && (oldCaseMap == null || (oldCaseMap!=null && c.ownerId!=oldCaseMap.get(c.Id).ownerId))){
                 //if owner is user, then get suport group from ownerRoleMap, else get it from ownerGroupMap.. 
                 if( (String.valueOf(c.ownerId)).startsWith('005')  &&  ownerRoleMap.get(c.ownerId)!=null && (ownerGroupMap.get(ownerRoleMap.get(c.ownerId))!=null)){
                     c.Owner_Support_Group__c =  ownerGroupMap.get(ownerRoleMap.get(c.ownerId));  
                 } else if(ownerGroupMap.get(c.ownerId)!=null){
                      c.Owner_Support_Group__c = ownerGroupMap.get(c.ownerId);
                 } else {
                      c.Owner_Support_Group__c = null;
                 }
             }
         }
     }

      public static void verifySubtopicSize(List<Case> newCases, Map<Id,Case> oldCases) {
     
     String caseRT;
     Set<String> setRT;
     if(settings!=null){
         caseRT = settings.Case_Subtopic_Size_RT_Restriction__c;
         if(caseRT!=null){
         setRT = new Set<String>(caseRT.split(','));
         }
         else{
         setRT = new Set<String>();
         }
       }  
         Map<ID, Schema.RecordTypeInfo> caseRtType = Schema.SObjectType.Case.getRecordTypeInfosById();
         
         for(Case newCase:newCases){
             if(newCase.RecordTypeId != null){
                 String type = caseRtType.get(newCase.RecordTypeId).getName();
                 
                 if(!setRT.contains(type)){
                     
                     if(newCase.ES_DJC_Sub_Topic__c != null && newCase.ES_DJC_Sub_Topic__c.countMatches(';') > 0
                        && (oldCases == null
                            || !oldCases.containsKey(newCase.Id)
                            || oldCases.get(newCase.Id).ES_DJC_Sub_Topic__c == null
                            || oldCases.get(newCase.Id).ES_DJC_Sub_Topic__c != newCase.ES_DJC_Sub_Topic__c)){
                                newCase.addError(Label.ESDJC_Subtopic_only_one_option_error);
                            }
                 }      } 
         }
      
     }
	
    public static void updateCaseResponseFlag(Set<Id> caseIds){
        
        if(caseIds == null || caseIds.isEmpty()){
            return;
        }
        
        Set<Id> idsCasesUpdated = new Set<Id>();
        
        List<Case> cases = [SELECT Id, ES_DJC_Is_Ready_to_close_case__c, First_Response_Flag__c, Status
                            FROM Case WHERE id IN :caseIds and First_Response_Flag__c = false and IsClosed = false and Valid_SLA_Origin__c = true];
        
        for(Case c : cases){
            
            c.First_Response_Flag__c = true;
            c.ES_DJC_SLA_Expiration_Warning__c=false;
            c.ES_DJC_First_Response_Date_Time__c = System.now();
            
            idsCasesUpdated.add(c.Id);
        }
        
        List<CaseMilestone> milestones = [SELECT ID, CompletionDate, CaseId 
                                          FROM CaseMilestone WHERE CaseId IN : idsCasesUpdated AND IsCompleted = false];
        
        for(CaseMilestone milestone : milestones){
            milestone.CompletionDate = System.now();
        }
        
        Savepoint sp = Database.setSavePoint();
        
        try{
            update milestones;
            update cases;
        }
        catch (Exception e){
            Database.rollback(sp);
        }
    }

     public static void setupReimbursementCases(List<Case> newRecords){

        List<DJC_Reimbursement_Total_Claimed__c> totals = new List<DJC_Reimbursement_Total_Claimed__c>();
        List<List<sObject>> caseTotalsAssociations = new List<List<sObject>>();
        List<String> groupIds = new List<String>();
        Map<Id,List<String>> groupIdsPerCase = new Map<Id,List<String>>();
        List<Integer> policyIds = new List<Integer>();
        List<Integer> categoryIds = new List<Integer>();
        List<Reimbursement_Case_Totals_Claimed__c> associations = new List<Reimbursement_Case_Totals_Claimed__c>();

        for(Case c:newRecords){
            if(c.Type == 'Wellness Reimbursement Request' || c.Type == 'Education Reimbursement Request'){
                policyIds.add(c.Reimbursement_Policy_Id__c.intValue());
                categoryIds.add(c.Reimbursement_Category_Id__c.intValue());
            }
        }

         Map<Integer, Reimbursement_Policy__mdt> policies = new Map<Integer, Reimbursement_Policy__mdt>();
         Map<Integer, Reimbursement_Category__mdt> categories = new Map<Integer, Reimbursement_Category__mdt>();
        
         for(Reimbursement_Policy__mdt policy : [SELECT Id__c, Active__c, Country__c, Currency__c, Organization__c FROM Reimbursement_Policy__mdt WHERE Id__c IN :policyIds]){
             policies.put(policy.Id__c.intValue(), policy);
         }
         
         for(Reimbursement_Category__mdt category : [SELECT Id__c, Group__c, MasterLabel FROM Reimbursement_Category__mdt WHERE Id__c IN :categoryIds]){
             categories.put(category.Id__c.intValue(), category);
         }
         
        for(Case c:newRecords){
            if(c.Type == 'Wellness Reimbursement Request' || c.Type == 'Education Reimbursement Request'){

                String division = c.Division__c == null ? c.Division_Lookup__c : c.Division__c;
                DJC_Region region = DJC_Wellness_Util.getRegion(division);
                DJC_WellnessManagerFactory wellnessManagerFactory = DJC_WellnessManagerFactory.getInstance(region, policies.get(c.Reimbursement_Policy_Id__c.intValue()), categories.get(c.Reimbursement_Category_Id__c.intValue()), c.Contact);
                DJC_TimeRangeManager timeRangeManager = wellnessManagerFactory.getTimeRangeManager();
                Date createdDate = Date.newInstance(c.CreatedDate.year(), c.CreatedDate.month(), c.CreatedDate.day());

                List<String> groupIdsCase = new List<String>();

                groupIdsCase.add(c.ContactId + ';' + timeRangeManager.getCurrentTimeRange(createdDate) + ';' + c.Reimbursement_Policy_Id__c + ';Submitted');
                groupIdsCase.add(c.ContactId + ';' + timeRangeManager.getCurrentTimeRange(createdDate) + ';' + c.Reimbursement_Policy_Id__c + ';Approved');

                if(c.Type == 'Wellness Reimbursement Request'){
                    groupIdsCase.add(c.ContactId + ';' + timeRangeManager.getPreviousTimeRange(createdDate) + ';' + c.Reimbursement_Policy_Id__c + ';Submitted');
                    groupIdsCase.add(c.ContactId + ';' + timeRangeManager.getPreviousTimeRange(createdDate) + ';' + c.Reimbursement_Policy_Id__c + ';Approved');
                }

                groupIdsPerCase.put(c.Id, groupIdsCase);
                groupIds.addAll(groupIdsCase);
            }
        }

        List<DJC_Reimbursement_Total_Claimed__c> totalsClaimed = [SELECT Id, Group_Id__c FROM DJC_Reimbursement_Total_Claimed__c WHERE Group_Id__c IN :groupIds];
         
        Map<String,DJC_Reimbursement_Total_Claimed__c> existingTotals = new Map<String,DJC_Reimbursement_Total_Claimed__c>();

        for(DJC_Reimbursement_Total_Claimed__c totalClaimed : totalsClaimed){
            existingTotals.put(totalClaimed.Group_Id__c, totalClaimed);
        }

        for(Case c:newRecords){
            if(c.Type == 'Wellness Reimbursement Request' || c.Type == 'Education Reimbursement Request'){
                
                List<String> groupIdsCase = groupIdsPerCase.get(c.Id);
                
                for(String groupId : groupIdsCase){

                    if(!existingTotals.containsKey(groupId)){

                        List<String> parameters = groupId.split(';');

                        DJC_Reimbursement_Total_Claimed__c totalClaimed = new DJC_Reimbursement_Total_Claimed__c(
                        Contact__c = c.ContactId, currencyIsoCode = c.CurrencyIsoCode, Reimbursement_Policy_Id__c = c.Reimbursement_Policy_Id__c, Status__c = parameters.get(parameters.size() - 1), Period__c = parameters.get(1));

                        totals.add(totalClaimed);
                        caseTotalsAssociations.add(new sObject[]{totalClaimed, new Reimbursement_Case_Totals_Claimed__c(Case__c = c.Id)});
                        existingTotals.put(groupId, totalClaimed);
                    }else{
                        DJC_Reimbursement_Total_Claimed__c totalClaimed = existingTotals.get(groupId);
                        caseTotalsAssociations.add(new sObject[]{totalClaimed, new Reimbursement_Case_Totals_Claimed__c(Case__c = c.Id)});
                    }

                }
            }
        }
        
         if(!totals.isEmpty()){
            INSERT totals;
         }

        for(List<sObject> item : caseTotalsAssociations){
            DJC_Reimbursement_Total_Claimed__c totalsItem = (DJC_Reimbursement_Total_Claimed__c)item.get(0);
            Reimbursement_Case_Totals_Claimed__c association = (Reimbursement_Case_Totals_Claimed__c)item.get(1);
            
            association.Total_Claimed__c = totalsItem.Id;
            associations.add(association);
        }
        
         if(!associations.isEmpty()){
             INSERT associations;
         }

     }

     // Case notications emails send on 7, 14, 17, 20 days after Package case opened 
     // and Package is not collected (Case is not closed)
     // Requirement says, Email should captured in Case Emails, Tried workflow, emails sent through email alerts are not logged as case emails
     public static void sendPackageReminderNotifications(Map<Id, Case> oldCasesMap,  Map<Id, Case> newCasesMap){
        Id packageRecardType = Schema.SObjectType.Case.RecordTypeInfosByName.get('All REWS Package Management').RecordTypeId;
        List<Case> casePackageReminderNotifications = new List<Case>();
        for(Id caseId: oldCasesMap.keySet()){
            if(newCasesMap.get(caseId).RecordTypeId == packageRecardType &&
                newCasesMap.get(caseId).REWS_Reminder_Notification_Trigger__c != oldCasesMap.get(caseId).REWS_Reminder_Notification_Trigger__c &&
                (newCasesMap.get(caseId).REWS_Reminder_Notification_Trigger__c != null || newCasesMap.get(caseId).REWS_Reminder_Notification_Trigger__c != '')
            ){
                casePackageReminderNotifications.add(newCasesMap.get(caseId));
            }
        }
        if(casePackageReminderNotifications.size() > 0){
            EmailTemplate emailTemplte = ESDJC_Util.getEmailTemplate('REWS_Package_Reminder_Notifications');
            ESDJC_CaseHandler.sendEmails(casePackageReminderNotifications, emailTemplte.Id);
        }
     }

    // Added future method to send emails with after update value. 
    // Without future annontation emails are sent before data is commited to database. Email will show old status.
    public static void sendEmails(List<Case> sendEmailsToTheseCases, Id templateId){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for(Case c: sendEmailsToTheseCases){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(c.contactId);
                mail.setTemplateId(templateId);
                mail.setWhatId(c.id);
                mail.OrgWideEmailAddressId=REWS_Setting__c.getInstance().Mail_services_Orgwide_email__c;
                emails.add(mail);
        }
        if(emails.size()>0){
         Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emails, false);
      }
    }

    public static void calculateExpectedDateOfApproval(List<Case> cases){
        for(Case c : cases){
            if(c.type == 'Wellness Reimbursement Request' || c.type == 'Education Reimbursement Request'){
                calculateReimbursementCaseExpectedDateOfApproval(c);
            }
        }
    }

    private static void calculateReimbursementCaseExpectedDateOfApproval(Case c){

        Datetime createdDate = System.now();
        
        if(Test.isRunningTest()){
            createdDate = Test_Wellness_Util.testDate;
        }
        
        DJC_Division division = DJC_Division.getDivisionByName(c.Division__c);
        createdDate = createdDate.addDays(1); //Initially, approval date should be one day after creation

        //If approval day is Saturday or Sunday, it has to be moved to next Monday
        String approvalDay = createdDate.format('EEEE', division.timeZoneKey);

        if(approvalDay == 'Saturday'){
            createdDate = createdDate.addDays(2);
        }else if(approvalDay == 'Sunday'){
            createdDate = createdDate.addDays(1);
        }

        //If approval hour is before 13, case will be approved in the morning.  Otherwise it
        //will be approved in the afternoon.
        Integer approvalHour = Integer.valueOf(createdDate.format('HH', division.timeZoneKey));
        Integer approvalMinute = Integer.valueOf(createdDate.format('mm', division.timeZoneKey));

        Datetime approvalDate = createdDate;
        if(approvalHour < 13){
            approvalDate = approvalDate.addHours(9 - approvalHour + Integer.valueOf(Math.random() * 4));
        }else{
            approvalDate = approvalDate.addHours(13 - approvalHour + Integer.valueOf(Math.random() * 5));
        }

        //Set a random approval minute
        c.DJC_reimb_expected_date_of_approval__c = approvalDate.addMinutes(-approvalMinute + Integer.valueOf(Math.random() * 60));
    }
    
    //Method to pause the SLA clock if status changed to "Waiting for Response - External"
    public static void updateSLAClock(Map<Id, Case> newCasesMap,  Map<Id, Case> oldCasesMap){
        String WAITING = 'Waiting for Response - External';
        for(Id caseId : oldCasesMap.keySet()){
            String oldStatus = oldCasesMap.get(caseId).Status;
            String newStatus = newCasesMap.get(caseId).Status;
            if(oldStatus != WAITING && newStatus == WAITING){
                newCasesMap.get(caseId).isStopped = true;
            }else if(oldStatus == WAITING && newStatus != WAITING){
                newCasesMap.get(caseId).isStopped = false;
            }
        }

    }

    //Method to pause the SLA clock if status changed to "Waiting for Response - External"
    public static void updateSLAClock(List<Case> newCases){
        String WAITING = 'Waiting for Response - External';
        for(Case currCase : newCases){
            if(currCase.Status == WAITING){
                currCase.isStopped = true;
            }else{
                currCase.isStopped = false;
            }
        }

    }

    //Method to populate ER Division to implement Case Sharing
    public static void setERDivision(List<Case> newList){

        Set<Id> ERRecTypeIds = new Set<Id>();
    Set<String> ERTypes = new Set<String>();
        List<Case> ERCaseList = new List<Case>();

        String queryString = 'select Id from RecordType where Developername IN '+ System.Label.ES_DJC_ER_SOQL;
        
        for(SObject recType : Database.query(queryString)){

            ERRecTypeIds.add(recType.Id);

        }
    
    String erType = System.Label.ES_DJC_ER_Type;

        for(String str : erType.split(',')){

            ERTypes.add(str);
        }

        if (!ERRecTypeIds.isEmpty()){

            for(Case c : newList){
                
                Boolean isERRecordTypeId = ERRecTypeIds.contains(c.RecordTypeId);
        Boolean isERCaseType = ERTypes.contains(c.Type);

                if(isERRecordTypeId || isERCaseType){
                   ERCaseList.add(c);
                }
            }
        }
    
    if (!ERCaseList.isEmpty()){

            for(Case c : ERCaseList){
            
                String division = c.Division_Lookup__c;

                if(division != NULL){

                    if(division.equalsIgnoreCase('Americas - USA') || 
                       division.equalsIgnoreCase('Americas - Canada')){

                        c.ER_Division__c = 'Americas';

                    }else if(division.equalsIgnoreCase('Americas - Latin America') || 
                       division.equalsIgnoreCase('EMEA - All Countries')){

                        c.ER_Division__c = 'EMEA';

                    }else if(division.startsWithIgnoreCase('APAC')){

                        c.ER_Division__c = 'APAC';

                    }else{

                        c.ER_Division__c = 'Japan';
                    }
                }
            }
        }
    }
    //Method to populate Fiscal Quarter Fields
    public static void populateFiscalQuarter(List<Case> newList){

        Set<Id> RecTypeIds = new Set<Id>();
        List<Case> caseList = new List<Case>();

        String queryString = 'select Id from RecordType where Developername IN '+ System.Label.ES_DJC_CRT;
        
        for(SObject recType : Database.query(queryString)){

            RecTypeIds.add(recType.Id);

        }
            
        if (!RecTypeIds.isEmpty()){

            for(Case c : newList){
                
                Boolean isValidRecordType = RecTypeIds.contains(c.RecordTypeId);

                if(isValidRecordType){
                   caseList.add(c);
                }
            }
        }
    
        if (!caseList.isEmpty()){

            for(Case c : caseList){
                
                if(c.DJC_ER_Date_Reported__c != NULL){
                    Date reportedDate = c.DJC_ER_Date_Reported__c;
                    c.Date_Reported_Qtr__c = getQuarter(reportedDate);
                }
                
                if(c.GEI_Investigation_Date_Closed__c != NULL){
                    Date investigationCloseDate = c.GEI_Investigation_Date_Closed__c;
                    c.GEI_Investigation_Date_Closed_Qtr__c = getQuarter(investigationCloseDate);
                }           
            }
        }
    }

    //Method to calculate Quarter
    public static String getQuarter(Date targetDate){
    
        String result, output;

        if(targetDate != NULL){
            
            Integer month = targetDate.month();
            String quarter = '';
            Integer year;

            if ((month == 1) || (month >= 11)){
                quarter = 'Q4';
            } else if (month <= 4){
                quarter = 'Q1';
            } else if (month <= 7){
                quarter = 'Q2';
            } else if (month <= 10){
                quarter = 'Q3';
            }

            year = (month == 1? targetDate.year() : targetDate.year() + 1);

            result = String.format('{0}-{1}', new String[]{quarter, String.valueOf(year)});

        }
    
        output = 'FY-' + result;
          
        return output;
      
    }

    public static void validateGEICaseClosure(List<Case> cases, Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Id GEICaseRecordTypeId = [Select Id from RecordType where DeveloperName = 'Global_Ethics_Integrity'].Id;
        for(Case c : cases){
            if(c.RecordTypeId == GEICaseRecordTypeId && (newCaseMap.get(c.Id).Status != oldCaseMap.get(c.Id).Status) && c.Status == 'Closed'){
                caseMap.put(c.Id, c);
            }
        }

        for(Case c : [Select Id, (Select Id, Root_Cause__c from Allegations__r where Root_Cause__c = null and RecordType.DeveloperName = 'GE_I_Allegations') from Case where Id in: caseMap.keySet()]){
            if(c.Allegations__r.size()>0){
                newCaseMap.get(c.Id).addError(System.Label.ESDJC_GEI_Case_Allegation_Closure_Error);
            }
        }
    }

    public static void validateWarmlineCaseClosure(List<Case> cases, Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
    
        Set<Id> caseIds = new Set<Id>();
        Set<Id> caseIdsWithNoWarmlineRec = new Set<Id>();
        Map<Id,Integer> casesWithWarmLineCountMap = new Map<Id,Integer>();
        Map<Id,List<Warmline__c>> caseToWarmLineMap = new Map<Id,List<Warmline__c>>();
        
        for(Case c : cases){
            if(c.RecordTypeId == warmlineCaseRecordTypeId && (newCaseMap.get(c.Id).Status != oldCaseMap.get(c.Id).Status) && c.Status == 'Closed'){
                caseIds.add(c.Id);
            }
        }
        
        if(!caseIds.isEmpty()){

            for(Warmline__c warmLineRec : [ Select Id,Case__c ,Engage_Stakeholders__c,Recommendations__c,
                                            Disposition__c,Primary_Topic__c,Connect_Date_Time__c from Warmline__c 
                                            where Case__c IN: caseIds]){
            
                if(warmLineRec != null){

                    if(!caseToWarmLineMap.containskey(warmLineRec.Case__c))
                        caseToWarmLineMap.put(warmLineRec.Case__c,new List<Warmline__c>()); 
                          
                    caseToWarmLineMap.get(warmLineRec.Case__c).add(warmLineRec);
                }
            }

            for (AggregateResult ar : [ Select Case__c, count(Id) cnt FROM Warmline__c where Case__c IN: caseIds 
                                        group by Case__c]){
                 
                casesWithWarmLineCountMap.put(Id.valueOf(String.valueOf(ar.get('Case__c'))),Integer.valueOf(ar.get('cnt')));
                 
            }
                        
            for(Id caseId : caseIds){
                                
                if(!casesWithWarmLineCountMap.containskey(caseId)){
                    caseIdsWithNoWarmlineRec.add(caseId);
                }
            }                 
              
            if(!caseToWarmLineMap.isEmpty()){
                                
                for(Id caseId : caseToWarmLineMap.keySet()){
                                                                 
                    if(caseToWarmLineMap.get(caseId) != null){
                        
                        for(Warmline__c warmLineRec :caseToWarmLineMap.get(caseId)){
                            
                            Map<Id,String> sObjRecordError = ESDJC_Util.validateRequiredFields(Warmline__c.sObjectType,warmLineRec);
                            
                            if(sObjRecordError != null){

                                if(sObjRecordError.get(warmLineRec.Id) != null){
                                    
                                    newCaseMap.get(caseId).addError(sObjRecordError.get(warmLineRec.Id));
                                }
                            }                                
                        }                                                                                                                                                                      
                    }               
                }               
            }

            if(!caseIdsWithNoWarmlineRec.isEmpty()){
                                    
                for(Id caseId : caseIdsWithNoWarmlineRec){
                   
                    newCaseMap.get(caseId).addError(System.Label.ESDJC_Warmline_Case_Closure_Error);
                   
                }
            }
        }
    } 

    public static void sendWarmlineCaseNotifications(Map<Id, Case> oldCasesMap,  Map<Id, Case> newCasesMap){
        
        List<Case> warmlineCaseClosureNotifications = new List<Case>();
        
        for (Id caseId: oldCasesMap.keySet()) {
            if (newCasesMap.get(caseId).RecordTypeId == warmlineCaseRecordTypeId) {
                if (newCasesMap.get(caseId).Status != oldCasesMap.get(caseId).Status &&
                    (newCasesMap.get(caseId).Status == 'Closed')
                ) {
                    warmlineCaseClosureNotifications.add(newCasesMap.get(caseId));
                }
            }
        }
        
        if (warmlineCaseClosureNotifications.size() > 0) {
            EmailTemplate emailTemplte = ESDJC_Util.getEmailTemplate('Warmline_Case_Closure_Notification');
            ESDJC_CaseHandler.sendEmails(warmlineCaseClosureNotifications, emailTemplte.Id);
        }
     }

    /**
     * @param newMap new Cases State
     * @param oldMap old Cases State
     * @author Andrey Bury. Employee Engagement Team.
     * @date 4 Mar 2022
     * @description This method created as part of W-10704856 GUS Story. Used for populating
     * ESDJC_Waiting_For_Response_Start_Date__c Case Datetime Field when Case Status changed to
     * "Waiting for Response" and clear this field when Status changed from "Waiting for Response"
     */
    public static void populateWaitingForResponseStartDate(Map<Id, Case> newMap, Map<Id, Case> oldMap) {
        List<String> supportedRTIds = new List<String>();

        for (RecordTypeInfo rti: Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().values()) {
            if (!AUTO_RESPONSE_SUPPORTED_RT_DEV_NAMES.contains(rti.getDeveloperName())) continue;

            supportedRTIds.add(rti.getRecordTypeId());
        }

        for (Case c : newMap.values()) {
            if (!supportedRTIds.contains(c.RecordTypeId)) continue;

            if (oldMap.get(c.Id).Status == CASE_STATUS_WAITING_FOR_RESPONSE && c.Status != CASE_STATUS_WAITING_FOR_RESPONSE) {
                c.ESDJC_Waiting_For_Response_Start_Date__c = null;
                continue;
            }

            if (oldMap.get(c.Id).Status != CASE_STATUS_WAITING_FOR_RESPONSE && c.Status == CASE_STATUS_WAITING_FOR_RESPONSE) {
                c.ESDJC_Waiting_For_Response_Start_Date__c = Datetime.now();
            }
        }
    }
    public static void publishClosedCaseNotificationEvents(List<caseNotificationEvent__e> closedCaseNotifications){
        
        List<Database.SaveResult> results = EventBus.publish(closedCaseNotifications);
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    PF_Logger.log('ESDJC Case Handler','ERROR','Failure happen when publishing events','EVENT Error',err.getMessage(),'ESDJC Case Handler');
                }
            } 
        }
        if(!PF_Logger.logs.isEmpty()){
            PF_Logger.createLogs(PF_Logger.logs);
        }
    }
}