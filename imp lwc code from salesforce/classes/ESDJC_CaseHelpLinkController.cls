//Case extention controller class for the  CaseHelpLinks.page
public with sharing class ESDJC_CaseHelpLinkController {
    private Case aCase;
    //public List<ESDJC_CaseHelpLinkInfo> links {get; set;}
    public List<ESDJC_CaseArticleInfo> linkedCaseArticles {get; set;}
    
    public ESDJC_CaseHelpLinkController(ApexPages.StandardController stdController) {
        aCase = (Case) stdController.getRecord();
        aCase = [SELECT ContactId FROM Case WHERE Id = :aCase.Id];
        /*Contact aContact;
        if(aCase != null && aCase.ContactId != null) {
            aContact = [SELECT Division__c FROM Contact WHERE id= :aCase.ContactId];
        }
        links = new List<ESDJC_CaseHelpLinkInfo>();

        String region = '';
        if(aContact != null && aContact.Division__c != null){
            region = getRegion(aContact.Division__c);
        }
        List<Case_Help_Link__c> linkRecords = [SELECT name, URL__c FROM Case_Help_Link__c WHERE Region__c = 'global' or Region__c = :region ORDER BY name];
        if(linkRecords != null && linkRecords.size() > 0){
            ESDJC_CaseHelpLinkInfo row;
            Case_Help_Link__c link;
            for(Integer i=0;i<linkRecords.size();i=i+3){
                row = new ESDJC_CaseHelpLinkInfo();
                link = linkRecords.get(i);
                row.addRow(new ESDJC_CaseHelpLinkInfo(link.name, link.URL__c));
                
                if(i+1 < linkRecords.size()) {
                    link = linkRecords.get(i+1);
                    row.addRow(new ESDJC_CaseHelpLinkInfo(link.name, link.URL__c));
                }

                if(i+2 < linkRecords.size()) {
                    link = linkRecords.get(i+2);
                    row.addRow(new ESDJC_CaseHelpLinkInfo(link.name, link.URL__c));
                }
                
                links.add(row);
            }
        }*/
        populateLinkedArticles(aCase);
    }   
    
    private void populateLinkedArticles(Case aCase) {
        linkedCaseArticles = new List<ESDJC_CaseArticleInfo>();
        ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        
        if(aCase != null && aCase.id != null){
            List<CaseArticle> caseArticles = [SELECT CaseId,KnowledgeArticleId FROM CaseArticle WHERE CaseId=:aCase.Id];
            Map<String, CaseArticle> caseArticleMap = new Map<String, CaseArticle>();
            for(CaseArticle ca : caseArticles){
                caseArticleMap.put(ca.KnowledgeArticleId, ca);
            }
            Id howToRecordTypeId = [Select Id from RecordType where DeveloperName='How_To'].Id;
            List<Knowledge__kav> howTos = [SELECT Id,Title,UrlName,KnowledgeArticleId  FROM Knowledge__kav WHERE PublishStatus ='online' and KnowledgeArticleId IN :caseArticleMap.keySet() and RecordTypeId=:howToRecordTypeId];
            
            for(Knowledge__kav kav : howTos){
                linkedCaseArticles.add(new ESDJC_CaseArticleInfo(kav.Title, settings.SSO_URL__c+'/apex/ESDJC_Communities?id='+kav.KnowledgeArticleId ));
            }
        }
    }   
}