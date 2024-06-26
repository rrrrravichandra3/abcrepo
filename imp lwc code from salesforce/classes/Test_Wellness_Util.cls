public with sharing class Test_Wellness_Util {
    
    public static Contact apacContact {public get; private set;}
    public static Contact emeaContact {public get; private set;}
    public static Contact koreaContact {public get; private set;}
    public static Contact latinContact {public get; private set;}
    public static Contact canadaContact {public get; private set;}
    public static Contact USContact {public get; private set;}
    public static Contact japanContact {public get; private set;}

    public static Contact foundationAPACContact{public get; private set;}
    public static DJC_Wellness_Provider__c apacProvider {public get; private set;}
    public static DJC_Wellness_Provider__c emeaProvider {public get; private set;}
    public static DJC_Wellness_Provider__c koreaProvider {public get; private set;}
    public static DJC_Wellness_Provider__c USProvider {public get; private set;}
    public static DJC_Wellness_Provider__c canadaProvider {public get; private set;}
    public static DJC_Wellness_Provider__c latinProvider {public get; private set;}    
    public static DJC_Wellness_Provider__c JapanProvider {public get; private set;}
 
    public static final String APAC_CURRENCY = 'INR';
    public static final String EMEA_CURRENCY = 'EUR';
    public static final String KOREA_CURRENCY = 'KRW';
    public static final String US_CURRENCY = 'USD';
    public static final String CANADA_CURRENCY = 'CAD';
    public static final String LATIN_CURRENCY = 'MXN';
    public static final String JAPAN_CURRENCY = 'JPY';

    public static final String APAC_COUNTRY = 'India';
    public static final String EMEA_COUNTRY = 'France';
    public static final String US_COUNTRY = 'United States of America';
    public static final String LATIN_COUNTRY = 'Mexico';
    public static final String CANADA_COUNTRY = 'Canada';
    public static final String Japan_COUNTRY = 'Japan';

    public static final Integer APAC_WELLNESS_POLICY = 51;
    public static final Integer APAC_HEALTH_POLICY = 31;    
    public static final Integer APAC_EDUCATION_POLICY = 11;    
    public static final Integer EMEA_WELLNESS_POLICY = 52;
    public static final Integer EMEA_EDUCATION_POLICY = 8;
    public static final Integer US_EDUCATION_POLICY = 25;
    public static final Integer LATIN_WELLNESS_POLICY = 55;
    public static final Integer LATIN_EDUCATION_POLICY = 15;
    public static final Integer CANADA_EDUCATION_POLICY = 4;

    //--For Japan - Giving arbitary value as Japan doesn't have policy setup.
    public static final Integer JAPAN_WELLNESS_POLICY = 999;
    public static final Integer JAPAN_EDUCATION_POLICY = 998;

    public static final Integer WELLNESS_CATEGORY = 2;
    public static final Integer EDUCATION_CATEGORY = 1;
    
    public static Datetime testDate = System.now();

    public class expenseCaseTestData{
        Contact caseContact;
        Integer WellnessPolicyId;
        Integer EdPolicyId;
        String CurrISO;
        DJC_Wellness_Provider__c provider;
        public expenseCaseTestData(contact c,Integer WellnessPolicyId, Integer EdPolicyId , string ISO, DJC_Wellness_Provider__c provider)
        {
            this.caseContact=c;
            this.WellnessPolicyId= WellnessPolicyId;
            this.EdPolicyId = EdPolicyId;
            this.CurrISO = ISO;
            this.provider = provider;
        }
    }
        
    public static map<string,expenseCaseTestData> mDivisionToExpenseCaseData = new map<string,expenseCaseTestData>();

    public static Decimal currencyTypeConversionRateForClaim(String claimCurrencyISOCode){
        Decimal conversionRateToUSDForClaim = 0;
        for(CurrencyType ctype:[SELECT ConversionRate,DecimalPlaces,IsActive,IsCorporate,IsoCode FROM CurrencyType where IsActive = true]) {
            if (ctype.IsoCode.equals(claimCurrencyISOCode)) {
                conversionRateToUSDForClaim = ctype.ConversionRate;
            }
        }
        return conversionRateToUSDForClaim;
    }

    public static Decimal currencyTypeConversionRateForDefaultCurrency(String defaultCurrencyISOCode){
        Decimal conversionRateToUSDForDefaultCurrency = 0;
        for (CurrencyType ctype:[SELECT ConversionRate,DecimalPlaces,IsActive,IsCorporate,IsoCode FROM CurrencyType where IsActive = true]) {
            if (ctype.IsoCode.equals(defaultCurrencyISOCode)){
                conversionRateToUSDForDefaultCurrency = ctype.ConversionRate;
            }
        }
        return conversionRateToUSDForDefaultCurrency;
    }
        
    private static boolean initialized = false;
    
    public static DJC_Wellness_Reimbursement_Claim__c createWellnessClaim (Case expensecase, Map<String, Object> nameValueMap, boolean doInsert) {
        init();
        DJC_Wellness_Reimbursement_Claim__c claim = new DJC_Wellness_Reimbursement_Claim__c();       
        claim.DJC_Wellness_Case__c = expensecase.id;
        if(expensecase.type == 'Wellness Reimbursement Request'){
             claim.DJC_Wellness_Provider__c = mDivisionToExpenseCaseData.get(expensecase.division__c).provider.id;
        }
        /*if (wellnessCase.Contactid == apacContact.id) {
            claim.DJC_Wellness_Provider__c = apacProvider.id;
        } else {
            claim.DJC_Wellness_Provider__c = emeaProvider.id;
        }*/ 
        
        for (String key : nameValueMap.keySet()) {
            claim.put(key, nameValueMap.get(key));
        }            
        if (doInsert)
            insert claim;
        return claim;
    } 
    
    
   public static void init(){        
       if (initialized) {
           return;
        } 
        //Create custom settings
        ESDJC_TestUtil.init();
       
       //Create contacts
        apacContact = ESDJC_AssignmentHelper.getContacts(1, 'APAC - All Countries', 'Mumbai', 'India', Date.newInstance(2018, 6, 17))[0];
        emeaContact = ESDJC_AssignmentHelper.getContacts(1, 'EMEA - All Countries', 'Paris', 'France', Date.newInstance(2018, 6, 17))[0];
        koreaContact = ESDJC_AssignmentHelper.getContacts(1,'APAC - All Countries', 'Seoul', 'Korea, Republic of', Date.newInstance(2018, 6, 17))[0];     
        foundationAPACContact = ESDJC_AssignmentHelper.createContactsByDeptDivWorkLoc(1,'APAC - All Countries','FOUN-Foundation','India', Date.newInstance(2018, 6, 17))[0];
        USContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - USA', 'San Francisco', 'United States', Date.newInstance(2018, 6, 17))[0];
        CanadaContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - Canada', 'Ottawa', 'Canada', Date.newInstance(2018, 6, 17))[0];
        latinContact = ESDJC_AssignmentHelper.getContacts(1, 'Americas - Latin America', 'Cancun', 'Mexico', Date.newInstance(2018, 6, 17))[0];
        JapanContact = ESDJC_AssignmentHelper.getContacts(1, 'Japan', 'Tokyo', 'Japan', Date.newInstance(2018, 6, 17))[0];

        //Add providers
        apacProvider = new DJC_Wellness_Provider__c();
        apacProvider.DJC_Contact__c = apacContact.id;
        apacProvider.Name = '24x7 Fitness';
        insert apacProvider;
        emeaProvider = new DJC_Wellness_Provider__c();
        emeaProvider.DJC_Contact__c = emeaContact.id;
        emeaProvider.Name = '24x7 Fitness emea';
        insert emeaProvider;
        koreaProvider = new DJC_Wellness_Provider__c();
        koreaProvider.DJC_Contact__c = koreaContact.id;
        koreaProvider.Name = '24x7 Fitness apac';
        insert koreaProvider;
        USProvider = new DJC_Wellness_Provider__c();
        USProvider.DJC_Contact__c = USContact.id;
        USProvider.Name = '24x7 Fitness US';
        insert USProvider;              
        CanadaProvider = new DJC_Wellness_Provider__c();    
        CanadaProvider.DJC_Contact__c = CanadaContact.id;
        CanadaProvider.Name = '24x7 Fitness apac';
        insert CanadaProvider;       
        JapanProvider = new DJC_Wellness_Provider__c();
        JapanProvider.DJC_Contact__c = JapanContact.id;
        JapanProvider.Name = '24x7 Fitness Japan';
        insert JapanProvider;
        LatinProvider = new DJC_Wellness_Provider__c();
        LatinProvider.DJC_Contact__c = latinContact.id;
        LatinProvider.Name = '24x7 Fitness latin';
        insert LatinProvider;

        mDivisionToExpenseCaseData.put('APAC - All Countries', new expenseCaseTestData(apacContact,APAC_WELLNESS_POLICY,APAC_EDUCATION_POLICY,APAC_CURRENCY, apacProvider));
        mDivisionToExpenseCaseData.put('EMEA - All Countries', new expenseCaseTestData(EMEAContact,EMEA_WELLNESS_POLICY,EMEA_EDUCATION_POLICY,EMEA_CURRENCY, EMEAProvider));
        mDivisionToExpenseCaseData.put('Japan', new expenseCaseTestData(JapanContact,Japan_WELLNESS_POLICY,Japan_EDUCATION_POLICY,Japan_CURRENCY, JapanProvider));
        mDivisionToExpenseCaseData.put('Americas - USA', new expenseCaseTestData(USContact,null,US_EDUCATION_POLICY,US_CURRENCY, USProvider));
        mDivisionToExpenseCaseData.put('Americas - Canada', new expenseCaseTestData(CanadaContact,null,Canada_EDUCATION_POLICY,Canada_CURRENCY, CanadaProvider));
        mDivisionToExpenseCaseData.put('Americas - Latin America', new expenseCaseTestData(latinContact,Latin_WELLNESS_POLICY,Latin_EDUCATION_POLICY,Latin_CURRENCY, LatinProvider));


        initialized = true;
    }

    public static void initEdu(){

        if (initialized) {
           return;
        } 

        ESDJC_TestUtil.init();
             
        apacContact = ESDJC_AssignmentHelper.getContacts(1, 'APAC - All Countries', 'Mumbai', 'India')[0];
        emeaContact = ESDJC_AssignmentHelper.getContacts(1, 'EMEA - All Countries', 'Paris', 'France')[0];
       
        apacProvider = new DJC_Wellness_Provider__c();
        apacProvider.DJC_Contact__c = apacContact.id;
        apacProvider.Name = '24x7 Fitness';
        insert apacProvider;
        emeaProvider = new DJC_Wellness_Provider__c();
        emeaProvider.DJC_Contact__c = emeaContact.id;
        emeaProvider.Name = '24x7 Fitness emea';
        insert emeaProvider;
        

        mDivisionToExpenseCaseData.put('EMEA - All Countries', new expenseCaseTestData(EMEAContact,EMEA_WELLNESS_POLICY,EMEA_EDUCATION_POLICY,EMEA_CURRENCY, EMEAProvider));
        mDivisionToExpenseCaseData.put('APAC - All Countries', new expenseCaseTestData(apacContact,APAC_WELLNESS_POLICY,APAC_EDUCATION_POLICY,APAC_CURRENCY, apacProvider));
       

        initialized = true;
    }
    
    public static Case createAPACWellnessCase() {
        init();
        Case apacCase = new Case();
        apacCase.Contactid = apacContact.id;
        apacCase.subject = 'test apac case'; 
        apacCase.Description = 'test apac case';
        apacCase.Type = 'Wellness Reimbursement Request';
        apacCase.ES_DJC_Topic__c = 'Wellness';
        apacCase.Division__c = 'APAC - All Countries';  //As this field is used in DJC_WellnessIntegrationcontroller      
        apacCase.Reimbursement_Policy_Id__c = APAC_WELLNESS_POLICY;
        apacCase.Reimbursement_Category_Id__c = WELLNESS_CATEGORY;
        apacCase.CurrencyIsoCode = APAC_CURRENCY;
        apacCase.PII__c = 'Yes';
        insert apacCase;
        return apacCase;
    }
    public static Case createEdCaseByRegion(string division){
        init();
        expenseCaseTestData data = mDivisionToExpenseCaseData.get(division);
        Case edCase = new Case();
        edCase.Contactid = data.caseContact.id;
        edCase.subject = 'test ed case for contact '+ data.caseContact.name;
        edCase.Description = 'test apac case';
        edCase.Type = 'Education Reimbursement Request';
        edCase.ES_DJC_Topic__c = 'Education';
        edCase.ES_DJC_Sub_Topic__c = 'College';
        edCase.Origin = 'Employee Success - Web';
        edCase.Reimbursement_Policy_Id__c = data.EdPolicyId;
        edCase.Reimbursement_Category_Id__c = EDUCATION_CATEGORY;
        edCase.CurrencyIsoCode = data.CurrISO;
        edCase.PII__c = 'Yes';
        edCase.Division__c =  division; 
        edCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
        edCase.Status = 'Approved';

        return edCase;
    }
    public static Case createWellnessCaseByRegion(string division){
        expenseCaseTestData data = mDivisionToExpenseCaseData.get(division);
        Case wellnessCase = new Case();
        wellnessCase.Contactid = data.caseContact.id;
        wellnessCase.subject = 'test wellness case for contact '+ data.caseContact.name;
        wellnessCase.Description = 'test apac case';
        wellnessCase.Type = 'Wellness Reimbursement Request';
        wellnessCase.ES_DJC_Topic__c = 'Health';
        wellnessCase.ES_DJC_Sub_Topic__c = 'Fitness';
        wellnessCase.Origin = 'Employee Success - Web';
        wellnessCase.Reimbursement_Policy_Id__c = data.WellnessPolicyId;
        wellnessCase.Reimbursement_Category_Id__c = WELLNESS_CATEGORY;
        wellnessCase.CurrencyIsoCode = data.CurrISO;
        wellnessCase.PII__c = 'Yes';
        wellnessCase.Division__c =  division; 
        wellnessCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
        wellnessCase.Status = 'Approved';
        wellnesscase.DJC_Reimbursement_Case_Approved_On__c= system.now();
        return wellnessCase;
    }
     public static Case createAPACEducationCase() {
        init();
        Case apacCase = new Case();
        apacCase.Contactid = apacContact.id;
        apacCase.subject = 'test apac case';
        apacCase.Description = 'test apac case';
        apacCase.Type = 'Education Reimbursement Request';
        apacCase.ES_DJC_Topic__c = 'Education';
        apacCase.ES_DJC_Sub_Topic__c = 'College';
        apacCase.Origin = 'Employee Success - Web';
        apacCase.Division__c = 'APAC - All Countries';  //As this field is used in DJC_EducationIntegrationcontroller           
        apacCase.Reimbursement_Policy_Id__c = APAC_EDUCATION_POLICY;
        apacCase.Reimbursement_Category_Id__c = EDUCATION_CATEGORY;
        apacCase.CurrencyIsoCode = APAC_CURRENCY;
        apacCase.PII__c = 'Yes';
        //apacCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();

        insert apacCase;

        return apacCase;
    }

    public static Case createAPACEduCase() {
        initEdu();
        Case apacCase = new Case();
        apacCase.Contactid = apacContact.id;
        apacCase.subject = 'test apac case';
        apacCase.Description = 'test apac case';
        apacCase.Type = 'Education Reimbursement Request';
        apacCase.ES_DJC_Topic__c = 'Education';
        apacCase.ES_DJC_Sub_Topic__c = 'College';
        apacCase.Origin = 'Employee Success - Web';
        apacCase.Division__c = 'APAC - All Countries';  //As this field is used in DJC_EducationIntegrationcontroller           
        apacCase.Reimbursement_Policy_Id__c = APAC_EDUCATION_POLICY;
        apacCase.Reimbursement_Category_Id__c = EDUCATION_CATEGORY;
        apacCase.CurrencyIsoCode = APAC_CURRENCY;
        apacCase.PII__c = 'Yes';
        //apacCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();

        insert apacCase;

        return apacCase;
    }

    public static Case createAPACEdCaseForFoundationContact() {
        init();
        Case apacCase = new Case();
        apacCase.Contactid = foundationAPACContact.id;
        apacCase.subject = 'test foundation ed case for contact'+ foundationAPACContact.name;
        apacCase.Description = 'test apac case';
        apacCase.Type = 'Education Reimbursement Request';
        apacCase.ES_DJC_Topic__c = 'Education';
        apacCase.ES_DJC_Sub_Topic__c = 'College';
        apacCase.Origin = 'Employee Success - Web';
        apacCase.Reimbursement_Policy_Id__c = APAC_EDUCATION_POLICY;
        apacCase.Reimbursement_Category_Id__c = EDUCATION_CATEGORY;
        apacCase.CurrencyIsoCode = APAC_CURRENCY;
        apacCase.PII__c = 'Yes';
        apacCase.Status = 'Approved';
        apacCase.Division__c =  'APAC - All Countries';
        apacCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
        return apacCase;
    } 
     public static Case createAPACWellnessCaseForFoundationContact() {
        init();
        Case apacCase = new Case();
        apacCase.Contactid = foundationAPACContact.id;
        apacCase.subject = 'test foun wellness apa case for contact'+ foundationAPACContact.name;
        apacCase.Description = 'test foun wellness apac case';
        apacCase.Type = 'Wellness Reimbursement Request';
        apacCase.ES_DJC_Topic__c = 'Health';
        apacCase.ES_DJC_Sub_Topic__c = 'Fitness';
        apacCase.Origin = 'Employee Success - Web';
        apacCase.Reimbursement_Policy_Id__c = APAC_WELLNESS_POLICY;
        apacCase.Reimbursement_Category_Id__c = WELLNESS_CATEGORY;
        apacCase.CurrencyIsoCode = APAC_CURRENCY;
        apacCase.PII__c = 'Yes';
        apacCase.Division__c =  'APAC - All Countries';
        apacCase.Status = 'Approved';
        return apacCase;
    } 
    public static Case createAPACHealthCase() {
        init();
        Case apacHealthReimbursementCase = new Case();
        apacHealthReimbursementCase.Contactid = apacContact.id;
        apacHealthReimbursementCase.subject = 'test apac case';
        apacHealthReimbursementCase.Description = 'test apac case';
        apacHealthReimbursementCase.Type = 'Wellness Reimbursement Request';        
        apacHealthReimbursementCase.ES_DJC_Topic__c = 'Health/Vision/TCM';
        apacHealthReimbursementCase.Reimbursement_Policy_Id__c = APAC_HEALTH_POLICY;
        apacHealthReimbursementCase.Reimbursement_Category_Id__c = 7;
        apacHealthReimbursementCase.PII__C ='Yes';
        apacHealthReimbursementCase.Division__c =  'APAC - All Countries';
       
        insert apacHealthReimbursementCase;
        Test.setCreatedDate(apacHealthReimbursementCase.id,system.today().addmonths(-1));

        return apacHealthReimbursementCase;
    }

    public static Case createEMEAWellnessCase() {
        init();
        Case emeaCase = new Case(); 
        emeaCase.Contactid = emeaContact.id;
        emeaCase.subject = 'test emea case';
        emeaCase.Description = 'test emea case';
        emeaCase.Type = 'Wellness Reimbursement Request';        
        emeaCase.ES_DJC_Topic__c = 'Wellness';
        emeaCase.Reimbursement_Policy_Id__c = EMEA_WELLNESS_POLICY;
        emeaCase.Reimbursement_Category_Id__c = WELLNESS_CATEGORY;
        emeaCase.CurrencyIsoCode = EMEA_CURRENCY;
        emeaCase.ES_DJC_Sub_Topic__c = 'Vision';
        emeaCase.Origin = 'Employee Success - Web';
        emeaCase.PII__c = 'Yes';
        emeaCase.Division__c =  'EMEA - All Countries';

       // emeaCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
        insert emeaCase;   
    
        return emeaCase;
    }
    
    public static Case createEMEAEducationCase() {
        init();
        Case emeaCase = new Case(); 
        emeaCase.Contactid = emeaContact.id;
        emeaCase.subject = 'test emea case';
        emeaCase.Description = 'test emea case';
        emeaCase.Type = 'Education Reimbursement Request';        
        emeaCase.ES_DJC_Topic__c = 'Education';
        emeaCase.Reimbursement_Policy_Id__c = EMEA_EDUCATION_POLICY;
        emeaCase.Reimbursement_Category_Id__c = EDUCATION_CATEGORY; 
        emeaCase.CurrencyIsoCode = EMEA_CURRENCY;
        emeaCase.PII__c = 'Yes';
        insert emeaCase;     
  
        return emeaCase;
    }

    public static Case createEMEAEduCase() {
        initEdu();
        Case emeaCase = new Case(); 
        emeaCase.Contactid = emeaContact.id;
        emeaCase.subject = 'test emea case';
        emeaCase.Description = 'test emea case';
        emeaCase.Type = 'Education Reimbursement Request';        
        emeaCase.ES_DJC_Topic__c = 'Education';
        emeaCase.Reimbursement_Policy_Id__c = EMEA_EDUCATION_POLICY;
        emeaCase.Reimbursement_Category_Id__c = EDUCATION_CATEGORY; 
        emeaCase.CurrencyIsoCode = EMEA_CURRENCY;
        emeaCase.PII__c = 'Yes';
        insert emeaCase;     
  
        return emeaCase;
    }

     public static Case createAPACEducationCaseForClose() {
        init();
        Case apacCase = new Case();
        apacCase.Contactid = apacContact.id;
        apacCase.subject = 'test apac case';
        apacCase.Description = 'test apac case';
        apacCase.Type = 'Education Reimbursement Request';
        apacCase.ES_DJC_Topic__c = 'Education';
        apacCase.ES_DJC_Sub_Topic__c = 'College';
        apacCase.Origin = 'Employee Success - Web';
        apacCase.Reimbursement_Policy_Id__c = APAC_EDUCATION_POLICY;
        apacCase.Reimbursement_Category_Id__c = EDUCATION_CATEGORY;
        apacCase.CurrencyIsoCode = APAC_CURRENCY;
        apacCase.PII__c = 'Yes';
        apacCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();

        insert apacCase;
        Test.setCreatedDate(apacCase.id,system.today().addmonths(-1));

        return apacCase;
    }
    
    public static Case createEMEAWellnessCaseForClose() {
        init();
        Case emeaCase = new Case(); 
        emeaCase.Contactid = emeaContact.id;
        emeaCase.subject = 'test emea case';
        emeaCase.Description = 'test emea case';
        emeaCase.Type = 'Wellness Reimbursement Request';        
        emeaCase.ES_DJC_Topic__c = 'Wellness';
        emeaCase.Reimbursement_Policy_Id__c = EMEA_WELLNESS_POLICY;
        emeaCase.Reimbursement_Category_Id__c = WELLNESS_CATEGORY;
        emeaCase.CurrencyIsoCode = EMEA_CURRENCY;
        emeaCase.ES_DJC_Sub_Topic__c = 'Vision';
        emeaCase.Origin = 'Employee Success - Web';
        emeaCase.PII__c = 'Yes';
        emeaCase.Division__c =  'EMEA - All Countries';
         emeaCase.recordtypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
        insert emeaCase; 

        Test.setCreatedDate(emeaCase.id,system.today().addmonths(-1));
      
        return emeaCase;
    }
     public static Map<String, Object> buildFieldsForClaim (date startDate, String status, String activity, String currencyISOCode, Double amountRequested, date completedDate) {
        Map<String, object> nameValueMap = new Map<String, object>();
        nameValueMap.put('DJC_Wellness_Start_Date_of_Activity__c', startDate);
        nameValueMap.put('DJC_Wellness_Request_Status__c', status);
        nameValueMap.put('DJC_Wellness_Activity__c', activity);
        nameValueMap.put('CurrencyIsoCode', currencyISOCode);
        nameValueMap.put('DJC_Wellness_Amount_Requested__c', amountRequested);
        nameValueMap.put('DJC_Education_Date_Completed__c', completedDate);
        return nameValueMap;
    }
    
    public static Decimal convertValueToCurrency(String currentCurrencyISOCode, String currencyISOCode, Decimal value, Integer decimalPlaces){
        Decimal convertedValue = value * getCurrencyRateByISOCode(currencyISOCode) / getCurrencyRateByISOCode(currentCurrencyISOCode);
        return convertedValue.setScale(decimalPlaces, System.roundingMode.HALF_EVEN);
    }
    
    public static Decimal getApacWellnessLimit(String period){
       Reimbursement_Policy_Limit__mdt l = [SELECT Limit__c FROM Reimbursement_Policy_Limit__mdt WHERE Policy_Id__c = :APAC_WELLNESS_POLICY AND Period__c = :period];
       return l.Limit__c;
    }
    
    public static Decimal getApacHealthLimit(String period){
       Reimbursement_Policy_Limit__mdt l = [SELECT Limit__c FROM Reimbursement_Policy_Limit__mdt WHERE Policy_Id__c = :APAC_HEALTH_POLICY AND Period__c = :period];
       return l.Limit__c;
    }
    
    private static Decimal getCurrencyRateByISOCode(String currencyISOCode){
        CurrencyType currencyType = [SELECT ConversionRate FROM CurrencyType where IsoCode = :currencyISOCode AND IsActive = true LIMIT 1];
        if(currencyType != null){
            return currencyType.ConversionRate;
        }
        return 1.0;
    }
    
        public static void createBulkWellnessCases(Contact c,Integer noOfRecs){
            Reimbursement_Policy__mdt Policy = [SELECT Id__c, Currency__c 
                                                      FROM Reimbursement_Policy__mdt 
                                                      WHERE Country__c = :c.ES_DJC_Contact_Country__c 
                                                      AND Active__c = true
                                                      and MasterLabel Like '%Wellness%'];
            system.assertNotEquals(Policy,null,policy);
            Reimbursement_Category__mdt category = [SELECT MasterLabel,Id__c FROM Reimbursement_Category__mdt 
                                                    WHERE Group__c = 'Wellness'];
            system.assertNotEquals(category,null,category);
            
           // DJC_Wellness_Provider__c provider = [select name from DJC_Wellness_Provider__c where DJC_Contact__c = :c.id];


            list<case> wellnessCasesToInsert = new list<case>();
            list<DJC_Wellness_Reimbursement_Claim__c> claimsToInsert = new list<DJC_Wellness_Reimbursement_Claim__c>();
            
            for(integer i =0;i<noOfRecs;i++){
                Case wellnessCase = new case();
                wellnessCase.Contactid = c.id;
                wellnessCase.subject = 'test bulk case';
                wellnessCase.Description = 'test bulk case';
                wellnessCase.recordtypeid=Schema.SObjectType.Case.getRecordTypeInfosByName().get('All Expense Cases').getRecordTypeId();
                
                wellnessCase.Type = 'Wellness Reimbursement Request';
                wellnessCase.Reimbursement_Policy_Id__c = Policy.Id__c;
                wellnessCase.Reimbursement_Category_Id__c = category.Id__c;
                wellnessCase.ES_DJC_Topic__c = category.MasterLabel;
                wellnessCase.Division__c = c.Division__c;
                wellnessCase.Origin = 'Employee Success - Web';
                wellnessCase.CurrencyIsoCode = Policy.Currency__c;
                
                wellnessCasesToInsert.add(wellnessCase);    
            }
            
            
            insert wellnessCasesToInsert;
            
            DJC_Wellness_Provider__c Provider = new DJC_Wellness_Provider__c();
            Provider.DJC_Contact__c = c.id;
            Provider.Name = '24x7 Fitness';
            insert Provider;    
                
            for(integer j=0;j<noOfRecs;j++){
                DJC_Wellness_Reimbursement_Claim__c claim = new DJC_Wellness_Reimbursement_Claim__c();       
                claim.DJC_Wellness_Case__c = wellnessCasesToInsert[j].id;
                claim.DJC_Wellness_Provider__c = Provider.id;
                claim.DJC_Wellness_Start_Date_of_Activity__c = System.today();
                claim.DJC_Wellness_Request_Status__c = 'Approved';
                claim.DJC_Wellness_Activity__c ='Badminton';
                claim.CurrencyIsoCode = wellnessCasesToInsert[j].CurrencyIsoCode;
                claim.DJC_Wellness_Amount_Requested__c=1;  
                claimsToInsert.add(claim);   
            }    
            
                
            insert claimsToInsert;      
            
    }
    public static void bulkCasesSetup(Contact c,Integer noOfRecs){
        init();     
        Test_Wellness_Util.createBulkWellnessCases(c,noOfRecs);
        list<case> wellnessCasesCreated = [select id,status from case 
                                           where subject like '%test bulk case%'];
        for(case wellnesscase:wellnessCasesCreated){
            wellnesscase.status='Approved';
            Test.setCreatedDate(wellnesscase.id,system.today().addmonths(-1));

        }
        update wellnessCasesCreated;
        system.assertEquals(wellnessCasesCreated.size(),noOfRecs,'Expecting noOfRecs wellness cases to be created.');
        //system.assertEquals(wellnessCasesCreated[0].DJC_Wellness_Reimbursement_Claims__r,1,'Expecting 1 claim per wellness case to be created.');
        
    }
}