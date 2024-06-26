public with sharing class MyReferralsCtrl {
    //This class is for the My Referral page

    public boolean displayPopup {get; set;}
    
    public  Integer MAX_ROWS = 100;
    public  Integer DEFAULT_SPAN = 1; //years
    private List<ReferralInfo> referrals = new List<ReferralInfo>();
    public User currentUser{get;set;}
   
    public EmailObject emailObject;
    TF2_Location_Currency_Mapping__c proxy = new TF2_Location_Currency_Mapping__c();
    public TF2_Location_Currency_Mapping__c  getProxyObject() { return proxy; }
    private TF2Settings__c configurations;
    public DateTime oldStartTime {get;set;}
    public DateTime oldEndTime {get;set;}
    public boolean isEvenRow{get;set{isEvenRow=!isEvenRow;}}
    String messageBegin = 'Go to this web URL';
    
    public EmailObject getEmailObject() {
        if (emailObject == null) { 
            emailObject = new EmailObject(); 
        }
        Integer messageBeginIdx = 0;
        if(emailObject.body != null){
        	messageBeginIdx = emailObject.body.indexOf(messageBegin);
        }
	    if(emailObject.body != null && emailObject.body.length()>1 && messageBeginIdx != 0){
	        emailObject.body = emailObject.body.substring(messageBeginIdx,emailObject.body.length());
	    }
      	return emailObject;
    }
 
    public void closePopup() {
        displayPopup = false;
    }
 
    public void showPopup() {
        displayPopup = true;
    }
    

    public MyReferralsCtrl() {
        configurations = TF2Settings__c.getInstance();      
        if(proxy.Start_Date__c== null){
            proxy.Start_Date__c= Date.today().addYears(-1*DEFAULT_SPAN);
            if(proxy.Start_Date__c < configurations.My_Referrals_Start_Date__c){
                proxy.Start_Date__c = configurations.My_Referrals_Start_Date__c;
            }
        }
        if(proxy.End_Date__c == null){
            proxy.End_Date__c = Date.today();
        }
        
        String userName = UserInfo.getUserName();
        List<User> users = [Select Email, firstName, lastName From User where UserName = :userName];
        if(users != null && users.size() == 1){
            currentUser = users[0];
        }
        
        doSearch();
    }
    
    public List<ReferralInfo> getMyReferrals() {
        return referrals;
    }
    
    public void doSearch() {
        DateTime startTime = DateTime.now().addYears(-1*DEFAULT_SPAN);
        String msg = '';
        if(proxy.Start_Date__c!= null){     
            if(proxy.Start_Date__c < configurations.My_Referrals_Start_Date__c){
                msg = 'Start date must be on or after '+configurations.My_Referrals_Start_Date__c.format();
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, msg));
                return;
            }
            startTime = DateTime.newInstance(proxy.Start_Date__c.year(), proxy.Start_Date__c.month(), proxy.Start_Date__c.day(), 0,0,0);
        }
        DateTime endTime = DateTime.now();
        if(proxy.End_Date__c != null){
            endTime = DateTime.newInstance(proxy.End_Date__c.year(), proxy.End_Date__c.month(), proxy.End_Date__c.day(), 23,59, 59);
        }
        
        if(endTime < startTime){
                msg = 'End date must be after the start date';
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, msg));
                return;
        }

        referrals = Utils.getMyReferrals(currentUser.Email, startTime, endTime, MAX_ROWS);
        msg = 'No referrals found!';
        if(referrals != null && referrals.size() > 0){
            Integer size = referrals.size();
            if(size == 1){
                msg = 'Showing one referral';
            } else if(size < MAX_ROWS){
                msg = 'Showing '+size+ ' referrals on this page';
            } else {
                msg = 'Showing first'+MAX_ROWS+ ' referrals. Please narrow down your search with start and end dates';
            }
        }
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, msg));
    }
    
    public String getHeader() {
        return configurations.Referral_Status_Header_URL__c;
    }
    public String getFooter() {
        return configurations.Referral_Status_Footer_URL__c;
    }

	public Boolean getHeaderFlag(){
		if ( configurations.Referral_Status_Header_URL__c != null )
			return true;
		else
			return false;
	}
	
	public Boolean getFooterFlag(){
		if ( configurations.Referral_Status_Footer_URL__c != null )
			return true;
		else
			return false;	
	}

    public void sendEmail() {
        closePopup();
        try {
            Messaging.reserveSingleEmailCapacity(2);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {emailObject.toAddress}; 
            String[] ccAddresses = new String[] {currentUser.Email};
            
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setReplyTo(currentUser.Email);
            mail.setSenderDisplayName(currentUser.firstName + ' ' +currentUser.LastName);
            mail.setSubject(emailObject.subject);
            mail.setUseSignature(false);
            mail.setPlainTextBody(emailObject.body);    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
}