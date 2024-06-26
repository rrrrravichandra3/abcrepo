public class GenerateEnvironmentTest5 {
    
    /*
     * ENVIRONMENT TO TEST: Test_PerformanceAccessUtil
    */
    
    //public static Department__c department;
    
    public static TF2_Department__c department;
    
    public static CompetencyGroup__c competencyGroup;
    public static CompetencyGroupMember__c competencyGroupMember1;
    public static CompetencyGroupMember__c competencyGroupMember2;
    public static List<CompetencyGroupMember__c> allCompetencyGroupMembers = new List<CompetencyGroupMember__c>();
    public static Competency__c competency1;
    public static Competency__c competency2;
    
    public static User myself;
    public static User pcommStandard;
    public static User esadminStandard;
    public static User ceoStandard;
    public static User esbpStandard;
    
    public static User manager;
    public static User employeeStandard;
    public static User managerStandard;
    public static User secondManagerStandard;
    public static User reviewManagerStandard;
    public static User review2ndManagerStandard;
    
    public static User employeeSupport;
    public static User managerSupport;
    public static User secondManagerSupport;
    public static User reviewManagerSupport;
    public static User review2ndManagerSupport;
    
    public static User employeeEducation;
    public static User managerEducation;
    public static User secondManagerEducation;
    public static User reviewManagerEducation;
    public static User review2ndManagerEducation;
    
    public static User employeeConsulting;
    public static User managerConsulting;
    public static User secondManagerConsulting;
    public static User reviewManagerConsulting;
    public static User review2ndManagerConsulting;
    
    public static User employeeCSM;
    public static User managerCSM;
    public static User secondManagerCSM;
    public static User reviewManagerCSM;
    public static User review2ndManagerCSM;

    
    public static V2MOM__c v2momAdHoc;
    public static V2MOM__c v2momIndividual;
    public static V2MOM__c v2momIndividualQ1Q2Sup;
    public static V2MOM__c v2momIndividualQ3Q4Sup;
    public static V2MOM__c v2momIndividualQ1Q2Edu;
    public static V2MOM__c v2momIndividualQ3Q4Edu;
    public static V2MOM__c v2momIndividualQ1Q2Cons;
    public static V2MOM__c v2momIndividualQ3Q4Cons;
    public static V2MOM__c v2momIndividualQ1Q2CSM;
    public static V2MOM__c v2momIndividualQ3Q4CSM;
    
    public static Method__c method1;
    public static Method__c method2;
    
    public static Method__c methodQ1Q2Sup1;
    public static Method__c methodQ1Q2Sup2;
    public static Method__c methodQ3Q4Sup3;
    public static Method__c methodQ3Q4Sup4;

    public static Method__c methodQ1Q2Edu1;
    public static Method__c methodQ1Q2Edu2;
    public static Method__c methodQ3Q4Edu3;
    public static Method__c methodQ3Q4Edu4;

    public static List<Method__c> allMethods = new List<Method__c>();
    

    public static boolean emptyMethodReviewRating = false;
    public static boolean emptyMethodReviewComment = false;

    public static MethodReview__c method1revEmpl;
    public static MethodReview__c method1revMngr;
    public static MethodReview__c method1rev2ndMngr;
    public static MethodReview__c method1rev3rdParty;
    
    public static MethodReview__c method2revEmpl;
    public static MethodReview__c method2revMngr;
    public static MethodReview__c method2rev2ndMngr;
    public static MethodReview__c method2rev3rdParty;
    
    public static MethodReview__c methodQ1Q2Sup1revEmpl;
    public static MethodReview__c methodQ1Q2Sup1revMngr;
    public static MethodReview__c methodQ1Q2Sup1rev2ndMngr;
    public static MethodReview__c methodQ1Q2Sup1rev3rdParty;
    
    public static MethodReview__c methodQ1Q2Sup2revEmpl;
    public static MethodReview__c methodQ1Q2Sup2revMngr;
    public static MethodReview__c methodQ1Q2Sup2rev2ndMngr;
    public static MethodReview__c methodQ1Q2Sup2rev3rdParty;
    
    public static MethodReview__c methodQ3Q4Sup3revEmpl;
    public static MethodReview__c methodQ3Q4Sup3revMngr;
    public static MethodReview__c methodQ3Q4Sup3rev2ndMngr;
    public static MethodReview__c methodQ3Q4Sup3rev3rdParty;
    
    public static MethodReview__c methodQ3Q4Sup4revEmpl;
    public static MethodReview__c methodQ3Q4Sup4revMngr;
    public static MethodReview__c methodQ3Q4Sup4rev2ndMngr;
    public static MethodReview__c methodQ3Q4Sup4rev3rdParty;
    
    public static MethodReview__c methodQ1Q2Edu1revEmpl;
    public static MethodReview__c methodQ1Q2Edu1revMngr;
    public static MethodReview__c methodQ1Q2Edu1rev2ndMngr;
    public static MethodReview__c methodQ1Q2Edu1rev3rdParty;
    
    public static MethodReview__c methodQ1Q2Edu2revEmpl;
    public static MethodReview__c methodQ1Q2Edu2revMngr;
    public static MethodReview__c methodQ1Q2Edu2rev2ndMngr;
    public static MethodReview__c methodQ1Q2Edu2rev3rdParty;
    
    public static MethodReview__c methodQ3Q4Edu3revEmpl;
    public static MethodReview__c methodQ3Q4Edu3revMngr;
    public static MethodReview__c methodQ3Q4Edu3rev2ndMngr;
    public static MethodReview__c methodQ3Q4Edu3rev3rdParty;
    
    public static MethodReview__c methodQ3Q4Edu4revEmpl;
    public static MethodReview__c methodQ3Q4Edu4revMngr;
    public static MethodReview__c methodQ3Q4Edu4rev2ndMngr;
    public static MethodReview__c methodQ3Q4Edu4rev3rdParty;
    
    public static List<MethodReview__c> allMethodReviews = new List<MethodReview__c>();

    public static boolean emptyCompReviewRating = false;
    public static boolean emptyCompReviewComment = false;
    
    public static CompetencyReview__c competency1revEmpl;
    public static CompetencyReview__c competency1revMngr;
    public static CompetencyReview__c competency1rev2ndMngr;
    public static CompetencyReview__c competency1rev3rdParty;
    
    public static CompetencyReview__c competency2revEmpl;
    public static CompetencyReview__c competency2revMngr;
    public static CompetencyReview__c competency2rev2ndMngr;
    public static CompetencyReview__c competency2rev3rdParty;
    
    public static CompetencyReview__c competencyQ1Q2Sup1revEmpl;
    public static CompetencyReview__c competencyQ1Q2Sup1revMngr;
    public static CompetencyReview__c competencyQ1Q2Sup1rev2ndMngr;
    public static CompetencyReview__c competencyQ1Q2Sup1rev3rdParty;
    
    public static CompetencyReview__c competencyQ1Q2Sup2revEmpl;
    public static CompetencyReview__c competencyQ1Q2Sup2revMngr;
    public static CompetencyReview__c competencyQ1Q2Sup2rev2ndMngr;
    public static CompetencyReview__c competencyQ1Q2Sup2rev3rdParty;
    
    public static CompetencyReview__c competencyQ3Q4Sup3revEmpl;
    public static CompetencyReview__c competencyQ3Q4Sup3revMngr;
    public static CompetencyReview__c competencyQ3Q4Sup3rev2ndMngr;
    public static CompetencyReview__c competencyQ3Q4Sup3rev3rdParty;
    
    public static CompetencyReview__c competencyQ3Q4Sup4revEmpl;
    public static CompetencyReview__c competencyQ3Q4Sup4revMngr;
    public static CompetencyReview__c competencyQ3Q4Sup4rev2ndMngr;
    public static CompetencyReview__c competencyQ3Q4Sup4rev3rdParty;
    
    public static CompetencyReview__c competencyQ1Q2Edu1revEmpl;
    public static CompetencyReview__c competencyQ1Q2Edu1revMngr;
    public static CompetencyReview__c competencyQ1Q2Edu1rev2ndMngr;
    public static CompetencyReview__c competencyQ1Q2Edu1rev3rdParty;
    
    public static CompetencyReview__c competencyQ1Q2Edu2revEmpl;
    public static CompetencyReview__c competencyQ1Q2Edu2revMngr;
    public static CompetencyReview__c competencyQ1Q2Edu2rev2ndMngr;
    public static CompetencyReview__c competencyQ1Q2Edu2rev3rdParty;
    
    public static CompetencyReview__c competencyQ3Q4Edu3revEmpl;
    public static CompetencyReview__c competencyQ3Q4Edu3revMngr;
    public static CompetencyReview__c competencyQ3Q4Edu3rev2ndMngr;
    public static CompetencyReview__c competencyQ3Q4Edu3rev3rdParty;
    
    public static CompetencyReview__c competencyQ3Q4Edu4revEmpl;
    public static CompetencyReview__c competencyQ3Q4Edu4revMngr;
    public static CompetencyReview__c competencyQ3Q4Edu4rev2ndMngr;
    public static CompetencyReview__c competencyQ3Q4Edu4rev3rdParty;
    
    public static List<CompetencyReview__c> allCompetencyReviews = new List<CompetencyReview__c>();

    public static boolean emptyOverallReview = false;
    
    public static AdditionalComment__c overallrevEmpl;
    public static AdditionalComment__c overallrevMngr;
    public static AdditionalComment__c overallrev2ndMngr;
    public static AdditionalComment__c overallrev3rdParty;
    
    public static AdditionalComment__c overallQ1Q2SuprevEmpl;
    public static AdditionalComment__c overallQ1Q2SuprevMngr;
    public static AdditionalComment__c overallQ1Q2Suprev2ndMngr;
    public static AdditionalComment__c overallQ1Q2Suprev3rdParty;
    
    public static AdditionalComment__c overallQ3Q4SuprevEmpl;
    public static AdditionalComment__c overallQ3Q4SuprevMngr;
    public static AdditionalComment__c overallQ3Q4Suprev2ndMngr;
    public static AdditionalComment__c overallQ3Q4Suprev3rdParty;
    
    public static AdditionalComment__c overallQ1Q2EdurevEmpl;
    public static AdditionalComment__c overallQ1Q2EdurevMngr;
    public static AdditionalComment__c overallQ1Q2Edurev2ndMngr;
    public static AdditionalComment__c overallQ1Q2Edurev3rdParty;
    
    public static AdditionalComment__c overallQ3Q4EdurevEmpl;
    public static AdditionalComment__c overallQ3Q4EdurevMngr;
    public static AdditionalComment__c overallQ3Q4Edurev2ndMngr;
    public static AdditionalComment__c overallQ3Q4Edurev3rdParty;
    
    public static List<AdditionalComment__c> allOverallReviews = new List<AdditionalComment__c>();


    public static boolean emptyOverallRating = false;

    public static ReviewRating__c reviewRating;
    public static ReviewRating__c reviewRatingQ1Q2Sup;
    public static ReviewRating__c reviewRatingQ3Q4Sup;
    public static ReviewRating__c reviewRatingQ1Q2Edu;
    public static ReviewRating__c reviewRatingQ3Q4Edu;

    public static List<ReviewRating__c> allOverallRatings = new List<ReviewRating__c>();


    public static boolean emptySSComm = false;
    
    public static ScorecardSupportComment__c sscommQ1Q2SuprevEmpl;
    public static ScorecardSupportComment__c sscommQ1Q2SuprevMngr;
    public static ScorecardSupportComment__c sscommQ1Q2Suprev2ndMngr;
    public static ScorecardSupportComment__c sscommQ1Q2Suprev3rdParty;
    
    public static ScorecardSupportComment__c sscommQ3Q4SuprevEmpl;
    public static ScorecardSupportComment__c sscommQ3Q4SuprevMngr;
    public static ScorecardSupportComment__c sscommQ3Q4Suprev2ndMngr;
    public static ScorecardSupportComment__c sscommQ3Q4Suprev3rdParty;
    
    public static ScorecardSupportComment__c sscommQ1Q2EdurevEmpl;
    public static ScorecardSupportComment__c sscommQ1Q2EdurevMngr;
    public static ScorecardSupportComment__c sscommQ1Q2Edurev2ndMngr;
    
    public static ScorecardSupportComment__c sscommQ3Q4EdurevEmpl;
    public static ScorecardSupportComment__c sscommQ3Q4EdurevMngr;
    public static ScorecardSupportComment__c sscommQ3Q4Edurev2ndMngr;
    
    public static List<ScorecardSupportComment__c> allSSComms = new List<ScorecardSupportComment__c>();
    

    public static ReviewFormTemplate__c reviewFormTemplate;
    
    public static PerformanceReviewPeriod__c PRPIndividual;
    public static PerformanceReviewPeriod__c PRPIndividualQ1Q2;
    public static PerformanceReviewPeriod__c PRPIndividualQ3Q4;

    public static List<PerformanceReviewPeriod__c> allPRPs = new List<PerformanceReviewPeriod__c>();
    
    public static PerformanceReview__c PRIndividual;
    public static PerformanceReview__c PRIndividualQ1Q2Edu;
    public static PerformanceReview__c PRIndividualQ3Q4Edu;
    public static PerformanceReview__c PRIndividualQ1Q2Sup;
    public static PerformanceReview__c PRIndividualQ3Q4Sup;
    public static PerformanceReview__c PRIndividualQ1Q2Cons;
    public static PerformanceReview__c PRIndividualQ3Q4Cons;
    public static PerformanceReview__c PRIndividualQ1Q2CSM;
    public static PerformanceReview__c PRIndividualQ3Q4CSM;

    public static List<PerformanceReview__c> allPRs = new List<PerformanceReview__c>();

    public static boolean createScorecards = true;
    public static boolean createScorecardsWithData = false;
    public static boolean createScorecardsWithDataZero = false;

    public static ScorecardSupportReview__c sQ1Sup;
    public static ScorecardSupportReview__c sQ2Sup;
    public static ScorecardSupportReview__c sQ3Sup;
    public static ScorecardSupportReview__c sQ4Sup;

    public static ScorecardSupportReview__c sQ1Edu;
    public static ScorecardSupportReview__c sQ2Edu;
    public static ScorecardSupportReview__c sQ3Edu;
    public static ScorecardSupportReview__c sQ4Edu;
    
    public static ScorecardSupportReview__c sQ1CSM;
    public static ScorecardSupportReview__c sQ2CSM;
    public static ScorecardSupportReview__c sQ3CSM;
    public static ScorecardSupportReview__c sQ4CSM;
    
    public static List<ScorecardSupportReview__c> allScorecards = new List<ScorecardSupportReview__c>();

    
    public static List<Profile> profList;
    public static List<User> userList;
    
    
    public static void genPerformanceCSM(){
        getUsers();
        getUser('None');
        
        v2momIndividualQ1Q2CSM = createV2MOM(employeeCSM.Id, 'vision individual CSM Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
        v2momIndividualQ3Q4CSM = createV2MOM(employeeCSM.Id, 'vision individual CSM Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
    
        Date d1 = System.today();
        Date d2 = d1.addYears(1);
    
        PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
        PRPIndividualQ3Q4 = createPRP('Test PRP Individual Q3/Q4', 'FY08', 'Individual Q3/Q4', d1, d2);
        
        department = createDepartment('Test Department', false);
        competencyGroup = createCompetencyGroup();  
        reviewFormTemplate = createReviewFromTemplate();
        
        PRIndividualQ1Q2CSM = createPerformanceReview('Test PReview CSM IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
                                             v2momIndividualQ1Q2CSM.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeCSM.Id, reviewManagerCSM.Id, review2ndManagerCSM.Id,
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
            
        PRIndividualQ3Q4CSM = createPerformanceReview('Test PReview CSM IndividualQ3Q4', PRPIndividualQ3Q4.Id, 
                                             v2momIndividualQ3Q4CSM.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeCSM.Id, reviewManagerCSM.Id, review2ndManagerCSM.Id, 
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
                                             
         upsert(allPRs);
         
        sQ1CSM = addScorecardSupportReviewWithDataCSM('Q1CSM', PRIndividualQ1Q2CSM, 'Q1', 1, 2, 3, 4, 5, 6, 7, 8, 2, 10, 11, 12, 1, 14, 15, 16, 17, 18, 4, 20, 21, 22, 23, 24, 3, 3);
        sQ2CSM = addScorecardSupportReviewWithDataCSM('Q2CSM', PRIndividualQ1Q2CSM, 'Q2', 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3);
        sQ3CSM = addScorecardSupportReviewWithDataCSM('Q3CSM', PRIndividualQ3Q4CSM, 'Q3', 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3);
        sQ4CSM = addScorecardSupportReviewWithDataCSM('Q4CSM', PRIndividualQ3Q4CSM, 'Q4', 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3);
        
        upsert(allScorecards);
         
         
    }
    
    public static User getManager(){
                        
            if(manager == null){
                Profile p = [Select Id From Profile where Name =: 'Manager'];
                manager =  new User(    username='test__manager@test.com',
                                    lastName='testManager',
                                    email='managertest@mailinator.com',
                                    alias='mtest',
                                    timeZoneSidKey='America/Los_Angeles',
                                    localeSidKey='en_US',
                                    emailEncodingKey='ISO-8859-1',
                                    LanguagelocaleKey='en_US',
                                    ProfileID = p.Id);
                /* Run As Review Employee */
                system.runAs( getSystemAdmin()){
                    insert manager; 
                }                   
                
            }
            return manager;
        
    }
    
    public static User getEmployeeStandard(){
        Profile p = [Select Id From Profile where Name =: 'Employee'];
        employeeStandard =  new User(   username = 'testStandardemp@test.com',
                                        lastName = 'standard',
                                        email = 'emptest1@mailinator.com',
                                        alias = 'etest',
                                        timeZoneSidKey ='America/Los_Angeles',
                                        manager__c = getManager().Id,
                                        localeSidKey = 'en_US',
                                        emailEncodingKey = 'ISO-8859-1',
                                        LanguagelocaleKey = 'en_US',
                                        ProfileId = p.Id
                                    );
        /* Run As Review Manager */
        system.runAs(getManager()){
            insert employeeStandard;
        }
        return employeeStandard;                                    
    }
    
    public static User getSystemAdmin(){
        Profile p = [Select Id From Profile where Name =: 'System Administrator'];
        User adminUser = [Select id From User Where ProfileID =: p.Id And IsActive =: True limit 1][0];
        return adminUser; 
    }    
    
    public static void genPerformanceAccessUtil(){
        try {
            getUsers();
            getUser('None');
            
            // create v2moms
            v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
            
            v2momIndividualQ1Q2Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
            v2momIndividualQ3Q4Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
            
            v2momIndividualQ1Q2Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
            v2momIndividualQ3Q4Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
            
            v2momIndividualQ1Q2Cons = createV2MOM(employeeConsulting.Id, 'vision individual Cons Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
            v2momIndividualQ3Q4Cons = createV2MOM(employeeConsulting.Id, 'vision individual Cons Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
            
            v2momIndividualQ1Q2CSM = createV2MOM(employeeCSM.Id, 'vision individual CSM Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
            v2momIndividualQ3Q4CSM = createV2MOM(employeeCSM.Id, 'vision individual CSM Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
    
            // create the competencies for step 2
            competencyGroup = createCompetencyGroup();
    
            // create other necessary elements
            reviewFormTemplate = createReviewFromTemplate();
            
            department = createDepartment('Test Department', false);
            
            
            Date d1 = System.today();
            Date d2 = d1.addYears(1);
            
            // Create the performance review periods for different V2MOMs types     
            PRPIndividual = createPRP('Test PRP Department', 'FY08', 'Individual', d1, d2);
            PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
            PRPIndividualQ3Q4 = createPRP('Test PRP Individual Q3/Q4', 'FY08', 'Individual Q3/Q4', d1, d2);
            
            upsert(allPRPs);
    
            // Create the different performance reviews for each V2MOM type
            PRIndividual = createPerformanceReview('Test PReview Individual', PRPIndividual.Id,
                                             v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeStandard.Id, reviewManagerStandard.Id, review2ndManagerStandard.Id, 
                                             pcommStandard.Id, secondManagerSupport.Id, department.Id, 'Created');
    
            PRIndividualQ1Q2Sup = createPerformanceReview('Test PReview Sup IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
                                             v2momIndividualQ1Q2Sup.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, 
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
            
            PRIndividualQ3Q4Sup = createPerformanceReview('Test PReview Sup IndividualQ3Q4', PRPIndividualQ3Q4.Id, 
                                             v2momIndividualQ3Q4Sup.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeSupport.Id, reviewManagerSupport.Id, review2ndManagerSupport.Id, 
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
    
            PRIndividualQ1Q2Edu = createPerformanceReview('Test PReview Edu IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
                                             v2momIndividualQ1Q2Edu.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeEducation.Id, reviewManagerEducation.Id, review2ndManagerEducation.Id,
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
            
            PRIndividualQ3Q4Edu = createPerformanceReview('Test PReview Edu IndividualQ3Q4', PRPIndividualQ3Q4.Id, 
                                             v2momIndividualQ3Q4Edu.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeEducation.Id, reviewManagerEducation.Id, review2ndManagerEducation.Id, 
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
    
            PRIndividualQ1Q2Cons = createPerformanceReview('Test PReview Cons IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
                                             v2momIndividualQ1Q2Cons.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeConsulting.Id, reviewManagerConsulting.Id, review2ndManagerConsulting.Id,
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
            
            PRIndividualQ3Q4Cons = createPerformanceReview('Test PReview Cons IndividualQ3Q4', PRPIndividualQ3Q4.Id, 
                                             v2momIndividualQ3Q4Cons.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeConsulting.Id, reviewManagerConsulting.Id, review2ndManagerConsulting.Id, 
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
    
            PRIndividualQ1Q2CSM = createPerformanceReview('Test PReview CSM IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
                                             v2momIndividualQ1Q2CSM.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeCSM.Id, reviewManagerCSM.Id, review2ndManagerCSM.Id,
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
            
            PRIndividualQ3Q4CSM = createPerformanceReview('Test PReview CSM IndividualQ3Q4', PRPIndividualQ3Q4.Id, 
                                             v2momIndividualQ3Q4CSM.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeCSM.Id, reviewManagerCSM.Id, review2ndManagerCSM.Id, 
                                             pcommStandard.Id, secondManagerStandard.Id, department.Id, 'Created');
    
            upsert(allPRs);
            
            
        } catch (Exception e) {
            System.debug(' ****************** genPerformanceAccessUtil * ');
            System.debug(e.getMessage());
        }
    }
    
    public static V2MOM__c createV2MOM(Id user, String vision, String t, String name, 
                                        String effDate, String share){
                                            
        V2MOM__c v = new V2MOM__c (     OwnerId = employeeStandard.Id,
                                        Vision__c = vision, 
                                        V2MOM_Type__c = t,
                                        Name = name, 
                                        Effective_Date__c = effDate,
                                        Share_With__c = share);
        //allv2moms.add(v);
        try{
            upsert(v);  
        }catch(Exception e){
            system.debug('Error: ' + e);
        }
        
        
        return v;
    }
    
    //public static Department__c createDepartment(String name, boolean excl){
    public static TF2_Department__c createDepartment(String name, boolean excl){
            TF2_Department__c d = new TF2_Department__c();
            d.Name = name;
            d.Exclude_ESBP__c = excl;
            upsert(d);
            return d;
    }

    public static PerformanceReviewPeriod__c createPRP(String pname, String effdate, String v2momType,
                                                        Date sdate, Date edate){
        PerformanceReviewPeriod__c prp = new PerformanceReviewPeriod__c(Name = pname,
                                                                        Effective_Date__c = effdate,
                                                                        V2MOM_Type__c = v2momType,
                                                                        StartDate__c = sdate,
                                                                        EndDate__c = edate);
                                                                        
        allPRPs.add(prp);
        
        return prp;
    }
    
    
    public static void getUsers(){
        userList = [select id, username, Profile.Name from User 
                                                where username=:GenerateEnvironmentTestUsers.ccpcomm 
                                                or username=:GenerateEnvironmentTestUsers.ccesadmin
                                                or username=:GenerateEnvironmentTestUsers.ccceo
                                                or username=:GenerateEnvironmentTestUsers.ccesbp
                                                
                                                or username=:GenerateEnvironmentTestUsers.ccstndempl
                                                or username=:GenerateEnvironmentTestUsers.ccstndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevstndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevstnd2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccstnd2ndmngr
                                                
                                                or username=:GenerateEnvironmentTestUsers.ccsup2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevsup2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccsupmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevsupmngr
                                                or username=:GenerateEnvironmentTestUsers.ccsupempl
                                                
                                                or username=:GenerateEnvironmentTestUsers.ccedu2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevedu2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccedumngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevedumngr
                                                or username=:GenerateEnvironmentTestUsers.cceduempl
                                                
                                                or username=:GenerateEnvironmentTestUsers.cccons2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevcons2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccconsmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevconsmngr
                                                or username=:GenerateEnvironmentTestUsers.ccconsempl
                                                
                                                or username=:GenerateEnvironmentTestUsers.cccsm2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevcsm2ndmngr
                                                or username=:GenerateEnvironmentTestUsers.cccsmmngr
                                                or username=:GenerateEnvironmentTestUsers.ccrevcsmmngr
                                                or username=:GenerateEnvironmentTestUsers.cccsmempl
                                                or username=: UserInfo.getUserName()
                                                ];
                                                
        myself = getUser(UserInfo.getUserName());
        pcommStandard = getUser(GenerateEnvironmentTestUsers.ccpcomm);
        esadminStandard = getUser(GenerateEnvironmentTestUsers.ccesadmin);
        ceoStandard = getUser(GenerateEnvironmentTestUsers.ccceo);
        esbpStandard = getUser(GenerateEnvironmentTestUsers.ccesbp);
                                                
        employeeStandard = getEmployeeStandard();
        managerStandard = getUser(GenerateEnvironmentTestUsers.ccstndmngr);
        secondManagerStandard = getUser(GenerateEnvironmentTestUsers.ccstnd2ndmngr);
        reviewManagerStandard = getUser(GenerateEnvironmentTestUsers.ccrevstndmngr);
        review2ndManagerStandard = getUser(GenerateEnvironmentTestUsers.ccrevstnd2ndmngr);

        employeeSupport = getUser(GenerateEnvironmentTestUsers.ccsupempl);
        managerSupport = getUser(GenerateEnvironmentTestUsers.ccsupmngr);
        secondManagerSupport = getUser(GenerateEnvironmentTestUsers.ccsup2ndmngr);
        reviewManagerSupport = getUser(GenerateEnvironmentTestUsers.ccrevsupmngr);
        review2ndManagerSupport = getUser(GenerateEnvironmentTestUsers.ccrevsup2ndmngr);

        employeeEducation = getUser(GenerateEnvironmentTestUsers.cceduempl);
        managerEducation = getUser(GenerateEnvironmentTestUsers.ccedumngr);
        secondManagerEducation = getUser(GenerateEnvironmentTestUsers.ccedu2ndmngr);
        reviewManagerEducation = getUser(GenerateEnvironmentTestUsers.ccrevedumngr);
        review2ndManagerEducation = getUser(GenerateEnvironmentTestUsers.ccrevedu2ndmngr);

        employeeConsulting = getUser(GenerateEnvironmentTestUsers.ccconsempl);
        managerConsulting = getUser(GenerateEnvironmentTestUsers.ccconsmngr);
        secondManagerConsulting = getUser(GenerateEnvironmentTestUsers.cccons2ndmngr);
        reviewManagerConsulting = getUser(GenerateEnvironmentTestUsers.ccrevconsmngr);
        review2ndManagerConsulting = getUser(GenerateEnvironmentTestUsers.ccrevcons2ndmngr);

        employeeCSM = getUser(GenerateEnvironmentTestUsers.cccsmempl);
        managerCSM = getUser(GenerateEnvironmentTestUsers.cccsmmngr);
        secondManagerCSM = getUser(GenerateEnvironmentTestUsers.cccsm2ndmngr);
        reviewManagerCSM = getUser(GenerateEnvironmentTestUsers.ccrevcsmmngr);
        review2ndManagerCSM = getUser(GenerateEnvironmentTestUsers.ccrevcsm2ndmngr);
    }
    
    public static User getUser(String oname){
        for (User u : userList){
            if (u.username.equals(oname)){
                return u;
            }
        }

        return null;
    }
        
    public static PerformanceReview__c createPerformanceReview(String pname, Id prp, Id v2, Id cgrp, Id rftpl,
                                                              Id empl, Id mngr, Id sndMngr, Id pcomm, Id thirdPt,
                                                              Id dpt, String status){
                                                            
        PerformanceReview__c pr = new PerformanceReview__c(Name = pname,
                                                           PerformanceReviewPeriod__c = prp,
                                                           V2MOM__c = v2,
                                                           CompetencyGroup__c = cgrp,
                                                           ReviewFormTemplate__c = rftpl,
                                                           Employee__c = empl,
                                                           Manager__c = mngr,
                                                           SecondManager__c = sndMngr,
                                                           PCOMM__c = pcomm,
                                                           ThirdPartyReviewer__c = thirdPt,
                                                           
                                                           Status__c = status);
                                                           //Department__c = dpt,Cost_Center__c = dpt,
                                                                        
        allPRs.add(pr);
        
        return pr;
    }

    
    public static PerformanceReview__c changeStatusPReview(PerformanceReview__c pr,
                                                                String previousStatus,
                                                                String newStatus){
        pr.Status__c = newStatus;
        pr.PreviousStatus__c = previousStatus;
        
        upsert(pr);
        
        return pr;
    }

    public static CompetencyGroup__c createCompetencyGroup()
    {
        CompetencyGroup__c competencyGroupNew = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
        upsert(competencyGroupNew);
        
        return competencyGroupNew;
    }
    
    
    public static ReviewFormTemplate__c createReviewFromTemplate()
    {
        ReviewFormTemplate__c reviewFromTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
        upsert(reviewFromTemplate);
        
        return reviewFromTemplate;
    }
    
    public static ScorecardSupportReview__c addScorecardSupportReviewWithDataCSM(String pname,
                                                                                PerformanceReview__c pr,
                                                                                String fq,
                                                                                Double SIPipeLineContributionTraningTarget,
                                                                                Double SIPipeLineContributionTraningActual,
                                                                                Double SIPipeLineContributionTarget,  
                                                                                Double SIPipeLineContributionConsultingTarget,
                                                                                Double SIPipeLineContributionConsultingActual,
                                                                                Double SIPipeLineContributionActual,
                                                                                Double RenewalExcellenceWeight,
                                                                                Double RenewalExcellenceTarget,
                                                                                Double RenewalExcellenceRating,
                                                                                Double RenewalExcellenceActual,
                                                                                Double OperationalExcellenceWeight,
                                                                                Double OperationalExcellenceTarget,
                                                                                Double OperationalExcellenceRating,
                                                                                Double OperationalExcellenceActual,
                                                                                Double ExecutiveRelationshipsTarget,
                                                                                Double ExecutiveRelationshipsActual,
                                                                                Double CSMSalesImpactWeight,
                                                                                Double CSMSalesImpactTarget,
                                                                                Double CSMSalesImpactRating,
                                                                                Double CSMSalesImpactActual,
                                                                                Double CSEAmountTarget,
                                                                                Double CSEAmountActual,
                                                                                Double ACVGrowthTarget,
                                                                                Double ACVGrowthActual,
                                                                                Double PipelineContributionActual,
                                                                                Double PipelineContributionTarget) {
                                                                            
        
        ScorecardSupportReview__c s = new ScorecardSupportReview__c ();
        s.Name = pname;
        s.PerformanceReview__c = pr.Id;
        s.FiscalQuarter__c = fq;
        s.SIPipeLineContributionTraningTarget__c = SIPipeLineContributionTraningTarget;
        s.SIPipeLineContributionTraningActual__c = SIPipeLineContributionTraningActual;
        s.SIPipeLineContributionTarget__c = SIPipeLineContributionTarget;
        s.SIPipeLineContributionConsultingTarget__c = SIPipeLineContributionConsultingTarget;
        s.SIPipeLineContributionConsultingActual__c = SIPipeLineContributionConsultingActual;
        s.SIPipeLineContributionActual__c = SIPipeLineContributionActual;
        s.RenewalExcellenceWeight__c = RenewalExcellenceWeight;
        s.RenewalExcellenceTarget__c = RenewalExcellenceTarget;
        s.RenewalExcellenceRating__c = RenewalExcellenceRating;
        s.RenewalExcellenceActual__c = RenewalExcellenceActual;
        s.OperationalExcellenceWeight__c = OperationalExcellenceWeight;
        s.OperationalExcellenceTarget__c = OperationalExcellenceTarget;
        s.OperationalExcellenceRating__c = OperationalExcellenceRating;
        s.OperationalExcellenceActual__c = OperationalExcellenceActual;
        s.ExecutiveRelationshipsTarget__c = ExecutiveRelationshipsTarget;
        s.ExecutiveRelationshipsActual__c = ExecutiveRelationshipsActual;
        s.CSMSalesImpactWeight__c = CSMSalesImpactWeight;
        s.CSMSalesImpactTarget__c = CSMSalesImpactTarget;
        s.CSMSalesImpactRating__c = CSMSalesImpactRating;
        s.CSMSalesImpactActual__c = CSMSalesImpactActual;
        s.CSEAmountTarget__c = CSEAmountTarget;
        s.CSEAmountActual__c = CSEAmountActual;
        s.ACVGrowthTarget__c = ACVGrowthTarget;
        s.ACVGrowthActual__c = ACVGrowthActual;
        s.PipelineContributionActual__c = PipelineContributionActual;
        s.PipelineContributionTarget__c = PipelineContributionTarget;
        
        allScorecards.add(s);
        
        return s;
    }
    
}