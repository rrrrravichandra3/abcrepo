/**
*W-11822445- <Build> Single Community - Knowledge Article URL
* 
* Version      Date            Author                  Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* v1.0         01-10-2022      Ashutosh Belwal         Initial Version
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

public without sharing class MA_GenerateCommunityPageUrls {

    private static final String NETWORK_NAME = Label.MA_Generic_Community_Name;
    private static final String DEFAULT_NAVIGATION = Label.MA_Default_Navigation_Menu;
    private static final string KAV_OBJECT_NAME = 'Knowledge__kav';

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Genrates authenticated sso url for login
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    String                                  DESCRIPTION (Data type String, Current record Id)
    * @return   List<CommunityUrlWrapper>               DESCRIPTION (returns login urls of community pages)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static List<CommunityUrlWrapper> getCompanyList(String recordId){
        try {
 
            String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            Boolean isArticle = sObjName == KAV_OBJECT_NAME;

            List<CommunityUrlWrapper> lstReturn = new List<CommunityUrlWrapper>();
            Map<String,Acquisition_Company__c> ssoVsCompany = new Map<String,Acquisition_Company__c>();

            Network myNetwork = [SELECT Id FROM Network WHERE Name =: NETWORK_NAME ];
            ConnectApi.Community  communityUrl = ConnectApi.Communities.getCommunity(myNetwork.id);
            String query = Label.MA_GenerateUrl_Query;
            
            if(isArticle){
                List<String> lstStatus = Label.MA_GenerateUrl_QueryFilter.split(',');
                query += ' WHERE Status__c NOT IN: lstStatus AND SSO_Config_Name__c != null';
                for(Acquisition_Company__c objCompany : Database.query(query))
                {
                    ssoVsCompany.put(objCompany.SSO_Config_Name__c, objCompany);
                }
            }else{
                query += ' WHERE Id =: recordId LIMIT 1';
                Acquisition_Company__c objCompany = Database.query(query);
                ssoVsCompany.put(objCompany.SSO_Config_Name__c, objCompany);
            }

            Map<String, String> pageUrls = new Map<String, String>();
          
            pageUrls = isArticle ? getKnowledgeDetails(recordId) : generateCommunityMenuUrls();
            
            for(SamlSsoConfig objConfig : [SELECT DeveloperName, Id 
                                            FROM SamlSsoConfig 
                                            WHERE DeveloperName IN: ssoVsCompany.keySet()])
            {
                CommunityUrlWrapper wrapInstance =  new CommunityUrlWrapper();
                wrapInstance.acqCompanyName = ssoVsCompany.get(objConfig.DeveloperName).Name;
                for(String title : pageUrls.keySet()){
                    String url = communityUrl.siteUrl+'/s'+ (isArticle ? '/article/': '')+pageUrls.get(title)+'?sso='+objConfig.Id;
                   
                    wrapInstance.communityPageUrls.put(title, url);
                   
                }
                lstReturn.add(wrapInstance);
            }

            return lstReturn;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Rerurn knowledge article details
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    String                                  DESCRIPTION (Data type String, Current record Id)
    * @return   Map<String, String>                     DESCRIPTION (returns knowledge title vs url)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, String> getKnowledgeDetails(String recordId){

        Knowledge__kav objKav = [SELECT Title, UrlName FROM Knowledge__kav WHERE Id =: recordId LIMIT 1];
        return new Map<String, String>{objKav.Title => objKav.UrlName};

    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Returns Generic community navigation menu pages
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   Map<String, String>                     DESCRIPTION (returns Page label vs Page tit)
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private static Map<String, String> generateCommunityMenuUrls(){
        
        Map<String, String> nameVsURL = new Map<String, String>();
        List<NavigationMenuItem> navigationMenuItem = new List<NavigationMenuItem>([SELECT Label,Target, AccessRestriction, ParentId,Position,Status,TargetPrefs
                                                                                    FROM NavigationMenuItem
                                                                                    WHERE NavigationLinkSetId IN (SELECT Id FROM NavigationLinkSet WHERE Network.Name =: NETWORK_NAME AND DeveloperName LIKE: DEFAULT_NAVIGATION  )
                                                                                    ORDER BY Position]);
        for(NavigationMenuItem objItem : navigationMenuItem){
            nameVsURL.put(objItem.Label, objItem.Target);
        }
        return nameVsURL;                
    }

    
    public class CommunityUrlWrapper{
        @AuraEnabled
        public String acqCompanyName{get;set;}
        @AuraEnabled
        public Map<String, String> communityPageUrls{get{
            if(communityPageUrls == null) {
                communityPageUrls = new Map<String, String>();
            }
            return communityPageUrls;
        }set;}
        
    }
}