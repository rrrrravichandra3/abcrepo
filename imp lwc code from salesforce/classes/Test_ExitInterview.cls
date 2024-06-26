/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_ExitInterview {

    static testMethod void testMethodOne() 
    {
        GenerateEnvironmentExitInterview.genExitInterviewEnvironment();
        
        System.currentPageReference().getParameters().put('idExitInterview', GenerateEnvironmentExitInterview.exitInterview.Id);
        System.assertEquals(System.currentPageReference().getParameters().get('idExitInterview'), GenerateEnvironmentExitInterview.exitInterview.Id);



 
            SendExitInterviewController controller = new SendExitInterviewController();
        
            controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
            controller.getExitInterview();

            
            //controller.sendExitInterView();
            controller.getAllExitInterviews();
            controller.getIsESR();
            controller.getIsSysAdmin();
            controller.getAllExitInterviews();
            controller.getAllEmployeeExitIntervies();
            controller.getEmployeeAllReadyHaveOne();
            controller.getErrorDate();

            
            controller.orderByManager();

            
            controller = new SendExitInterviewController();
            controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
            controller.getAllExitInterviews();
            controller.getAllEmployeeExitIntervies();
            controller.orderByManager();
            controller.getAllExitInterviews();
            controller.getAllEmployeeExitIntervies();

            
            controller.orderByName();

            
            controller = new SendExitInterviewController();
            controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
            controller.getAllExitInterviews();
            controller.getAllEmployeeExitIntervies();
            controller.orderByName();
            controller.getAllEmployeeExitIntervies();
            controller.getAllExitInterviews();

            
            controller = new SendExitInterviewController();
            controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
            controller.orderByDate();
            controller.getAllExitInterviews();
            controller.getAllEmployeeExitIntervies();
            controller.orderByDate();
            controller.getAllEmployeeExitIntervies();   



            controller.getExitInterViewCustom();
            
            System.runAs(GenerateEnvironmentExitInterview.getSystemAdmin()){
                controller.sendExitInterView();
            }
            controller.getEmployeeAlreadyHaveOne();
       
        List<User> users = [select Id From User Where Title = 'ES Representative (ESR)' and Profile.ID !=: PerformanceAccessUtil.getSystem_Administrator_Id() and IsActive = true];
        User currentUser;
        
        if (users.size() != 0)
        {
            currentUser = users[0];
            System.runAs(currentUSer)

            {
                currentUser = users[0];
                System.currentPageReference().getParameters().put('idExitInterview', GenerateEnvironmentExitInterview.exitInterview.Id);


                controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
                controller.getIsESR();



                
                
            }   
        }
        


        
        controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
        
        //controller.DeleteExitInterview();
      
        users = [select Id, Profile.Name From User Where Profile.Name = 'Employee Success/Business Partner' and IsActive = true limit 1];
        
        if (users.size() != 0)
        {
            currentUser = users[0];
			System.assertEquals(currentUser.Profile.Name, 'Employee Success/Business Partner');

            System.runAs(currentUSer)

            {
                currentUser = users[0];
                System.currentPageReference().getParameters().put('idExitInterview', GenerateEnvironmentExitInterview.exitInterview.Id);
                controller = new SendExitInterviewController();

           
                controller.getAllExitInterviews();
                controller.getAllEmployeeExitIntervies();
                controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
                controller.getIsESR();

                
                controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
                controller.getExitInterview();

               
                controller.getAllExitInterviews();
                controller.getIsESR();
                controller.getIsSysAdmin();
                controller.getAllExitInterviews();
                controller.getAllEmployeeExitIntervies();
                controller.getEmployeeAllReadyHaveOne();
                controller.getErrorDate();

                
                controller.orderByManager();

                
                controller = new SendExitInterviewController();
                controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
                controller.getAllExitInterviews();
                controller.getAllEmployeeExitIntervies();
                controller.orderByManager();
                controller.getAllExitInterviews();
                controller.getAllEmployeeExitIntervies();

                
                controller.orderByName();

                
                controller = new SendExitInterviewController();
                controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
                controller.getAllExitInterviews();
                controller.getAllEmployeeExitIntervies();
                controller.orderByName();
                controller.getAllEmployeeExitIntervies();
                controller.getAllExitInterviews();

                
                controller = new SendExitInterviewController();
                controller.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
                controller.orderByDate();
                controller.getAllEmployeeExitIntervies();
                controller.orderByDate();
                controller.getAllEmployeeExitIntervies();   

            }   
        }
       
    }
    

    static testMethod void testMethodTwo() 
    {
        GenerateEnvironmentExitInterview.genExitInterviewEnvironment();
        GenerateEnvironmentExitInterview.insertExitInterview();
        System.currentPageReference().getParameters().put('id', GenerateEnvironmentExitInterview.exitInterview.Id);
		System.assertEquals(System.currentPageReference().getParameters().get('id'), GenerateEnvironmentExitInterview.exitInterview.Id);
        
        ExitInterviewController controller = new ExitInterviewController();
       
        controller.getStatus();
        controller.getShowEditField();
        controller.getIsESR();
        controller.getShowESRComment();
        
        controller.saveAndSubmit();
        controller.saveAndFinishLater();
        controller.save();
        controller.saveSendBackToEmployee();
        controller.getExitInterview();
        
        ExitInterviewController.Employee employeeController = controller.getEmployee();
        employeeController.getEmployeeId();
        employeeController.getManager();
        employeeController.getName();
        employeeController.getTerminationDate();
        employeeController.getJobTitle();
        employeeController.getDepartmentName();
        employeeController.getHireDate();
        employeeController.getEmployeeNumber();
        
        ExitInterviewController.PerformanceReview performanceController = controller.getReview();
        performanceController.getFiscalYear();
        performanceController.getPerformanceInformation();
        performanceController.getPerformanceReview();

        List<User> users = [select Id, Profile.Name From User Where Profile.Name = 'Employee Success/Business Partner' and IsActive = true limit 1];
        
        if (users.size() != 0)
        {
            User currentUser = users[0];
			System.assertEquals(currentUser.Profile.Name, 'Employee Success/Business Partner');

            System.runAs(currentUSer)

            {
                currentUser = users[0];
                System.currentPageReference().getParameters().put('idExitInterview', GenerateEnvironmentExitInterview.exitInterview.Id);
                SendExitInterviewController controllerExitInterview = new SendExitInterviewController();

              
                controllerExitInterview.setExitInterview(GenerateEnvironmentExitInterview.exitInterview);
                controllerExitInterview.orderByDate();

           
                controllerExitInterview.orderByDate();
                controllerExitInterview.getAllExitInterviews();
                controllerExitInterview.orderByDate();
                controllerExitInterview.getAllExitInterviews();
                controllerExitInterview.getAllEmployeeExitIntervies();  

                
                controllerExitInterview.orderByTerminationDate();
                controllerExitInterview.getAllExitInterviews();

                
                controllerExitInterview.orderByTerminationDate();
                controllerExitInterview.getAllExitInterviews();

                
                controllerExitInterview.orderByManager();
                controllerExitInterview.getAllExitInterviews();

                
                controllerExitInterview.orderByManager();
                controllerExitInterview.getAllExitInterviews();

            }   
        }
          
    }
   
    static testMethod void testMethodThree() 
    {
        GenerateEnvironmentExitInterview.getUsers();
        GenerateEnvironmentExitInterview.insertExitInterviewNoComments();
        System.currentPageReference().getParameters().put('id', GenerateEnvironmentExitInterview.exitInterview.Id);
		System.assertEquals(System.currentPageReference().getParameters().get('id'), GenerateEnvironmentExitInterview.exitInterview.Id);

        
        ExitInterviewController controller = new ExitInterviewController();
        controller = new ExitInterviewController();

        
        controller.getStatus();
        controller.getShowEditField();
        controller.getIsESR();
        controller.getShowESRComment();
        
        controller.saveAndSubmit();
        controller.saveAndFinishLater();
        controller.save();
        controller.saveSendBackToEmployee();
        controller.getExitInterview();
        controller.getInterviewComment();
        controller.getInterviewCommentContinue();
        
        
        ExitInterviewController.Employee employeeController = controller.getEmployee();
        employeeController.getEmployeeId();
        employeeController.getManager();
        employeeController.getName();
        employeeController.getTerminationDate();
        employeeController.getJobTitle();
        employeeController.getDepartmentName();

        
        controller.setInterviewComment(GenerateEnvironmentExitInterview.exitInterviewComment);
        controller.setInterviewCommentContinue(GenerateEnvironmentExitInterview.exitInterviewCommentContinue);



        
                   
            controller.getShowEditField();
            GenerateEnvironmentExitInterview.exitInterview.Status__c = 'Completed';
			System.assertEquals(GenerateEnvironmentExitInterview.exitInterview.Status__c, 'Completed');
            
            update GenerateEnvironmentExitInterview.exitInterview;

            
            System.currentPageReference().getParameters().put('id', GenerateEnvironmentExitInterview.exitInterview.Id);

            
            controller = new ExitInterviewController();

            
            controller.getShowEditField();
            controller.getShowESRComment();
            controller.getShowEditField();





        
        
        
        
        
        List<User> users = [select Id From User Where Title = 'ES Representative (ESR)' And Profile.ID !=: PerformanceAccessUtil.getSystem_Administrator_Id() and IsActive = true];
        User currentUser;
        
        if (users.size() > 1)
        {
            currentUser = users[0];

            
            System.runAs(currentUser)


            {
                    
                System.currentPageReference().getParameters().put('id', GenerateEnvironmentExitInterview.exitInterview.Id);

                
                //controller = new ExitInterviewController();

                
                controller.getShowEditField();
                controller.getShowESRComment();
                controller.getShowEditField();
                controller.getIsESR();

            }
        }
       

        
        controller.getIsShowMangerOneToOne();
        controller.getIsLeavingInformationNull();
        controller.getIsLeavingInformationOtherNull();
        controller.getIsThinkLeavingNull();
        controller.getIsCompanyNameNull();
        controller.getIsNewRoleNull();
        controller.getIsHowYouHeardOportunityNull();
        controller.getIsPositionOfferNull();
        controller.getIsBenefitsNotGoodNull();
        controller.getIsCompensationNull();
        controller.getIsCompensationNotGoodAsNull();
        controller.getIsExpectationNull();
        controller.getIsExpectationNotClosedNull();
        controller.getIsBenefitsNull();
        controller.getIsManagerPerformanceExpectationsNull();
        controller.getIsPerformanceMeasuredNull();
        controller.getIsReceivePerformanceReviewNull();
        controller.getIsRegularOneToOneWithManager();
        controller.getIsOnBoardingExperienceNull();
        controller.getIsCurrentManagerNull();
        controller.getIsManagersInterestSupportNull();
        controller.getIsCareerDevelopmentOpportunitiesNull();
        controller.getIsCultureAtSalesforceNull();
        controller.getIsMoraleOnYourTeamNull();
        controller.getIsItemsNotRankedAsFiveNull();
        controller.getIsManagerDoneDifferentlyNull();
        controller.getIsManagerCommunicateDepartmentV2MOMNull();
        controller.getIsManagerCommunicateDepartmentV2MOMNull();
        controller.getIsRoleContributedCompanyNull();
        controller.getIsHavePersonalV2MOMNull();
        controller.getIsSalesforceStrengthsAndWeaknesseNull();
        controller.getIsOverallWorkExperienceNull();
        controller.getIsSomethingToShareNull();
        controller.getIsCommentLeavingReasonNull();
        controller.getIsCanFedbackBeeSharedNull();
        controller.getIsCommentContinueThinkLeavingNull();
        controller.getIsCommentPositionOfferNull();
        controller.getIsExpectationsNotClosedNull();
        controller.getIsComentManagerPerformanceExpectationsNull();
        controller.getIsComentPerformanceMeasuredNull();
        controller.getIsComentReceivePerformanceReviewNull();
        controller.getIsComentRegularOneToOneWithManagerNull();
        controller.getIsComentItemsNotRankedAsFiveNull();
        controller.getIsComentManagerDoneDifferentlyNull();
        controller.getIsComentManagerCommunicateDepartmentV2MOMNull();
        controller.getIsComentUnderstandRoleContributedNull();
        controller.getIsComentUnderstandRoleContributedCompanyNull();
        controller.getIsComentHavePersonalV2MOMNull();
        controller.getIsCommentSalesforceStrengthsAndWeaknesseNull();
        controller.getIsCommentOverallWorkExperienceNull();
        controller.getIsCommentSomethingToShareNull();
        controller.getIsCommentCanFedbackBeeSharedNull();
        controller.getIsComplete();
        //controller.getIsSysAdmin();
        controller.getIsEmployee();
        controller.getShowNoInformation();
        controller.getIsInCompleteStatus();
        controller.getIsUnderstandRoleContributedNull();
        controller.getIsInformationEntered();

        
        controller.getIsV2MOMPresent();
        controller.getReview();
        controller.getMostRecentV2MOM();
        controller.getMostRecentReview();
        controller.getEmployeeObject();
        controller.getCurrentUser();
        controller.getErrorDate();
        controller.setErrorDate(true);
        controller.getLeavingReason();
        controller.setLeavingReason('leaving reason');
		System.assertEquals(controller.getLeavingReason(), 'leaving reason');
        controller.getShowEditField();
        controller.getIsShowLeavingOhter();
        controller.getCreatedDate();
        controller.getLastModifiedDate();
        controller.getIsSysAdminEsbpEsAdminESR();

        
        controller.CancelExitInterview();
        controller.DeleteExitInterview();


        
        
    }
  
}