public without sharing class PWWITestCtrl  {
    public Acquisition_Compensation__c compObj{get;set;}
    public Date ContractStartDate{get;set;}
    public Decimal salary{get;set;}
    public PWWITestCtrl(ApexPages.StandardController controller){
        compObj = new Acquisition_Compensation__c();
        Acquisition_Contacts__c objcon = (Acquisition_Contacts__c)controller.getRecord();
        compObj = [SELECT Id, Pay_Plan__c, Time_Type__c, Car_Allowance_Plan__c, CurrencyIsoCode, Pay_Group__c,Default_Hours__c,
                   Scheduled_Hours__c,Pay_Rate_Type__c,Annualized_Base_Salary__c,Hourly_Rate__c,Draw_Frequency__c,Draw_Duration__c,
                   Draw_is_Recoverable__c,Bonus_Plan__c,Stock_Plan__c,Stock_Reason__c,Stock_Grant_Amount__c,Grant_Type__c,One_Time_Payment_Amount__c,
                   Car_Allowance_Amount__c,Car_Allowance_Frequency__c,Stock_Grant_Date__c,Additional_OTP_Plan__c,Additional_OTP_Amount__c,
                   Additional_OTP_Effective_Date__c,Workday_Creation_Date__c, Workday_Integration_Status__c, Job_Code__c,Contact_Status__c,
                   Acquisition_Contact__r.Hire_Reason__c,Acquisition_Contact__r.Employee_Type__c,Acquisition_Contact__r.Gender__c,
                   Acquisition_Contact__r.Probation_End_Date__c,Acquisition_Contact__r.Probation_Start_Date__c,Acquisition_Contact__r.Home_Address_Street_Line_2__c,
                   Acquisition_Contact__r.Visa_Type__c,Acquisition_Contact__r.Visa_Expiration_Date__c,Acquisition_Contact__r.Office_Address_Country__c,
                   Acquisition_Contact__r.ID_Type__c,Acquisition_Contact__r.SSNID_Number__c,Acquisition_Contact__r.Personal_Phone_Number__c,
                   Acquisition_Contact__r.Phone_Number_Target__c,Acquisition_Contact__r.Personal_Email_Address__c,Acquisition_Contact__r.Home_Address_Country__c,
                   Acquisition_Contact__r.Company__c, Acquisition_Contact__r.Acquisition_Org__c,Acquisition_Contact__r.Applicant_ID__c,
                   Acquisition_Contact__r.Continuous_Service_Date__c, Acquisition_Contact__r.Employee_ID__c,Acquisition_Contact__c, 
                   Acquisition_Contact__r.Hire_Date_Target__c, Acquisition_Contact__r.Hire_Date__c,
                   Acquisition_Contact__r.Employee_ID_Target__c, Acquisition_Contact__r.First_Name_Legal__c, Acquisition_Contact__r.Id,
                   Acquisition_Contact__r.Position_ID_CW__c,Acquisition_Contact__r.Position_ID_FTE__c,Acquisition_Contact__r.Supervisory_Organization__c,
                   Acquisition_Contact__r.Last_Name_Legal__c,Acquisition_Contact__r.Country_of_Birth__c,Acquisition_Contact__r.First_Name_Preferred__c,
                   Acquisition_Contact__r.Last_Name_Preferred__c,Acquisition_Contact__r.Birth_Date__c,Acquisition_Contact__r.Home_Address_Street__c,
                   Acquisition_Contact__r.Home_Address_City__c,Acquisition_Contact__r.Home_Address_Region__c,Acquisition_Contact__r.Home_Address_Zip_Postal_Code__c,
                   Acquisition_Contact__r.Close_Date__c,Job_Family__c,Acquisition_Contact__r.Business_Title__c,Acquisition_Contact__r.Cost_Center__c,
                   Acquisition_Contact__r.Primary_Coverage_Country__c,Acquisition_Contact__r.Business_Unit__c,Acquisition_Contact__r.Email_Address_Target__c,
                   Acquisition_Contact__r.Company_Service_Date__c, Acquisition_Contact__r.Original_Hire_Date__c, Annualized_Base_Salary_Target__c, 
                   Bonus_Amount_Target__c, Commission_Amount_Target__c, Commission_Plan__c, Commission_Amount__c, Draw_Amount__c, One_Time_Payment_Plan__c,
                   On_Target_Earnings_Target__c, Acquisition_Contact__r.Founder_Type__c, Acquisition_Contact__r.Key_Critical_Employee__c, Acquisition_Contact__r.Change_in_Control_CiC__c, 
                   Acquisition_Contact__r.Background_Check__c,  Acquisition_Contact__r.Acquisition_Company_Name__c, Acquisition_Contact__r.Business_Title_Target__c, 
                   Acquisition_Contact__r.Active_at_Close__c, Acquisition_Contact__r.Active_at_Harmonization__c, Acquisition_Contact__r.Department_Target__c, 
                   Acquisition_Contact__r.Transitional_Employee__c, Frequency__c,Job_Profile_Title__c  FROM Acquisition_Compensation__c WHERE Acquisition_Contact__c =: objcon.Id LIMIT 1];
        
        ContractStartDate = compObj.Acquisition_Contact__r.Close_Date__c > compObj.Acquisition_Contact__r.Hire_Date_Target__c? compObj.Acquisition_Contact__r.Close_Date__c :compObj.Acquisition_Contact__r.Hire_Date_Target__c;
         
            if(compObj.Pay_Plan__c == 'Hourly Plan'){
                salary = compObj.Hourly_Rate__c;
            }else{
                
                salary = compObj.Annualized_Base_Salary__c;
            }
    }
}