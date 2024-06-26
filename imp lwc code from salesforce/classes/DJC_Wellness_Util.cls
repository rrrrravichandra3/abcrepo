public without sharing class DJC_Wellness_Util {

    private static List<CurrencyType> currType = [SELECT ConversionRate,DecimalPlaces,IsActive,IsCorporate,IsoCode FROM CurrencyType where IsActive = true];
    
    public static Case getWellnessCaseById(String caseId){

        return [select  status,
                        Type,
                        Tier__c,
                        isClosed,
                        ES_DJC_Topic__c,
                        ES_DJC_Sub_Topic__c,
                        currencyISOCode,
                        subject,
                        contactId,
                        Reimbursement_Category_Id__c,
                        Reimbursement_Policy_Id__c,
                        Division__c,
                       (select DJC_Wellness_Amount_Requested__c,
                                DJC_Wellness_Request_Comments__c,
                                DJC_Wellness_End_Date_of_Activity__c,
                                DJC_Wellness_Start_Date_of_Activity__c,
                                DJC_Wellness_Request_Status__c,
                                DJC_Wellness_Activity__c,
                                DJC_Wellness_Provider__r.name,
                                DJC_Education_Policy__c,
                                DJC_Education_Date_Completed__c,
                                DJC_Reimbursement_Claim_Detail__c,
                                DJC_Education_Institution__r.name,
                                CurrencyISOCode,
                                local_id__c,
                                DJC_Education_Course_Description__c,
                                DJC_Education_Course_Justification__c,
                        		DJC_Education_Course_Duration__c,
                        		DJC_Education_Taxable__c
                        		from Wellness_Reimbursement_Claims__r order by name)
                from case where id = :caseId];
    }
    
    public static Reimbursement_Category__mdt getWellnessCategoryById(Integer categoryId){
        for(Reimbursement_Category__mdt category:[SELECT Id__c, MasterLabel, Group__c FROM Reimbursement_Category__mdt WHERE Id__c = :categoryId]){
            return category;
        }
        return null;
    }
    
    public static Reimbursement_Policy__mdt getWellnessPolicyById(Integer policyId){
        for(Reimbursement_Policy__mdt policy:[SELECT Id__c, Active__c, Country__c, Currency__c, Organization__c FROM Reimbursement_Policy__mdt WHERE Id__c = :policyId]){
            return policy;
        }
        return null;
    }

    /**
     * Converts requested claim amount
     **/
    public static Decimal getConvertedCurrency (DJC_Wellness_Reimbursement_Claim__c claim, String defaultCurrencyISOCode) {
        if (claim == null) {
            throw new ApplicationException('Null claim found');
        }
        if (String.isEmpty(defaultCurrencyISOCode)) {
            throw new ApplicationException('defaultCurrencyISOCode not found');            
        }
        Decimal conversionRateToUSDForClaim = null;
        Decimal conversionRateToUSDForDefaultCurrency = null;
        Integer scale = 2;
        for (CurrencyType ctype : currType) {
            if (ctype.IsoCode.equals(claim.CurrencyISOCode)) {
                conversionRateToUSDForClaim = ctype.ConversionRate;
            }
            if (ctype.IsoCode.equals(defaultCurrencyISOCode)){
                conversionRateToUSDForDefaultCurrency = ctype.ConversionRate;
                scale = ctype.DecimalPlaces;
            }
        }
        
        if ((conversionRateToUSDForClaim == null) || (conversionRateToUSDForDefaultCurrency == null)) {
            system.debug('fatal error: conversionRateToUSDForClaim or conversionRateToUSDForDefaultCurrency not found');
            claim.addError('unable to validate the claim');
        }
        Decimal convertedAmt = claim.DJC_Wellness_Amount_Requested__c * conversionRateToUSDForDefaultCurrency / conversionRateToUSDForClaim;        

        if(defaultCurrencyISOCode == 'JPY' || defaultCurrencyISOCode == 'KRW'){
                convertedAmt = math.ceil(convertedAmt);
                return convertedAmt;
        }
        return convertedAmt.setScale(scale, System.roundingMode.HALF_EVEN);                
    }
    
    public static Map<Id,List<Attachment>> getExistingAttachments(List<DJC_Wellness_Reimbursement_Claim__c> claims) {
        
        Map<Id, List<Attachment>> claimAttachment = new Map<Id, List<Attachment>>();
        List<Attachment> existingAttachments = [select id, name, parentId, description from Attachment where parentId IN :claims AND (NOT Name LIKE '#deleted_%')];
        
        for (Attachment attachmentRec : existingAttachments) {
            List<Attachment> attachments = claimAttachment.get(attachmentRec.ParentId);
            if (attachments == null) {
                attachments = new List<Attachment>();
                claimAttachment.put(attachmentRec.ParentId, attachments);
            }
            attachments.add(attachmentRec);
        }
        return claimAttachment;
    }
    
    public static DJC_Region getRegion(String division) {
        
        DJC_Region region = DJC_Region.AMER;

        if (division.containsIgnoreCase('APAC')) {
            region = DJC_Region.APAC;
        } else if (division.containsIgnoreCase('EMEA')) {
            region = DJC_Region.EMEA;
        } else if (division.containsIgnoreCase('Japan')) {
            region = DJC_Region.Japan;
        } else if (division.containsIgnoreCase('Latin America')){
            region = DJC_Region.LACA;
        }
        return region;
    }
}