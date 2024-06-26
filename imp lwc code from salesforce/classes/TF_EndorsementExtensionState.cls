public class TF_EndorsementExtensionState {
    
    @AuraEnabled
    public Boolean isOpen {get; set;}
    
    @AuraEnabled
    public Boolean isRejected {get; set;}
    
    @AuraEnabled
    public Boolean isFirstApp {get; set;}

    @AuraEnabled
    public Boolean disableEndorsementForMcLaren {get; set;}
        
    @AuraEnabled
    public Endorsement__c endorsement {get; set;}
}