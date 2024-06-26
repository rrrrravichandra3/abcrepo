/*
*    Utility class to club together methods that are modified often and is shared between Acquisition List view controller and record level button controller.
*    Modifying these methods here ensures that both - list controller and record level controller stay updated without repeatng same change in each one of them.
*/
public with sharing class Acquisition_Docusign_Util{

    
    
    //for each country, fetch an instance of its corresponding extension class
    public static DocuSignAcquisitionBaseCountry getDocusignObject(Acquisition_Offer__c acqOffer){
        String country = acqOffer.Office_Country__c;
        DocuSignAcquisitionBaseCountry docusign = null;
        if(country == 'United States'){
            docusign = new DocuSignAcquisitionUS();
            docusign.setAcquisitionOffer(acqOffer);
        }else if(country == 'Germany'){
            docusign = new DocuSignAcquisitionGermany();
            docusign.setAcquisitionOffer(acqOffer);
        }else if(country == 'United Kingdom'){
            docusign = new DocuSignAcquisitionUK();
            docusign.setAcquisitionOffer(acqOffer);
        }else if(country == 'France'){
            docusign = new DocuSignAcquisitionFrance();
            docusign.setAcquisitionOffer(acqOffer);
        }
        return docusign;
    }


    //Query to get fields from Acquisition Offer. add more fields in query string as needed. List view controller, as well as record level controller both use this query
    public static String getQueryFields(){
        String query = 'Select Id, Name, Bonus_Target__c, Compensation_Grade__c, Variable_Payment_Frequency__c, Relocation_Allowance__c, Office_City__c , EMEA_Misc_Contractual_Clause__c, Car_Allowance_Amount__c ,Position_Type__c, Employee_Personal_Email__c, Hourly_Rate__c, Acq_Non_Exempt_Salary__c, First_Name_Legal__c, Last_Name_Legal__c, Office_Country__c, Pay_Rate_Type_Salary_Hourly__c, Bonus_Plan__c, Relocation_Package_Cost__c, Employee_Type__c, Stock_Grant_Amount__c, Office_State_Province__c, Current_DocuSign__c, Continuous_Service_Date__c, Hire_Date__c, Planned_End_Date__c, Offer_Date__c, Offer_Expiration_Date__c, Probation_Start_Date__c, Probation_End_Date__c, Base_Salary__c, RSU_Amount__c, Target_Variable_Amount__c, Draw_Amount__c, Sign_On_Bonus__c, On_Target_Earnings__c, Overtime_OT__c, Double_TIme_DT__c from Acquisition_Offer__c ';
        return query;
    }

    //Converts a decimal into comma separated US style string. Example, 1232.55 gets converted to 1,232.55
    public static String convertDecimalToCommaSeparatedString(Decimal amount){
        String amountString = amount.toPlainString();
        string regex = '(\\d)(?=(\\d{3})+(?!\\d))';
        String formattedAmount = amountString.replaceAll(regex, '$1,');
        return formattedAmount;
    }

    //Interchanges dots with commas. Useful for chagning US number formates to EMEA number formats. Example 3,445.50 gets changed to 3.445,50
    public static String interchangeDotsAndCommas(String amountString){
        amountString = amountString.replaceAll(',','@');
        amountString = amountString.replaceAll('\\.',',');
        amountString = amountString.replaceAll('@','\\.');
        return amountString;
    }

    
}