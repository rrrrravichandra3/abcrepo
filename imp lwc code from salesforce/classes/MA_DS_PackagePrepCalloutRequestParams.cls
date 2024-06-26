/**
 * W-13011399
 * Extends MA_DS_AbstractCalloutRequestParams class to Serialize value of Params attribute for the Package Prep API callout.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/04/2023      Chakshu Malhotra        W-13011399 - Adds logic to convert MA_DS_PackagePrepWrapper.PackagePrepParams to an accepted format of Package Prep API callout.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_PackagePrepCalloutRequestParams extends MA_DS_AbstractCalloutRequestParams {

    private static final String STOCK_GRANT_FORMAT = Label.MA_DS_Stock_Grant_Format;
    private static final String CURRENCY_FORMATTED_FIELDS_STR = Label.MA_DS_Package_Prep_Currency_Fields;
    private static Set<String> officeAddressCountries {get; set;}

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to convert the requestParams & wrap it in a ParamsWrapper instance, as per the accepted Payload format for the Package Prep API Request.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type MA_DS_CalloutFramework.RequestParams , RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void deserializeParams(MA_DS_CalloutFramework.RequestParams requestParams) {
        this.requestParams = requestParams;
        MA_DS_PackagePrepWrapper.PackagePrepParams packagePrepParams = (MA_DS_PackagePrepWrapper.PackagePrepParams)requestParams;

        ParamsWrapper wrapperInstance = new ParamsWrapper();
        wrapperInstance.CompanyName = packagePrepParams.acqCompanyName;
        wrapperInstance.CompanyId = packagePrepParams.acqCompanyId;
        wrapperInstance.CommonId = packagePrepParams.commonId;
        wrapperInstance.FirstBatch = String.valueOf(packagePrepParams.firstBatch).toUpperCase();
        wrapperInstance.FinalBatch = String.valueOf(packagePrepParams.finalBatch).toUpperCase();
        wrapperInstance.PackageRecipients = getPackageRecipientsWrapper(packagePrepParams.acqContacts);
        wrapperInstance.CurrencyFormattedFields = MA_DS_SalaryFormatter.getCurrencyFormattedFieldsWrapper(CURRENCY_FORMATTED_FIELDS_STR);
        wrapperInstance.CurrencyFormats = MA_DS_SalaryFormatter.getCurrencyFormatsWrapper(officeAddressCountries);

        super.deserializedParams = JSON.deserializeUntyped(JSON.serialize(wrapperInstance));
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap List of PackageRecipientWrapper instances within PackageRecipientsWrapper instance, based on the details in "requestParams".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContacts	                        DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts for the Package Prep)
    * @return   PackageRecipientsWrapper            DESCRIPTION (return PackageRecipientsWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static PackageRecipientsWrapper getPackageRecipientsWrapper(List<Acquisition_Contacts__c> acqContacts) {
        PackageRecipientsWrapper packageRecipientsWrapper = new PackageRecipientsWrapper();
        packageRecipientsWrapper.PackageRecipient = getPackageRecipientWrapperList(acqContacts);
        return packageRecipientsWrapper;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap PackageRecipientWrapper details in the List of PackageRecipientWrapper instance, based on the details in "requestParams".
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    acqContacts	                        DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contacts for the Package Prep)
    * @return   List<PackageRecipientWrapper>       DESCRIPTION (return List of PackageRecipientWrapper instances)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<PackageRecipientWrapper> getPackageRecipientWrapperList(List<Acquisition_Contacts__c> acqContacts) {
        List<PackageRecipientWrapper> packageRecipientWrapperList = new List<PackageRecipientWrapper>();
        officeAddressCountries = new Set<String>();

        for(Acquisition_Contacts__c acqContact : acqContacts) {
            PackageRecipientWrapper packageRecipientWrapper = new PackageRecipientWrapper();
            updateWithContactInfo(packageRecipientWrapper, acqContact);

            if(acqContact.Acquisition_Compensation__r != null && acqContact.Acquisition_Compensation__r.size() > 0) {
                updateWithCompensationInfo(packageRecipientWrapper, acqContact.Acquisition_Compensation__r[0]);
            }

            if(acqContact.MA_DS_Applied_Rules__r != null && acqContact.MA_DS_Applied_Rules__r.size() > 0) {
                packageRecipientWrapper.AppliedRules = getAppliedRulesWrapper(acqContact.MA_DS_Applied_Rules__r);
            }

            packageRecipientWrapperList.add(packageRecipientWrapper);

            if(String.isNotBlank(acqContact.Office_Address_Country__c)) {
                officeAddressCountries.add(acqContact.Office_Address_Country__c);
            }
        }

        return packageRecipientWrapperList;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Contact record details in PackageRecipientWrapper wrapper instance.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageRecipientWrapper	            DESCRIPTION (Data Type PackageRecipientWrapper, Wrapper instance to wrap Acquisition Contact details)
    * @param    acqContact	                        DESCRIPTION (Data Type Acquisition_Contacts__c, Acquisition Contact record details)
    * @return   void
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateWithContactInfo(PackageRecipientWrapper packageRecipientWrapper, Acquisition_Contacts__c acqContact) {
        packageRecipientWrapper.ContactId = acqContact.Id;
        packageRecipientWrapper.ContactFirstName = acqContact.First_Name_Legal__c;
        packageRecipientWrapper.ContactLastName = acqContact.Last_Name_Legal__c;
        packageRecipientWrapper.ContactFullName = acqContact.Name;
        packageRecipientWrapper.HomeAddressCity = acqContact.Home_Address_City__c;
        packageRecipientWrapper.HomeAddressCommune = acqContact.Home_Address_Commune__c;
        packageRecipientWrapper.HomeAddressCountry = acqContact.Home_Address_Country__c;
        packageRecipientWrapper.HomeAddressRegion = acqContact.Home_Address_Region__c;
        packageRecipientWrapper.HomeAddressStateProvince = acqContact.Home_Address_State_Province__c;
        packageRecipientWrapper.HomeAddressStreet = acqContact.Home_Address_Street__c;
        packageRecipientWrapper.HomeAddressStreetArabic = acqContact.Home_Address_Street_Arabic__c;
        packageRecipientWrapper.HomeAddressStreetLine2 = acqContact.Home_Address_Street_Line_2__c;
        packageRecipientWrapper.HomeAddressStreetLine2Arabic = acqContact.Home_Address_Street_Line_2_Arabic__c;
        packageRecipientWrapper.HomeAddressZipPostalCode = acqContact.Home_Address_Zip_Postal_Code__c;
        packageRecipientWrapper.EmployeeIDTarget = acqContact.Employee_ID_Target__c;
        packageRecipientWrapper.ContactEmail = acqContact.MA_DS_Preferred_Email_Address__c;
        packageRecipientWrapper.CurrentManager = acqContact.Manager_Name_Target__r?.Name;
        packageRecipientWrapper.FutureManager = acqContact.Manager_Name__r?.Name;
        packageRecipientWrapper.FutureManagerTitle = acqContact.Manager_Title__c;
        packageRecipientWrapper.EmploymentType = acqContact.Employee_Type__c;
        packageRecipientWrapper.ExemptionStatus = acqContact.Pay_Rate_Type__c;
        packageRecipientWrapper.BusinessTitle = acqContact.Business_Title__c;
        packageRecipientWrapper.BenefitsContinuationWeeks = acqContact.COBRA_Months__c;
        packageRecipientWrapper.OutplacementMonths = acqContact.Outplacement_Months__c;
        packageRecipientWrapper.WorkLocationStatus = acqContact.Work_Location_Status__c;
        packageRecipientWrapper.EnvelopeVoidDate =  MA_DS_DateFormatter.getFormattedDate(acqContact.MA_DS_Envelope_Void_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.WorkLocationCity = acqContact.Office_Address_City__c;
        packageRecipientWrapper.WorkLocationCountry = acqContact.Office_Address_Country__c;
        packageRecipientWrapper.AdditionalField1 = acqContact.Additional_Field_1__c;
        packageRecipientWrapper.AdditionalField2 = acqContact.Additional_Field_2__c;
        packageRecipientWrapper.AdditionalField3 = acqContact.Additional_Field_3__c;
        packageRecipientWrapper.AdditionalField4 = acqContact.Additional_Field_4__c;
        packageRecipientWrapper.AdditionalField5 = acqContact.Additional_Field_5__c;
        packageRecipientWrapper.Age = Integer.valueOf(acqContact.MA_DS_Age__c);
        packageRecipientWrapper.BirthDate = MA_DS_DateFormatter.getFormattedDate(acqContact.Birth_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.BusinessTitleTarget = acqContact.Business_Title_Target__c;
        packageRecipientWrapper.ChangeInControl = String.valueOf(acqContact.Change_in_Control_CiC__c).toUpperCase();
        packageRecipientWrapper.ChangeInControlEndDate = MA_DS_DateFormatter.getFormattedDate(acqContact.CiC_End_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.ContinuousServiceDate = MA_DS_DateFormatter.getFormattedDate(acqContact.Continuous_Service_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.CurrencyCultureCode = acqContact.MA_DS_Currency_Culture_Code__c;
        packageRecipientWrapper.Department = acqContact.Department__c;
        packageRecipientWrapper.EmploymentEndDate = MA_DS_DateFormatter.getFormattedDate(acqContact.Employment_End_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.EntityName = acqContact.Entity_Name__c;
        packageRecipientWrapper.Gender = acqContact.Gender__c;
        packageRecipientWrapper.HireDate = MA_DS_DateFormatter.getFormattedDate(acqContact.Hire_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.HireDateTarget = MA_DS_DateFormatter.getFormattedDate(acqContact.Hire_Date_Target__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.ManagerEmailAddress = acqContact.Manager_Email_Address__c;
        packageRecipientWrapper.MaritalStatus = acqContact.Marital_Status__c;
        packageRecipientWrapper.Nationality = acqContact.Nationality__c;
        packageRecipientWrapper.OfficeAddressStreet = acqContact.Office_Address_Street__c;
        packageRecipientWrapper.OfficeAddressZipPostalCode = acqContact.Office_Address_Zip_Postal_Code__c;
        packageRecipientWrapper.PTOAnnualLeveDays = acqContact.PTO_Annual_Leave_Days__c;
        packageRecipientWrapper.PreferredFirstName = acqContact.First_Name_Preferred__c;
        packageRecipientWrapper.PreferredLastName = acqContact.Last_Name_Preferred__c;
        packageRecipientWrapper.PreferredFullName = acqContact.Full_Name_Preferred__c;
        packageRecipientWrapper.KeyCriticalEmployee = acqContact.Key_Critical_Employee__c;
        packageRecipientWrapper.OfficeAddressStateProvince = acqContact.Office_Address_State_Province__c;
        packageRecipientWrapper.ProbationEndDate = MA_DS_DateFormatter.getFormattedDate(acqContact.Probation_End_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.RemoteNonRemote = acqContact.Remote_Non_Remote__c;
        packageRecipientWrapper.SeveranceWeeks = acqContact.Severance_Weeks__c;
        packageRecipientWrapper.SSNIDNumber = acqContact.SSNID_Number__c;
        packageRecipientWrapper.TermDateTarget = MA_DS_DateFormatter.getFormattedDate(acqContact.Term_Date_Target__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.TransitionalEmployee = String.valueOf(acqContact.Transitional_Employee__c).toUpperCase();
        packageRecipientWrapper.TransitionalEndDate = MA_DS_DateFormatter.getFormattedDate(acqContact.Transitional_End_Date__c, acqContact.Office_Address_Country__c);
        packageRecipientWrapper.TransitionalTimePeriod = acqContact.Transitional_Time_Period__c;
        packageRecipientWrapper.University = acqContact.University__c;
        packageRecipientWrapper.WorkdayLocation = acqContact.Workday_Location__c;
        packageRecipientWrapper.PackageSentDate = MA_DS_DateFormatter.getFormattedDate(Date.today(), acqContact.Office_Address_Country__c);
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Compensation record details in PackageRecipientWrapper wrapper instance.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    packageRecipientWrapper	            DESCRIPTION (Data Type PackageRecipientWrapper, Wrapper instance to wrap Acquisition Contact details)
    * @param    acqCompensation	                    DESCRIPTION (Data Type Acquisition_Compensation__c, Acquisition Compensation record details of the Acquisition Contact)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateWithCompensationInfo(PackageRecipientWrapper packageRecipientWrapper, Acquisition_Compensation__c acqCompensation) {
        packageRecipientWrapper.CompensationRecordId = acqCompensation.Id;
        packageRecipientWrapper.JobGrade = Integer.valueOf(acqCompensation.Job_Grade__c);
        packageRecipientWrapper.AnnualizedBaseSalary = acqCompensation.Annualized_Base_Salary__c;
        packageRecipientWrapper.HourlyPayRate = acqCompensation.Hourly_Rate__c;
        packageRecipientWrapper.BonusPlan = acqCompensation.Bonus_Plan__c;
        packageRecipientWrapper.CurrencyTarget = acqCompensation.Currency_Target__c;
        packageRecipientWrapper.BonusAmount = acqCompensation.Bonus_Amount__c;
        packageRecipientWrapper.CommissionAmount = acqCompensation.Commission_Amount__c;
        packageRecipientWrapper.OnTargetEarnings = acqCompensation.On_Target_Earnings__c;
        packageRecipientWrapper.GrantType = acqCompensation.Grant_Type__c;
        packageRecipientWrapper.EquityUSD = String.valueOf(acqCompensation.Stock_Grant_Amount__c)?.replaceAll(STOCK_GRANT_FORMAT, '$1,');
        packageRecipientWrapper.DrawDuration = acqCompensation.Draw_Duration__c;
        packageRecipientWrapper.DrawAmount = acqCompensation.Draw_Amount__c;
        packageRecipientWrapper.PayRateType = acqCompensation.Pay_Rate_Type__c;
        packageRecipientWrapper.Severance = acqCompensation.Severance_Amount__c;
        packageRecipientWrapper.AdditionalAllowanceAmount = acqCompensation.Additional_Allowance_Amount__c;
        packageRecipientWrapper.AdditionalAllowanceFrequency = acqCompensation.Additional_Allowance_Frequency__c;
        packageRecipientWrapper.AdditionalAllowancePlan = acqCompensation.Additional_Allowance_Plan__c;
        packageRecipientWrapper.CompensationAdditionalField1 = acqCompensation.Additional_Field_1__c;
        packageRecipientWrapper.CompensationAdditionalField2 = acqCompensation.Additional_Field_2__c;
        packageRecipientWrapper.CompensationAdditionalField3 = acqCompensation.Additional_Field_3__c;
        packageRecipientWrapper.CompensationAdditionalField4 = acqCompensation.Additional_Field_4__c;
        packageRecipientWrapper.CompensationAdditionalField5 = acqCompensation.Additional_Field_5__c;
        packageRecipientWrapper.AdditionalOTPAmount = acqCompensation.Additional_OTP_Amount__c;
        packageRecipientWrapper.AdditionalOTPEffectiveDate = MA_DS_DateFormatter.getFormattedDate(acqCompensation.Additional_OTP_Effective_Date__c, packageRecipientWrapper.WorkLocationCountry);
        packageRecipientWrapper.AdditionalOTPPlan = acqCompensation.Additional_OTP_Plan__c;
        packageRecipientWrapper.AdditionalStockGrantAmount = String.valueOf(acqCompensation.Additional_Stock_Grant_Amount__c)?.replaceAll(STOCK_GRANT_FORMAT, '$1,');
        packageRecipientWrapper.AdditionalStockPlan = acqCompensation.Additional_Stock_Plan__c;
        packageRecipientWrapper.CarAllowanceAmount = acqCompensation.Car_Allowance_Amount__c;
        packageRecipientWrapper.CarAllowanceFrequency = acqCompensation.Car_Allowance_Frequency__c;
        packageRecipientWrapper.CarAllowancePlan = acqCompensation.Car_Allowance_Plan__c;
        packageRecipientWrapper.BelgiumMonthlyBaseSalary = acqCompensation.MA_DS_Belgium_Monthly_Base_Salary__c;
        packageRecipientWrapper.BelgiumMonthlyCarAllowance = acqCompensation.MA_DS_Belgium_Monthly_Car_Allowance__c;
        packageRecipientWrapper.BonusTarget = acqCompensation.Bonus_Target__c;
        packageRecipientWrapper.Classification = acqCompensation.Classification__c;
        packageRecipientWrapper.ClassificationTarget = acqCompensation.Classification_Target__c;
        packageRecipientWrapper.CommissionPlan = acqCompensation.Commission_Plan__c;
        packageRecipientWrapper.CurrencyCode = acqCompensation.CurrencyIsoCode;
        packageRecipientWrapper.DrawFrequency = acqCompensation.Draw_Frequency__c;
        packageRecipientWrapper.DrawIsRecoverable = String.valueOf(acqCompensation.Draw_is_Recoverable__c).toUpperCase();
        packageRecipientWrapper.FlextimeEligible = String.valueOf(acqCompensation.Flextime_Eligible__c).toUpperCase();
        packageRecipientWrapper.IndBasicPay = acqCompensation.MA_DS_India_Basic_Pay__c;
        packageRecipientWrapper.IndBasicPayMonthly = acqCompensation.MA_DS_India_Basic_Pay_Monthly__c;
        packageRecipientWrapper.IndCEAllowanceMonthly = acqCompensation.MA_DS_India_CE_Allowance_Monthly__c;
        packageRecipientWrapper.IndCEAllowanceNum = acqCompensation.MA_DS_India_CE_Allowance_Num__c;
        packageRecipientWrapper.IndCostToCompanyMonthly = acqCompensation.MA_DS_India_Cost_To_Company_Monthly__c;
        packageRecipientWrapper.IndDriverSalaryMonthly = acqCompensation.MA_DS_India_Driver_Salary_Monthly__c;
        packageRecipientWrapper.IndDriverSalaryNum = acqCompensation.MA_DS_India_Driver_Salary_Num__c;
        packageRecipientWrapper.IndHRA = acqCompensation.MA_DS_India_House_Rent_Allowance__c;
        packageRecipientWrapper.IndHRAMonthly = acqCompensation.MA_DS_India_House_Rent_Allowance_Monthly__c;
        packageRecipientWrapper.IndIncentiveTarget = acqCompensation.MA_DS_India_Incentive_Target__c;
        packageRecipientWrapper.IndIncentiveTargetMonthly = acqCompensation.MA_DS_India_Incentive_Target_Monthly__c;
        packageRecipientWrapper.IndLeaveTravelAllowanceMonthly = acqCompensation.MA_DS_India_Leave_Travel_Allow_Monthly__c;
        packageRecipientWrapper.IndLeaveTravelAllowance = acqCompensation.MA_DS_India_Leave_Travel_Allowance__c;
        packageRecipientWrapper.IndLeaveTravelAllowanceInput = acqCompensation.MA_DS_India_Leave_Travel_Allowance_Input__c;
        packageRecipientWrapper.IndOtherAllowance = acqCompensation.MA_DS_India_Other_Allowance__c;
        packageRecipientWrapper.IndOtherAllowanceMonthly = acqCompensation.MA_DS_India_Other_Allowance_Monthly__c;
        packageRecipientWrapper.IndPF = acqCompensation.MA_DS_India_Provident_Fund__c;
        packageRecipientWrapper.IndPFMonthly = acqCompensation.MA_DS_India_Provident_Fund_Monthly__c;
        packageRecipientWrapper.IndTelephoneReimburseMonthly = acqCompensation.MA_DS_India_Telephone_Reimburse_Montlhy__c;
        packageRecipientWrapper.IndTelephoneReimburseNum = acqCompensation.MA_DS_India_Telephone_Reimburse_Num__c;
        packageRecipientWrapper.IndVehicleReimburseMonthly = acqCompensation.MA_DS_India_Vehicle_Reimburse_Montlhy__c;
        packageRecipientWrapper.IndVehicleReimburseNum = acqCompensation.MA_DS_India_Vehicle_Reimburse_Num__c;
        packageRecipientWrapper.IsraelBasicPay = acqCompensation.MA_DS_Israel_Basic_Pay__c;
        packageRecipientWrapper.IsraelOTP20Hrs = acqCompensation.MA_DS_Israel_OT_Pay_20_Hrs__c;
        packageRecipientWrapper.IsraelOTP40Hrs = acqCompensation.MA_DS_Israel_OT_Pay_40_Hrs__c;
        packageRecipientWrapper.JapanBasePay = acqCompensation.MA_DS_Japan_Base_Pay__c;
        packageRecipientWrapper.JapanFixedOTAllowance = acqCompensation.MA_DS_Japan_Fixed_OT_Allowance__c;
        packageRecipientWrapper.MonthlyBaseSalary = acqCompensation.MA_DS_Monthly_Base_Salary__c;
        packageRecipientWrapper.OnCallHourly = acqCompensation.On_call_Hourly__c;
        packageRecipientWrapper.OnCallSevenDay = acqCompensation.On_call_Seven_day__c;
        packageRecipientWrapper.OnCallWeekend = acqCompensation.On_call_Weekend__c;
        packageRecipientWrapper.OnCallWorking = String.valueOf(acqCompensation.On_call_Working__c).toUpperCase();
        packageRecipientWrapper.OTPAmount = acqCompensation.One_Time_Payment_Amount__c;
        packageRecipientWrapper.OneTimePaymentPlan = acqCompensation.One_Time_Payment_Plan__c;
        packageRecipientWrapper.Overtime = acqCompensation.Overtime__c;
        packageRecipientWrapper.OvertimeIneligible = String.valueOf(acqCompensation.Overtime_Ineligible__c).toUpperCase();
        packageRecipientWrapper.PeriodSalary = acqCompensation.MA_Period_Salary__c;
        packageRecipientWrapper.PeriodSalaryDurationMonths = Integer.valueOf(acqCompensation.MA_Period_Salary_Duration_Months__c);
        packageRecipientWrapper.ProratedBaseSalary = acqCompensation.Prorated_Base_Salary__c;
        packageRecipientWrapper.ScheduledHours = acqCompensation.Scheduled_Hours__c;
        packageRecipientWrapper.StockGrantDate = MA_DS_DateFormatter.getFormattedDate(acqCompensation.Stock_Grant_Date__c, packageRecipientWrapper.WorkLocationCountry);
        packageRecipientWrapper.TimeType = acqCompensation.Time_Type__c;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap the Applied Rules within AppliedRuleWrapper, and wrapping the List of AppliedRuleWrapper instances within AppliedRulesWrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    appliedRules	                    DESCRIPTION (Data Type List<MA_DS_Applied_Rule__c>, List of Applied Rule records for the Acquisition Contact)
    * @return   AppliedRulesWrapper                 DESCRIPTION (return AppliedRulesWrapper instance)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static AppliedRulesWrapper getAppliedRulesWrapper(List<MA_DS_Applied_Rule__c> appliedRules) {
        List<AppliedRuleWrapper> appliedRuleWrapperList = new List<AppliedRuleWrapper>();

        for(MA_DS_Applied_Rule__c appliedRule : appliedRules) {
            AppliedRuleWrapper appliedRuleWrapper = new AppliedRuleWrapper();
            appliedRuleWrapper.AppliedRuleRecordId = appliedRule.Id;
            appliedRuleWrapper.AppliedRuleName = appliedRule.Name;
            appliedRuleWrapper.PackageDistId = appliedRule.MA_DS_Package_Distribution__c;
            appliedRuleWrapper.TemplateId = appliedRule.MA_DS_Template__c;
            appliedRuleWrapper.SubjectToAudit = String.valueOf(appliedRule.MA_DS_Flagged_For_Audit__c).toUpperCase();
            appliedRuleWrapperList.add(appliedRuleWrapper);
        }

        AppliedRulesWrapper appliedRulesWrapper = new AppliedRulesWrapper();
        appliedRulesWrapper.AppliedRule = appliedRuleWrapperList;

        return appliedRulesWrapper;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of Params attribute of the API payload for the Package Prep process.
    * Holds Acquisition Company details, Package Common Id, along with FirstBatch & FinalBatch flags (API requests) being sent for Package Prep.
    * Wraps instance of PackageRecipientsWrapper.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ParamsWrapper {
        String CompanyName;
        Id CompanyId;
        Id CommonId;
        String FirstBatch;
        String FinalBatch;
        PackageRecipientsWrapper PackageRecipients;
        MA_DS_SalaryFormatter.CurrencyFormatsWrapper CurrencyFormats;
        MA_DS_SalaryFormatter.CurrencyFormattedFieldsWrapper CurrencyFormattedFields;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of PackageRecipientWrapper instances, to wrap it within PackageRecipientsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageRecipientsWrapper {
        List<PackageRecipientWrapper> PackageRecipient;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details (from Acquisition Contact & Acquisition Compensation record) of each Acquisition Contact.
    * Also, holds the AppliedRulesWrapper for each Acquisition Contact.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class PackageRecipientWrapper {
        Id ContactId;
        Id CompensationRecordId;
        String ContactFirstName;
        String ContactLastName;
        String ContactFullName;
        String HomeAddressCity;
        String HomeAddressCommune;
        String HomeAddressCountry;
        String HomeAddressRegion;
        String HomeAddressStateProvince;
        String HomeAddressStreet;
        String HomeAddressStreetArabic;
        String HomeAddressStreetLine2;
        String HomeAddressStreetLine2Arabic;
        String HomeAddressZipPostalCode;
        String ContactAddress;
        String EmployeeIDTarget;
        String ContactEmail;
        String CurrentManager;
        String FutureManager;
        String FutureManagerTitle;
        String EmploymentType;
        String ExemptionStatus;
        String BusinessTitle;
        String BenefitsContinuationWeeks;
        String OutplacementMonths;
        String WorkLocationStatus;
        String EnvelopeVoidDate;
        String WorkLocationCity;
        String WorkLocationCountry;
        String AdditionalField1;
        String AdditionalField2;
        String AdditionalField3;
        String AdditionalField4;
        String AdditionalField5;
        Integer Age;
        String BirthDate;
        String BusinessTitleTarget;
        String ChangeInControl;
        String ChangeInControlEndDate;
        String ContinuousServiceDate;
        String CurrencyCultureCode;
        String Department;
        String EmploymentEndDate;
        String EntityName;
        String Gender;
        String HireDate;
        String HireDateTarget;
        String ManagerEmailAddress;
        String MaritalStatus;
        String Nationality;
        String OfficeAddressStreet;
        String OfficeAddressZipPostalCode;
        String PTOAnnualLeveDays;
        String PreferredFirstName;
        String PreferredLastName;
        String PreferredFullName;
        String KeyCriticalEmployee;
        String OfficeAddressStateProvince;
        String ProbationEndDate;
        String RemoteNonRemote;
        String SeveranceWeeks;
        String SSNIDNumber;
        String TermDateTarget;
        String TransitionalEmployee;
        String TransitionalEndDate;
        String TransitionalTimePeriod;
        String University;
        String WorkdayLocation;
        Integer JobGrade;
        Decimal AnnualizedBaseSalary;
        Decimal HourlyPayRate;
        String BonusPlan;
        String CurrencyTarget;
        Decimal BonusAmount;
        Decimal CommissionAmount;
        Decimal OnTargetEarnings;
        String GrantType;
        String EquityUSD;
        String DrawDuration;
        Decimal DrawAmount;
        String PayRateType;
        Decimal Severance;
        Decimal AdditionalAllowanceAmount;
        String AdditionalAllowanceFrequency;
        String AdditionalAllowancePlan;
        String CompensationAdditionalField1;
        String CompensationAdditionalField2;
        String CompensationAdditionalField3;
        String CompensationAdditionalField4;
        String CompensationAdditionalField5;
        Decimal AdditionalOTPAmount;
        String AdditionalOTPEffectiveDate;
        String AdditionalOTPPlan;
        String AdditionalStockGrantAmount;
        String AdditionalStockPlan;
        Decimal CarAllowanceAmount;
        String CarAllowanceFrequency;
        String CarAllowancePlan;
        Decimal BelgiumMonthlyBaseSalary;
        Decimal BelgiumMonthlyCarAllowance;
        Decimal BonusTarget;
        String Classification;
        String ClassificationTarget;
        String CommissionPlan;
        String CurrencyCode;
        String DrawFrequency;
        String DrawIsRecoverable;
        String FlextimeEligible;
        Decimal IndBasicPay;
        Decimal IndBasicPayMonthly;
        Decimal IndCEAllowanceMonthly;
        Decimal IndCEAllowanceNum;
        Decimal IndCostToCompanyMonthly;
        Decimal IndDriverSalaryMonthly;
        Decimal IndDriverSalaryNum;
        Decimal IndHRA;
        Decimal IndHRAMonthly;
        Decimal IndIncentiveTarget;
        Decimal IndIncentiveTargetMonthly;
        Decimal IndLeaveTravelAllowanceMonthly;
        Decimal IndLeaveTravelAllowance;
        Decimal IndLeaveTravelAllowanceInput;
        Decimal IndOtherAllowance;
        Decimal IndOtherAllowanceMonthly;
        Decimal IndPF;
        Decimal IndPFMonthly;
        Decimal IndTelephoneReimburseMonthly;
        Decimal IndTelephoneReimburseNum;
        Decimal IndVehicleReimburseMonthly;
        Decimal IndVehicleReimburseNum;
        Decimal IsraelBasicPay;
        Decimal IsraelOTP20Hrs;
        Decimal IsraelOTP40Hrs;
        Decimal JapanBasePay;
        Decimal JapanFixedOTAllowance;
        Decimal MonthlyBaseSalary;
        Decimal OnCallHourly;
        Decimal OnCallSevenDay;
        Decimal OnCallWeekend;
        String OnCallWorking;
        Decimal OTPAmount;
        String OneTimePaymentPlan;
        Decimal Overtime;
        String OvertimeIneligible;
        Decimal PeriodSalary;
        Integer PeriodSalaryDurationMonths;
        Decimal ProratedBaseSalary;
        Decimal ScheduledHours;
        String StockGrantDate;
        String TimeType;
        String PackageSentDate;
        AppliedRulesWrapper AppliedRules;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of AppliedRuleWrapper instances, to wrap it within AppliedRulesWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AppliedRulesWrapper {
        List<AppliedRuleWrapper> AppliedRule;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the Applied Rule details of each Acquisition Contact.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class AppliedRuleWrapper {
        Id AppliedRuleRecordId;
        String AppliedRuleName;
        Id PackageDistId;
        Id TemplateId;
        String SubjectToAudit;
    }
}