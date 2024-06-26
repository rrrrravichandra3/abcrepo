@isTest
public class CcEmp_MuleAPICaller_Test {
    public static CcEmp_MuleAPICaller service;
    
    
    static void setupMuleAPICaller() {
        String mockresponse = '{"data":[{"all_locations__c":"Italy - Milan\n\nItaly - Milan - Remote\n\nItaly - Prato - Remote\n\nItaly - Rome\n\nItaly - Rome - Remote","business_unit__c":"1625-MuleSoft","company__c":"403-SFDC Italy","compensation_grade__c":7,"cost_center__c":"3002-Engagement Delivery","country__c":"Italy","created_moment__c":"2023-05-23T10:30:37.324+00:00","days_since_last_update__c":7,"external_url__c":"https://salesforce.wd12.myworkdayjobs.com/External_Career_Site/job/Italy---Rome/Engagement-Delivery-Manager---MuleSoft_JR176374-2","hiring_manager_worker_id__c":769616,"internal_posting_url__c":"https://wd12.myworkday.com/salesforce/d/inst/1$9925/9925$43372.htmld","job_code__c":1369,"job_description__c":"Role Description\nWe are seeking an innovative and passionate Project Manager for our MuleSoft team who shares our vision of bringing the power of cloud computing to enterprises. Engagement Delivery Managers are responsible for overseeing our teams to drive successful customer outcomes with our implementations. They manage and run more complex, enterprise and strategic projects. Our Project Managers actively participate on the project, scoping, contracts review, knowledge transfer, and budget management.\nYour Impact\nServe as the overall Leader of the project team and exhibit excellent leadership skills in forming a team, ensuring strong communication channels, giving clarity, motivation and direction to the team throughout the engagement\nBe the primary customer interface and perform project management activities that ensures adherence to Salesforce methodology and project gates and governance\nBuild and lead project plans; supervise and review project progress and timelines; adjust schedules and plans as needed; ensure on time and on budget delivery of projects and identify and resolve issues to ensure project success\nSupervise utilization of project resources in alignment with resource allocation and budget. This includes on time entry and approvals for project timesheets\nAble to lead one or two large projects or a couple of small to medium sized interrelated projects requiring complex cross-functional teamwork and management at the program level\nFacilitate requirements gathering and assist with crafting project deliverables, and Salesforce documentation as needed\nBeing an extension to the account team to extend the Salesforce footprint\nParticipate in end to end implementation planning including project management, risk & issue management, communication and business organisational change\nFacilitate User Acceptance Testing with business end users including coordination and user acceptance sign-off\nBasic qualifications\nProven experience in Project Management, including experience handling external client projects\nAbility to balance the business and technical requirements to produce a project plan and collaborate to acquire the information, such as estimates, as input to the project plan\nDemonstrated project management skills, with direct responsibility for running project teams, up to 10+ people, budget and schedule.\nDemonstrated ability to have difficult conversations\nProven history of delivering high quality results on schedule and within budget, managing a budget\nManage and communicate with remote developers\nOutstanding and effective interpersonal skills; along with strong communication skills both verbal and written.\nAbility to work effectively in a fast paced, high energy, team-oriented environment\nProficiency in Italian, Spanish and English language\nAvailable to travel regionally and occasionally internationally depending on customer needs up to 30% of the time\nPreferred qualifications\nProject Management Methodology Certification such as Prince, PMP, SAFe, Scrum\nExperience with business process expertise around an industry Vertical (i.e. Financial, Health & Life Sciences, or Manufacturing, Retail, Logistics)\nPre- Sales Skills, Enterprise change and management experience.\nEnterprise-scale integration solutions and cloud technology or equivalent\nExperience implementing enterprise-scale CRM software solutions around processes such as Sales, Service, Marketing, Commerce is a plus\nBenefits & Perks:\nCheck out our benefits site (https://salesforcebenefits.com/international.html) that explains our various benefits, including wellbeing reimbursement, generous parental leave, adoption assistance, fertility benefits, and more.Visit for the full breakdown!","job_family__c":"Engagement Delivery","job_family_group__c":"Customer Success","job_profile__c":"Engagement Delivery Manager","job_requisition__c":"JR176374 Engagement Delivery Manager - MuleSoft (Evergreen) (Open)","job_requistion_type__c":"Evergreen","job_title__c":"Engagement Delivery Manager - MuleSoft","last_modified__c":"2024-01-30T09:10:41.799+00:00","management_level__c":"4 Professional","number_of_openings_available_1__c":0,"number_of_openings_available__c":0,"posted_internally__c":"Yes","primary_country_coverage__c":"403-Italy","primary_location__c":"Italy - Rome","recruting_start_date__c":"2023-04-28T00:00:00.000+00:00","reference_id__c":"JR176374","region__c":"EMEA","status__c":"Open","total_openings__c":0,"worker_sub_type__c":"Regular"}]}';
        Test.setMock(HttpCalloutMock.class, new CcEmp_MuleAPICallerMock(mockresponse, 200));
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json','Authorization' => 'Bearer token'};
        Map<String, String> body = new Map<String, String>{'bodyParam1' => 'application/json','param2' => 'Bearer token'};
        Map<String, String> query = new Map<String, String>{'queryparam1' => 'value1','param2' => 'value2'};
        service = new CcEmp_MuleAPICaller();
        service.setConfigName('GetJobs');
        service.buildHeaders(headers);
        service.buildQuery(query);
        service.buildPostParams(body);
    }
    
  
    // Test method to verify building headers
    @isTest
    static void testConfiguration() {
        setupMuleAPICaller();
        Assert.areEqual(service.apiCalloutConfig.CcEmp_Is_Active__c, true);
    }
    
    // Test method to verify building headers
    @isTest
    static void testQueryParams() {
        setupMuleAPICaller();
        Test.startTest();
        
        String response = service.init();
        
        Test.stopTest();
        Boolean hasParams = service.apiRequest.getEndpoint().contains('queryparam1');
        Assert.isTrue(hasParams);
        
        
    }
    
    
    @isTest
    static void testBuildHeaders() {
        setupMuleAPICaller();
        Test.startTest();
        String response = service.init();
        Test.stopTest();
        
        Boolean hasBodyParam = service.apiRequest.getBody().contains('bodyParam1');
        Assert.isTrue(hasBodyParam);
    }
    
    @isTest
    static void testException() {
        
        Test.startTest();
        try{
            service = new CcEmp_MuleAPICaller();
            service.setConfigName('invalid');
        }catch(Exception ex){
            CcEmp_CalloutService.CalloutResponse message = (CcEmp_CalloutService.CalloutResponse)JSON.deserialize(ex.getMessage(), CcEmp_CalloutService.CalloutResponse.class);
           Assert.isFalse(message.isSuccess);
        }
        Test.stopTest();
       
    }
    
    
    
    
}