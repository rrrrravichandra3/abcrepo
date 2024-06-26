public with sharing class PF_NHW_PastCasePickerPageService extends PF_NHW_PageService{

    protected override Map<String, Object> getPageConfig(){
        
        Map<String, Object> pageConfig = new Map<String, Object>();
        pageConfig.put('NH', getPastCases());
        
        return pageConfig;
    }
        
    private List<CasePickerNewHire> getPastCases(){
        
        List<CasePickerNewHire> auraNewHires = new List<CasePickerNewHire>();
        Set<Id> userIds = getUserIds();
        List<Case> allPastCases = new List<Case>();
        //Past cases for current hiring manager
        List<Case> pastCasesForHM = PF_NHW_ProvisioningCaseStore.getPastProvisioningCases(userIds);
        allPastCases.addAll(pastCasesForHM);
        //if current user is part of Executive Onboarding team, get all past SVP cases but exclude the cases already retrieved in list pastCasesForHM
        Set<Id> hiringManagerCaseIds = (new Map<Id,Case>(allPastCases)).keySet();
        if(NHW_Util.isCurrentUserExecutive()){
            List<Case> pastSVPCases = PF_NHW_ProvisioningCaseStore.getPastProvisioningSVPCases(hiringManagerCaseIds);
            allPastCases.addAll(pastSVPCases);
        }
        
        for(Case c: allPastCases){
            if(c.Created_with_NHW_2_0__c && (c.RecordTypeId == NHW_Util.getnhwCaseRecordTypeId())){
                
                PF_NHW_ProcessHandler.CaseProcessInformation processInformation = null;
                
                try{
                    processInformation = PF_NHW_ProcessHandler.getProcessInformation(c);
                }catch(AuraHandledException ex){
                    System.debug(System.LoggingLevel.ERROR, ex.getMessage());
                    continue;
                }
                
                auraNewHires.add(new CasePickerNewHire(c.Id,c.First_Name__c + ' ' + c.Last_Name__c, 
                                                             DateTime.newInstance(c.NHW_Start_Date__c.year(), c.NHW_Start_Date__c.month(), c.NHW_Start_Date__c.day()).format('MMM dd, yyyy'), 
                                                             c.Business_Title__c, c.NHW_Organization__c, c.NHW_Employee_Type__c.toLowerCase(), c.NHW_Start_Date__c));
            }
        }
        
        auraNewHires.sort();
        
        return auraNewHires;
    }
    
    private static Set<Id> getUserIds(){
        
        Set<Id> userIdSet = new set<Id>();
        userIdSet.add(UserInfo.getUserId());
        
        Set<Id> contactIdSet = new set<Id>();
        Set<String> managerEmailSet = new set<String>();
        User u = [Select Id, Email From User Where Id =: UserInfo.getUserId()];
        
        for (User u1 : [Select Id, ContactId From User Where Email =: u.Email]) {
            userIdSet.add(u1.Id);
            if (u1.ContactId != null) {
                contactIdSet.add(u1.ContactId);
            }
        }
        
        for (Delegate__c d : [Select Id, Manager__r.Email From Delegate__c Where Delegate__c IN :contactIdSet And Type__c = 'New Hire Wizard']) {
            if (d.Manager__r.Email != null) {
                managerEmailSet.add(d.Manager__r.Email);
            }                   
        }
        
        for (User u1 : [Select Id, ContactId From User Where Email IN :managerEmailSet]) {
            userIdSet.add(u1.Id);
        }
        
        return userIdSet;
    }
    
    public class CasePickerNewHire implements Comparable{
        
        @AuraEnabled
        public String name{get; private set;}
        
        @AuraEnabled
        public String startDate{get; private set;}
        
        @AuraEnabled
        public String caseId{get; private set;}

        @AuraEnabled        
        public String title{get; private set;}
        
        @AuraEnabled        
        public String department{get; private set;}
        
        @AuraEnabled        
        public String flowType{get; private set;}
        
        public Date startDateNoFormat{get; private set;}
        
        public CasePickerNewHire(String caseId, String name, String startDate,
                                 String title, String department, String flowType,
                                 Date startDateNoFormat){
            this.name = name;
            this.startDate = startDate;
            this.caseId = caseId;
            this.title = title;
            this.department = department;
            this.startDateNoFormat = startDateNoFormat;
            this.flowType = flowType;
        }
        
        public Integer compareTo(Object o){
            
            CasePickerNewHire newHire = (CasePickerNewHire)o;
            
            if(this.startDateNoFormat < newHire.startDateNoFormat){
                return 1;
            }else if(this.startDateNoFormat > newHire.startDateNoFormat){
                return -1;
            }

            return 0;
        }
    }
    
    public override String processPageInformation(){
        return null;
    }
    
    public override List<ReviewItem> getReviewList(Case provisioningCase, PF_NHW_Process process){
        return null;
    }
    
}