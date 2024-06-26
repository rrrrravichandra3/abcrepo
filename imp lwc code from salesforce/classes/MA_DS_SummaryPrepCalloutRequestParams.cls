/**
 * W-12578116
 * Extends MA_DS_AbstractCalloutRequestParams class to Serialize value of Params attribute for the Manager Summary Prep API callout.
 * 
 * Version      Date            Author                  Description
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         30/03/2023      Chakshu Malhotra        W-12578116 - Adds logic to convert MA_DS_ManagerSummaryPrepWrapper.ManagerSummaryPrepParams to an accepted format of Manager Summary Prep API callout.
 * ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public without sharing class MA_DS_SummaryPrepCalloutRequestParams extends MA_DS_AbstractCalloutRequestParams {
    
    private static final String STOCK_GRANT_FORMAT = Label.MA_DS_Stock_Grant_Format;
    private static final String CURRENCY_FORMATTED_FIELDS_STR = Label.MA_DS_Summary_Prep_Currency_Fields;
    private static Set<String> officeAddressCountries {get; set;}

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to convert the requestParams & wrap it in a ParamsWrapper instance, as per the accepted Payload format for the Manager Summary Prep API Request.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    requestParams	    DESCRIPTION (Data Type MA_DS_CalloutFramework.RequestParams, RequestParams type Params that need to be added in the API callout payload)
    * @return   void
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public override void deserializeParams(MA_DS_CalloutFramework.RequestParams requestParams) {
        this.requestParams = requestParams;
        MA_DS_ManagerSummaryPrepWrapper.ManagerSummaryPrepParams summaryPrepParams = (MA_DS_ManagerSummaryPrepWrapper.ManagerSummaryPrepParams)requestParams;

        ParamsWrapper wrapperInstance = new ParamsWrapper();
        wrapperInstance.CompanyName = summaryPrepParams.acqCompanyName;
        wrapperInstance.CompanyId = summaryPrepParams.acqCompanyId;
        wrapperInstance.CommonId = summaryPrepParams.commonId;
        wrapperInstance.TotalBatches = summaryPrepParams.totalBatches;
        wrapperInstance.CurrentBatchNumber = summaryPrepParams.currentBatchNumber;
        wrapperInstance.OfferCommunicators = getOfferCommunicatorsWrapper(summaryPrepParams.summaryTemplateId, summaryPrepParams.primaryPDIds, summaryPrepParams.offerCommunicator, summaryPrepParams.summarizedContacts);
        wrapperInstance.CurrencyFormattedFields = MA_DS_SalaryFormatter.getCurrencyFormattedFieldsWrapper(CURRENCY_FORMATTED_FIELDS_STR);
        wrapperInstance.CurrencyFormats = MA_DS_SalaryFormatter.getCurrencyFormatsWrapper(officeAddressCountries);
        super.deserializedParams = JSON.deserializeUntyped(JSON.serialize(wrapperInstance));
    }

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to wrap List of OfferCommunicatorWrapper instances within OfferCommunicatorsWrapper instance, based on the details in "requestParams".
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryTemplateId	                DESCRIPTION (Data Type Id, Manager Summary Template Id, used by CLM to merge data in Manager Summary reports)
    * @param    primaryPDIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    offerCommunicator	                DESCRIPTION (Data Type Acquisition_Contacts__c, Offer Communicator details as per Acquisition Contact record)
    * @param    summarizedContacts	                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of summarized Acquisition Contacts for the Offer Communicator)
    * @return   OfferCommunicatorsWrapper           DESCRIPTION (return OfferCommunicatorsWrapper instance)
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static OfferCommunicatorsWrapper getOfferCommunicatorsWrapper(Id summaryTemplateId, Set<Id> primaryPDIds, Acquisition_Contacts__c offerCommunicator, List<Acquisition_Contacts__c> summarizedContacts) {
        OfferCommunicatorsWrapper offerCommunicatorsWrapper = new OfferCommunicatorsWrapper();
        offerCommunicatorsWrapper.OfferCommunicator = getOfferCommunicatorWrapperList(summaryTemplateId, primaryPDIds, offerCommunicator, summarizedContacts);
        return offerCommunicatorsWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & wrap OfferCommunicatorWrapper details in the List of OfferCommunicatorWrapper instance, based on the details in "requestParams".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summaryTemplateId	                DESCRIPTION (Data Type Id, Manager Summary Template Id, used by CLM to merge data in Manager Summary reports)
    * @param    primaryPDIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    offerCommunicator	                DESCRIPTION (Data Type Acquisition_Contacts__c, Offer Communicator details as per Acquisition Contact record)
    * @param    summarizedContacts	                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of summarized Acquisition Contacts for the Offer Communicator)
    * @return   List<OfferCommunicatorWrapper>      DESCRIPTION (return List of OfferCommunicatorWrapper instances)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<OfferCommunicatorWrapper> getOfferCommunicatorWrapperList(Id summaryTemplateId, Set<Id> primaryPDIds, Acquisition_Contacts__c offerCommunicator, List<Acquisition_Contacts__c> summarizedContacts) {
        OfferCommunicatorWrapper offerCommunicatorWrapper = new OfferCommunicatorWrapper();
        offerCommunicatorWrapper.SummarizedContacts = getSummarizedContactsWrapper(primaryPDIds, summarizedContacts);
        offerCommunicatorWrapper.OfferCommunicatorId = offerCommunicator.Id;
        offerCommunicatorWrapper.OfferCommunicatorFirstName = offerCommunicator.First_Name_Legal__c;
        offerCommunicatorWrapper.OfferCommunicatorLastName = offerCommunicator.Last_Name_Legal__c;
        offerCommunicatorWrapper.OfferCommunicatorFullName = offerCommunicator.Name;
        offerCommunicatorWrapper.OfferCommunicatorEmail = offerCommunicator.MA_DS_Preferred_Email_Address__c;
        offerCommunicatorWrapper.EmployeeIDTarget = offerCommunicator.Employee_ID_Target__c;
        offerCommunicatorWrapper.ManagerSummaryTemplateId = summaryTemplateId;
        offerCommunicatorWrapper.SubjectToAudit = String.valueOf(offerCommunicatorWrapper.SummarizedContacts.subjectToAudit).toUpperCase();
        return new List<OfferCommunicatorWrapper> {offerCommunicatorWrapper};
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to add a List of SummarizedContactWrapper instances to a SummarizedContactsWrapper instance, based on the "requestParams".
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    primaryPDIds	                DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    summarizedContacts	            DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of Acquisition Contact record details for the summarized contacts)
    * @return   SummarizedContactsWrapper       DESCRIPTION (return the SummarizedContactsWrapper instance)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static SummarizedContactsWrapper getSummarizedContactsWrapper(Set<Id> primaryPDIds, List<Acquisition_Contacts__c> summarizedContacts) {
        SummarizedContactsWrapper summarizedContactsWrapper = new SummarizedContactsWrapper();
        summarizedContactsWrapper.SummarizedContact = getSummarizedContactWrapperList(primaryPDIds, summarizedContacts, summarizedContactsWrapper);
        return summarizedContactsWrapper;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create & get a List of SummarizedContactWrapper instances, based on the summarized contact details in "requestParams".
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    primaryPDIds	                    DESCRIPTION (Data Type Set<Id>, Set of Package Distribution Ids to process them for Manager Summary Prep or Regeneration)
    * @param    summarizedContacts	                DESCRIPTION (Data Type List<Acquisition_Contacts__c>, List of summarized Acquisition Contacts for the Offer Communicator)
    * @param    summarizedContactsWrapper	        DESCRIPTION (Data Type SummarizedContactsWrapper, SummarizedContactsWrapper instance)
    * @return   List<SummarizedContactWrapper>      DESCRIPTION (return List of wrapper instances of SummarizedContactWrapper)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static List<SummarizedContactWrapper> getSummarizedContactWrapperList(Set<Id> primaryPDIds, List<Acquisition_Contacts__c> summarizedContacts, SummarizedContactsWrapper summarizedContactsWrapper) {
        List<SummarizedContactWrapper> summarizedContactWrapperList = new List<SummarizedContactWrapper>();
        officeAddressCountries = new Set<String>();

        for(Acquisition_Contacts__c summarizedContact : summarizedContacts) {
            SummarizedContactWrapper summarizedContactWrapper = new SummarizedContactWrapper();
            updateWithContactInfo(summarizedContactWrapper, summarizedContact);
            
            if(summarizedContact.Acquisition_Compensation__r != null && summarizedContact.Acquisition_Compensation__r.size() > 0) {
                updateWithCompensationInfo(summarizedContactWrapper, summarizedContact.Acquisition_Compensation__r[0]);
            }

            if(summarizedContact.MA_DS_Applied_Rules__r != null && summarizedContact.MA_DS_Applied_Rules__r.size() > 0) {
                summarizedContactsWrapper.subjectToAudit = summarizedContactsWrapper.subjectToAudit || summarizedContact.MA_DS_Applied_Rules__r[0].MA_DS_Flagged_For_Audit__c;
                summarizedContactWrapper.PackageDistId = summarizedContact.MA_DS_Applied_Rules__r[0].MA_DS_Package_Distribution__c;
                Boolean isPrimaryDistributionId = primaryPDIds.contains(summarizedContactWrapper.PackageDistId);
                summarizedContactWrapper.IsPrimaryDist = String.valueOf(isPrimaryDistributionId).toUpperCase();
            }

            summarizedContactWrapperList.add(summarizedContactWrapper);

            if(String.isNotBlank(summarizedContact.Office_Address_Country__c)) {
                officeAddressCountries.add(summarizedContact.Office_Address_Country__c);
            }
        }

        return summarizedContactWrapperList;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Contact record details in SummarizedContactWrapper wrapper instance.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summarizedContactWrapper	        DESCRIPTION (Data Type SummarizedContactWrapper, Wrapper instance to wrap Summarized Contact details)
    * @param    summarizedContact	                DESCRIPTION (Data Type Acquisition_Contacts__c, Acquisition Contact record details of the Summarized Contact)
    * @return   void
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateWithContactInfo(SummarizedContactWrapper summarizedContactWrapper, Acquisition_Contacts__c summarizedContact) {
        summarizedContactWrapper.ContactId = summarizedContact.Id;
        summarizedContactWrapper.CurrentManager = summarizedContact.Manager_Name_Target__r?.Name;
        summarizedContactWrapper.FutureManager = summarizedContact.Manager_Name__r?.Name;
        summarizedContactWrapper.EmployeeFirstName = summarizedContact.First_Name_Legal__c;
        summarizedContactWrapper.EmployeeLastName = summarizedContact.Last_Name_Legal__c;
        summarizedContactWrapper.EmploymentType = summarizedContact.Employee_Type__c;
        summarizedContactWrapper.BusinessTitle = summarizedContact.Business_Title__c;
        summarizedContactWrapper.AdditionalField1 = summarizedContact.Additional_Field_1__c;
        summarizedContactWrapper.AdditionalField2 = summarizedContact.Additional_Field_2__c;
        summarizedContactWrapper.AdditionalField3 = summarizedContact.Additional_Field_3__c;
        summarizedContactWrapper.AdditionalField4 = summarizedContact.Additional_Field_4__c;
        summarizedContactWrapper.AdditionalField5 = summarizedContact.Additional_Field_5__c;
        summarizedContactWrapper.BusinessTitleTarget = summarizedContact.Business_Title_Target__c;
        summarizedContactWrapper.ChangeInControl = String.valueOf(summarizedContact.Change_in_Control_CiC__c).toUpperCase();
        summarizedContactWrapper.ChangeInControlEndDate =  MA_DS_DateFormatter.getFormattedDate(summarizedContact.CiC_End_Date__c, summarizedContact.Office_Address_Country__c);
        summarizedContactWrapper.ContinuousServiceDate =  MA_DS_DateFormatter.getFormattedDate(summarizedContact.Continuous_Service_Date__c, summarizedContact.Office_Address_Country__c);
        summarizedContactWrapper.CurrencyCultureCode = summarizedContact.MA_DS_Currency_Culture_Code__c;
        summarizedContactWrapper.Department = summarizedContact.Department__c;
        summarizedContactWrapper.EmploymentEndDate =  MA_DS_DateFormatter.getFormattedDate(summarizedContact.Employment_End_Date__c, summarizedContact.Office_Address_Country__c);
        summarizedContactWrapper.PreferredFirstName = summarizedContact.First_Name_Preferred__c;
        summarizedContactWrapper.PreferredLastName = summarizedContact.Last_Name_Preferred__c;
        summarizedContactWrapper.PreferredFullName = summarizedContact.Full_Name_Preferred__c;
        summarizedContactWrapper.KeyCriticalEmployee = summarizedContact.Key_Critical_Employee__c;
        summarizedContactWrapper.OfficeAddressCity = summarizedContact.Office_Address_City__c;
        summarizedContactWrapper.OfficeAddressStateProvince = summarizedContact.Office_Address_State_Province__c;
        summarizedContactWrapper.ProbationEndDate = MA_DS_DateFormatter.getFormattedDate(summarizedContact.Probation_End_Date__c, summarizedContact.Office_Address_Country__c);
        summarizedContactWrapper.RemoteNonRemote = summarizedContact.Remote_Non_Remote__c;
        summarizedContactWrapper.SeveranceWeeks = summarizedContact.Severance_Weeks__c;
        summarizedContactWrapper.TransitionalEmployee = String.valueOf(summarizedContact.Transitional_Employee__c).toUpperCase();
        summarizedContactWrapper.TransitionalEndDate = MA_DS_DateFormatter.getFormattedDate(summarizedContact.Transitional_End_Date__c, summarizedContact.Office_Address_Country__c);
        summarizedContactWrapper.TransitionalTimePeriod = summarizedContact.Transitional_Time_Period__c;
        summarizedContactWrapper.WorkLocationStatus = summarizedContact.Work_Location_Status__c;
        summarizedContactWrapper.WorkdayLocation = summarizedContact.Workday_Location__c;
        summarizedContactWrapper.EmployeeIdTarget = summarizedContact.Employee_ID_Target__c;
        summarizedContactWrapper.BenefitsContinuationWeeks = summarizedContact.COBRA_Months__c;
        summarizedContactWrapper.OutplacementMonths = summarizedContact.Outplacement_Months__c;
        summarizedContactWrapper.WorkLocationCountry = summarizedContact.Office_Address_Country__c;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to update Acquisition Compensation record details in SummarizedContactWrapper wrapper instance.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    summarizedContactWrapper	        DESCRIPTION (Data Type SummarizedContactWrapper, Wrapper instance to wrap Summarized Contact details)
    * @param    acqCompensation	                    DESCRIPTION (Data Type Acquisition_Compensation__c, Acquisition Compensation record details of the Summarized Contact)
    * @return   void
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static void updateWithCompensationInfo(SummarizedContactWrapper summarizedContactWrapper, Acquisition_Compensation__c acqCompensation) {
        summarizedContactWrapper.JobGrade = Integer.valueOf(acqCompensation.Job_Grade__c);
        summarizedContactWrapper.AnnualizedBaseSalary = acqCompensation.Annualized_Base_Salary__c;
        summarizedContactWrapper.CurrencyTarget = acqCompensation.Currency_Target__c;
        summarizedContactWrapper.CurrencyCode = acqCompensation.CurrencyISOCode;
        summarizedContactWrapper.BonusAmount = acqCompensation.Bonus_Amount__c;
        summarizedContactWrapper.CommissionAmount = acqCompensation.Commission_Amount__c;
        summarizedContactWrapper.OnTargetEarnings = acqCompensation.On_Target_Earnings__c;
        summarizedContactWrapper.EquityUSD = String.valueOf(acqCompensation.Stock_Grant_Amount__c)?.replaceAll(STOCK_GRANT_FORMAT, '$1,');
        summarizedContactWrapper.Severance = acqCompensation.Severance_Amount__c;
        summarizedContactWrapper.AdditionalAllowanceAmount = acqCompensation.Additional_Allowance_Amount__c;
        summarizedContactWrapper.AdditionalAllowanceFrequency = acqCompensation.Additional_Allowance_Frequency__c;
        summarizedContactWrapper.AdditionalAllowancePlan = acqCompensation.Additional_Allowance_Plan__c;
        summarizedContactWrapper.CompensationAdditionalField1 = acqCompensation.Additional_Field_1__c;
        summarizedContactWrapper.CompensationAdditionalField2 = acqCompensation.Additional_Field_2__c;
        summarizedContactWrapper.CompensationAdditionalField3 = acqCompensation.Additional_Field_3__c;
        summarizedContactWrapper.CompensationAdditionalField4 = acqCompensation.Additional_Field_4__c;
        summarizedContactWrapper.CompensationAdditionalField5 = acqCompensation.Additional_Field_5__c;
        summarizedContactWrapper.AdditionalOTPAmount = acqCompensation.Additional_OTP_Amount__c;
        summarizedContactWrapper.AdditionalOTPEffectiveDate = MA_DS_DateFormatter.getFormattedDate(acqCompensation.Additional_OTP_Effective_Date__c, summarizedContactWrapper.WorkLocationCountry);
        summarizedContactWrapper.AdditionalOTPPlan = acqCompensation.Additional_OTP_Plan__c;
        summarizedContactWrapper.AdditionalStockGrantAmount = String.valueOf(acqCompensation.Additional_Stock_Grant_Amount__c)?.replaceAll(STOCK_GRANT_FORMAT, '$1,');
        summarizedContactWrapper.AdditionalStockPlan = acqCompensation.Additional_Stock_Plan__c;
        summarizedContactWrapper.CarAllowanceAmount = acqCompensation.Car_Allowance_Amount__c;
        summarizedContactWrapper.CarAllowanceFrequency = acqCompensation.Car_Allowance_Frequency__c;
        summarizedContactWrapper.CarAllowancePlan = acqCompensation.Car_Allowance_Plan__c;
        summarizedContactWrapper.BelgiumMonthlyBaseSalary = acqCompensation.MA_DS_Belgium_Monthly_Base_Salary__c;
        summarizedContactWrapper.BelgiumMonthlyCarAllowance = acqCompensation.MA_DS_Belgium_Monthly_Car_Allowance__c;
        summarizedContactWrapper.BonusPlan = acqCompensation.Bonus_Plan__c;
        summarizedContactWrapper.BonusTarget = acqCompensation.Bonus_Target__c;
        summarizedContactWrapper.Coefficient = acqCompensation.Coefficient__c;
        summarizedContactWrapper.Classification = acqCompensation.Classification__c;
        summarizedContactWrapper.ClassificationTarget = acqCompensation.Classification_Target__c;
        summarizedContactWrapper.CommissionPlan = acqCompensation.Commission_Plan__c;
        summarizedContactWrapper.DrawAmount = acqCompensation.Draw_Amount__c;
        summarizedContactWrapper.DrawDuration = acqCompensation.Draw_Duration__c;
        summarizedContactWrapper.DrawFrequency = acqCompensation.Draw_Frequency__c;
        summarizedContactWrapper.DrawIsRecoverable = String.valueOf(acqCompensation.Draw_is_Recoverable__c).toUpperCase();
        summarizedContactWrapper.FlextimeEligible = String.valueOf(acqCompensation.Flextime_Eligible__c).toUpperCase();
        summarizedContactWrapper.GrantType = acqCompensation.Grant_Type__c;
        summarizedContactWrapper.HourlyRate = acqCompensation.Hourly_Rate__c;
        summarizedContactWrapper.MonthlyBaseSalary = acqCompensation.MA_DS_Monthly_Base_Salary__c;
        summarizedContactWrapper.OnCallHourly = acqCompensation.On_call_Hourly__c;
        summarizedContactWrapper.OnCallSevenDay = acqCompensation.On_call_Seven_day__c;
        summarizedContactWrapper.OnCallWeekend = acqCompensation.On_call_Weekend__c;
        summarizedContactWrapper.OnCallWorking = String.valueOf(acqCompensation.On_call_Working__c).toUpperCase();
        summarizedContactWrapper.OneTimePaymentAmount = acqCompensation.One_Time_Payment_Amount__c;
        summarizedContactWrapper.OneTimePaymentPlan = acqCompensation.One_Time_Payment_Plan__c;
        summarizedContactWrapper.Overtime = acqCompensation.Overtime__c;
        summarizedContactWrapper.OvertimeIneligible = String.valueOf(acqCompensation.Overtime_Ineligible__c).toUpperCase();
        summarizedContactWrapper.ExemptionStatus = acqCompensation.Pay_Rate_Type__c;
        summarizedContactWrapper.PeriodSalary = acqCompensation.MA_Period_Salary__c;
        summarizedContactWrapper.PeriodSalaryDurationMonths = Integer.valueOf(acqCompensation.MA_Period_Salary_Duration_Months__c);
        summarizedContactWrapper.ProratedBaseSalary = acqCompensation.Prorated_Base_Salary__c;
        summarizedContactWrapper.ScheduledHours = acqCompensation.Scheduled_Hours__c;
        summarizedContactWrapper.StockGrantDate = MA_DS_DateFormatter.getFormattedDate(acqCompensation.Stock_Grant_Date__c, summarizedContactWrapper.WorkLocationCountry);
        summarizedContactWrapper.TimeType = acqCompensation.Time_Type__c;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold details of Params attribute of the API payload for the Manager Summary Prep process.
    * Holds Acquisition Company details, Manager Summary Common Id, along with Total Batches (API requests) being sent for Manager Summary Prep.
    * Wraps instance of OfferCommunicatorsWrapper, MA_DS_SalaryFormatter.CurrencyFormatsWrapper & MA_DS_SalaryFormatter.CurrencyFormattedFieldsWrapper.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class ParamsWrapper {
        String CompanyName;
        Id CompanyId;
        Id CommonId;
        Integer TotalBatches;
        Integer CurrentBatchNumber;
        OfferCommunicatorsWrapper OfferCommunicators;
        MA_DS_SalaryFormatter.CurrencyFormatsWrapper CurrencyFormats;
        MA_DS_SalaryFormatter.CurrencyFormattedFieldsWrapper CurrencyFormattedFields;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of OfferCommunicatorWrapper instances, to wrap it within OfferCommunicatorsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class OfferCommunicatorsWrapper {
        List<OfferCommunicatorWrapper> OfferCommunicator;
    }

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details (from Acquisition Contact record) of Offer Communicator, along with SummarizedContactsWrapper instance.
    * Flags "SubjectToAudit" to true if atleast one of the Summarized Contact's Applied Rule record is Flagged For Audit.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class OfferCommunicatorWrapper {
        String SubjectToAudit;
        Id OfferCommunicatorId;
        String OfferCommunicatorFirstName;
        String OfferCommunicatorLastName;
        String OfferCommunicatorFullName;
        String OfferCommunicatorEmail;
        String EmployeeIDTarget;
        Id ManagerSummaryTemplateId;
        SummarizedContactsWrapper SummarizedContacts;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the List of SummarizedContactWrapper instances, to wrap it within SummarizedContactsWrapper node.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class SummarizedContactsWrapper {
        List<SummarizedContactWrapper> SummarizedContact;
        transient Boolean subjectToAudit = false;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Wrapper class to hold the details (from Acquisition Contact & Acquisition Compensation record) of each Summarized Contact.
    * Also, holds the Package Distribution to which the Summarized Contact belongs to.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private class SummarizedContactWrapper {
        Id ContactId;
        String CurrentManager;
        String FutureManager;
        String EmployeeFirstName;
        String EmployeeLastName;
        String EmploymentType;
        String BusinessTitle;
        String AdditionalField1;
        String AdditionalField2;
        String AdditionalField3;
        String AdditionalField4;
        String AdditionalField5;
        String BusinessTitleTarget;
        String ChangeInControl;
        String ChangeInControlEndDate;
        String ContinuousServiceDate;
        String CurrencyCultureCode;
        String Department;
        String EmploymentEndDate;
        String PreferredFirstName;
        String PreferredLastName;
        String PreferredFullName;
        String KeyCriticalEmployee;
        String OfficeAddressCity;
        String OfficeAddressStateProvince;
        String ProbationEndDate;
        String RemoteNonRemote;
        String SeveranceWeeks;
        String TransitionalEmployee;
        String TransitionalEndDate;
        String TransitionalTimePeriod;
        String WorkLocationStatus;
        String WorkdayLocation;
        String EmployeeIdTarget;
        String BenefitsContinuationWeeks;
        String OutplacementMonths;
        Integer JobGrade;
        Decimal AnnualizedBaseSalary;
        String CurrencyTarget;
        String CurrencyCode;
        Decimal BonusAmount;
        Decimal CommissionAmount;
        Decimal OnTargetEarnings;
        String EquityUSD;
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
        String BonusPlan;
        Decimal BonusTarget;
        String Coefficient;
        String Classification;
        String ClassificationTarget;
        String CommissionPlan;
        Decimal DrawAmount;
        String DrawDuration;
        String DrawFrequency;
        String DrawIsRecoverable;
        String FlextimeEligible;
        String GrantType;
        Decimal HourlyRate;
        Decimal MonthlyBaseSalary;
        Decimal OnCallHourly;
        Decimal OnCallSevenDay;
        Decimal OnCallWeekend;
        String OnCallWorking;
        Decimal OneTimePaymentAmount;
        String OneTimePaymentPlan;
        Decimal Overtime;
        String OvertimeIneligible;
        String ExemptionStatus;
        Decimal PeriodSalary;
        Integer PeriodSalaryDurationMonths;
        Decimal ProratedBaseSalary;
        Decimal ScheduledHours;
        String StockGrantDate;
        String TimeType;
        Id PackageDistId;
        String IsPrimaryDist;
        String WorkLocationCountry;
    }
}