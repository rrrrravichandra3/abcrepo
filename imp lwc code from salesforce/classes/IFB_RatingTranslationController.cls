public with sharing class IFB_RatingTranslationController {
	public String intvRating {get; set;}
    public String intvLanguage;
    private Map<String, String> japaneseTranslation { get; set; }


    public IFB_RatingTranslationController(){
        japaneseTranslation = new Map<String, String>();
        //set up japanese translation Map
        IFB_Recruiting_Scoring__c recruitingScores = IFB_Recruiting_Scoring__c.getOrgDefaults();
        japaneseTranslation.put(recruitingScores.Rating1_Score_Label__c, recruitingScores.Rating1_Score_Japan_Label__c);
        japaneseTranslation.put(recruitingScores.Rating2_Score_Label__c, recruitingScores.Rating2_Score_Japan_Label__c);
        japaneseTranslation.put(recruitingScores.Rating3_Score_Label__c, recruitingScores.Rating3_Score_Japan_Label__c);
        japaneseTranslation.put(recruitingScores.Rating4_Score_Label__c, recruitingScores.Rating4_Score_Japan_Label__c);
        japaneseTranslation.put(System.Label.SIFT_Capture_Feedback_Recommendation_Not_Assessed, System.Label.SIFT_Capture_Feedback_Recommendation_Not_Assessed_Japanese);
    }

    public void setintvLanguage(String lang){
        if(String.isBlank(lang)){
            intvLanguage = 'English';
        }else{
            intvLanguage = lang;
        }
        
    }

    public String getintvLanguage(){
        return intvLanguage;
    }

    public String getTranslatedRating(){
        //if rating is null, don't bother with translation
        if(String.isBlank(intvRating)){
            return intvRating;
        }
        //return English Value;
        if(intvLanguage == 'English'){
            return intvRating;
        }
        //return Japanese translation
        else if(intvLanguage == 'Japan'){
            String japanRating = japaneseTranslation.get(intvRating);
            if(String.isBlank(japanRating)){
                japanRating = intvRating;
            }
            return japanRating;
        }
        //fail safe, return original english version
        else{
            return intvRating;
        }
        
    }
}