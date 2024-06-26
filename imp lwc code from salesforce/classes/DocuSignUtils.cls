public without sharing class DocuSignUtils {
   
   public static final String KOKUA='KOKUA';
   
   public static final String KOKUAPLUS='KOKUA+';
   
   public static final String KSO_ANNUAL='KSO - Annual';
   
   public static final String KSO_QUARTELY='KSO - Quarterly';
   
   public static final String COMISSION_ISV_WITHDRAW='Commission - ISV with draw';
   
   public static final String COMISSION_ISV_WithOUTDRAW='Commission - ISV without draw';
   
   public static final String COMISSION_WithDRAW='Commission - with draw';
   
   public static final String COMISSION_WithOUTDRAW='Commission - without draw';
   
   
   private static Map<String,Offer_Template__c> offerTemplateMap= new Map<String, Offer_Template__c>();// mape of external id of template and offer template object
   private static final List<String> args = new String[]{'0','number','###,###,###'};
   
   /*Method to fill offertemplateMap using the country iso code(country code). Map has a key as countryISOCODE+ExtenalID of offer_Template__c object    
    *@param country: countryCode of the offer business site 
    *return: MAP<String,Offer_Template__c>
   */
   public static Map<String, Offer_Template__c> getOfferTemplateMap(String country) {

        if(offerTemplateMap.size()==0){
            String key = '';
            for(Offer_Template__c template : [SELECT Id,Name,External_ID__c,Template_ID__c,Country_ISO_Code__c  FROM Offer_Template__c 
                                                     WHERE Template_ID__c != null And ( Country_ISO_Code__c= :country or Country_ISO_Code__c='ALL')]){
                key = template.Country_ISO_Code__c + template.External_ID__c;
                key = key.toLowerCase();
                offerTemplateMap.put(key, template);
                
                key = template.Country_ISO_Code__c + template.name;
                key = key.toLowerCase();
                offerTemplateMap.put(key, template);
            
            }
        }
        return offerTemplateMap;
    }
   
   /*Method to get the templateId of an template using the externalId and countryCode. It uses a map with key as countryCode+extenalId
    *to get the templateId.   
    *@param name:String extenalId of template, String countryCode of the offer business site 
    *return: templateId as string
   */ 
   public static String getTemplateID(String externalId, String countryCode) {
        if(externalId != null){
            String key = countryCode+externalId ;
            key = key.toLowerCase();
            Offer_Template__c template = getOfferTemplateMap(countryCode).get(key); 
            if(template != null){
                return template.Template_ID__c;
            }
        }
        return null;
   }
   
   /*Method to format date to DDMMMMYYYY (01Aug2014) format  
    *@param name:date as string 
    *return: formatted date as string
   */ 
	 public static String formatDateToDDMMMMYYYY(String dateString){
    	 
    	 DateTime Dt= DateTime.valueOf(dateString);    	 
    	 return Dt.format('dd MMMM yyyy');
   }
   
   /*Method to format date to DD/MM/YYYY (01/08/2014) format  
    *@param name:date as string 
    *return: formatted date as string
   */ 
   public static String formatDateToDDMMYYYY(String dateString){
    	 
    	 DateTime Dt= DateTime.valueOf(dateString);    	 
    	 return Dt.format('dd/MM/yyyy');  	
   }

   /*Method to format date to MMMMDDYYYY (Aug 01, 2014) format  
    *@param name:date as string 
    *return: formatted date as string
   */ 
     public static String formatDateToMMMMDDYYYY(String dateString){
         
         DateTime Dt= DateTime.valueOf(dateString);      
         return Dt.format('MMMM dd, yyyy');
   }
   

   /*Method to format date to MM/DD/YYYY (08/23/2014) format  
    *@param name:date as string 
    *return: formatted date as string
   */ 
   public static String formatDateToMMDDYYYY(String dateString){
         
         DateTime Dt= DateTime.valueOf(dateString);      
         return Dt.format('MM/dd/yyyy');    
   }
   
   /*Method to format currecy to comma seperated format (10,000) for ten thousand
    *@param name:currency as string 
    *return: formatted currency as string
   */ 
   public static String formatCurrencyCommaSeperated( String amount ){
 
        Decimal integerValue = Decimal.valueOf(amount);
        String formattedAmount =  String.format(integerValue.format(),args);
        return formattedAmount;
        
   }
 
   /*Method to format currecy to dot seperated format (10.000) for ten thousand  
    *@param name:currency as string 
    *return: formatted currency as string
   */   
   public static String formatCurrencyDotSeperated( String amount ){    	
                
        Decimal integerValue = Decimal.valueOf(amount);
        String formattedAmount =  String.format(integerValue.format(),args);
        return formattedAmount.replaceAll(',','.');
        
   }
      
}