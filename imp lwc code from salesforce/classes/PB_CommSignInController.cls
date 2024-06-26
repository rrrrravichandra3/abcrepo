public without sharing class PB_CommSignInController {
    
    static final string LOGIN_FLOW_REGISTER = 'REGISTER';
    static final string LOGIN_FLOW_SIGNIN = 'SIGNIN';
    static final String NO_COMMUNITY_ACCESS = 'Uh-oh! You do not have access to the Community. Please contact Support for help.';
    static final String INVALID_EMAIL_FORMAT = 'Invalid Email Format';
    static final String INVALID_VERIFICATION_CODE = 'Invalid verification code';
    static final String NO_CONTACT_EXISTS = 'No Contact exists. Pleae use the same email where you received the invitaion.';
    
    
    /*******************************************************************************************************
* @description Checks for Contact/User with the Email provided by the user and
* sends varification code to the email associated
* @param userEmail : the email input from the user to login
* @return Response Wrapper
* @example
* NHW_Community_SignInController.ResponseWrapper responseWrapper = NHW_Community_SignInController.signInUser('test@test.com');
*/
    @AuraEnabled
    public static PB_CommSignInController.ResponseWrapper signInUser(string userEmail) {
        List<User> communityUser = new List<User>();
        PB_CommSignInController.ResponseWrapper resWrap = new PB_CommSignInController.ResponseWrapper();
        try {
            //validate user email format
            if (!validateEmail(userEmail)) {
                //If the email address format is incorrect
                resWrap.errorMessage = INVALID_EMAIL_FORMAT;
                return resWrap;
            }
            // Query associated WD Candidate contact with same email
            List<Contact> userContactsWithEmail = PB_CommSignInService.getContacts(userEmail);
            
            //Query if those contacts pass any further custom eligibility checks (job-app in placement)
            List<Contact> eligibleContacts = PB_CommSignInService.getEligibleContacts(userContactsWithEmail);
            
            communityUser = PB_CommSignInService.getUser(userEmail);
            
            //If there is no WD Candidate Contact associated with the email, do not allow the users to login
            if (userContactsWithEmail.size() == 0) {
                resWrap.errorMessage = NO_CONTACT_EXISTS;
                resWrap.attemptId = null;
            } else if(eligibleContacts.size()==0) {   //If there is no Contact in eligible stages
                resWrap.errorMessage = NO_COMMUNITY_ACCESS;
                resWrap.attemptId = null;
            } else if(eligibleContacts.size()!=0){
                // If there is a contact existing with the email address
                // If there is no existing user with same email, create user and send verification code to Login
                if (communityUser.size() == 0) {
                    User newuser = PB_CommSignInService.createUser(userEmail, eligibleContacts[0]);
                    resWrap.loginFlowType = LOGIN_FLOW_REGISTER;
                    resWrap.attemptId =  (!test.isRunningTest()) ? System.UserManagement.initSelfRegistration(Auth.VerificationMethod.EMAIL, newuser) : null;
                    
                } else {
                    //If there is  already an existing user with same email address, send verification code to login
                    resWrap.loginFlowType = LOGIN_FLOW_SIGNIN;
                    resWrap.attemptId = (!test.isRunningTest()) ? System.UserManagement.initPasswordlessLogin(communityUser[0].Id,Auth.VerificationMethod.EMAIL) : null;
                    resWrap.userId = communityUser[0].Id;
                }
            }
        } catch (Exception exp) {
            System.debug('signInUser Exception' + exp);
            resWrap.errorMessage = 'Internal Server Error';
            resWrap.attemptId = null;
        }
        return resWrap;
    }
    
    /*******************************************************************************************************
* @description verifies the verification code provided by the user and
* logins the user to community
* @param responseObject : the email input from the user to login
* @param Response Wrapper : return type from userSignin method
* @return Verify Wrapper
*
* @example
* PB_CommSignInController.VerifyWrapper verifyWrapper = PB_CommSignInController.verifyUser(responsewrapper,'12345');
*/
    @AuraEnabled
    public static PB_CommSignInController.VerifyWrapper verifyUser(ResponseWrapper responseObject, String userInput, String userEmail) {
        Auth.VerificationResult res;
        PB_CommSignInController.VerifyWrapper verifyWrapper = new PB_CommSignInController.VerifyWrapper();
        try {
            if (!validateVerificationCode(userInput)) {
                //Error Message for invalid verication code format
                verifyWrapper.message = INVALID_VERIFICATION_CODE;
                verifyWrapper.success = false;
                return verifyWrapper;
            }
            // for verifing user self registration
            if (responseObject.loginFlowType == LOGIN_FLOW_REGISTER) {
                if (!test.isRunningTest()) {
                    res = System.UserManagement.verifySelfRegistration(Auth.VerificationMethod.EMAIL,responseObject.attemptId,userInput,null
                    );  
                }
                System.debug('LOGIN_FLOW_REGISTER response++++' + res);
                //for verifying user signing in
            } else if ((responseObject.loginFlowType == LOGIN_FLOW_SIGNIN)) {
                String userId = responseObject.userId;
                if (!test.isRunningTest()) {
                    res = System.UserManagement.verifyPasswordlessLogin(userId,Auth.VerificationMethod.EMAIL,responseObject.attemptId,userInput,null);
                }
                System.debug('LOGIN_FLOW_SIGNIN response--++++' + res);
            }
            //set verifywrapper for testing
            if (test.isRunningTest()) {
                verifyWrapper.message = 'test';
                verifyWrapper.success = true;
            } else {
                //set verifywrapper
                if(res.success){
                    verifyWrapper.message = res.message;
                    verifyWrapper.success = res.success;
                }
                else{
                    verifyWrapper.message = 'Incorrect Verification Code. Please Try Again';
                    verifyWrapper.success = false;
                }        
            }
        }catch (Exception exp) {
            verifyWrapper.message = 'Internal Server Error';
            verifyWrapper.success = false;
        }
        return verifyWrapper;
    }
    
    
    /*******************************************************************************************************
* @description checks for valid email input from the user
* @param userEmail : the email input from the user to login
* @return Boolean  validating email format
* @example Boolean bool = IA_Util.validateEmail('test@test.com');
*/
    public static boolean validateEmail(String userEmail) {
        if (userEmail != null) {
            String emailRegex = '([a-zA-Z0-9+_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern emailPattern = Pattern.compile(emailRegex);
            Matcher emailMatcher = emailPattern.matcher(userEmail);
            return emailMatcher.matches();
        } else {
            return false;
        }
    }
    
    public class ResponseWrapper {
        @AuraEnabled
        public String loginFlowType { get; set; }
        @AuraEnabled
        public String attemptId { get; set; }
        @AuraEnabled
        public Id userId { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }
    }
    
    public class VerifyWrapper {
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public boolean success { get; set; }
    }
    
    public static boolean validateVerificationCode(String verificationCode) {
        if (verificationCode != null) {
            String fiveDigitNumberRegex = '\\b\\d{5,6}\\b';
            Pattern digitPattern = Pattern.compile(fiveDigitNumberRegex);
            Matcher digitMatcher = digitPattern.matcher(verificationCode);
            return digitMatcher.matches();
        } else {
            return false;
        }
    }
}