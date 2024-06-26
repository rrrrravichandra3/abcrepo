global with sharing class IFB_InterviewQuestionUtilities 
{
    public static final String DEFAULT_POSITION = 'Default';
    
    static webservice string RenumberQuestions(string questionCategory)
    {
        string resultStr = '';
        List<IFB_Interview_Question__c> renumberedQuestions = new List<IFB_Interview_Question__c>();
        integer i = 1;
        for(IFB_Interview_Question__c iq: [select Id from IFB_Interview_Question__c where Question_Category_Text__c =: questionCategory and Active__c = true
                                       order by Sort_Order__c, Competency__c, LastModifiedDate desc nulls last])
        {
            iq.Sort_Order__c = i;
            renumberedQuestions.add(iq);
            i++;
        }
        
        if(renumberedQuestions.size() > 0)
        {
            try
            {
                update renumberedQuestions;
                resultStr = questionCategory + ' Renumbered';
            }
            catch(Exception ex)
            {
                resultStr = ex.getMessage();
            }
        }
        else
        {
            resultStr = 'No questions to renumber';
        }
        
        return resultStr;
    }

    public static String getQuestionCategoryMapKey(String position, String interviewType)
    {
        return position + '|' + interviewType;
    }
    
    //return position specific question category for interviewType if it exists
    //otherwise return default
    public static String getQuestionCategory(String position, String interviewType)
    {
        Map<String, IFB_InterviewQuestionCategoryMap__c> questionCategoryMap = new Map<String, IFB_InterviewQuestionCategoryMap__c>();
        List<IFB_InterviewQuestionCategoryMap__c> customSettingRecords = IFB_InterviewQuestionCategoryMap__c.getAll().values();
        for(IFB_InterviewQuestionCategoryMap__c currentCSentry : customSettingRecords){
            String externalKey = currentCSentry.Position__c + '|'+ currentCSentry.Interview_Record_Type_Name__c;
            questionCategoryMap.put(externalKey,currentCSentry);
        }
        if (questionCategoryMap != null)
        {
            IFB_InterviewQuestionCategoryMap__c positionSpecificValue = 
                questionCategoryMap.get(getQuestionCategoryMapKey(position, interviewType));
            if (positionSpecificValue != null)
            {
                return positionSpecificValue.Question_Category__c;
            } 
            else
            {
                IFB_InterviewQuestionCategoryMap__c defaultValue = 
                    questionCategoryMap.get(getQuestionCategoryMapKey(DEFAULT_POSITION, interviewType));
                if (defaultValue != null)
                {
                    return defaultValue.Question_Category__c;
                }
            }
        }
        return ''; // system misconfigured - consider throwing exception
    }
    
    public static List<IFB_Interview_Question__c> GetActiveQuestions(String position, String interviewType)
    {
        List<IFB_Interview_Question__c> interviewQuestions = new List<IFB_Interview_Question__c>();

        // We are intentionally skipping the FLS check of the Sort_Order__c field.
        // That field is only accessible by a subset of users and is referenced in shared components (Page Layouts/Related Lists/List Views) 
        // accesible to other uses that don't have access to the field.  Users of those groups may share the same Profile, so limiting access
        // at UI level (via multiple Page Layouts or separate List Views) is not straight forward or the effort to do it (Page Overrides?) 
        // might not worth it.
        Boolean hasAccess = IFB_AccessibilityUtils.checkFLS('IFB_Interview_Question__c',
                                IFB_AccessibilityUtils.PermissionType.ACCESSIBLE,
                                new List<String> {
                                'Id',
                                'Question_Category_Text__c',
                                'Active__c',
                                'Competency__c'}); 

        if (hasAccess) {
            interviewQuestions = [select Id
                              from   IFB_Interview_Question__c
                              where  Question_Category_Text__c =: getQuestionCategory(position, interviewType)
                              and    Active__c = true 
                              order by Sort_Order__c, Competency__c nulls last]; 
        }
             
        return interviewQuestions;
    }
}