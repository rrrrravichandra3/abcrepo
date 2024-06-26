public with sharing class DJC_ExpenseTotalsController {
    public case reimbursementCase;
    public list<ClaimDetail> ClaimDetailList{get;set;} 
    public static DJC_ClaimManager ClaimManager;

    public DJC_ExpenseTotalsController(ApexPages.StandardController stdController){
        reimbursementCase = [SELECT Reimbursement_Policy_Id__c, Reimbursement_Category_Id__c,Division__c,contactId FROM Case WHERE Id = :((Case)stdController.getRecord()).Id];
        ClaimDetailList = getApprovedTotals(reimbursementCase);
    }   

    public static list<ClaimDetail> getApprovedTotals(case reimbursementCase){
         try{ 
 
           list<ClaimDetail> ClaimDetailList = new list<ClaimDetail>(); 
            String division = reimbursementCase.Division__c == null ? reimbursementCase.Division_Lookup__c : reimbursementCase.Division__c;
            DJC_Region region = DJC_Wellness_Util.getRegion(division);
            Id contactId = reimbursementCase.contactId;
            Reimbursement_Policy__mdt policy = DJC_Wellness_Util.getWellnessPolicyById((Integer)reimbursementCase.Reimbursement_Policy_Id__c);
            Reimbursement_Category__mdt category = DJC_Wellness_Util.getWellnessCategoryById((Integer)reimbursementCase.Reimbursement_Category_Id__c);
            Contact ctct = [select id,name,Start_Date__c,ES_DJC_Contact_Country__c from contact where id = :contactId];
            if(policy == null ){
                throw new ApplicationException('Reimbursement policy not found');
            } 
                               
            if(category == null){ 
                throw new ApplicationException('Reimbursement category not found');
            } 

            DJC_WellnessManagerFactory WellnessMger = DJC_WellnessManagerFactory.getInstance(region, policy, category, ctct);
            ClaimManager = WellnessMger.getClaimManager();
            DJC_TimeRangeManager TimeRangeManager = WellnessMger.getTimeRangeManager();
            String currentRange = TimeRangeManager.getCurrentTimeRange();
            String PreviousRange = TimeRangeManager.getPreviousTimeRange();

            ClaimDetailList.add( new ClaimDetail('Approved',currentRange,Policy.Currency__c) );
            ClaimDetailList.add(new ClaimDetail('Submitted',currentRange,Policy.Currency__c));
            ClaimDetailList.add(new ClaimDetail('Approved',PreviousRange,Policy.Currency__c));
            ClaimDetailList.add(new ClaimDetail('Submitted',PreviousRange,Policy.Currency__c));

            
            return ClaimDetailList;

         } Catch(Exception ex){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
             return null;
         }

    }


    public class ClaimDetail{
        Public String Status{get;set;}
        Public String Range{get;set;}
        Public Decimal Total{get;set;}
        Public String PolicyCurrencyISO{get;set;}
        public ClaimDetail(String Status,String Range,String PolicyCurrencyISO){
            this.Range = Range;
            this.Status = Status;
            this.PolicyCurrencyISO  =  PolicyCurrencyISO;
            this.Total  =  DJC_ExpenseTotalsController.ClaimManager.getClaimTotalsForGivenStatusRange(Status,Range);
        }

    }
}