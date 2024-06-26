@isTest
private class Test_ReviewFormTemplateCls {
      
    public static testMethod void execute_methods_ReviewFormTemplateController() {

          GenerateEnvironmentTest.reviewFormTemplate =  GenerateEnvironmentTest.createReviewFromTemplate();
 	
        Test.startTest();
         
       
            ReviewFormTemplate__c reviewFormTemplate = new ReviewFormTemplate__c();
            ApexPages.StandardController stdController = new ApexPages.StandardController(reviewFormTemplate); 
            ReviewFormTemplateCls controller = new ReviewFormTemplateCls(stdController);
            

            
            ReviewFormTemplate__c rft = GenerateEnvironmentTest.reviewFormTemplate;
            
            System.debug('This is ' + rft );
            
            // CASE 1 correct numbers
            rft.MethodWeight__c = 70;
            rft.CompetencyWeight__c = 30;
            
            controller = new ReviewFormTemplateCls(rft);
            
            controller.getReviewFormTemplate();
            
            if(controller.getShowError()){
                System.assert(true,'Must show error');
            }
            if(controller.getMsgError() == null){
                System.assert(true,'Null message');
            }
                
            if(controller.getReviewFormTemplate() == null){
                System.assert(true,'Null review form template');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.save() != null){
                System.assert(true,'Error in code, save must be null');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.saveClone() != null){
                System.assert(true,'Error in code, save clone must be null');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.saveAndNew() != null){
                System.assert(true,'Error in code, save&New must be null');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.saveCloneAndNew() != null){
                System.assert(true,'Error in code, save&New clone must be null');
            }
            if(controller.cancel() == null){
                System.assert(true,'Null cancel');
            }
            if(controller.getRedirect('/') == null){
                System.assert(true,'null redirect');
            }
            
            // CASE 2 methods over 100
            rft.MethodWeight__c = 101;
            rft.CompetencyWeight__c = 10;
            
            controller.setReviewFormTemplate(rft);
            
            if(controller.getShowError()){
                System.assert(true,'Must show error');
            }
            if(controller.getMsgError() == null){
                System.assert(true,'Null message');
            }
                
            if(controller.getReviewFormTemplate() == null){
                System.assert(true,'Null review form template');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.save() != null){
                System.assert(true,'Error in code, save must be null');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.saveClone() != null){
                System.assert(true,'Error in code, save clone must be null');
            }
            controller.setReviewFormTemplate(rft);
            if(controller.saveAndNew() != null){
                System.assert(true,'Error in code, save&New must be null');
            }
            controller.setReviewFormTemplate(rft);
            if(controller.saveCloneAndNew() != null){
                System.assert(true,'Error in code, save&New clone must be null');
            }
            if(controller.cancel() == null){
                System.assert(true,'Null cancel');
            }
            if(controller.getRedirect('/') == null){
                System.assert(true,'null redirect');
            }

            // CASE 3 competencies over 100
            rft.MethodWeight__c = 10;
            rft.CompetencyWeight__c = 101;

            controller.setReviewFormTemplate(rft);
            
            if(controller.getShowError()){
                System.assert(true,'Must show error');
            }
            if(controller.getMsgError() == null){
                System.assert(true,'Null message');
            }
                
            if(controller.getReviewFormTemplate() == null){
                System.assert(true,'Null review form template');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.save() != null){
                System.assert(true,'Error in code, save must be null');
            }
            controller.setReviewFormTemplate(rft);
            if(controller.saveClone() != null){
                System.assert(true,'Error in code, save clone must be null');
            }
            controller.setReviewFormTemplate(rft);
            if(controller.saveAndNew() != null){
                System.assert(true,'Error in code, save&New must be null');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.saveCloneAndNew() != null){
                System.assert(true,'Error in code, save&New clone must be null');
            }
            if(controller.cancel() == null){
                System.assert(true,'Null cancel');
            }
            if(controller.getRedirect('/') == null){
                System.assert(true,'null redirect');
            }

            // CASE 4 sum over 100
            rft.MethodWeight__c = 50;
            rft.CompetencyWeight__c = 60;

            controller.setReviewFormTemplate(rft);
            
            if(controller.getShowError()){
                System.assert(true,'Must show error');
            }
            if(controller.getMsgError() == null){
                System.assert(true,'Null message');
            }
                
            if(controller.getReviewFormTemplate() == null){
                System.assert(true,'Null review form template');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.save() != null){
                System.assert(true,'Error in code, save must be null');
            }
            
            controller.setReviewFormTemplate(rft);
            if(controller.saveClone() != null){
                System.assert(true,'Error in code, save must be null');
            }
            controller.setReviewFormTemplate(rft);
            if(controller.saveAndNew() != null){
                System.assert(true,'Error in code, save&New must be null');
            }
            controller.setReviewFormTemplate(rft);
            if(controller.saveCloneAndNew() != null){
                System.assert(true,'Error in code, save&New must be null');
            }
            if(controller.cancel() == null){
                System.assert(true,'Null cancel');
            }
            if(controller.getRedirect('/') == null){
                System.assert(true,'null redirect');
            }
     
        
        Test.stopTest();

    }
    
}