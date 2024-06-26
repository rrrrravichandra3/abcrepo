@isTest(SeeAllData=true)
public with sharing class Test_ESDJC_Unauthorized {
    static testMethod void testLoginRedirect() {      
        ESDJC_UnauthorizedErrorController LoginRedirect_ES = new ESDJC_UnauthorizedErrorController();
        LoginRedirect_ES.redirectLoginPage();
    }
  }