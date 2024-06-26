public with sharing class Talent_Spa_Controller {    


        @AuraEnabled(cacheable=true)
        public static List<PageConfig> getPagesConfig() {
    
            PageConfig growApp = new PageConfig();
            growApp.name = 'GrowthApp';
            growApp.isActive = true;
            growApp.isLandingPage = true;
            growApp.menuOrder = 1;
            growApp.pageId = 'growApp';
    
            PageConfig careerPath = new PageConfig();
            careerPath.name = 'CareerPath';
            careerPath.isActive = true;
            careerPath.isLandingPage = false;
            careerPath.menuOrder = 2;
            careerPath.pageId = 'careerPath';
    
            PageConfig jobsSearch = new PageConfig();
            jobsSearch.name = 'JobsSearch';
            jobsSearch.isActive = true;
            jobsSearch.isLandingPage = false;
            jobsSearch.menuOrder = 2;
            jobsSearch.pageId = 'jobsSearch';

    
            return new List<PageConfig>{ growApp, careerPath,jobsSearch};
        }
    
        public class PageConfig {
            @AuraEnabled
            public String name;
            @AuraEnabled
            public Boolean isActive = false;
            @AuraEnabled
            public Boolean isLandingPage = false;
            @AuraEnabled
            public Integer menuOrder = 1;
            @AuraEnabled
            public String pageId;
        }
    
    
}