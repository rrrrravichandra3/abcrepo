/* This is the Domain Model class for the New Hire Wizard */
//This class currently hosts data flowing from upstream.
public with sharing class NHWRecruitmentModel {
    
    public NHWModelType modelType{get; private set;}

    Public Id ModelId{get;set;}

    Public Id EmployeeContactId{get;set;}
    Public Id CompanyId{get;set;}
    Public Id BusinessSiteId{get;set;}
    Public Id ManagerContactId{get;set;}


    Public string OfferType{get;set;}
    Public string SFWorkEmailAddress{get;set;}
    Public string ResourceType{get;set;}
    Public string EmployeeNumber{get;set;}
    Public string EmployeeName{get;set;}   
    Public string FirstName{get;set;}
    Public string LastName{get;set;}
    Public string CompanyAgencyName{get;set;}
    Public string PrimaryCoverageCountry{get;set;}
    Public string JobStatus{get;set;} 
    Public string BusinessTitle{get;set;}
    Public string BusinessUnitName{get;set;}
    Public string CostCenterName{get;set;}
    Public string BusinessUnitId{get;set;} 
    Public string CostCenterId{get;set;}
    Public Date   StartDate{get;set;}
    Public Boolean isRemote{get;set;}
    Public Date EndDate{get;set;}
    Public string OfficeAddress{get;set;}
    Public string OfficeCity{get;set;}
    Public string OfficeStateProvince{get;set;}
    Public string OfficeZipPostalCode{get;set;}
    Public string OfficeCountry{get;set;}

    Public string PersonalEmail{get;set;}
    Public string Manager_s_Email{get;set;}
    Public string supportforceEmail{get;set;}
    Public string HiringManagerName{get;set;}
    Public string ReqCreationReason{get;set;}

    public string Region{get;set;}

    Public list<case> preboardingCases = new list<case>();
    Public list<case> provisioningCases = new list<case>();
    
    public NHWRecruitmentModel(NHWModelType modelType){
        this.modelType = modelType;
    }
}