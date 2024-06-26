/**
* @author Apuroop Gadde
* @date 06-30-2017
* @group Unit Test Classes
* @description Utils class for unit tests
*/
@isTest
public class WDR_TestUtils {
    /**
    * @description Util method to create and insert a new TF2_Company
    **/
    public static  TF2_Company__c createCompany() {
        List<TF2_Company__c> company = [SELECT Id FROM TF2_Company__c WHERE Name = 'Test CMP'];
        if(company != null && company.size() == 0) {
            TF2_Company__c testCompany = new TF2_Company__c(Name='Test CMP',Company_Code__c='100', Region__c = 'APAC', Active__c=true);         
            insert testCompany;
            return testCompany ;  
        }
        return company.get(0);

    }

    /**
    * @description Util method to create and insert a new Business Unit
    **/
    public static Business_Unit__c createBusinessUnit() {
        List<Business_Unit__c> testBU = [SELECT Id FROM Business_Unit__c WHERE Name = '1901 Heroku'];
        if(testBU != null && testBU.size() == 0) {
            Business_Unit__c testBusinessUnit = new Business_Unit__c(Name='1901 Heroku',BU_Code__c='1901');
            insert testBusinessUnit;
            return testBusinessUnit;            
        }
        return testBU.get(0);

    }

    public static  TF2_Department__c createDepartment() {
        List<TF2_Department__c> testDepts = [SELECT Id FROM TF2_Department__c where Name='Finance'];
        if(testDepts != null && testDepts.size() == 0) {
            TF2_Department__c testDept = new TF2_Department__c(Name = 'Finance', Department_Number__c = 'D_002');
            insert testDept;
            return testDept;            
        }
        return testDepts.get(0);
    }
    
    /**
    * @description Util method to create and insert a new TF2_PCC
    **/
    public static  TF2_PCC__c createPrimaryCountryOfCoverage() {
        List<TF2_PCC__c> testPCCs = [SELECT Id FROM TF2_PCC__c where Name='Test Region'];
        if(testPCCs != null && testPCCs.size() == 0) {
            TF2_PCC__c testPCC = new TF2_PCC__c(Name='Test Region',PCC_Code__c='P101');
            insert testPCC;
            return testPCC;            
        }
        return testPCCs.get(0);
    }

    /**
    * @description Util method to create and insert a new user who is a hiring manager
    **/
    public static User createHiringManagerWithNoHeirarchy(String hmFName, String hmLName) {
        Profile p = [select id from profile where name='Manager'];      
        User testHiringManager = new User(alias = 'standt5', email='test@test.org',
        emailencodingkey='UTF-8', lastname = hmLName, languagelocalekey='en_US',localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Los_Angeles', username=hmFname.deleteWhitespace()+hmLName.deleteWhitespace()+'@test.org', FirstName = hmFName, Title='Second Level manager', 
        Management_Level__c = '3.1 manager');
        insert testHiringManager;
        return testHiringManager;
    }

    /**
    * @description Util method to create and insert a new WDR_Job
    **/
    public static WDR_Job__c createWDRJobReq(String jobName) {
        List<WDR_Job__c> testWDRJobs = [SELECT Id FROM WDR_Job__c where Name=:jobName];  
        if(testWDRJobs != null && testWDRJobs.size() == 0) {
            TF2_Company__c testCompany = createCompany();
            Business_Unit__c testBU = createBusinessUnit();
            TF2_Department__c testDep = createDepartment();
            TF2_PCC__c testPCC = createPrimaryCountryOfCoverage();
            User testHM = createHiringManagerWithNoHeirarchy(jobName+'testFname',jobName+'testLName');
            WDR_Job__c testJob = new WDR_Job__c(Name = jobName,Job_Title__c = 'test job', Job_Code__c = 'test Code', Job_Level__c = 'test JL', Employment_Type__c = 'testET',
                                            Company__c = testCompany.Id, Business_Unit__c = testBU.Id , Department__c = testDep.Id, PCC__c = testPCC.Id, Division__c = 'testDiv',
                                            Region__c = 'AMER', Hiring_Manager__c = testHM.Id);
            insert testJob;    
            return testJob;    
        }      
        return testWDRJobs.get(0);
    }

    /**
    * @description Util method to create and insert a new WDR_Candidate
    **/
    public static WDR_Candidate__c createWDRCandidate() {
        WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestCandidate',First_Name__c = 'Ftest', Last_Name__c = 'LTest',Mailing_City__c = 'MCity',
                        Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
                        Email__c = 'testEmail@test.com');
        insert testCandidate;
        return testCandidate;

    }

    /**
    * @description Util method to create and insert a new WDR_Candidate
    **/
    public static WDR_Candidate__c createWDROfferRejectedCandidate() {
        WDR_Candidate__c testCandidate = new WDR_Candidate__c(Name='TestOfferRejectedCandidate',First_Name__c = 'FRejectedtest', Last_Name__c = 'LRejectedTest',Mailing_City__c = 'MCity',
                        Mailing_State__c = 'MState', Mailing_Country__c = 'MCountry',Mailing_Postal_Code__c = 'PostalCode', Mailing_Street__c = 'MStreet', 
                        Email__c = 'testEmail@test.com');
        insert testCandidate;
        return testCandidate;

    }

    /**
    * @description Util method to create and insert a new Business site
    **/
    public static TF2_Business_Site__c createTestBusSite() {    
            TF2_Business_Site__c testBusSite = new TF2_Business_Site__c(Name ='test BS',Country__c ='test Country', Street_Address__c = 'One market st',
                                                    Type__c = 'Field Office', Active__c = true );
            insert testBusSite; 
            return testBusSite;
    }

    /**
    * @description Util method to create and insert a new WDR Application
    **/
    public static WDR_Application__c createWDRApplication() {
        WDR_Candidate__c testCand = createWDRCandidate();   
        WDR_Job__c testJob = createWDRJobReq('test Job');
        TF2_Business_Site__c testBusSite = createTestBusSite();
        WDR_Application__c testApp = new WDR_Application__c(Job__c = testJob.Id, Candidate__c = testCand.Id, Internal_Candidate__c = false, 
                                Business_Site__c = testBusSite.Id, Offer_Type__c = 'test Offer', Candidate_Stage__c = 'Interview', SIFT_Group__c = 'CSG',
                                SIFT_Position__c = 'Success Partner', Start_Date__c = Date.today().addDays(50), SIFT_Recruiter_Intro__c = 'test Intro');
        insert testApp;
        return testApp;
    }

    /**
    * @description Util method to create and insert a new WDR Application
    **/
    public static WDR_Application__c createWDROfferRejectedApplication() {
        WDR_Candidate__c testCand = createWDROfferRejectedCandidate();   
        WDR_Job__c testJob = createWDRJobReq('test Job');
        TF2_Business_Site__c testBusSite = createTestBusSite();
        WDR_Application__c testApp = new WDR_Application__c(Job__c = testJob.Id, Candidate__c = testCand.Id, Internal_Candidate__c = false, 
                                Business_Site__c = testBusSite.Id, Offer_Type__c = 'test Offer', Candidate_Stage__c = 'Rejected', SIFT_Group__c = 'CSG',
                                SIFT_Position__c = 'Success Partner', Start_Date__c = Date.today().addDays(50), SIFT_Recruiter_Intro__c = 'test Intro');
        insert testApp;
        return testApp;
    }
}