public with sharing class IFB_CaptureFeedbackLightningController {
    
    private static final String accessErrorMessage = 'Insufficient access to perform this action';
    private static final String interviewNotFoundErrorMessage = 'Interview not found';
    
    @AuraEnabled
    public static InitialResources getInitialResources(Id interviewId) {
        
        //Checking the user has access to the objects and fields
        if(!IFB_InterviewUtils.isInterviewAccessible()
          || !IFB_InterviewUtils.isInterviewUpdateable()
          || !IFB_InterviewUtils.isEvaluationUpdateable()
          || !IFB_InterviewUtils.isQuestionAccessible()){

            throw new AuraHandledException(accessErrorMessage);
        }
        
        List<IFB_Interview__c> interviews = [SELECT Id, Name,
                                                Candidate__r.Group__c,
                                                Candidate__r.SIFT_Group__r.Name,
                                                Candidate__r.Position__c,
                                                Candidate__r.SIFT_Position__r.Name,
                                                Candidate__r.Name, 
                                                Candidate__r.Email__c,
                                                Candidate__r.City__c, 
                                                Candidate__r.State__c,
                                                Interviewer__r.Name,
                                                Interviewer2__r.Name,
                                                Interviewer3__r.Name,
                                                Interviewer4__r.Name,
                                                Interviewer5__r.Name, 
                                                Interview_Format__c,
                                                Interview_Language__c,
                                                Interview_Type__r.Name,
                                                No_Show__c, 
                                                Scheduled_Interview_Date__c,
                                                Actual_Interview_Date__c,
                                                Recommendation__c,
                                                Comments__c,
                                                Status__c,
                                                Locked__c,
                                                Is_Japan_CSG__c,
                                                RecordTypeId,
                                                RecordType.DeveloperName
                                              FROM IFB_Interview__c 
                                              where Id = :interviewId];
         if (!interviews.isEmpty()) {
             if(!isInterviewEditable(interviews[0])){
                 throw new AuraHandledException(accessErrorMessage);
             }
             
             List<IFB_Interview_Evaluation__c> evaluations = getEvaluations(interviews[0].Id);
             List<String> competenciesNames = new List<String>();
             
             for(IFB_Interview_Evaluation__c evaluation:evaluations){
                 competenciesNames.add(evaluation.Interview_Question__r.Competency__c);
             }

             Boolean autoSaveDisabled = true;
             Integer autoSaveIntervalTimer = 300000;
             try{
                 autoSaveDisabled = IFB_SIFT_Settings_List__c.getInstance('SIFT').Disable_AutoSave_Feedback__c;
                 autoSaveIntervalTimer = Integer.valueOf(IFB_SIFT_Settings_List__c.getInstance('SIFT').AutoSave_Interval__c);
                 //min value for timer needs to be 30 sec
                 //incase values are entered wrong, it will default to 5 min
                 if((autoSaveIntervalTimer == null) || (autoSaveIntervalTimer<30000)){
                    autoSaveIntervalTimer = 300000;
                 }
             }catch(Exception e){
                autoSaveIntervalTimer = 300000;
             }
             
             return new InitialResources(interviews[0], evaluations, getRecommendationOptions(),
                                  getCompetencyDescriptions(competenciesNames, interviews[0].Candidate__r.SIFT_Group__r.Name, interviews[0].Interview_Type__r.Name, interviews[0].Candidate__r.SIFT_Position__r.Name), 
                                  getRatingOptions(),autoSaveDisabled,autoSaveIntervalTimer);

         }

         throw new AuraHandledException(interviewNotFoundErrorMessage);
    }

    private static List<IFB_Interview_Evaluation__c> getEvaluations(Id interviewId) {

         List<IFB_Interview_Evaluation__c> evaluations = [SELECT Id, Name,
                                                            Interview_Question__r.Competency__c,
                                                            Interview_Question__r.Japan_Domain__c,
                                                            Interview_Question__r.Question__c,
                                                            Interview_Question__r.Japan_Question__c,
                                                            Score__c,
                                                            Rating__c,
                                                            Interview_Question__r.Rating1_Definition__c,
                                                            Interview_Question__r.Rating2_Definition__c,
                                                            Interview_Question__r.Rating3_Definition__c,
                                                            Interview_Question__r.Rating4_Definition__c,
                                                            Interview_Question__r.Japan_Rating1_Definition__c,
                                                            Interview_Question__r.Japan_Rating2_Definition__c,
                                                            Interview_Question__r.Japan_Rating3_Definition__c,
                                                            Interview_Question__r.Japan_Rating4_Definition__c,
                                                            Comments__c,
                                                            Skipped__c 
                                                        FROM IFB_Interview_Evaluation__c
                                                        where Interview__c = :interviewId
                                                        ORDER BY Interview_Question__r.Sort_Order__c];
        
         return evaluations;
    }

    @AuraEnabled
    public static IFB_Interview__c saveInterview(IFB_Interview__c interview, List<IFB_Interview_Evaluation__c> evaluations, String message) {
        
        if(!IFB_InterviewUtils.isInterviewAccessible()
           || !IFB_InterviewUtils.isInterviewUpdateable()
           || !IFB_InterviewUtils.isEvaluationUpdateable()
           || !IFB_InterviewUtils.isQuestionAccessible()){
               
               throw new AuraHandledException(accessErrorMessage);
        }
        
        IFB_Interview__c currentInterview = null;

        if(IFB_AccessibilityUtils.checkFLS('IFB_Interview__c',
                IFB_AccessibilityUtils.PermissionType.ACCESSIBLE,
                new List<String> {'Actual_Interview_Date__c'})){
             currentInterview = [SELECT Id, Status__c, Locked__c, Interviewer__c,
                    Interviewer2__c, Interviewer3__c, Interviewer4__c, Interviewer5__c, Actual_Interview_Date__c FROM IFB_Interview__c WHERE Id = :interview.Id];
        }

        if((!IFB_AccessibilityUtils.checkFLS('IFB_Interview__c',
                IFB_AccessibilityUtils.PermissionType.ACCESSIBLE,
                new List<String> {'Actual_Interview_Date__c'})) || (!isInterviewEditable(currentInterview))){
            throw new AuraHandledException(accessErrorMessage);
        }

        //IFB_Interview__c.Status__c -> Is Editable in Permission Set?: NO
        if (message == 'SUBMIT') {
            interview.Status__c = 'Feedback submitted';
        }else{
            interview.Status__c = 'Feedback in progress';
        }

        Decimal overallScore = 0.0;
        Integer overallCount = 0;
                                                     
        for(IFB_Interview_Evaluation__c evaluation:evaluations){
            if((!evaluation.Skipped__c) && evaluation.Score__c != null && evaluation.Score__c > 0){
                overallScore += evaluation.Score__c;
                overallCount++;
            }
        }

        if(overallCount > 0){
            if(IFB_AccessibilityUtils.checkFLS('IFB_Interview__c',
                    IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                    new List<String> {'Overall_Interview_Score__c'})){
                    interview.Overall_Interview_Score__c = overallScore / overallCount;
            }else{
                throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview_Candidate);
            }
        }
        
        if(currentInterview.Actual_Interview_Date__c == null) {
            //Moved the setting of Actual Interview date from client side to server side
            if(IFB_AccessibilityUtils.checkFLS('IFB_Interview__c',
                    IFB_AccessibilityUtils.PermissionType.UPDATEABLE,
                    new List<String> {'Actual_Interview_Date__c'})){
                interview.Actual_Interview_Date__c = DateTime.now();
            }else{
                throw new PF_SecurityCheckException(Label.SIFT_Exception_Update_IFB_Interview_Candidate);
            }
        }

        try{
            update interview;
            update evaluations;
        }catch(DMLException ex){
            if(ex.getDmlStatusCode(0).equalsIgnoreCase('CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY')){
                throw new AuraHandledException('RESUBMIT');
            }
            throw new AuraHandledException(ex.getDmlMessage(0));
        }
        
        return interview;
    }
    
    private static Map<String,Competency> getCompetencyDescriptions(List<String> competencyNames, String groupValue, String interviewTypeValue, String positionValue) {
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

    private static List<SelectOption> getRecommendationOptions(){
        
        if(!IFB_AccessibilityUtils.checkFLS('IFB_Interview__c', IFB_AccessibilityUtils.PermissionType.ACCESSIBLE, new List<String>{'Recommendation__c'}) ){
            throw new AuraHandledException(accessErrorMessage);
        }

        Map<String, String> japaneseTranslationDictionary = SIFTJapaneseTranslationMetadataDAO.getAllJapaneseTranslations();
        
        List<Schema.PicklistEntry> entries = IFB_Interview__c.Recommendation__c.getDescribe().getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.PicklistEntry entry : entries){
            String englishLabel = entry.getLabel();
            if(japaneseTranslationDictionary.containsKey(englishLabel)){
                options.add(new SelectOption(englishLabel,japaneseTranslationDictionary.get(englishLabel),entry.getValue()));
            }else{
                options.add(new SelectOption(englishLabel, englishLabel, entry.getValue()));
            }
        }
        
        return options;
    }
    
    private static List<SelectOption> getRatingOptions(){
        
        IFB_Recruiting_Scoring__c recruitingScores = IFB_Recruiting_Scoring__c.getOrgDefaults();
        
        List<SelectOption> ratings = new List<SelectOption>();
        
        ratings.add(new SelectOption('', '', ''));
        ratings.add(new SelectOption(recruitingScores.Rating4_Score_Label__c, recruitingScores.Rating4_Score_Japan_Label__c, recruitingScores.Rating4_Score_Value__c.format()));
        ratings.add(new SelectOption(recruitingScores.Rating3_Score_Label__c, recruitingScores.Rating3_Score_Japan_Label__c, recruitingScores.Rating3_Score_Value__c.format()));
        ratings.add(new SelectOption(recruitingScores.Rating2_Score_Label__c, recruitingScores.Rating2_Score_Japan_Label__c, recruitingScores.Rating2_Score_Value__c.format()));
        ratings.add(new SelectOption(recruitingScores.Rating1_Score_Label__c, recruitingScores.Rating1_Score_Japan_Label__c, recruitingScores.Rating1_Score_Value__c.format()));
        
        return ratings;
    }
    
    private static boolean isInterviewEditable(IFB_Interview__c interview){
        
        Boolean userIsInterviewer;
        
        if (interview.Interviewer__c  == UserInfo.getUserId() ||
            interview.Interviewer2__c == UserInfo.getUserId() ||
            interview.Interviewer3__c == UserInfo.getUserId() ||
            interview.Interviewer4__c == UserInfo.getUserId() ||
            interview.Interviewer5__c == UserInfo.getUserId()) {
                userIsInterviewer = true;
            } else {
                userIsInterviewer = false;
            }
        
        return ((userIsInterviewer || SIFT_Settings__c.getInstance().Capture_Feedback_Override__c) && (interview.Status__c == 'New' || interview.Status__c == 'Feedback in progress')
           && !interview.Locked__c);
    }
    
    public class SelectOption{
        
        @AuraEnabled
        public String label;
        
        @AuraEnabled
        public String japanLabel;
        
        @AuraEnabled
        public String value;
        
        public SelectOption(String label, String value){
            this(label,'',value);
        }
        
        public SelectOption(String label, String japanLabel, String value){
            this.label = label;
            this.japanLabel = japanLabel;
            this.value = value;
        }
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
    
    //Wraps all the information needed by the Lightning page to load
    public class InitialResources{
        
        @AuraEnabled
        public IFB_Interview__c interview;
        
        @AuraEnabled
        public List<IFB_Interview_Evaluation__c> evaluations;
        
        @AuraEnabled
        public List<SelectOption> recommendationOptions;
        
        @AuraEnabled
        public Map<String,Competency> competencies;
        
        @AuraEnabled
        public List<SelectOption> ratingOptions;

        @AuraEnabled
        public Boolean autoSaveDisabled;

        @AuraEnabled
        public Integer autoSaveIntervalTimer;
        
        public InitialResources(IFB_Interview__c interview,
                         List<IFB_Interview_Evaluation__c> evaluations,
                         List<SelectOption> recommendationOptions,
                         Map<String,Competency> competencies,
                         List<SelectOption> ratingOptions,
                         Boolean autoSaveDisabled,
                         Integer autoSaveIntervalTimer){
                             
            this.interview = interview;
            this.evaluations = evaluations;
            this.recommendationOptions = recommendationOptions;
            this.competencies = competencies;
            this.ratingOptions = ratingOptions;
            this.autoSaveDisabled = autoSaveDisabled;
            this.autoSaveIntervalTimer = autoSaveIntervalTimer;
        }
        
    }
}