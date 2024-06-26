public with sharing class NHWMCDataPrepService {

//BU
//T&P CC = a1Wc0000000sRsF BU = a34c0000000x6KF;
//Other CC = a34c0000000x6Lk BU = a34c0000000x6Le
//Finance CC= a1Wc0000000sRoW bu=a34c0000000x6Lk
// IT cc=a1Wc0000000sRpN BU = a34c0000000x6KM
/*DEV
public  Id FINBU = 'a34c0000000x6Lk';
public  Id FINCC = 'a1Wc0000000sRoW';
public  Id ITBU = 'a34c0000000x6KM';
public  Id ITCC = 'a1Wc0000000sRpN';
public  Id TPBU = 'a34c0000000x6KF';
public  Id TPCC = 'a1Wc0000000sRsF';
public  Id OTHERBU = 'a34c0000000x6Lk';
public  Id OTHERCC = 'a1Wc0000000sRne';*/

/** qa **/
public  Id FINBU;// = 'a34190000000xD8';
public  Id FINCC;// = 'a1W19000001h48K';
public  Id ITBU ;// = 'a34190000000xDJ';
public  Id ITCC ;// = 'a1W19000001h40v';
public  Id TPBU ;//= 'a34190000000xDC';
public  Id TPCC ;//= 'a1W19000001h42I';
public  Id OTHERBU;// = 'a34190000000xD2';
public  Id OTHERCC;// = 'a1W19000001h45s';

public  TF2_PCC__c PCC = new TF2_PCC__c();
public  Map<string,TF2_Company__c> regionToCompany = new map<string,TF2_Company__c>();
public  Map<string,TF2_Business_Site__c> regionToRemoteSite = new map<string,TF2_Business_Site__c>();
public  Map<string,TF2_Business_Site__c> regionToSite = new map<string,TF2_Business_Site__c>();
public  Map<Integer,Date> emailNumToDefDate = new Map<Integer,Date>();
public  Map<Integer,list<String>> emailNumToCandidateName = new Map<Integer,list<String>>();
public  Job_Profile__c jobProfile = new Job_Profile__c();
public  string RunNumber ;
public  Id hiringmanagerId;
public  Account CandidateAcc;
public  Id Candidaterecordtypeid;

public static String GetStrFromNum(Integer dt){
    String datenumstr='';
    while(dt>0){
        Integer lastnum= math.mod(dt,10)-1;
        if(lastnum == -1){
            lastnum = -2;
        }
        datenumstr = datenumstr+String.fromCharArray(new list<Integer>{65+lastnum});
        dt= dt/10;
    }
    system.debug('datenumstr'+datenumstr.reverse());
  return datenumstr.reverse();
}
//TODO
//Add region contacts and region JRs

public NHWMCDataPrepService(){
    CandidateAcc =  [select id from account where name='Candidates' limit 1];
    Candidaterecordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
    jobProfile = [select name from Job_Profile__c where name = 'Software Engineering MTS' limit 1];
    PCC = [select name from TF2_PCC__c where name ='100-United States of America' limit 1];

    List<TF2_Department__c> CCs = new List<TF2_Department__c>();
    CCs = [select id,Department_Number__c from TF2_Department__c where Department_Number__c in ('7401','4002','2040','7100')];
    System.AssertEquals(CCs.size(),4,'Expecting departments 7401,4002,2040,7100');
    for(TF2_Department__c CC:CCs){
        if(CC.Department_Number__c == '7401'){
            ITCC = CC.Id;            
        }else if(CC.Department_Number__c == '4002'){
            TPCC = CC.Id;
        }else if(CC.Department_Number__c == '7100'){
            FINCC = CC.Id;
        }else {
            OTHERCC = CC.Id;
        }
    }
    

    //FIN-1001,IT-2301,TP-4000,Other-3000

    List<Business_Unit__c> BUs = new List<Business_Unit__c>();
    BUs = [select id,BU_Code__c from Business_Unit__c where BU_Code__c in ('1001','2301','4000','3000')];
    System.AssertEquals(BUs.size(),4,'Expecting departments 1001,2301,4000,3000');
    for(Business_Unit__c BU:BUs){
        if(BU.BU_Code__c == '1001'){
            FINBU = BU.Id;            
        }else if(BU.BU_Code__c == '2301'){
            ITBU = BU.Id;
        }else if(BU.BU_Code__c == '4000'){
            TPBU = BU.Id;
        }else if (BU.BU_Code__c == '3000'){
            OTHERBU = BU.Id;
        }
    }

    list<TF2_Business_Site__c> bizsites = [select id,name,Country__c from TF2_Business_Site__c
                                                   where Country__c in ('United States','France','India','Japan') 
                                                   and Active__c=true 
                                                   and type__c='Regional Site' ];
    list<TF2_Company__c> Comps = [select Company_Code__c,region__c,Active__C 
                                        from TF2_Company__c where active__c=true AND company_code__c in ('100','300','600','400')];
    for(TF2_Company__c comp:Comps){
        if(comp.Company_Code__c=='100'){
            regionToCompany.put('AMER',comp);       
        }
        else if(comp.Company_Code__c=='300'){
            regionToCompany.put('Japan',comp);       
            
        }else if(comp.Company_Code__c=='600'){
            regionToCompany.put('APAC',comp);       
            
        }else if(comp.Company_Code__c=='400'){
            regionToCompany.put('EMEA',comp);       
            
        }
    }
    for(TF2_Business_Site__c site:bizsites){
        if(site.Country__c=='United States' ){
            if(site.name.contains('Remote')){
                regionToRemoteSite.put('AMER',site);       
            }else{
                regionToSite.put('AMER',site);       
            }
        }
        else if(site.Country__c=='France' ){
            if(site.name.contains('Remote')){
                regionToRemoteSite.put('EMEA',site);       
            }else{
                regionToSite.put('EMEA',site);       
            }            
        }else if(SITE.Country__c=='Japan'){
            if(site.name.contains('Remote')){
                regionToRemoteSite.put('Japan',site);       
            }else{
                regionToSite.put('Japan',site);       
            }              
        }else if(site.Country__c=='India' ){
            if(site.name.contains('Remote')){
                regionToRemoteSite.put('APAC',site);       
            }else{
                regionToSite.put('APAC',site);       
            }             
        }
    }
   emailNumToCandidateName.put(1,new list<string>{'TechRdyITAMER','TechRdyITJP'});
    emailNumToCandidateName.put(2,new list<string>{'SetuITAMER','SetupITJP'});
    emailNumToCandidateName.put(3,new list<string>{'ASAPITAMER','ASAPITJP'});
    emailNumToCandidateName.put(4,new list<string>{'LastChanceITAMER','LastChanceITJP','LastChanceFINAMER','LastChanceFINJP','LastChanceTPAMER','LastChanceTPJP',
                                                   'LastChanceOthAMER','LastChanceOthJP'});
    emailNumToCandidateName.put(5,new list<string>{'NHWithoutUITAMER', 'NHWithoutUITJP','NHWithoutUFINAMER','NHWithoutUFINJP','NHWithoutUTPAMER','NHWithoutUTPJP',
                                                   'NHWithoutUOthAMER','NHWithoutUOthJP'});
    emailNumToCandidateName.put(6,new list<string>{'GoodToGoITAMER','GoodToGoITJP'});
    emailNumToCandidateName.put(7,new list<string>{'GetRdyDayOneITAMER','GetRdyDayOneITJP','GetRdyDayOneITEMEA','GetRdyDayOneITAPAC'});
    emailNumToCandidateName.put(8,new list<string>{'RemoteITAMER','RemoteITJP','RemoteITEMEA','RemoteITAPAC'});
    emailNumToCandidateName.put(9,new list<string>{'SetUpDayOneITAMER','SetUpDayOneITJP','SetUpDayOneITEMEA','SetUpDayOneITAPAC'});

    emailNumToDefDate.put(1,System.today().adddays(28));
    emailNumToDefDate.put(2,System.today().adddays(28));
    emailNumToDefDate.put(3,System.today().adddays(10));
    emailNumToDefDate.put(4,System.today().adddays(5));
    emailNumToDefDate.put(5,System.today().adddays(5));
    emailNumToDefDate.put(6,System.today().adddays(12));
    emailNumToDefDate.put(7,System.today().adddays(7));
    emailNumToDefDate.put(8,System.today().adddays(5));
    emailNumToDefDate.put(9,System.today().adddays(3));



    system.assert(regionToSite.size()==4,regionToSite);
    system.assert(regionToCompany.size()==4,regionToCompany);
    system.assert(regionToRemoteSite.size()==4,regionToRemoteSite);  

}

public list<contact> getCandidateSet(String GenerationType,Integer emailNum){
      list<contact> FTEContacts = new list<contact>();
        Contact con = new Contact();
        Contact JapanCon = new Contact();
        con.recordTypeId=Candidaterecordtypeid;
        con.AccountId = CandidateAcc.id;
        con.MailingState='CA';
        con.MailingCountry='USA';
        con.MailingStreet='123 Las Pulgas';
        con.MailingCity='Belmont';
        con.firstName = emailNumToCandidateName.get(emailNum)[0];
        con.lastName=RunNumber;
        con.Email='test_'+con.firstName+system.today().format()+RunNumber+'@salesforce.com';
        
        if(GenerationType == 'DEFONESET'){
            FTEContacts.add(con);  
            return FTEContacts;

        }else if(GenerationType == 'DEFAULTDTES'){
            FTEContacts.add(con);             
            JapanCon = con.clone(false,false,false,false);
            JapanCon.MailingState='Nagoya';
            JapanCon.MailingCountry='Japan';
            JapanCon.MailingStreet='123 Yosaka';
            JapanCon.MailingCity='Tokyo';
            JapanCon.firstName = emailNumToCandidateName.get(emailNum)[1];
            JapanCon.lastName=RunNumber;
            JapanCon.Email='test_'+japancon.firstName+system.today().format()+RunNumber+'@salesforce.com';

            FTEContacts.add(JapanCon);   


            IF(emailNum == 4 || emailNum == 5){
            Contact FINCon = con.clone(false,false,false,false);
            Contact TPCon = con.clone(false,false,false,false);
            Contact OtherCon = con.clone(false,false,false,false);
            for(String FN:emailNumToCandidateName.get(emailNum)){
                Contact c = new Contact();
                if(FN.contains('IT')){
                    continue;
                }
                if(FN.contains('JP')){
                    c = JapanCon.clone(false,false,false,false);

                }else{
                    c = Con.clone(false,false,false,false);

                }
                    c.firstName = FN;
                    c.lastName = runNumber;
                    c.Email='test_'+c.firstName+system.today().format()+RunNumber+'@salesforce.com';
                    FTEContacts.add(c);
            }

            }else if(emailNum == 7 || emailNum == 8 || emailNum ==9){
                Contact EMEACon = con.clone(false,false,false,false);
                Contact APACCon = con.clone(false,false,false,false);
                APACCon.firstName = emailNumToCandidateName.get(emailNum)[3];
                APACCon.lastName = runNumber;
                APACCon.Email='test_'+APACCon.firstName+system.today().format()+RunNumber+'@salesforce.com';            
                EMEACon.firstName = emailNumToCandidateName.get(emailNum)[2];
                EMEACon.lastName = runNumber;
                EMEACon.Email='test_'+EMEACon.firstName+system.today().format()+RunNumber+'@salesforce.com';
                FTEContacts.add(EMEACon);
                FTEContacts.add(APACCon);

            }    
        }else if(GenerationType =='DEFTHRTY'){
            for(Integer i=1;i<=30;i++){
                Contact con1 = new Contact();
                con1.recordTypeId=Candidaterecordtypeid;
                con1.AccountId = CandidateAcc.id;
                con1.MailingState='CA';
                con1.MailingCountry='USA';
                con1.MailingStreet='123 Las Pulgas';
                con1.MailingCity='Belmont';
                con1.lastName = emailNumToCandidateName.get(emailNum)[0]+RunNumber;
                con1.firstName=getStrFromNum(i);
                con1.Email='test_'+con1.firstName+system.today().format()+RunNumber+'@salesforce.com';
                FTEContacts.add(con1);

            }

        }


            
      return FTEContacts;
            

}
  
    public static case createOnboardingCase(NHWRecruitmentModel SelectedRecruitmentDataObject){
        Case newHireCase = new Case();

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
        newHireCase.Shipping_Address__c =SelectedRecruitmentDataObject.OfficeAddress;
        newHireCase.Shipping_City__c =SelectedRecruitmentDataObject.OfficeCity;
        newHireCase.Shipping_State__c = SelectedRecruitmentDataObject.OfficeStateProvince;
        newHireCase.Shipping_Zip_Postal__c =SelectedRecruitmentDataObject.OfficeZipPostalCode;
        newHireCase.Shipping_Country__c = SelectedRecruitmentDataObject.OfficeCountry;
        newHireCase.Manager_Name__c = SelectedRecruitmentDataObject.ManagerContactId;
        newHireCase.Manager_s_Email__c = SelectedRecruitmentDataObject.Manager_s_Email;
        newHireCase.Email_Address__c = SelectedRecruitmentDataObject.supportforceEmail;
        newHireCase.End_Date__c = SelectedRecruitmentDataObject.EndDate;
        newHireCase.Same_as_Office_Location__c = true;        
        newHireCase.RecordTypeId = NHW_Util.getnhwCaseRecordTypeId();
        newHireCase.NHW_Employee_Type__c = 'Regular Employee';
        newHireCase.Origin = 'NHW';
        newHireCase.Internal_Support_Category__c =  'New Hire Onboarding Request - Employee'; 
        newHireCase.NH_Is_Exact_Target__c = false;  
        newHireCase.NHW_Access_Code__c=NHWMCDataPrepService.ALLACCESSCODE; 
        newHireCase.NHW_Organization__c = 'CSG';
        newHireCase.NHW_Role__c='CSG-CFL';
        newHireCase.Onboarding_Buddy_Name__c='Amy Legg';
        newHireCase.Onboarding_Buddy_Email__c='aleggutz@salesforce.com';
        newHireCase.Mobile_Phone_Required__c = 'No';
        newHireCase.Desk_and_VoiceMail__c = 'No';
        newHireCase.Computer_Type__c = 'Not Required';
        newHireCase.Laptop_Type__c = 'Mac Pro';
        newhireCase.Description = 'This is test provisioning case';
        newhireCase.Department_Admin_Contact__c= 'Amy Legg';
        newhireCase.NH_Training_Email_Merge__c ='CSG Bootcamp - 7/25/17<br /><br />BSF - Sales - 7/10/17';
        return newhireCase;


    }
    public static string ALLACCESSCODE = '[{"accessType":"Cloud Application (Non Force.com)","accessDetailList":[{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Centro Database","isc":"IT Helpdesk - ExactTarget - New Hire Provisioning Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Financial Applications"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"SFM/CRD Open Access & git.soma.salesforce.com","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"sreedhar.karukonda@supportforce.com.spfqa2","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Perforce, Code Collab","isc":"Internal GUS.com App: User Access/Profile/Perm Sets/BlackTab","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Serraview Apps","isc":"Facilities: Serraview Apps User Setup/Configuration","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Financial Applications"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Business Objects","isc":"Data Warehouse: Data Warehouse Support: Data Warehouse Access Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"sreedhar.karukonda@supportforce.com.spfqa2","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Oracle","isc":"IT - Finance Systems: Oracle Apps: Access/changes/Issues","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Financial Applications"},{"userToClone":"sreedhar.karukonda@supportforce.com.spfqa2","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Coupa","isc":"Coupa: New User Access","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Financial Applications"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Oracle - ET","isc":"IT - Finance Systems: Oracle Apps - ET User Access","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Financial Applications"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"PSE","isc":"MC Services Operations: OpenAir Other / General Application Support","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Financial Applications"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Demo Account","isc":"Marketing Cloud Demo Accounts - User Access","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Financial Applications"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Impersonation Accounts","isc":"IT Helpdesk - ExactTarget - New Hire Provisioning Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Financial Applications"}]},{"accessType":"Desktop/Laptop Application","accessDetailList":[{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"UltraEdit","isc":"IT Helpdesk - ExactTarget - New Hire Provisioning Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"MindManager","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Microsoft Visio","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Microsoft Project","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Microsoft Access","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"KeyNote (iWork)","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Camtasia","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"GoToMeeting","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Planning / Essbase","isc":"IT - Finance Systems: Hyperion: HFM - New User Access/Security","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"HFM / Essbase","isc":"IT - Finance Systems: Hyperion: HFM - New User Access/Security","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Virtual Machine","isc":"IT Helpdesk - ExactTarget - New Hire Provisioning Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"UltraEdit","isc":"IT Helpdesk - ExactTarget - New Hire Provisioning Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Virtual Machine","isc":"IT Helpdesk - ExactTarget - New Hire Provisioning Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"OmniGraffle","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Oxygen XML Editor","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"}]},{"accessType":"Desktop & Laptop Hardware","accessDetailList":[]},{"accessType":"Force.com Org & Application","accessDetailList":[{"userToClone":"sreedhar.karukonda@supportforce.com.spfqa2","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"EventForce","isc":"Marketing Operations: Access to EventForce custom app in 62 Org","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Employee Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"BlackTab","isc":"Internal Salesforce.com App New Hire Access Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"sreedhar.karukonda@supportforce.com.spfqa2","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"LiveOps Account","isc":"IT Helpdesk - Software Request - New Hire Software Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"PurchasingForce","isc":"Marketing Operations: Access to PRForce, PurchasingForce, Dreamforce Org","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"sreedhar.karukonda@supportforce.com.spfqa2","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Supportforce","isc":"Internal Salesforce.com App New Hire Access Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"sreedhar.karukonda@supportforce.com.spfqa2","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"GUS access","isc":"Internal Salesforce.com App New Hire Access Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"aleggutz@salesforce.com.itdev1","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Org62","isc":"Internal Salesforce.com App New Hire Access Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Employee Essentials"},{"userToClone":"No User Needed","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Sandbox Blacktab","isc":"Internal Salesforce.com App New Hire Access Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Productivity Essentials"},{"userToClone":"sreedhar.karukonda@supportforce.com.spfqa2","sfSSt":"Sreedhar Karukonda","org62SST":"Sreedhar Karukonda","name":"Salesforce.com (ET) NA7","isc":"Internal ET App New Hire Access Request","gusSST":"Sreedhar Karukonda","contractorSST":null,"category":"Employee Essentials"}]},{"accessType":"Mobile","accessDetailList":[]}]';
}