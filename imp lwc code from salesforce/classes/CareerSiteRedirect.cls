global with sharing class CareerSiteRedirect implements Site.UrlRewriter {
    
    global PageReference mapRequestUrl(PageReference myFriendlyUrl){
        
        String url = myFriendlyUrl.getUrl();
        
        if ( url.contains('Servlet') ){
            return new PageReference('/' );         
        } 

        return null;
    }
    
    global PageReference[] generateUrlFor(PageReference[] CareerSiteUrls){
        List<PageReference> finalUrls = new List<PageReference>();

        for(PageReference mySalesforceUrl : CareerSiteUrls){
    
            String url = mySalesforceUrl.getUrl();
            
   
               finalUrls.add(mySalesforceUrl);
             
        }           

        return finalUrls;
    }
            
}