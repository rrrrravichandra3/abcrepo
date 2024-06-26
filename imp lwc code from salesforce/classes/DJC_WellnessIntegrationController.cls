@RestResource(urlMapping='/GetReimbursementClaims/*')
global without sharing class DJC_WellnessIntegrationController {
    //public for unit tests only
    public static final String ENDPOINT_ERROR = 'ERROR - Invalid Request. Please make sure the endpoint is either /GetReimbursementClaims/APAC/yyyy-MM-dd%20hh:mm:ss or /GetReimbursementClaims/EMEA/yyyy-MM-dd%20hh:mm:ss or  /GetReimbursementClaims/Japan/yyyy-MM-dd%20hh:mm:ss or /GetReimbursementClaims/Americas-LatinAmerica/yyyy-MM-dd%20hh:mm:ss';
    public static Map<String,Integer> DecimalPlacesToCurrencyCode = new Map<String,Integer>();
    public static Map<String,Decimal> conversionRateToCurrencyCode = new Map<String,Decimal>();
    @HttpGet
    global static ResponseHandler getAllReimbursementClaims() {
        ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance(); 
        Integer Batchsize = (Integer)((settings.DJC_Integration_Batch_Size__c == null) ? 200 :settings.DJC_Integration_Batch_Size__c);
        //W-3440121	Exclude foundation employees from Integration.
        list<string> DeptsToExclude = (list<string> )((settings.DJC_WD_Depts_To_Exclude__c == null) ? null : (settings.DJC_WD_Depts_To_Exclude__c.split(',')));   
        
        String region;
        DateTime lastRunDate = DateTime.newInstance(0);
        String[] uriKeys = RestContext.request.requestURI.split('/');
        system.debug('uriKeys ' + uriKeys);
        if (uriKeys == null) {
            return new ResponseHandler(null, system.now(), 'ERROR - Unable to locate REST Resource');
        }
        if (uriKeys.size() < 3 ) {
            return new ResponseHandler(null, system.now(), ENDPOINT_ERROR);
        }
        region = getRegion(uriKeys[2]);
        if (region == null) {
            return new ResponseHandler(null, system.now(), ENDPOINT_ERROR);        
        }    
        
        if (uriKeys.size() > 3) {
            String strDateTime = EncodingUtil.urlDecode(uriKeys[3], 'UTF-8');
            system.debug('dateTime '+strDateTime);
            lastRunDate = DateTime.valueOf(strDateTime);                        
        }
        //W-3445910 Adding End of month cutoff
        //Get DD from settings and Create  cutoff datetime in GMT for current run.    
        //Default is 1st of month viz DD= 1.
        Integer cutoffDD =(Integer) ((settings.DJC_WD_Cutoff_Date_DD__c != null && settings.DJC_WD_Cutoff_Date_DD__c > 0 ) ? settings.DJC_WD_Cutoff_Date_DD__c : 1);           
        DateTime cutOffGMT = DateTime.newInstanceGMT(system.now().yearGMT(), system.now().monthGMT(),cutoffDD, 0, 0, 0); 
        
        //Offset the above GMT time to adjust for actual user timezone which varies by division.
        DJC_Division Division = DJC_Division.getDivisionByName(region);
        Integer tzoffset  = Division.getDivTzOffsetForGMTDatetime(cutOffGMT) ;//Get tz offset from GMT for current division
        DateTime cutOffGMTForDivision = cutOffGMT.addhours(tzoffset*-1);
        
        system.debug(LOGGINGLEVEL.INFO,'cutoffDD :'+cutoffDD);
        system.debug(LOGGINGLEVEL.INFO,'cutOffGMT :'+cutOffGMT); 
        system.debug(LOGGINGLEVEL.INFO,'cutOffGMTForDivision :'+cutOffGMTForDivision);
        
        Set<Id> reimbursementCaseIds = new Set<Id>();
        List<Claim> claims = getAllClaims(region, lastRunDate,cutOffGMTForDivision,reimbursementCaseIds,DeptsToExclude);
        
        //W-3393679 moving the case status update to batch class to avoid 101 limit exception       
        DJC_Integration_UpdateCaseBatch updateCasebatchobj = new DJC_Integration_UpdateCaseBatch(reimbursementCaseIds,'Extracted For Payment','Wellness');
        Database.executebatch(updateCasebatchobj,Batchsize);
        //updateCaseStatus(reimbursementCaseIds);
        ResponseHandler response = new ResponseHandler(claims, system.now(), 'Success');
        return response;
    }
    
    private static void updateCaseStatus(Set<Id> reimbursementCaseIds) {
        List<Case> reimbursementCases = new List<Case>();
        for (Id caseId : reimbursementCaseIds) {
            Case c = new Case(id = caseId);
            c.Status = 'Extracted for Payment';
            reimbursementCases.add(c);
        }
        update reimbursementCases;
    }
    
    private static String getRegion(String division) {
        if (division == 'APAC') {
            return 'APAC - All Countries';
        } else if (division == 'EMEA') {
            return 'EMEA - All Countries';
        }
        else if (division == 'Japan') {
            return 'Japan';
        }
        else if (division == 'Americas-LatinAmerica') {
            return 'Americas - Latin America';
        }
        return null;
    }
    
    private static List<Claim> getAllClaims(String region, DateTime lastRunDate,DateTime cutOffGMTForDivision,Set<Id> reimbursementCaseIds,list<string> DeptsToExclude) {        
        List<Claim> aList = new List<Claim>();        
        //List<Reimbursement_Category_Policy_Assoc__mdt> policyCategoryAssn = queryPolicyCategoryAssn(); 
        Map<String,String> mPolicyCatToWDCode = getWorkdayCode();
        populateCurrencyTypeMaps();
        List<DJC_Wellness_Reimbursement_Claim__c> wellnessClaims = new list<DJC_Wellness_Reimbursement_Claim__c>();
        
        if(DeptsToExclude != null) {
            wellnessClaims = queryWellnessClaims(region, lastRunDate,cutOffGMTForDivision,DeptsToExclude);          	
        }
        else{
            wellnessClaims = queryWellnessClaims(region, lastRunDate,cutOffGMTForDivision);//If null,then no need to have dept exclude condition.          	       	
        } 
        
        for (DJC_Wellness_Reimbursement_Claim__c claim : wellnessClaims) {
            String workdayCode = mPolicyCatToWDCode.get(claim.DJC_Wellness_Case__r.Reimbursement_Category_Id__c.intValue() + '#' +claim.DJC_Wellness_Case__r.Reimbursement_Policy_Id__c.intValue() + '#' +claim.DJC_Education_Taxable__c);
            /*String workdayCode = getWorkdayCode(policyCategoryAssn, claim.DJC_Wellness_Case__r.Reimbursement_Policy_Id__c.intValue(), 
claim.DJC_Wellness_Case__r.Reimbursement_Category_Id__c.intValue(),claim.DJC_Education_Taxable__c);*/
            reimbursementCaseIds.add(claim.DJC_Wellness_Case__r.id);
            aList.add(new Claim(claim.DJC_Wellness_Case__r.contact.EmployeeNumber__c, claim.DJC_Wellness_Activity__c, claim.DJC_Wellness_Amount_Requested__c, getConvertedCurrency(claim, claim.DJC_Wellness_Case__r.CurrencyIsoCode,conversionRateToCurrencyCode,DecimalPlacesToCurrencyCode), claim.CurrencyISOCode, claim.DJC_Wellness_Case__r.CurrencyIsoCode, workdayCode, 
                                claim.DJC_Wellness_Start_Date_of_Activity__c, claim.DJC_Wellness_End_Date_of_Activity__c, claim.DJC_Wellness_Request_Comments__c, claim.id, claim.DJC_Wellness_Case__r.id, claim.DJC_Wellness_Case__r.CaseNumber));
        }
        return aList;                        
    }
    
    private static List<Reimbursement_Category_Policy_Assoc__mdt> queryPolicyCategoryAssn() {
        return [select Workday_PCI__c, Category_Id__c, Policy_Id__c,IsTaxable__c
                from Reimbursement_Category_Policy_Assoc__mdt];
    }
    
    //TODO: Move it to Dynamic SOQL - To avoid Existing criteria change should be made in two places and support adding new criteria .
    private static List<DJC_Wellness_Reimbursement_Claim__c> queryWellnessClaims(String region, DateTime lastRunDate,Datetime cutOffGMTForDivision) {
        
        return [select id, DJC_Wellness_Case__r.id, DJC_Wellness_Case__r.CaseNumber,
                DJC_Wellness_Amount_Requested__c, DJC_Wellness_Case__r.Reimbursement_Policy_Id__c, DJC_Wellness_Case__r.Reimbursement_Category_Id__c,
                DJC_Wellness_Start_Date_of_Activity__c, DJC_Wellness_Activity__c,
                DJC_Wellness_Provider__r.Name, DJC_Wellness_Request_Status__c, DJC_Wellness_End_Date_of_Activity__c,
                DJC_Wellness_Request_Comments__c, CurrencyISOCode, DJC_Wellness_Case__r.contact.EmployeeNumber__c,DJC_Education_Taxable__c,
                DJC_Wellness_Case__r.CurrencyIsoCode
                from DJC_Wellness_Reimbursement_Claim__c 
                where DJC_Wellness_Request_Status__c = 'Approved'
                and DJC_Wellness_Case__r.createddate >= :lastRunDate and DJC_Wellness_Case__r.createddate <= :cutOffGMTForDivision
                and DJC_Wellness_Case__r.status in ('Approved', 'Approved for Partial Payment')
                and DJC_Wellness_Case__r.Division__c = :region and DJC_Wellness_Case__r.Type = 'Wellness Reimbursement Request'];
    }
    private static List<DJC_Wellness_Reimbursement_Claim__c> queryWellnessClaims(String region, DateTime lastRunDate,Datetime cutOffGMTForDivision,list<string> deptsToExclude) {
        
        return [select id, DJC_Wellness_Case__r.id, DJC_Wellness_Case__r.CaseNumber,
                DJC_Wellness_Amount_Requested__c, DJC_Wellness_Case__r.Reimbursement_Policy_Id__c, DJC_Wellness_Case__r.Reimbursement_Category_Id__c,
                DJC_Wellness_Start_Date_of_Activity__c, DJC_Wellness_Activity__c,
                DJC_Wellness_Provider__r.Name, DJC_Wellness_Request_Status__c, DJC_Wellness_End_Date_of_Activity__c,
                DJC_Wellness_Request_Comments__c, CurrencyISOCode, DJC_Wellness_Case__r.contact.EmployeeNumber__c,DJC_Education_Taxable__c,
                DJC_Wellness_Case__r.CurrencyIsoCode
                from DJC_Wellness_Reimbursement_Claim__c 
                where DJC_Wellness_Request_Status__c = 'Approved'
                and DJC_Wellness_Case__r.createddate >= :lastRunDate and DJC_Wellness_Case__r.createddate <= :cutOffGMTForDivision
                and DJC_Wellness_Case__r.status in ('Approved', 'Approved for Partial Payment')
                and DJC_Wellness_Case__r.Division__c = :region and DJC_Wellness_Case__r.Type = 'Wellness Reimbursement Request'
                and DJC_Wellness_Case__r.contact.department NOT in :deptsToExclude];
        
    }    
    private static Map<String,String> getWorkdayCode() {
        Map<String,String> mPolicyCatToWDCode = new Map<String,String>();
        for (Reimbursement_Category_Policy_Assoc__mdt assn : [SELECT Workday_PCI__c, Category_Id__c, Policy_Id__c,IsTaxable__c
                                                              FROM Reimbursement_Category_Policy_Assoc__mdt]) {
                                                                  
                                                                  mPolicyCatToWDCode.put(assn.Category_Id__c.intValue() + '#' +assn.Policy_Id__c.intValue() + '#' +assn.IsTaxable__c,assn.Workday_PCI__c);
                                                                  
                                                              }
        return mPolicyCatToWDCode;
    } 
    private static void populateCurrencyTypeMaps(){
        
        for (CurrencyType currType : [SELECT ConversionRate,DecimalPlaces,IsActive,IsCorporate,IsoCode
                                      FROM  CurrencyType where IsActive = true]) {
                                          conversionRateToCurrencyCode.put(currType.IsoCode,currType.ConversionRate);
                                          DecimalPlacesToCurrencyCode.put(currType.IsoCode,currType.DecimalPlaces);
                                      }
        
    }
    public static Decimal getConvertedCurrency (DJC_Wellness_Reimbursement_Claim__c claim, String defaultCurrencyISOCode,Map<String,Decimal> conversionRateToCurrencyCode,Map<String,Integer> DecimalPlacesToCurrencyCod ) {
        if (claim == null) {
            throw new ApplicationException('Null claim found'); // Here the Currency Code for the Claim and Case Currency are same 
            //Currency Code for the Claim -- USD   and Case Currency -- GBP
        }
        if (String.isEmpty(defaultCurrencyISOCode)) {
            throw new ApplicationException('defaultCurrencyISOCode not found');            
        }
        Decimal conversionRateToUSDForClaim = null;
        Decimal conversionRateToUSDForDefaultCurrency = null;
        Integer scale = 2;
        
        if(conversionRateToCurrencyCode.containsKey(claim.CurrencyISOCode)){
            conversionRateToUSDForClaim = conversionRateToCurrencyCode.get(claim.CurrencyISOCode);
        }
        if (conversionRateToCurrencyCode.containsKey(defaultCurrencyISOCode)){
            conversionRateToUSDForDefaultCurrency = conversionRateToCurrencyCode.get(defaultCurrencyISOCode);
            scale = DecimalPlacesToCurrencyCode.get(defaultCurrencyISOCode);
        }      
        if ((conversionRateToUSDForClaim == null) || (conversionRateToUSDForDefaultCurrency == null)) {
            claim.addError('unable to validate the claim');
        }
        Decimal convertedAmt = claim.DJC_Wellness_Amount_Requested__c * conversionRateToUSDForDefaultCurrency / conversionRateToUSDForClaim;        
        
        if(defaultCurrencyISOCode == 'JPY' || defaultCurrencyISOCode == 'KRW'){
            convertedAmt = math.ceil(convertedAmt);
            return convertedAmt;
        }
        return convertedAmt.setScale(scale, System.roundingMode.HALF_EVEN);                
    }  
    global class ResponseHandler {
        public String status {public get; private set;}
        public List<Claim> wellnessClaims{public get; private set;}
        public DateTime timestamp{public get; private set;}
        ResponseHandler(List<Claim> wellnessClaims, DateTime timestamp, String message) {
            this.wellnessClaims = wellnessClaims;
            this.timeStamp = timestamp;
            this.status = message;
        }        
    }
    
    global class Claim {
        public String employeeNumber{public get; private set;}
        public String activity{public get; private set;}
        public Decimal amount{public get; private set;}
        public Decimal convertedAmount{public get; private set;}
        public String claimCurrency{public get; private set;}
        public String countryCurrency{public get; private set;}
        public String workdayCode{public get; private set;}
        public Date startDateOfActivity{public get; private set;}
        public Date endDateOfActivity{public get; private set;}
        public String comments{public get; private set;}
        public String claimId{public get; private set;}
        public String caseId{public get; private set;}
        public String caseNumber{public get; private set;}
        
        public claim (String employeeNumber, String activity, Decimal amount, Decimal convertedAmount, String claimcurrency, String countryCurrency, String workdayCode, date startDateOfActivity,
                      date endDateOfActivity, String comments, Id claimId, Id caseId, String caseNumber) {
                          this.employeeNumber = employeeNumber;
                          this.activity = activity;
                          this.amount = amount;
                          this.convertedAmount = convertedAmount;
                          this.claimCurrency = claimcurrency;
                          this.countryCurrency = countryCurrency;
                          this.workdayCode = workdayCode;
                          this.startDateOfActivity = startDateOfActivity;
                          this.endDateOfActivity = endDateOfActivity;
                          this.comments = comments;
                          this.claimId = claimId;
                          this.caseId = caseId;
                          this.caseNumber = caseNumber;
                      }
    }            
}