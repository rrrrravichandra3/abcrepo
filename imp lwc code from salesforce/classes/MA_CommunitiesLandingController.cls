/**
* This page controller is replica of CommunitiesLandingController modified to redirect to welcome mat page for MA Communities.
*/
public with sharing class MA_CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        Id CurrentCommunityId = Network.getNetworkId();
        
        String WelcomeMatURL = Network.getLoginURL(CurrentCommunityId).replaceFirst('/login','/s/welcomemat');
        return new pagereference(WelcomeMatURL);
        
    }
    
    public MA_CommunitiesLandingController() {}
    
    
}