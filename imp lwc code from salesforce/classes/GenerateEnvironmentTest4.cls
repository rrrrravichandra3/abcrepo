public class GenerateEnvironmentTest4 {
    /*
    * ENVIRONMENT TO TEST: 
    *                       Test_PerformanceCompetencyController
    */
          
    //public static Department__c department;
    public static TF2_Department__c department;
    
    public static CompetencyGroup__c competencyGroup;
    public static CompetencyGroupMember__c competencyGroupMember1;
    public static CompetencyGroupMember__c competencyGroupMember2;
    public static List<CompetencyGroupMember__c> allCompetencyGroupMembers = new List<CompetencyGroupMember__c>();
    public static Competency__c competency;
    
    public static User pcommStandard;
    public static User esadminStandard;
    public static User ceoStandard;
    public static User esbpStandard;
    
    public static User employeeStandard = new User();
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
    
    public static Method__c method1 = new Method__c();
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
    
    public static PerformanceReviewPeriod__c PRPIndividual = new PerformanceReviewPeriod__c();
    public static PerformanceReviewPeriod__c PRPIndividualQ1Q2 = new PerformanceReviewPeriod__c();
    public static PerformanceReviewPeriod__c PRPIndividualQ3Q4 = new PerformanceReviewPeriod__c();

    public static List<PerformanceReviewPeriod__c> allPRPs = new List<PerformanceReviewPeriod__c>();
    
    public static PerformanceReview__c PRIndividual = new PerformanceReview__c();
    public static PerformanceReview__c PRIndividualQ1Q2Edu = new PerformanceReview__c();
    public static PerformanceReview__c PRIndividualQ3Q4Edu = new PerformanceReview__c();
    public static PerformanceReview__c PRIndividualQ1Q2Sup = new PerformanceReview__c();
    public static PerformanceReview__c PRIndividualQ3Q4Sup = new PerformanceReview__c();

    public static List<PerformanceReview__c> allPRs = new List<PerformanceReview__c>();
    public static List<PerformanceReview__c> allPRsManager = new List<PerformanceReview__c>();

    public static boolean createScorecards = true;

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
        
    public static void genScorecardMetricEducation(){
        try {
            getUsers();
            getUser('None');
            
            // create v2moms
            v2momIndividual = createV2MOM(employeeStandard.Id, 'vision individual', 'Individual', 'Test V2MOM Individual', 'FY08', 'My Management Hierarchy');
                    
            v2momIndividualQ1Q2Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
            v2momIndividualQ3Q4Sup = createV2MOM(employeeSupport.Id, 'vision individual Sup Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
                    
            v2momIndividualQ1Q2Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q1Q2', 'Individual Q1/Q2', 'Test V2MOM Individual Q1Q2', 'FY08', 'My Management Hierarchy');
            v2momIndividualQ3Q4Edu = createV2MOM(employeeEducation.Id, 'vision individual Edu Q3Q4', 'Individual Q3/Q4', 'Test V2MOM Individual Q3Q4', 'FY08', 'My Management Hierarchy');
            
            // create the methods for each v2mom        
            method1 = createMethod(v2momIndividual.Id, null, 1, 'Method 1', 'Description method 1');
            method2 = createMethod(v2momIndividual.Id, null, 2, 'Method 2', 'Description method 2');
            
            methodQ1Q2Sup1 = createMethod(v2momIndividualQ1Q2Sup.Id, null, 1, 'Method 1', 'Description method 1');
            methodQ1Q2Sup2 = createMethod(v2momIndividualQ1Q2Sup.Id, null, 2, 'Method 2', 'Description method 2');
            
            methodQ3Q4Sup3 = createMethod(v2momIndividualQ3Q4Sup.Id, null, 1, 'Method 1', 'Description method 1');
            methodQ3Q4Sup4 = createMethod(v2momIndividualQ3Q4Sup.Id, null, 2, 'Method 2', 'Description method 2');
            
            methodQ1Q2Edu1 = createMethod(v2momIndividualQ1Q2Edu.Id, null, 1, 'Method 1', 'Description method 1');
            methodQ1Q2Edu2 = createMethod(v2momIndividualQ1Q2Edu.Id, null, 2, 'Method 2', 'Description method 2');
            
            methodQ3Q4Edu3 = createMethod(v2momIndividualQ3Q4Edu.Id, null, 1, 'Method 1', 'Description method 1');
            methodQ3Q4Edu4 = createMethod(v2momIndividualQ3Q4Edu.Id, null, 2, 'Method 2', 'Description method 2');
            
            upsert(allmethods);
            
            // create the competencies for step 2
            //competencyGroup = [select Id from CompetencyGroup__c where Name = 'CCCompGrp' and Code__c='CCCompGrp'];
            competencyGroup = createCompetencyGroup();
            competency = createCompetency('Test Competency', 'New competency test');
            competencyGroupMember1 = createCompetencyGroupMember('CCCompGrpMember1', competency.Id, competencyGroup.Id, 30);
            
            Competency__c competency1 = new Competency__c();
            competency1 = createCompetency('Test Competency1', 'New competency test1');
            
            competencyGroupMember2 = createCompetencyGroupMember('CCCompGrpMember2', competency1.Id, competencyGroup.Id, 70);
            
            upsert(allCompetencyGroupMembers);
            
            // create other necessary elements
            //reviewFormTemplate = [select Id from ReviewFormTemplate__c where Name = 'CCRevTpl' and Code__c='CCRevTpl'];
            reviewFormTemplate = createReviewFromTemplate();
            department = createDepartment('Test Department', false);
            
            
            Date d1 = System.today();
            Date d2 = d1.addYears(1);
            
            // Create the performance review periods for different V2MOMs types     
            PRPIndividual = createPRP('Test PRP Department', 'FY08', 'Individual', d1, d2);
            System.debug('PRPIndividual ' + PRPIndividual.Id);
            PRPIndividualQ1Q2 = createPRP('Test PRP Individual Q1/Q2', 'FY08', 'Individual Q1/Q2', d1, d2);
            PRPIndividualQ3Q4 = createPRP('Test PRP Individual Q3/Q4', 'FY08', 'Individual Q3/Q4', d1, d2);
            try{
                upsert(allPRPs);
            }catch(Exception e){
                    
            }
            
            
    
            // Create the different performance reviews for each V2MOM type
            PRIndividual = createPerformanceReview('Test PReview Individual', PRPIndividual.Id,
                                             v2momIndividual.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeStandard.Id, reviewManagerStandard.Id, review2ndManagerStandard.Id, pcommStandard.Id, department.Id, 'Employee Self Assessmen');
    
            PRIndividualQ1Q2Edu = createPerformanceReview('Test PReview Edu IndividualQ1Q2', PRPIndividualQ1Q2.Id, 
                                             v2momIndividualQ1Q2Edu.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeEducation.Id, reviewManagerEducation.Id, review2ndManagerEducation.Id,
                                             pcommStandard.Id, department.Id, 'Employee Self Assessmen');
            
            PRIndividualQ3Q4Edu = createPerformanceReview('Test PReview Edu IndividualQ3Q4', PRPIndividualQ3Q4.Id, 
                                             v2momIndividualQ3Q4Edu.Id, competencyGroup.Id, reviewFormTemplate.Id,
                                             employeeEducation.Id, reviewManagerEducation.Id, review2ndManagerEducation.Id, 
                                             pcommStandard.Id, department.Id, 'Manager Assessment');
            try{
                upsert(allPRs);
                upsert(allPRsManager);
            }catch(Exception e){
        
            }
            
            
            if (createScorecards){
                // Create the education scorecards
                sq1Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q1', PRIndividualQ1Q2Edu.Id, reviewManagerEducation.Id, 'Q1');
                sq2Edu = createScorecardSupportReviewWithDataEducation('Test Scorecard Edu Q2', PRIndividualQ1Q2Edu.Id, reviewManagerEducation.Id, 'Q2',
                                                            20, 10, 30, 2, 4, 5, 21, 22, 23, 24, 25, 26);
                sq3Edu = createScorecardSupportReviewEmpty('Test Scorecard Edu Q3', PRIndividualQ3Q4Edu.Id, reviewManagerEducation.Id, 'Q3');
                sq4Edu = createScorecardSupportReviewWithDataEducation('Test Scorecard Edu Q4', PRIndividualQ3Q4Edu.Id, reviewManagerEducation.Id, 'Q4',
                                                            10, 1, 5, 2, 4, 5, 31, 32, 33, 34, 35, 36);
            }
            
            
            try{
                upsert(allScorecards);
            }catch(Exception e){
                    
            }
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
                    
            method2revEmpl = createMethodReview('Method Review employee std method2', PRIndividual.Id, null, null,
                                                'Completed', employeeStandard.Id, method2.Id,
                                                'comment method 2 employee standard');
            
            method2revMngr = createMethodReview('Method Review manager std method2', PRIndividual.Id, 3.0, 65,
                                                null, reviewManagerStandard.Id, method2.Id,
                                                'comment method 2 manager standard');
            
            method2rev2ndMngr = createMethodReview('Method Review 2nd manager stnd method2', PRIndividual.Id, null, null,
                                                null, review2ndManagerStandard.Id, method2.Id,
                                                'comment method 2 2nd manager standard');           
    
    
            
            methodQ1Q2Edu1revEmpl = createMethodReview('Method Review employee sup methodQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, null, null,
                                                'N/A', employeeEducation.Id, methodQ1Q2Edu1.Id,
                                                'comment methodQ1Q2Edu1 employee education');
            
            methodQ1Q2Edu1revMngr = createMethodReview('Method Review manager sup methodQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, 1.0, 30,
                                                null, reviewManagerEducation.Id, methodQ1Q2Edu1.Id,
                                                'comment methodQ1Q2Edu1 manager education');
            
            methodQ1Q2Edu1rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, null, null,
                                                null, review2ndManagerEducation.Id, methodQ1Q2Edu1.Id,
                                                'comment methodQ1Q2Edu1 2nd manager education');
            
            methodQ1Q2Edu2revEmpl = createMethodReview('Method Review employee sup methodQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, null, null,
                                                'In Progress', employeeEducation.Id, methodQ1Q2Edu2.Id,
                                                'comment methodQ1Q2Edu2 employee education');
            
            methodQ1Q2Edu2revMngr = createMethodReview('Method Review manager sup methodQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, 4.0, 70,
                                                null, reviewManagerEducation.Id, methodQ1Q2Edu2.Id,
                                                'comment method 2 manager education');
            
            methodQ1Q2Edu2rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, null, null,
                                                null, review2ndManagerEducation.Id, methodQ1Q2Edu2.Id,
                                                'comment methodQ1Q2Edu2 2nd manager education');
            
            methodQ3Q4Edu3revEmpl = createMethodReview('Method Review employee sup methodQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, null, null,
                                                'N/A', employeeEducation.Id, methodQ3Q4Edu3.Id,
                                                'comment methodQ3Q4Edu3 employee education');
            
            methodQ3Q4Edu3revMngr = createMethodReview('Method Review manager sup methodQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, 5.0, 10,
                                                null, reviewManagerEducation.Id, methodQ3Q4Edu3.Id,
                                                'comment methodQ3Q4Edu3 manager education');
            
            methodQ3Q4Edu3rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, null, null,
                                                null, review2ndManagerEducation.Id, methodQ3Q4Edu3.Id,
                                                'comment methodQ3Q4Edu3 2nd manager education');
            
            methodQ3Q4Edu4revEmpl = createMethodReview('Method Review employee sup methodQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, null, null,
                                                'In Progress', employeeEducation.Id, methodQ3Q4Edu4.Id,
                                                'comment methodQ3Q4Edu4 employee education');
            
            methodQ3Q4Edu4revMngr = createMethodReview('Method Review manager sup methodQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, 2.0, 90,
                                                null, reviewManagerEducation.Id, methodQ3Q4Edu4.Id,
                                                'comment methodQ3Q4Edu4 manager education');
            
            methodQ3Q4Edu4rev2ndMngr = createMethodReview('Method Review 2nd manager sup methodQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, null, null,
                                                null, review2ndManagerEducation.Id, methodQ3Q4Edu4.Id,
                                                'comment methodQ3Q4Edu4 2nd manager education');
            try{
                upsert(allMethodReviews);   
            }catch(Exception e){
                
            }
            
    
            
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
                    
            competency2revEmpl = createCompetencyReview('Competency Review employee std competency2', PRIndividual.Id, null,
                                                employeeStandard.Id, competencyGroupMember2.Id,
                                                'comment competency 2 employee standard');
            
            competency2revMngr = createCompetencyReview('Competency Review manager std competency2', PRIndividual.Id, 3.0,
                                                reviewManagerStandard.Id, competencyGroupMember2.Id,
                                                'comment competency 2 manager standard');
            
            competency2rev2ndMngr = createCompetencyReview('Competency Review 2nd manager stnd competency2', PRIndividual.Id, null,
                                                review2ndManagerStandard.Id, competencyGroupMember2.Id,
                                                'comment competency 2 2nd manager standard');           
    
            competencyQ1Q2Edu1revEmpl = createCompetencyReview('Competency Review employee sup competencyQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, null,
                                                employeeEducation.Id, competencyGroupMember1.Id,
                                                'comment competencyQ1Q2Edu1 employee education');
            
            competencyQ1Q2Edu1revMngr = createCompetencyReview('Competency Review manager sup competencyQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, 1.0,
                                                reviewManagerEducation.Id, competencyGroupMember1.Id,
                                                'comment competencyQ1Q2Edu1 manager education');
            
            competencyQ1Q2Edu1rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ1Q2Edu1', PRIndividualQ1Q2Edu.Id, null,
                                                review2ndManagerEducation.Id, competencyGroupMember1.Id,
                                                'comment competencyQ1Q2Edu1 2nd manager education');
            
            competencyQ1Q2Edu2revEmpl = createCompetencyReview('Competency Review employee sup competencyQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, null,
                                                employeeEducation.Id, competencyGroupMember2.Id,
                                                'comment competencyQ1Q2Edu2 employee education');
            
            competencyQ1Q2Edu2revMngr = createCompetencyReview('Competency Review manager sup competencyQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, 4.0,
                                                reviewManagerEducation.Id, competencyGroupMember2.Id,
                                                'comment competency 2 manager education');
            
            competencyQ1Q2Edu2rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ1Q2Edu2', PRIndividualQ1Q2Edu.Id, null,
                                                review2ndManagerEducation.Id, competencyGroupMember2.Id,
                                                'comment competencyQ1Q2Edu2 2nd manager education');
            
            competencyQ3Q4Edu3revEmpl = createCompetencyReview('Competency Review employee sup competencyQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, null,
                                                employeeEducation.Id, competencyGroupMember1.Id,
                                                'comment competencyQ3Q4Edu3 employee education');
            
            competencyQ3Q4Edu3revMngr = createCompetencyReview('Competency Review manager sup competencyQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, 5.0,
                                                reviewManagerEducation.Id, competencyGroupMember1.Id,
                                                'comment competencyQ3Q4Edu3 manager education');
            
            competencyQ3Q4Edu3rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ3Q4Edu3', PRIndividualQ3Q4Edu.Id, null,
                                                review2ndManagerEducation.Id, competencyGroupMember1.Id,
                                                'comment competencyQ3Q4Edu3 2nd manager education');
            
            competencyQ3Q4Edu4revEmpl = createCompetencyReview('Competency Review employee sup competencyQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, null,
                                                employeeEducation.Id, competencyGroupMember2.Id,
                                                'comment competencyQ3Q4Edu4 employee education');
            
            competencyQ3Q4Edu4revMngr = createCompetencyReview('Competency Review manager sup competencyQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, 2.0,
                                                reviewManagerEducation.Id, competencyGroupMember2.Id,
                                                'comment competencyQ3Q4Edu4 manager education');
            
            competencyQ3Q4Edu4rev2ndMngr = createCompetencyReview('Competency Review 2nd manager sup competencyQ3Q4Edu4', PRIndividualQ3Q4Edu.Id, null,
                                                review2ndManagerEducation.Id, competencyGroupMember2.Id,
                                                'comment competencyQ3Q4Edu4 2nd manager education');
            try{
                upsert(allCompetencyReviews);   
            }catch(Exception e){
                
            }
            
            
            overallrevEmpl = createOverallReview('overall review Empl stnd', PRIndividual.Id, '', '', '', '', 
                                                    employeeStandard.Id, 'comment Empl stnd overall');
            
            overallrevMngr = createOverallReview('overall review Mngr stnd', PRIndividual.Id, '', '', '', '', 
                                                    reviewManagerStandard.Id, 'comment Mngr stnd overall');
            
            overallrev2ndMngr = createOverallReview('overall review 2nd Mngr stnd', PRIndividual.Id, '', '', '', '', 
                                                    review2ndManagerStandard.Id, 'comment 2nd Mngr stnd overall');
    
            overallQ1Q2EdurevEmpl = createOverallReview('overall review Empl edu', PRIndividualQ1Q2Edu.Id, '', '', '', '', 
                                                    employeeEducation.Id, 'comment Empl edu overall');
            
            overallQ1Q2EdurevMngr = createOverallReview('overall review Mngr edu', PRIndividualQ1Q2Edu.Id, '', '', '', '', 
                                                    reviewManagerEducation.Id, 'comment Mngr edu overall');
            
            overallQ1Q2Edurev2ndMngr = createOverallReview('overall review 2nd Mngr edu', PRIndividualQ1Q2Edu.Id, '', '', '', '', 
                                                    review2ndManagerEducation.Id, 'comment 2nd Mngr edu overall');
                    
            overallQ3Q4EdurevEmpl = createOverallReview('overall review Empl edu', PRIndividualQ3Q4Edu.Id, '', '', '', '', 
                                                    employeeEducation.Id, 'comment Empl edu overall');
            
            overallQ3Q4EdurevMngr = createOverallReview('overall review Mngr edu', PRIndividualQ3Q4Edu.Id, '', '', '', '', 
                                                    reviewManagerEducation.Id, 'comment Mngr edu overall');
            
            overallQ3Q4Edurev2ndMngr = createOverallReview('overall review 2nd Mngr edu', PRIndividualQ3Q4Edu.Id, '', '', '', '', 
                                                    review2ndManagerEducation.Id, 'comment 2nd Mngr edu overall');
            try{
                upsert(allOverallReviews);  
            
            
    
            reviewRating = createOverallRating('overall rating Mngr stnd', PRIndividual.Id, 2.0, 3.2, reviewManagerStandard.Id);
            reviewRatingQ1Q2Edu = createOverallRating('overall rating Mngr edu q1q2', PRIndividualQ1Q2Edu.Id, 3.0, 1.3, reviewManagerEducation.Id);
            reviewRatingQ3Q4Edu = createOverallRating('overall rating Mngr edu q3q4', PRIndividualQ3Q4Edu.Id, 4.0, 0.5, reviewManagerEducation.Id);
            
            upsert(allOverallRatings);
            
            }catch(Exception e){
                
            }
    
            if (createScorecards){
    
                sscommQ1Q2EdurevEmpl = createScorecardSupportReviewComment(PRIndividualQ1Q2Edu.Id,
                                                                                employeeEducation.Id, 
                                                                                'CS comm Q1Q2 employee sup',
                                                                                'renewals comm Q1Q2 employee sup',
                                                                                'WMCases comm Q1Q2 employee sup',
                                                                                'WMSMES comm Q1Q2 employee sup', 
                                                                                'WMHC comm Q1Q2 employee sup',
                                                                                'WMPA comm Q1Q2 employee sup',
                                                                                'supportInitiatives comm Q1Q2 employee sup',
                                                                                'salesImpact comm Q1Q2 employee sup',
                                                                                'timeOnPlatform comm Q1Q2 employee sup',
                                                                                'forecastAccuracy comm Q1Q2 employee sup');
                
                sscommQ1Q2EdurevMngr = createScorecardSupportReviewComment(PRIndividualQ1Q2Edu.Id,
                                                                                reviewManagerEducation.Id, 
                                                                                'CS comm Q1Q2 manager sup',
                                                                                'renewals comm Q1Q2 manager sup',
                                                                                'WMCases comm Q1Q2 manager sup',
                                                                                'WMSMES comm Q1Q2 manager sup', 
                                                                                'WMHC comm Q1Q2 manager sup',
                                                                                'WMPA comm Q1Q2 manager sup',
                                                                                'supportInitiatives comm Q1Q2 manager sup',
                                                                                'salesImpact comm Q1Q2 manager sup',
                                                                                'timeOnPlatform comm Q1Q2 manager sup',
                                                                                'forecastAccuracy comm Q1Q2 manager sup');
                
                sscommQ1Q2Edurev2ndMngr = createScorecardSupportReviewComment(PRIndividualQ1Q2Edu.Id,
                                                                                review2ndManagerEducation.Id, 
                                                                                'CS comm Q1Q2 secondManager sup',
                                                                                'renewals comm Q1Q2 secondManager sup',
                                                                                'WMCases comm Q1Q2 secondManager sup',
                                                                                'WMSMES comm Q1Q2 secondManager sup', 
                                                                                'WMHC comm Q1Q2 secondManager sup',
                                                                                'WMPA comm Q1Q2 secondManager sup',
                                                                                'supportInitiatives comm Q1Q2 secondManager sup',
                                                                                'salesImpact comm Q1Q2 secondManager sup',
                                                                                'timeOnPlatform comm Q1Q2 secondManager sup',
                                                                                'forecastAccuracy comm Q1Q2 secondManager sup');
                        
                sscommQ3Q4EdurevEmpl = createScorecardSupportReviewComment(PRIndividualQ3Q4Edu.Id,
                                                                                employeeEducation.Id, 
                                                                                'CS comm Q3Q4 employee sup',
                                                                                'renewals comm Q3Q4 employee sup',
                                                                                'WMCases comm Q3Q4 employee sup',
                                                                                'WMSMES comm Q3Q4 employee sup', 
                                                                                'WMHC comm Q3Q4 employee sup',
                                                                                'WMPA comm Q3Q4 employee sup',
                                                                                'supportInitiatives comm Q3Q4 employee sup',
                                                                                'salesImpact comm Q3Q4 employee sup',
                                                                                'timeOnPlatform comm Q3Q4 employee sup',
                                                                                'forecastAccuracy comm Q3Q4 employee sup');
                
                sscommQ3Q4EdurevMngr = createScorecardSupportReviewComment(PRIndividualQ3Q4Edu.Id,
                                                                                reviewManagerEducation.Id, 
                                                                                'CS comm Q3Q4 manager sup',
                                                                                'renewals comm Q3Q4 manager sup',
                                                                                'WMCases comm Q3Q4 manager sup',
                                                                                'WMSMES comm Q3Q4 manager sup', 
                                                                                'WMHC comm Q3Q4 manager sup',
                                                                                'WMPA comm Q3Q4 manager sup',
                                                                                'supportInitiatives comm Q3Q4 manager sup',
                                                                                'salesImpact comm Q3Q4 manager sup',
                                                                                'timeOnPlatform comm Q3Q4 manager sup',
                                                                                'forecastAccuracy comm Q3Q4 manager sup');
                
                sscommQ3Q4Edurev2ndMngr = createScorecardSupportReviewComment(PRIndividualQ3Q4Edu.Id,
                                                                                review2ndManagerEducation.Id, 
                                                                                'CS comm Q3Q4 secondManager sup',
                                                                                'renewals comm Q3Q4 secondManager sup',
                                                                                'WMCases comm Q3Q4 secondManager sup',
                                                                                'WMSMES comm Q3Q4 secondManager sup', 
                                                                                'WMHC comm Q3Q4 secondManager sup',
                                                                                'WMPA comm Q3Q4 secondManager sup',
                                                                                'supportInitiatives comm Q3Q4 secondManager sup',
                                                                                'salesImpact comm Q3Q4 secondManager sup',
                                                                                'timeOnPlatform comm Q3Q4 secondManager sup',
                                                                                'forecastAccuracy comm Q3Q4 secondManager sup');
        
                upsert(allSSComms);
            }
        } catch (Exception e) {
            System.debug(' ****************** genScorecardMetricEducation * ');
            System.debug(e.getMessage());
        }
    }
    
    public static V2MOM__c createV2MOM(Id user, String vision, String t, String name, 
                                        String effDate, String share){
        V2MOM__c v = new V2MOM__c ( OwnerId=user,
                                        Vision__c = vision, 
                                        V2MOM_Type__c = t,
                                        Name = name, 
                                        Effective_Date__c = effDate,
                                        Share_With__c = share);
        //allv2moms.add(v);
    try{
        upsert(v);
    }catch (Exception e) {
                }
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
        
    public static ScorecardSupportReview__c createScorecardSupportReviewEmpty(String pname, 
                                                                        Id pr,
                                                                        Id reviewer,
                                                                        String fq){
        ScorecardSupportReview__c s = new ScorecardSupportReview__c (Name = pname,
                                                                    PerformanceReview__c = pr,
                                                                    Reviewer__c = reviewer,
                                                                    FiscalQuarter__c = fq);

        
        allScorecards.add(s);
        
        return s;
    }

    public static ScorecardSupportReview__c createScorecardSupportReviewWithDataEducation(String pname, 
                                                                        Id pr,
                                                                        Id reviewer,
                                                                        String fq,
                                                                        Double forecastAccuracyWeight,
                                                                        Double salesImpactWeight,
                                                                        Double timeOnPlatformWeight,  
                                                                        Double forecastAccuracyRating,
                                                                        Double salesImpactRating,
                                                                        Double timeOnPlatformRating,
                                                                        Double forecastAccuracyActual,
                                                                        Double forecastAccuracyTarget,
                                                                        Double timeOnPlatformTarget,
                                                                        Double timeOnPlatformActual,
                                                                        Double salesImpactActual,
                                                                        Double salesImpactTarget) {

        ScorecardSupportReview__c s = new ScorecardSupportReview__c (Name = pname,
                                                                    PerformanceReview__c = pr,
                                                                    Reviewer__c = reviewer,
                                                                    FiscalQuarter__c = fq);
        
        s.ForecastAccuracyWeight__c = forecastAccuracyWeight;
        s.SalesImpactWeight__c = salesImpactWeight;
        s.TimeOnPlatformWeight__c = timeOnPlatformWeight;  
        s.ForecastAccuracyRating__c = forecastAccuracyRating;
        s.SalesImpactRating__c = salesImpactRating;
        s.TimeOnPlatformRating__c = timeOnPlatformRating;
        s.ForecastAccuracyActual__c = forecastAccuracyActual;
        s.ForecastAccuracyTarget__c = forecastAccuracyTarget;
        s.TimeOnPlatformTarget__c = timeOnPlatformTarget;
        s.TimeOnPlatformActual__c = timeOnPlatformActual;
        s.SalesImpactActual__c = salesImpactActual;
        s.SalesImpactTarget__c = salesImpactTarget;
        
        allScorecards.add(s);
        
        return s;
    }
    
    public static ScorecardSupportComment__c createScorecardSupportReviewComment(Id pr,
                                                                        Id reviewer, 
                                                                        String CS,
                                                                        String renewals,
                                                                        String WMCases,
                                                                        String WMSMES, 
                                                                        String WMHC,
                                                                        String WMPA,
                                                                        String supportInitiatives,
                                                                        String salesImpact,
                                                                        String timeOnPlatform,
                                                                        String forecastAccuracy){
        
        ScorecardSupportComment__c s;
        
        if (emptySSComm){
            s = new ScorecardSupportComment__c (Reviewer__c = reviewer,
                                                PerformanceReview__c = pr);
        }
        
        if (!emptySSComm){
            s = new ScorecardSupportComment__c (Reviewer__c = reviewer,
                                                PerformanceReview__c = pr,
                                                CommentWMSMES__c = WMSMES,
                                                CommentWMPA__c = WMPA,
                                                CommentWMHC__c = WMHC,
                                                CommentWMCases__c = WMCases,
                                                CommentTimeOnPlatform__c = timeOnPlatform,
                                                CommentSupportInitiatives__c = supportInitiatives,
                                                CommentSalesImpact__c = salesImpact,
                                                CommentRenewals__c = renewals,
                                                CommentForecastAccuracy__c = forecastAccuracy,
                                                CommentCS__c = CS);
        }
        
        allSSComms.add(s);
        
        return s;
        
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
        //Id owner=userInfo.getUserId();                                                    
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
                                                where ( username=:GenerateEnvironmentTestUsers.ccpcomm 
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
                                                or username=:GenerateEnvironmentTestUsers.cccsmempl)
                                                
                                                and isActive=true                                               
                                                ];
                                                
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
                                                              Id empl, Id mngr, Id sndMngr, Id pcomm, Id dpt, String status){
                                                            
        PerformanceReview__c pr = new PerformanceReview__c(Name = pname,
                                                           PerformanceReviewPeriod__c = prp,
                                                           V2MOM__c = v2,
                                                           CompetencyGroup__c = cgrp,
                                                           ReviewFormTemplate__c = rftpl,
                                                           Employee__c = empl,
                                                           Manager__c = mngr,
                                                           SecondManager__c = sndMngr,
                                                           PCOMM__c = pcomm,
                                                           Cost_Center__c = dpt,
                                                           Status__c = status);
                                                           //Department__c = dpt,
        
        if (status == 'Manager Assessment') {                                                               
            allPRsManager.add(pr);
        }
        else {
            allPRs.add(pr);
        }
        
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
    @isTest
    static  void test1(){
        PerformanceReview__c pr = [select id from performanceReview__c limit 1];
        User u = [Select id from User where isActive=true limit 1];
        V2mom__c v2mom = [Select id from v2mom__c limit 1];
        Value__c value =[Select id from value__c limit 1];
        String previousStatus='Created';
        String newStatus= 'Manager Assessment';
        
        GenerateEnvironmentTest4.genScorecardMetricEducation();
        GenerateEnvironmentTest4.changeStatusPReview(pr, previousStatus, newStatus);
        GenerateEnvironmentTest4.createReviewFromTemplate();
        GenerateEnvironmentTest4.createCompetency('Name', 'Description');
        CompetencyGroupMember__c comp = GenerateEnvironmentTest4.createCompetencyGroupMember('Group Member',GenerateEnvironmentTest4.createCompetency('Name', 'Description').id,GenerateEnvironmentTest4.createCompetencyGroup().id, 4 );
        PerformanceReviewPeriod__c prp = GenerateEnvironmentTest4.createPRP('Name', '12/12/2012', 'Year End', Date.today(), Date.today());
        GenerateEnvironmentTest4.createScorecardSupportReviewWithDataEducation('name', pr.id, u.id, 'Q3', 2.7, 0.9, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
        GenerateEnvironmentTest4.createScorecardSupportReviewComment(pr.id, u.id, 'CS', 'renewals', 'WMCases', 'WMSMES', 'WMHC', 'WMPA', 'supportInitiatives', 'salesImpact', 'timeOnPlatform', 'forecastAccuracy');
        GenerateenvironmentTest4.createDepartment('Test', true);
        GenerateEnvironmentTest4.createCompetencyReview('oname', pr.id, 2.0, u.id, comp.id, 'comment');
        GenerateEnvironmentTest4.createOverallReview('oname', pr.id, 'updtMeth', 'suggComp', 'suggMeth', 'commComp', u.id, 'comment');
        GenerateEnvironmentTest4.createOverallRating('oname', pr.id, 2.0, 3.0, u.id);
        GenerateenvironmentTest4.createScorecardSupportReviewEmpty('name', pr.id, u.id, 'Q1');
        Method__c meth = GenerateEnvironmentTest4.createMethod(v2mom.id, value.id, 1, 'name', 'Description');
        
        GenerateEnvironmentTest4.createMethodReview('oname', pr.id, 2.0, 2, 'Approved', u.id, meth.id, 'comment');
        GenerateEnvironmentTest4.createPerformanceReview('pname', prp.id, v2mom.id, GenerateEnvironmentTest4.createCompetencyGroup().id, GenerateEnvironmentTest4.createReviewFromTemplate().id, u.id, u.id, u.id, u.id, GenerateEnvironmentTest4.createDepartment('Test2', true).id, 'Created');
        GenerateEnvironmentTest4.createPerformanceReview('pname', prp.id, v2mom.id, GenerateEnvironmentTest4.createCompetencyGroup().id, GenerateEnvironmentTest4.createReviewFromTemplate().id, u.id, u.id, u.id, u.id, GenerateEnvironmentTest4.createDepartment('Test2', true).id, 'Manager Assessment');
    }
}