/**
 * Base class for all case forms (ES, REWS, Ergo and wellness)
 * 
 * **/
public without sharing abstract class BaseDJCController {
    
    private List<User> thisUser {get;set;}
    public string headermsg{get;set;}
    
    public transient blob Attach1 {get;set;}
    public string FileName1{get;set;}   
    public transient blob Attach2 {get;set;}
    public string FileName2{get;set;}
    public transient blob Attach3 {get;set;}
    public string FileName3{get;set;}
    public transient blob Attach4 {get;set;}
    public string FileName4{get;set;}   
    public transient blob Attach5 {get;set;}
    public string FileName5{get;set;}
    public transient blob Attach6 {get;set;}
    public string FileName6{get;set;}
    public transient blob Attach7 {get;set;}
    public string FileName7{get;set;}
    public transient blob Attach8 {get;set;}
    public string FileName8{get;set;}
    public transient blob Attach9 {get;set;}
    public string FileName9{get;set;}    
    
    public BaseDJCController(){
        thisUser = [select contactid, contact.Division__c, contact.ES_DJC_Work_Location__c, contact.ES_DJC_Contact_Country__c,
                    contact.DJC_Contact_Floor__c,contact.DJC_Contact_Building__c, contact.DJC_Contact_Cube_Workstation__c, Contact.Name, Contact.recordType.name,
                    Contact.Email, Contact.Phone
                    from user where id = :UserInfo.getUserId()];        
    }
    
    public Case newCase{
        get{
            if (newCase == null){
                newCase = new Case();
            }            	
            newCase.RecordTypeId = getRecordType();
            return newCase;
        }               
        set;
    }
    
    public Case getNewCase() {
        return newCase;
    }
    
    protected virtual void reset() {
        RequestFormType = null;
        newCase = null;     
        headermsg = 'Select Your Form';
    }
    
    public string RequestFormType{get;set;}
    
    public string TypeParam{get; set;}
    
    public virtual void setType(){
        RequestFormType = TypeParam;
    }
    
    public string division{
        get{
            if (division==null){
                if (thisUser.size()>0){
                    if (thisUser[0].contact.Division__c!=null){
                        if ((thisUser[0].contact.Division__c).equalsIgnoreCase('EMEA - All Countries')){
                            division = 'EMEA';
                            return division;
                        }
                        if ((thisUser[0].contact.Division__c).equalsIgnoreCase('APAC - All Countries')){
                            division = 'APAC';
                            return division;                                            
                        }
                        if ((thisUser[0].contact.Division__c).equalsIgnoreCase('Japan')){
                            division = 'Japan';
                            return division;                    
                        }
                        if ((thisUser[0].contact.Division__c).equalsIgnoreCase('Americas - Canada')){
                            division = 'AmerNonHQ';
                            return division;
                        }
                        if ((thisUser[0].contact.Division__c).equalsIgnoreCase('Americas - Latin America')){
                            division = 'AmerNonHQ';
                            return division;
                        }                       
                        if ((thisUser[0].contact.Division__c).containsIgnoreCase('Americas')){
                            if (thisUser[0].contact.ES_DJC_Work_Location__c !=null){
                                if ((thisUser[0].contact.ES_DJC_Work_Location__c.containsIgnoreCase('San Francisco')) || 
                                    (thisUser[0].contact.ES_DJC_Work_Location__c.containsIgnoreCase('San Mateo'))){
                                        division = 'AmerHQ';
                                        return division;                        
                                    }else{                                                          
                                        division = 'AmerNonHQ';
                                        return division;
                                    }                                               
                            }               
                        }                                                                                       
                    }                               
                }                           
            }
            if (division==null){
                division = 'AmerHQ';
            }
            return division;
        }
        set;
    }
    
    public boolean isEmployee {
        get{
        	return ((thisUser[0].contact.recordtype.name != null) && (thisUser[0].contact.recordtype.name.equalsIgnoreCase('Employee')));
        }
        private set;
    }
    
    public User getCurrentUser() {
        return thisUser[0];
    }     
    
    protected boolean isblank(object o){
        return ((o==null)||(o==''));
    }
    
    public boolean isRemote {
        get {
            if ((thisUser.size() > 0) && (thisUser[0].contact.ES_DJC_Work_Location__c != null)) {
                return thisUser[0].contact.ES_DJC_Work_Location__c.containsIgnoreCase('remote');
            }
            return false;
        }
        private set;
    }
    
    public User currentUser {
        get {
            return thisUser[0];
        }
        private set;
    }
    
    
    public String contactName{
        get {
            if (thisUser.size() == 0 || thisUser[0].Contact == null || thisUser[0].Contact.Name == null) {
                return '';
            }
            return thisUser[0].Contact.Name;
        }
        private set;
    }
    
    public String contactCity {
        get {
            if (thisUser.size() > 0) {
                return thisUser[0].contact.ES_DJC_Work_Location__c;
            }
            return '';
        }
        private set;
    }
    
    public String contactCountry {
        get {
            if (thisUser.size() > 0) {
                return thisUser[0].contact.ES_DJC_Contact_Country__c;
            }
            return '';
        }
        private set;
    }

    public String contactEmail{
        get{
            if(thisUser.size() > 0){
                return thisUser[0].contact.Email;
            }
            return '';
        }
        private set;
    }

    public String contactPhone{
        get{
            if(thisUser.size() > 0){
                return thisUser[0].contact.Phone;
            }
            return '';
        }
        private set;
    }

    public String contactBuilding{
        get{
            if(thisUser.size() > 0){
                return thisUser[0].contact.DJC_Contact_Building__c;
            }
            return '';
        }
        private set;
    }
    
    public boolean isIndyEmployee {
        public get {
            if (isIndyEmployee == null) {
				String workLocation = currentUser.contact.ES_DJC_Work_Location__c;
                if ((workLocation != null) && (workLocation.contains('Indianapolis'))) {
                    isIndyEmployee = true;
                } else {
                    isIndyEmployee = false;
                }
            }
            return isIndyEmployee;            
        }
        private set;
    }
    
    public boolean isQuebecEmployee {
        public get {
            if (isQuebecEmployee == null) {
				String workLocation = currentUser.contact.ES_DJC_Work_Location__c;
                if ((thisUser[0].contact.Division__c!= null) &&
                    thisUser[0].contact.Division__c.equalsIgnoreCase('Americas - Canada') &&
                    (workLocation != null) && (workLocation.containsIgnoreCase('Quebec'))) {
                    isQuebecEmployee = true;
                } else {
                    isQuebecEmployee = false;
                }
            }
            return isQuebecEmployee;            
        }
        private set;
    }

    public boolean isTorontoEmployee {
        public get {
            if (isTorontoEmployee == null) {
				String workLocation = currentUser.contact.ES_DJC_Work_Location__c;
                if ((thisUser[0].contact.Division__c!= null) &&
                    thisUser[0].contact.Division__c.equalsIgnoreCase('Americas - Canada') &&
                    (workLocation != null) && (workLocation.containsIgnoreCase('Toronto'))) {
                    isTorontoEmployee = true;
                } else {
                    isTorontoEmployee = false;
                }
            }
            return isTorontoEmployee;            
        }
        private set;
    }

    public boolean inChicagoNYOrSF {
        public get {
            if (inChicagoNYOrSF == null) {
				String workLocation = currentUser.contact.ES_DJC_Work_Location__c;
                if ((workLocation != null) && (workLocation.contains('Chicago') || 
                                               workLocation.contains('New York') || 
                                               workLocation.contains('San Francisco'))) {
                    inChicagoNYOrSF = true;
                } else {
                    inChicagoNYOrSF = false;
                }
            }
            return inChicagoNYOrSF;            
        }
        private set;
    }
    
    public List<SelectOption> yesNoOptions{
        get{
            if(yesNoOptions == null){
                yesNoOptions = new List<SelectOption>();
                yesNoOptions.add(new SelectOption('true', 'Yes'));
                yesNoOptions.add(new SelectOption('false', 'No'));
            }
            return yesNoOptions;
        }
        private set;
    }
    
    public abstract String getRecordType();
    
    public void setAttachment1(blob attachment, String fileName) {
        Attach1 = attachment;
        FileName1 = fileName;
    }
    
    public void setAttachment2(blob attachment, String fileName) {
        Attach2 = attachment;
        FileName2 = fileName;
    }
    
    public void setAttachment3(blob attachment, String fileName) {
        Attach3 = attachment;
        FileName3 = fileName;
    }
    
    public void setAttachment4(blob attachment, String fileName) {
        Attach4 = attachment;
        FileName4 = fileName;
    }
    
    public void setAttachment5(blob attachment, String fileName) {
        Attach5 = attachment;
        FileName5 = fileName;
    }
    
    public void setAttachment6(blob attachment, String fileName) {
        Attach6 = attachment;
        FileName6 = fileName;
    }
    
    public void setAttachment7(blob attachment, String fileName) {
        Attach7 = attachment;
        FileName7 = fileName;
    }
    
    public void setAttachment8(blob attachment, String fileName) {
        Attach8 = attachment;
        FileName8 = fileName;
    }
    public void setAttachment9(blob attachment, String fileName) {
        Attach9 = attachment;
        FileName9 = fileName;
    }
    
    
    protected void saveCaseRecord(){
        
        Case c = newCase;
        c.id = null;
        c.setOptions(ESDJC_Util.getAssignmentRulesDMLOption(null));
        Savepoint s = Database.setSavepoint();
        Database.Saveresult sr = database.insert(c);
        if (sr.isSuccess()){
            Id caseid = sr.getId();     
            system.debug('attach1 '+Attach1);
            List<Attachment> attachmentList = new List<Attachment>(); 
            if (attach1 != null){
                Blob b = Attach1;
                Attachment attachment = new Attachment(Name =FileName1,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }
            if (attach2 != null){
                Blob b = Attach2;
                Attachment attachment = new Attachment(Name =FileName2,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }
            if (attach3 != null){
                Blob b = Attach3;
                Attachment attachment = new Attachment(Name =FileName3,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }
            if (attach4 != null){
                Blob b = Attach4;
                Attachment attachment = new Attachment(Name =FileName4,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }
            if (attach5 != null){
                Blob b = Attach5;
                Attachment attachment = new Attachment(Name =FileName5,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }
            if (attach6 != null){
                Blob b = Attach6;
                Attachment attachment = new Attachment(Name =FileName6,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }
            if (attach7 != null){
                Blob b = Attach7;
                Attachment attachment = new Attachment(Name =FileName7,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }
            if (attach8 != null){
                Blob b = Attach8;
                Attachment attachment = new Attachment(Name =FileName8,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }
            if (attach9 != null){
                Blob b = Attach9;
                Attachment attachment = new Attachment(Name =FileName9,body = b,parentId=caseid,OwnerId = UserInfo.getUserId());
                attachmentList.add(attachment);
            }            
            if (attachmentList.size() > 0){
                try {
                    insert attachmentList;
                }catch (DMLException e) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment: '+e.getmessage()));
                    Database.rollback(s);                
                    throw new ApplicationException(e.getMessage());
                }
            }                                                                                                  
        }
        else {
            String errors = '';
            for (Database.Error err : sr.getErrors()) {
                errors += err.getMessage()+'\n';
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, errors));
        }                       
    }        
}