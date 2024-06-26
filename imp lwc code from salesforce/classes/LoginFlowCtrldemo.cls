public class LoginFlowCtrldemo {
    public String randomIntegerString{get;set;}
    public String userName{get;set;}
    public String otpInputValue{get;set;}
    public void sendOtpEmail(){
        User objUser = [SELECT Id,ContactId,Email,Name FROM User WHERE Id =: Userinfo.getUserId()];
        
        randomIntegerString = string.valueof(Math.abs(Crypto.getRandomInteger()));
        System.debug('otp is '+randomIntegerString);
        list<Messaging.singleEmailMessage> mails=new list<Messaging.SingleEmailMessage>();
        userName = objUser.Name;
		

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string[] to = new string[] {objUser.ContactId};
        //string[] cc = new string[] {ccMail};
        
        //email.setToAddresses(to);
        
        email.setTargetObjectId(objUser.ContactId);
        email.setOrgWideEmailAddressId('0D24u000000sY9eCAE');
        
        email.setSubject('Otp Email for preboaring');
        email.setPlainTextBody('Hello'+UserInfo.getUsername()+'Here is your otp '+randomIntegerString);
        email.setHtmlBody('Hello'+UserInfo.getUsername()+'Here is your otp '+randomIntegerString);
        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            System.debug('result@@@@'+results);
        }catch(exception e){
            System.debug('#@#@#@#'+e);
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }        
        
    }
	
    public PageReference verify(){
        System.debug(otpInputValue+'before verify otp is '+randomIntegerString);
        if(otpInputValue == randomIntegerString){
            PageReference pg = Auth.SessionManagement.finishLoginFlow('/');
            System.debug('@@#@'+pg);
            return pg;
        }else{
            //return Auth.SessionManagement.finishLoginFlow();
            return null;
        }
    }    
    
}