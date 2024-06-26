public class ReimbursementPapiRequestClaimWrapper {
        public String uniqueId{get; set;}
        public String employeeId {get; set;}
        public Date effectiveDate{ get; set;}
        public String reimbursementName { get; set;}
        public Decimal amount{ get; set;}
        public String claimCurrency{ get; set;}
        public boolean isTaxable{get;set;}
        public String region{get;set;}
}