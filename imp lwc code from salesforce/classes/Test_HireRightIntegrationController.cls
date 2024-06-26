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
private class Test_HireRightIntegrationController {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        User currentUser =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
        RecordType accountRecordType =[Select SobjectType, Name, Id From RecordType r where SobjectType ='Account' and isActive=true limit 1];
        
        Account candidateAccount = new Account();
        candidateAccount.Name='Candidates';
        candidateAccount.RecordTypeId = accountRecordType.Id;
        candidateAccount.Description = 'Test candiate account for test cases.';
        insert candidateAccount;
        
        Contact candidate = new Contact();
        candidate.AccountId = candidateAccount.Id;
        candidate.FirstName = 'Test FS';
        candidate.LastName = 'Test LS';
        candidate.Email = 'a@b.com';
        candidate.Phone='1231231234';
        candidate.MailingStreet='1 California';
        candidate.MailingCity='San Francisco';
        candidate.MailingState='CA';
        candidate.MailingPostalCode='94582';
        candidate.MailingCountry='US';
        candidate.English_Level__c='Business Level';
        insert candidate;
        
        Employment_Application__c employmentApp = new Employment_Application__c();
        employmentApp.Name='Test';
        employmentApp.Contact__c = candidate.Id;
        insert employmentApp;
        
        System.currentPageReference().getParameters().put('Id',employmentApp.Id);
        HireRightIntegrationController hrController = new HireRightIntegrationController();
        hrController.validateRequest();
        System.assert(ApexPages.hasMessages());
        System.currentPageReference().getParameters().put('Action',employmentApp.Id);
        HireRightIntegrationController hrController1 = new HireRightIntegrationController();
        hrController1.validateRequest();
        System.assert(ApexPages.hasMessages());
        System.currentPageReference().getParameters().put('Action','INTIATE_BI');
        HireRightIntegrationController hrController2 = new HireRightIntegrationController();
        hrController2.validateRequest();
        System.assert(ApexPages.hasMessages());
        hrController2.processBackgroundData();
        System.assert(ApexPages.hasMessages());
        System.debug('Messages------>'+ ApexPages.getMessages());
        System.currentPageReference().getParameters().put('Action','VIEW_BI');
        HireRightIntegrationController hrController3 = new HireRightIntegrationController();
        hrController3.validateRequest();
        System.assert(ApexPages.hasMessages());
        System.currentPageReference().getParameters().put('Action','UPDATE_BI');
        HireRightIntegrationController hrController4 = new HireRightIntegrationController();
        hrController4.validateRequest();
        System.assert(ApexPages.hasMessages());
        hrController4.processBackgroundData();
        
    }
    
    static testMethod void myUnitTest1() {
    	User currentUser =[Select u.Profile.Name, u.ProfileId, u.IsActive, u.Id, u.LastName, u.FirstName,u.Email From User u where u.Profile.Name='System Administrator' and u.IsActive=true limit 1];
        RecordType accountRecordType =[Select SobjectType, Name, Id From RecordType r where SobjectType ='Account' and isActive=true limit 1];
        
        Account candidateAccount = new Account();
        candidateAccount.Name='Candidates';
        candidateAccount.RecordTypeId = accountRecordType.Id;
        candidateAccount.Description = 'Test candiate account for test cases.';
        insert candidateAccount;
        
        Contact candidate = new Contact();
        candidate.AccountId = candidateAccount.Id;
        candidate.FirstName = 'Test FS';
        candidate.LastName = 'Test LS';
        candidate.Email = 'a@b.com';
        candidate.Phone='1231231234';
        candidate.MailingStreet='1 California';
        candidate.MailingCity='San Francisco';
        candidate.MailingState='CA';
        candidate.MailingPostalCode='94582';
        candidate.MailingCountry='US';
        candidate.English_Level__c='Business Level';
        insert candidate;
        
        Employment_Application__c employmentApp = new Employment_Application__c();
        employmentApp.Name='Test';
        employmentApp.Contact__c = candidate.Id;
        employmentApp.First_Name_Contact__c ='Test FS';
		employmentApp.Middle_Name_Contact__c ='Test M';
		employmentApp.Last_Name_Contact__c ='Test LS';
		employmentApp.Mobile_Phone_Contact__c ='1231231234';
		employmentApp.Home_Phone_Contact__c ='1231231234';
		employmentApp.Email_Contact__c ='a@b.com';
		employmentApp.Country_Contact__c ='US';
		employmentApp.Zip_Postal_Code_Contact__c = '94582';
		employmentApp.State_Contact__c ='CA';
		employmentApp.City_Contact__c ='SFO';
		employmentApp.Current_Address_Contact__c = '1 California';
		employmentApp.Name_of_Company_Job_1__c ='Test';
		employmentApp.Phone_Job_1__c = '1231231234';
		employmentApp.Country_Job_1__c = 'US';
		employmentApp.State_Job_1__c = 'CA';
		employmentApp.Address_Job_1__c = '1 Cal';
		employmentApp.Current_Employer__c = 'SFDC';
		employmentApp.Job_Title_Job_1__c = 'SMTS';
		employmentApp.Position_and_Duties_Job_1__c ='LMTS';
		employmentApp.From_Year_Job_1__c = '2002';
		employmentApp.From_Month_Job_1__c = '03';
		employmentApp.To_Year_Job_1__c = '11';
		employmentApp.To_Month_Job_1__c = '07';
		employmentApp.Ending_Salary_Job_1__c = 12345.00;
		employmentApp.Name_of_Supervisor_Job_1__c ='Test S';
		employmentApp.Reason_for_Leaving_Job_1__c = 'Test';
		employmentApp.Permission_to_Contact_Employer__c = 'Yes';
		employmentApp.Name_of_Company_Job_2__c = 'SFDC 1';
		employmentApp.Phone_Job_2__c = '21231231234';
		employmentApp.Country_Job_2__c = 'US';
		employmentApp.State_Job_2__c  = 'CA';
		employmentApp.City_Job_2__c = 'SFO';
		employmentApp.Address_Job_2__c = '1 Cal';
		employmentApp.Job_Title_Job_2__c = 'Act';
		employmentApp.Position_and_Duties_Job_2__c ='LMTS';
		//employmentApp.From_Year_Job_2__c  = '2002';
		employmentApp.From_Year_Job_2__c  = '';
		//employmentApp.From_Month_Job_2__c = '03';
		employmentApp.From_Month_Job_2__c = '';
		employmentApp.To_Year_Job_2__c  = '2011';
		employmentApp.To_Month_Job_2__c  = '07';
		employmentApp.Ending_Salary_Job_2__c  = 12345.00;
		employmentApp.Name_of_Supervisor_Job_2__c ='Test S';
		employmentApp.Reason_for_Leaving_Job_2__c = 'Test';
		employmentApp.Name_of_Company_Job_3__c = 'SFDC 2';
		employmentApp.Phone_Job_3__c = '';
		employmentApp.Country_Job_3__c = 'US';
		employmentApp.State_Job_3__c = 'CA';
		employmentApp.City_Job_3__c = 'SFO';
		employmentApp.Address_Job_3__c = '1 Cal';
		employmentApp.Job_Title_Job_3__c  ='LMTS';
		employmentApp.Position_and_Duties_Job_3__c ='LMTS';
		employmentApp.From_Year_Job_3__c  = '2002';
		employmentApp.From_Month_Job_3__c = '03';
		employmentApp.To_Year_Job_3__c = '2011';
		employmentApp.To_Month_Job_3__c = '07';
		employmentApp.Ending_Salary_Job_3__c = 12345.00;
		employmentApp.Name_of_Supervisor_Job_3__c  ='Test S';
		employmentApp.Reason_for_Leaving_Job_3__c = 'Test';
		employmentApp.School_Name_Graducate__c = 'Test';
		employmentApp.Country_Graduate__c = 'US';
		employmentApp.State_Graduate__c =  'CA';
		employmentApp.City_Graduate__c = 'SFO';
		employmentApp.Degree_Earned_Graduate__c  = '2002';
		employmentApp.Last_Attended_Year_Graduate__c = '2000';
		employmentApp.Last_Attended_Month_Graduate__c = '02';
		employmentApp.Major_Graduate__c = 'Test';
		employmentApp.Minor_Graduate__c = 'Test';
		employmentApp.Start_Date_Year_Graduate__c =  '2002';
		employmentApp.Last_Attended_Year_Graduate__c = '2002'; 
		employmentApp.Last_Attended_Month_Graduate__c = '02';
		employmentApp.Graduated_First_Name_Graduate__c = 'Test';
		employmentApp.Graduated_Name_Last_Graduate__c = 'Test';
		employmentApp.School_Name_University__c = 'Test';
		employmentApp.Country_University__c = 'US';
		employmentApp.State_University__c  =  'CA';
		employmentApp.City_University__c  = 'SFO';
		employmentApp.Degree_Earned_University__c  = 'Test';
		employmentApp.Last_Attended_Year_University__c  = '2002'; 
		employmentApp.Last_Attended_Month_University__c = '02';
		employmentApp.Major_University__c = 'Test';
		employmentApp.Minor_University__c = 'Test';
		employmentApp.Start_Date_Year_University__c  = '2002'; 
		employmentApp.Start_Date_University__c = '02';
		employmentApp.Last_Attended_Year_University__c = '2002'; 
		employmentApp.Last_Attended_Month_University__c  = '02';
		employmentApp.Graduated_First_Name_University__c = 'Test';
		employmentApp.Graduated_Last_Name_University__c = 'Test';
        insert employmentApp;
        
        BI_User_Permission__c biUserPermission = new BI_User_Permission__c();
        biUserPermission.User__c = currentUser.Id;
        biUserPermission.Intiate__c = true;
        biUserPermission.View__c = true;
        insert biUserPermission;
        System.runAs(currentUser) {
        	System.currentPageReference().getParameters().put('Id',employmentApp.Id);
        	System.currentPageReference().getParameters().put('Action','INTIATE_BI');
        	HireRightIntegrationController hrController = new HireRightIntegrationController();
        	hrController.isTest = true;
        	hrController.validateRequest();
        	System.assert(!ApexPages.hasMessages());
        	PageReference pgf =hrController.processBackgroundData();
        	employmentApp = [Select id,name,BI_Summary_Status__c,Criminal_Screen__c,Education_Screen__c,Employment_Screen__c from Employment_Application__c where Id =: employmentApp.Id];
        	System.debug('employmentApp.BI_Summary_Status__c----------->'+ employmentApp.BI_Summary_Status__c);
        	System.assert(employmentApp.BI_Summary_Status__c == 'Sent');
        	System.assert(employmentApp.Criminal_Screen__c == 'Sent');
        	System.assert(employmentApp.Education_Screen__c == 'Sent');
        	System.assert(employmentApp.Employment_Screen__c == 'Sent');
        	 
        	System.currentPageReference().getParameters().put('Id',employmentApp.Id);
        	System.currentPageReference().getParameters().put('Action','VIEW_BI');
        	HireRightIntegrationController viewHRController = new HireRightIntegrationController();
        	viewHRController.isTest = true;
        	viewHRController.validateRequest();
        	System.debug('Messages------>'+ ApexPages.getMessages());
        	PageReference viewPgf =viewHRController.processBackgroundData();
        	
        	System.currentPageReference().getParameters().put('Id',employmentApp.Id);
        	System.currentPageReference().getParameters().put('Action','VIEW_BI');
        	HireRightIntegrationController updateHRController = new HireRightIntegrationController();
        	updateHRController.isTest = true;
        	updateHRController.validateRequest();
        	System.debug('Messages------>'+ ApexPages.getMessages());
        	PageReference updatePgf =updateHRController.processBackgroundData();
        	
        }
    }   
}