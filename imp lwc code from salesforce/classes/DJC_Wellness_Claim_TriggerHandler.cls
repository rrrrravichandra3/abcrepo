public without sharing class DJC_Wellness_Claim_TriggerHandler {
    
    private static final ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();

    private static final Set<String> NON_WELLNESS_CLAIM_TYPES = new Set<String>{'Dental', 'Vision', 'TCM'};
    
    public static void validateAllClaimsAgainstQuarterlyOrAnnualLimits(List<DJC_Wellness_Reimbursement_Claim__c> newRecords) {
        //Algo
        //1. Get all the claims for each contact per quarter (or year) per claim policy found in newRecords
        //2. Query for existing claims for each quarter-year and claim type found above
        //3. Add up the amounts. 
        //4. Check against quarterly or annual limits for each claim type
        
        Map<id, String> contactToCurrencyISOCode = new Map<id, String>();
        
        Map<Contact, Map<String, Map<PolicyLimit,List<ClaimWrapper>>>> contactToTotalClaims = new Map<Contact, Map<String, Map<PolicyLimit,List<ClaimWrapper>>>>();
        Set<String> timeRanges = new Set<String>();
        Map<id, Case> newClaimCaseMap = getClaimCasesFromNewRecords(newRecords);
        
        for (DJC_Wellness_Reimbursement_Claim__c claim : newRecords) {
            
            Case claimCase = newClaimCaseMap.get(claim.DJC_Wellness_Case__c);   

            if(claimCase == null){
                continue;
            }
            
            DJC_Wellness_ClaimBuilder claimBuilder = new DJC_Wellness_ClaimBuilder(claim, claimCase.Contact);

            claimBuilder.addCase(claimCase);
            claim = claimBuilder.build();
            timeRanges.add(claimBuilder.timeRange);
            updateMap(contactToTotalClaims, claimCase, claimBuilder.timeRange, new ClaimWrapper(claim, true));
        }
        
        List<DJC_Wellness_Reimbursement_Claim__c> Existingclaims = getExistingClaims(contactToTotalClaims.keySet(), timeRanges, newRecords);
                
        for (DJC_Wellness_Reimbursement_Claim__c claim : Existingclaims) {
            updateMap(contactToTotalClaims, claim.DJC_Wellness_Case__r, 
                      claim.Time_Range__c, new ClaimWrapper(claim, false));
        }
        
        validateClaims(contactToTotalClaims, newClaimCaseMap);
    }

    private static void validateClaims(Map<Contact, Map<String, Map<PolicyLimit, List<ClaimWrapper>>>> wellnessClaims, Map<id, Case> newClaimCaseMap) {
        DJC_TimeRangeManager timeRangeManager;
        Date wellnessClaimStartDate;
        Date hireDate;

        for (Contact contactRecord : wellnessClaims.keySet()) {
            Map<String, Map<PolicyLimit,List<ClaimWrapper>>> qtrlyClaims = wellnessClaims.get(contactRecord);            
            String contactCountry = contactRecord.ES_DJC_Contact_Country__c;
            hireDate = contactRecord.Start_Date__c;
            
            for (String qtr : qtrlyClaims.keySet()) {
                Map<PolicyLimit, List<ClaimWrapper>> claims = qtrlyClaims.get(qtr);
                for (PolicyLimit policy : claims.keySet()) {
                    Decimal claimsTotal = calculateTotal(claims.get(policy), policy.CurrencyIsoCode);
                    List<ClaimWrapper> claimWrappers = claims.get(policy);
                    for(ClaimWrapper cW : claimWrappers){
                        wellnessClaimStartDate = cW.getClaim().DJC_Wellness_Start_Date_of_Activity__c;
                        Decimal policyLimit;
                        
                        if((newClaimCaseMap.get(cW.getClaim().DJC_Wellness_Case__c) != null && newClaimCaseMap.get(cW.getClaim().DJC_Wellness_Case__c).ES_DJC_Topic__c == 'Wellness') || (cW.getClaim().DJC_Wellness_Case__r != null && cW.getClaim().DJC_Wellness_Case__r.ES_DJC_Topic__c == 'Wellness')) {
                            timeRangeManager = new DJC_QuarterTimeRangeManager(DJC_Wellness_Util.getRegion(contactRecord.Division__c));
                            if(wellnessClaimStartDate != null && timeRangeManager.getCurrentTimeRange(wellnessClaimStartDate) == timeRangeManager.getCurrentTimeRange(hireDate)){
                                Decimal balanceForAMonthInQuarter = policy.policyLimit / 3;
                                if (timeRangeManager.getRegion() == DJC_Region.APAC || timeRangeManager.getRegion() == DJC_Region.LACA) {
                                    if(Math.mod(hireDate.month(), 3) == 2){
                                        policyLimit = balanceForAMonthInQuarter * 3;
                                    }
                                    if(Math.mod(hireDate.month(), 3) == 0){
                                        policyLimit = balanceForAMonthInQuarter * 2;
                                    }
                                    if(Math.mod(hireDate.month(), 3) == 1){
                                        policyLimit = balanceForAMonthInQuarter * 1;
                                    }
                                }
                                else{
                                    if(Math.mod(hireDate.month(), 3) == 2){
                                        policyLimit = balanceForAMonthInQuarter * 2;
                                    }
                                    if(Math.mod(hireDate.month(), 3) == 0){
                                        policyLimit = balanceForAMonthInQuarter * 1;
                                    }
                                    if(Math.mod(hireDate.month(), 3) == 1){
                                        policyLimit = balanceForAMonthInQuarter * 3;
                                    }
                                }
                            }
                        }
                        /*
                            @W-6963041 Tech debt to avoid SOQL 101 error.
                        */

                        else if((newClaimCaseMap.get(cW.getClaim().DJC_Wellness_Case__c) != null && NON_WELLNESS_CLAIM_TYPES.contains(newClaimCaseMap.get(cW.getClaim().DJC_Wellness_Case__c).ES_DJC_Topic__c)) || 
                                (cW.getClaim().DJC_Wellness_Case__r != null && NON_WELLNESS_CLAIM_TYPES.contains(cW.getClaim().DJC_Wellness_Case__r.ES_DJC_Topic__c))) {
                            timeRangeManager = new DJC_YearTimeRangeManager(DJC_Wellness_Util.getRegion(contactRecord.Division__c));
                            if(wellnessClaimStartDate != null && timeRangeManager.getCurrentTimeRange(wellnessClaimStartDate) == timeRangeManager.getCurrentTimeRange(hireDate)){
                                Decimal balanceForAMonth = policy.policyLimit / 12;
                                if (timeRangeManager.getRegion() == DJC_Region.APAC && contactCountry.equalsIgnoreCase(System.Label.ES_DJC_Country_India_Label)) {
                                    if(hireDate.month() >= 8 && hireDate.month() <= 12){
                                        policyLimit = balanceForAMonth * (20 - hireDate.month());
                                    }
                                    else {
                                        policyLimit = balanceForAMonth * (8 - hireDate.month());
                                    }
                                }
                            else if (timeRangeManager.getRegion() == DJC_Region.APAC || timeRangeManager.getRegion() == DJC_Region.LACA) {
                                    if(hireDate.month() >= 2 && hireDate.month() <= 12){
                                        policyLimit = balanceForAMonth * (14 - hireDate.month());
                                    }
                                    else {
                                        policyLimit = balanceForAMonth;
                                    }
                                }
                                else{
                                    policyLimit = balanceForAMonth * (13 - hireDate.month());
                                }
                            }
                        }
                        
                        if(policyLimit != null){
                            Decimal policyLimitRounded = policyLimit.setScale(2);
                            if (claimsTotal > policyLimitRounded) {
                                system.debug('Exceeded the total limit defined for ' + qtr + ' of '+
                                             policy.policyLimit + ' for ' + contactCountry);
                                addValidationError(qtrlyClaims, 'Claim amount is over the ' + getReadableTimeRange(policy.categoryGroup) + ' maximum.');
                            }
                        }
                        
                    }

                    if (claimsTotal > policy.policyLimit) {
                        system.debug('Exceeded the total limit defined for ' + qtr + ' of '+
                                     policy.policyLimit + ' for ' + contactCountry);
                        addValidationError(qtrlyClaims, 'Claim amount is over the ' + getReadableTimeRange(policy.categoryGroup) + ' maximum.');
                    }
                }  
            }
        }   
    }

    private static String getReadableTimeRange(String categoryGroup){
        if(categoryGroup != null){
            if(categoryGroup.equalsIgnoreCase('Health') || categoryGroup.equalsIgnoreCase('Education')){
                return 'year';
            }else if(categoryGroup.equalsIgnoreCase('Wellness')){
                return 'quarter';
            }
        }
        return '';
    }
    
    private static Map<id, Case>  getClaimCasesFromNewRecords(List<DJC_Wellness_Reimbursement_Claim__c> newRecords) {
        List<id> caseIds = new List<id>();        
        for (DJC_Wellness_Reimbursement_Claim__c claim : newRecords) {
            caseIds.add(claim.DJC_Wellness_Case__c);
        }        
        Map<id, Case> claimCases = new Map<id, Case>([select ContactId, Contact.Start_Date__c, Contact.ES_DJC_Contact_Country__c, Contact.Division__c, Division_Lookup__c,
                                                      ES_DJC_Sub_Topic__c, ES_DJC_Topic__c,
                                                      Division__c,
                                                      Status,
                                                      Reimbursement_Policy_Id__c,
                                                      Reimbursement_Category_Id__c
                                                      from Case where id IN :caseIds and status NOT IN ('Rejected','Saved')
                                                      AND Reimbursement_Policy_Id__c != null AND Reimbursement_Category_Id__c != null]);
        return claimCases;
        
    }
    
    private static List<DJC_Wellness_Reimbursement_Claim__c> getExistingClaims(Set<Contact> contacts, Set<String> timeRanges, List<DJC_Wellness_Reimbursement_Claim__c> existingRecords ) {
        return [select DJC_Wellness_Amount_Requested__c, DJC_Wellness_Case__r.contactId,                
                Time_Range__c, DJC_Wellness_Case__r.Contact.ES_DJC_Contact_Country__c,
                CurrencyIsoCode,
                DJC_Wellness_Start_Date_of_Activity__c,
                DJC_Wellness_Case__r.Contact.Start_Date__c,
                DJC_Wellness_Case__r.Contact.Division__c,
                DJC_Wellness_Case__r.Reimbursement_Policy_Id__c,
                DJC_Wellness_Case__r.Reimbursement_Category_Id__c,
                DJC_Wellness_Case__r.Division__c,
                DJC_Wellness_Case__r.Division_Lookup__c,
                DJC_Wellness_Case__r.ES_DJC_Sub_Topic__c, DJC_Wellness_Case__r.ES_DJC_Topic__c
                from DJC_Wellness_Reimbursement_Claim__c
                where DJC_Wellness_Case__r.contactId IN :contacts 
                and Id NOT IN :existingRecords
                and Time_Range__c  IN :timeRanges
                and DJC_Wellness_Request_Status__c NOT IN ('Rejected','Saved')
                and DJC_Wellness_Case__r.status NOT IN ('Rejected','Saved')
                and DJC_Wellness_Case__r.Reimbursement_Policy_Id__c != null
                and DJC_Wellness_Case__r.Reimbursement_Category_Id__c != null];
    }

    private static Decimal calculateTotal(List<ClaimWrapper> claims, String defaultcurrencyISOCode) {
        Decimal total = 0;
        for (ClaimWrapper claim: claims) {
            decimal claimAmount;
            if (claim.getClaim().CurrencyIsoCode != defaultCurrencyISOCode) {
                claimAmount = DJC_Wellness_Util.getConvertedCurrency (claim.getClaim(), defaultCurrencyISOCode);
            } else {
                claimAmount = claim.getClaim().DJC_Wellness_Amount_Requested__c;
            }
            total += claimAmount;
        }
        return total;
    }
    
    
    private static void updateMap(Map<Contact, Map<String, Map<PolicyLimit,List<ClaimWrapper>>>> healthOrWellnessClaims, Case claimCase, String quarterYear, ClaimWrapper claim) {
        Map<String, Map<PolicyLimit,List<ClaimWrapper>>> qtrList = healthOrWellnessClaims.get(claimCase.contact);
        if (qtrList == null) {
            qtrList = new Map<String, Map<PolicyLimit,List<ClaimWrapper>>>();
            healthOrWellnessClaims.put(claimCase.contact, qtrList);
        }
        Map<PolicyLimit,List<ClaimWrapper>> claims = qtrList.get(quarterYear);
        if (claims == null) {
            claims = new Map<PolicyLimit,List<ClaimWrapper>>();
            qtrList.put(quarterYear, claims);
        }
        
        Reimbursement_Policy__mdt policy = DJC_Wellness_Util.getWellnessPolicyById(claimCase.Reimbursement_Policy_Id__c.intValue());
        Reimbursement_Category__mdt category = DJC_Wellness_Util.getWellnessCategoryById(claimCase.Reimbursement_Category_Id__c.intValue());
            
        List<ClaimWrapper> contactClaims = claims.get(new PolicyLimit(policy.Id__c.intValue(), category.Group__c, policy.Currency__c));
        if (contactClaims == null) {
            contactClaims = new List<ClaimWrapper>();
            
            DJC_Region region = null;
            
            if(claimCase.Division__c != null){
                region = DJC_Wellness_Util.getRegion(claimCase.Division__c);
            } else{
                region = DJC_Wellness_Util.getRegion(claimCase.Division_Lookup__c);
            }
            
            DJC_WellnessManagerFactory managerFactory = DJC_WellnessManagerFactory.getInstance(region, policy, category, claimCase.contact);
            DJC_ClaimManager claimManager = managerFactory.getClaimManager();
            
            PolicyLimit polLimit = new PolicyLimit(policy.Id__c.intValue(), category.Group__c, policy.Currency__c);
            polLimit.policyLimit = claimManager.getLimitForPeriodAndPolicy(quarterYear).Limit__c;
            
            claims.put(polLimit, contactClaims);
        }
        contactClaims.add(claim);
    }
  
    private static void addValidationError(Map<String, Map<PolicyLimit,List<ClaimWrapper>>> claims, String msg) {
        for (String key : claims.keySet()) {
            Map<PolicyLimit,List<ClaimWrapper>> policyToClaims = claims.get(key);
            
            for (List<ClaimWrapper> claimsList  : policyToClaims.values()){
                for (ClaimWrapper ctcClaim : claimsList) {                
                    if (ctcClaim.isNew()) {
                        ctcClaim.getClaim().DJC_Wellness_Amount_Requested__c.addError(msg);   
                    }
                }
            }            
        }        
    }

    private Class ClaimWrapper {
        private final DJC_Wellness_Reimbursement_Claim__c claim;
        private final boolean newRecord;
        
        public ClaimWrapper(DJC_Wellness_Reimbursement_Claim__c claim, boolean newRecord) {
            this.claim = claim;
            this.newRecord = newRecord;
        }
        
        public boolean isNew() {
            return newRecord;
        }
        
        public DJC_Wellness_Reimbursement_Claim__c getClaim() {
            return claim;
        }
    }
    
    private Class PolicyLimit {
        private final Integer policyId;
        private Decimal policyLimit;
        private final String categoryGroup;
        private final String currencyIsoCode;
        
        public PolicyLimit (Integer policyId, String categoryGroup, String currencyIsoCode) {
            this.policyId = policyId;
            this.categoryGroup = categoryGroup;
            this.currencyIsoCode = currencyIsoCode;
        }
        
        public Integer hashCode() {
            return policyId;
        }
        public Boolean equals(Object obj) {
            if (obj instanceof PolicyLimit) {
                PolicyLimit policy = (PolicyLimit)obj;
                return (policy.policyId == this.policyId);
            }
            return false;
        }
    }
}