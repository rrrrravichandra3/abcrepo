public class Ergo_Assessment_Request_Form extends Ergo_Controller {

    public Ergo_Assessment_Request_Form(){

        RequestFormType = 'ErgoAssessmentRequestAmer';

        if(isRemote || division.equalsIgnoreCase('EMEA') && !isErgoPresent){
            newCase.DJC_Ergo_Assessment_Type__c = 'Designated Remote Employee';
        }else{
            newCase.DJC_Ergo_Assessment_Type__c = '1x1';
        }

        newCase.Origin = 'Ergo - Web';
        newCase.DJC_Ergo_In_Pain__c = 'No';

        newCase.REWS_Building__c = contactBuilding;

        if ((currentUser.contact.DJC_Contact_Floor__c != null) && (currentUser.contact.DJC_Contact_Floor__c.isNumeric())){
            newCase.REWS_Floor__c = Decimal.valueOf(currentUser.contact.DJC_Contact_Floor__c);
        }
        newCase.REWS_Cube_number__c = currentUser.contact.DJC_Contact_Cube_Workstation__c;
    }

    public List<SelectOption> assessmentTypes{
        get{
            if(assessmentTypes == null){

                assessmentTypes = new List<SelectOption>();
                Schema.DescribeFieldResult dfr = Schema.SObjecttype.Case.Fields.DJC_Ergo_Assessment_Type__c;

                for (Schema.Picklistentry pe : dfr.getPicklistValues()) {
                    if (isRemote == true || pe.getValue() != 'Designated Remote Employee' || division.equalsIgnoreCase('EMEA') && !isErgoPresent) {
                        if(pe.getValue() == 'Designated Remote Employee'){
                            assessmentTypes.add(new SelectOption(pe.getValue(), 'Remote Assessment'));
                        }else{
                            assessmentTypes.add(new SelectOption(pe.getValue(), pe.getLabel()));
                        }
                    }
                }
            }
            return assessmentTypes;
        }
        private set;
    }

    public Boolean trainingCompleted{
        get{
            if(trainingCompleted == null){
                trainingCompleted = false;
            }
            return trainingCompleted;
        }
        set;
    }

    public PageReference save() {

        if(validateCase()){
            newCase.Subject = newCase.DJC_Ergo_Assessment_Type__c + ' Request for ' + contactName;
            newCase.Type = 'Ergonomics Assessment Request';
            newCase.ES_DJC_Topic__c = newCase.DJC_Ergo_Assessment_Type__c + ' Assessment';
            newCase.Tier__c = 'Tier 1';
            if (newCase.DJC_Ergo_In_Pain__c == 'Yes') {
                newCase.Priority = 'High';
            }
            
            Case caseCopy = newCase.clone(false, false, true, true);
            Boolean savingSuccessful = false;
            
            try{
                saveCaseRecord();
                savingSuccessful = true;
            }catch(Exception ex){
                System.debug('Error saving case: ' + ex.getMessage());
            }

            /* This logic has been removed according to W-3209854 - Alejandro Chaparro
            //create workstation & furniture request if any items are requested

            if (savingSuccessful && caseCopy.Ergo_Items_Requested__c != null) {
                Case c = new Case(Description = caseCopy.Subject, Origin='REWS - Web', REWS_Building__c=caseCopy.REWS_Building__c, REWS_Floor__c=caseCopy.REWS_Floor__c,
                        REWS_Cube_number__c = caseCopy.REWS_Cube_number__c, REWS_Request_Type__c='New Supply Request', 
                        REWS_Items_Requested_AMER__c = caseCopy.Ergo_Items_Requested__c, Subject='Workstation & Furniture Request',
                        Type='Furniture Requests', ES_DJC_Topic__c='New Furniture Request', Priority='Low', Tier__c='Tier 1', 
                        RecordTypeId = getRewsRecordType());
                c.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
                insert c;
            }*/
            
            String url = ApexPages.CurrentPage().getUrl();
            PageReference p = new PageReference(url+'&thanks=true');
            p.setRedirect(true);
            return p;
        }
        return null;
    }

    private boolean validateCase() {

        boolean noError = true;
        if (isBlank(newCase.DJC_Ergo_Assessment_Type__c)) {
            newCase.DJC_Ergo_Assessment_Type__c.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        if (!isRemote && isBlank(newCase.REWS_Building__c)) {
            newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        if (!isRemote && isBlank(newCase.REWS_Floor__c)) {
            newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        if (isRemote != true && isBlank(newCase.REWS_Cube_Number__c)) {
            newCase.REWS_Cube_number__c.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        if ((newCase.DJC_Ergo_Assessment_Type__c == 'Designated Remote Employee' 
                || (newCase.DJC_Ergo_Assessment_Type__c == '1x1' && !isErgoPresent))
                && isBlank(newCase.DJC_Ergo_Desk_Depth__c)) {
            newCase.DJC_Ergo_Desk_Depth__c.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        if (isBlank(newCase.DJC_Ergo_Best_Contact__c)) {
            newCase.DJC_Ergo_Best_Contact__c.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        if (isBlank(newCase.DJC_Ergo_In_Pain__c)) {
            newCase.DJC_Ergo_In_Pain__c.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        if (newCase.DJC_Ergo_In_Pain__c == 'Yes' && isBlank(newCase.DJC_Ergo_Pain_Summary__c)) {
            newCase.DJC_Ergo_Pain_Summary__c.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        if (newCase.Description == null) {
            newCase.Description.addError(DEFAULT_ERROR_MESSAGE);
            noError = false;
        }
        return validateAttachments() && noError;
    }

    private boolean validateAttachments() {

        boolean noError = true;

        Boolean photosAttached = !(Attach1 == null && Attach2 == null && Attach3 == null && Attach4 == null && Attach5 == null && Attach6 == null && Attach7 == null);

        if (!photosAttached && (newCase.DJC_Ergo_Assessment_Type__c == 'Designated Remote Employee' 
                || newCase.DJC_Ergo_Assessment_Type__c == '1x1' && !isErgoPresent)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please attach a photo(s) of your work area before submitting this request'));
            noError = false;
        }
        if (Attach8 == null && !isIndyEmployee && !isQuebecEmployee) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You are required to complete the ergonomics online training before requesting an assessment. If you have already completed the training, please attach the email confirmation before submitting this request. If you have not completed the training, please do so now.'));
            noError = false;
        }
        return noError;
    }
}