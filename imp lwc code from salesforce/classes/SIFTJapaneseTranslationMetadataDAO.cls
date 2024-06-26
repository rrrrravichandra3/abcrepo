public with sharing class SIFTJapaneseTranslationMetadataDAO {
	
	private static Boolean japaneseTranslationsRetrieved = false;
    private static Map<String, String> japanTranslations = new Map<String, String>();

    public static Map<String, String> getAllJapaneseTranslations(){
        if(japaneseTranslationsRetrieved == false){
            List<SIFT_Japan_Translation_Dictionary__mdt> translationRecords = [Select MasterLabel, Translation__c from SIFT_Japan_Translation_Dictionary__mdt];
            for(SIFT_Japan_Translation_Dictionary__mdt currTranslationRecord : translationRecords){
                japanTranslations.put(currTranslationRecord.MasterLabel, currTranslationRecord.Translation__c);
            }
            japaneseTranslationsRetrieved = true;
        }
        return japanTranslations;
    }
}