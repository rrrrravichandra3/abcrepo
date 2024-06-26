public with sharing class IFB_IntvQuestionTranslationController {
	public IFB_Interview_Evaluation__c eval {get;set;}
	public String intvLanguage;

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
	
	public String gettranslatedQuestion(){
		//if interview question is blank, return blank
		if(String.isBlank(eval.Interview_Question__r.Question__c)){
			return eval.Interview_Question__r.Question__c;
		}
		if(intvLanguage == 'Japan'){
			//return the value in the field Japan_Question__c
			//but, as a fall back, if for some reason translation wasn't uploaded, return the english version (which is in field Question__c)
			String japanQuestion = eval.Interview_Question__r.Japan_Question__c;
			if((!String.isBlank(eval.Interview_Question__r.Question__c)) && (String.isBlank(japanQuestion))){
				japanQuestion = eval.Interview_Question__r.Question__c;
			}
			return eval.Interview_Question__r.Japan_Question__c;
		}else{
			//default value is english question
			return eval.Interview_Question__r.Question__c;
		}
	}
}