// Test Data Factory class to create Test Data used for Test Classes for the Recruiting App
@isTest
public class IFB_RecruitingTestDataFactory {
    
    public static void createUser(String sPermissionSet, Integer numUsers) {
        // Create User
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        
        // Determine the Alias
        String sAlias = '';
        String sPSName = '';
        
        if (sPermissionSet.equals('Recruiter'))
        {
            sPSName = 'IFB_Recruiting_Recruiter';
            sAlias = 'REC';
        }
        else
        {
            if (sPermissionSet.equals('Management'))
            {
                sPSName = 'IFB_Recruiting_Management';
                sAlias = 'MGR';
            }
            else
            {
                if (sPermissionSet.equals('Interviewer'))
                {
                    sPSName = 'IFB_Recruiting_Interviewer';
                    sAlias = 'INT';
                }
            }
                    
        }
        
        PermissionSet ps = [SELECT Id FROM PermissionSet Where Name =: sPSName];
        
        // Create the Users
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        
        for(Integer i=0;i<numUsers;i++) {
           
            String sUserID = sAlias + i;
        
            User u = new User(Alias = sUserID, Email= sUserID + '@recruitingapp2.com',
                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                 LocaleSidKey='en_US', ProfileId = p.Id,
                 TimeZoneSidKey='America/Los_Angeles', UserName= sUserID + '@recruitingapp2.com');
                 
            userList.add(u);    
        }
        
        if(!userList.isEmpty())
        {
            insert userList;
        }
        
        for (User u: userList)
        {
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.Id, AssigneeId = u.Id);
            psaList.add(psa);    
        }
        
        if(!psaList.isEmpty())
        {
            insert psaList;
        }
    }
    
    public static void createInterviewQuestionCategory(List<String> interviewRecordTypeName, List<String> positions, List<String> categories) {
       
        List<IFB_InterviewQuestionCategoryMap__c> iqCategoryList = new List<IFB_InterviewQuestionCategoryMap__c>();
        
        for(Integer i = 0; i < positions.size(); i++) { 
            IFB_InterviewQuestionCategoryMap__c iqcm = new IFB_InterviewQuestionCategoryMap__c (
                                                   Name = IFB_InterviewQuestionUtilities.getQuestionCategoryMapKey(positions[i], interviewRecordTypeName[i]),
                                                   Position__c = IFB_InterviewQuestionUtilities.DEFAULT_POSITION,
                                                   Interview_Record_Type_Name__c = interviewRecordTypeName[i],
                                                   Question_Category__c = categories[i]);
            iqCategoryList.add(iqcm);    
        }
        
        if(!iqCategoryList.isEmpty())
        {
            insert iqCategoryList;
        }
    }
    
    public static void createInterviewQuestions(String category, Integer noOfQuestions) {
       
        List<IFB_Interview_Question__c> questionList = new List<IFB_Interview_Question__c>();
        
        for(Integer i = 1; i <= noOfQuestions; i++) { 
            IFB_Interview_Question__c question = new IFB_Interview_Question__c (
                                                   Active__c = true,
                                                   Domain__c = 'Development',
                                                   Question__c = 'Question' + i,
                                                   Question_Category__c = category,
                                                   Sort_Order__c = i);
            questionList.add(question);    
        }
        
        if(!questionList.isEmpty())
        {
            insert questionList;
        }
    }
    
    public static void createRatings() {
       
        IFB_Recruiting_Scoring__c rating = IFB_Recruiting_Scoring__c.getInstance(UserInfo.getOrganizationId());
        if(rating.Id == null)
        {
            rating.Rating1_Definition__c = 'Candidate Below Par';
            rating.Rating1_Score_Label__c = 'Below Expectations';
            rating.Rating1_Score_Value__c = 1;
            rating.Rating2_Definition__c = 'Probably Would Not Work';
            rating.Rating2_Score_Label__c = 'Partially Meets Expectations';
            rating.Rating2_Score_Value__c = 2;
            rating.Rating3_Definition__c = 'Good Fit';
            rating.Rating3_Score_Label__c = 'Meets Expectations';
            rating.Rating3_Score_Value__c = 3;
            rating.Rating4_Definition__c = 'Hire this person immediately';
            rating.Rating4_Score_Label__c = 'Exceeds Expectations';
            rating.Rating4_Score_Value__c = 4;
            insert rating;
        }
        
    }
}