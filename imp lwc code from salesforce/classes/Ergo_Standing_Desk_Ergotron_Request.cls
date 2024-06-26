public with sharing class Ergo_Standing_Desk_Ergotron_Request extends Ergo_Controller {

	public Ergo_Standing_Desk_Ergotron_Request() {

		RequestFormType = 'ErgotronRequestAmer';

		newCase.Origin = 'Ergo - Web';
		newCase.Subject = 'Stand Desk Attachment (Ergotron) Request for ' + ContactName;
        newCase.type = 'Stand Desk Attachment (Ergotron) Request';
        newCase.ES_DJC_Topic__c = 'Stand Desk Attachment (Ergotron) Request';
        newCase.Tier__c = 'Tier 1';


		newCase.REWS_Building__c = contactBuilding;

        if ((currentUser.contact.DJC_Contact_Floor__c != null) && (currentUser.contact.DJC_Contact_Floor__c.isNumeric())){
        	newCase.REWS_Floor__c = Decimal.valueOf(currentUser.contact.DJC_Contact_Floor__c);
        }
        newCase.REWS_Cube_number__c = currentUser.contact.DJC_Contact_Cube_Workstation__c;
	}
	
    public PageReference save(){
    	if(validateCase()){

    		saveCaseRecord();

    		String url = ApexPages.CurrentPage().getUrl();
            PageReference p = new PageReference(url+'&thanks=true');
            p.setRedirect(true);
            return p;
    	}
    	return null;
    }

	public boolean validateCase() {

		boolean noError = true;

		if (isBlank(newCase.REWS_Building__c)) {
			newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
			noError = false;
		}

		if (isBlank(newCase.REWS_Floor__c)) {
			newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
			noError = false;
		}

		if (isBlank(newCase.REWS_Cube_Number__c)) {
			newCase.REWS_Cube_number__c.addError(DEFAULT_ERROR_MESSAGE);
			noError = false;
		}
		return validateAttachments() && noError;
	}
	
	private boolean validateAttachments() {
		if (Attach1 == null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You must receive and attach proof of your manager\'s approval before submitting this request.'));
			return false;
		}
		if ((Attach9 == null) && (!isIndyEmployee) && (!isQuebecEmployee)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please attach your Online Training Confirmation Email.'));
			return false;
		}
        if (!inChicagoNYOrSF && !isTorontoEmployee) {
			
        	Boolean photosAttached = !(Attach2 == null && Attach3 == null && Attach4 == null && Attach5 == null && Attach6 == null && Attach7 == null);

        	if (!photosAttached) {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please attach a photo(s) of your work area before submitting this request'));
           		return false;
        	}
        }
		return true;
	}
}