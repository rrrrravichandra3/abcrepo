/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author: release $
 * $Change: 8269191 $
 * $DateTime: 2013/10/04 16:05:59 $
 * $File: //it/applications/supportforce/termination/main/sfdc/src/classes/TermCaseValidationHandler.cls $
 * $Id: //it/applications/supportforce/termination/main/sfdc/src/classes/TermCaseValidationHandler.cls#30 $
 * $Revision: #30 $
 */

public with sharing class NHWWrapper
{
    public class HelpTextWrapper
    {
        public String name {get; set;}
        public String description {get; set;}
        
        public HelpTextWrapper(String n, String d)
        {
            name = n;
            description = d;
        }
    }
    
    public class EmployeeWrapper
    {
        public NHWRecruitmentModel RecruitmentModelObject {get; set;}
        public Case onboardCase {get; set;}
        public Boolean isEmployee {get; set;}
        public Boolean isETEmployee {get; set;}
        public Boolean isETContractor {get; set;}
        public Integer maxPage
        {
            get
            {
                if (isEmployee)
                {
                    return 4;
                }
                return 3;
            }
            set;
        }
        public Boolean hasNoCase {
            get {
                if (onboardCase == null || onboardCase.Id == null) {
                    return true;
                }
                return false;
            }
            set;
        }
        public EmployeeWrapper(NHWRecruitmentModel modelobject)
        {
            isETEmployee = false;
            isETContractor = false;
            RecruitmentModelObject = modelobject;
            onboardCase = new Case();
            isEmployee = true;
            Map<String,NHW_Exact_Target_BU__c> BUMap = new Map<String,NHW_Exact_Target_BU__c >(); 
            List<NHW_Exact_Target_BU__c> buList = NHW_Exact_Target_BU__c.getall().values(); 
            for(NHW_Exact_Target_BU__c n:buList){
                if(n.Business_Unit__c != null){
                    BUMap.put(n.Business_Unit__c,n);      
                }
            }
            system.debug(LOGGINGLEVEL.INFO,'********BUMAp ' + BUMap);
            system.debug(LOGGINGLEVEL.INFO,RecruitmentModelObject.BusinessUnitName);
            if(RecruitmentModelObject.BusinessUnitName != null && BUMap.containsKey(RecruitmentModelObject.BusinessUnitName)){
                isETEmployee = true; 
                onboardCase.NH_Is_Exact_Target__c = true;
            }
            system.debug(LOGGINGLEVEL.INFO,'******isETEmployee ' + isETEmployee);
        }        

        public EmployeeWrapper(Case c)
        {
            isETEmployee = false;
            onboardCase = c;
            isEmployee = false;
            system.debug('****** inside nhwWrapper.employeewrapper and case is ' + c.NH_Is_Exact_target__c);
            if (c.NHW_Employee_Type__c == 'Regular Employee') {
                isEmployee = true;
            }
            if((c.NHW_Employee_Type__c == 'Regular Employee' || c.NHW_Employee_Type__c == 'Relocation') && c.NH_Is_Exact_Target__c != null && c.NH_Is_Exact_Target__c){
                isETEmployee = true;
            }
            if(c.NHW_Employee_Type__c == 'Contractor' && c.NH_Is_Exact_Target__c){
                isETContractor = true;
            }
        }
        
        public PageReference selectEmployee()
        {
            PageReference pageRef; // = Page.NewHireWizard_1_0; //Commented because of dependency. If dependency occuers cant able delete NewHireWizard_1_0 Page.
            if (onboardCase != null && onboardCase.Id != null)
            {
                pageRef.getParameters().put('caseId', onboardCase.Id);
            }
            else
            {
                pageRef.getParameters().put('placementId', RecruitmentModelObject.ModelId);
            }
            system.debug('*****got pagereference in selectEmployee');
            pageRef.setRedirect(true);
            return pageRef;
        }
    }
    
    public class OnboardingWrapper {
    public list<NHW_AccessWrapper> accessList           {get; set;}
    public String accessType                        {get; set;}
    public String selectedAccess                    {get; set;}
    public Boolean getIsOpenAirSelected             {get; set;}
    public Boolean isListEmpty {
        get {
        return getRemainingAccess().isEmpty();
        }
        private set;
    }
    public Boolean hasSelected {
        get {
            for (NHW_AccessWrapper aw : accessList) {
                if (aw.selected) {
                    return true;
                }
            }
            return false;
        }
        private set;
    }
    public list<NHW_AccessWrapper> selectedAccessList {
        get {
            list<NHW_AccessWrapper> resultList = new list<NHW_AccessWrapper>();
            
            for (NHW_AccessWrapper aw : accessList) {
                if (aw.selected || aw.item.Auto_Display__c) {
                    resultList.add(aw);
                }
            }
            return resultList;
        } 
        set;
    }
    
    public OnboardingWrapper(String a) {
        accessType = a;
        accessList = new list<NHW_AccessWrapper>();
    }
    
    public void addAccess() {
        for (NHW_AccessWrapper aw : accessList) {
        if (selectedAccess == aw.item.Name) {
            aw.selected = true;
            system.debug('******adding Access ' + aw.item.Name + ' aw.OpenAirSelected ' + aw.OpenAirSelected);
            if (aw.item.Name == 'PSE') {
                IsOpenAirSelected = true;
                aw.OpenAirSelected = true;     
            }
            
            system.debug('******adding Access ' + aw.item.Name + ' aw.OpenAirSelected ' + aw.OpenAirSelected);
            break;
        }
        }
    }
    
    public list<SelectOption> getRemainingAccess() {
        list<SelectOption> resultList = new list<SelectOption>();
        list<String> nameList = new list<String>();
        
        for (NHW_AccessWrapper aw : accessList) {
        if (!aw.selected) {
            nameList.add(aw.item.Name);
        }
        }
        
        nameList.sort();
        
        for (String s : nameList) {
            resultList.add(new SelectOption(s, s));
        }
        
        return resultList;      
    }
    
    
    public boolean IsOpenAirSelected {
      get {  
        list<SelectOption> resultList = new list<SelectOption>();
        list<String> nameList = new list<String>();
        
        for (NHW_AccessWrapper aw : selectedAccessList) {
        if (aw.item.Name == 'PSE' && aw.selected) {
            system.debug('***** returning true for getIsOpenAirSelected');
            return true;
        }
        }
        system.debug('***** returning false for getIsOpenAirSelected');
        return false;
    } set; 
    }
    
    }
    
    
    
    public class TrainingWrapper
    {
        public String name {get; set;}
        public String selectedCampaign {get; set;}
        public list<SelectOption> campaignList {get; set;}
        public Boolean disabled {get; set;}
        public Boolean required {get;set;}
        public Boolean hasCampaigns
        {
          get
          {
            if (campaignList.size() == 1)
            {
              return false;
            }
            return true;
          } 
        }
        
        public TrainingWrapper(String n)
        {
            name = n;
            campaignList = new list<SelectOption>();
            campaignList.add(new SelectOption('', '--Select--'));
            disabled = false;
            required=false;
        }
        public TrainingWrapper(NHW_Provisioning__c Provrec)
        {
            name = Provrec.name;
            campaignList = new list<SelectOption>();
            campaignList.add(new SelectOption('', '--Select--'));
            disabled = false;
            required=Provrec.required__c;
        }
    }
}