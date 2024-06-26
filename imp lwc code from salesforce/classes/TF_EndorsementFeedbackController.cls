public with sharing class TF_EndorsementFeedbackController {
    
    @AuraEnabled
    public static TF_EndorsementExtensionState getEndorsementState(Id endorsementId) {
    	// We reuse the logic of the EndorsementExtension extension controller 
    	// and return its state.
        Endorsement__c endorsement = new Endorsement__c(Id = endorsementId);
        ApexPages.StandardController sc = new ApexPages.StandardController(endorsement);
        EndorsementExtension ext = new EndorsementExtension(sc);
        
        TF_EndorsementExtensionState extensionState = new TF_EndorsementExtensionState();
        extensionState.isOpen = ext.isOpen;
        extensionState.isRejected = ext.isRejected;
        extensionState.isFirstApp = ext.isFirstApp;
        extensionState.endorsement = ext.getEndorse();
        extensionState.disableEndorsementForMcLaren = ext.disableEndorsementForMcLaren;        
        return extensionState;
    }
    

	@AuraEnabled
	public static TF_EndorsementExtensionState updateEndorsement(Endorsement__c endorsement, 
                                                                 Boolean isOpen, 
                                                                 Boolean isRejected, 
                                                                 Boolean isFirstApp, String actionName,
                                                                 Boolean disableEndorsementForMcLaren) {
        
        // We reuse the logic of the EndorsementExtension extension controller 
    	// and return its state.
        EndorsementExtension ext = new EndorsementExtension(null);
        ext.setEndorse(endorsement);
        ext.isOpen = isOpen;
       	ext.isRejected = isRejected;
        ext.isFirstApp = isFirstApp;
        
        // This is to prevent the extension to add error messages to the Visualforce page
        // (which does not exist in this context)
        ext.addErrorsToVisualforcePage = false;
        ext.disableEndorsementForMcLaren = disableEndorsementForMcLaren;        
        
        // actionName is mapped with the aura:id of the buttons.                                                             
        PageReference pr;
        if (actionName == 'endorsed') {
            pr = ext.Endorsed();
        } else if (actionName == 'declined') {
            pr = ext.Declined();
        }
        
        TF_EndorsementExtensionState extensionState = new TF_EndorsementExtensionState();
        extensionState.isOpen = ext.isOpen;
        extensionState.isRejected = ext.isRejected;
        extensionState.isFirstApp = ext.isFirstApp;
        extensionState.endorsement = ext.getEndorse();
        extensionState.disableEndorsementForMcLaren = ext.disableEndorsementForMcLaren;        
        
        return extensionState;
	}
}