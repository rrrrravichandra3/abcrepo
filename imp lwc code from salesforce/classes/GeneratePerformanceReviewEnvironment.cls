public with sharing class GeneratePerformanceReviewEnvironment {
    
    
    
    public static PerformanceReview__c createPerformance(){
                
                User employee = GenerateEnvironmentTestUsers.createEmployeeWithManager();
                User manager = GenerateEnvironmentTestUsers.createManager();
                User secondManager = GenerateEnvironmentTestUsers.create2ndManager();
                User PCOMM = GenerateEnvironmentTestUsers.createPCOMM();
                
                Date sdate = System.today();
                Date edate = sdate.addYears(1);
                
                CompetencyGroup__c competency = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
                insert competency;
                
                PerformanceReviewPeriod__c performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
                                  Effective_Date__c = 'FY11',
                                  V2MOM_Type__c = 'Individual',
                                          StartDate__c = sdate,
                                    EndDate__c = edate);
                insert performanceReviewPeriod;
                
                 ReviewFormTemplate__c review = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
                 insert review;
                
                //Department__c department = new Department__c();
                TF2_Department__c department = new TF2_Department__c();
                department.Name = 'nombre';
                insert department;
                
                V2MOM__c v2mom =  GenerateV2MOMEnvironment.createV2MOM('V2MOM Name','Department','FY12','Vision', 'My Management Hierarchy','Not Submitted',False);
                

                
                PerformanceReview__c performance = new PerformanceReview__c(Name = 'Performance1',
                                                        PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
                                                        V2MOM__c = v2mom.Id,
                                                        CompetencyGroup__c = competency.Id,
                                                        ReviewFormTemplate__c = review.Id,
                                                        
                                                        Employee__c = employee.Id,
                                                        Manager__c = manager.Id,
                                                        SecondManager__c = secondManager.Id,
                                                        Cost_Center__c = department.Id,
                                                        PCOMM__c = PCOMM.Id,
                                                        Status__c = 'Created');
                                                         
                insert performance;
                return performance;
    }
    
    public static PerformanceReview__c createPerformance_TestFile(){
                
                User employee = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.PCOMM__c, u.Manager__c, u.Id From User u Where u.Profile.Name =: 'Employee' AND u.IsActive = true limit 1];
                User manager = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.PCOMM__c, u.Manager__c, u.Id From User u Where u.Profile.Name =: 'Manager' AND u.IsActive = true limit 1];
                
                
                Date sdate = System.today();
                Date edate = sdate.addYears(1);
                CompetencyGroup__c competency;
                PerformanceReviewPeriod__c performanceReviewPeriod;
                system.runAs(manager){
                    competency = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
                    insert competency;
                
                    performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
                                                                                                        Effective_Date__c = 'FY11',
                                                                                                        V2MOM_Type__c = 'Individual',
                                                                                                        StartDate__c = sdate,
                                                                                                        EndDate__c = edate);
                    insert performanceReviewPeriod; 
               
                
                }
                 ReviewFormTemplate__c review = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
                 insert review;
                
                Department__c department = new Department__c();
                department.Name = 'nombre';
                insert department;
                
                V2MOM__c v2mom =  GenerateV2MOMEnvironment.createV2MOM('V2MOM Name','Department','FY12','Vision', 'My Management Hierarchy','Not Submitted',False);
                

                
                PerformanceReview__c performance = new PerformanceReview__c(Name = 'Performance1',
                                                        PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
                                                        V2MOM__c = v2mom.Id,
                                                        CompetencyGroup__c = competency.Id,
                                                        ReviewFormTemplate__c = review.Id,
                                                        
                                                        Employee__c = employee.Id,
                                                        Manager__c = manager.Id,
                                                        SecondManager__c = null,
                                                        PCOMM__c = null,
                                                        Department__c = department.Id,
                                                        
                                                        Status__c = 'Created');
                insert performance;
                return performance;
    }
    
    public static PerformanceReview__c createPerformance_OverallCSM(){
                
                User employee = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.PCOMM__c, u.Manager__c, u.Id From User u Where u.Profile.Name =: 'Employee' AND u.IsActive = true limit 1];
                User manager = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.PCOMM__c, u.Manager__c, u.Id From User u Where u.Profile.Name =: 'Manager' AND u.IsActive = true limit 1];
                User secondManager = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.PCOMM__c, u.Manager__c, u.Id From User u Where u.Id =: manager.Id AND u.IsActive = true limit 1];
                User pcomm = [Select u.Profile.Name, u.Profile.Id, u.ProfileId, u.PCOMM__c, u.Manager__c, u.Id From User u Where u.Profile.Name =: 'PCOMM' AND u.IsActive = true limit 1];
                
                Date sdate = System.today();
                Date edate = sdate.addYears(1);
                CompetencyGroup__c competency;
                PerformanceReviewPeriod__c performanceReviewPeriod;
                system.runAs(manager){
                    competency = new CompetencyGroup__c(Name = 'CCCompGrp', Code__c = 'CCCompGrp');
                    insert competency;
                
                    performanceReviewPeriod = new PerformanceReviewPeriod__c(Name = 'Test PRP Department',
                                                                                                        Effective_Date__c = 'FY11',
                                                                                                        V2MOM_Type__c = 'Individual',
                                                                                                        StartDate__c = sdate,
                                                                                                        EndDate__c = edate);
                    insert performanceReviewPeriod; 
               
                
                }
                 ReviewFormTemplate__c review = new ReviewFormTemplate__c(Name = 'CCRevTpl', Code__c = 'CCRevTpl');
                 insert review;
                
                Department__c department = new Department__c();
                department.Name = 'nombre';
                insert department;
                
                V2MOM__c v2mom =  GenerateV2MOMEnvironment.createV2MOM('V2MOM Name','Ad Hoc','FY12','Vision', 'My Management Hierarchy','Not Submitted',False);
                

                
                PerformanceReview__c performance = new PerformanceReview__c(Name = 'Performance1',
                                                        PerformanceReviewPeriod__c = performanceReviewPeriod.Id,
                                                        V2MOM__c = v2mom.Id,
                                                        CompetencyGroup__c = competency.Id,
                                                        ReviewFormTemplate__c = review.Id,
                                                        
                                                        Employee__c = employee.Id,
                                                        Manager__c = manager.Id,
                                                        SecondManager__c = secondManager.Id,
                                                        PCOMM__c = pcomm.Id,
                                                        Department__c = department.Id,
                                                        
                                                        Status__c = 'Created');
                insert performance;
                return performance;
    }
    
    public static PerformanceReview__c createPerformanceReview(String name, 
                                                        Id period,
                                                        Id v2mom,
                                                        Id competency,
                                                        Id review,
                                                        Id employee,
                                                        Id manager,
                                                        Id secondManager,
                                                        Id pcomm,
                                                        Id department) {    
            PerformanceReview__c performance = new PerformanceReview__c(Name = name,
                                                        PerformanceReviewPeriod__c = period,
                                                        V2MOM__c = v2mom,
                                                        CompetencyGroup__c = competency,
                                                        ReviewFormTemplate__c = review,
                                                        Employee__c = employee,
                                                        Manager__c = manager,
                                                        SecondManager__c = secondManager,
                                                        PCOMM__c = pcomm,
                                                        Cost_Center__c = department,
                                                        Status__c = 'Created');
                                                        //Department__c = department,
                                                        
                                                                        
        insert performance;
        return performance;
    }
   
}