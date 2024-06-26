@isTest
private class TestPF_PerformanceReviewPrint_Unit {
    static testMethod void oneTest() {
        test.startTest();
        
            PerformanceReviewPrint prp = new PerformanceReviewPrint();
            String performanceId = [Select id From PerformanceReview__c limit 1][0].id;
            prp.performanceRevId = performanceId;
            prp.constructor();
            PerformanceReview__c testPerformance = prp.getPerformanceReviewWithoutSharing(performanceId);
            prp.getAllMethodWeightSum();
            prp.getAvgRatingMethods();
            prp.getCommentsHistory();
            prp.getCompetencies();
            prp.getCompetencyCalculatedRatingWithinCompetencies();  
            prp.getScorecardCommentWithoutSharing();
            List<Method__c> methods = [Select m.id, 
                                            m.name, 
                                            m.Value__c, 
                                            m.Value__r.Name, 
                                            m.Description__c, 
                                            (Select name, description__c From Obstacles__r ORDER BY Priority__c),  
                                            (Select name, description__c From Measures__r ORDER BY Priority__c)
                                        From Method__c m];
            prp.getPerformanceReviewCommentWithoutSharing(testPerformance, methods);
            prp.getPerformanceReviewEmployeeWithoutSharing(testPerformance, methods);
            prp.getPerformanceReviewDataWithoutSharing(testPerformance, methods);                           
            prp.setScorecardHasComments();
            List<PerformanceReview__c> performances = [ Select      id,  name, Employee__c, Employee__r.Name, Manager__c, Manager__r.Name,  SecondManager__c,SecondManager__r.Name,  PCOMM__c, PCOMM__r.Name, ThirdPartyReviewer__c, CompetencyGroup__c,  CompetencyGroup__r.Name,  PerformanceReviewPeriod__c,  PerformanceReviewPeriod__r.name, PerformanceReviewPeriod__r.Effective_Date__c,  ReviewFormTemplate__c,  ReviewFormTemplate__r.MethodWeight__c,  ReviewFormTemplate__r.CompetencyWeight__c,  V2MOM__c,  V2MOM__r.V2MOM_Type__c,  V2MOM__r.Vision__c,
                                                                OwnerId, Status__c, PreviousStatus__c, EmailComment__c, ReviewRating__c, PremierUser__c, ReviewRating__r.OverallRating__c  
                                                        From PerformanceReview__c limit 5];
            
            for(PerformanceReview__c perf : performances ){
                prp.setPerformanceRev(perf);
                prp.getMethods();
                prp.getMethodAndMetricWeight();
                prp.getAllMethodWeightSum();
            } 
            prp.getShowSupportScorecard();
            prp.getDisplayCompetencyCalculatedRating();
            prp.getDisplayMethodCalculatedWeight();
            prp.getDisplayMetricCalculatedWeight();
            prp.getDisplayMetricCalculatedRating();
            prp.getDisplayOverallCalculatedRating();
            prp.getDisplayOverallRating();
            PerformanceReview__History prHistory = [Select CreatedDate, Field, OldValue, NewValue From PerformanceReview__History][0];
            
            prp.getPerformanceReviewHistory();         
            prp.isPCOMMLikeViewProfile = true;
            system.assert( prp.isPCOMMLikeViewProfile );
            prp.getCompetencies();
            prp.constructor();
            
                                            
        test.stopTest();        
        
    }
    
    
    static testMethod void testGetHasComments() {
        PerformanceReviewPrint prp = new PerformanceReviewPrint();
        system.assert(!prp.getHasCommentCS());
        system.assert(!prp.getHasCommentRenewals());
        system.assert(!prp.getHasCommentSI());
        system.assert(!prp.getHasCommentWMCases());
        system.assert(!prp.getHasCommentWMSMES());
        system.assert(!prp.getHasCommentWMPA());
        system.assert(!prp.getHasCommentWMHC());
        system.assert(!prp.getHasCommentWMCCP());
        system.assert(!prp.getHasCommentWMCAA());
        system.assert(!prp.getHasCommentForecastAccuracy());
        system.assert(!prp.getHasCommentSalesImpact());
        system.assert(!prp.getHasCommentTimeOnPlatform());
        system.assert(!prp.getHasCommentCSMSalesImpact());
        system.assert(!prp.getHasCommentRenewalExcellence());
        system.assert(!prp.getHasCommentOperationalExcellence());
        system.assert(!prp.getHasCommentStrategicInitiatives());        
    }
    
    static testMethod void testValue() {
        User employee = GenerateEnvironmentTest.getEmployeeStandard();
        V2MOM__c v2mom = new V2MOM__c();
        Value__c value = new Value__c(V2MOM__r = v2mom, Priority__c = 1, Name='Value 1');
        Method__c method = new Method__c(V2MOM__r = v2mom, Priority__c = 1, Name='Method 1');
        
        Date sdate = System.today();
        Date edate = sdate.addYears(1);
        PerformanceReviewPeriod__c performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
                                                                                Effective_Date__c = 'FY11',
                                                                                V2MOM_Type__c = 'Individual',
                                                                                StartDate__c = sdate,
                                                                                EndDate__c = edate);
        CompetencyGroup__c competencyGroup = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
        Competency__c competency = new Competency__c(Name = 'Competency1');
        CompetencyGroupMember__c competencyGroupMember = new CompetencyGroupMember__c(CompetencyGroup__c = competencyGroup.Id, Competency__c = competency.Id );
        ReviewFormTemplate__c reviewFormTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
        String statusThirdParty='3rd Party Assessment';
        String statusManagerAssessment = 'Manager Assessment';
        //Department__c department =  GenerateEnvironmentTest3.createDepartment('Test Department', false);
        TF2_Department__c department =  GenerateEnvironmentTest3.createDepartment('Test Department', false);
        
        PerformanceReview__c p = new PerformanceReview__c(Name = 'Performance Review',
                                                                   PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
                                                                   V2MOM__c = v2mom.Id,
                                                                   CompetencyGroup__c = competencyGroup.Id,
                                                                   ReviewFormTemplate__c = reviewFormTemplate.Id,
                                                                   Employee__c = employee.Id,
                                                                   Manager__c = employee.Id,
                                                                   SecondManager__c = employee.Id,
                                                                   PCOMM__c = employee.Id,
                                                                   Cost_Center__c = department.Id,
                                                                   Status__c = statusThirdParty,
                                                                   PreviousStatus__c = statusManagerAssessment); 
                                                                   //Department__c = department.Id,
                                                                   
        
        PerformanceMethodController controller = new PerformanceMethodController(method,p); 
        List<PerformanceMethodController> controllerList = new List<PerformanceMethodController>();
        controllerList.add(controller); 
        
        test.startTest();   
            PerformanceReviewPrint.Value v = new PerformanceReviewPrint.Value(value,controllerList); 
            v.getId();
            system.assertEquals(value.Name, v.getName() );
            v.getMethods();
            System.assertEquals( controllerList.size() ,v.getMethodCount());
        test.stopTest();
    }
    
    
      
    static testMethod void testGetCompetencyReviewWithSharingMap() {
        User employee = GenerateEnvironmentTest.getEmployeeStandard();
        V2MOM__c v2mom = new V2MOM__c();
        Value__c value = new Value__c(V2MOM__r = v2mom, Priority__c = 1, Name='Value 1');
        Method__c method = new Method__c(V2MOM__r = v2mom, Priority__c = 1, Name='Method 1');
        
        Date sdate = System.today();
        Date edate = sdate.addYears(1);
        PerformanceReviewPeriod__c performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
                                                                                Effective_Date__c = 'FY11',
                                                                                V2MOM_Type__c = 'Individual',
                                                                                StartDate__c = sdate,
                                                                                EndDate__c = edate);
        CompetencyGroup__c competencyGroup = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
        Competency__c competency = new Competency__c(Name = 'Competency1');
        CompetencyGroupMember__c competencyGroupMember = new CompetencyGroupMember__c(CompetencyGroup__c = competencyGroup.Id, Competency__c = competency.Id );
        ReviewFormTemplate__c reviewFormTemplate = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
        String statusThirdParty='3rd Party Assessment';
        String statusManagerAssessment = 'Manager Assessment';
        //Department__c department =  GenerateEnvironmentTest3.createDepartment('Test Department', false);
        TF2_Department__c department =  GenerateEnvironmentTest3.createDepartment('Test Department', false);
        
        PerformanceReview__c p = new PerformanceReview__c(Name = 'Performance Review',
                                                                   PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
                                                                   V2MOM__c = v2mom.Id,
                                                                   CompetencyGroup__c = competencyGroup.Id,
                                                                   ReviewFormTemplate__c = reviewFormTemplate.Id,
                                                                   Employee__c = employee.Id,
                                                                   Manager__c = employee.Id,
                                                                   SecondManager__c = employee.Id,
                                                                   PCOMM__c = employee.Id,
                                                                   Cost_Center__c = department.Id,
                                                                   Status__c = statusThirdParty,
                                                                   PreviousStatus__c = statusManagerAssessment); 
                                                                   //Department__c = department.Id,
        
        List<CompetencyGroupMember__c> memberList = new List<CompetencyGroupMember__c>();
        memberList.add(competencyGroupMember);  
        test.startTest();
            PerformanceReviewPrint prp = new PerformanceReviewPrint();
            Map<Id, CompetencyReview__c> result = prp.getCompetencyReviewWithSharingMap(p, memberList);
            system.assertEquals('Performance Review', p.Name);
        test.stopTest();
    }
    
          
    static testMethod void testPerformanceReviewHistory() {
        PerformanceReview__History ph = [select id, createdDate from PerformanceReview__History limit 1];

        PerformanceReviewPrint prp = new PerformanceReviewPrint();
        test.startTest();
            PerformanceReviewPrint.PerformanceReviewHistoryDate prhd = new PerformanceReviewPrint.PerformanceReviewHistoryDate(ph);
            String sDate = prhd.getCreatedDate();
            String expectedDate = ph.CreatedDate.format();          
            prhd.getPerformanceReviewHistory();
            prhd.setCreatedDate('');
            prhd.setPerformanceReviewHistory(ph);
            system.assertEquals(expectedDate, sDate);
        test.stopTest();
    }
    
    static testMethod void testOtherMethods(){
        Date endDate = Date.today().addYears(1);
        Date startDate = Date.today();
        User employee = GenerateEnvironmentTest.getEmployeeStandard();
        User manager = GenerateEnvironmentTest.getManager();
        User secondManager = GenerateEnvironmentTest.getSecondManager();
        User pcomm = GenerateEnvironmentTest.getPCOMMUser();
        V2MOM__c v2mom = GenerateEnvironmentTest.createV2MOM(employee.Id, 'prprint vision', 'Individual', 'v2mom prprint name', 'FY10', 'My Management Hierarchy');
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest.createPRP('PRPPrint test', 'FY10', 'Individual', startDate , endDate );
        CompetencyGroup__c cgroup = GenerateEnvironmentTest.createCompetencyGroup('PRPrint','PRPrint code');
        Competency__c competency = GenerateEnvironmentTest.createCompetency('PRPrint name','desc');
        CompetencyGroupMember__c cgMember = GenerateEnvironmentTest.createCompetencyGroupMember('cgm', 'cgmCode', competency.Id, cgroup.Id, 23);
        ReviewFormTemplate__c rft = GenerateEnvironmentTest.createReviewFromTemplate('RFT Print', 'RFT Print Code');
        
        //Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        TF2_Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        
        PerformanceReview__c review = GenerateEnvironmentTest.createPReviewNormal('PRPrint test', period.Id, v2mom.Id, cgroup.Id, rft.Id, employee.Id, manager.Id, secondManager.Id, pcomm.Id, department.Id);
        ScorecardSupportReview__c ssr = new ScorecardSupportReview__c(name = 'ssr name', Comment__c = 'ssr comment', FiscalQuarter__c = 'Q1', PerformanceReview__r = review, PerformanceReviewPeriod__r = period, Reviewer__r = employee);
        ScorecardSupportComment__c ssComment = new ScorecardSupportComment__c(Reviewer__r = employee, PerformanceReview__r = review, name = 'SSC', ScorecardSupportReview__r = ssr);
        List<ScorecardSupportComment__c> commentList = new List<ScorecardSupportComment__c>();
        commentList.add(ssComment);  
        ApexPages.currentPage().getParameters().put('id', review.Id);
        test.startTest();
            PerformanceReviewPrint prp = new PerformanceReviewPrint();
            prp.getIsPremierUser();
            prp.getIsScorecardProfile();
            prp.orderScorecardReviewList(commentList);
            prp.getIsApproved();
            prp.getPerformanceReview();
            prp.getScorecardSupport();
            prp.getEmployee();
            prp.getManager();
            prp.getSecondManager();
            prp.getPComm();
            prp.getReviewFormTemplate();
            prp.getPerformanceReviewPeriodStartDate();
            prp.getPerformanceReviewPeriodEndDate();
            prp.getNameOwner();
            prp.getUserProfile();
            prp.getIsQuarterV2MOM();
            prp.getMethodAndMetricWeightShow();
            system.runAs( GenerateEnvironmentTest.getSystemAdmin() ){
                prp.getDisplayMethodCalculatedRating();
            }
            system.assert(!prp.getIsOldPerformanceReview());
            
        test.stopTest();
      
    }
    
    static testMethod void testOrderOverallReviewList(){
        Date endDate = Date.today().addYears(1);
        Date startDate = Date.today();
        User employee = GenerateEnvironmentTest.getEmployeeStandard();
        User manager = GenerateEnvironmentTest.getManager();
        User secondManager = GenerateEnvironmentTest.getSecondManager();
        User pcomm = GenerateEnvironmentTest.getPCOMMUser();
        V2MOM__c v2mom = GenerateEnvironmentTest.createV2MOM(employee.Id, 'prprint vision', 'Individual', 'v2mom prprint name', 'FY10', 'My Management Hierarchy');
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest.createPRP('PRPPrint test', 'FY10', 'Individual', startDate , endDate );
        CompetencyGroup__c cgroup = GenerateEnvironmentTest.createCompetencyGroup('PRPrint','PRPrint code');
        Competency__c competency = GenerateEnvironmentTest.createCompetency('PRPrint name','desc');
        CompetencyGroupMember__c cgMember = GenerateEnvironmentTest.createCompetencyGroupMember('cgm', 'cgmCode', competency.Id, cgroup.Id, 23);
        ReviewFormTemplate__c rft = GenerateEnvironmentTest.createReviewFromTemplate('RFT Print', 'RFT Print Code');
        
        //Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        TF2_Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        
        PerformanceReview__c review = GenerateEnvironmentTest.createPReviewNormal('PRPrint test', period.Id, v2mom.Id, cgroup.Id, rft.Id, employee.Id, manager.Id, secondManager.Id, pcomm.Id, department.Id);
        AdditionalComment__c employeeComment = new AdditionalComment__c(Reviewer__r = employee, PerformanceReview__r = review);
        AdditionalComment__c managerComment = new AdditionalComment__c(Reviewer__r = manager, PerformanceReview__r = review);
        AdditionalComment__c secondManagerComment = new AdditionalComment__c(Reviewer__r = secondManager, PerformanceReview__r = review);
        AdditionalComment__c pcommComment = new AdditionalComment__c(Reviewer__r = pcomm, PerformanceReview__r = review);
        List<AdditionalComment__c> commentList = new List<AdditionalComment__c>();
        commentList.add(employeeComment);  
        commentList.add(managerComment);  
        commentList.add(secondManagerComment);  
        commentList.add(pcommComment);  
        
        ApexPages.currentPage().getParameters().put('id', review.Id);
        test.startTest();
            PerformanceReviewPrint prp = new PerformanceReviewPrint();
            prp.getIsPremierUser();
            prp.getIsScorecardProfile();
            List<AdditionalComment__c> resultList = prp.orderOverallReviewList(commentList);
            system.assertEquals(commentList.size(), resultList.size());
            
        test.stopTest();
    }
     
    static testMethod void testSetScorecardHasComments(){    
        Date endDate = Date.today().addYears(1);
        Date startDate = Date.today();
        User employee = GenerateEnvironmentTest.getEmployeeStandard();
        User manager = GenerateEnvironmentTest.getManager();
        User secondManager = GenerateEnvironmentTest.getSecondManager();
        User pcomm = GenerateEnvironmentTest.getPCOMMUser();
        employee.PCOMM__c = pcomm.Id;
        GenerateEnvironmentTest.updateUser(employee);
        V2MOM__c v2mom = GenerateEnvironmentTest.createV2MOM(employee.Id, 'prprint vision', 'Individual', 'v2mom prprint name', 'FY10', 'My Management Hierarchy');
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest.createPRP('PRPPrint test', 'FY10', 'Individual', startDate , endDate );
        CompetencyGroup__c cgroup = GenerateEnvironmentTest.createCompetencyGroup('PRPrint','PRPrint code');
        Competency__c competency = GenerateEnvironmentTest.createCompetency('PRPrint name','desc');
        CompetencyGroupMember__c cgMember = GenerateEnvironmentTest.createCompetencyGroupMember('cgm', 'cgmCode', competency.Id, cgroup.Id, 23);
        ReviewFormTemplate__c rft = GenerateEnvironmentTest.createReviewFromTemplate('RFT Print', 'RFT Print Code');
        //Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        TF2_Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        
        PerformanceReview__c review = GenerateEnvironmentTest.createPReviewNormal('PRPrint test', period.Id, v2mom.Id, cgroup.Id, rft.Id, employee.Id, manager.Id, secondManager.Id, pcomm.Id, department.Id);
        ScorecardSupportReview__c ssr = new ScorecardSupportReview__c(name = 'ssr name', Comment__c = 'ssr comment', FiscalQuarter__c = 'Q1', PerformanceReview__c = review.Id, PerformanceReviewPeriod__c = period.Id, Reviewer__c = employee.Id);
        ScorecardSupportComment__c employeeComment = new ScorecardSupportComment__c(Reviewer__c = employee.Id, PerformanceReview__c = review.Id, name = 'SSC', ScorecardSupportReview__c = ssr.Id, Locked__c = true, CommentCS__c='ccs', CommentRenewals__c = 'cr', CommentSupportInitiatives__c='csi',
                                                                                    CommentWMCases__c='cwmc', CommentWMSMES__c='cwmsmes', CommentWMPA__c='cwmpa', CommentWMHC__c='cwmhc', CommentSalesImpact__c ='csi', CommentTimeOnPlatform__c='ctop', CommentForecastAccuracy__c='cfa', CommentRenewalExcellence__c='cre',
                                                                                    CommentOperationalExcellence__c='coe', CommentStrategicInitiatives__c='csi',CommentCSMSalesImpact__c='ccsmsi', CommentWMCCP__c='cwmccp', CommentWMCAA__c='cwmcaa');
        ScorecardSupportComment__c managerComment = new ScorecardSupportComment__c(Reviewer__c = manager.Id, PerformanceReview__c = review.Id, name = 'SSC', ScorecardSupportReview__c = ssr.Id);
        ScorecardSupportComment__c secondManagerComment = new ScorecardSupportComment__c(Reviewer__c = secondManager.Id, PerformanceReview__c = review.Id, name = 'SSC', ScorecardSupportReview__c = ssr.Id);
        ScorecardSupportComment__c pcommComment = new ScorecardSupportComment__c(Reviewer__c = pcomm.Id, PerformanceReview__c = review.Id, name = 'SSC', ScorecardSupportReview__c = ssr.Id);
        
        List<ScorecardSupportComment__c> commentList = new List<ScorecardSupportComment__c>();
        commentList.add(employeeComment);  
        commentList.add(managerComment);  
        commentList.add(secondManagerComment);  
        commentList.add(pcommComment);  
        system.runAs( GenerateEnvironmentTest.getSystemAdmin() ){
            insert ssr;
            insert commentList;
        }
        ApexPages.currentPage().getParameters().put('id', review.Id);
        test.startTest();
        system.runAs(pcomm){
            PerformanceReviewPrint prp = new PerformanceReviewPrint();
            prp.scorecardComments = commentList;
            prp.setScorecardHasComments();
            system.assert(!prp.getIsOldPerformanceReview());
        }
        test.stopTest();
    }
    
     static testMethod void testAdditionalCommentDate(){   
        AdditionalComment__c ac = [select id, lastModifiedDate, reviewer__r.name, reviewer__r.id, performanceReview__r.id from AdditionalComment__c limit 1]; 
        test.startTest();
            PerformanceReviewPrint.AdditionalCommentDate adComment = new PerformanceReviewPrint.AdditionalCommentDate(ac);
            adComment.getAdditionalComment();
            String formattedDate = adComment.getCreatedDateFormatted();
            adComment.setAdditionalComment(ac);
            String modifiedFormattedDate = formattedDate + ' modified';
            adComment.setCreatedDateFormatted(modifiedFormattedDate);
            String newFormattedDate = adComment.getCreatedDateFormatted();
            System.assertEquals(formattedDate, newFormattedDate);
        test.stopTest();
     }
     

     
     static testMethod void test_RunAs(){
       Date endDate = Date.today().addYears(1);
        Date startDate = Date.today();
        User employee = GenerateEnvironmentTest.getEmployeeStandard();
        User manager = GenerateEnvironmentTest.getManager();
        User secondManager = GenerateEnvironmentTest.getSecondManager();
        User pcomm = GenerateEnvironmentTest.getPCOMMUser();
        employee.PCOMM__c = pcomm.Id;
        GenerateEnvironmentTest.updateUser(employee);
        V2MOM__c v2mom = GenerateEnvironmentTest.createV2MOM(employee.Id, 'prprint vision', 'Individual', 'v2mom prprint name', 'FY10', 'My Management Hierarchy');
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest.createPRP('PRPPrint test', 'FY10', 'Individual', startDate , endDate );
        CompetencyGroup__c cgroup = GenerateEnvironmentTest.createCompetencyGroup('PRPrint','PRPrint code');
        Competency__c competency = GenerateEnvironmentTest.createCompetency('PRPrint name','desc');
        CompetencyGroupMember__c cgMember = GenerateEnvironmentTest.createCompetencyGroupMember('cgm', 'cgmCode', competency.Id, cgroup.Id, 23);
        ReviewFormTemplate__c rft = GenerateEnvironmentTest.createReviewFromTemplate('RFT Print', 'RFT Print Code');
        //Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        TF2_Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        
        PerformanceReview__c review = GenerateEnvironmentTest.createPReviewNormal('PRPrint test', period.Id, v2mom.Id, cgroup.Id, rft.Id, employee.Id, manager.Id, secondManager.Id, pcomm.Id, department.Id);
        
        ApexPages.currentPage().getParameters().put('id', review.Id);
        test.startTest();
        system.runAs(pcomm){
            PerformanceReviewPrint prp = new PerformanceReviewPrint();
            prp.getMethods();
        }
        test.stopTest();
     }
     
     static testMethod void test_Profiles(){
       Date endDate = Date.today().addYears(1);
        Date startDate = Date.today();
        User employee = GenerateEnvironmentTest.getEmployeeStandard();
        User manager = GenerateEnvironmentTest.getManager();
        User secondManager = GenerateEnvironmentTest.getSecondManager();
        User pcomm = GenerateEnvironmentTest.getPCOMMUser();
        employee.PCOMM__c = pcomm.Id;
        GenerateEnvironmentTest.updateUser(employee);
        V2MOM__c v2mom = GenerateEnvironmentTest.createV2MOM(employee.Id, 'prprint vision', 'Individual', 'v2mom prprint name', 'FY10', 'My Management Hierarchy');
        PerformanceReviewPeriod__c period = GenerateEnvironmentTest.createPRP('PRPPrint test', 'FY10', 'Individual', startDate , endDate );
        CompetencyGroup__c cgroup = GenerateEnvironmentTest.createCompetencyGroup('PRPrint','PRPrint code');
        Competency__c competency = GenerateEnvironmentTest.createCompetency('PRPrint name','desc');
        CompetencyGroupMember__c cgMember = GenerateEnvironmentTest.createCompetencyGroupMember('cgm', 'cgmCode', competency.Id, cgroup.Id, 23);
        ReviewFormTemplate__c rft = GenerateEnvironmentTest.createReviewFromTemplate('RFT Print', 'RFT Print Code');
        //Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        TF2_Department__c department = GenerateEnvironmentTest.createDepartment('PRPrint dept', false);
        
        PerformanceReview__c review = GenerateEnvironmentTest.createPReviewNormal('PRPrint test', period.Id, v2mom.Id, cgroup.Id, rft.Id, employee.Id, manager.Id, secondManager.Id, pcomm.Id, department.Id);
        
        ApexPages.currentPage().getParameters().put('id', review.Id);
        test.startTest();
            PerformanceReviewPrint prp = new PerformanceReviewPrint();
            system.assert(!prp.getIsEducationProfile());
            system.assert(!prp.getIsSupportProfile()); 
            system.assert(!prp.getIsConsultingProfile());
            system.assert(!prp.getIsCSMProfile());
            prp.getCompetencyWeightShow();
            prp.getScorecardComments();
            system.assert(!prp.getScorecardViewProfile());
            system.assert(!prp.getHaveProfile());
            system.assert(!prp.getIsMngr() );
            system.assert(!prp.getIsMngrInAssmnt() );
            system.assert(!prp.getIsEmplMngr2ndMngrOr3PtInAssmnt() );
            system.assert(!prp.getOverallCalcMethodRatingView() );
            system.assert(!prp.getOverallCalcMetricRatingView() );
            system.assert(!prp.getOverallCalcCompRatingView());
            system.assert(!prp.getOverallRatingView() );
            system.assert(prp.getShowOverallRating() );
        test.stopTest();
     }
}