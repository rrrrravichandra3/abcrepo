public class IFB_SIFT_Repository_Controller {
    /*
    1.Retrieve interview types, competencies, interview questions based on sift position and sift interview type
    2.Retrieve competency descriptions based on sift group, sift position and sift interview type
    */

    @AuraEnabled
    public static IFB_SIFT_Repository_Controller.interviewQuestionval getInterviewQuestions(string siftGroup,string siftPosition,string siftInterviewtype){
        List<IFB_Interview_Question__c> interviewQuestions = new list<IFB_Interview_Question__c>();
        IFB_SIFT_Repository_Controller.interviewQuestionval interviewQuestionval = null;
        List<IFB_SIFT_Repository_Controller.interviewQuestion> interviewQuestionObjs = new list<IFB_SIFT_Repository_Controller.interviewQuestion>();
        Map<String, String> QuestionCategoryInterviewMap = new Map<String, String>();
        Profile  profile= [select name from profile where id = :userinfo.getProfileId()];
        //track click event
        PF_Analyticsfactory.getPFAnalyticsImpl().trackEvents(new List<PF_AnalyticsEvent>{ new PF_AnalyticsEvent('SIFT Repo',profile.name+'_clicked_view_button',profile.name+'_clicked_view_button','80')});
        
        if(siftPosition != null){
                       
            Map<String, IFB_InterviewQuestionCategoryMap__c> questionCategoryMap = new Map<String, IFB_InterviewQuestionCategoryMap__c>();
            List<IFB_InterviewQuestionCategoryMap__c> customSettingRecords = IFB_InterviewQuestionCategoryMap__c.getAll().values();
            for(IFB_InterviewQuestionCategoryMap__c currentCSentry : customSettingRecords){
                String externalKey = currentCSentry.Position__c + '|'+ currentCSentry.Interview_Record_Type_Name__c;
                questionCategoryMap.put(externalKey,currentCSentry);
            }
            
            Set<string> QuestionCategoryNames = new Set<string>();

            if(siftInterviewtype!= null){
                String externalKey = siftPosition+ '|' + siftInterviewtype;
                if(questionCategoryMap.containsKey(externalKey)){
                    IFB_InterviewQuestionCategoryMap__c intQCatMap = questionCategoryMap.get(externalKey);
                    QuestionCategoryNames.add(intQCatMap.Question_Category__c);
                    if(!QuestionCategoryInterviewMap.containsKey(intQCatMap.Question_Category__c)){
                        QuestionCategoryInterviewMap.put(intQCatMap.Question_Category__c, intQCatMap.Interview_Record_Type_Name__c);
                    }
                }
                else{
                    externalKey = 'Default'+ '|' + siftInterviewtype;
                    if(questionCategoryMap.containsKey(externalKey)){
                        IFB_InterviewQuestionCategoryMap__c intQCatMap = questionCategoryMap.get(externalKey);
                        QuestionCategoryNames.add(intQCatMap.Question_Category__c);
                        if(!QuestionCategoryInterviewMap.containsKey(intQCatMap.Question_Category__c)){
                            QuestionCategoryInterviewMap.put(intQCatMap.Question_Category__c, intQCatMap.Interview_Record_Type_Name__c);
                        }
                    }
                }
            }else{
                List<SIFT_Interview_Type__c> allInterviewTypes = [Select Id, Name from SIFT_Interview_Type__c where SIFT_Group__r.Name =: siftGroup AND Active__c = true];
                for(SIFT_Interview_Type__c intwType : allInterviewTypes){
                    String externalKey = siftPosition+ '|' + intwType.Name;
                    if(questionCategoryMap.containsKey(externalKey)){
                        IFB_InterviewQuestionCategoryMap__c intQCatMap = questionCategoryMap.get(externalKey);
                        QuestionCategoryNames.add(intQCatMap.Question_Category__c);
                        if(!QuestionCategoryInterviewMap.containsKey(intQCatMap.Question_Category__c)){
                            QuestionCategoryInterviewMap.put(intQCatMap.Question_Category__c, intQCatMap.Interview_Record_Type_Name__c);
                        }
                    }
                    else{
                        externalKey = 'Default'+ '|' + intwType.Name;
                        if(questionCategoryMap.containsKey(externalKey)){
                            IFB_InterviewQuestionCategoryMap__c intQCatMap = questionCategoryMap.get(externalKey);
                            QuestionCategoryNames.add(intQCatMap.Question_Category__c);
                            if(!QuestionCategoryInterviewMap.containsKey(intQCatMap.Question_Category__c)){
                                QuestionCategoryInterviewMap.put(intQCatMap.Question_Category__c, intQCatMap.Interview_Record_Type_Name__c);
                            }
                        }
                    }
                }
            }
            
            interviewQuestions =  [select Competency__c ,Question__c, Question_Category_Text__c,
                                                                   Rating1_Definition__c,Rating2_Definition__c,Rating3_Definition__c,Rating4_Definition__c
                                                                   from   IFB_Interview_Question__c
                                                                   where  Question_Category_Text__c IN :QuestionCategoryNames
                                                                   and    Active__c = true 
                                                                   order by Question_Category_Text__c, Sort_Order__c, Competency__c nulls last];
            
            Map<String, List<String>> intvTypeToCompetencyNamesListMap = new Map<String, List<String>>();
            for(IFB_Interview_Question__c currentQuestion : interviewQuestions){
                String intvTypeName = QuestionCategoryInterviewMap.get(currentQuestion.Question_Category_Text__c);
                String competencyName = currentQuestion.Competency__c;
                if(intvTypeName == null || competencyName == null || String.isEmpty(intvTypeName) || String.isEmpty(competencyName)){
                    continue;
                }
                if(!intvTypeToCompetencyNamesListMap.containsKey(intvTypeName)){
                    intvTypeToCompetencyNamesListMap.put(intvTypeName, new List<String>());
                }
                intvTypeToCompetencyNamesListMap.get(intvTypeName).add(competencyName);
            }
            
            Map<String,Competency> competencyDescriptionMap = getCompetencyDescriptions(siftGroup, siftPosition, intvTypeToCompetencyNamesListMap);

            if(siftInterviewtype != null){
                for(IFB_Interview_Question__c intWQ : interviewQuestions){
                    String compDescription = '';
                    List<String> additionalQuestions = new List<String>();
                    if(competencyDescriptionMap.containsKey(intWQ.Competency__c)){
                        compDescription = competencyDescriptionMap.get(intWQ.Competency__c).description;
                        additionalQuestions = competencyDescriptionMap.get(intWQ.Competency__c).additionalQuestions;
                    }
                    List<String> rating = new List<String>();
                     rating.add('Rating 1 : '+(String.isBlank(intWQ.Rating1_Definition__c)?'':intWQ.Rating1_Definition__c));
                     rating.add('Rating 2 : '+(String.isBlank(intWQ.Rating2_Definition__c)?'':intWQ.Rating2_Definition__c));
                     rating.add('Rating 3 : '+(String.isBlank(intWQ.Rating3_Definition__c)?'':intWQ.Rating3_Definition__c));
                     rating.add('Rating 4 : '+(String.isBlank(intWQ.Rating4_Definition__c)?'':intWQ.Rating4_Definition__c));
                    interviewQuestionObjs.add(new interviewQuestion(siftInterviewtype, intWQ.Competency__c,compDescription,additionalQuestions,intWQ.Question__c,rating));
                }
                interviewQuestionval = new interviewQuestionval(interviewQuestionObjs, competencyDescriptionMap);
            }
            else{
                for(IFB_Interview_Question__c intWQ : interviewQuestions){
                    String compDescription = '';
                    List<String> additionalQuestions = new List<String>();
                    if(competencyDescriptionMap.containsKey(intWQ.Competency__c)){
                        compDescription = competencyDescriptionMap.get(intWQ.Competency__c).description;
                        additionalQuestions = competencyDescriptionMap.get(intWQ.Competency__c).additionalQuestions;
                    }
                    List<String> rating = new List<String>();
                    rating.add('Rating 1 : '+(String.isBlank(intWQ.Rating1_Definition__c)?'':intWQ.Rating1_Definition__c));
                    rating.add('Rating 2 : '+(String.isBlank(intWQ.Rating2_Definition__c)?'':intWQ.Rating2_Definition__c));
                    rating.add('Rating 3 : '+(String.isBlank(intWQ.Rating3_Definition__c)?'':intWQ.Rating3_Definition__c));
                    rating.add('Rating 4 : '+(String.isBlank(intWQ.Rating4_Definition__c)?'':intWQ.Rating4_Definition__c));
                  interviewQuestionObjs.add(new interviewQuestion(QuestionCategoryInterviewMap.get(intWQ.Question_Category_Text__c), intWQ.Competency__c,compDescription,additionalQuestions, intWQ.Question__c,rating));
                }
                interviewQuestionval = new interviewQuestionval(interviewQuestionObjs, competencyDescriptionMap);
            }
        }
        
        return interviewQuestionval;
        
    }

    @AuraEnabled
    public static Map<String,Competency> getCompetencyDescriptions(String groupValue, String positionValue, Map<String, List<String>> intvTypeToCompetencyNamesListMap) {
        Map<String,Competency> competencies = new Map<String,Competency>();
        
        for(String currentIntvType : intvTypeToCompetencyNamesListMap.keySet()){
            Map<String, Competency> tempMap = getCompetencyDescriptionsSingleIntvType(intvTypeToCompetencyNamesListMap.get(currentIntvType), groupValue, currentIntvType, positionValue);
            competencies.putAll(tempMap);
        }
        return competencies;
    }

    private static Map<String,Competency> getCompetencyDescriptionsSingleIntvType(List<String> competencyNames, String groupValue, String interviewTypeValue, String positionValue) {
        Map<String,Competency> competencies = new Map<String,Competency>();
        List<IFB_Competency_Description__c> descriptions = IFB_CompetencyDescription_DAO.getRecordsFromCompetencyNames(competencyNames, groupValue, interviewTypeValue, positionValue);
        
        IFB_CompetencyDescriptionSorter competencySorter = new IFB_CompetencyDescriptionSorter(descriptions, groupValue, interviewTypeValue, positionValue);
        Map<String, IFB_Competency_Description__c> competencyNameTodecriptionRecMap = competencySorter.getCompetencyByNameMap();

        for(IFB_Competency_Description__c description : competencyNameTodecriptionRecMap.values()){
            Competency competency = new Competency(description.Name, description.Competency_Description__c, description.Japan_Name__c, description.Japan_Competency_Description__c);
            //Populate english additional questions
            if(!String.isBlank(description.Additional_Questions__c)){
                String questions = IFB_InterviewUtilities.sanitizeAndreplacePipeWithNewLine(description.Additional_Questions__c);
                for(String question : questions.split('\n')){
                    if(String.isBlank(question) == false) {
                        competency.additionalQuestions.add(question);                        
                    }
                }
            }
            //Populate Japan Additional Questions
            if(!String.isBlank(description.Japan_Additional_Question__c)){
                String questions = IFB_InterviewUtilities.sanitizeAndreplacePipeWithNewLine(description.Japan_Additional_Question__c);                
                for(String question : questions.split('\n')){
                    if(String.isBlank(question) == false) {                    
                        competency.japanAdditionalQuestions.add(question);
                    }
                }
            }
            competencies.put(description.Name, competency);
        }        
        return competencies;
    }

    public class Competency{
        
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public List<String> additionalQuestions;
        @AuraEnabled
        public String japanName;
        @AuraEnabled
        public String japanDescription;
        @AuraEnabled
        public List<String> japanAdditionalQuestions;
        
        public Competency(String name, String description, String japanName, String japanDescription){
            this.name = name;
            this.description = description;
            this.japanName = japanName;
            this.japanDescription = japanDescription;
            additionalQuestions = new List<String>();
            japanAdditionalQuestions = new List<String>();
        }
    }
    
    public class interviewQuestion{
        @AuraEnabled
        public string interviewType;
        @AuraEnabled
        public string Competency;
        @AuraEnabled
        public string Question;
        @AuraEnabled
        public string CompetencyDescription;
        @AuraEnabled
        public List<string> AdditionalQuestions;
        @AuraEnabled
        public List<string> rating;
            
        public interviewQuestion(string typeval,string comp,string compDesc,List<string> addtnlQ,string question,List<string> rating){
            this.interviewType=typeval;
            this.Competency = comp;
            this.CompetencyDescription = compDesc;
            this.AdditionalQuestions = addtnlQ;
            this.Question = question;
            this.rating = rating;
        }
        
    }
    public class interviewQuestionval{
        @AuraEnabled
        public List<IFB_SIFT_Repository_Controller.interviewQuestion> interviewQuestions;
        @AuraEnabled
        public Map<String,Competency> competencyDescriptionMap;
        public interviewQuestionval(List<IFB_SIFT_Repository_Controller.interviewQuestion> interviewQuestions, Map<String,Competency> competencyDescriptionMap){
            this.interviewQuestions=interviewQuestions;
            this.competencyDescriptionMap = competencyDescriptionMap;
        }
    }
}