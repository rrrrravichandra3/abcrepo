global with sharing class FormSiteRedirect implements Site.UrlRewriter {

    public static final PageReference formDefaul = new PageReference( '/Unauthorized' );
    
    global PageReference mapRequestUrl(PageReference myFriendlyUrl){
        
        String url = myFriendlyUrl.getUrl();
        
        if ( url.contains('Servlet') ){
            return new PageReference( '/Unauthorized' );            
        }

        return null;
    }
    
    global PageReference[] generateUrlFor(PageReference[] CareerSiteUrls){
        List<PageReference> finalUrls = new List<PageReference>();

        for(PageReference mySalesforceUrl : CareerSiteUrls){
    
            String url = mySalesforceUrl.getUrl();
            
            if( url.contains('Servlet') ){
                finalUrls.add( formDefaul );
            } else {    
               finalUrls.add(mySalesforceUrl);
             }
        }           

        return finalUrls;
    }
    
}