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

 
public without sharing class NewHireWizardController {
 
    public Integer currentPageNumber {get; set;}
    public Case newHireCase {get; set;}
    public Boolean hasError {get; set;}

    public NHWRecruitmentModel SelectedRecruitmentDataObject  {
        get{
            if(SelectedRecruitmentDataObject==null){
                this.SelectedRecruitmentDataObject =  NHW_Util.getCurrentRecruitmentObject();  
            }
            return SelectedRecruitmentDataObject; 
        }
        private set;
    } 

    public String selectedStartAction {get; set;}
    public String gusSst {get;set;} //sst username for GUS org
    public String org62ContSst {get;set;} //sst username for org62 contractors 
    public String sfSst {get;set;} //sst username for supportforce org
    public Case dummyCase {get; set;} // this case is to display fields
    public list<NHWWrapper.HelpTextWrapper> helpTextList {get; set;}
    public Boolean NHOdisabled {get; set;}
    public Boolean isBSFEnrolled {get; set;}
    public Boolean hasSpecializedTraining{get;set;}
    public Boolean hasBSF{get;set;}
    public Boolean isJapanEmployee {get; set;}
    public Boolean validateBecomeingSalesforceTraining {get; set;}
    public Boolean skipPage3 {get; set;}
    public Boolean IsBSFDateBasedOnBootcamp = false;
    public static Boolean useNewConfigForBootcamps {
        get{
            if(useNewConfigForBootcamps == null)
                return (Boolean)NH_Settings__c.getInstance().Use_New_Config_For_Bootcamps__c;
            system.debug(LOGGINGLEVEL.INFO,useNewConfigForBootcamps);
            return useNewConfigForBootcamps;
        } 
        set;
    }
    public static Boolean useNewConfigForApplications {
        get{
            if(useNewConfigForApplications == null)
                return (Boolean)NH_Settings__c.getInstance().Use_New_Config_for_Applications__c;
            system.debug(LOGGINGLEVEL.INFO,useNewConfigForApplications);
            return useNewConfigForApplications;
        } 
        set;
    }
    public static Boolean useNewConfigForDeskPhone {
        get{
            if(useNewConfigForDeskPhone == null)
                return (Boolean)NH_Settings__c.getInstance().Use_New_Config_For_DeskPhone__c;
            system.debug(LOGGINGLEVEL.INFO,useNewConfigForDeskPhone);
            return useNewConfigForDeskPhone;
        } 
        set;
    }
    public String onBoardingBuddyName {get;set;}
    public list<NHWWrapper.OnboardingWrapper> fullAccessList {get; set;}
    public list<NHWWrapper.EmployeeWrapper> employeeList {get; set;}
    public list<NHWWrapper.EmployeeWrapper> existingEmployeeList {get; set;}
    public list<Case> preBoardEmployeeList {get; set;}
    public list<SelectOption> orgList {get{return NHWHelper.getOrgList(isExactTarget);} private set;}
    public list<SelectOption> orgListContractor {get{return NHWHelper.getOrgList(isExactTargetContractor);} private set;}
    
    public list<SelectOption> resourceType {
        get{

            if(NH_Settings__c.getInstance().Use_New_Config_For_ResourceType__c){

                System.debug('Resource Type options using new config');

                if(newHireCase != null && newHireCase.NHW_Employee_Type__c == null && selectedStartAction != null){
                    if(selectedStartAction == 'fte'){
                        newHireCase.NHW_Employee_Type__c = 'Regular Employee';
                    }else if(selectedStartAction == 'contractor'){
                        newHireCase.NHW_Employee_Type__c = 'Contractor';
                    }else if(selectedStartAction == 'relocation'){
                        newHireCase.NHW_Employee_Type__c = 'Relocation';
                    }
                }

                List<NHW_Provisioning__c> resourceTypeProvisionings = NHW_ProvisioningStore.getProvisionings(newHireCase,'Resource Type');
                List<SelectOption> resourceTypeOptions = new List<SelectOption>();

                resourceTypeOptions.add(new SelectOption('', '--None--'));

                for(NHW_Provisioning__c provisioning:resourceTypeProvisionings){
                    resourceTypeOptions.add(new SelectOption(provisioning.Name, provisioning.Name));
                }

                resourceTypeOptions.sort();

                return resourceTypeOptions;
            }

            return NHWHelper.getResourceType(selectedStartAction);
        } 
        private set;
    }
    public list<SelectOption> conHireReason {
        get{

            if(NH_Settings__c.getInstance().Use_New_Config_For_HireReason__c){

                System.debug('Hire Reason options using new config');

                if(newHireCase != null && newHireCase.NHW_Employee_Type__c == null && selectedStartAction != null){
                    if(selectedStartAction == 'fte'){
                        newHireCase.NHW_Employee_Type__c = 'Regular Employee';
                    }else if(selectedStartAction == 'contractor'){
                        newHireCase.NHW_Employee_Type__c = 'Contractor';
                    }else if(selectedStartAction == 'relocation'){
                        newHireCase.NHW_Employee_Type__c = 'Relocation';
                    }
                }

                List<NHW_Provisioning__c> hireReasonProvisionings = NHW_ProvisioningStore.getProvisionings(newHireCase,'Hire Reason');
                List<SelectOption> hireReasonOptions = new List<SelectOption>();

                hireReasonOptions.add(new SelectOption('', '--None--'));

                for(NHW_Provisioning__c provisioning:hireReasonProvisionings){
                    hireReasonOptions.add(new SelectOption(provisioning.Name, provisioning.Name));
                }

                hireReasonOptions.sort();

                return hireReasonOptions;
            }

            return NHWHelper.getConHireReason(selectedStartAction);
        } 
        private set;
    }
    public string trainingTextExtract {
        get{
             String TrainingExtract = '';      
             if (newHireCase.NHW_Training__c != null) {
                    for (String s : newHireCase.NHW_Training__c.split('<br />', 0)) {
                        if (s != null && s != '') {
                            Integer colPos = s.indexOf('::');
                            if (colPos > 0) {
                                TrainingExtract = TrainingExtract+ s.substring(colPos + 2) +'<br/>';
                            }
                        }
                    }
             }
             return TrainingExtract;
        } 
        private set;
    }
    public boolean isBUExcludedforOrg62{
        get{
            if(newHireCase != null && newHireCase.NHW_Business_Unit__c != null){
                    String businessUnit = NHW_Util.getBusinessUnitIdToName(newhireCase.NHW_Business_Unit__c);
                    businessUnit = businessUnit.split('-',0)[0];
                    system.debug('***businessUnit ' + businessUnit);
                    system.debug('***NHW_Util.isBUexcluded(businessUnit) ' + NHW_Util.isBUexcluded(businessUnit));
                    if(newHireCase.NHW_Employee_Type__c =='Contractor' && NHW_Util.isBUexcluded(businessUnit)){
                        system.debug('******removing Access for Org62');
                        return true;
                    }
                    else return false;
            }
            return false;
        }
        private set;                 
    }
    public String selectedNHOCampaign {get; set;} // New Hire Orientation is special
    public String selectedBootcampId {get; set;} 
    
    public list<SelectOption> NHOcampaignList {get; set;}
    public list<NHW_Org62Service.CampaignResult> EligibleBSFCampaignList;
    public list<NHW_Org62Service.CampaignResult> EligibleBSFForBootcampList;
    public map<string,NHW_Provisioning__c> mTypeToProvRecBSF = new map<string,NHW_Provisioning__c>();
    
    public list<NHWWrapper.TrainingWrapper> trainingList {get; set;}
    public Boolean emptyList {get; set;}
    public boolean isRemoteExecuted;
    public boolean isSameAsOfficeChecked;
    public boolean isRemote{
        get {
            if(!this.isRemoteExecuted)
                isRemote = false;

            if (selectedStartAction != 'contractor' && selectedStartAction != 'relocation' && !this.isRemoteExecuted && SelectedRecruitmentDataObject.isRemote){
                isRemote = true;
                this.isRemoteExecuted = true;

            }
            else if ((selectedStartAction == 'contractor' || selectedStartAction == 'relocation') && !this.isRemoteExecuted && newHireCase !=null && newHireCase.NH_Business_Site__c != null && NHW_Util.getBusinessSiteIdToName(newHireCase.NH_Business_Site__c).contains('Remote')){
                isRemote = true;
                this.isRemoteExecuted = true;
            }
            system.debug('*****isRemote and isRemoteExecuted ' + isRemote + ' ' + this.isRemoteExecuted);    
            return isRemote;    
        }
        set;
    }

    public boolean displayDeskPhoneOption{
        get {
            system.debug('****isRemote in displayDeskPhoneOption ' + isRemote);
            if(!isRemote){
                Map<String,NH_BU_CC_Selections__c> autoSelectComboMap = NH_BU_CC_Selections__c.getAll();
                system.debug('****autoSelectComboMap ' + autoSelectComboMap + ' cc ' + newHireCase.Cost_Center_NHW__c.split('-',0)[0]);
                for(NH_BU_CC_Selections__c n:autoSelectComboMap.values()){
                    system.debug('****n.Desk_Phone_High_Use_CC__c ' + n.Desk_Phone_High_Use_CC__c);
                    if(n.Desk_Phone_High_Use_CC__c != null && newHireCase.Cost_Center_NHW__c.split('-',0)[0] ==  n.Desk_Phone_High_Use_CC__c &&
                       ((newHireCase.NHW_Organization__c == 'Marketing Cloud' && newHireCase.NHW_Role__c != 'Support') || (newHireCase.NHW_Organization__c != 'Marketing Cloud'))){
                        system.debug('****returning true from displayDeskPhoneOption at line 93'); 
                        return true;
                    }
                }
                system.debug('****returning false from displayDeskPhoneOption at line 98'); 
                return false;
            }
            else return false;
        }
        set;
    }

    public boolean displayDeskPhoneText2{
        get {
            if(!isRemote){
                Map<String,NH_BU_CC_Selections__c> autoSelectComboMap = NH_BU_CC_Selections__c.getAll();
                for(NH_BU_CC_Selections__c n:autoSelectComboMap.values()){
                    if(newHireCase.Cost_Center_NHW__c.split('-',0)[0] ==  n.Desk_Phone_High_Use_CC__c){
                        return false;
                    } 
                }
                if(newHireCase.NHW_Role__c != 'Support'){
                    return true;
                }
                else return false;
            }
            else return false;
        }
        set;
    }

    public list<SelectOption> roleList {
        get {
            if (newHireCase != null)
                return NHWHelper.getRoleList(newHireCase.NHW_Organization__c,selectedStartAction);
            return NHWHelper.getRoleList('','');
        } set;
    }
    public list<SelectOption> mobileList {
        get {
            if (newHireCase != null) 
                return NHWHelper.getMobileList(newHireCase.Division__c);
            return NHWHelper.getMobileList('');
        } set;
    }

    public List<SelectOption> desktopList{

        get{
            if(desktopList == null){

                List<NHW_Provisioning__c> desktopProvisionings = NHW_ProvisioningStore.getProvisionings(newHireCase,'Desktop');
                desktopList = new List<SelectOption>();
                desktopList.add(new SelectOption('', '--None--'));

                for(NHW_Provisioning__c provisioning:desktopProvisionings){
                    desktopList.add(new SelectOption(provisioning.Name, provisioning.Name));
                }
            }
            return desktopList;
        } set;
    }

    public list<SelectOption> laptopList {
        get {
            if(NH_Settings__c.getInstance().Use_New_Config_For_Laptop__c){

                System.debug('Laptop options using new config');
                
                List<NHW_Provisioning__c> laptopProvisionings = NHW_ProvisioningStore.getProvisionings(newHireCase,'Laptop');
                List<SelectOption> laptopOptions = new List<SelectOption>();

                laptopOptions.add(new SelectOption('', '--None--'));

                for(NHW_Provisioning__c provisioning:laptopProvisionings){
                    laptopOptions.add(new SelectOption(provisioning.Name, provisioning.Name));
                }

                laptopOptions.sort();

                return laptopOptions;
            }

            if (newHireCase != null && newHireCase.NHW_Employee_Type__c != 'Regular Employee') return NHWHelper.getLaptopList(
                    NHW_Util.getCostCenterIdToName(newHireCase.NHW_Cost_Center__c), newHireCase.NHW_Employee_Type__c, newHireCase.Office_Country__c, newHireCase.NHW_Organization__c, NHW_Util.getBusinessUnitIdToName(newHireCase.NHW_Business_Unit__c));
            else return NHWHelper.getLaptopList(
                    newHireCase.Cost_Center_NHW__c, newHireCase.NHW_Employee_Type__c, newHireCase.Office_Country__c, newHireCase.NHW_Organization__c, newHireCase.Business_Unit_NHW__c);

        } set; 
    }

    public list<SelectOption> NHOServiceWorkshopList {
        get {
            if (newHireCase != null) return NHWHelper.getMCServiceWorkshopList();
            return null;
        }
        set;
    }
    public list<SelectOption> NHOServiceOrientationList {
        get {
            if (newHireCase != null) return NHWHelper.getMCServiceOrientationList();
            return null;
        }
        set;
    }
    public Integer maxPage {
        get {
            if (newHireCase != null && newHireCase.NHW_Employee__c != null) {
                return 4;
            } 
            return 3;
        } set;
    }

    public boolean isExactTarget {
        get {
            if(newHireCase.Id == null){
                NHWWrapper.EmployeeWrapper ew = new NHWWrapper.EmployeeWrapper(SelectedRecruitmentDataObject);
                if(ew.isETEmployee){
                    this.isExactTarget=true; 
                }
                else{
                    this.isExactTarget=false;
                }
            }
            else if(newHireCase != null){
                NHWWrapper.EmployeeWrapper ew = new NHWWrapper.EmployeeWrapper(newHireCase);
                if(ew.isETEmployee){
                    this.isExactTarget=true; 
                }
                else{
                    this.isExactTarget=false;
                } 
            }
            return isExactTarget; 

        }
        private set; 
    } 


    public boolean isExactTargetContractor {
        get {
            if (newHireCase != null && newHireCase.NHW_Business_Unit__c != null && (newHireCase.NHW_Employee_Type__c == null || (newHireCase.NHW_Employee_Type__c !=null && newHireCase.NHW_Employee_Type__c != 'Regular Employee'))) {
                if(NHW_Util.exactTargetBUs != null & NHW_Util.exactTargetBUs.get(NHW_Util.getBusinessUnitIdToName(newHireCase.NHW_Business_Unit__c)) != null){
                    return true;    
                } 
            } 
            return false;
        } set;
    }

    private String companyNameOrg62String;
    private String org62ContactId;
    private String supportforceEmail;
    private set<Id> userIdSet = new set<Id>();
    @testvisible
    private map<Id, NHW_Org62Service.CampaignResult> fullCampaignMap = 
            new map<Id, NHW_Org62Service.CampaignResult>();
    @testvisible
    private set<Id> enrolledCampaignSet = new set<Id>();
    @testvisible
    private map<String, String> campaignMap = new map<String, String>();
    @testvisible
    private map<String, String> fullCampaignIdMap = new map<String, String>();

    public NewHireWizardController() {
        this.isRemoteExecuted = false;
        resetDefaults();
        loadUserIdSet();
        loadHelpText();
        //loadAccessList();
        useNewConfigForBootcamps = (Boolean)NH_Settings__c.getInstance().Use_New_Config_For_Bootcamps__c;
        useNewConfigForApplications = (Boolean)NH_Settings__c.getInstance().Use_New_Config_for_Applications__c;
        system.debug(LOGGINGLEVEL.INFO,useNewConfigForBootcamps);
        if (ApexPages.currentPage().getParameters().get('caseId') != null) {
            try{
                newHireCase = NHW_Util.getCurrentCase(); 
            }
            catch(Exception e){
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your case Id is invalid.'));
            }
            this.isSameAsOfficeChecked = false;
            if(useNewConfigForApplications){
                loadApplicationList();
            }else{
                loadAccessList();
            }
            loadCase();
        }
        else if (ApexPages.currentPage().getParameters().get('placementId') != null) {
            /*check if on-boarding ticket already exists and throw error if it does */
            List<Case> onBoarding = [select id,casenumber from case where recordTypeId=:NHW_Util.getnhwCaseRecordTypeId()]; 
            if(onBoarding!=null && onBoarding.size()>0){
                hasError=true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'On-boarding case: '+ onBoarding[0].casenumber+ ' already exists for this placement.'));
            }
            else{ //continue with normal flow 
                SelectedRecruitmentDataObject = NHW_Util.getCurrentRecruitmentObject();

                this.isSameAsOfficeChecked = true; 
                if(useNewConfigForApplications){
                    loadApplicationList();
                }else{
                    loadAccessList();
                }
               //loadPlacement();
                if (currentPageNumber == null || currentPageNumber < 1) {
                    currentPageNumber = 1;
                }
                populateNewCase(); 
                loadCampaignsAndContact();
            }
        }
        if(newHireCase != null && newHireCase.NHW_Employee_Type__c == 'Regular Employee'){
            selectedStartAction = 'fte';
        }
        else if(newHireCase != null && newHireCase.NHW_Employee_Type__c == 'Contractor'){
            selectedStartAction = 'contractor';
        }
        else if(newHireCase != null && newHireCase.NHW_Employee_Type__c == 'Relocation'){
            selectedStartAction = 'relocation';
        }
    }

    public String getSiteURL(){
        return ESDJC_Util.getSiteURL();
    }  

    private void resetDefaults(){
        currentPageNumber = -1;
        hasError = false;
        newHireCase = new Case(RecordTypeId = NHW_Util.getnhwCaseRecordTypeId(),Origin='NHW');
        newHireCase.Computer_Type__c = 'Not Required';
        newHireCase.Same_as_Office_Location__c = true;
        dummyCase = new Case();
    }

    private void loadUserIdSet() {
        userIdSet = new set<Id>();
        userIdSet.add(UserInfo.getUserId());

        try {
            set<Id> contactIdSet = new set<Id>();
            set<String> managerEmailSet = new set<String>();
            User u = [Select Id, Email From User Where Id =: UserInfo.getUserId()];

            for (User u1 : [Select Id, ContactId From User Where Email =: u.Email]) {
                userIdSet.add(u1.Id);
                if (u1.ContactId != null) {
                    contactIdSet.add(u1.ContactId);
                }
            }

            for (Delegate__c d : [Select Id, Manager__r.Email
                                  From Delegate__c 
                                  Where Delegate__c IN :contactIdSet
                                  And Type__c = 'New Hire Wizard']) {
                if (d.Manager__r.Email != null) {
                    managerEmailSet.add(d.Manager__r.Email);
                }                   
            }

            for (User u1 : [Select Id, ContactId From User Where Email IN :managerEmailSet]) {
                userIdSet.add(u1.Id);
            }
        }
        catch (Exception e) {}
    }

    private void loadHelpText() {
        helpTextList = new list<NHWWrapper.HelpTextWrapper>();
        helpTextList.add(new NHWWrapper.HelpTextWrapper('Hire New Employee', 
                '1. Hiring or Re-hiring an Employee (FTE, Intern, Foundation, Fixed Term)<br />' + 
                '2. Converting a Contractor to an Employee'));
        helpTextList.add(new NHWWrapper.HelpTextWrapper('Hire New Contractor', 
                '1. Hiring or Re-hiring a Contractor (Agency Temp, Consulting Firm ' + 
                'Employee, Independent Contractor)<br />' + 
                '2. Converting an Employee to a Contractor'));
        helpTextList.add(new NHWWrapper.HelpTextWrapper('International Relocation', 
                'Relocating an Employee from one region to another'));
        helpTextList.add(new NHWWrapper.HelpTextWrapper('Return to Exisiting Process', 
                'To resume an on-boarding request you have saved for later ' + 
                '(Employee or Contractor).'));
    }     

    public void loadApplicationList(){
        List<NHW_Provisioning__c> ApplicableApps = new list<NHW_Provisioning__c>();
        NHWWrapper.OnboardingWrapper OnboardingWrapRec ;
        fullAccessList = new list<NHWWrapper.OnboardingWrapper>();
        ApplicableApps = NHW_ProvisioningStore.getProvisionings(newhirecase,'Application');
        system.debug(LoggingLevel.INFO,'ApplicableApps --'+ApplicableApps);
        map<String, list<NHW_Provisioning__c>> AppTypeToProvRec = new map<String, list<NHW_Provisioning__c>>();
        for(NHW_Provisioning__c provRec:ApplicableApps){
            String AppType=provRec.Onboarding_Type__c;
            if(AppTypeToProvRec.containskey(AppType)){
                AppTypeToProvRec.get(AppType).add(provRec);
            }else{
                AppTypeToProvRec.put(AppType,new list<NHW_Provisioning__c>{provRec});
            }
        }

        for (String AppType : AppTypeToProvRec.keySet()) {
            OnboardingWrapRec = new NHWWrapper.OnboardingWrapper(AppType);

            for (NHW_Provisioning__c provRec : AppTypeToProvRec.get(AppType)) {
               NHW_AccessWrapper aw = new NHW_AccessWrapper(provRec);
               if(aw.item.Auto_Display__c){//Displays as default selected.
                    aw.selected = true;
               } 
               if(aw.item.is_Auto_Provisioned__c){//No Render button displayed
                    aw.isAutoProvisioned = true;
               } 
               OnboardingWrapRec.accessList.add(aw);
            }
            fullAccessList.add(OnboardingWrapRec);
        }

    }
    public void loadAccessList() {
        boolean isET;
        String bucckey,buccSFMKey,businessUnit,costCenter; 
        Map<String,NH_BU_CC_Selections__c> autoSelectComboMap = NH_BU_CC_Selections__c.getAll();
        set<String> sfmBUCombo = new set<String>();
        
        for(NH_BU_CC_Selections__c n:autoSelectComboMap.values()){
          sfmBUCombo.add(n.SFM_Open_Access_BU__c+'-'+n.SFM_Open_Access_CC__c);
        }
        
        if(newHireCase.NHW_Employee_Type__c != 'Contractor'){ 
            isET = isExactTarget;
        }
        else {
            isET = isExactTargetContractor;
        }    
        if(isET && newHireCase!=null && newHireCase.NHW_Organization__c!=null ){
            fullAccessList = NHWHelper.getAccessList(newHireCase.NHW_Organization__c,newHireCase);
        }
        else if(newHireCase != null ){
            system.debug('****in non-ET flow in loadAccessList method');
            fullAccessList = NHWHelper.getAccessList(newHireCase);
        }
        else {
            fullAccessList = new list<NHWWrapper.OnboardingWrapper>();
        }
        if(fullAccessList != null && fullAccessList.size() >0){
        for(NHWWrapper.OnboardingWrapper ow:fullAccessList){
            for(NHW_AccessWrapper aw:ow.accessList){
            if(newHireCase.NHW_Employee_Type__c!='Contractor' && aw.item.Name == System.Label.NHW_GUS_SST){
                    if(newHireCase.Business_Unit_NHW__c!=null && newHireCase.Cost_Center_NHW__c!=null){
                        try{
                            buccKey = 'BU'+newHireCase.Business_Unit_NHW__c.split('-',0)[0]+'_CC'+newHireCase.Cost_Center_NHW__c.split('-',0)[0];
                        } catch(Exception e){
                            System.debug('Exceptiopn while parsinfg BU and CC list' + e.getMessage());
                        }
                        if(buccKey!=null && autoSelectComboMap!=null && autoSelectComboMap.containsKey(bucckey)){
                            aw.item.Auto_Display__c = true;
                        }
                    }
                }
                if(aw.item.Auto_Display__c && aw.item.Name != 'Org62'){
                    aw.selected = true;
                }
                if(newHireCase.NHW_Organization__c == 'Marketing Cloud' && newHireCase.NHW_Role__c == 'Sales' && aw.item.Name == 'Demo Account (Demo NTO)'){
                    aw.selected = true;
                }
                if(aw.item.name == 'Org62' && !isBUExcludedforOrg62){
                        aw.selected = true;    
                }
                else if(aw.item.name == 'Org62' && isBUExcludedforOrg62){
                        aw.selected = false;
                }
                if(aw.item.Name == 'SFM/CRD Open Access & git.soma.salesforce.com' && newHireCase.Business_Unit_NHW__c != null && newHireCase.Cost_Center_NHW__c != null){
                    
                    try{
                            buccSFMKey = newHireCase.Business_Unit_NHW__c.split('-',0)[0]+'-'+newHireCase.Cost_Center_NHW__c.split('-',0)[0];
                            
                        } catch(Exception e){
                            System.debug(LOGGINGLEVEL.INFO,'Exceptiopn while parsing SFM BU and CC list' + e.getMessage());
                        }
                        system.debug(LoggingLevel.info,'buccSFMKey '+buccSFMKey);
                        if(buccSFMKey!=null && autoSelectComboMap!=null && autoSelectComboMap.containsKey(buccSFMKey) && !sfmBUCombo.contains(buccSFMKey)){
                            aw.selected = true;
                           system.debug(LoggingLevel.info,'INSIDE selected SFM access ');
                           system.debug(LoggingLevel.info,'sfmBUCombo '+sfmBUCombo);

                        }    
                }
            }
        }
        }

    }

    public PageReference refreshValues(){
        //we can add conditions to re-load specific values.. for now asking to re-load fullAccessList

            if(useNewConfigForApplications){
                loadApplicationList();
            }else{
                loadAccessList();
            }
        return null; 
    }

    /* Rerender methods */
    public void updateBuddyInfo() {
        try {
            Contact c = [Select Id, Email, Name, EmployeeNumber__c
                         From Contact 
                         Where Id =: dummyCase.NHW_Trail_Guide__c];
            
            if(c.EmployeeNumber__c == 'CTRCT'){
                dummyCase.NHW_Trail_Guide__c = null;
                newHireCase.Onboarding_Buddy_Name__c = null;
                newHireCase.Onboarding_Buddy_Email__c = null;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Trail Guide must be a FTE'));
            }else if(c.Id == newHireCase.Manager_Name__c){
                dummyCase.NHW_Trail_Guide__c = null;
                newHireCase.Onboarding_Buddy_Name__c = null;
                newHireCase.Onboarding_Buddy_Email__c = null;
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The manager and Trail Guide can\'t be the same individual. Please select another individual to provide your new hire with guidance, info, and coaching.'));
            }else{
                newHireCase.Onboarding_Buddy_Name__c = c.Name;
                newHireCase.Onboarding_Buddy_Email__c = c.Email;
            }
        }
        catch (Queryexception qe) {
            dummyCase.NHW_Trail_Guide__c = null;
            newHireCase.Onboarding_Buddy_Name__c = null;
            newHireCase.Onboarding_Buddy_Email__c = null;
        }
    }

    public void updateIsET(){
        try {
            NHWWrapper.EmployeeWrapper ew = new NHWWrapper.EmployeeWrapper(SelectedRecruitmentDataObject);
            if(ew.isETEmployee) {

                newHireCase.NH_Is_Exact_Target__c = true;
            }
            else{
                newHireCase.NH_Is_Exact_Target__c = false;
            }


        }
        catch (Queryexception qe) {

        }
    }

    public void updateRole() {
        if (newHireCase != null) { 
            NHWHelper.getRoleList(newHireCase.NHW_Organization__c,selectedStartAction);
        } else {
            NHWHelper.getRoleList('','');
        }
    }

    public void updateManagerInfo() {
        try {
            Contact c = [Select Id, Email, Name From Contact Where Id =: newHireCase.Manager_Name__c];
            newHireCase.Manager_s_Email__c = c.Email;
        }
        catch (Queryexception qe) {
            newHireCase.Manager_Name__c = null;
            newHireCase.Manager_s_Email__c = null;
        }
    }

    public void updateBusinessSite() {
        if (currentPageNumber == 1) {
            try {
                TF2_Business_Site__c b = [Select Id, Street_Address__c, City__c,
                                          State_Province__c, Postal_Code__c,
                                          Country__c, Name
                                          From TF2_Business_Site__c 
                                          Where Id =: newHireCase.NH_Business_Site__c];

                newHireCase.Office_Address__c = 
                        b.Street_Address__c != null ? 
                                b.Street_Address__c : 'N/A';
                newHireCase.Office_City__c = 
                        b.City__c != null ? 
                                b.City__c : 'N/A';
                newHireCase.Office_State_Province__c = 
                        b.State_Province__c != null ? 
                                b.State_Province__c : 'N/A';
                newHireCase.Office_Zip_Postal_Code__c = 
                        b.Postal_Code__c != null ? 
                                b.Postal_Code__c : 'N/A';
                newHireCase.Office_Country__c = 
                        b.Country__c != null ? 
                                b.Country__c : 'N/A';

                system.debug('***about to enter updateBusinessSite meothod if condition ' + b.Name + ' ' + selectedStartAction );
                if(b.Name != null && b.Name.contains('Remote') && selectedStartAction != 'fte'){
                    newHireCase.Location_Type__c = '';
                    newHireCase.Shipping_Address__c = '';
                    newHireCase.Shipping_City__c = '';
                    newHireCase.Shipping_State__c = '';
                    newHireCase.Shipping_Zip_Postal__c = ''; 
                    newHireCase.Shipping_Country__c = '';
                }                
            } catch (Queryexception qe) {
                newHireCase.Office_Address__c = null;
                newHireCase.Office_City__c = null;
                newHireCase.Office_State_Province__c = null;
                newHireCase.Office_Zip_Postal_Code__c = null; 
                newHireCase.Office_Country__c = null;
            }

        }
        else if (currentPageNumber == 2) {
            try {
                TF2_Business_Site__c b = [Select Id, Name, Street_Address__c, City__c,
                                          State_Province__c, Postal_Code__c,
                                          Country__c
                                          From TF2_Business_Site__c 
                                          Where Id =: newHireCase.NH_Shipping_Business_Site__c];

                if(b.Name.contains('Remote')){
                    if(selectedStartAction == 'fte'){
                        updateShippingAddressForRemote();   
                        newHireCase.Location_Type__c = 'Remote - Home Office';
                        calculateSameAsOffice();
                        return;
                    }    
                }
                newHireCase.Shipping_Address__c = 
                        b.Street_Address__c != null ? 
                                b.Street_Address__c : 'N/A';
                newHireCase.Shipping_City__c = 
                        b.City__c != null ? 
                                b.City__c : 'N/A';
                newHireCase.Shipping_State__c = 
                        b.State_Province__c != null ? 
                                b.State_Province__c : 'N/A';
                newHireCase.Shipping_Zip_Postal__c = 
                        b.Postal_Code__c != null ? 
                                b.Postal_Code__c : 'N/A';
                newHireCase.Shipping_Country__c = 
                        b.Country__c != null ? 
                                b.Country__c : 'N/A';
                calculateSameAsOffice();
                newHireCase.Location_Type__c = getLocationType(b.Name);

            } catch (Queryexception qe) {
                newHireCase.Shipping_Address__c = null;
                newHireCase.Shipping_City__c = null;
                newHireCase.Shipping_State__c = null;
                newHireCase.Shipping_Zip_Postal__c = null; 
                newHireCase.Shipping_Country__c = null;
                newHireCase.Location_Type__c = null;
            }
        }
    }

    public String getLocationType(String businessSiteName){
        if(businessSiteName != null && businessSiteName != ''){ 
            if(businessSiteName.contains('Remote'))
                return 'Remote - Home Office';
            else if(businessSiteName.contains('Client'))
                return 'Client';
            else
                return 'Office';    
        }
        return '';
    }


    public void copyShippingAddress() {
        if (newHireCase.Same_as_Office_Location__c) {
            newHireCase.Location_Type__c = getLocationType(NHW_Util.getBusinessSiteIdToName(newHireCase.NH_Business_Site__c));
            if(newHireCase.Location_Type__c.contains('Remote')){
                if(selectedStartAction == 'fte'){
                    updateShippingAddressForRemote();   
                    return;
                } 
            }
            newHireCase.Shipping_Address__c = 
                    newHireCase.Office_Address__c != null ? 
                            newHireCase.Office_Address__c : 'N/A';
            newHireCase.Shipping_City__c = 
                    newHireCase.Office_City__c != null ? 
                            newHireCase.Office_City__c : 'N/A';
            newHireCase.Shipping_State__c = 
                    newHireCase.Office_State_Province__c != null ? 
                            newHireCase.Office_State_Province__c : 'N/A';
            newHireCase.Shipping_Zip_Postal__c = 
                    newHireCase.Office_Zip_Postal_Code__c != null ? 
                            newHireCase.Office_Zip_Postal_Code__c : 'N/A';
            newHireCase.Shipping_Country__c = 
                    newHireCase.Office_Country__c != null ? 
                            newHireCase.Office_Country__c : 'N/A';
        } else {

            newHireCase.Shipping_Address__c = null;
            newHireCase.Shipping_City__c = null;
            newHireCase.Shipping_State__c = null;  
            newHireCase.Shipping_Zip_Postal__c = null; 
            newHireCase.Shipping_Country__c = null;
            newHireCase.Location_Type__c = null;
        }
    }

    private void calculateSameAsOffice(){
        if(newHireCase.Shipping_Address__c == newHireCase.Office_Address__c &&
                newHireCase.Shipping_City__c == newHireCase.Office_City__c &&
                newHireCase.Shipping_State__c == newHireCase.Office_State_Province__c &&
                newHireCase.Shipping_Zip_Postal__c == newHireCase.Office_Zip_Postal_Code__c &&
                newHireCase.Shipping_Country__c == newHireCase.Office_Country__c){
            newHireCase.Same_as_Office_Location__c = true;
        }
        else newHireCase.Same_as_Office_Location__c = false;
    }

    private void updateShippingAddressForRemote(){
        //isRemote = true;
        newHireCase.Shipping_Address__c = 
                SelectedRecruitmentDataObject.OfficeAddress != null ? 
                        SelectedRecruitmentDataObject.OfficeAddress  : 'N/A';
        newHireCase.Shipping_City__c = 
                SelectedRecruitmentDataObject.OfficeCity != null ? 
                        SelectedRecruitmentDataObject.OfficeCity : 'N/A';
        newHireCase.Shipping_State__c = 
                SelectedRecruitmentDataObject.OfficeStateProvince != null ? 
                        SelectedRecruitmentDataObject.OfficeStateProvince: 'N/A';
        newHireCase.Shipping_Zip_Postal__c = 
                SelectedRecruitmentDataObject.OfficeZipPostalCode != null ? 
                        SelectedRecruitmentDataObject.OfficeZipPostalCode : 'N/A';
        newHireCase.Shipping_Country__c = 
               SelectedRecruitmentDataObject.OfficeCountry != null ? 
                        SelectedRecruitmentDataObject.OfficeCountry : 'N/A';

    }


    private void refreshETFields(){

        if(newHireCase.NHW_Role__c != null && newHireCase.Office_Country__c != null && (newHireCase.Office_Country__c!='Brazil' && newHireCase.Office_Country__c != 'BR')){
            newHireCase.NH_Legacy_ET_Dept_Code__c = null;
        }

        if(newHireCase.NH_Is_Exact_Target__c != null && newHireCase.NH_Is_Exact_Target__c){
            if(newHireCase.NHW_Role__c != null && newHireCase.NHW_Role__c != 'Support'){
                newHireCase.NH_ET_Team__c = null;
            }
            if(newHireCase.NHW_Role__c != null && newHireCase.NHW_Role__c != 'Support' && newHireCase.NHW_Role__c != 'Services'){
                newHireCase.NH_ET_Sub_Region__c = null;
            }
            if(newHireCase.NHW_Role__c != null && newHireCase.NHW_Role__c == 'Support' && newHireCase.NH_ET_Team__c != 'Platinum'){
                newHireCase.NH_ET_Sub_Region__c = null;
            }

            if(newHireCase.Office_Country__c!='Brazil' && newHireCase.Office_Country__c != 'BR'){
                if(newHireCase.NHW_Role__c != null && newHireCase.NHW_Role__c != 'Finance/Accounting'){
                    newHireCase.NH_Legacy_ET_Dept_Code__c = null;
                }
            }

            if(newHireCase.NHW_Role__c != null && (!(newHireCase.NHW_Role__c == 'Services' || (newHireCase.NHW_Role__c == 'Support' && newHireCase.NH_ET_Team__c == 'Platinum')))){
                newHireCase.NH_Open_Air_Role__c = null;
            }


        }
    }  
    /* Data load methods */
    private void loadCandidates() { 
        employeeList = new list<NHWWrapper.EmployeeWrapper>();
        existingEmployeeList = new list<NHWWrapper.EmployeeWrapper>();
        preBoardEmployeeList = new list<Case>();
        set<Id> modelIdSet = new set<Id>();
        set<Id> existingCaseIdSet = new set<Id>();
        map<Id, Case> RecruitmentmentWithProvisioningMap = new map<Id, Case>();
        list<NHWRecruitmentModel> AllRecruitmentObjectList = new list<NHWRecruitmentModel>();
        list<NHWRecruitmentModel> RecruitmentObjectsYetToBeProvisioned = new list<NHWRecruitmentModel>();

        NHWWrapper.EmployeeWrapper ew;
        Boolean flag;
        AllRecruitmentObjectList = NHWRecruitmentModelObjectsStore.getAllNHWRecruitmentModelObjectsForMger(userIdSet);

        if (selectedStartAction != 'existing') {
            for(NHWRecruitmentModel ModelObj:AllRecruitmentObjectList){
                if ((ModelObj.preboardingCases != null && !ModelObj.preboardingCases.isEmpty())
                  || (ModelObj.provisioningCases != null && !ModelObj.provisioningCases.isEmpty())
                   ) {
                    Boolean isPreboardingInProgress = false; // True = Preboarding Case is created but not closed yet
                    Boolean closedPreboarding = false; // True = Preboarding Case is closed, either available to Onboard or Onboarded
                    Boolean isOnboarding = false; // True = Onboarding case is created but not submitted
                    Boolean isOnboarded = false;  // True = Onboarding case is submitted or Cancled
                    for(Case c: modelobj.provisioningCases){
                        if (!(c.Status == 'Closed' || c.Status.contains('Sent to Supportforce') || c.Status.contains('Cancel')) && c.RecordTypeId == NHW_Util.getnhwCaseRecordTypeId()) {
                            isOnboarding = true;
                            isOnboarded = false;
                        }else{
                            if(!isOnboarding) isOnboarded = true;
                        }
                    }
                    if(!(isOnboarding || isOnboarded)){

                        for(Case c:modelobj.preboardingCases){//Preboarding case is in Progress in supportforce for the placement.
                            //System.assert(false, JSON.serialize(modelobj.preboardingCases));
                            if(c.RecordTypeId == NHW_Util.getnhwPreBoardCaseRecordTypeId()){
                                if (c.Status.contains('Sent to Supportforce')) {
                                    preBoardEmployeeList.add(c);
                                }
                                if (c.Status == 'Closed') {

                                    isPreboardingInProgress = false;
                                    closedPreboarding = true;
                                }
                            }
                        }
                    }
                    
                    if(closedPreboarding){
                        RecruitmentObjectsYetToBeProvisioned.add(modelobj);
                        modelIdSet.add(modelobj.ModelId);
                    }
                }
            }
            
            if (!RecruitmentObjectsYetToBeProvisioned.isEmpty()) {
                for (Case c : [Select Id, CaseNumber, NHW_Employee__c, 
                               NHW_Page_Number__c, Status, NHW_Employee_Type__c, 
                               NHW_Job_Application__c, Manager_Name__c, 
                               Manager_Name__r.Name,NH_Is_Exact_Target__c 
                               From Case 
                               Where NHW_Job_Application__c IN :modelIdSet
                               And RecordTypeId =: NHW_Util.getnhwCaseRecordTypeId()
                               And IsClosed = false
                               And Status != 'Sent to Supportforce']) {
                    RecruitmentmentWithProvisioningMap.put(c.NHW_Job_Application__c, c);
                    existingCaseIdSet.add(c.Id);
                }

                for (NHWRecruitmentModel model : RecruitmentObjectsYetToBeProvisioned) {
                    ew = new NHWWrapper.EmployeeWrapper(model);

                    if (!RecruitmentmentWithProvisioningMap.containsKey(model.ModelId) && selectedStartAction != 'existing') {
                        employeeList.add(ew);
                    }
                }

            }
            system.debug(logginglevel.INFO,'preBoardEmployeeList--'+preBoardEmployeeList);
            system.debug(logginglevel.INFO,'existingEmployeeList--'+existingEmployeeList);
            system.debug(logginglevel.INFO,'employeeList--'+employeeList);
            
        }

        if (selectedStartAction == 'existing' || selectedStartAction == 'fte') {
            for (Case c : [Select Id, CaseNumber, NHW_Employee__c, 
                           NHW_Page_Number__c, Status, First_Name__c, 
                           Last_Name__c, NHW_Start_Date__c, 
                           Resource_Type__c, NHW_Employee_Type__c,
                           Manager_s_Email__c,
                           Manager_Name__c, Manager_Name__r.Name, Business_Title__c,
                            NH_Is_Exact_Target__c
                           From Case
                           Where RecordTypeId =: NHW_Util.getnhwCaseRecordTypeId()
                           And IsClosed = false
                           And Status != 'Sent to Supportforce'
                           And (CreatedById IN : userIdSet
                                   Or LastModifiedById IN : userIdSet)]) {
                ew = new NHWWrapper.EmployeeWrapper(c);
                if (ew.onboardCase.NHW_Page_Number__c <= ew.maxPage) {
                    existingEmployeeList.add(ew);
                }
            }
        }

        if ( (selectedStartAction == 'existing' && existingEmployeeList.isEmpty()) || (employeeList.isEmpty() && existingEmployeeList.isEmpty() && preBoardEmployeeList.isEmpty()) ) {
            emptyList = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have no employees to onboard.'));
        }
    }

    private void loadCase() {
        String org62Access;
        String gusAccess;
        String sfAccess;
        newHireCase = NHW_Util.getCurrentCase(); 

        if (newHireCase.Onboarding_Buddy_Name__c != null) {
            try {
                dummyCase.NHW_Trail_Guide__c = [Select Id 
                                       From Contact 
                                       Where Name = 
                                       :newHireCase.Onboarding_Buddy_Name__c
                                       limit 1].Id;
            }
            catch (Exception e) {

            }
        }                        
        if (newHireCase.NHW_Employee__c != null){
            loadCampaignsAndContact();
        }

        if (!hasError) {
            Decimal p = newHireCase.NHW_Page_Number__c;

            if (p == null || p < 1) {
                currentPageNumber = 1;
            }
            else {
                currentPageNumber = Integer.valueOf(p);
            }
            if ((currentPageNumber == 3 || currentPageNumber == 4) && newHireCase.NHW_Employee__c != null) {
                system.debug(LOGGINGLEVEL.INFO,useNewConfigForBootcamps);
                if(useNewConfigForBootcamps){
                  getTrainings();
                }else{
                  fillCampaignList();
                }
            }

			 if (newHireCase.NHW_Access_Code__c != null && 
                    newHireCase.NHW_Access_Code__c != '') {
                    map<String, map<String, String>> accessMap = new map<String, map<String, String>>();
                    set<String> userNameSet = new set<String>();
                    map<String, Id> userIdMap = new map<String, Id>();
                    for(NHW_AccessCode accessC : (List<NHW_AccessCode>) JSON.deserialize(newHireCase.NHW_Access_Code__c,List<NHW_AccessCode>.class)){
                        for(NHW_AccessDetails accessD: accessC.accessDetailList){
                            if(accessD.org62SST!=null){
                                org62Access = accessD.org62SST;
                            } else if(accessD.gusSST!=null){
                                gusAccess = accessD.gusSST; 
                            } else if(accessD.sfSSt!=null){
                                sfAccess = accessD.sfSSt;
                            }
                            userNameSet.add(accessD.userToClone);
                            if(accessMap.containsKey(accessC.accessType)){
                                if(accessD.Name.startsWith('Business Objects')){
                                    accessMap.get(accessC.accessType).put('Business Objects',accessD.userToClone); 
                                }else{
                                    accessMap.get(accessC.accessType).put(accessD.name,accessD.userToClone); 
                                }
                            }
                            else {
                                if(accessD.Name.startsWith('Business Objects')){
                                    accessMap.put(accessC.accessType,new Map<String,String>{'Business Objects' => accessD.userToClone});
                                }else{
                                    accessMap.put(accessC.accessType,new Map<String,String>{accessD.name => accessD.userToClone});
                                }
                                
                            }
                        }
                    }

                    for (User u : [Select Id, Name, FirstName, LastName 
                                   From User 
                                   Where Name IN : userNameSet 
                                   And IsActive = true]) {
                        userIdMap.put(u.Name, u.Id);
                    }

                    if(fullAccessList != null && fullAccessList.size() > 0){
                    for (NHWWrapper.OnboardingWrapper ow : fullAccessList) {
                        if (accessMap.containsKey(ow.accessType)) {
                            for (NHW_AccessWrapper aw : ow.accessList) {
                                if (accessMap.get(ow.accessType).containsKey(aw.item.Name)) {
                                    aw.selected = true;
                                    if(org62Access!=null && aw.item.Name==System.Label.NHW_Org62_SST){
                                        aw.org62Holder = org62Access;
                                    } else if(aw.item.Name == System.Label.NHW_GUS_SST){
                                        aw.gusSSTHolder = gusAccess;
                                    } else if(aw.item.Name == System.Label.NHW_Supportforce_SST){
                                        aw.sfSSTHolder = sfAccess;
                                    }
                                    if (userIdMap.containsKey(accessMap.get(
                                            ow.accessType).get(aw.item.Name))) {
                                        //aw.placeHold.ts2__HiringManager__c = 
                                              //  userIdMap.get(accessMap.get(ow.accessType).get(aw.item.Name));
                                    }
                                }
                            }
                        }
                    }}
                }
            }    

            else {
                loadDefaultAccess();
            }
        }
    
    private void loadDefaultAccess() {
        set<String> accessSet = new set<String>();

        for (NHW_Provisioning_Default__c npc : [Select Controller__c, 
                                                Controller__r.Name, 
                                                Dependent__c, 
                                                Dependent__r.Name, 
                                                Dependent__r.Type__c, 
                                                Type__c
                                                From NHW_Provisioning_Default__c 
                                                Where (Controller__r.Name = 
                                                :newHireCase.NHW_Role__c OR Controller__r.Name = :newHireCase.NHW_Employee_Type__c)
        And Dependent__r.Type__c = 
        'Application']) {
            accessSet.add(npc.Dependent__r.Name);
        }
        system.debug('*****fullAccessList ' + fullAccessList);
        if(fullAccessList != null && fullAccessList.size() > 0){
        for (NHWWrapper.OnboardingWrapper ow : fullAccessList) {
            for (NHW_AccessWrapper aw : ow.accessList) {
                if (accessSet.contains(aw.item.Name)) {
                    aw.selected = true;
                }
            }
        }}
    }

    public void getTrainings(){

        system.debug(LOGGINGLEVEL.INFO,'Inside trainings');
        isJapanEmployee=false;
        validateBecomeingSalesforceTraining = false;
        hasBSF = false;
        hasSpecializedTraining = false;        
        if(SelectedRecruitmentDataObject.Region== 'Japan'){
                isJapanEmployee = true;
        }

        Case provCase = NHW_Util.getProvisioningCaseById(newhirecase.Id);

        //Get provisionings based on Filter_Criteria__c
        List<NHW_Provisioning__c> ApplicableTrainings = NHW_ProvisioningStore.getProvisionings(provCase,'Training');

         map<string,NHW_Provisioning__c> mTypeToProvRecSpecializedTrainings = new map<string,NHW_Provisioning__c>();
         mTypeToProvRecBSF = new map<string,NHW_Provisioning__c>();
         map<String, list<NHW_Org62Service.CampaignResult>> trainingMap = new map<String, list<NHW_Org62Service.CampaignResult>>();
         map<String, String>campaignMap = new map<String, String>();
         Integer colPos;
         NHWWrapper.TrainingWrapper tw;
         trainingList = new list<NHWWrapper.TrainingWrapper>();
         IsBSFDateBasedOnBootcamp = false;



         for(NHW_Provisioning__c TrainingProvRec:ApplicableTrainings){

            if(TrainingProvRec.name.startsWith('Becoming Salesforce')){
                validateBecomeingSalesforceTraining = true;
            }

             if( TrainingProvRec.name.equalsIgnoreCase(NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE) 
                ||  TrainingProvRec.name.equalsIgnoreCase(NHW_Util.INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE) ){
                 mTypeToProvRecBSF.put(TrainingProvRec.name,TrainingProvRec);                 
             }
             else{
                 mTypeToProvRecSpecializedTrainings.put(TrainingProvRec.name,TrainingProvRec);
             }
         }
         system.debug(LOGGINGLEVEL.INFO,'ApplicableTrainings '+ApplicableTrainings);
         system.debug(LOGGINGLEVEL.INFO,mTypeToProvRecSpecializedTrainings);
         system.debug(LOGGINGLEVEL.INFO,mTypeToProvRecBSF);
                 
        //From campaignResultMap - Grab CampaignRecs having the campaignType applicable for the new hire.
         if(mTypeToProvRecSpecializedTrainings.size()>0){
            hasSpecializedTraining=true;
            for (NHW_Org62Service.CampaignResult sp : fullCampaignMap.values()) {
                
                NHW_Provisioning__c provisioningRec = new NHW_Provisioning__c();

                if(mTypeToProvRecSpecializedTrainings.containskey(sp.campaignType)){
                   provisioningRec = mTypeToProvRecSpecializedTrainings.get(sp.campaignType);

                }else if(mTypeToProvRecSpecializedTrainings.containskey(sp.campaignItemId)){
                   provisioningRec = mTypeToProvRecSpecializedTrainings.get(sp.campaignType);      

                }else{
                    continue;//Skipping the campaign rec as it is not in eligble campaign type/criteria.
                }

                if(sp.campaignStartDate!= null){
                    //Check if campaign start dates is between  lower cutoff and upper cutoff offsets(if available) from new hire start date.
                    if(provisioningRec.Lower_Cutoff__c != null){
                        if(sp.campaignStartDate < newhirecase.NHW_Start_Date__c.addDays(provisioningRec.Lower_Cutoff__c.intValue()) ){
                            continue; //Skip this training  as it is before lower cutoff.
                        }
                    } 
                    if(provisioningRec.Upper_Cutoff__c != null){
                        if(sp.campaignStartDate > newhirecase.NHW_Start_Date__c.addDays(provisioningRec.Upper_Cutoff__c.intValue()) ){
                            continue; //Skip this training  as it is after upper cutoff.
                        }
                    }
                }else{
                    continue; //Skiping the campaign rec as it is has invalid campaign start date;
                }

                if(provisioningRec.drives_BSF__c){
                    system.debug(LOGGINGLEVEL.INFO,' ** provisioningRec.drives_BSF__c'+provisioningRec.drives_BSF__c);
                    IsBSFDateBasedOnBootcamp= true;
                }
                if(trainingMap.containsKey(sp.campaignType)){
                    //trainingMap.put(sp.campaignType,trainingMap.get(sp.campaignType).add(sp));
                    trainingMap.get(sp.campaignType).add(sp);
                }else{
                    trainingMap.put(sp.campaignType,new list<NHW_Org62Service.CampaignResult>{sp});
                }
                 system.debug(LOGGINGLEVEL.INFO,' ** IsBSFDateBasedOnBootcamp'+IsBSFDateBasedOnBootcamp);

            }
         }
         else{
             hasSpecializedTraining = false;
         }
                 
        //Grab past user selection if available
        if (newHireCase.NHW_Training__c != null) {
                for (String s : newHireCase.NHW_Training__c.split('<br />', 0)) {
                    if (s != null && s != '') {
                        colPos = s.indexOf('::');
                        if (colPos > 0) {
                            campaignMap.put(s.substring(0, colPos), s.substring(colPos + 2));
                        }
                    }
                }
         }

         //Iterate over list of campaigns for each campaign Type and Build Training wrapper to surface on UI
        for (String campaignType : mTypeToProvRecSpecializedTrainings.keySet()) {
            tw = new NHWWrapper.TrainingWrapper(mTypeToProvRecSpecializedTrainings.get(campaignType));

            if(trainingMap.containsKey(campaignType)){
                            
                for (NHW_Org62Service.CampaignResult sp : trainingMap.get(campaignType)) {

                    //Get  selected campaign id based on if newhire is already enrolled or user's past selection.
                    if (enrolledCampaignSet != null && 
                            enrolledCampaignSet.contains(sp.campaignId)) {
                        tw.selectedCampaign = sp.campaignId;
                        tw.disabled = true;
                    }
                    else if (campaignMap.containsKey(tw.Name) && 
                            fullCampaignIdMap.containsKey(campaignMap.get(tw.Name))) {//Grab Id of selected campaign based it's name.
                        tw.selectedCampaign = 
                                fullCampaignIdMap.get(campaignMap.get(tw.Name));
                    }
                    tw.campaignList.add(new SelectOption(sp.campaignId, sp.campaignName));
                //system.debug('tw before after condition ' + tw);    
                }
            }

                    
            if (tw.campaignList.size() == 0) {
                system.debug('tw.campaignList ' + tw.campaignList);
                tw.campaignList = new list<SelectOption>();
                tw.campaignList.add(new SelectOption('', '--No Trainings Available--'));
            }

            //TODO refactor this.
            if (tw.campaignList != null && !tw.campaignList.isEmpty()) {
                list<String> nameList = new list<String>();
                map<String, String> nameMap = new map<String, String>();

                for (SelectOption s1 : tw.campaignList) {
                    nameList.add(s1.getLabel());
                    nameMap.put(s1.getLabel(), s1.getValue());
                }

                nameList.sort();
                tw.campaignList = new list<SelectOption>();
                for (String s1 : nameList) {
                    if (nameMap.containsKey(s1)) {
                        tw.campaignList.add(new SelectOption(nameMap.get(s1), s1));
                    }
                }
            }
                    trainingList.add(tw);
        }
        system.debug(LOGGINGLEVEL.INFO,'Trainingmap - '+Trainingmap);
        system.debug(LOGGINGLEVEL.INFO,'trainingList - '+trainingList);
                //W-3289255 Moving BSF Logic after bootcamp training wrapper population as they drive BSF campaign selection.   


        if(mTypeToProvRecBSF.size()>0){
            hasBSF = true;            
            getBSF();

        }else{
            hasBSF = false;
        }


    }
    public void getBSF(){
       /**BSF Logic */
          NHOdisabled = false;
          isBSFEnrolled = false;
          NHOcampaignList = new list<SelectOption>{new SelectOption('', '--Select--')};
          selectedNHOCampaign=null;

          EligibleBSFCampaignList = new list<NHW_Org62Service.CampaignResult>();
          EligibleBSFForBootcampList = new list<NHW_Org62Service.CampaignResult>();
          
          
          //BSF Not available for Japan employees  - Moved to config
         /* if(SelectedRecruitmentDataObject.Region== 'Japan'){
                NHOdisabled = true;
                isJapanEmployee = true;
                return;                             
          }  */       

          
          /*if( newHireCase.NHW_Organization__c =='Sales & Sales Support' || newHireCase.NHW_Organization__c =='CSG' || 
              (newHireCase.NHW_Organization__c =='Marketing Cloud' && (newhirecase.NHW_role__c=='Services' || newhirecase.NHW_role__c=='Sales'))
            ){
             IsBSFDateBasedOnBootcamp = true;
          }*/
          system.debug(LOGGINGLEVEL.INFO,'IsBSFDateBasedOnBootcamp:'+IsBSFDateBasedOnBootcamp);
          /*system.debug('selectedBootcampId' +selectedBootcampId);
           system.debug('t.selectedcampaign'+trainingList);
          selectedBootcampId = ApexPages.currentPage().getParameters().get('selectedbootcamp');
          system.debug('selectedBootcampId from apexpages' +selectedBootcampId);*/
          
          for(NHWWrapper.TrainingWrapper tw1:traininglist){
            if(IsBSFDateBasedOnBootcamp){
                selectedBootcampId = tw1.selectedcampaign;       
                system.debug(LOGGINGLEVEL.INFO,'selectedBootcampId inside CSG/Sales loop' +selectedBootcampId);
                                    
            }           
          }
          system.debug(LOGGINGLEVEL.INFO,'selectedBootcampId from traininglist' +selectedBootcampId);
          

          
          for (NHW_Org62Service.CampaignResult sp : fullCampaignMap.values()) {
                
                        NHW_Provisioning__c provisioningRec = new NHW_Provisioning__c();

                        if(mTypeToProvRecBSF.containskey(sp.campaignType)){
                            provisioningRec = mTypeToProvRecBSF.get(sp.campaignType);

                        }else{
                            continue;
                        }    
                        

                        if (enrolledCampaignSet != null && 
                                enrolledCampaignSet.contains(sp.campaignId)) {
                            selectedNHOCampaign = sp.campaignId;
                            isBSFEnrolled = true;
                        } else if (campaignMap.containsKey(sp.campaignType) && 
                                fullCampaignIdMap.containsKey(campaignMap.get(sp.campaignType))) {
                            selectedNHOCampaign = 
                                    fullCampaignIdMap.get(campaignMap.get(sp.campaignType));
                        }
                         //W-3289255 if user has not selected Bootcamp for sales and CSG new hires then BSF should be empty and disabled.                                        
                        if(selectedBootcampId == null && IsBSFDateBasedOnBootcamp){//When user loads page 3 first time ,should be unable to select BSF for sales and CSG
                           NHOdisabled = true;
                           selectedNHOCampaign = null;
                           return;
                        }
                        
                         system.debug(LOGGINGLEVEL.INFO,'selectedNHOCampaign so far..'+selectedNHOCampaign);
                        
                        if (selectedNHOCampaign == sp.campaignId || 
                                selectedNHOCampaign == 
                                fullCampaignIdMap.get(campaignMap.get(sp.campaignType)) &&
                                sp.campaignStartDate != null && newHireCase.NHW_Start_Date__c!=null && 
                                sp.campaignStartDate >= (newHireCase.NHW_Start_Date__c.addDays(provisioningRec.Lower_Cutoff__c.intValue())) 
                                && sp.campaignStartDate <= (newHireCase.NHW_Start_Date__c.addDays(provisioningRec.Upper_Cutoff__c.intValue()))
                           ){
                              
                               system.debug('inside eligible BSG check');
                               EligibleBSFCampaignList.add(sp);                                 
                                    
                               if(IsBSFDateBasedOnBootcamp){
                                    if( selectedBootcampId != null && selectedBootcampId != '' && 
                                       (sp.campaignStartDate <  fullCampaignMap.get(selectedBootcampId).campaignStartDate) ){
                                        EligibleBSFForBootcampList.add(sp);                                     
                                    }
                                    else{
                                        system.debug(LOGGINGLEVEL.INFO,'inside ineligible BSF based on Bootcamp date criteria');
                                    }
                               }else{                                        
                                     system.debug(LOGGINGLEVEL.INFO,'inside Non-BSF driven by bootcamp flow.');                                 
                               }    
                            
                            //system.debug(LOGGINGLEVEL.INFO,'NHOcampaignList inside selected NHO'+NHOcampaignList);
                        }
                        else{
                             system.debug(LOGGINGLEVEL.INFO,'inside ineligible BSF based on  newhire start date criteria ');
                            
                        }
                                 
                }
                //new SelectOption(sp.campaignId, sp.campaignName)
                system.debug(LOGGINGLEVEL.INFO,'EligibleBSFCampaignList' + EligibleBSFCampaignList);
                system.debug(LOGGINGLEVEL.INFO,'EligibleBSFForBootcampList' + EligibleBSFForBootcampList);
                

                if (EligibleBSFCampaignList != null && !EligibleBSFCampaignList.isEmpty()) {

                     list<String> nameList = new list<String>();
                     map<String, String> nameMap = new map<String, String>();
                     map<Date, list<NHW_Org62Service.CampaignResult>> mStartDateToCampaignresult = new map<Date,list<NHW_Org62Service.CampaignResult>>();//Group BSF campaigns by date.Assuming two BSFs dont start on same date.
                                        
                    //If  eligible BSF campaigns exist based out of bootcamp then we are showing the latest Eligible BSF based off the Bootcamp
                    if(IsBSFDateBasedOnBootcamp && !isBSFEnrolled && EligibleBSFForBootcampList != null && !EligibleBSFForBootcampList.isEmpty()){//Skip this flow if BSF is already enrolled.
                        //Grab dates to get latest available BSF
                        for(NHW_Org62Service.CampaignResult sp : EligibleBSFForBootcampList){
                            if(mStartDateToCampaignresult.containskey(sp.campaignstartdate)){
                               mStartDateToCampaignresult.get(sp.campaignstartdate).add(sp);
                            }else{
                                mStartDateToCampaignresult.put(sp.campaignstartdate,new list<NHW_Org62Service.CampaignResult>{sp});                             
                            }
                        }
                        
                        list<date> BSFStartDates = new list<date>(mStartDateToCampaignresult.keyset());
                        BSFStartDates.sort();
                        system.debug(LOGGINGLEVEL.INFO,'BSFStartDates'+BSFStartDates);
                        list<NHW_Org62Service.CampaignResult> latestBSFCampaigns = mStartDateToCampaignresult.get(BSFStartDates.get(BSFStartDates.size()-1));//Get campaign result correspondig to latest SD.
                        system.debug(LOGGINGLEVEL.INFO,'latestBSFCampaign'+latestBSFCampaigns);
                        
                        //reinitialize the BSF Eligible Campaign list  with BSF campaigns starting on the latest eligible date.
                        EligibleBSFCampaignList = new list<NHW_Org62Service.CampaignResult>(latestBSFCampaigns);
                   }
                   
            
 
                    for (NHW_Org62Service.CampaignResult sp : EligibleBSFCampaignList) {
                        nameList.add(sp.campaignName);
                        nameMap.put(sp.campaignName, sp.campaignId);
                    }

                    nameList.sort(); 
                    system.debug(LOGGINGLEVEL.INFO,'nameList ' + nameList);
                    
                    //W-3413415 Adding select option if there are more than one BSF items.
                    //Reason being - If we have more than one BSFs starting on same start date (due to diff locations - Eg:BSF HQ and BSF Indy),we don't want it to default it to first option.
                    //We want manager to explicity select one (based on employee location) before proceeding to page 4.
                    //Currently our bootcamp drive logic doesn't have location criteria as there is no field on campaigns to discern loc of BSFs.
                    
                    if(nameList.size()>1){
                      NHOcampaignList = new list<SelectOption>{new SelectOption('', '--Select--')};
                    }
                    else{
                      NHOcampaignList = new list<SelectOption>();                                           
                    }

                    for (String s : nameList) {
                        if (nameMap.containsKey(s)) {
                            NHOcampaignList.add(new SelectOption(nameMap.get(s), s));
                        }
                    }
                    system.debug(LOGGINGLEVEL.INFO,'NHOcampaignList ' + NHOcampaignList);
                }
    }

 
    @testvisible
    public void fillCampaignList() {
        
        isJapanEmployee=false;
        trainingList = new list<NHWWrapper.TrainingWrapper>();
        system.debug(LOGGINGLEVEL.INFO,'NHW_Training__c IN fillCampaignList :'+newHireCase.NHW_Training__c);
        skipPage3=false;
        if(SelectedRecruitmentDataObject.Region== 'Japan'){
                isJapanEmployee = true;
        }   
     
        Map<String, NHW_Provisioning_Default__c> trainingDefaultMap = 
                new Map<String, NHW_Provisioning_Default__c>();
                map<String, list<NHW_Org62Service.CampaignResult>> trainingMap = 
                        new map<String, list<NHW_Org62Service.CampaignResult>>();
                campaignMap = new map<String, String>();
                Integer colPos;
                NHWWrapper.TrainingWrapper tw;

                for (NHW_Provisioning_Default__c npc : [Select Controller__c, 
                                                        Controller__r.Name, 
                                                        Dependent__c, 
                                                        Dependent__r.Name, 
                                                        Dependent__r.Type__c, 
                                                        Dependent__r.Days_to_Exclude__c,
                                                        Type__c 
                                                        From NHW_Provisioning_Default__c 
                                                        Where (Controller__r.Name = 
                                                        :newHireCase.NHW_Role__c OR Controller__r.Name =: newHireCase.NHW_Organization__c)
                And Dependent__r.Type__c = 
                'Training']) {
                    trainingDefaultMap.put(npc.Dependent__r.Name, npc);
                }
                if (newHireCase.NHW_Training__c != null) {
                    for (String s : newHireCase.NHW_Training__c.split('<br />', 0)) {
                        if (s != null && s != '') {
                            colPos = s.indexOf('::');
                            if (colPos > 0) {
                                campaignMap.put(s.substring(0, colPos), s.substring(colPos + 2));
                            }
                        }
                    }
                }
                system.debug('fullCampaignMap'+fullCampaignMap);
                system.debug(LOGGINGLEVEL.INFO,'campaignMap'+campaignMap);
                system.debug(LOGGINGLEVEL.INFO,'trainingDefaultMap'+trainingDefaultMap);

                if(trainingDefaultMap.containsKey(NHW_Util.INTERNAL_TRAINING_SEBOOTCAMP_CAMPAIGN_TYPE)){
                    if(trainingDefaultMap.containsKey(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE)){
                        trainingDefaultMap.remove(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE);//SE folks want to go their own bootcamps and not sales.
                    }

                }

                //Required Bootcamps are skipped for Japan
                if(isJapanEmployee && (trainingDefaultMap.containsKey(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE) || trainingDefaultMap.containsKey(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE))){
                    skipPage3= true;
                    NHOdisabled = true;
                    return;
                }

                //W-3360653 Hide specialized training text if not available.
                if(trainingDefaultMap.size()>0){
                    hasSpecializedTraining = true;
                    //W-3289255 Populating training wrapper for bootcamps first as they drive BSF logic.              
                    for (NHW_Org62Service.CampaignResult sp : fullCampaignMap.values()) {
                    if (sp.campaignType != NHW_Util.INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE && sp.campaignType != NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE){
                         if (trainingDefaultMap.containsKey(sp.campaignType)) {
                            if (trainingDefaultMap.get(sp.campaignType).Dependent__r.Days_to_Exclude__c != null && 
                                    trainingDefaultMap.get(sp.campaignType).Dependent__r.Days_to_Exclude__c > 0) {
                                if (sp.campaignStartDate != null && newHireCase.NHW_Start_Date__c!=null && 
                                        sp.campaignStartDate > newHireCase.NHW_Start_Date__c.addDays(trainingDefaultMap.get(sp.campaignType).Dependent__r.Days_to_Exclude__c.intValue())) {
                                    if (trainingMap.containsKey(sp.campaignType)) {
                                        trainingMap.get(sp.campaignType).add(sp);
                                    } else {
                                        trainingMap.put(sp.campaignType, 
                                                new NHW_Org62Service.CampaignResult[]{sp});
                                    }   
                                }
                            } else {
                                if (trainingMap.containsKey(sp.campaignType)) {
                                    trainingMap.get(sp.campaignType).add(sp);
                                } else {
                                    trainingMap.put(sp.campaignType, 
                                            new NHW_Org62Service.CampaignResult[]{sp});
                                }
                            }
                        } else if (trainingDefaultMap.containsKey(sp.campaignItemId)) {
                            if (trainingDefaultMap.get(sp.campaignItemId).Dependent__r.Days_to_Exclude__c != null && 
                                    trainingDefaultMap.get(sp.campaignItemId).Dependent__r.Days_to_Exclude__c > 0) {
                                if (sp.campaignStartDate != null && newHireCase.NHW_Start_Date__c!=null && 
                                        sp.campaignStartDate > newHireCase.NHW_Start_Date__c.addDays(trainingDefaultMap.get(sp.campaignItemId).Dependent__r.Days_to_Exclude__c.intValue())) {
                                    if (trainingMap.containsKey(sp.campaignItemId)) {
                                        trainingMap.get(sp.campaignItemId).add(sp);
                                    } else {
                                        trainingMap.put(sp.campaignItemId, 
                                                new NHW_Org62Service.CampaignResult[]{sp});
                                    }   
                                }
                            } else {
                                if (trainingMap.containsKey(sp.campaignItemId)) {
                                    trainingMap.get(sp.campaignItemId).add(sp);
                                } else {
                                    trainingMap.put(sp.campaignItemId, 
                                            new NHW_Org62Service.CampaignResult[]{sp});
                                }
                            }
                        }
                      } 
                    }
                }
                else{//No Training defaults available for org/role
                    hasSpecializedTraining = false;
                    if(isJapanEmployee){
                        skipPage3=true;
                    }
                }
                /*if(trainingMap.size()==0){//Current specialized trainings dint match date criteria.
                    hasSpecializedTraining = false;                 
                }*/

                for (String s : trainingDefaultMap.keySet()) {
                    tw = new NHWWrapper.TrainingWrapper(s);
                    if (trainingMap.containsKey(s)) {
                        for (NHW_Org62Service.CampaignResult sp : trainingMap.get(s)) {
                            if (enrolledCampaignSet != null && 
                                    enrolledCampaignSet.contains(sp.campaignId)) {
                                tw.selectedCampaign = sp.campaignId;
                                tw.disabled = true;
                            }
                            else if (campaignMap.containsKey(tw.Name) && 
                                    fullCampaignIdMap.containsKey(campaignMap.get(tw.Name))) {
                                tw.selectedCampaign = 
                                        fullCampaignIdMap.get(campaignMap.get(tw.Name));
                            }
                            tw.campaignList.add(new SelectOption(sp.campaignId, sp.campaignName));
                            system.debug('tw before after condition ' + tw);    
                        }
                    }
                    if (tw.campaignList.size() == 0) {
                        system.debug('tw.campaignList ' + tw.campaignList);
                        tw.campaignList = new list<SelectOption>();
                        tw.campaignList.add(new SelectOption('', '--No Trainings Available--'));
                    }
                    if (tw.campaignList != null && !tw.campaignList.isEmpty()) {
                        list<String> nameList = new list<String>();
                        map<String, String> nameMap = new map<String, String>();

                        for (SelectOption s1 : tw.campaignList) {
                            nameList.add(s1.getLabel());
                            nameMap.put(s1.getLabel(), s1.getValue());
                        }

                        nameList.sort();
                        tw.campaignList = new list<SelectOption>();
                        for (String s1 : nameList) {
                            if (nameMap.containsKey(s1)) {
                                tw.campaignList.add(new SelectOption(nameMap.get(s1), s1));
                            }
                        }
                    }
                    trainingList.add(tw);
                }
                //W-3289255 Moving BSF Logic after bootcamp training wrapper population as they drive BSF campaign selection.   
                BSFForBootcamp();                               


               

    }
    public void BSFForBootcamp(){

          NHOdisabled = false;
          isBSFEnrolled = false;
          NHOcampaignList = new list<SelectOption>{new SelectOption('', '--Select--')};
          selectedNHOCampaign=null;
          
      
          EligibleBSFCampaignList = new list<NHW_Org62Service.CampaignResult>();
          EligibleBSFForBootcampList = new list<NHW_Org62Service.CampaignResult>();
          
          Boolean IsBSFDateBasedOnBootcamp = false;
          
          if( newHireCase.NHW_Organization__c =='Sales' && (newhirecase.NHW_role__c!='Solution Engineer - CBU' && newhirecase.NHW_role__c !='Solution Engineer - EBU' && newhirecase.NHW_role__c !='Solution Engineer - Other'  )
            || newHireCase.NHW_Organization__c =='CSG'  ||
              (newHireCase.NHW_Organization__c =='Marketing Cloud' && (newhirecase.NHW_role__c=='Services' || newhirecase.NHW_role__c=='Sales'))
            ){
             IsBSFDateBasedOnBootcamp = true;
          }
          system.debug(LOGGINGLEVEL.INFO,'IsBSFDateBasedOnBootcamp:'+IsBSFDateBasedOnBootcamp);
          
          for(NHWWrapper.TrainingWrapper tw:traininglist){
            if(tw.name.containsIgnoreCase(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE) || tw.name.containsIgnoreCase(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE) ){
                selectedBootcampId = tw.selectedcampaign;       
                system.debug(LOGGINGLEVEL.INFO,'selectedBootcampId inside CSG/Sales loop' +selectedBootcampId);
                                    
            }           
          }
          system.debug(LOGGINGLEVEL.INFO,'selectedBootcampId from traininglist' +selectedBootcampId);
          

          
          for (NHW_Org62Service.CampaignResult sp : fullCampaignMap.values()) {
                     if (sp.campaignType == NHW_Util.INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE || sp.campaignType == NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE) {
                        
                        //W-3265189 Logic to surface ONLY campaigns of type relevant to new hire Org/Role.
                        if(newHireCase.NHW_Organization__c =='Marketing Cloud'){
                            if(sp.campaignType == NHW_Util.INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE 
                            && (newHireCase.NHW_Role__c == 'Services' || newHireCase.NHW_Role__c =='Sales')){
                                continue; //Campaigns of this type needs to be skipped from surfacing for this new hire case.;
                            }
                            if(sp.campaignType == NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE 
                            && (newHireCase.NHW_Role__c != 'Services' && newHireCase.NHW_Role__c !='Sales')){
                                continue; //Campaigns of this type needs to be skipped from surfacing for this new hire case;
                            }                       
                        }else{
                            if(sp.campaignType == NHW_Util.INTERNAL_TRAINING_NONSALES_CAMPAIGN_TYPE 
                            && (newHireCase.NHW_Organization__c =='Sales' || newHireCase.NHW_Organization__c == 'Sales Support' || newHireCase.NHW_Organization__c =='CSG')){
                                continue; //Campaigns of this type needs to be skipped from surfacing for this new hire case.;
                            }
                            if(sp.campaignType == NHW_Util.INTERNAL_TRAINING_SALES_CAMPAIGN_TYPE 
                            && (newHireCase.NHW_Organization__c !='Sales' && newHireCase.NHW_Organization__c != 'Sales Support' && newHireCase.NHW_Organization__c !='CSG')){
                                continue; //Campaigns of this type needs to be skipped from surfacing for this new hire case;
                            }                           
                        }
                        

                        if (enrolledCampaignSet != null && 
                                enrolledCampaignSet.contains(sp.campaignId)) {
                            selectedNHOCampaign = sp.campaignId;
                            isBSFEnrolled = true;
                        } else if (campaignMap.containsKey(sp.campaignType) && 
                                fullCampaignIdMap.containsKey(campaignMap.get(sp.campaignType))) {
                            selectedNHOCampaign = 
                                    fullCampaignIdMap.get(campaignMap.get(sp.campaignType));
                        }
                         //W-3289255 if user has not selected Bootcamp for sales and CSG new hires then BSF should be empty and disabled.                                        
                        if(selectedBootcampId == null && IsBSFDateBasedOnBootcamp){//When user loads page 3 first time ,should be unable to select BSF for sales and CSG
                           NHOdisabled = true;
                           selectedNHOCampaign = null;
                           return;
                        }
                        
                         system.debug(LOGGINGLEVEL.INFO,'selectedNHOCampaign so far..'+selectedNHOCampaign);
                        
                        if (selectedNHOCampaign == sp.campaignId || 
                                selectedNHOCampaign == 
                                fullCampaignIdMap.get(campaignMap.get(sp.campaignType)) &&
                                (sp.campaignStartDate != null && newHireCase.NHW_Start_Date__c!=null && 
                                sp.campaignStartDate >= (newHireCase.NHW_Start_Date__c + 1) && sp.campaignStartDate <= (newHireCase.NHW_Start_Date__c + 119) )
                           ){
                              
                               system.debug('inside eligible BSG check');
                               EligibleBSFCampaignList.add(sp);                                 
                                    
                               if(IsBSFDateBasedOnBootcamp){
                                    if( selectedBootcampId != null && selectedBootcampId != '' && 
                                       (sp.campaignStartDate <  fullCampaignMap.get(selectedBootcampId).campaignStartDate) ){
                                        EligibleBSFForBootcampList.add(sp);                                     
                                    }
                                    else{
                                        system.debug(LOGGINGLEVEL.INFO,'inside ineligible BSF based on Bootcamp date criteria');
                                    }
                               }else{                                        
                                     system.debug(LOGGINGLEVEL.INFO,'inside Non-BSF driven by bootcamp flow.');                                 
                               }    
                            
                            //system.debug(LOGGINGLEVEL.INFO,'NHOcampaignList inside selected NHO'+NHOcampaignList);
                        }
                        else{
                             system.debug(LOGGINGLEVEL.INFO,'inside ineligible BSF based on  newhire start date criteria ');
                            
                        }
                    }              
                }
                //new SelectOption(sp.campaignId, sp.campaignName)
                system.debug(LOGGINGLEVEL.INFO,'EligibleBSFCampaignList' + EligibleBSFCampaignList);
                system.debug(LOGGINGLEVEL.INFO,'EligibleBSFForBootcampList' + EligibleBSFForBootcampList);
                

                if (EligibleBSFCampaignList != null && !EligibleBSFCampaignList.isEmpty()) {

                     list<String> nameList = new list<String>();
                     map<String, String> nameMap = new map<String, String>();
                     map<Date, list<NHW_Org62Service.CampaignResult>> mStartDateToCampaignresult = new map<Date,list<NHW_Org62Service.CampaignResult>>();//Group BSF campaigns by date.Assuming two BSFs dont start on same date.
                                        
                    //If  eligible BSF campaigns exist based out of bootcamp then we are showing the latest Eligible BSF based off the Bootcamp
                    if(IsBSFDateBasedOnBootcamp && !isBSFEnrolled && EligibleBSFForBootcampList != null && !EligibleBSFForBootcampList.isEmpty()){//Skip this flow if BSF is already enrolled.
                        //Grab dates to get latest available BSF
                        for(NHW_Org62Service.CampaignResult sp : EligibleBSFForBootcampList){
                            if(mStartDateToCampaignresult.containskey(sp.campaignstartdate)){
                               mStartDateToCampaignresult.get(sp.campaignstartdate).add(sp);
                            }else{
                                mStartDateToCampaignresult.put(sp.campaignstartdate,new list<NHW_Org62Service.CampaignResult>{sp});                             
                            }
                        }
                        
                        list<date> BSFStartDates = new list<date>(mStartDateToCampaignresult.keyset());
                        BSFStartDates.sort();
                        system.debug(LOGGINGLEVEL.INFO,'BSFStartDates'+BSFStartDates);
                        list<NHW_Org62Service.CampaignResult> latestBSFCampaigns = mStartDateToCampaignresult.get(BSFStartDates.get(BSFStartDates.size()-1));//Get campaign result correspondig to latest SD.
                        system.debug(LOGGINGLEVEL.INFO,'latestBSFCampaign'+latestBSFCampaigns);
                        
                        //reinitialize the BSF Eligible Campaign list  with BSF campaigns starting on the latest eligible date.
                        EligibleBSFCampaignList = new list<NHW_Org62Service.CampaignResult>(latestBSFCampaigns);
                   }
                   
            
 
                    for (NHW_Org62Service.CampaignResult sp : EligibleBSFCampaignList) {
                        nameList.add(sp.campaignName);
                        nameMap.put(sp.campaignName, sp.campaignId);
                    }

                    nameList.sort(); 
                    system.debug(LOGGINGLEVEL.INFO,'nameList ' + nameList);
                    
                    //W-3413415 Adding select option if there are more than one BSF items.
                    //Reason being - If we have more than one BSFs starting on same start date (due to diff locations - Eg:BSF HQ and BSF Indy),we don't want it to default it to first option.
                    //We want manager to explicity select one (based on employee location) before proceeding to page 4.
                    //Currently our bootcamp drive logic doesn't have location criteria as there is no field on campaigns to discern loc of BSFs.
                    
                    if(nameList.size()>1){
                      NHOcampaignList = new list<SelectOption>{new SelectOption('', '--Select--')};
                    }
                    else{
                      NHOcampaignList = new list<SelectOption>();                                           
                    }

                    for (String s : nameList) {
                        if (nameMap.containsKey(s)) {
                            NHOcampaignList.add(new SelectOption(nameMap.get(s), s));
                        }
                    }
                    system.debug(LOGGINGLEVEL.INFO,'NHOcampaignList ' + NHOcampaignList);
                }
    }
    private void loadCaseWithRecruitmentData(){

        newHireCase.NHW_Job_Application__c = SelectedRecruitmentDataObject.ModelId;
        newHireCase.Offer_Type__c = SelectedRecruitmentDataObject.OfferType;
        newHireCase.Resource_Type__c = SelectedRecruitmentDataObject.ResourceType;
        newHireCase.NHW_Employee__c = SelectedRecruitmentDataObject.EmployeeContactId;
        newHireCase.NH_Employee_Id__c = SelectedRecruitmentDataObject.EmployeeNumber;
        newHireCase.First_Name__c = SelectedRecruitmentDataObject.FirstName;
        newHireCase.Last_Name__c = SelectedRecruitmentDataObject.LastName;
        newHireCase.Subject = 'New Hire Provisioning Request for ' + 
                newHireCase.First_Name__c + ' ' + newHireCase.Last_Name__c;
        newHireCase.Company__c = SelectedRecruitmentDataObject.CompanyId;
        newHireCase.Company_Agency_Name__c = SelectedRecruitmentDataObject.CompanyAgencyName;
        newHireCase.Primary_Coverage_Country__c = SelectedRecruitmentDataObject.PrimaryCoverageCountry;
        newHireCase.Job_Status__c = SelectedRecruitmentDataObject.JobStatus;
        newHireCase.Business_Title__c = SelectedRecruitmentDataObject.BusinessTitle;
        newHireCase.Business_Unit_NHW__c = SelectedRecruitmentDataObject.BusinessUnitName;
        newHireCase.Cost_Center_NHW__c =  SelectedRecruitmentDataObject.CostCenterName;
        newHireCase.NHW_Business_Unit__c = SelectedRecruitmentDataObject.BusinessUnitId;
        newHireCase.NHW_Cost_Center__c =  SelectedRecruitmentDataObject.CostCenterId;
        newHireCase.NHW_Start_Date__c = SelectedRecruitmentDataObject.StartDate;
        newHireCase.NH_Personal_Email__c = String.valueOf(SelectedRecruitmentDataObject.PersonalEmail);  

        newHireCase.NH_Business_Site__c = SelectedRecruitmentDataObject.BusinessSiteId;
        newHireCase.Office_Address__c =SelectedRecruitmentDataObject.OfficeAddress;
        newHireCase.Office_City__c =SelectedRecruitmentDataObject.OfficeCity;
        newHireCase.Office_State_Province__c = SelectedRecruitmentDataObject.OfficeStateProvince;
        newHireCase.Office_Zip_Postal_Code__c =SelectedRecruitmentDataObject.OfficeZipPostalCode;
        newHireCase.Office_Country__c = SelectedRecruitmentDataObject.OfficeCountry;
        newHireCase.Manager_Name__c = SelectedRecruitmentDataObject.ManagerContactId;
        newHireCase.Manager_s_Email__c = SelectedRecruitmentDataObject.Manager_s_Email;
        newHireCase.Email_Address__c = SelectedRecruitmentDataObject.supportforceEmail;
        newHireCase.End_Date__c = SelectedRecruitmentDataObject.EndDate;

        //TODO:isSameAsOfficeChecked var is either misused or redundant.Need to verify if it is valid.
         if(this.isSameAsOfficeChecked){
            system.debug('**** setting Same_as_Office_Location__c to true from loadCaseWithRecruitmentData');
            newHireCase.Same_as_Office_Location__c = true;
            this.isSameAsOfficeChecked = false;
        }

    }

    private void populateNewCase() {
        //refreshCaseFromPlacement();

        loadCaseWithRecruitmentData();
       
        newHireCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        newHireCase.NHW_Employee_Type__c = 'Regular Employee';
        newHireCase.Origin = 'NHW';
        newHireCase.Internal_Support_Category__c = 
                'New Hire Onboarding Request - Employee'; 
        newHireCase.NH_Is_Exact_Target__c = isExactTarget;                

    }

    @testvisible
    private void loadCampaignsAndContact()
    { 
        fullCampaignMap = new map<Id, NHW_Org62Service.CampaignResult>();
        fullCampaignIdMap = new map<String, String>();
        try{
            // if(!newHireCase.NH_Is_Exact_Target__c){
            NHW_Org62Service.Org62Data o6d = NHW_Org62Service.getCampaignResults(newHireCase.Email_Address__c, newHireCase.First_Name__c + ' ' + newHireCase.Last_Name__c);
            if (o6d != null) {
                if (o6d.campaignList != null && !o6d.campaignList.isEmpty()) {
                    for (NHW_Org62Service.CampaignResult sp : o6d.campaignList) {
                        system.debug(sp.campaignType);
                        system.debug(sp.campaignName);
                        fullCampaignMap.put(sp.campaignId, sp);
                        fullCampaignIdMap.put(sp.campaignName, sp.campaignId);
                    }
                }

                org62ContactId = o6d.contactId;
                if (o6d.campaignMemberList != null && !o6d.campaignMemberList.isEmpty()) {
                    for (NHW_Org62Service.CampaignMemberResult sp : 
                        o6d.campaignMemberList) {
                        if (sp.contactId == org62ContactId) {
                            enrolledCampaignSet.add(sp.campaignId);
                        }
                    }
                }
            }
        }
        catch(Exception Ex){
            system.debug('************* exception in loamCampaigns method ' + ex.getLineNumber() + ex.getMessage());
        }

    }

    private Boolean generateTrainingText() {
        newHireCase.NHW_Training__c = '';
        newHireCase.NH_Training_Email_Merge__c = '';
        
        system.debug('trainingList in generateTrainingText:'+trainingList);
        for (NHWWrapper.TrainingWrapper tw : trainingList) {
            if (tw.hasCampaigns) {
                if (String.isNotBlank(tw.selectedCampaign)) {
                    if (fullCampaignMap != null && fullCampaignMap.containsKey(tw.selectedCampaign)) {
                        newHireCase.NHW_Training__c +=  tw.name + '::' + fullCampaignMap.get(tw.selectedCampaign).campaignName+'<br />' ;                      
                        newHireCase.NH_Training_Email_Merge__c += fullCampaignMap.get(tw.selectedCampaign).campaignName+'<br /><br />';
                    } else {
                        newHireCase.NHW_Training__c +=  tw.name + '::' + tw.selectedCampaign + '<br />' ;
                        newHireCase.NH_Training_Email_Merge__c += tw.selectedCampaign + '<br /><br />' ;
                    }
                }
            }
        }
        if ( selectedNHOCampaign != '' && selectedNHOCampaign != null) {//Suppressing null to be printed

            newHireCase.NHW_Training__c += 'Internal - New Hire Orientation::';

            if (fullCampaignMap != null && fullCampaignMap.containsKey(selectedNHOCampaign)) {
                newHireCase.NHW_Training__c += fullCampaignMap.get(selectedNHOCampaign).campaignName;
                newHireCase.NH_Training_Email_Merge__c += fullCampaignMap.get(selectedNHOCampaign).campaignName;
            } else {
                newHireCase.NHW_Training__c += selectedNHOCampaign;
                newHireCase.NH_Training_Email_Merge__c += selectedNHOCampaign;
            }

        }
        system.debug(LOGGINGLEVEL.INFO,'NHW_Training__c IN generateTrainingText :'+newHireCase.NHW_Training__c);
        
        return true;

    }

    public Boolean createAccessField() {
        set<Id> userIdSet = new set<Id>();
        List<NHW_AccessCode> accessCodeList = new List<NHW_AccessCode>();

        if(fullAccessList != null && fullAccessList.size() > 0){
            for (NHWWrapper.OnboardingWrapper ow : fullAccessList) {
                for (NHW_AccessWrapper aw : ow.accessList) {
                    if (aw.selected) {
                        if( (aw.item.Name==System.Label.NHW_GUS_SST && aw.gusSSTHolder!=null) || (aw.item.Name == System.Label.NHW_Supportforce_SST && aw.sfSSTHolder!=null) || (aw.item.Name== System.Label.NHW_Org62_SST && (aw.org62Holder!=null && aw.org62Holder!='') ) ){
                            
                        } else if((aw.item.Name==System.Label.NHW_GUS_SST && aw.gusSSTHolder == null) || (aw.item.Name == System.Label.NHW_Supportforce_SST && aw.sfSSTHolder == null) || (aw.item.Name == System.Label.NHW_Org62_SST && (aw.org62Holder == null ||  aw.org62Holder == '') ) ){
                            
                        }

                    }
                }
            }
        }
        map<Id, User> userMap = new map<Id, User>([Select Id, Name, FirstName, LastName From User  Where Id IN : userIdSet]);
        if(fullAccessList != null && fullAccessList.size() > 0){           
            for (NHWWrapper.OnboardingWrapper ow : fullAccessList) {
                List<NHW_AccessDetails> accessDetails = new List<NHW_AccessDetails>(); 
                for (NHW_AccessWrapper aw : ow.accessList) {
                    if (aw.selected) {
                        
                        if(aw.item.Name != 'Business Objects'){
                            NHW_AccessDetails details = new NHW_AccessDetails();
                            details.name = aw.item.Name;
                            details.isc = aw.item.Supportforce_ISC__c;
                            details.category = aw.item.Onboarding_Category__c;

                            if(aw.item.Name== System.Label.NHW_Org62_SST){
                                details.org62SST = aw.org62Holder;

                            } else if (aw.item.Name == System.Label.NHW_GUS_SST) {
                                details.gusSST = aw.gusSSTHolder;
                            } else if(aw.item.Name == System.Label.NHW_Supportforce_SST) {
                                details.sfSSt = aw.sfSSTHolder;
                            }  
                            accessDetails.add(details);
                        }else{ //Sreedhar W-3181896: Add multiselect sub options for Business Objects Option under "Cloud Application (Non Force.com)".
                            if(newHireCase != null && newHireCase.Business_Objects__c != null){
                                List<String> businessObjectOptions = newHireCase.Business_Objects__c.split(';');
                                for(String option: businessObjectOptions){
                                    NHW_AccessDetails details = new NHW_AccessDetails();
                                    details.name = aw.item.Name + ' - ' + option;
                                    details.isc = aw.item.Supportforce_ISC__c;
                                    details.category = aw.item.Onboarding_Category__c;
                                    details.userToClone =  'No User Needed';
                                    accessDetails.add(details);
                                }
                            }else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                        'You must select at least one option for Business Objects access.'));
                                                return false;
                            }
                        }
                        
                    }
                }
                accessCodeList.add(new NHW_AccessCode(ow.accessType,accessDetails));
            }
        }
        List<NHW_AccessDetails> accessDetails = new List<NHW_AccessDetails>();
        if(useNewConfigForDeskPhone){
                if(!isRemote){
                    List<NHW_Provisioning__c> ApplicableDeskphones = NHW_ProvisioningStore.getProvisionings(newhirecase,'Mobile');
                    ApplicableDeskphones = [Select Id, Name, Onboarding_Category__c, 
                                            Need_User_to_Clone__c, Filter_Criteria__c,Filter_Required__c,Is_Auto_Provisioned__c,
                                            Supportforce_ISC__c, Include_for_ET_Employees__c,Auto_Display__c,
                                            Type__c, Onboarding_Type__c,Organization__r.Name,Organization__c
                                            From NHW_Provisioning__c
                                            Where Type__c = 'Mobile' and id in :ApplicableDeskphones];

                    for(NHW_Provisioning__c provRec:ApplicableDeskphones){
                        SYSTEM.DEBUG(LOGGINGLEVEL.INFO,'Is_Auto_Provisioned__c '+provRec.is_Auto_Provisioned__c);
                        SYSTEM.DEBUG(LOGGINGLEVEL.INFO,'User selected'+newHireCase.Desk_and_VoiceMail__c);
                        //Check if provisioning qualifies for Auto Provisioning or if user selected as Yes.
                        if(provRec.Is_Auto_Provisioned__c || (!provRec.is_Auto_Provisioned__c && (displayDeskPhoneOption && newHireCase.Desk_and_VoiceMail__c == 'Yes'))){
                            NHW_AccessDetails detailsForJson = new NHW_AccessDetails();
                            detailsForJson.name = provRec.Name;
                            detailsForJson.isc = provRec.Supportforce_ISC__c;
                            detailsForJson.category = provRec.Onboarding_Category__c;
                            accessDetails.add(detailsForJson);
                            newHireCase.Desk_and_VoiceMail__c = 'Yes';  
                        }
                    }
                  
                }


        }else{
             for (NHW_Provisioning__c noi : [Select Id, Name, Onboarding_Category__c, 
                                        Need_User_to_Clone__c, Filter_Criteria__c,Filter_Required__c,
                                        Supportforce_ISC__c, Include_for_ET_Employees__c,Auto_Display__c,
                                        Type__c, Onboarding_Type__c,Organization__r.Name,Organization__c
                                        From NHW_Provisioning__c
                                        Where (Type__c = 'Mobile')]) {
                    system.debug('*****mobileNoi & isRemote ' + noi.Name + ' ' + isRemote); 
                    system.debug('****newHireCase.NHW_Organization__c & newHireCase.NHW_Role__c ' + newHireCase.NHW_Organization__c + ' ' + newHireCase.NHW_Role__c);

                    if(noi.Name == 'Phone and Voicemail - i3' && !isRemote){
                        if((NHW_Util.deskPhoneI3Countries != null && NHW_Util.deskPhoneI3Countries.get(newHireCase.Office_Country__c) != null) || 
                            NHW_Util.deskPhoneI3Cities != null && NHW_Util.deskPhoneI3Cities.get(newHireCase.Office_City__c) != null){
                            if((newHireCase.NHW_Organization__c == 'Marketing Cloud' && newHireCase.NHW_Role__c == 'Support') || newHireCase.Desk_and_VoiceMail__c == 'Yes'){
                                newHireCase.Desk_and_VoiceMail__c = 'Yes';
                                system.debug('***have set Desk_and_VoiceMail__c field ' + newHireCase.Desk_and_VoiceMail__c);
                                
                                NHW_AccessDetails detailsForJson = new NHW_AccessDetails();
                                detailsForJson.name = noi.Name;
                                detailsForJson.isc = noi.Supportforce_ISC__c;
                                detailsForJson.category = noi.Onboarding_Category__c;
                                accessDetails.add(detailsForJson);
                                newHireCase.Desk_and_VoiceMail__c = 'Yes';
                            }
                        }
                        //I3 AND CISCO combo provisioning has been removed.
                        /*else {
                            if(newHireCase.NHW_Organization__c == 'Marketing Cloud' && newHireCase.NHW_Role__c == 'Support'){
                                
                                newHireCase.Desk_and_VoiceMail__c = 'Yes';
                                system.debug('***have set Desk_and_VoiceMail__c field ' + newHireCase.Desk_and_VoiceMail__c);

                                NHW_AccessDetails detailsForJson = new NHW_AccessDetails();
                                detailsForJson.name = noi.Name;
                                detailsForJson.isc = noi.Supportforce_ISC__c;
                                detailsForJson.category = noi.Onboarding_Category__c;
                                accessDetails.add(detailsForJson);
                                newHireCase.Desk_and_VoiceMail__c = 'Yes';
                                system.debug('***have set Desk_and_VoiceMail__c field ' + newHireCase.Desk_and_VoiceMail__c);
                            }  
                        }*/
                    }
                    if(noi.Name == 'Phone and Voicemail - Cisco' && !isRemote){
                        if((NHW_Util.deskPhoneI3Countries != null && NHW_Util.deskPhoneI3Countries.get(newHireCase.Office_Country__c) == null) && 
                            (NHW_Util.deskPhoneI3Cities != null && NHW_Util.deskPhoneI3Cities.get(newHireCase.Office_City__c) == null)){
                            if((newHireCase.NHW_Organization__c == 'Marketing Cloud' && newHireCase.NHW_Role__c == 'Support') || (newHireCase.Desk_and_VoiceMail__c == 'Yes')){
                                NHW_AccessDetails detailsForJson = new NHW_AccessDetails();
                                detailsForJson.name = noi.Name;
                                detailsForJson.isc = noi.Supportforce_ISC__c;
                                detailsForJson.category = noi.Onboarding_Category__c;
                                accessDetails.add(detailsForJson);
                            }      
                        }    
                    } 
            }
 
        }
        accessCodeList.add(new NHW_AccessCode('Mobile',accessDetails));
        System.debug(JSON.serialize(accessCodeList));
        newHireCase.NHW_Access_Code__c = Json.serialize(accessCodeList);
        return true;
    }     

    /* Dml methods */
    private Boolean updateCase()
    {
        newHireCase.NHW_Page_Number__c = currentPageNumber;
        try
        {
            if (newHireCase.Id == null) {
                refreshETFields();
                insert newHireCase;
                list<Case> preBoardingCaseList = new list<Case>();
                if(SelectedRecruitmentDataObject!= null){//Excluding Contractors and reloc as they don't have RecruitmentModelobject
                    for (Case c : [Select Id, NHW_Send_Reminder__c
                                From Case
                                Where NHW_Send_Reminder__c = true and NHW_Job_Application__c = :SelectedRecruitmentDataObject.ModelId and recordTypeId=:NHW_Util.getnhwPreBoardCaseRecordTypeId()]) {
                                    c.NHW_Send_Reminder__c = false;
                                    preBoardingCaseList.add(c);
                                }
                    
                    try {
                        update preBoardingCaseList;
                    } catch (Exception e1) {
                        ApexPages.addMessages(e1);
                    }  
                }
          
            } else {
                update newHireCase;
            }
            return true;
        }
        catch (Exception e)
        {
            system.debug(LoggingLevel.INFO,'Exception in UpdateCase()');
            ApexPages.addMessages(e);
            return false;
        }
    }


    private Boolean createCampaignMember() {
        List<String> campaignsInfo = new List<String>();
        try {
            if (org62ContactId == null || org62ContactId == '') {
                try {
                    TF2_Company__c comp = [Select Id, Name From TF2_Company__c Where Id =: newHireCase.Company__c];
                    companyNameOrg62String = comp.Name;
                } catch (Queryexception qe) {
                    companyNameOrg62String = null;
                }
                String trailGuideContactId = '';
                if(newHireCase.Onboarding_Buddy_Email__c != null){
                    List<Contact> org62Contacts = NHW_Org62Service.org62Contacts(newHireCase.Onboarding_Buddy_Email__c);
                    if(!org62Contacts.isEmpty()){
                        trailGuideContactId = org62Contacts[0].Id;
                    }else{
                        PF_Logger.log('NHW','WARNING','Org62 query for Employee contact with Email ' +newHireCase.Onboarding_Buddy_Email__c+' returned no contacts.', 'Trail Guide Query', 'Org62 query for Employee contact with Email ' +newHireCase.Onboarding_Buddy_Email__c+' returned no contacts. Queried contact for salesforce.com account', 'NewHireWizardController', newHireCase.First_Name__c + ' '+newHireCase.Last_Name__c);
                        PF_Logger.createLogs(PF_Logger.logs);
                    }
                }

                org62ContactId = newHireCase.First_Name__c + ';' + 
                newHireCase.Last_Name__c + ';' +
                newHireCase.Email_address__c + ';' +
                newHireCase.Manager_s_Email__c + ';' +
                newHireCase.NHW_Start_Date__c + ';' +
                newHireCase.NHW_Role__c + ';' +
                newHireCase.Business_Title__c + ';' +
                companyNameOrg62String + ';' + newHireCase.Business_Unit_NHW__c + ';' +
                newHireCase.NH_Is_Exact_Target__c+';'+
                trailGuideContactId;                  

            }
            if (selectedNHOCampaign != null && selectedNHOCampaign != '') {
                if (enrolledCampaignSet != null && 
                        !enrolledCampaignSet.contains(selectedNHOCampaign)) {
                    campaignsInfo.add(selectedNHOCampaign);
                }
            }
            if (trainingList != null) 
            {  
                for (NHWWrapper.TrainingWrapper tw : trainingList) {
                    if (tw.selectedCampaign != null && tw.selectedCampaign != '') {
                        if (enrolledCampaignSet != null && 
                                !enrolledCampaignSet.contains(tw.selectedCampaign)) {
                            campaignsInfo.add(tw.selectedCampaign);

                        }
                    }
                }
                NHW_Org62Service.org62CallOut(
                        'createCampaignMember',campaignsInfo, 
                        org62ContactId,newHireCase.First_Name__c + ' ' + newHireCase.Last_Name__c);

            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return false;
        }
        return true;
    }

    /* PageReference methods */
    public PageReference cancel() {

        PageReference pageRef; // = Page.NewHireWizard_1_0; //Commented because of dependency. If dependency occuers cant able delete NewHireWizard_1_0 Page and we will be going to delete this class after delpoying this QA4.
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference previous() {
        if (currentPageNumber == 3 && newHireCase.NHW_Employee__c != null) {
            if (!generateTrainingText()) {
                return null;
            }
        }
        if(currentPageNumber == 3){
            if(selectedStartAction == 'contractor' && (newHireCase.Contractor_Hire_Reason__c == 'Badge-Only' ||
                             newHireCase.Contractor_Hire_Reason__c == 'Temp Receptionist')){
                currentPageNumber--; 
            }
        }
        if(currentPageNumber == 4){
            //Skip Page 3 if Japan employee doesn't have any specialized trainings.
            if(useNewConfigForBootcamps){
                if(!hasSpecializedTraining && !hasBSF){
                    currentPageNumber--;                 
                }
            }else{
                if((isJapanEmployee && skipPage3)){
                    currentPageNumber--;                 
                }

            }

        }
        if(currentPageNumber==2){
            createAccessField();
            refreshETFields();
            this.isRemoteExecuted = false;
        }
        currentPageNumber--;
        if (!updateCase()) {
            currentPageNumber++;
        } else if (currentPageNumber == 2 && 
                (newHireCase.NHW_Access_Code__c == '' || 
                newHireCase.NHW_Access_Code__c == null)) {
            loadDefaultAccess();
            //loadAccessList();
        } else if (currentPageNumber == 3) {
            System.debug(LOGGINGLEVEL.INFO,useNewConfigForBootcamps);
            if(useNewConfigForBootcamps){
                getTrainings();
            }else{
                fillCampaignList();
            }
        }
        return null;
    }

    public PageReference next() {

        if (currentPageNumber == 3 && newHireCase.NHW_Employee__c != null) {
            refreshETFields();
            if (!generateTrainingText()) {
                return null;
            }
            
            if(useNewConfigForBootcamps){
                for(NHWWrapper.TrainingWrapper tw:traininglist){
                    if(tw.required == true && tw.selectedcampaign == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select the required trainings(s) before proceeding to the next page.'));                                                                                   
                        system.debug('inside Bootcamp not selected.');  
                        return null;                                                            
                    }           
                }
            }else{
                for(NHWWrapper.TrainingWrapper tw:traininglist){
                    if(tw.name.containsIgnoreCase(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE) || tw.name.containsIgnoreCase(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE) ){
                        if(tw.selectedcampaign == null){
                            if(tw.name.containsIgnoreCase(NHW_Util.INTERNAL_TRAINING_SALESBOOTCAMP_CAMPAIGN_TYPE)){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a Sales Bootcamp before proceeding to the next page.'));                                                        
                            }else if(tw.name.containsIgnoreCase(NHW_Util.INTERNAL_TRAINING_CSGBOOTCAMP_CAMPAIGN_TYPE)){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a CSG Bootcamp before proceeding to the next page.'));                                                      
                            }
                            system.debug('inside Bootcamp not selected.');  
                            return null;                    
                        }                                           
                    }           
                }
            }

            if( !isJapanEmployee && validateBecomeingSalesforceTraining && (selectedNHOCampaign == null)){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select a Becoming Salesforce campaign before proceeding to the next page.'));    
                 system.debug('inside BSF campaign not selected.');
                 return null;                   
            }           


        }
        if (currentPageNumber == 2) {
            //system.debug('******isRemote ' + isRemote);
            if (NHWHelper.needsEquipment(newHireCase)) {
                if(newHireCase!=null && newHireCase.NH_Is_Exact_Target__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                            'You must select laptop.'));
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                            'You must select both a desktop and laptop.'));
                }
                return null;
            } else if (!newHireCase.Existing_Equipment__c && newHireCase.Computer_Type__c != 'Not Required' && newHireCase.Floor_Location_Cube_Location__c == null && newHireCase.Location_Type__c != 'Remote - Home Office') {
                newHireCase.Floor_Location_Cube_Location__c.addError('Floor Location/Cube Location is required when a desktop is selected');
                return null;
            }
            else if (!createAccessField()) {
                return null;
            }
            else if (newHireCase!=null && newHireCase.NH_Is_Exact_Target__c && (newHireCase.NHW_Role__c == 'Services' || 
                    (newHireCase.NHW_Role__c == 'Support' && newHireCase.NH_ET_Team__c == 'Platinum')) && newhireCase.NH_Open_Air_Role__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must select a PSE Role'));    
                return null;
            }
            else if (newHireCase!=null && newHireCase.Mobile_Phone_Required__c == '--Select--'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Does the employee need a mobile phone? Please select yes or no.'));    
                return null;
            }
        } else if (currentPageNumber == 1) {

            if (newHireCase.NHW_Employee_Type__c != 'Regular Employee') {
                if(selectedStartAction == 'contractor')
                    newHireCase.NHW_Employee_Type__c = 'Contractor';
                else if(selectedStartAction == 'relocation')    
                    newHireCase.NHW_Employee_Type__c = 'Relocation';
                if(isExactTargetContractor){
                    newHireCase.NH_Is_Exact_Target__c = true;
                }
            }
            if(selectedStartAction != 'fte' && isRemote){
                newHireCase.Same_as_Office_Location__c = false;
            }
            if(selectedStartAction != 'fte' && !isRemote){
                newHireCase.Same_as_Office_Location__c = true;
            }
            if (newHireCase.NHW_Organization__c == null || 
                    newHireCase.NHW_Organization__c == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                        'No Organization Selected'));
                return null;
            }
            else if (newHireCase.NHW_Role__c == null || 
                    newHireCase.NHW_Role__c == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 
                        'No Role Selected'));
                return null;
            }
            if(dummyCase.NHW_Trail_Guide__c != null){
                Contact con = [Select Id, Email, Name 
                         From Contact 
                         Where Id =: dummyCase.NHW_Trail_Guide__c];
                onBoardingBuddyName = con.Name;
                if(newHireCase != null){
                    newHireCase.Onboarding_Buddy_Name__c = onBoardingBuddyName;
                    newHireCase.Onboarding_Buddy_Email__c = con.Email;
                }
            }

        //Moving syncing of BU/CC Name fields for contractor before ET flow's updatecase
           if(selectedStartAction != 'fte'){
                try{
                    if(newHireCase.NHW_Business_Unit__c != null){
                        newHireCase.Business_Unit_NHW__c = NHW_Util.getBusinessUnitIdToName(newHireCase.NHW_Business_Unit__c);
                    }
                    
                }
                catch (Queryexception qe){
                    newHireCase.Business_Unit_NHW__c = null;
                }    
            }

            if(selectedStartAction != 'fte'){
                try{
                    if(newHireCase.NHW_Cost_Center__c != null){
                        TF2_Department__c c = [Select Id, Name from TF2_Department__c where Id =: newHireCase.NHW_Cost_Center__c];
                        newHireCase.Cost_Center_NHW__c = c.Name;
                    }
                }
                catch (Queryexception qe){
                    newHireCase.Cost_Center_NHW__c = null;
                }    
            }

            if(newHireCase != null && newHireCase.NHW_Organization__c == 'Marketing Cloud'){
                updateCase();
                refreshETFields();
                //loadDefaultAccess();
                //loadCase();
                if(ApexPages.currentPage().getParameters().get('caseId') != null){
                    newHireCase = NHW_Util.getCurrentCase();
                }
                if(newHireCase.NHW_Employee_Type__c == 'Regular Employee'){
                    updateIsET();
                }
            }
            refetchAccessList();

            if(newHireCase != null && newHireCase.Same_as_Office_Location__c && (selectedStartAction == 'fte' || (selectedStartAction != 'fte' && !isRemote))){
                copyShippingAddress();

            }
            if(fullAccessList == null){
                refetchAccessList();
            }

            if(selectedStartAction == 'contractor' && (newHireCase.Contractor_Hire_Reason__c == 'Badge-Only' ||
                                 newHireCase.Contractor_Hire_Reason__c == 'Temp Receptionist')){
                clearProvisioningFields();
                currentPageNumber++;    
            }


        }
        currentPageNumber++;
        if (currentPageNumber == 0) {
            if (selectedStartAction != 'contractor' && selectedStartAction != 'relocation') {
                loadCandidates();
            } else {
                currentPageNumber ++;
            }
        } else if (!updateCase()) {
            currentPageNumber--;
        } else if (currentPageNumber == 2 && 
                (newHireCase.NHW_Access_Code__c == '' || 
                newHireCase.NHW_Access_Code__c == null)) {

            if(useNewConfigForApplications){
                loadApplicationList();
            }else{
                loadAccessList();
            }        
        } else if (currentPageNumber == 3 || newHireCase.NHW_Job_Application__c != null) {
            System.debug(LOGGINGLEVEL.INFO,useNewConfigForBootcamps);
            if(useNewConfigForBootcamps){
                getTrainings();
               if(!hasSpecializedTraining && !hasBSF ){     
                //Skip Page 3 if Japan employee doesn't have any specialized trainings.
                 currentPageNumber ++;
                 //Refresh prev page 3 selections if any,               
                 newHireCase.NHW_Training__c = '';
                 newHireCase.NH_Training_Email_Merge__c = '';
                 if(newHireCase.NHW_Employee__c != null){
                     refreshETFields();             
                 }
               }
               
            }else{
                fillCampaignList();
               if(isJapanEmployee && skipPage3){        
                //Skip Page 3 if Japan employee doesn't have any specialized trainings.
                 currentPageNumber ++;
                 //Refresh prev page 3 selections if any,               
                 newHireCase.NHW_Training__c = '';
                 newHireCase.NH_Training_Email_Merge__c = '';
                 if(newHireCase.NHW_Employee__c != null){
                     refreshETFields();             
                 }
               }
             }
            


        }
        return null;
    }

    private void clearProvisioningFields(){
        if(newHireCase != null){
            List<NHW_AccessCode> accessCodeList = new List<NHW_AccessCode>();
            newHireCase.Mobile_Phone_Required__c = 'No';
            newHireCase.Desk_and_VoiceMail__c = 'No';
            newHireCase.Computer_Type__c = 'Not Required';
            newHireCase.Laptop_Type__c = '';
            newHireCase.NHW_Access_Code__c = '[{"accessType":"Desktop/Laptop Application","accessDetailList":[]},{"accessType":"Force.com Org & Application","accessDetailList":[]},{"accessType":"Cloud Application (Non Force.com)","accessDetailList":[]},{"accessType":"Mobile","accessDetailList":[]}]';
            //fullAccessList = newHireCase.NHW_Access_Code__c;
        }
        
    }



    public void refetchAccessList(){  
        list<NHWWrapper.OnboardingWrapper> currentAccessList; 
        if(fullAccessList!=null){
            currentAccessList= fullAccessList; 
        }
        else{
            if(useNewConfigForApplications){
                loadApplicationList();
            }else{
                loadAccessList();
            }
          return;
        }

        Map<String,NHW_AccessWrapper> selectedMap = new Map<String,NHW_AccessWrapper>(); 
        for(NHWWrapper.OnboardingWrapper onBoard : currentAccessList ){
            for(NHW_AccessWrapper aw : onBoard.accessList ){
                selectedMap.put(aw.item.Name,aw); 
            }
        }

        // fetch again since there is a possbillity of changing previous selections.. 
        // fullAccessList has now new values... compare and add/remove to the original list based on previous selections... 

        if(useNewConfigForApplications){
            loadApplicationList();
        }else{
            loadAccessList();
        }

        if(fullAccessList != null && fullAccessList.size() > 0){
        for(Integer i=0;i<fullAccessList.size();i++){

            for(Integer j=0;j<fullAccessList[i].accessList.size();j++){
                if(selectedMap.containsKey(fullAccessList[i].accessList[j].item.name)) {
                    if(fullAccessList[i].accessList[j].item.name == 'Org62' && !isBUExcludedforOrg62){
                        selectedMap.get(fullAccessList[i].accessList[j].item.name).selected = true;    
                    }
                    else if(fullAccessList[i].accessList[j].item.name == 'Org62' && isBUExcludedforOrg62){
                        selectedMap.get(fullAccessList[i].accessList[j].item.name).selected = false;
                    }
                    fullAccessList[i].accessList[j] = selectedMap.get(fullAccessList[i].accessList[j].item.name);
                }
            }

        }}

    }


    public PageReference complete() {
        //Update New Hire's floor location/cube location to TBD if unknown
        if (newHireCase.Floor_Location_Cube_Location__c == null) {
            newHireCase.Floor_Location_Cube_Location__c = 'TBD';
        }
        newHireCase.Status = 'Sent to Supportforce';
        if (newHireCase.NHW_Employee_Type__c == 'Regular Employee') {
            newHireCase.HR_Approved__c = true;
        }
        newHireCase.Internal_Support_Category__c = 
                'New Hire Onboarding Request - Contractor';
        newHireCase.Subject = 'New Hire Provisioning Request for ' + 
                newHireCase.First_Name__c + ' ' + newHireCase.Last_Name__c;
        newHireCase.Origin = 'NHW';
        if (newHireCase.NHW_Employee_Type__c != 'Contractor' && newHireCase.NHW_Employee_Type__c != 'Relocation') {
            loadCaseWithRecruitmentData();
            newHireCase.Internal_Support_Category__c = 
                'New Hire Onboarding Request - Employee';
        }
        newHireCase = NHWHelper.clearHiddenFields(newHireCase);
        currentPageNumber++;
        if (newHireCase.NHW_Employee_Type__c != 'Contractor') {
            if (!createCampaignMember() || !updateCase()) {
                currentPageNumber--;
            }
        }
        else {
            if(!updateCase()){
                currentPageNumber--;
            }
        }    
        return null;
    }
}