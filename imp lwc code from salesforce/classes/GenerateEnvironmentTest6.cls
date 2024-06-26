public class GenerateEnvironmentTest6 {
    
    /*
     * ENVIRONMENT TO TEST: Test_PerformanceIntroController
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
    
    public static Value__c value1;

    public static Method__c method1;
    public static Method__c method2;

    public static Obstacle__c obstacle1;

    public static Measure__c measure1;
    
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
    public static PerformanceReviewPeriod__c PRPAdHoc;
    public static PerformanceReviewPeriod__c PRPIndividualQ1Q2;
    public static PerformanceReviewPeriod__c PRPIndividualQ3Q4;

    public static List<PerformanceReviewPeriod__c> allPRPs = new List<PerformanceReviewPeriod__c>();
    
    public static PerformanceReview__c PRIndividual;
    public static PerformanceReview__c PRIndividualShort;
    public static PerformanceReview__c PRIndividualQ1Q2Edu;
    public static PerformanceReview__c PRIndividualQ3Q4Edu;
    public static PerformanceReview__c PRIndividualQ1Q2Sup;
    public static PerformanceReview__c PRIndividualQ3Q4Sup;
    public static PerformanceReview__c PRIndividualQ1Q2Cons;
    public static PerformanceReview__c PRIndividualQ3Q4Cons;
    public static PerformanceReview__c PRIndividualQ1Q2CSM;
    public static PerformanceReview__c PRIndividualQ3Q4CSM;

    public static List<PerformanceReview__c> allPRs = new List<PerformanceReview__c>();

    public static PerformanceReview__History PRHistory1;
    public static PerformanceReview__History PRHistory2;
    public static PerformanceReview__History PRHistory3;
    public static PerformanceReview__History PRHistory4;
    public static PerformanceReview__History PRHistory5;
    
    public static List<PerformanceReview__History> PRHistorys;
    
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
    
    
    
    public static List<ScorecardSupportReview__c> allScorecards = new List<ScorecardSupportReview__c>();

    
    public static List<Profile> profList;
    public static List<User> userList;
    
    public static void setCreatePerfShortReviewEmpty(){
        emptyOverallReview = true;
    }
    
    public static PerformanceReviewPeriod__c performanceReviewPeriod{
        get{
            if(performanceReviewPeriod == null){
                performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test Period',
                                                                    Effective_Date__c = 'FY10',
                                                                    V2MOM_Type__c = 'Individual',
                                                                    StartDate__c = date.newInstance(2010,1,1),
                                                                    EndDate__c = date.newInstance(2010,12,31));
                insert performanceReviewPeriod;
            }
            return  performanceReviewPeriod;
        }
    }
    public static void genPerformanceIntroShort(){
        try {
            getUsers();
            getUser('None');
            
            // create v2moms
            v2momIndividual = createV2MOM(employeeStandard.Id, 'vision ad hoc short', 'Individual', 'Test V2MOM Ad Hoc short', 'FY08', 'My Management Hierarchy');
    
            // create the methods for each v2mom        
            method1 = createMethod(v2momIndividual.Id, null, 1, 'Method 1', 'Description method 1');
            
            upsert(allmethods);
            
            obstacle1 = createObstacle(v2momIndividual.Id, null, method1.Id, 1, 'Description obstacle 1');
    
            Date d = System.today();
            
            measure1 = createMeasure(v2momIndividual.Id, null, method1.Id, 1, 'Description measure 1', d, d);
            
            // create the competencies for step 2
            //competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
            competencyGroup = createCompetencyGroup();
            
            competency1 = createCompetency('Test Competency 1', 'New competency test 1');
            competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency1.Id, competencyGroup.Id, 30);
            
            upsert(allCompetencyGroupMembers);
            
            // create other necessary elements
            //reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
            reviewFormTemplate = createReviewFromTemplate();
            
            department = createDepartment('Test Department', false);
            
            Date d1 = System.today();
            Date d2 = d1.addYears(1);
            
            // Create the performance review periods for different V2MOMs types     
            PRPAdHoc = createPRP('Test PRP Ad Hoc', 'FY08', 'Ad Hoc', d1, d2);
            
            upsert(allPRPs);
    
            // Create the different performance reviews for each V2MOM type
            PRIndividualShort = createPerformanceReview('Test PReview Individual (Short)', PRPAdHoc.Id,
                                             v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeStandard.Id, managerStandard.Id, secondManagerStandard.Id, 
                                             pcommStandard.Id, secondManagerSupport.Id, department.Id, 'Created');
    
            upsert(allPRs);
    
            overallrevEmpl = createOverallReview('overall review Empl stnd', PRIndividualShort.Id, 'com1', '', 'com3', '', 
                                                    employeeStandard.Id, 'comment Empl stnd overall');
            
            overallrevMngr = createOverallReview('overall review Mngr stnd', PRIndividualShort.Id, '', 'com2', '', 'com4', 
                                                    managerStandard.Id, 'comment Mngr stnd overall');
    
        } catch (Exception e) {
            System.debug(' ****************** genPerformanceIntroShort * ');
            System.debug(e.getMessage());
        }
    }

    public static void genPerformanceIntroShortEmpty(){
        try {
            getUsers();
            getUser('None');
            
            // create v2moms
            v2momIndividual = createV2MOM(employeeStandard.Id, 'vision ad hoc short', 'Individual', 'Test V2MOM Ad Hoc short', 'FY08', 'My Management Hierarchy');
    
            // create the methods for each v2mom        
            method1 = createMethod(v2momIndividual.Id, null, 1, 'Method 1', 'Description method 1');
            
            upsert(allmethods);
            
            obstacle1 = createObstacle(v2momIndividual.Id, null, method1.Id, 1, 'Description obstacle 1');
    
            Date d = System.today();
            
            measure1 = createMeasure(v2momIndividual.Id, null, method1.Id, 1, 'Description measure 1', d, d);
            
            // create the competencies for step 2
            //competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
            competencyGroup = createCompetencyGroup();
            
            competency1 = createCompetency('Test Competency 1', 'New competency test 1');
            competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency1.Id, competencyGroup.Id, 30);
            
            upsert(allCompetencyGroupMembers);
            
            // create other necessary elements
            //reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
            
            reviewFormTemplate = createReviewFromTemplate();
            
            department = createDepartment('Test Department', false);
            
            Date d1 = System.today();
            Date d2 = d1.addYears(1);
            
            // Create the performance review periods for different V2MOMs types     
            PRPAdHoc = createPRP('Test PRP Ad Hoc', 'FY08', 'Ad Hoc', d1, d2);
            
            upsert(allPRPs);
    
            // Create the different performance reviews for each V2MOM type
            PRIndividualShort = createPerformanceReview('Test PReview Individual (Short)', PRPAdHoc.Id,
                                             v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeStandard.Id, managerStandard.Id, secondManagerStandard.Id, 
                                             pcommStandard.Id, secondManagerSupport.Id, department.Id, 'Created');
    
            upsert(allPRs);
        } catch (Exception e) {
            System.debug(' ****************** genPerformanceIntroShortEmpty * ');
            System.debug(e.getMessage());
        }
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
    
    public static User getPCOMM(){
        Profile p = [Select Id From Profile Where Name =: 'PCOMM'];
        pcommStandard = new User(   userName = 'testPCOMM@test.com',
                                    lastName = 'PCOMM',
                                    email = 'empPCOMM@mailinator.com',
                                    alias = 'ptest',
                                    timeZoneSidKey = 'America/Los_Angeles',
                                    manager__c = getManager().Id,
                                    localeSidKey = 'en_US',
                                    emailEncodingKey = 'ISO-8859-1',
                                    LanguagelocaleKey = 'en_US',
                                    ProfileId = p.Id        
                                );
        system.runAS(getManager()){
            insert pcommStandard;
        }
        return pcommStandard;                       
        
    } 
    
    public static User getSystemAdmin(){
        Profile p = [Select Id From Profile where Name =: 'System Administrator'];
        User adminUser = [Select id From User Where ProfileID =: p.Id And IsActive =: True limit 1][0];
        return adminUser; 
    }
    
         
    
    public static PerformanceReview__c PerformanceReview{
        get{
            if(PerformanceReview == null){
                PerformanceReview = new PerformanceReview__c(Name = 'PerformanceReview Test',
                                   PerformanceReviewPeriod__c = PerformanceReviewPeriod.Id,
                                   V2MOM__c = createV2MOM(getManager().Id, 'Vision TestV2MOM', 'Individual', 'Test V2MOM', 'FY10', 'My Management Hierarchy').Id,
                                   CompetencyGroup__c = createCompetencyGroup().Id,
                                   ReviewFormTemplate__c = createReviewFromTemplate().Id,
                                   Employee__c = getEmployeeStandard().Id,
                                   Manager__c = getManager().Id,
                                   SecondManager__c = null,
                                   PCOMM__c = getPCOMM().Id,
                                   ThirdPartyReviewer__c = null,
                                   Cost_Center__c = Deparment.Id,
                                   Status__c = 'Employee Self Assessment',
                                   PreviousStatus__c = 'Created'
                                   );
                                   //Department__c = Deparment.Id,
                                   
               insert PerformanceReview;
               
            }
            return PerformanceReview;
        }
    }
    
    
    //public static Department__c Deparment{
    public static TF2_Department__c Deparment {
        get{
            if(Deparment==null){
                //Deparment = new Department__c(Name='TestDeparment', ExcludeESBP__c=true);
                Deparment = new TF2_Department__c(Name='TestDeparment', Exclude_ESBP__c=true);
                insert Deparment;
            }
            return Deparment;
        }
    }
    public static void genPerformanceIntroLongNormal(){
        try {
            getUsers();
            getUser('None');
            
            // create v2moms
            v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
            
            value1 = createValue(v2momIndividual.Id, 1, 'Value 1');
            
            // create the methods for each v2mom        
            method1 = createMethod(v2momIndividual.Id, value1.Id, 1, 'Method 1', 'Description method 1');
            method2 = createMethod(v2momIndividual.Id, value1.Id, 2, 'Method 2', 'Description method 2');
            
            upsert(allmethods);
            
            obstacle1 = createObstacle(v2momIndividual.Id, value1.Id, method1.Id, 1, 'Description obstacle 1');
    
            Date d = System.today();
            
            measure1 = createMeasure(v2momIndividual.Id, value1.Id, method1.Id, 1, 'Description measure 1', d, d);
            
            // create the competencies for step 2
            //competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
            competencyGroup = createCompetencyGroup();
            
            competency1 = createCompetency('Test Competency 1', 'New competency test 1');
            competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency1.Id, competencyGroup.Id, 30);
            
            upsert(allCompetencyGroupMembers);
            
            // create other necessary elements
            //reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
            
            reviewFormTemplate = createReviewFromTemplate();
            
            department = createDepartment('Test Department', false);
            
            
            Date d1 = System.today();
            Date d2 = d1.addYears(1);
            
            // Create the performance review periods for different V2MOMs types     
            PRPIndividual = createPRP('Test PRP Department', 'FY08', 'Individual', d1, d2);
            
            upsert(allPRPs);
    
            // Create the different performance reviews for each V2MOM type
            PRIndividual = createPerformanceReview('Test PReview Individual', PRPIndividual.Id,
                                             v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeStandard.Id, reviewManagerStandard.Id, review2ndManagerStandard.Id, 
                                             pcommStandard.Id, secondManagerSupport.Id, department.Id, 'Created');
    
            upsert(allPRs);
    
            // Create the method reviews
            method1revEmpl = createMethodReview('Method Review employee std method1', PRIndividual.Id, null, null,
                                                'In Progress', employeeStandard.Id, method1.Id,
                                                'comment method 1 employee standard');
            
            method1revMngr = createMethodReview('Method Review manager std method1', PRIndividual.Id, 2.0, 35,
                                                null, reviewManagerStandard.Id, method1.Id,
                                                'comment method 1 manager standard');
            
            method1rev2ndMngr = createMethodReview('Method Review 2nd manager stnd method1', PRIndividual.Id, null, null,
                                                null, review2ndManagerStandard.Id, method1.Id,
                                                'comment method 1 2nd manager standard');
            
            upsert(allMethodReviews);
    
            
            // Create the competency reviews
            competency1revEmpl = createCompetencyReview('Competency Review employee std competency1', PRIndividual.Id, null,
                                                employeeStandard.Id, competencyGroupMember1.Id,
                                                'comment competency 1 employee standard');
            
            competency1revMngr = createCompetencyReview('Competency Review manager std competency1', PRIndividual.Id, 2.0,
                                                reviewManagerStandard.Id, competencyGroupMember1.Id,
                                                'comment competency 1 manager standard');
            
            competency1rev2ndMngr = createCompetencyReview('Competency Review 2nd manager stnd competency1', PRIndividual.Id, null,
                                                review2ndManagerStandard.Id, competencyGroupMember1.Id,
                                                'comment competency 1 2nd manager standard');
            
            upsert(allCompetencyReviews);
    
            reviewRating = createOverallRating('overall rating Mngr stnd', PRIndividual.Id, 2.0, 3.2, reviewManagerStandard.Id);
            
            upsert(allOverallRatings);
        } catch (Exception e) {
            System.debug(' ****************** genPerformanceIntroLongNormal * ');
            System.debug(e.getMessage());
        }
    }
    
    public static V2MOM__c createV2MOM(Id user, String vision, String t, String name, 
                                        String effDate, String share){
                                            
        V2MOM__c V2MOM = new V2MOM__c ( OwnerId   = getManager().Id,
                                        Vision__c = 'Vision TestParentV2MOM', 
                                        //V2MOM_Type__c = 'Individual',
                                        Name = 'test Parent V2MOM', 
                                        Effective_Date__c = 'FY10',
                                        Share_With__c = 'My Management Hierarchy'
                                        );
        /* Run As Review Manager */
        system.runAs(getManager()){
            insert V2MOM;
        }
        V2MOM__c v = new V2MOM__c (     OwnerId=user,
                                        Vision__c = vision, 
                                        V2MOM_Type__c = t,
                                        Name = name, 
                                        Effective_Date__c = effDate,
                                        Share_With__c = share
                                    );
        v.parentId__c = V2MOM.Id;                           
        //allv2moms.add(v);
        upsert(v);
        
        return v;
    }
    
    //public static Department__c createDepartment(String name, boolean excl){
    public static TF2_Department__c createDepartment(String name, boolean excl){
            //Department__c d = new Department__c();
            TF2_Department__c d = new TF2_Department__c();
            d.Name = name;
            d.Exclude_ESBP__c = excl;
            upsert(d);
            return d;
    }
    
    public static Method__c createMethod(Id v2mom, Id value, Integer p, String name, String d){
        Method__c method = new Method__c(V2MOM__c = v2mom, 
                                        Value__c = value,
                                        Priority__c = p, 
                                        Name = name,
                                        Description__c = d);
        
        allMethods.add(method);
        
        return method;
    }
    
    public static Measure__c createMeasure(Id v2mom, Id value, Id method, Integer p, String d, Date startDate, Date endDate){
        Measure__c metric = new Measure__c(V2MOM__c = v2mom, 
                                        Method__c = method,
                                        Value__c = value,
                                        Priority__c = p, 
                                        Description__c = d,
                                        Start_Date__c = startDate,
                                        End_Date__c = endDate);
        upsert(metric);
        
        return metric;
    }
    
    public static Obstacle__c createObstacle(Id v2mom, Id value, Id method, Integer p, String d){
        Obstacle__c obstacle = new Obstacle__c(V2MOM__c = v2mom, 
                                        Method__c = method,
                                        Value__c = value,
                                        Priority__c = p, 
                                        Description__c = d);
        upsert(obstacle);
        
        return obstacle;
    }

    public static MethodReview__c createMethodReview(String oname,
                                                Id pr,
                                                double rating,
                                                Integer weight,
                                                String status, 
                                                Id reviewer,
                                                Id method,
                                                String comment){
        
        MethodReview__c methodReview;
        
        if (emptyMethodReviewComment){
            methodReview = new MethodReview__c(Weight__c = weight, 
                                                Status__c = status, 
                                                Reviewer__c = reviewer, 
                                                Rating__c = rating, 
                                                PerformanceReview__c = pr, 
                                                Method__c = method);
        }

        if (emptyMethodReviewRating){
            methodReview = new MethodReview__c(Weight__c = weight, 
                                                Status__c = status, 
                                                Reviewer__c = reviewer,  
                                                PerformanceReview__c = pr, 
                                                Method__c = method, 
                                                Comment__c = comment);
        }
        
        if ((!emptyMethodReviewRating) && (!emptyMethodReviewRating)){
            methodReview = new MethodReview__c(Weight__c = weight, 
                                                Status__c = status, 
                                                Reviewer__c = reviewer, 
                                                Rating__c = rating, 
                                                PerformanceReview__c = pr, 
                                                Method__c = method, 
                                                Comment__c = comment);
        }
        
        allMethodReviews.add(methodReview);
        
        return methodReview;
    }

    public static CompetencyReview__c createCompetencyReview(String oname,
                                                Id pr,
                                                double rating,
                                                Id reviewer,
                                                Id cgm,
                                                String comment){
        
        CompetencyReview__c compReview;
        
        if (emptyCompReviewComment){
            compReview = new CompetencyReview__c(Reviewer__c = reviewer, 
                                                Rating__c = rating, 
                                                PerformanceReview__c = pr, 
                                                CompetencyGroupMember__c = cgm);
        }
        
        if (emptyCompReviewRating){
            compReview = new CompetencyReview__c(Reviewer__c = reviewer,
                                                PerformanceReview__c = pr, 
                                                CompetencyGroupMember__c = cgm, 
                                                Comment__c = comment);
        }
        
        if ((!emptyCompReviewComment) && (!emptyCompReviewRating)){
            compReview = new CompetencyReview__c(Reviewer__c = reviewer, 
                                                Rating__c = rating, 
                                                PerformanceReview__c = pr, 
                                                CompetencyGroupMember__c = cgm, 
                                                Comment__c = comment);
        }
        
        allCompetencyReviews.add(compReview);
        
        return compReview;
    }

    public static AdditionalComment__c createOverallReview(String oname,
                                                            Id pr,
                                                            String updtMeth,
                                                            String suggComp,
                                                            String suggMeth,
                                                            String commComp,
                                                            Id reviewer,
                                                            String comment){
        AdditionalComment__c overallReview;
        
        if (emptyOverallReview){
            overallReview = new AdditionalComment__c(Reviewer__c = reviewer, 
                                                    PerformanceReview__c = pr);
        }
        
        if (!emptyOverallReview){
            overallReview = new AdditionalComment__c(UpdateMethods__c = updtMeth, 
                                                    SuggestionsCompetencies__c = suggComp, 
                                                    SuggestionMethods__c = suggMeth, 
                                                    Reviewer__c = reviewer, 
                                                    PerformanceReview__c = pr, 
                                                    Comment__c = comment, 
                                                    CommentCompetencies__c = commComp);
        }
        
        allOverallReviews.add(overallReview);
        upsert(overallReview);
        return overallReview;
    }

    public static ReviewRating__c createOverallRating(String oname,
                                                            Id pr,
                                                            double orating,
                                                            double crating,
                                                            Id reviewer){
        
        ReviewRating__c overallRating;
        
        if (emptyOverallRating){
            overallRating = new ReviewRating__c(Reviewer__c = reviewer, 
                                                PerformanceReview__c = pr);
        }
        
        if (!emptyOverallRating){
            overallRating = new ReviewRating__c(Reviewer__c = reviewer, 
                                                PerformanceReview__c = pr, 
                                                OverallRating__c = orating,
                                                CalculatedRating__c = crating);
        }
        
        allOverallRatings.add(overallRating);
        
        return overallRating;
    }

    public static CompetencyGroupMember__c createCompetencyGroupMember(String name, 
                                            Id comp, Id cg, Integer w){
            CompetencyGroupMember__c c = new CompetencyGroupMember__c();
            c.Name = name;
            c.CompetencyGroup__c = cg;
            c.Competency__c = comp;
            c.Weight__c = w;
            allCompetencyGroupMembers.add(c);
            return c;
    }
    
    public static Competency__c createCompetency(String name, String d){
            Competency__c c = new Competency__c();
            c.Name = name;
            c.Description__c = d;
            upsert(c);
            return c;
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
    
    public static Value__c createValue(Id v2mom, Integer p, String name){
        Value__c value = new Value__c ( V2MOM__c = v2mom, 
                                            Priority__c = p, 
                                            Name = name);
        upsert(value);
        
        return value;
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
                                                
        employeeStandard = getUser(GenerateEnvironmentTestUsers.ccstndempl);
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
                                                           Department__c = dpt,
                                                           Status__c = status,
                                                           OwnerId = empl);
                                                                        
        allPRs.add(pr);
        
        return pr;
    }

    
    public static PerformanceReview__c changeStatusPReview(PerformanceReview__c pr,
                                                                String previousStatus,
                                                                String newStatus){
        try{
            if(pr == null){
                
            } 
            pr.Status__c = newStatus;
            pr.PreviousStatus__c = previousStatus;
        
            upsert(pr);
        }catch(Exception e){
            System.debug('Exception: ' + e.getMessage());
        }                                                       
        
        
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

}