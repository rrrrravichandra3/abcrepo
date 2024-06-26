/* 
This class is meant for populating 
Auto_Provisioning_Notification Email Template
with all required data from related Job Application 
and Case records data dynamically.
This class is referenced in NHW_Autoprovisioning_Report
Visualforce Component and this Visualforce Component
is referenced in Email Template.
03/June/2020: Created Date. 
*/

Public with sharing class NHW_AutoprovisioningReportController{


    public List<JobApplicationWrapper> JobApplicationList;
    
   /*wrapper to hold placement and corresponding Onboarding Case, NHW link */

    public class JobApplicationWrapper{	
        	
        public WDR_Application__c jobApp {get;set;}	
        public string HMName {get;set;}	
        public string EmpName {get;set;}	
        public string EmpMailingStreet  {get;set;}	
        public string EmpMailingCity  {get;set;}	
        public string EmpMailingState {get;set;}	
        public string EmpMailingCountry {get;set;}	
        public string EmpMailingPostalCode {get;set;}	
        public date StartDate {get;set;}	
        public string Region {get;set;}	
        public string BUName {get;set;}	
        public string CCName {get;set;}	
        public string JobName {get;set;}	
        public Case onboardingCase {get;set;}	
        public Boolean placementHasOnboardingCase {get;set;}	
        public String nhwLink {get;set;} 	
        public String Org {get;set;} 	
        	
        public JobApplicationWrapper(WDR_Application__c JobApp, Case onboardingCase, boolean hasOnboardingcase, String link,String Org){	
            this.HMName=JobApp.Job__r.Hiring_Manager__r.Name;	
            this.EmpName=JobApp.Candidate__r.Name;	
            this.EmpMailingStreet=JobApp.Candidate__r.Mailing_Street__c;	
            this.EmpMailingCity=JobApp.Candidate__r.Mailing_City__c;	
            this.EmpMailingState=JobApp.Candidate__r.Mailing_State__c;	
            this.EmpMailingCountry=JobApp.Candidate__r.Mailing_Country__c;	
            this.EmpMailingPostalCode= JobApp.Candidate__r.Mailing_Postal_Code__c;	
            this.StartDate=JobApp.Start_Date__c;	
            this.Region=JobApp.Job__r.Region__c;	
            this.BUName=JobApp.Job__r.Business_Unit__r.Name;	
            this.CCName= JobApp.Job__r.Department__r.Name;  	
            this.JobName=JobApp.Job__r.Name;	
       	
            this.nhwLink = '';	
            this.JobApp = JobApp;	
            this.onboardingCase = onboardingCase;	
            this.placementHasOnboardingCase = hasOnboardingcase;	
            this.nhwLink = link;	
            this.Org =Org;	
            	
        }	
        	
    }   
    public List<JobApplicationWrapper> getJobApplicationList(){
    
        JobApplicationList =  fetchUrgentPendingJobApplications(); 
        
        if(JobApplicationList != null && JobApplicationList.size() > 0) return JobApplicationList;            
        
        return null; 
        
    } 
    
    
    public List<JobApplicationWrapper> fetchUrgentPendingJobApplications(){

        datetime myDateTime = datetime.now();
        
        NHW_Util NU = new NHW_Util();
        
        List<JobApplicationWrapper> JobApplications = new List<JobApplicationWrapper>();
        
        Map<Id, List<Case>> pendingJobandCases = NHW_Util.getPendingCasesForAutoprovisioning(myDateTime);
       
        for(WDR_Application__c JobApp:[select id, Start_Date__c,Candidate__r.Name, 
                                    Candidate__r.Mailing_Street__c,Candidate__r.Mailing_City__c,Candidate__r.Mailing_State__c,Candidate__r.Mailing_Country__c,Candidate__r.Mailing_Postal_Code__c,
                                    Job__r.Region__c, Job__r.Hiring_Manager__r.Name ,Job__r.Name, Job__r.Business_Unit__r.Name, Job__r.Department__r.Name
                                    from WDR_Application__c WHERE id in :pendingJobandCases.keyset()  ]){
                

            if(!pendingJobandCases.get(JobApp.id).isEmpty()){
            

                for(Case c:pendingJobandCases.get(JobApp.id)){
                    String org = '';
                    system.debug('****c.Subject c.status ' + c.Subject + ' ' + c.Status);
                    org= NU.getOrgForBUCC(c.Cost_Center_NHW__c.split('-',-1)[0],c.Business_Unit_NHW__c.split('-',-1)[0]);
                
                    if(c.Subject.StartsWith('New Hire Provisioning Request for') && c.Status == 'New'){
                        JobApplicationWrapper JobApplicationRec = new JobApplicationWrapper(JobApp,c,true, NU.getURLParam(false,c.Id,JobApp.id),org);
                        JobApplications.add(JobApplicationRec);
                        system.debug('*****JobApplications for new ' + JobApplications);
                            
                    }
                    else if(c.Subject.StartsWith('New Hire Preboarding Request for') && c.Status == 'Closed' && pendingJobandCases.get(JobApp.id).size()==1){
                        JobApplicationWrapper JobApplicationRec = new JobApplicationWrapper(JobApp,null,false,NU.getURLParam(true,c.Id,JobApp.id),org);
                        JobApplications.add(JobApplicationRec);
                        system.debug('*****JobApplications for closed ' + JobApplications);
                        
                    }
                }
            } 
        }
            system.debug('*****JobApplications from Util ' + JobApplications);
            
            return JobApplications;   
        }       

          
}