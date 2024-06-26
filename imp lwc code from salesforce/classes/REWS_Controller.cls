public class REWS_Controller extends BaseDJCController  {
    public static final String DEFAULT_ERROR_MESSAGE = 'Value is required';
	public static final String ISSUE_ERROR_MESSAGE = 'Please select one issue.';
    private REWS_Setting__c settings;    
    public boolean isOversizedPackage {get;set;}
    public String packCaseNumber{get;set;}
    public String packcaseId{get;set;}
    public boolean isApprovalAttached {get;set;}
    public String LargeFreightShipmentDestination {get;set;} 
    public String errorMessage{get;private set;}
    //All description fields go here
    public String requestSubject{get;set;}
    public String setupdescription{get;set;}
    
    
    public REWS_Controller(){ 
        
        if(ApexPages.currentPage().getParameters().get('PackcaseNum')!=null){
            packcaseId = ApexPages.currentPage().getParameters().get('PackcaseNum');
            packCaseNumber = [select caseNumber from case where Id=:packcaseId].caseNumber;
            
        } 
        isOversizedPackage = false;
        isApprovalAttached = false;
        settings = REWS_Setting__c.getInstance();
        reset();
        
    }    
    public REWS_Controller controller{get{return this;}}
    
    public List<SelectOption> getLOVLocations(){
        List<SelectOption> options =new List<SelectOption>();
        if(division=='Japan'){
            String locations = System.Label.REWS_Event_Locations_Japan;
             for(String s : locations.split('<br/>',-1)){
                options.add(new SelectOption(s,s));
             }
        }
        return options;
    }

    public Boolean showErgotronRequest{
        public get{
            return !division.equalsIgnoreCase('EMEA');
        }
        private set;
    }
    
    public override string getRecordType(){
        String recordType;
        if (division != null){          
            if (settings!= null){
                if (division == 'AmerHQ'){
                    recordType = settings.REWS_Case_Record_Type_Amer_HQ__c;
                }else if (division == 'AmerNonHQ'){
                    recordType = settings.REWS_Case_Record_Type_Amer_Non_HQ__c;
                }else if (division == 'APAC'){
                    recordType = settings.REWS_Case_Record_Type_APAC__c;
                }else if (division == 'EMEA'){
                    recordType = settings.REWS_Case_Record_Type_EMEA__c;
                }else if (division == 'Japan'){
                    recordType = settings.REWS_Case_Record_Type_Japan__c;
                }                                       
            }                       
        }
        else recordType = settings.REWS_Case_Record_Type_Amer_HQ__c; //default to Amer HQ
        
        return recordType;
    }
        
    public List<SelectOption> supplyOptions {get; set;}
    
    public List<SelectOption> selectedSupplyOptions {get; set;}
    
    public override void setType(){
        super.setType();
        
        if (RequestFormType == 'LargeDeliveryHQ' || RequestFormType == 'LargeDeliveryNonHQ' || RequestFormType == 'LargeDeliveryEMEA') {
        	newCase.REWS_Addressed_to_Name__c = currentUser.contact.Id;
        	newCase.REWS_Contact_Person_Upon_Arrival__c = currentUser.contact.Id;
        }
        
        if (RequestFormType == 'PackageShippingEMEA') {
        	newCase.REWS_EMEA_Currency__c = 'EUR';
        }
		newCase.Origin = 'REWS - Web';
        newCase.Tier__c = 'Tier 1';             

    }
    
    private void addCaseDescription() {
        if (newCase.description == null) {
            newCase.description = '';
        }
        if (!isBlank(requestSubject)) {
            newCase.description += 'Request Subject: '+requestSubject+'\n';
        }
        if (!isBlank(setupdescription)) {
            newCase.description += 'Setup Style: '+setupdescription+'\n';
        }
    
    }

    private void addCaseSubject() {
        if (newCase.RecordTypeId == settings.REWS_Case_Record_Type_Amer_HQ__c &&
            newCase.Type == 'Event & Meeting Setup' &&
            newCase.Subject == 'On-Site Meeting & Event Setup Request' && 
            newCase.REWS_Date_and_Time_of_Event__c != null &&
            newCase.REWS_Event_Start_Time__c != null &&
            newCase.REWS_Event_End_Time__c != null) {
            newCase.Subject = newCase.Subject + ' on ' + newCase.REWS_Date_and_Time_of_Event__c.month() +
            '/' + newCase.REWS_Date_and_Time_of_Event__c.day() + '/' + newCase.REWS_Date_and_Time_of_Event__c.year()
             + ' from ' + 
            newCase.REWS_Event_Start_Time__c + ' to ' + newCase.REWS_Event_End_Time__c;
        }
    }
    
    public PageReference assignOverSized(){
       isOversizedPackage=true;
       return saveCase();
    }
    
    public PageReference saveCase(Case c) {
    	newCase = c;
    	return saveCase();
    }
    
    public PageReference saveCase(){
        
        if(isOversizedPackage && oversizedValidation()){
            return null;
        }
        else if (!isOversizedPackage && validationErrors()) {
            return null;
        }
        addCaseDescription();
        addCaseSubject();
        saveCaseRecord();  
		
        //W-3190509 insert PDF attachment receipt for Onsite Event Type cases.
        if(newCase.Type == 'Event & Meeting Setup'){
        	createPDFAttachment(newcase.id,newcase.subject,requestFormType);            
        }

        reset();
        String url = ApexPages.CurrentPage().getUrl();
        PageReference p = new PageReference(url+'&thanks=true');
        p.setRedirect(true);
        return p;
    }
     
     @Future(callout=true)
     private static void createPDFAttachment(id caseid,string subjectname,string requestFormType){
        PageReference pdf = Page.ESDJC_Webforms_PDFPage;
         
        pdf.getParameters().put('recordId', caseid);
        pdf.getParameters().put('ObjectName', 'case');
         
        if(requestFormType == 'OnsiteMeetingHQ')
        	pdf.getParameters().put('FieldSetName', 'ESDJC_Webform_OnsiteEvent_HQ');
        else{
        	pdf.getParameters().put('FieldSetName', 'ESDJC_Webform_OnsiteEvent_NonHQ');             
        }
        Attachment attach = new Attachment();
        attach.ParentId = caseid;
        attach.name = subjectname + '-' + Datetime.now().format('MM-dd-yyyy KK-mm a') + '.pdf';
        attach.ContentType = 'application/pdf';
        attach.body = pdf.getContentAsPDF();
        insert attach;
    }   
    private boolean validationErrors(){
        boolean isError = false;
        errorMessage = ''; 
        if (!(RequestFormType.equalsIgnoreCase('ErgoAssessmentRequestAmer') || 
              RequestFormType.equalsIgnoreCase('ErgotronRequestAmer')) 
              && isblank(requestSubject)){
        	newCase.addError('Subject is required');
            isError= true;
        }
        //Amer NonHQ validations
        if ((division=='AmerNonHQ')){
            if (RequestFormType =='OnsiteMeetingNonHQ'){
                newCase.Type = 'Event & Meeting Setup';
                newCase.Subject = 'On-Site Meeting & Event Setup Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Number_of_Guests__c)){
                    newCase.REWS_Number_of_Guests__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Date_and_Time_of_Event__c)){
                    newCase.REWS_Date_and_Time_of_Event__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if(newCase.REWS_Markers__c == true && isBlank(newCase.REWS_Markers_Amount__c)){
                	newCase.REWS_Markers_Amount__c.addError('Please enter amount value');
                	isError=true;
                }
                if(newCase.REWS_Flipchart__c == true && isBlank(newCase.REWS_Flipchart_Amount__c)){
                	newCase.REWS_Flipchart_Amount__c.addError('Please enter amount value');
                	isError=true;
                }
                if(newCase.REWS_Easel__c == true && isBlank(newCase.REWS_Easel_Amount__c)){
                	newCase.REWS_Easel_Amount__c.addError('Please enter amount value');
                	isError=true;
                }   
                if (isblank(newCase.REWS_Do_you_need_catering__c)){
                    newCase.REWS_Do_you_need_catering__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }   
                if (isblank(newCase.REWS_Event_Contact__c)){
                    newCase.REWS_Event_Contact__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (newCase.REWS_Date_and_Time_of_Event__c < System.today()){
                    newCase.REWS_Date_and_Time_of_Event__c.addError('You cannot choose a past date.');
                    isError= true;
                }
                if(isBlank(newCase.REWS_Event_Start_Time__c)){
                	newCase.REWS_Event_Start_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
				
				if(isBlank(newCase.REWS_Event_End_Time__c)){
                	newCase.REWS_Event_End_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                if (compareTime()) {
                    newCase.REWS_Event_End_Time__c.addError('Please enter End Time greater than Start Time of Event.');
                    isError= true;
                }
                if(isBlank(newCase.REWS_Building__c)){
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }                      
              if(!isBlank(newCase.REWS_Setup_requested__c) && newCase.REWS_Setup_requested__c.equalsIgnoreCase('Other') &&
                  isBlank(setupdescription)) {
                	newCase.addError('Please specify your Setup Style');
                	isError = true;
                }                   
            }
            if (RequestFormType =='ConfRoomConversionNonHQ'){
                newCase.Type = 'Employee Moves & Workspace Assignments';
                newCase.ES_DJC_Topic__c = 'Conference Room Conversion';
                newCase.Subject = 'Conference Room Conversion Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Business_Justification__c)){
                    newCase.REWS_Business_Justification__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Space_Type__c)){
                    newCase.REWS_Space_Type__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                    return isError;
                } 
                  
                if ((newCase.REWS_Space_Type__c =='Restricted Conference Room')||
                                    (newCase.REWS_Space_Type__c =='Employee Seating')){
                    if (Attach1==null){
                        isApprovalAttached = true;
                        isError= true;
                    }
                }   
                if (newCase.REWS_Space_Type__c =='Private Office'){
                    if (Attach2==null){
                        isApprovalAttached = true;
                        isError= true;
                    }
                }   
            }
            if (RequestFormType =='PackageLocatorNonHQ'){
                newCase.Type = 'Mail Services'; 
                newCase.ES_DJC_Topic__c = 'Package Locater';
                newCase.Subject = 'Package Locator Request';
                
                if (isblank(newCase.REWS_Tracking_Number__c)){
                    newCase.REWS_Tracking_Number__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Building__c)){
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                  	isError= true;
                }
                if (isblank(newCase.REWS_Floor__c)){
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Sender__c)){
                    newCase.REWS_Sender__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Exact_Address_Given_to_Deliverer__c)){
                    newCase.REWS_Exact_Address_Given_to_Deliverer__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Was_addressee_name_the_employee__c)){
                    newCase.REWS_Was_addressee_name_the_employee__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }                                       
                if (isblank(newCase.REWS_Size__c)){
                    newCase.REWS_Size__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }                                                       
            }
            if (RequestFormType == 'SupplyRoomNonHQ') {
                newCase.Subject = 'Supply Room Request';
                newCase.Type = 'Office & Workstation Supplies';
                newCase.ES_DJC_Topic__c = 'Supply Room Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Supplies_Needed__c)) {
                    newCase.REWS_Supplies_Needed__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Building__c)) {
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Floor__c)) {
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
            }
            if (RequestFormType == 'WorkstationAndFurnitureNonHQ') {
                newCase.Subject = 'Workstation & Furniture Request';
                newCase.Type = 'Furniture Requests';
                newCase.ES_DJC_Topic__c = 'New Furniture Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Building__c)) {
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Floor__c)) {
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Cube_number__c)) {
                    newCase.REWS_Cube_number__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Request_Type__c)) {
                    newCase.REWS_Request_Type__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
            } 
            if (RequestFormType == 'MailFolderNonHQ') {
                newCase.Subject = 'Mail Folder Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Mail Folder Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Building__c)) {
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Floor__c)) {
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Cube_number__c)) {
                    newCase.REWS_Cube_number__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (newCase.REWS_Needs_mail_folder__c == false && newCase.REWS_Cancel_mail_folder__c == false) {
                    newCase.REWS_Needs_mail_folder__c.addError('Please choose at least one checkbox');
                    isError = true;
                }
            }
            
            if (RequestFormType == 'FedexAccountNonHQ') {
                newCase.Subject = 'Fedex Account Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Fedex Account Request';
                newCase.REWS_Fedex_Account_Request__c = true;
                
                if (isblank(newCase.REWS_Request_for_someone_else__c)) {
                    newCase.REWS_Request_for_someone_else__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                else if (newCase.REWS_Request_for_someone_else__c == 'Yes') {
                    if (isblank(newCase.REWS_Fedex_account_name__c)) {
                        newCase.REWS_Fedex_account_name__c.addError(DEFAULT_ERROR_MESSAGE);
                        isError = true;
                    }
                }
                
                else if (newCase.REWS_Request_for_someone_else__c == 'No') {
                    newCase.REWS_Fedex_account_name__c = null;
                }
            }
            
            if (RequestFormType == 'LargeDeliveryNonHQ') {
                newCase.Subject = 'Large Delivery/Freight Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Receiving';
                newCase.Priority = 'Low';
                 if (isblank(LargeFreightShipmentDestination)) {
                    newCase.addError('Where do you want it delivered? '+DEFAULT_ERROR_MESSAGE);
                    errorMessage = '<strong>Error:</strong>'+DEFAULT_ERROR_MESSAGE;
                    isError = true;
                }
                if (isblank(newCase.REWS_Expected_Delivery_Location__c)) {
                    newCase.REWS_Expected_Delivery_Location__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Addressed_to_Name__c)) {
                    newCase.REWS_Addressed_to_Name__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Contact_Person_Upon_Arrival__c)) {
                    newCase.REWS_Contact_Person_Upon_Arrival__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Expected_Date_and_Time_of_Delivery__c)) {
                    newCase.REWS_Expected_Date_and_Time_of_Delivery__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (newCase.REWS_Expected_Date_and_Time_of_Delivery__c < system.today()) {
                    newCase.REWS_Expected_Date_and_Time_of_Delivery__c.addError('You cannot add a past date.');
                    isError = true;
                }
                if(!isError){
                    newCase.REWS_Comments_Large_Delivery_Freight_Req__c = 'Destination : '+LargeFreightShipmentDestination + '\n'
                                                                        + newCase.REWS_Comments_Large_Delivery_Freight_Req__c ;
                }
            }
        }
        else if (division == 'AmerHQ') {
            if (RequestFormType == 'OnsiteMeetingHQ') {
                newCase.Type = 'Event & Meeting Setup';
                newCase.Subject = 'On-Site Meeting & Event Setup Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Number_of_Guests__c)) {
                    newCase.REWS_Number_of_Guests__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Date_and_Time_of_Event__c)) {
                    newCase.REWS_Date_and_Time_of_Event__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (newCase.REWS_Date_and_Time_of_Event__c < system.today()) {
                    newCase.REWS_Date_and_Time_of_Event__c.addError('You cannot add a past date.');
                    isError = true;
                }
                if(isBlank(newCase.REWS_Event_Start_Time__c)){
                	newCase.REWS_Event_Start_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                if(isBlank(newCase.REWS_Event_End_Time__c)){
                	newCase.REWS_Event_End_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                if (compareTime()) {
                    newCase.REWS_Event_End_Time__c.addError('Please enter End Time greater than Start Time of Event.');
                    isError= true;
                }
                if (isblank(newCase.REWS_What_do_you_need__c)) {
                    newCase.REWS_What_do_you_need__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Event_Contact__c)) {
                    newCase.REWS_Event_Contact__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                Set<String> tempSupplies = new Set<String>();
                if (newCase.REWS_What_do_you_need__c != null) {
                    tempSupplies.addAll(newCase.REWS_What_do_you_need__c.split(';'));
                }
                if (/*newCase.REWS_What_do_you_need__c == 'Supplies' || newCase.REWS_What_do_you_need__c == 'Both'*/ tempSupplies.contains('Supplies')) {
                    if (newCase.REWS_Markers__c == false && newCase.REWS_Flipchart__c == false && newCase.REWS_Easel__c == false) {
                        newCase.REWS_Markers__c.addError('Please choose atleast one supplies');
                        isError = true;
                    }
                }
                if(newCase.REWS_Markers__c == true && isBlank(newCase.REWS_Markers_Amount__c)){
                	newCase.REWS_Markers_Amount__c.addError('Please enter amount value');
                	isError = true;
                }
                if(newCase.REWS_Flipchart__c == true && isBlank(newCase.REWS_Flipchart_Amount__c)){
                	newCase.REWS_Flipchart_Amount__c.addError('Please enter amount value');
                	isError = true;
                }
                if(newCase.REWS_Easel__c == true && isBlank(newCase.REWS_Easel_Amount__c)){
                	newCase.REWS_Easel_Amount__c.addError('Please enter amount value');
                	isError = true;
                }
                if(!tempSupplies.contains('Supplies') && (newCase.REWS_Markers__c == true || newCase.REWS_Flipchart__c == true || newCase.REWS_Easel__c == true)){
                	newCase.REWS_What_do_you_need__c.addError('Please choose Supplies value as Supplies are selected below.');
                	isError = true;
                }
                if (/*(newCase.REWS_What_do_you_need__c == 'Setup' || newCase.REWS_What_do_you_need__c == 'Both')*/ tempSupplies.contains('Setup') && isblank(newCase.REWS_Setup_requested__c)) {
                    newCase.REWS_Setup_requested__c.addError('Please choose a setup style');
                    isError = true;
                }
                if(!isBlank(newCase.REWS_Setup_requested__c) && !tempSupplies.contains('Setup')){
                	newCase.REWS_What_do_you_need__c.addError('Please choose Setup value as Setup Style field is selected.');
                	isError = true;
                }
				if(!isBlank(newCase.REWS_Setup_requested__c) && newCase.REWS_Setup_requested__c.equalsIgnoreCase('Other') &&
                  isBlank(setupdescription)) {
                	newCase.addError('Please specify your Setup Style');
                	isError = true;
                }                
                if (newCase.REWS_Catered__c == true && isblank(newCase.REWS_Name_of_Caterer__c)) {
                    newCase.REWS_Name_of_Caterer__c.addError('Please enter the name of caterer');
                    isError = true;
                }
                if(isBlank(newCase.REWS_Building__c)){
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }    
            }
            else if (RequestFormType == 'ConfRoomConversionHQ') {
                newCase.Subject = 'Conference Room Conversion Request';
                newCase.Type = 'Employee Moves and Workspace Assignments';
                newCase.ES_DJC_Topic__c = 'Conference Room Conversion';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Space_Type__c)) {
                    newCase.REWS_Space_Type__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Business_Justification__c)) {
                    newCase.REWS_Business_Justification__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Preferred_Location__c)) {
                    newCase.REWS_Preferred_Location__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if ((newCase.REWS_Space_Type__c =='Restricted Conference Room')||(newCase.REWS_Space_Type__c =='Employee Seating')){
                    if (attach1==null){
                        isApprovalAttached = true;
                        isError= true;
                    }
                }   
                if (newCase.REWS_Space_Type__c =='Private Office'){
                    if (attach2==null){
                        isApprovalAttached = true;
                        isError= true;
                    }
                }
            }
            else if (RequestFormType == 'SupplyRoomHQ') {
                newCase.Subject = 'Supply Room Request';
                newCase.Type = 'Office & Workstation Supplies';
                newCase.ES_DJC_Topic__c = 'Supply Room Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Supplies_Needed__c)) {
                    newCase.REWS_Supplies_Needed__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Building__c)) {
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Floor__c)) {
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
            }
            else if (RequestFormType == 'WorkstationAndFurnitureHQ') {
                newCase.Subject = 'Workstation & Furniture Request';
                newCase.Type = 'Furniture Requests';
                newCase.ES_DJC_Topic__c = 'New Furniture Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Building__c)) {
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Floor__c)) {
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Cube_number__c)) {
                    newCase.REWS_Cube_number__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Request_Type__c)) {
                    newCase.REWS_Request_Type__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
            }
            else if (RequestFormType == 'MailFolderHQ') {
                newCase.Subject = 'Mail Folder Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Mail Folder Request';
                newCase.Priority = 'Low';
                
                if (isblank(newCase.REWS_Building__c)) {
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Floor__c)) {
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (isblank(newCase.REWS_Cube_number__c)) {
                    newCase.REWS_Cube_number__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                if (newCase.REWS_Needs_mail_folder__c == false && newCase.REWS_Cancel_mail_folder__c == false) {
                    newCase.REWS_Needs_mail_folder__c.addError('Please choose atleast one checkbox');
                    isError = true;
                }
            }
            else if (RequestFormType == 'FedexAccountHQ') {
                newCase.Subject = 'Fedex Account Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Fedex Account Request';
                newCase.REWS_Fedex_Account_Request__c = true;
                
                if (isblank(newCase.REWS_Request_for_someone_else__c)) {
                    newCase.REWS_Request_for_someone_else__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                
                else if (newCase.REWS_Request_for_someone_else__c == 'Yes') {
                    if (isblank(newCase.REWS_Fedex_account_name__c)) {
                        newCase.REWS_Fedex_account_name__c.addError(DEFAULT_ERROR_MESSAGE);
                        isError = true;
                    }
                }
                
                else if (newCase.REWS_Request_for_someone_else__c == 'No') {
                    newCase.REWS_Fedex_account_name__c = null;
                }
            }
            else if (RequestFormType =='PackageLocatorHQ') {
                newCase.Subject = 'Package Locator Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Package Locator';
                
                if (isblank(newCase.REWS_Tracking_Number__c)){
                    newCase.REWS_Tracking_Number__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Building__c)){
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Floor__c)){
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Sender__c)){
                    newCase.REWS_Sender__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Exact_Address_Given_to_Deliverer__c)){
                    newCase.REWS_Exact_Address_Given_to_Deliverer__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isblank(newCase.REWS_Was_addressee_name_the_employee__c)){
                    newCase.REWS_Was_addressee_name_the_employee__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }                                       
                if (isblank(newCase.REWS_Size__c)){
                    newCase.REWS_Size__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }                                                       
            }
            else if (RequestFormType == 'LargeDeliveryHQ') {
                newCase.Subject = 'Large Delivery/Freight Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Receiving';
                newCase.Priority = 'Low';
                if (isblank(LargeFreightShipmentDestination)) {
                    newCase.addError('Where do you want it delivered? '+DEFAULT_ERROR_MESSAGE);
                    errorMessage = '<strong>Error:</strong>'+DEFAULT_ERROR_MESSAGE;
                    isError = true;
                }
                if (isblank(newCase.REWS_Expected_Delivery_Location__c)) {
                    newCase.REWS_Expected_Delivery_Location__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Addressed_to_Name__c)) {
                    newCase.REWS_Addressed_to_Name__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Contact_Person_Upon_Arrival__c)) {
                    newCase.REWS_Contact_Person_Upon_Arrival__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Expected_Date_and_Time_of_Delivery__c)) {
                    newCase.REWS_Expected_Date_and_Time_of_Delivery__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (newCase.REWS_Expected_Date_and_Time_of_Delivery__c < system.today()) {
                    newCase.REWS_Expected_Date_and_Time_of_Delivery__c.addError('You cannot add a past date.');
                    isError = true;
                }
                if(!isError){
                    newCase.REWS_Comments_Large_Delivery_Freight_Req__c = 'Destination : '+LargeFreightShipmentDestination + '\n'
                                                                        + newCase.REWS_Comments_Large_Delivery_Freight_Req__c ;
                }


            }
           
        }
        
        //Japan Validations
        else if(division=='Japan'){
            if(RequestFormType=='EventNotificationJapan'){
                newCase.Subject= 'Event Notification Request';
                newCase.Type = 'Event & Meeting Setup';
                
                if (isBlank(newCase.REWS_Location__c)) {
                    newCase.REWS_Location__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Date_and_Time_of_Event__c)) {
                    newCase.REWS_Date_and_Time_of_Event__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (newCase.REWS_Date_and_Time_of_Event__c < system.today()) {
                    newCase.REWS_Date_and_Time_of_Event__c.addError('You cannot add a past date.');
                    isError= true;
                }
                if(isBlank(newCase.REWS_Event_Start_Time__c)){
                	newCase.REWS_Event_Start_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                if(isBlank(newCase.REWS_Event_End_Time__c)){
                	newCase.REWS_Event_End_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                if (compareTime()) {
                    newCase.REWS_Event_End_Time__c.addError('Please enter End Time greater than Start Time of Event.');
                    isError= true;
                }
            }
        }
        
        //EMEA Validations
        else if(division=='EMEA'){
            if(RequestFormType=='CarparkAccessEMEA'){
                newCase.Subject='Carpark Access Request';
                newCase.Type = 'Local Amenities';
                newCase.ES_DJC_Topic__c = 'Parking';
                newCase.Priority = 'Low';
                
                if (isBlank(newCase.REWS_Office__c)) {
                    newCase.REWS_Office__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Car_number_plate__c)) {
                    newCase.REWS_Car_number_plate__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
            }
            else if(RequestFormType=='PackageShippingEMEA'){
                newCase.Subject='Package Shipping Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Package Shipping Request';
                
                if (isBlank(newCase.REWS_Recipient_Name__c)) {
                    newCase.REWS_Recipient_Name__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Recipient_Phone_Number__c)) {
                    newCase.REWS_Recipient_Phone_Number__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Destination_Address__c)) {
                    newCase.REWS_Destination_Address__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Description_Quantity__c)) {
                    newCase.REWS_Description_Quantity__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Value__c)) {
                    newCase.REWS_Value__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_EMEA_Currency__c)) {
                    newCase.REWS_EMEA_Currency__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                
                if (isBlank(newCase.REWS_Date_Delivery__c)) {
                    newCase.REWS_Date_Delivery__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
            }
            
            else if(RequestFormType=='SupplyRequestEMEA'){
                newCase.Subject='Special Office Supply Request';
                newCase.Type = 'Office & Workstation Supplies';
                newCase.ES_DJC_Topic__c = 'Supply Room Request';
                newCase.Priority = 'Low';
                
                if (isBlank(newCase.REWS_Building__c)) {
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Floor__c)) {
                    newCase.REWS_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Additional_Supplies_Needed__c)) {
                    newCase.REWS_Additional_Supplies_Needed__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
            }
            else if(RequestFormType=='OnsiteMeetingEMEA'){
                newCase.Type = 'Event & Meeting Setup';
                newCase.Subject = 'On-Site Meeting & Event Setup Request';
                newCase.Priority = 'Low';
                
               if (newCase.REWS_Date_and_Time_of_Event__c < system.today()) {
                    newCase.REWS_Date_and_Time_of_Event__c.addError('You cannot add a past date.');
                    isError= true;
                }
                if(isBlank(newCase.REWS_Event_Start_Time__c)){
                	newCase.REWS_Event_Start_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                
                if (isBlank(newCase.REWS_Location__c)) {
                    newCase.REWS_Location__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Date_and_Time_of_Event__c)) {
                    newCase.REWS_Date_and_Time_of_Event__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
               
                if(isBlank(newCase.REWS_Event_End_Time__c)){
                	newCase.REWS_Event_End_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                
                if (compareTime()) {
                    newCase.REWS_Event_End_Time__c.addError('Please enter End Time greater than Start Time of Event.');
                    isError= true;
                }
                if (isBlank(newCase.REWS_Number_of_Guests__c)) {
                    newCase.REWS_Number_of_Guests__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_What_do_you_need__c)) {
                    newCase.REWS_What_do_you_need__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Event_Contact__c)) {
                    newCase.REWS_Event_Contact__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                
                if(newCase.REWS_What_do_you_need__c!=null && newCase.REWS_What_do_you_need__c.contains('Supplies')){
                    if (!newCase.REWS_Videoconferencing__c && !newCase.REWS_Flipchart_Easel__c) {
                       newCase.REWS_Videoconferencing__c.addError('Please choose atleast one supplies');
                       isError= true;
                  }
                }
                
                if(newCase.REWS_Flipchart_Easel__c == true && isBlank(newCase.REWS_Flipchart_Easel_Amount__c)){
                	newCase.REWS_Flipchart_Easel_Amount__c.addError('Please enter amount value');
                	isError = true;
                }
                
                if(newCase.REWS_What_do_you_need__c!=null && newCase.REWS_What_do_you_need__c.contains('Setup')){
                    if (isBlank(newCase.REWS_Setup_requested__c)) {
                       newCase.REWS_Setup_requested__c.addError(DEFAULT_ERROR_MESSAGE);
                        isError= true;
                  }
                }
                if(isBlank(newCase.REWS_Building__c)){
                    newCase.REWS_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }    
                if(!isBlank(newCase.REWS_Setup_requested__c) && newCase.REWS_Setup_requested__c.equalsIgnoreCase('Other') &&
                  isBlank(setupdescription)) {
                	newCase.addError('Please specify your Setup Style');
                	isError = true;
                }    
                
            }
            if (RequestFormType == 'LargeDeliveryEMEA') {
                newCase.Subject = 'Large Delivery/Freight Request';
                newCase.Type = 'Mail Services';
                newCase.ES_DJC_Topic__c = 'Receiving';
                newCase.Priority = 'Low';
                if (isblank(LargeFreightShipmentDestination)) {
                    newCase.addError('Where do you want it delivered? '+DEFAULT_ERROR_MESSAGE);
                    errorMessage = '<strong>Error:</strong>'+DEFAULT_ERROR_MESSAGE;
                    isError = true;
                }
                if (isblank(newCase.REWS_Expected_Delivery_Location__c)) {
                    newCase.REWS_Expected_Delivery_Location__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Addressed_to_Name__c)) {
                    newCase.REWS_Addressed_to_Name__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Contact_Person_Upon_Arrival__c)) {
                    newCase.REWS_Contact_Person_Upon_Arrival__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (isblank(newCase.REWS_Expected_Date_and_Time_of_Delivery__c)) {
                    newCase.REWS_Expected_Date_and_Time_of_Delivery__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError = true;
                }
                if (newCase.REWS_Expected_Date_and_Time_of_Delivery__c < system.today()) {
                    newCase.REWS_Expected_Date_and_Time_of_Delivery__c.addError('You cannot add a past date.');
                    isError = true;
                }
                if(!isError){
                    newCase.REWS_Comments_Large_Delivery_Freight_Req__c = 'Destination : '+LargeFreightShipmentDestination + '\n'
                                                                        + newCase.REWS_Comments_Large_Delivery_Freight_Req__c ;
                }
            }
        }
        // APAC Validations
        else if ((division=='APAC')){
            if (RequestFormType == 'CateringRequestAPAC') {
                newCase.Type = 'Event & Meeting Setup';
                newCase.Subject = 'Event Notification - Catering Request';
                
                if (isBlank(newCase.REWS_Number_of_Guests__c)) {
                    newCase.REWS_Number_of_Guests__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Date_and_Time_of_Event__c)) {
                    newCase.REWS_Date_and_Time_of_Event__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (newCase.REWS_Date_and_Time_of_Event__c < system.today()) {
                    newCase.REWS_Date_and_Time_of_Event__c.addError('You cannot add a past date.');
                    isError= true;
                }
                if(isBlank(newCase.REWS_Event_Start_Time__c)){
                	newCase.REWS_Event_Start_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                if(isBlank(newCase.REWS_Event_End_Time__c)){
                	newCase.REWS_Event_End_Time__c.addError(DEFAULT_ERROR_MESSAGE);
                	isError=true;
                }
                if (compareTime()) {
                    newCase.REWS_Event_End_Time__c.addError('Please enter End Time greater than Start Time of Event.');
                    isError= true;
                }
                if (isBlank(newCase.REWS_Location__c)) {
                    newCase.REWS_Location__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Event_Name__c)) {
                    newCase.REWS_Event_Name__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Do_you_need_catering__c)) {
                    newCase.REWS_Do_you_need_catering__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (newCase.REWS_Do_you_need_catering__c == 'Yes') {
                    if (isBlank(newCase.REWS_Name_of_Caterer__c)) {
                        newCase.REWS_Name_of_Caterer__c.addError(DEFAULT_ERROR_MESSAGE);
                        isError= true;
                    }
                    if (isBlank(newCase.REWS_Payment_method_for_caterer__c)) {
                        newCase.REWS_Payment_method_for_caterer__c.addError(DEFAULT_ERROR_MESSAGE);
                        isError= true;
                    }   
                }
            }
        }
        if (RequestFormType == 'RepairsRequest') {
                newCase.Type = 'Building Maintenance';
                newCase.ES_DJC_Topic__c = newCase.REWS_What_needs_repair__c;
                newCase.Subject = 'Repairs / Maintenance / Janitorial Request';
                newCase.ES_DJC_Sub_Topic__c = '--None--';
                if(newCase.RecordTypeId == settings.REWS_Case_Record_Type_Japan__c || newCase.RecordTypeId == settings.REWS_Case_Record_Type_APAC__c) {
                	newCase.Priority = 'High';
                } else {
                	newCase.Priority = 'Low';
                }
               if(newCase.REWS_What_needs_repair__c == null || newCase.REWS_What_needs_repair__c ==''
                || newCase.REWS_What_needs_repair__c.split(';').size()>1){
                    newCase.REWS_What_needs_repair__c.addError(ISSUE_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Issue_Location_Building__c)) {
                    newCase.REWS_Issue_Location_Building__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Issue_Location_Floor__c)) {
                    newCase.REWS_Issue_Location_Floor__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
                if (isBlank(newCase.REWS_Comments_Repairs_Maintainance_Req__c)) {
                    newCase.REWS_Comments_Repairs_Maintainance_Req__c.addError(DEFAULT_ERROR_MESSAGE);
                    isError= true;
                }
            }
            
        return isError;
    }
    
    private boolean oversizedValidation() {
        boolean isError = false;
        
        List<Case> isChildCaseAlrdyExists = [select id from case where parentId= : packcaseId];
        if(isChildCaseAlrdyExists!=null && isChildCaseAlrdyExists.size()>0){
        	newCase.addError('Our records show you have already requested assistance with this package. If you have any questions please go to My Cases tab and add a comment to your case. Thank you! ');
            return true;
        }
        
        newCase.Subject = 'Oversized Package Delivery Assistance Request';
        newCase.Type = 'Local Amenities';
        newCase.ES_DJC_Topic__c = 'Move Items';
        newCase.ParentId= packcaseId;
        //newCase.REWS_Package_Management__c = packageRecord.Id;
                
        if (isblank(newCase.REWS_Requested_Delivery_Location__c)) {
            newCase.REWS_Requested_Delivery_Location__c.addError(DEFAULT_ERROR_MESSAGE);
            isError = true;
        }
                
        if (isblank(newCase.REWS_Date_time_needed_delivered_by__c)) {
            newCase.REWS_Date_time_needed_delivered_by__c.addError(DEFAULT_ERROR_MESSAGE);
            isError = true;
        }
        
        if (newCase.REWS_Date_time_needed_delivered_by__c < system.today()) {
            newCase.REWS_Date_time_needed_delivered_by__c.addError('You cannot add a past date.');
            isError = true;
        }
        
        return isError;
    }
    
    
    private boolean compareTime(){
    	boolean isError = false;
        if ((newCase.REWS_Event_Start_Time__c == null) || (newCase.REWS_Event_End_Time__c == null)) {
            return true;
        }
    	String startTime = newCase.REWS_Event_Start_Time__c.replace(':','.');
    	String endTime = newCase.REWS_Event_End_Time__c.replace(':','.');
    	
    	List<String> startTimeValue = startTime.split(' ',-1);
    	List<String> endTimeValue = endTime.split(' ',-1);
    	
    	if(endTimeValue[1].contains('PM') && startTimeValue[1].contains('PM')) {
    		if(decimal.valueOf(startTimeValue[0]) != 12.00 && decimal.valueOf(startTimeValue[0]) != 12.30){
    			if(decimal.valueOf(endTimeValue[0]) < decimal.valueOf(startTimeValue[0])) 
    				isError = true;
    		}
    		if(decimal.valueOf(startTimeValue[0]) == 12.00 && decimal.valueOf(endTimeValue[0]) != 12.30){
    			if(decimal.valueOf(endTimeValue[0]) > decimal.valueOf(startTimeValue[0])) 
    				isError = true;
    		}
    		if(decimal.valueOf(startTimeValue[0]) == 12.30 && decimal.valueOf(endTimeValue[0]) != 12.30){
    			if(decimal.valueOf(endTimeValue[0]) > decimal.valueOf(startTimeValue[0])) 
    				isError = true;
    		}
    	}
    	
    	if(endTimeValue[1].contains('AM') && startTimeValue[1].contains('AM')) {
    		if(decimal.valueOf(endTimeValue[0]) < decimal.valueOf(startTimeValue[0]))
    			isError = true;
    	}
    	
    	if(endTimeValue[1].contains('AM') && startTimeValue[1].contains('PM')) {
    		if(decimal.valueOf(endTimeValue[0]) > decimal.valueOf(startTimeValue[0]))
    			isError = true;
    	}
    		
    		
    	return isError;
    }
    
    public void cancelCase(){       
        reset();        
    }
      
  public Pagereference doSomething(){
    decimal i = 2;
    return null;
  }
  
  protected override void reset(){
	super.reset();
    isApprovalAttached = false;
    ErrorMessage='';
    supplyOptions = new List<SelectOption>();
  }
  
    public String getUrl() {
        return ESDJC_Util.getSSOURL()+'/apex/REWS_LandingPage?thanks=';
    }
   
    public String getErgoUrl() {
        return ESDJC_Util.getSSOURL()+'/apex/DJC_Ergonomics?thanks=';
    }
    
   
    public REWS_Setting__c getSettings() {
    	return settings;
    }
    
}