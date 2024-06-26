public class PBLoginPOC {

    @AuraEnabled
    public static String inokeLogin(string username,string pwd){
         ApexPages.PageReference pageRef = Site.login(username, pwd,null);
        	System.debug(username+pwd);
         return pageRef.getUrl();
    }
    
    @AuraEnabled
    public static void resetPwd(string username){
        try {
            User u = [select id,isportalenabled from user where username=:username];
            if(u.IsPortalEnabled) {
                System.resetPassword(u.id,true);
            } else {
                throw new AuraHandledException('Please enter valid username');
            }
        } catch(Exception e) {
           throw new AuraHandledException(e.getMessage());
        }
       
    }
}