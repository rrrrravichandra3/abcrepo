public with sharing class CompensationEditController {
    public List<User> compUsers {get; set;}
    public String retURL {get; set;}
    private String usrIDs {get; set;}
    public String planDetail {get; set;}
    public String recordName {get; set;}
    public String currentRecordType {get; set;}
    public String currentRecordName {get; set;}
    public String compCurrency {get; set;}
    public String compensationIDs   {get; set;}
    public String compensationNames {get; set;}
    public String recordStatus      {get; set;}
    public List<String> compStatus  {get; set;}
    public List<Compensation__c> compensations {get; set;}
    public List<String> recordCurrencyCode {get; set;}
    public List<String> recordCurrencyDescription {get; set;}
    public boolean showBack {get; set;}
    private Id uIDs     {get; set;}
    private ListID__c userIDs {get; set;}
    public CompensationEditController(){
        compensationIDs     = '';
        compensationNames   = '';
        uIDs = null;
        showBack = false;
        if(Apexpages.currentPage().getParameters().get('uIDs') != null){
            uIDs = System.currentPageReference().getParameters().get('uIDs');
            
        }else{
            uIDs = System.currentPageReference().getParameters().get('userIDs');
            showBack = true;    
        }
        if(uIDs!=null){
            userIDs = [Select Id, CollectionID__c From ListID__c Where Id =: uIDs];
            this.usrIDs = userIDs.CollectionID__c;  
        }
        if(showBack){
            retURL = 'apex/LaunchCompensation?userIDs=' + usrIDs;
        }
        currentRecordType = System.currentPageReference().getParameters().get('recordID');
        currentRecordName = [Select r.Name From RecordType r Where r.Id =: currentRecordType limit 1].Name;
                
        
        compUsers = new List<User>();
        recordCurrencyCode = new List<String>();
        recordCurrencyCode.add('USD');
        recordCurrencyCode.add('AUD');
        recordCurrencyCode.add('CAD');
        recordCurrencyCode.add('CHF');
        recordCurrencyCode.add('CNY');
        recordCurrencyCode.add('DKK');
        recordCurrencyCode.add('EUR');
        recordCurrencyCode.add('GBP');
        recordCurrencyCode.add('HKD');
        recordCurrencyCode.add('HUF');
        recordCurrencyCode.add('ILS');
        recordCurrencyCode.add('INR');
        recordCurrencyCode.add('JPY');
        recordCurrencyCode.add('KRW');
        recordCurrencyCode.add('MXN');
        recordCurrencyCode.add('NZD');
        recordCurrencyCode.add('PHP');
        recordCurrencyCode.add('SEK');
        recordCurrencyCode.add('SGD');
        recordCurrencyCode.add('THB');
        recordCurrencyCode.add('TWD');
        
        
        recordCurrencyDescription = new List<String>();
        recordCurrencyDescription.add('U.S. Dollar');
        recordCurrencyDescription.add('Australian Dollar');
        recordCurrencyDescription.add('Canadian Dollar');
        recordCurrencyDescription.add('Swiss Franc');
        recordCurrencyDescription.add('Chinese Yuan');
        recordCurrencyDescription.add('Danish Krone');
        recordCurrencyDescription.add('Euro');
        recordCurrencyDescription.add('British Pound');
        recordCurrencyDescription.add('Hong Kong Dollar');
        recordCurrencyDescription.add('Hungarian Forint');
        recordCurrencyDescription.add('Israeli Shekel');
        recordCurrencyDescription.add('Indian Rupee');
        recordCurrencyDescription.add('Japanese Yen');
        recordCurrencyDescription.add('Korean Won');
        recordCurrencyDescription.add('Mexican Peso');
        recordCurrencyDescription.add('New Zealand Dollar');
        recordCurrencyDescription.add('Philippine Peso');
        recordCurrencyDescription.add('Swedish Krona');
        recordCurrencyDescription.add('Singapore Dollar');
        recordCurrencyDescription.add('Thai Baht');
        recordCurrencyDescription.add('Taiwan Dollar');
        compensations = new List<Compensation__c>();
        this.compStatus = new List<String>();
        compStatus.add('--None--');
        compStatus.add('Not Completed');
        compStatus.add('Completed');

        
    }
    
    public List<SelectOption> getAllRecordCurrency(){
        integer last = recordCurrencyCode.size();
        List<SelectOption> records = new List<SelectOption>();
        for (integer i = 0; i < last; i++){
            records.add(new SelectOption(recordCurrencyCode[i], recordCurrencyDescription[i]));
        }
        return records;
    }
    
    public List<SelectOption> getAllCompensationStatus(){
        integer last = compStatus.size();
        List<SelectOption> records = new List<SelectOption>();
        records.add(new SelectOption('', compStatus[0]));
        for (integer i = 1; i < last; i++){
            records.add(new SelectOption(compStatus[i], compStatus[i]));
        }
        return records;
    }
    
    public List<User> getCompUsers(){
        
        if(usrIDs != null){
            List<String> IDs = usrIDs.split(';');
            
            if(IDs.size() > 0){
                compUsers = [Select Id , name , email , phone, Department, EmployeeNumber From User Where EmployeeNumber IN: IDs and isActive=true];
            }   
        }
        return compUsers;
    }
    
    
    
    public PageReference saveAndContinue(){
        getCompUsers();
        if(compUsers.size() > 0){
            Compensation__c comp;
            
            if(recordName != null && recordName != ''){
                integer times=0;
               //moved the below line of code out of the for loop  
			   //W-1351704 references the bug
              Boolean  flag=Schema.sObjectType.Compensation__c.fields.Name.isCreateable() &&
                    Schema.sObjectType.Compensation__c.fields.OwnerId.isCreateable() &&
                    Schema.sObjectType.Compensation__c.fields.RecordTypeId.isCreateable() &&
                    Schema.sObjectType.Compensation__c.fields.Status__c.isCreateable() &&
                    Schema.sObjectType.Compensation__c.fields.CurrencyIsoCode.isCreateable();                    
                   
                   if(!flag){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have premission to Access Compensation Load App'));                   		
                        return null;                   		
                   }
                   
                for(User u : compUsers){
                    
                  //  {
                        comp = new Compensation__c();
                        comp.Name = u.Name + ' ' + u.EmployeeNumber + '-' + recordName;
                        compensationNames  += u.Id + ';';
                        comp.OwnerId = u.Id;
                        comp.RecordTypeId = currentRecordType;
                        if(this.recordStatus != null && !this.recordStatus.equals('')){
                            comp.Status__c = recordStatus;
                        }
                        //comp.Plan_Details__c = planDetail;
                        comp.CurrencyIsoCode = 'USD';
                        this.compensations.add(comp);
                  //  }
                }
                if(Schema.sObjectType.Compensation__c.isCreateable()){
                    insert compensations;
                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Compensations are not saved due to security violation'));
                }
                for(Integer i = 0; i < compensations.size(); i++){
                    compensationIDs   += compensations[i].Id + ';';
                } 
            }
            
        }
        return attachCompensation();
    } 
    
    public PageReference attachCompensation(){
        PageReference editPage = new PageReference('/apex/CompensationAttachment');
        editPage.setRedirect(true);
        
        if(compensations.size() > 0){
            if(Schema.sObjectType.ListID__c.fields.CollectionID__c.isCreateable() && Schema.sObjectType.ListID__c.fields.CollectionID__c.isUpdateable() &&
            Schema.sObjectType.ListID__c.fields.CompNamesCollection__c.isCreateable() && Schema.sObjectType.ListID__c.fields.CompNamesCollection__c.isUpdateable() &&
            Schema.sObjectType.ListID__c.fields.CompPlanDetail__c.isCreateable() && Schema.sObjectType.ListID__c.fields.CompPlanDetail__c.isUpdateable()){
                userIDs.CollectionID__c = compensationIDs;
                userIDs.CompNamesCollection__c = compensationNames;
                userIDs.CompPlanDetail__c = planDetail;
                upsert userIDs;
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Compensations are not saved due to security violation'));
            }
            editPage.getParameters().put('compIDs', userIDs.Id);
            editPage.getParameters().put('recordName', recordName);
            return editPage;    
        }
        return null;
        
        
    }
    
    public PageReference cancel(){
        PageReference launch = new PageReference('/apex/LaunchCompensation');
        launch.setRedirect(true);
        launch.getParameters().put('uIDs', uIDs);
        return launch;
    }
    
    
    
}