public with sharing class EndorsementExtension {
	
	private Endorsement__c endorse;
	public Boolean isOpen { get; set; }
	public Boolean isRejected { get; set; }
	public Boolean isFirstApp { get; set; }
	public Boolean isRolledOver  {get; set;}
	PageReference homePage = new PageReference('/');
    public Boolean addErrorsToVisualforcePage {get; set;}
    public Boolean disableEndorsementForMcLaren {get;set;}    
	
	public EndorsementExtension(ApexPages.StandardController stdController){
        this.addErrorsToVisualforcePage = true;
        if (stdController != null) {
            this.endorse = (Endorsement__c)stdController.getRecord();
            this.endorse = [ select Id, Candidate__c, Job_Requisition__c, Feedback__c, Endorser__c from Endorsement__c where Id =: this.endorse.Id ];

            isOpen = false;
            isRejected = false;
            isFirstApp = false;
            isRolledOver = false;
            
           
            disableEndorsementForMcLaren = getDisableEndorsementForMcLaren(); 
        }   
	}

	public Endorsement__c getEndorse(){
		return endorse;
	}
	
    public Endorsement__c setEndorse(Endorsement__c endorsement){
        
        this.endorse = endorsement;
		return this.endorse;
	}
	public PageReference Endorsed(){
	
		endorse.Status__c = 'Endorsed';

		try { 
			if( Endorsement__c.Status__c.getDescribe().isUpdateable() ) 
				update endorse;
            
			if ( isFirstApp ){
                // Checking if the 'app' is null is relevant for context where the state of the 
                // extension controller is maintained manually (see TF_EndorsementFeedbackController.cls)
 
			}
		} catch (Exception ex) {
            if (this.addErrorsToVisualforcePage) {			
				return null;
            } else {
                // If we are running in a context different from Visualforce (E.g. Lightning Component)
                // we propagate the exception and let that context handle it.
                throw ex;
            }
		}
		return homePage;

	}
	
	public PageReference Declined(){
		
		endorse.Status__c = 'Declined';
		
        try {        
            if( Endorsement__c.Status__c.getDescribe().isUpdateable() )
                update endorse;
                
        } catch (Exception ex) {
            if (this.addErrorsToVisualforcePage) {		
				return null;
            } else {
                // If we are running in a context different from Visualforce (E.g. Lightning Component)
                // we propagate the exception and let that context handle it.
                throw ex;
            }
		}
		return homePage;	
	}

	public PageReference redirectToDifferentUIPageIfS1() {
		String slds = ApexPages.currentPage().getParameters().get('endorsement.slds');
		
        //Only enabled in Salesforce 1 context. 
        //Or, if the 'endorsement.slds' parameter is set to '1'(debugging purposes)
		if (UserInfo.getUiThemeDisplayed() == 'Theme4t' || slds == '1') {
			return Page.TF_EndorsementFeedbackContainer;
		} else {
			return null;
		}
	}

	private boolean getDisableEndorsementForMcLaren() {
		boolean disableEndorsement = false ;
		boolean enableOverride = false;
		if(enableOverride == false) {
			return disableEndorsement;
		}
		return false;
	}	
}