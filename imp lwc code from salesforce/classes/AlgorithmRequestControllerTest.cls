@isTest
private with sharing class AlgorithmRequestControllerTest {
    @TestSetup
    static void makeData(){
        Profile theProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        List<User> theMentorUsers = new List<User>();

        Integer randomNumber = Integer.valueof((Math.random() * 10000));

        User mentorPatrick = new User();
        mentorPatrick.FirstName = 'Mentor';
        mentorPatrick.LastName = 'Patrick';
        mentorPatrick.Email = 'Mentor@Patrick.scratch1';
        mentorPatrick.Alias = 'Tcode';
        mentorPatrick.Username = 'Mentor@Patrick.scratch1'+randomNumber;
        mentorPatrick.CommunityNickname = 'testPatrick'+randomNumber;
        mentorPatrick.LocaleSidKey = 'en_US';
        mentorPatrick.TimeZoneSidKey = 'GMT';
        mentorPatrick.ProfileID = theProfileId.Id;
        mentorPatrick.LanguageLocaleKey = 'en_US';
        mentorPatrick.EmailEncodingKey = 'UTF-8';
        mentorPatrick.Title = 'Mentoring Officer';
        mentorPatrick.City = 'Dublin';
        mentorPatrick.Available__c = true;
        mentorPatrick.Bug_Report_Tooltip_Dismissed__c = true;
        mentorPatrick.Business_Unit__c = 'None';
        mentorPatrick.Capacity__c = 2;
        mentorPatrick.Cost_Center__c = '1001-System Engineering Budget';
        mentorPatrick.Department_Number__c = '1234';
        mentorPatrick.Employee_Id__c = '123456';
        mentorPatrick.Equality_Group_Member__c = 'BOLDforce';
        mentorPatrick.Hire_Date__c = date.newinstance(2005, 2, 17);
        mentorPatrick.Interests__c = 'Agriculture';
        mentorPatrick.Is_Manager__c = false;
        mentorPatrick.Job_Grade__c = 10;
        mentorPatrick.JobFamily__c = 'Engineering';
        mentorPatrick.Market_Segment__c = 'ENTR';
        mentorPatrick.Mentee_Location_Preference__c = 'Denmark';
        mentorPatrick.Mentee_Type_Preference__c = 'Mentoring from Anywhere';
        mentorPatrick.Mentor_Location_Preference__c = 'Ireland';
        mentorPatrick.Mentor_Type_Preference__c = 'Mentoring from Anywhere';
        mentorPatrick.Onboarding_Dismissed__c = false;
        mentorPatrick.Skills__c = 'Accounting';
        mentorPatrick.Skills_to_Improve__c = 'Accounting';
        mentorPatrick.Things_To_Learn__c = 'Animals';
        mentorPatrick.User_Bio__c = 'I want to be a Mentor';

        theMentorUsers.add(mentorPatrick);

        User mentorMichelle = new User();
        mentorMichelle.FirstName = 'Mentor';
        mentorMichelle.LastName = 'Michelle';
        mentorMichelle.Email = 'Mentor@Michelle.scratch1';
        mentorMichelle.Alias = 'Tcode';
        mentorMichelle.Username = 'Mentor@Michelle.scratch1'+randomNumber;
        mentorMichelle.CommunityNickname = 'testMichelle'+randomNumber;
        mentorMichelle.LocaleSidKey = 'en_US';
        mentorMichelle.TimeZoneSidKey = 'GMT';
        mentorMichelle.ProfileID = theProfileId.Id;
        mentorMichelle.LanguageLocaleKey = 'en_US';
        mentorMichelle.EmailEncodingKey = 'UTF-8';
        mentorMichelle.Title = 'Mentoring Officer';
        mentorMichelle.City = 'Dublin';
        mentorMichelle.Available__c = true;
        mentorMichelle.Bug_Report_Tooltip_Dismissed__c = true;
        mentorMichelle.Business_Unit__c = 'None';
        mentorMichelle.Capacity__c = 2;
        mentorMichelle.Cost_Center__c = '1001-System Engineering Budget';
        mentorMichelle.Department_Number__c = '1234';
        mentorMichelle.Employee_Id__c = '123456';
        mentorMichelle.Equality_Group_Member__c = 'BOLDforce';
        mentorMichelle.Hire_Date__c = date.newinstance(2002, 2, 17);
        mentorMichelle.Interests__c = 'Agriculture';
        mentorMichelle.Is_Manager__c = false;
        mentorMichelle.Job_Grade__c = 10;
        mentorMichelle.JobFamily__c = 'Engineering';
        mentorMichelle.Market_Segment__c = 'ENTR';
        mentorMichelle.Mentee_Location_Preference__c = 'Ireland';
        mentorMichelle.Mentee_Type_Preference__c = 'Mentoring from Anywhere';
        mentorMichelle.Mentor_Location_Preference__c = 'Ireland';
        mentorMichelle.Mentor_Type_Preference__c = 'Mentoring from Anywhere';
        mentorMichelle.Onboarding_Dismissed__c = false;
        mentorMichelle.Skills__c = 'Accounting';
        mentorMichelle.Skills_to_Improve__c = 'Accounting';
        mentorMichelle.Things_To_Learn__c = 'Animals';
        mentorMichelle.User_Bio__c = 'I want to be a Mentor';
        theMentorUsers.add(mentorMichelle);

        insert theMentorUsers;
    }
}