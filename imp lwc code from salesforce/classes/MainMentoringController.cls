public with sharing class MainMentoringController {
    // Retrieve current user's mentors based on mentoring match status
    //June_B_Deployment
    @AuraEnabled
    public static List<Mentoring_Match__c> retrieveMentorsFromOrg(String status){
        List<Mentoring_Match__c> mentoringMatches = [SELECT 
            Id, 
            Name, 
            Mentor__c, 
            Request_Message__c,
            Response_Message__c,
            Mentor__r.Name, 
            Mentor__r.Id, 
            Mentor__r.AboutMe, 
            Mentor__r.City, 
            Mentor__r.Email, 
            Mentor__r.MediumPhotoUrl, 
            Mentor__r.Title,
            Mentor__r.Hire_Date__c, 
            Mentor__r.Equality_Group_Member__c,
            Mentee__c,
            Mentee__r.Name, 
            Status__c,
            Score__c
            FROM Mentoring_Match__c WHERE Mentee__c =: UserInfo.getUserId() AND Status__c =: status WITH SECURITY_ENFORCED]; 
        return mentoringMatches;   
    }

    // Retrieve current user's mentees based on mentoring match status
    @AuraEnabled
    public static List<Mentoring_Match__c> retrieveMenteesFromOrg(String status){
       List<Mentoring_Match__c> mentoringMatches = [SELECT 
            Id, 
            Name, 
            Mentor__c, 
            Request_Message__c,
            Response_Message__c,
            Mentor__r.Name,
            Mentee__r.Name, 
            Mentee__r.Id, 
            Mentee__r.AboutMe, 
            Mentee__r.City, 
            Mentee__r.Email, 
            Mentee__r.MediumPhotoUrl, 
            Mentee__r.Title,
            Mentee__r.Hire_Date__c, 
            Mentee__r.Equality_Group_Member__c,
            Mentee__c, 
            Status__c,
            Score__c
            FROM Mentoring_Match__c WHERE Mentor__c =: UserInfo.getUserId() AND Status__c =: status WITH SECURITY_ENFORCED]; 
        return mentoringMatches;   
    }

    // Creates new mentor match
    @AuraEnabled
    public static Mentoring_Match__c createMentoringMatch(Id mentorId, Id menteeId, String status, String requestMessage, String responseMessage, Integer score, String removalReason, String removalInformation, String interestReason, String interestInformation){
        // Throw error if both menteeId and mentorId aren't provided
        if (mentorId == null && menteeId == null) {
            throw new AuraHandledException('Opps! Something went wrong: Please provide at least a menteeId or a mentorId');
        }

        // Either mentorId or menteeId should be the current user
        if (mentorId == null) {
            mentorId = UserInfo.getUserId();
        }
        if (menteeId == null) {
            menteeId = UserInfo.getUserId();
        }

        // Create mentoring match
        Mentoring_Match__c match = new Mentoring_Match__c();

        // Check if match exists already
        Integer matchCount = [SELECT count() FROM Mentoring_Match__c WHERE Mentor__c =: mentorId AND Mentee__c =: menteeId WITH SECURITY_ENFORCED];
        if (matchCount > 0) {
            match = [SELECT Id, Name, Mentor__c, Mentee__c, Status__c, Score__c FROM Mentoring_Match__c WHERE Mentor__c =: mentorId AND Mentee__c =: menteeId  WITH SECURITY_ENFORCED LIMIT 1];
        }

        match.Mentor__c = mentorId;
        match.Mentee__c = menteeId;
        match.Status__c = status;
        
        if (removalReason != null) {
            match.Dismissal_Reason__c = removalReason;
        }

        if (removalInformation!= null) {
            match.Dismissal_Additional_Information__c = removalInformation;
        }

        if (score != null) {
            match.Score__c = score;
        }

        if (requestMessage != null && requestMessage != '') {
            match.Request_Message__c = requestMessage;
        }

        if (responseMessage != null && responseMessage != '') {
            match.Response_Message__c = responseMessage;
        }

        // Insert mentoring match
        try {
             upsert match;
        } catch(Exception e) {
            throw new AuraHandledException('Opps! Something went wrong: ' + e.getMessage());
        }
        return match;
    }

    // Counts mentors and mentees for current user
    @AuraEnabled(Cacheable=true)
    public static List<Integer> countMentors(Id recordId){
        List<Integer> countArray = new List<Integer>();
        try {
            Integer mentors = [SELECT count() FROM Mentoring_Match__c WHERE Mentee__c =: recordId AND Status__c = 'Accepted' WITH SECURITY_ENFORCED];
            Integer mentees = [SELECT count() FROM Mentoring_Match__c WHERE Mentor__c =: recordId AND Status__c = 'Accepted' WITH SECURITY_ENFORCED];
            countArray.add(mentors);
            countArray.add(mentees);
        } catch(Exception e) {
            throw new AuraHandledException('Opps! Something went wrong: ' + e.getMessage());
        }
        return countArray;
    }

    // Retrieves all functional competencies selected for each role record 
    @AuraEnabled(Cacheable=true)
    public static List<PicklistWrapper> retrieveRolesAndCompetencies(){
        
        try {
            List<PicklistWrapper> theReturnList = new List<PicklistWrapper>();
            Schema.DescribeFieldResult theFCDescribe = User.Functional_Competencies__c.getDescribe();
            // Get picklist values from field description
            List<Schema.PicklistEntry> entries = theFCDescribe.getPicklistValues();
            List<Functional_Role__c> theFRs = [SELECT Id, Name, Functional_Competencies__c FROM Functional_Role__c WITH SECURITY_ENFORCED ORDER BY name ASC];

            for(Functional_Role__c theOrigFR : theFRs){
                PicklistWrapper thePW = new PicklistWrapper();
                thePW.role = theOrigFR;
                List<PicklistInfo> thePVI = new List<PicklistInfo>();
                List<String> theOrigFRValues = theOrigFR.Functional_Competencies__c.split(';');
                for (Schema.PicklistEntry entry : entries) {
                    for (String theOrigFRVal : theOrigFRValues) {
                        if(entry.getValue() == theOrigFRVal){
                            PicklistInfo theNewVal = new PicklistInfo();
                            theNewVal.label = thePW.role.Name+'-'+entry.getLabel();
                            theNewVal.value = entry.getValue();
                            thePVI.add(theNewVal);
                        }
                    }
                }
                thePW.values = thePVI;
                theReturnList.add(thePW);
            }
            System.debug('theFRs: ' + theFRs);
            System.debug('theReturnList: ' + theReturnList);

            return theReturnList;
        } catch (Exception e) {
            throw new AuraHandledException('Opps! Something went wrong: ' + e.getMessage());
        }
    }

    // Retrieve current program stages from mentoring match id
    @AuraEnabled(cacheable=true)
    public static ProgramWrapper retrieveProgramStagesFromMentoringMatch(String matchId){

        List<Program__c> allMatchPrograms = [SELECT Id, CreatedDate FROM Program__c WHERE Mentoring_Match__c = :matchId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        String theMatchProgramId = allMatchPrograms[0].Id;

        ProgramWrapper thePW = new ProgramWrapper();
        thePW.program = allMatchPrograms[0];
        System.debug('theMatchProgramId: ' + theMatchProgramId);
        try {
            if(allMatchPrograms.size() > 0){
                List<Program_Stage__c> theProgramStages = [SELECT Id, Name, Completed__c, Program__c, Program_Template_Stage__c FROM Program_Stage__c WHERE Program__c = :theMatchProgramId WITH SECURITY_ENFORCED];
                List<String> thePSTids = new List<String>();
                for(Program_Stage__c thePS : theProgramStages){
                    thePSTids.add(thePS.Program_Template_Stage__c);
                }
                List<Program_Template_Stage__c> theProgramTemplateStages = [SELECT Id, Name, Order__c, Mentee_Description__c, Mentee_Links_Description__c, Mentee_Sessions_Description__c, Mentor_Description__c, Mentor_Links_Description__c, Mentor_Sessions_Description__c, (SELECT Id, Name, Order__c, Link__c, Visibility__c FROM Program_Template_Stage_Links__r ORDER BY Order__c ASC), (SELECT Id, Name, Order__c, Link__c, Visibility__c FROM Program_Template_Stage_Sessions__r ORDER BY Order__c ASC) FROM Program_Template_Stage__c WHERE Id IN :thePSTids WITH SECURITY_ENFORCED ORDER BY Order__c ASC];
                List<ProgramStageWrapper> thePSWList = new List<ProgramStageWrapper>();
                for(Program_Stage__c thePS : theProgramStages){
                    for(Program_Template_Stage__c thePTS : theProgramTemplateStages){
                        if(thePS.Program_Template_Stage__c == thePTS.Id){
                            ProgramStageWrapper thePSW = new ProgramStageWrapper();
                            thePSW.programStage = thePS;
                            thePSW.programTemplateStage = thePTS;
                            thePSWList.add(thePSW);
                        }
                    }
                }
                thePW.programStages = thePSWList;
            }       
        } catch (Exception e) {
            throw new AuraHandledException('Opps! Something went wrong: ' + e.getMessage());
        }
        
       
        return thePW;   
    }

    // Retrieve all meetings from mentoring match id
    @AuraEnabled(cacheable=true)
    public static List<Meeting__c> retrieveMeetingsFromMentoringMatch(String matchId){
        List<Meeting__c> allMeetings = [SELECT Id, CreatedDate, Meeting_Title__c, Meeting_Date_Time__c FROM Meeting__c WHERE Mentoring_Match__c = :matchId WITH SECURITY_ENFORCED];
        return allMeetings;
    }

    @AuraEnabled(Cacheable=true)
    public static List<User> retrieveMentors(List<String> certifications, List<String> typeOfMentoring, List<String> functionalCompetencies, List<String> languages, List<String> experiences, List<String> egcs, List<String> greatCompetencies, List<String> locations){

        System.debug('certifications: '+ certifications);
        System.debug('typeOfMentoring: '+ typeOfMentoring);
        System.debug('functionalCompetencies: '+ functionalCompetencies);
        System.debug('languages: '+ languages);
        System.debug('experiences: '+ experiences);
        System.debug('egcs: '+ egcs);
        System.debug('greatCompetencies: '+ greatCompetencies);
        System.debug('locations: '+ locations);

        User currentUser = [SELECT 
            Id 
            /*Hire_Date__c, 
            Job_Grade__c
            Mgmt_Chain_Level_01__c,
            Mgmt_Chain_Level_02__c,
            Mgmt_Chain_Level_03__c,
            Mgmt_Chain_Level_04__c,
            Mgmt_Chain_Level_05__c,
            Mgmt_Chain_Level_06__c,
            Mgmt_Chain_Level_07__c,
            Mgmt_Chain_Level_08__c,
            Mgmt_Chain_Level_09__c,
            Mgmt_Chain_Level_10__c*/
            FROM User WHERE Id =: UserInfo.getUserId()];

        List<User> returnedUsers = new List<User>();
        List<Mentoring_Match__c> previousMatches = [SELECT 
            Id, 
            Mentor__c 
            FROM Mentoring_Match__c WHERE Status__c != 'Cancelled' AND Mentee__c =: UserInfo.getUserId() WITH SECURITY_ENFORCED];
        
        
            //Remove if statement when workerAPI is sorted
       // Decimal userJobGrade = 0;
       /* Decimal maxGrade = 20;
       
           currentUser.Job_Grade__c = 2;
        if(currentUser.Job_Grade__c != null){
          //  userJobGrade = currentUser.Job_Grade__c;
            maxGrade = currentUser.Job_Grade__c + 2;
        }*/
        String query = '';
        String selectQuery = 'SELECT Name, Id, AboutMe, City, Capacity__c, Email, MediumPhotoUrl, Title, Hire_Date__c, Equality_Group_Member__c, Available__c, Country, Mentee_Type_Preference__c, Skills__c, Interests__c, Business_Unit__c, Cost_Center__c, Great_Competencies__c, Mentoring_Language__c, Certifications__c, Experiences__c, toLabel(Functional_Competencies__c), (SELECT Id, Mentor__c FROM Mentoring_Matches__r WHERE Status__c = \''+ 'Accepted'+'\') FROM User';
        
        List<String> whereQueries = new List<String>();
        if(certifications.size() > 0){
            String tempQuery = 'Certifications__c INCLUDES (\''+String.join(certifications, ';')+'\')';
            whereQueries.add(tempQuery);
        }
        if(typeOfMentoring.size() > 0){
            String tempQuery = 'Mentee_Type_Preference__c INCLUDES (\''+String.join(typeOfMentoring, ';')+'\')';
            whereQueries.add(tempQuery);
        }
        if(functionalCompetencies.size() > 0){
            String tempQuery = 'Functional_Competencies__c INCLUDES (\''+String.join(functionalCompetencies, ';')+'\')';
            whereQueries.add(tempQuery);
        }
        if(languages.size() > 0){
            String tempQuery = 'Mentoring_Language__c INCLUDES (\''+String.join(languages, ';')+'\')';
            whereQueries.add(tempQuery);
        }
        if(experiences.size() > 0){
            String tempQuery = 'Experiences__c INCLUDES (\''+String.join(experiences, ';')+'\')';
            whereQueries.add(tempQuery);
        }
        if(egcs.size() > 0){
            String tempQuery = 'Equality_Group_Member__c INCLUDES (\''+String.join(egcs, ';')+'\')';
            whereQueries.add(tempQuery);
        }
        if(greatCompetencies.size() > 0){
            String tempQuery = 'Great_Competencies__c INCLUDES (\''+String.join(greatCompetencies, ';')+'\')';
            whereQueries.add(tempQuery);
        }
        if(locations.size() > 0){
            String tempQuery = 'Mentee_Location_Preference__c INCLUDES (\''+String.join(locations, ';')+'\')';
            whereQueries.add(tempQuery);
        }

        String tempNotCurrentUserQuery = 'Id != \''+UserInfo.getUserId()+'\'';
        whereQueries.add(tempNotCurrentUserQuery);

        String tempAvailableQuery = 'Available__c = true';
        whereQueries.add(tempAvailableQuery);

        String whereQuery = '';
        if(whereQueries.size() > 0){
            whereQuery = ' WHERE ' + String.join(whereQueries, ' AND ');
        }
        System.debug('whereQuery: '+ whereQuery);
        String orderQuery = ' ORDER BY LastLoginDate DESC';
        String limitQuery = ' LIMIT 50';
        String securityQuery = ' WITH SECURITY_ENFORCED';
        query = selectQuery + whereQuery + securityQuery + orderQuery + limitQuery;
        String pattern = '\\\\';
        String queryNew = String.escapeSingleQuotes(query);
        queryNew = queryNew.replaceAll(pattern,'');
        system.debug('queryNew '+queryNew);
        system.debug('queryOld '+query);
        List<User> potentialUsers = database.query(queryNew);        

        // Check if user has previously engaged with the mentor   
        //System.debug('potentialUsers: '+ potentialUsers);
        for (User user : potentialUsers) {
            Integer menteeCount = 0;
            Boolean addUser = true;
            if (user.Capacity__c != null) {
                for (Mentoring_Match__c match : user.Mentoring_Matches__r) {
                    if (match.Mentor__c == user.Id) {
                        menteeCount = menteeCount + 1;
                    }
                }
                if (menteeCount >= user.Capacity__c) {
                    addUser = false;
                }
            }
            if (addUser == true) {
                //System.debug('previousMatches: '+ previousMatches);
                for (Mentoring_Match__c dismissedMatch : previousMatches) {
                    if (user.Id == dismissedMatch.Mentor__c) {
                        addUser = false;
                    }
                }
            }
            if (addUser == true) {
                returnedUsers.add(user);
            }
        }

        return returnedUsers;
    }

    @AuraEnabled( cacheable=true )  
    public static Template_Survey__c retrieveSurveyLinks() {
        return Template_Survey__c.getOrgDefaults();
    }

    public class PicklistWrapper {
        @AuraEnabled
        public Functional_Role__c role {get;set;}
        @AuraEnabled
        public List<PicklistInfo> values {get;set;}

        public PicklistWrapper(){
        }

        public PicklistWrapper(Functional_Role__c theR, List<PicklistInfo> thePVs){
            role = theR;
            values = thePVs;
        }
    }

    public class PicklistInfo {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}

        public PicklistInfo(){
        }

        public PicklistInfo(String theL, String theV){
            label = theL;
            value = theV;
        }
    }

    public class ProgramWrapper {
        @AuraEnabled
        public Program__c program {get;set;}
        @AuraEnabled
        public List<ProgramStageWrapper> programStages {get;set;}

        public ProgramWrapper(){
        }

        public ProgramWrapper(Program__c theP, List<ProgramStageWrapper> thePS){
            program = theP;
            programStages = thePS;
        }
    }

    public class ProgramStageWrapper {
        @AuraEnabled
        public Program_Stage__c programStage {get;set;}
        @AuraEnabled
        public Program_Template_Stage__c programTemplateStage {get;set;}

        public ProgramStageWrapper(){
        }

        public ProgramStageWrapper(Program_Stage__c thePS, Program_Template_Stage__c thePST){
            programStage = thePS;
            programTemplateStage = thePST;
        }
    }

    @AuraEnabled( cacheable=true )  
    public static Boolean getMentoringMatch(ID mentorId, Id menteeId) {
        List<Mentoring_Match__c> matchResults = [SELECT id, Name FROM Mentoring_Match__c WHERE Mentor__c =: mentorId AND Mentee__c =: menteeId WITH SECURITY_ENFORCED];
        if(matchResults.size()>0) return true;
        else return false;
    }
}