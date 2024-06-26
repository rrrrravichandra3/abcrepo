@isTest
private with sharing class MainMentoringControllerTest {
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
        mentorPatrick.Employee_Id__c = '111111';
        mentorPatrick.Equality_Group_Member__c = 'BOLDforce';        
        mentorPatrick.Hire_Date__c = date.newinstance(2005, 2, 17);
        mentorPatrick.Interests__c = 'Bookworm';
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
        mentorPatrick.Things_To_Learn__c = 'Bookworm';
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
        mentorMichelle.Employee_Id__c = '222222';
        mentorMichelle.Equality_Group_Member__c = 'BOLDforce';
        mentorMichelle.Hire_Date__c = date.newinstance(2002, 2, 17);
        mentorMichelle.Interests__c = 'Bookworm';
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
        mentorMichelle.Things_To_Learn__c = 'Bookworm';
        mentorMichelle.User_Bio__c = 'I want to be a Mentor';
        theMentorUsers.add(mentorMichelle);

        User mentorCiaran = new User();
        mentorCiaran.FirstName = 'Mentor';
        mentorCiaran.LastName = 'Ciaran';
        mentorCiaran.Email = 'Mentor@Ciaran.scratch1';
        mentorCiaran.Alias = 'Tcode';
        mentorCiaran.Username = 'Mentor@Ciaran.scratch1'+randomNumber;
        mentorCiaran.CommunityNickname = 'testCiaran'+randomNumber;
        mentorCiaran.LocaleSidKey = 'en_US';
        mentorCiaran.TimeZoneSidKey = 'GMT';
        mentorCiaran.ProfileID = theProfileId.Id;
        mentorCiaran.LanguageLocaleKey = 'en_US';
        mentorCiaran.EmailEncodingKey = 'UTF-8';
        mentorCiaran.Title = 'Mentoring Officer';
        mentorCiaran.City = 'Dublin';
        mentorCiaran.Available__c = true;
        mentorCiaran.Bug_Report_Tooltip_Dismissed__c = true;
        mentorCiaran.Business_Unit__c = 'None';
        mentorCiaran.Capacity__c = 2;        
        mentorCiaran.Cost_Center__c = '1001-System Engineering Budget';
        mentorCiaran.Department_Number__c = '1234';
        mentorCiaran.Employee_Id__c = '111111';
        mentorCiaran.Equality_Group_Member__c = 'BOLDforce';        
        mentorCiaran.Hire_Date__c = date.newinstance(2005, 2, 17);
        mentorCiaran.Interests__c = 'Bookworm';
        mentorCiaran.Is_Manager__c = false;
        mentorCiaran.Job_Grade__c = 10;
        mentorCiaran.JobFamily__c = 'Engineering';
        mentorCiaran.Market_Segment__c = 'ENTR';
        mentorCiaran.Mentee_Location_Preference__c = 'Denmark';
        mentorCiaran.Mentee_Type_Preference__c = 'Mentoring from Anywhere';
        mentorCiaran.Mentor_Location_Preference__c = 'Ireland';
        mentorCiaran.Mentor_Type_Preference__c = 'Mentoring from Anywhere';        
        mentorCiaran.Onboarding_Dismissed__c = false;
        mentorCiaran.Skills__c = 'Accounting';
        mentorCiaran.Skills_to_Improve__c = 'Accounting';
        mentorCiaran.Things_To_Learn__c = 'Bookworm';
        mentorCiaran.User_Bio__c = 'I want to be a Mentor';

        mentorCiaran.Certifications__c = 'Sales Leader Excellence Coach';
        mentorCiaran.Functional_Competencies__c = 'AE Account Planning and Strategies';
        mentorCiaran.Mentoring_Language__c = 'English';
        mentorCiaran.Experiences__c = 'Career Experience - Expat Life and/or Relocation';
        mentorCiaran.Equality_Group_Member__c = 'Abilityforce';
        mentorCiaran.Great_Competencies__c = 'Accountability';
        
        theMentorUsers.add(mentorCiaran);

        insert theMentorUsers;
        
        List<Mentoring_Match__c> theMatches = new List<Mentoring_Match__c>();

        Mentoring_Match__c newMatch = new Mentoring_Match__c();
        newMatch.Mentee__c = mentorPatrick.Id;
        newMatch.Mentor__c = mentorMichelle.Id;
        newMatch.Status__c = 'Requested';
        theMatches.add(newMatch);

        Mentoring_Match__c newMatch2 = new Mentoring_Match__c();
        newMatch2.Mentee__c = mentorMichelle.Id;
        newMatch2.Mentor__c = mentorPatrick.Id;
        newMatch2.Status__c = 'Requested';
        theMatches.add(newMatch2);

        Mentoring_Match__c newMatch3 = new Mentoring_Match__c();
        newMatch3.Mentee__c = UserInfo.getUserId();
        newMatch3.Mentor__c = mentorPatrick.Id;
        newMatch3.Status__c = 'Requested';
        theMatches.add(newMatch3);

        Mentoring_Match__c newMatch4 = new Mentoring_Match__c();
        newMatch4.Mentee__c = mentorPatrick.Id;
        newMatch4.Mentor__c = UserInfo.getUserId();
        newMatch4.Status__c = 'Requested';
        //Inserted this here outside of the list so I can use ID later
        insert newMatch4;
        
        insert theMatches;

        List<Functional_Role__c> theFunctionalRoles = new List<Functional_Role__c>();

        Functional_Role__c theFunctionalRole1 = new Functional_Role__c();
        theFunctionalRole1.Name = 'Account Executive';
        theFunctionalRole1.Functional_Competencies__c = 'AE Account Planning and Strategies;AE Research and Discovery;AE Solutioning;AE Customer Communication;AE Resource Application;AE Team Selling';
        theFunctionalRoles.add(theFunctionalRole1);

        Functional_Role__c theFunctionalRole2 = new Functional_Role__c();
        theFunctionalRole2.Name = 'Accounting/Compliance/Audit';
        theFunctionalRole2.Functional_Competencies__c = 'AC/CO/AU Critical Attention to Detail;AC/CO/AU Decision Making;AC/CO/AU Creating Strategy;AC/CO/AU Understanding of Regulatory Standards, Guidelines, Governance, and Financial Management;AC/CO/AU Planning and Organization';
        theFunctionalRoles.add(theFunctionalRole2);

        insert theFunctionalRoles;

        Program_Template__c thePT = new Program_Template__c();
        thePT.Name = 'Standard';
        insert thePT;

        Program_Template_Stage__c theProgramTemplateStage1 = new Program_Template_Stage__c();
        theProgramTemplateStage1.Name = 'Welcome';
        theProgramTemplateStage1.Mentee_Description__c = '<h4>Your Mentee Journey Starts Now</h4><p>At Salesforce, Mentoring is a great way to get personal and development guidance from others. Many employees here at all levels - even executive leadership - have benefited from it.</p><p><br></p><p>These templates provide essential tools and suggestions for building a successful learning partnership with your Mentor. Please take the time to review before you begin your Mentoring journey.</p><p><br></p><p><b>It will help you:</b></p><ul><li>Understand how Mentoring works in practice</li><li>Prepare for and establish a meaningful relationship with your Mentor</li><li>Optimize the Mentoring experience for both of you</li></ul><p><br></p>';
        theProgramTemplateStage1.Mentor_Description__c = '<h4>Your Mentor Journey Starts Now</h4><p>You are now stepping into the shoes of a Mentor and will play an important role in fostering the development of others, helping them meet their development goals within the company.</p><p><br></p><p>Whether you’re a first-time or experienced Mentor, these templates provide essential tools and suggestions for building a successful learning partnership with your Mentee. Please take the time to review it before you begin your Mentoring experience.</p><p><br></p><p><b>The templates will help you:</b></p><ul><li>Understand how Mentoring works in practice</li><li>Prepare for and establish a meaningful relationship with your Mentee</li><li>Optimize the Mentoring experience for both of you</li></ul>';
        theProgramTemplateStage1.Order__c = 1;
        theProgramTemplateStage1.Program_Template__c = thePT.Id;
        insert theProgramTemplateStage1;

        Program_Template_Stage__c theProgramTemplateStage2 = new Program_Template_Stage__c();
        theProgramTemplateStage2.Name = 'Stage 1: Get Ready';
        theProgramTemplateStage2.Mentee_Description__c = '<p><b style=\"font-size: 14px;\">Define your own Mentoring goals</b></p><p><br></p><p>The first step of finding a mentor is defining what you want (not planning your whole career, but what you want in the short term). For self reflection, you might find the resources such as Values or Pathways for self reflection helpful - find them on the Talent Experience site <a href=\"https://talentexperience.salesforce.com/grow-your-career/career-planning/\" target=\"_blank\">here</a>.</p><p><br></p><p><span style=\"color: rgb(68, 68, 68);\">Use the links below for inspiration and don&#39;t forget to check out </span><a href=\"https://salesforce-internal.slack.com/archives/C02LABLUMU7\" target=\"_blank\" style=\"background-color: rgb(255, 255, 255);\">#mentoring-at-salesforce</a><span style=\"color: rgb(68, 68, 68);\"> on Slack!</span></p>';
        theProgramTemplateStage2.Mentor_Description__c = '<p><b style=\"font-size: 14px;\">Define your own Mentoring goals</b></p><p><br></p><p>Mentors typically find that Mentoring is a learning adventure. As a Mentor, you will find that while you might be giving a lot to your Mentee, there is much you can gain from your relationship as well. Treat this experience as an enlightening adventure and free yourself to be open to seeing different perspectives, in order to gain new insight and knowledge.</p><p><br></p><p>Use the links below for inspiration and don&#39;t <span style=\"color: rgb(68, 68, 68); background-color: rgb(255, 255, 255);\">forget to check out </span><a href=\"https://salesforce-internal.slack.com/archives/C02LABLUMU7\" target=\"_blank\" style=\"background-color: rgb(255, 255, 255);\">#mentoring-at-salesforce</a><span style=\"background-color: rgb(255, 255, 255); color: rgb(68, 68, 68);\"> on Slack!</span></p>';
        theProgramTemplateStage2.Order__c = 2;
        theProgramTemplateStage2.Program_Template__c = thePT.Id;
        insert theProgramTemplateStage2;


        Program__c theP = new Program__c();
        theP.Program_Template__c = thePT.Id;
        theP.Mentoring_Match__c = newMatch4.Id;
        insert theP;

        List<Program_Stage__c> theProgramStages = new List<Program_Stage__c>();

        Program_Stage__c theProgramStage1 = new Program_Stage__c();
        theProgramStage1.Program__c = theP.Id;
        theProgramStage1.Completed__c = false;
        theProgramStage1.Program_Template_Stage__c = theProgramTemplateStage1.Id;
        System.debug('theP.Id:' + theP.Id);
        insert theProgramStage1;

        Program_Stage__c theProgramStage2 = new Program_Stage__c();
        theProgramStage2.Program__c = theP.Id;
        theProgramStage2.Completed__c = false;
        theProgramStage2.Program_Template_Stage__c = theProgramTemplateStage2.Id;
        insert theProgramStage2;

        Meeting__c theMeeting = new Meeting__c();
        theMeeting.Meeting_Title__c = 'Meeting Title';
        theMeeting.Mentoring_Match__c = newMatch4.Id;
        theMeeting.Meeting_Date_Time__c = DateTime.now();
        insert theMeeting;

        Template_Survey__c theSurveyLinks = new Template_Survey__c();
        theSurveyLinks.Mentee_Survey_Link__c = 'http://www.google.com';
        theSurveyLinks.Mentor_Survey_Link__c = 'http://www.google.com';
        insert theSurveyLinks;
    }

    @isTest
    static void validateRetrieveMentorsFromOrg(){
        List<Mentoring_Match__c> theMentorMatches = MainMentoringController.retrieveMentorsFromOrg('Requested');
        System.assert(!theMentorMatches.isEmpty(), 'retrieveMentorsFromOrg error, list is empty');
    }

    @isTest
    static void validateRetrieveMenteesFromOrg(){
        List<Mentoring_Match__c> theMenteeMatches = MainMentoringController.retrieveMenteesFromOrg('Requested');
        System.assert(!theMenteeMatches.isEmpty(), 'retrieveMenteesFromOrg error, list is empty');
    }

    @isTest
    static void validateCreateMentoringMatch(){
        User theMentorPatrick = [SELECT Id FROM User WHERE FirstName = 'Mentor' AND LastName = 'Patrick' AND Employee_Id__c = '111111' LIMIT 1];
        User theMentorMichelle = [SELECT Id FROM User WHERE FirstName = 'Mentor' AND LastName = 'Michelle' AND Employee_Id__c = '222222' LIMIT 1];

        MainMentoringController.createMentoringMatch(theMentorPatrick.Id, null, 'Requested', 'Can I be your Mentor', 'No', 100, 'Other', 'More removal information', 'Other', 'More interest information');
        MainMentoringController.createMentoringMatch(null, theMentorMichelle.Id, 'Requested', 'Can I be your Mentor', 'No', 100, 'Other', 'More removal information', 'Other', 'More interest information');

        Mentoring_Match__c theMentoringMatch = MainMentoringController.createMentoringMatch(theMentorPatrick.Id, theMentorMichelle.Id, 'Requested', 'Can I be your Mentor', 'No', 100, 'Other', 'More removal information', 'Other', 'More interest information');
        System.assert(theMentoringMatch.Id != null, 'createMentoringMatch error, no match created');
    }

    @isTest
    static void validateCountMentors(){
        List<Integer> theMetrics = MainMentoringController.countMentors(UserInfo.getUserId());
        System.assert(!theMetrics.isEmpty(), 'countMentors error, list is empty');
    }
    
    @isTest
    static void validateRolesAndCompetencies(){
        List<MainMentoringController.PicklistWrapper> theMetrics = MainMentoringController.retrieveRolesAndCompetencies();
        System.assert(!theMetrics.isEmpty(), 'rolesAndCompetencies error, list is empty');
    }

    @isTest
    static void validateProgramStagesFromMentoringMatch(){
        User theMentorPatrick = [SELECT Id FROM User WHERE FirstName = 'Mentor' AND LastName = 'Patrick' AND Employee_Id__c = '111111' LIMIT 1];
        Mentoring_Match__c theMentoringMatch = [SELECT Id, Mentee__c, Mentor__c, Status__c FROM Mentoring_Match__c WHERE Mentee__c = :theMentorPatrick.Id AND Mentor__c = :UserInfo.getUserId() AND Status__c = 'Requested'];
        MainMentoringController.ProgramWrapper theMetric = MainMentoringController.retrieveProgramStagesFromMentoringMatch(theMentoringMatch.Id);
        System.assert(theMetric != null, 'programStagesFromMentoringMatch error, object is empty');
    }
// Methods added to increase code coverage - 27/06/2023
    @isTest
    static void validateMeetingsFromMentoringMatch(){
        User theMentorPatrick = [SELECT Id FROM User WHERE FirstName = 'Mentor' AND LastName = 'Patrick' AND Employee_Id__c = '111111' LIMIT 1];
        Mentoring_Match__c theMentoringMatch = [SELECT Id, Mentee__c, Mentor__c, Status__c FROM Mentoring_Match__c WHERE Mentee__c = :theMentorPatrick.Id AND Mentor__c = :UserInfo.getUserId() AND Status__c = 'Requested'];
        List<Meeting__c> theMetrics = MainMentoringController.retrieveMeetingsFromMentoringMatch(theMentoringMatch.Id);
        System.assert(!theMetrics.isEmpty(), 'meetingsFromMentoringMatch error, list is empty');
    }

    @isTest
    static void validateRetrieveMentors(){
        List<String> certs = new List<String>{'Sales Leader Excellence Coach'};
        List<String> typeOfMentoring = new List<String>{'Mentoring from Anywhere'};
        List<String> functionalCompetencies = new List<String>{'AE Account Planning and Strategies'};
        List<String> languages = new List<String>{'English'};
        List<String> experiences = new List<String>{'Career Experience - Expat Life and/or Relocation'};
        List<String> egcs = new List<String>{'Abilityforce'};
        List<String> greatCompetencies = new List<String>{'Accountability'};
        List<String> locations = new List<String>{'Denmark'};
        List<User> theUsers = MainMentoringController.retrieveMentors(certs, typeOfMentoring, functionalCompetencies, languages, experiences, egcs, greatCompetencies, locations);
        System.assert(!theUsers.isEmpty(), 'retrieveMentors error, list is empty');
    }

    @isTest
    static void validateRetrieveSurveyLinks(){
        Template_Survey__c theTemplateSurvey = MainMentoringController.retrieveSurveyLinks();
        System.assert(theTemplateSurvey != null, 'retrieveSurveyLinks error, object is empty');
    }
    @isTest
    static void validategetMentoringMatch(){
        User theMentorPatrick = [SELECT Id FROM User WHERE FirstName = 'Mentor' AND LastName = 'Patrick' AND Employee_Id__c = '111111' LIMIT 1];
        User theMentorMichelle = [SELECT Id FROM User WHERE FirstName = 'Mentor' AND LastName = 'Michelle' AND Employee_Id__c = '222222' LIMIT 1];
        Boolean result = MainMentoringController.getMentoringMatch(theMentorPatrick.Id,theMentorMichelle.Id);
        system.assertEquals(true, result);
    }
}