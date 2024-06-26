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

public with sharing class NHWHelper
{
  /* Picklist methods */
  public static list<SelectOption> getOrgList(Boolean isET) {
    list<String> oList = new list<String>();
    list<SelectOption> resultList = new list<SelectOption>();
    string s;
    integer otherIndex;
    system.debug('****in getOrgList method and isET is ' + isET);
    for (NHW_Provisioning__c npd : [Select Id, Name 
                                    From NHW_Provisioning__c 
                                    Where Type__c = 'Organization']) {
      if(isET && npd.Name == 'Marketing Cloud'){
          oList.add(npd.Name);
      }
      else if(!isET && npd.Name != 'Marketing Cloud'){
          oList.add(npd.Name);
      }
    }
    
    if (!oList.isEmpty())
    {   
        //if(!isET){
            resultList.add(new SelectOption('', '--None--')); 
        //}    
        oList.sort();
        for (integer i=0;i < oList.size(); i++) {
            s = oList[i];
            if(s != 'Other')
              resultList.add(new SelectOption(s, s));
            else 
              otherIndex = i;
        }
        if(otherIndex != null && oList[otherIndex] != null && oList[otherIndex] == 'Other'){
          resultList.add(new SelectOption(oList[otherIndex], oList[otherIndex]));  
        }
    }
    system.debug('******resultList in getOrg method is ' + resultList);
    return resultList;
  }
  
  public static list<SelectOption> getRoleList(String orgName, String nhwType) {
      list<String> oList = new list<String>();
      list<SelectOption> resultList = new list<SelectOption>();
      string s;
      integer otherIndex;
      resultList.add(new SelectOption('', '--None--'));
      for (NHW_Provisioning__c npd : [Select Id, Name, Inclusion_Criteria__c 
                                      From NHW_Provisioning__c
                                      Where Type__c = 'Role'
                                      And Organization__r.Name =: orgName
                                      ]) {
          if(npd.Inclusion_Criteria__c != null && npd.Inclusion_Criteria__c.contains(nhwType))
              oList.add(npd.Name);
      }
      
      if (!oList.isEmpty()){
          if(oList.size() > 1){
            oList.sort();
          }
          else {
              resultList.clear();    
          }
          for (integer i=0;i < oList.size(); i++) {
            s = oList[i];
            if(s != 'Other')
              resultList.add(new SelectOption(s, s));
            else 
              otherIndex = i;
          }
          if(otherIndex != null && oList[otherIndex] != null && oList[otherIndex] == 'Other'){
            resultList.add(new SelectOption(oList[otherIndex], oList[otherIndex]));  
          }
      }    
        return resultList;
  }
  
  
  public static list<NHWWrapper.OnboardingWrapper> getAccessList(Case nhwCase) {
      list<NHWWrapper.OnboardingWrapper> fullaccessList = new list<NHWWrapper.OnboardingWrapper>();
      map<String, list<NHW_Provisioning__c>> typeMap = new map<String, list<NHW_Provisioning__c>>();
      NHWWrapper.OnboardingWrapper tempOW;
      Boolean goodToAdd = true;
      List<NH_BU_CC_Selections__c> settings = NH_BU_CC_Selections__c.getall().values();
      if(nhwCase == null) return null;
      String WorkLocationCountry = nhwCase.Office_Country__c;
      String laptopType = nhwCase.Laptop_Type__c ;
      String costCenter,businessUnit;
      if(nhwCase.NHW_Employee_Type__c == 'Contractor'){
          costCenter = NHW_Util.getCostCenterIdToName(nhwCase.NHW_Cost_Center__c);
          businessUnit = NHW_Util.getBusinessUnitIdToName(nhwCase.NHW_Business_Unit__c);
      }
      else{
          costCenter = nhwCase.Cost_Center_NHW__c;
          businessUnit = nhwCase.Business_Unit_NHW__c;
      }
      if(costCenter!=null && businessUnit!=null)
      {
        costCenter = costCenter.split('-',0)[0];
        businessUnit = businessUnit.split('-',0)[0];
      }
      Map<String, String> swBUCombo = new Map<String,String>();
      

      for(NH_BU_CC_Selections__c s: settings){
        if(s.SW_BU_Access_Coupa_Oracle_BF__c != null && s.SW_CC_Access_Coupa_Oracle_BF__c != null){
            swBUCombo.put(s.SW_BU_Access_Coupa_Oracle_BF__c,s.SW_CC_Access_Coupa_Oracle_BF__c);
        }
      }
      if(workLocationCountry == null) return null;
      
      for (NHW_Provisioning__c noi : [Select Id, Name, Onboarding_Category__c, 
                                           Need_User_to_Clone__c, Auto_Display__c,
                                           Supportforce_ISC__c, Include_for_ET_Employees__c,
                                           Type__c, Onboarding_Type__c,Organization__c, Organization__r.Name
                                       From NHW_Provisioning__c
                                       Where (Type__c = 'Application' 
                                       and Organization__r.Name != 'Marketing Cloud'
                                       and duplicate_reason__c = null)]) {
          system.debug('***** noi.Name ' + noi.Name + ' *** WorkLocationCountry '+ WorkLocationCountry );
          
          if(noi.Onboarding_Type__c != null) {
            if(noi.Name == 'Virtual Machine'){
                goodToAdd = addToAccessList(WorkLocationCountry,laptopType); 
                if(goodToAdd){
                   if (typeMap.containsKey(noi.Onboarding_Type__c)) {
                      typeMap.get(noi.Onboarding_Type__c).add(noi);
                      system.debug('****added noi at 1' + noi);
                   } 
                   else{
                      typeMap.put(noi.Onboarding_Type__c, new NHW_Provisioning__c[]{noi});
                      system.debug('****added noi at 2' + noi);
                   }
                }
            }
            else if (noi.Name != 'UltraEdit' && noi.Name != 'Virtual Machine' && noi.Name != 'Oracle' && noi.Name != 'Coupa' && noi.Name != 'Budgetforce' && noi.Name != 'HFM / Essbase' && noi.Name != 'Planning / Essbase' && noi.Name != 'Business Objects'){
              if(typeMap.containsKey(noi.Onboarding_Type__c)) {
                  typeMap.get(noi.Onboarding_Type__c).add(noi);
                }
                else{
                  typeMap.put(noi.Onboarding_Type__c, new NHW_Provisioning__c[]{noi});
                }  
            }
            else if(noi.Name == 'UltraEdit'){
              if(WorkLocationCountry == 'Brazil' || WorkLocationCountry == 'BR'){
                if (typeMap.containsKey(noi.Onboarding_Type__c)) {
                  typeMap.get(noi.Onboarding_Type__c).add(noi);
                }
                else{
                  typeMap.put(noi.Onboarding_Type__c, new NHW_Provisioning__c[]{noi});
                }
              }
            }
        else if(noi.Name =='HFM / Essbase' || noi.Name == 'Planning / Essbase'  || noi.Name == 'Business Objects'){
          if(swBUCombo.get(businessUnit) == costCenter){              
            if(typeMap.containsKey(noi.Onboarding_Type__c)){
                typeMap.get(noi.Onboarding_Type__c).add(noi);
            }else{
              typeMap.put(noi.Onboarding_Type__c, new NHW_Provisioning__c[]{noi});
            }
          }
        }
        else if(noi.Name =='Oracle' || noi.Name =='Coupa'|| noi.Name == 'Budgetforce'){
          if(swBUCombo.get(businessUnit) == costCenter){
            if(typeMap.containsKey(noi.Onboarding_Type__c)){
              typeMap.get(noi.Onboarding_Type__c).add(noi);
            }else{
              typeMap.put(noi.Onboarding_Type__c, new NHW_Provisioning__c[]{noi});
            }
          }
        } 
      }
    }
    
    for (String s : typeMap.keySet()) {
        tempOW = new NHWWrapper.OnboardingWrapper(s);
        for (NHW_Provisioning__c noi : typeMap.get(s)) {
          tempOW.accessList.add(new NHW_AccessWrapper(noi));
        }
        fullAccessList.add(tempOW);
    }
    return fullAccessList;
  }
  
   public static list<NHWWrapper.OnboardingWrapper> getAccessList(String orgName, Case newHireCase) {
      list<NHWWrapper.OnboardingWrapper> fullaccessList = new list<NHWWrapper.OnboardingWrapper>();
      map<String, list<NHW_Provisioning__c>> typeMap = new map<String, list<NHW_Provisioning__c>>();
      boolean goodToAdd=true; 
      NHWWrapper.OnboardingWrapper tempOW;
      System.debug('***org name **' + orgName); 
      for (NHW_Provisioning__c noi : [Select Id, Name, Onboarding_Category__c, 
                                           Need_User_to_Clone__c, Filter_Criteria__c,Filter_Required__c,
                                           Supportforce_ISC__c, Include_for_ET_Employees__c,Auto_Display__c,
                                           Type__c, Onboarding_Type__c,Organization__r.Name,Organization__c
                                       From NHW_Provisioning__c
                                       Where (Type__c = 'Application') and Duplicate_Reason__c=null
                                       ]) {
        

         if (noi.Onboarding_Type__c != null && 
          ((noi.Organization__r.Name != orgName && noi.Include_for_ET_Employees__c) || 
          (noi.Organization__r.Name == orgName))){
           
           if(noi.name.contains('PSE')){
            System.debug('***open air ** fetched');
            }
        //Make old model support the updated config recs.
        if(!noi.Filter_Required__c  
          && ( (noi.Filter_Criteria__c == '') || 
               (noi.Filter_Criteria__c != null && !noi.Filter_Criteria__c.contains('##')))){
        //if(!noi.Filter_Required__c && (noi.Filter_Criteria__c == null || noi.Filter_Criteria__c == '')){
              system.debug('****typeMap ' + typeMap + ' ' + noi);
              if (typeMap.containsKey(noi.Onboarding_Type__c)) {
                      typeMap.get(noi.Onboarding_Type__c).add(noi);
                      system.debug('****added noi at 1' + noi);
              } 
              else {
                  typeMap.put(noi.Onboarding_Type__c, new NHW_Provisioning__c[]{noi});
                  system.debug('****added noi at 2' + noi);
                  }
           }
           //Make old model support the updated config recs.
          // else if(!noi.Filter_Required__c && noi.Filter_Criteria__c != null && noi.Filter_Criteria__c != ''){
             else if(!noi.Filter_Required__c && noi.Filter_Criteria__c != null && noi.Filter_Criteria__c.contains('##')){           
              System.debug('**before calling parseFC**' + noi.name);
               if(parseFilterCriteria(noi,newHireCase)){
                   if (typeMap.containsKey(noi.Onboarding_Type__c)) {
                      typeMap.get(noi.Onboarding_Type__c).add(noi);
                      system.debug('****added noi at 3' + noi);
                  } 
                  else {
                      typeMap.put(noi.Onboarding_Type__c, new NHW_Provisioning__c[]{noi});
                      system.debug('****added noi at 4' + noi);
                  }
               }
           }
           else{
         
         goodToAdd=true;
          if (noi.Onboarding_Type__c != null) {
              //Only Virtual machine qualifies for this flow.
            /* For desktop/laptop, call addToAccessList method and add only if return value is true ... check for (noi.Filter_Required__c) before calling addToAccessList method   */
            if(noi.Filter_Required__c){
              System.debug('***calling for -->' + noi.Name + '*' + noi.Onboarding_Type__c);
              goodToAdd = addToAccessList(noi,newHireCase); 
            }
            if(goodToAdd){
              if (typeMap.containsKey(noi.Onboarding_Type__c)) {
                  typeMap.get(noi.Onboarding_Type__c).add(noi);
                  system.debug('****added noi at 1' + noi);
              } 
              else {
                typeMap.put(noi.Onboarding_Type__c, new NHW_Provisioning__c[]{noi});
                system.debug('****added noi at 2' + noi);
              }
            }
          }
        }
      }
    }
  
    for (String s : typeMap.keySet()) {
        tempOW = new NHWWrapper.OnboardingWrapper(s);
        for (NHW_Provisioning__c noi : typeMap.get(s)) {
          tempOW.accessList.add(new NHW_AccessWrapper(noi));
        }
        fullAccessList.add(tempOW);
    }
    return fullAccessList; 
}
  
  
  public static list<SelectOption> getMCServiceWorkshopList() {
    list<String> oList = new list<String>();
    list<SelectOption> resultList = new list<SelectOption>();
    resultList.add(new SelectOption('', '--Select--'));
    
    List<NHW_Marketing_Cloud__c> MCWorkshopValues = NHW_Marketing_Cloud__c.getall().values();
        for(NHW_Marketing_Cloud__c rec:MCWorkshopValues){
            if(rec.NH_Services_Workshop__c != null){
                oList.add(rec.NH_Services_Workshop__c); 
            }
        }  
    
    if (!oList.isEmpty()) {
       for (String s : oList) {
            resultList.add(new SelectOption(s, s));
        }
    }
    
    return resultList;
    }
    
    public static list<SelectOption> getMCServiceOrientationList() {
    list<Date> oList = new list<Date>();
    list<SelectOption> resultList = new list<SelectOption>();
    resultList.add(new SelectOption('', '--Select--'));
    
    List<NHW_Marketing_Cloud__c> MCWorkshopValues = NHW_Marketing_Cloud__c.getall().values();
        for(NHW_Marketing_Cloud__c rec:MCWorkshopValues){
            if(rec.NH_Services_Orientation1__c != null){
                oList.add(rec.NH_Services_Orientation1__c); 
            }
        }  
    
    if (!oList.isEmpty()) {
       oList.sort();
       for (Date s : oList) {
            DateTime dtDate = datetime.newInstance(s.year(), s.month(),s.day());
            resultList.add(new SelectOption(dtDate.format('MMM')+' '+s.Day()+', '+s.year(),dtDate.format('MMM')+' '+s.Day()+', '+s.year()));
        }
    }
    
    return resultList;
        
    }
  
  public static list<SelectOption> getResourceType(String nhwProcess){
    list<String> oList = new list<String>();
    list<SelectOption> resultList = new list<SelectOption>();
    system.debug('*****nhwProcess in Resource Type method ' + nhwProcess);
    for (NHW_Provisioning_Default__c npc : [Select Controller__c, 
                                                   Controller__r.Name, 
                                                   Dependent__c, 
                                                   Dependent__r.Name, Type__c 
                                            From NHW_Provisioning_Default__c 
                                            Where Controller__r.Name = 
                                              :nhwProcess and Type__c = 'Employment Type to Resource Type']) {
        oList.add(npc.Dependent__r.Name);
    }
    
    if (!oList.isEmpty()) {
        if(oList.size() > 1){
            resultList.add(new SelectOption('', '--None--'));
            oList.sort();
        }
        for (String s : oList) {
            resultList.add(new SelectOption(s, s));
        }
    }
    return resultList;
  }
  
  public static list<SelectOption> getConHireReason(String nhwProcess){
    list<String> oList = new list<String>();
    list<SelectOption> resultList = new list<SelectOption>();
    
    system.debug('*****nhwProcess in Hire Reason method ' + nhwProcess);
    
    for (NHW_Provisioning_Default__c npc : [Select Controller__c, 
                                                   Controller__r.Name, 
                                                   Dependent__c, 
                                                   Dependent__r.Name, Type__c 
                                            From NHW_Provisioning_Default__c 
                                            Where Controller__r.Name = 
                                              :nhwProcess and Type__c = 'Employment Type to Contractor Hire Reason']) {
        oList.add(npc.Dependent__r.Name);
    }
    
    if (!oList.isEmpty()) {
        if(oList.size() > 1){
            resultList.add(new SelectOption('', '--None--'));
            oList.sort();
        }
        for (String s : oList) {
            resultList.add(new SelectOption(s, s));
        }
    }
    return resultList;
  }
  
  public static list<SelectOption> getMobileList(String chosenDivision) {
    list<String> oList = new list<String>();
    list<SelectOption> resultList = new list<SelectOption>();
    resultList.add(new SelectOption('', '--Select--'));
    
    for (NHW_Provisioning_Default__c npc : [Select Controller__c, 
                                                   Controller__r.Name, 
                                                   Dependent__c, 
                                                   Dependent__r.Name, Type__c 
                                            From NHW_Provisioning_Default__c 
                                            Where Controller__r.Name = 
                                              :chosenDivision]) {
        oList.add(npc.Dependent__r.Name);
    }
    
    if (!oList.isEmpty()) {
        oList.sort();
        for (String s : oList) {
            resultList.add(new SelectOption(s, s));
        }
    }
    
    return resultList;
    }
    
    public static list<SelectOption> getLaptopList(String costCenter, String employeeType, String workLocationCountry, String organization, String businessUnit){
        list<String> oList = new list<String>();
        list<SelectOption> resultList = new list<SelectOption>();
        resultList.add(new SelectOption('', '--None--'));
        map<String, set<String>> laptopMap = new map<String, set<String>>();
        set<String> laptopSet = new set<String>();
        set<String> ccSet = getcostCenters();   
        set<String> ccComboSet = getCostCentersCombo();
        set<String> buComboSet = getBusinessUnitCombo(); 
        costCenter = costCenter.split('-',0)[0];
        businessUnit = businessUnit.split('-',0)[0];
        List<NH_BU_CC_Selections__c> settings = NH_BU_CC_Selections__c.getall().values();
        Map<String, String> hwBUCombo = new Map<String,String>();
        for(NH_BU_CC_Selections__c s: settings){
          if(s.SW_BU_Access_Coupa_Oracle_BF__c != null && s.SW_CC_Access_Coupa_Oracle_BF__c != null){
              hwBUCombo.put(s.SW_BU_Access_Coupa_Oracle_BF__c,s.SW_CC_Access_Coupa_Oracle_BF__c);
          }
        }
        if(workLocationCountry == null) return null;
        for (NHW_Provisioning_Default__c npc : [Select Controller__c, Controller__r.Name, Dependent__c, 
                                                       Dependent__r.Name, Type__c, 
                                                       Controller__r.Type__c 
                                                From NHW_Provisioning_Default__c 
                                                Where Dependent__r.Type__c = 
                                                  'Laptop']) {
        if (laptopMap.containsKey(npc.Dependent__r.Name)) {
          laptopMap.get(npc.Dependent__r.Name).add(npc.Controller__r.Name);
        }
        else {
        laptopSet = new set<String>();
        laptopSet.add(npc.Controller__r.Name);
        laptopMap.put(npc.Dependent__r.Name, laptopSet);
        }
    }
    system.debug('***** employeeType ' +  employeeType + ' **costCenter ' +  costCenter + ' WORKLOCation ' + worklocationCountry);
    system.debug('***** ccSet ' + ccSet + ' ccSet.contains(costCenter) ' + ccSet.contains(costCenter));
    for (NHW_Provisioning__c p : [Select Id, Name, Include_for_ET_Employees__c, Auto_Display__c
                                    From NHW_Provisioning__c
                                    Where Type__c = 'Laptop'
                                    And Name IN :laptopMap.keySet() AND Duplicate_Reason__c = null]) {
        if (laptopMap.containsKey(p.Name)) {
            system.debug('***** organization ' + organization + ' p.Name.endsWith ' + p.Name + ' ' + p.Name.endsWith('Developer Laptop'));
            if(p.Name.endsWith('Dell Laptop')){
                if((organization != 'Marketing Cloud' && (workLocationCountry == 'Brazil' || worklocationCountry == 'BR')) || 
                   (organization == 'Marketing Cloud' && (workLocationCountry.startswith('United States') || worklocationCountry == 'US'))){
                   resultList.add(new SelectOption(p.Name, p.Name));
                }
            }
            else if((p.Name.endsWith('Developer Laptop') || p.Name.startsWith('Mac Pro 15')) && (workLocationCountry != 'Brazil' && worklocationCountry != 'BR')){
                if(organization == 'Marketing Cloud' && (ccSet.contains(costCenter) || (ccComboSet.contains(costCenter) && buComboSet.contains(businessUnit)))){
                    resultList.add(new SelectOption(p.Name, p.Name));    
                }  
                else if (organization != 'Marketing Cloud' && ccSet.contains(costCenter)){
                    resultList.add(new SelectOption(p.Name, p.Name));  
                }  
            }
            else if(p.Name.startsWith('Macbook Pro 13')){
                if(workLocationCountry == 'Brazil' || worklocationCountry == 'BR'){
                      resultList.add(new SelectOption(p.Name, p.Name)); 
                  }   
            }
            else if(p.Name.startsWith('Mac 15')){
                if((organization == 'Marketing Cloud' && workLocationCountry != 'Brazil' && worklocationCountry != 'BR' && !workLocationCountry.startswith('United States') && worklocationCountry != 'US') ||
                   (organization != 'Marketing Cloud' && workLocationCountry != 'Brazil' && worklocationCountry != 'BR' && employeeType == 'Regular Employee' && 
                    ccSet.contains(costCenter))){
                        resultList.add(new SelectOption(p.Name, p.Name));    
                }        
            }
            else if(p.Name.startsWith('Dell PC Laptop')){
                resultList.add(new SelectOption(p.Name, p.Name));    
            } 
            else if(p.Name.startsWith('Macbook Air')){
                if((workLocationCountry != 'Brazil' && worklocationCountry != 'BR') && (hwBUCombo.get(businessUnit) != costCenter)){
                       resultList.add(new SelectOption(p.Name, p.Name));     
                   }    
            }
            else if(p.Name.startsWith('Not Required')){
                if(organization == 'Marketing Cloud' && employeeType == 'Contractor'){
                       resultList.add(new SelectOption(p.Name, p.Name));     
                }    
            }
        }
    }
    if (!resultList.isEmpty()) {
        resultList.sort();
    }
    
    return resultList;
    }   
    
    public static Set<String> getCostCenters(){
        Set<String> ccStringSet = new Set<String>();
        List<NHW_Exact_Target_BU__c> ccList = NHW_Exact_Target_BU__c.getall().values();
        for(NHW_Exact_Target_BU__c rec: ccList){
            if(rec.Laptop_Cost_Center__c != null){
                ccStringSet.add(rec.Laptop_Cost_Center__c.split('-',0)[0]);
            }
        }
        return ccStringSet;
    }

    public static Set<String> getCostCentersCombo(){
        Set<String> ccStringSet = new Set<String>();
        List<NHW_Exact_Target_BU__c> ccList = NHW_Exact_Target_BU__c.getall().values();
        for(NHW_Exact_Target_BU__c rec: ccList){
            if(rec.Laptop_Cost_Center_New__c != null){
                ccStringSet.add(rec.Laptop_Cost_Center_New__c);
            }
        }
        return ccStringSet;
    }

    public static Set<String> getBusinessUnitCombo(){
        Set<String> buStringSet = new Set<String>();
        List<NHW_Exact_Target_BU__c> ccList = NHW_Exact_Target_BU__c.getall().values();
        for(NHW_Exact_Target_BU__c rec: ccList){
            if(rec.Laptop_Business_Unit__c != null){
                buStringSet.add(rec.Laptop_Business_Unit__c);
            }
        }
        return buStringSet;
    }
    
    public static Case clearHiddenFields(Case newHireCase) {
    if (newHireCase.Mobile_Phone_Required__c != 'Yes') {
      newHireCase.ES_DJC_Business_Justification__c = null;
    }
    if (newHireCase.Existing_Equipment__c) {
        newHireCase.Computer_Type__c = null;
        newHireCase.Laptop_Type__c = null;
    }
    return newHireCase;
  }
  
  public static Boolean needsEquipment(Case newHireCase) {
    if (!newHireCase.Existing_Equipment__c && 
        ((newHireCase.Laptop_Type__c == null || 
          newHireCase.Laptop_Type__c == '') || 
        (newHireCase.Computer_Type__c == null || 
          newHireCase.Computer_Type__c == ''))) {
        return true;
    }
    return false;
  }
  
  
   private static boolean addToAccessList(NHW_Provisioning__c noi,Case newHireCase){
    
         boolean goodToAdd=false; 
              
              System.debug('***' + newHireCase.Laptop_Type__c); 
              System.debug('**name noi *' + noi.Name + '**' + noi.Onboarding_Type__c);
              
              if(noi.Onboarding_Type__c=='Desktop/Laptop Application'){
                
                  if(noi.Name=='Virtual Machine' && newHireCase.Laptop_Type__c!=null && newHireCase.Laptop_Type__c.contains('Mac') && (newHireCase.Office_Country__c == 'Brazil' || newHireCase.Office_Country__c == 'BR' ||
                     newHireCase.Office_Country__c.startswith('United States') || newHireCase.Office_Country__c == 'US')){
                                goodToAdd=true;
                  }
                 
              }
                 
                 return goodToAdd; 
         }

    private static boolean addToAccessList(String workLocationCountry, String laptopType){
    
         boolean goodToAdd=false; 
              
              System.debug('*** workLocationCountry ' + workLocationCountry); 
              System.debug('**laptopType ' + laptopType);
              
              if(laptopType != null && laptopType.contains('Mac') && (worklocationCountry == 'Brazil' || worklocationCountry == 'BR')){
                                goodToAdd=true;
                  }
                 
              
                 
                 return goodToAdd; 
         }     
         
  
  public static boolean parseFilterCriteria(NHW_Provisioning__c accessRec,Case newHireCase){
      if(newHireCase != null){
      String querySubstring;
      
          system.debug('**** accessRec ' + accessRec.Filter_Criteria__c);
          if(accessRec.Filter_Criteria__c != null && accessRec.Filter_Criteria__c != '' 
             && accessRec.Filter_Criteria__c.contains('##') ){//Supporting old format filter criteria
              for (String s : accessRec.Filter_Criteria__c.split('##', 0)) {
                  if (s != null && s != '') {
                      querySubstring = s.trim();
                
                  }
              } 
          }
      
      if(querySubstring == null || querySubstring == ''){
          return false;
      }
      else {
          system.debug('******newhirecase in parseFilterCriteria ' + newHireCase);
          String caseQuery = 'select Id from Case where Id = \'' + newHireCase.Id + '\' and ' + querySubstring; 
          system.debug('*****caseQuery ' + caseQuery);
          Sobject[] objData = Database.query(caseQuery);
          if(objData.size() > 0){
              system.debug('******returning true from parseFilterCriteria');
              return true;
          }
          else{
              system.debug('******returning false from parseFilterCriteria');
              return false;
          }
      }
      }
      else {
          system.debug('******returning false from parseFilterCriteria');
              return false;
      }
}
}