/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author Mike Fullmore - 4/2/2009
*/

public with sharing class ReviewFormTemplateCls {
    
    ReviewFormTemplate__c oReviewFormTemplate;
    
    boolean showError = false;
    String msgError;
    String ReviewTemplateDetailsUrl;
    
    public boolean getShowError(){
        return showError;
        }
    
    public String getMsgError(){
        return msgError;
        }
     
           
    public ReviewFormTemplateCls(ApexPages.StandardController stdController) {
            oReviewFormTemplate = (ReviewFormTemplate__c)stdController.getSubject();
            init();
        }
        
    public ReviewFormTemplateCls(ReviewFormTemplate__c rt) {
        oReviewFormTemplate = rt;
        init();
    }
    
    private void init() {}  
    
    public ReviewFormTemplate__c getReviewFormTemplate() {
        if(oReviewFormTemplate.id != null){
            oReviewFormTemplate = [SELECT Name, Introduction__c, CompetencyWeight__c, MethodWeight__c, Code__c
                FROM ReviewFormTemplate__c
                WHERE id = :oReviewFormTemplate.id
            ];              
        }
        return oReviewFormTemplate;
    }

    public void setReviewFormTemplate(ReviewFormTemplate__c r) {
        oReviewFormTemplate = r;
    }
        
 
        
    public PageReference getRedirect(String redirectUrl) {
        PageReference pageRef = new PageReference(redirectUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
}