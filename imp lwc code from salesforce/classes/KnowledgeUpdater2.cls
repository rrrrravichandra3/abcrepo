public with sharing class KnowledgeUpdater2 {
    
    public static Map<String,String> role2divisionNames = new Map<String,String>{'ES Benefits Associate Amer' =>    'Benefits - AMER',
        'ES Benefits Manager Amer' =>   'Benefits - AMER',
        'ES Benefits Associate APAC' => 'Benefits - APAC',
        'ES Benefits Manager APAC' =>   'Benefits - APAC',
        'ES Benefits Associate EMEA' => 'Benefits - EMEA',
        'ES Benefits Manager EMEA' =>   'Benefits - EMEA',
        'ES Compensation Associate' =>  'Compensation',
        'ES Compensation Manager' =>    'Compensation',
        'ES Employee Referral Associate' => 'Employee Referrals',
        'ES Employee Referral Manager' =>   'Employee Referrals',
        'ES Associate Business Partner' =>  'Employee Relations',
        'ES ER Consultants Amer' => 'Employee Relations - AMER',
        'ES ER Manager Amer' => 'Employee Relations - AMER',
        'ES Regional Manager Amer' =>   'ES - AMER',
        'ES Specialist Amer' => 'ES - AMER',
        'ES Specialist Manager Amer' => 'ES - AMER',
        'ES SVP' => 'ES - AMER',
        'ES Regional Manager APAC' =>   'ES - APAC',
        'ES Specialist APAC' => 'ES - APAC',
        'ES Specialist Manager APAC' => 'ES - APAC',
        'ES Regional Manager EMEA' =>   'ES - EMEA',
        'ES Specialist EMEA' => 'ES - EMEA',
        'ES Specialist Manager EMEA' => 'ES - EMEA',
        'ES Admin Japan' => 'ES - Japan',
        'ES Regional Manager Japan' =>  'ES - Japan',
        'ES Specialist Manager Japan' =>    'ES - Japan',
        'ES Ops Analyst' => 'ES Ops - Global',
        'ES Tech Analyst' =>    'ES Tech',
        'ES Tech Manager' =>    'ES Tech',
        'ES ESPP/401K Analyst' =>   'ESPP/401k',
        'ES ESPP/401K Manager' =>   'ESPP/401k',
        'REWS HQ Mail Services Console User' => 'AMER   Mail Services - HQ',
        'ES Mobility/Immigration Associate' =>  'Mobility/Immigration',
        'ES Mobility/Immigration Manager' =>    'Mobility/Immigration',
        'ES Global Payroll Manager' =>  'Payroll - Global',
        'ES Payroll Analyst Japan' =>   'Payroll - Japan',
        'ES Payroll Manager Japan' =>   'Payroll - Japan',
        'REWS NonHQ Real Estate Console User AMER' =>   'Real Estate - NON HQ',
        'ES Reporting Manager' =>   'Reporting',
        'ES Talent Development Manager' =>  'Talent Development',
        'ES Talent Development Specialist' =>   'Talent Development',
        'ES Work.com Analyst' =>    'work.com',
        'ES Work.com Manager' =>    'work.com',
        'REWS NonHQ Workplace Services Console User' => 'AMER   Workplace Services - AMER Non HQ',
        'REWS Regional Manager APAC' => 'Workplace Services - APAC',
        'REWS Workplace Services Console User APAC' =>  'Workplace Services - APAC',
        'REWS Regional Manager EMEA' => 'Workplace Services - EMEA',
        'REWS Workplace Services Console User EMEA' =>  'Workplace Services - EMEA',
        'REWS Leadership Role' =>   'Workplace Services - HQ',
        'REWS Admin' => 'Workplace Services - HQ',
        'REWS HQ Workplace Services Console User AMER' =>   'Workplace Services - HQ',
        'REWS Regional Manager AMER' => 'Workplace Services - HQ',
        'REWS Regional Manager Japan' =>    'Workplace Services - Japan',
        'REWS Workplace Services Console User Japan' => 'Workplace Services - Japan'
    };
    
    public static void updateArticles(){
        List<Knowledge__kav> howtos = new List<Knowledge__kav>();
        List<ID> publishIds = new List<ID>();
        Id howToRecordTypeId = [Select Id from RecordType where DeveloperName='How_To'].Id;
        
        SavePoint s = Database.setSavepoint();
        try{
            //How to English articles
            List<Knowledge__kav> hkav = [select id, KnowledgeArticleId, Article_Owner_Group__c from Knowledge__kav 
                                        where publishStatus = 'Online' and language = 'en_US' and   
                                        Article_Owner_Group__c=null and owner.UserRole.Name IN  
                                        :role2divisionNames.keySet() and Owner.profile.name != 'System Administrator' 
                                        and RecordTypeId=:howToRecordTypeId limit 30];
            
            //Unpublish the articles
            for (Knowledge__kav p : hkav){             
               try{
                	KbManagement.PublishingService.editOnlineArticle (p.KnowledgeArticleId, false);
                	publishIds.add(p.KnowledgeArticleId);
               }catch(Exception ex){
               		system.debug(ex.getMessage()+' moving on...');
               }   
            }  
            
            //Query draft articles, update them and add to a list
            List<Knowledge__kav> hkavdraft = [select id,KnowledgeArticleId,Article_Owner_Group__c,owner.UserRole.Name from Knowledge__kav 
                                            where publishStatus = 'Draft' and KnowledgeArticleid IN :publishIds and language = 'en_US' and RecordTypeId=:howToRecordTypeId];
            
            for(Knowledge__kav p : hkavdraft){
                if (role2divisionNames.containsKey(p.owner.UserRole.Name)){
                    p.Article_Owner_Group__c = role2divisionNames.get(p.owner.UserRole.Name);
                    howtos.add(p);
                }               
            }
                        
            List<Knowledge__kav> hkavdraftjp = [select id,KnowledgeArticleId,Article_Owner_Group__c,owner.UserRole.Name from Knowledge__kav 
                                                where publishStatus = 'Draft' and KnowledgeArticleid IN :publishIds and language = 'ja' and RecordTypeId=:howToRecordTypeId ];
            for(Knowledge__kav p : hkavdraftjp){
                if (role2divisionNames.containsKey(p.owner.UserRole.Name)){
                    p.Article_Owner_Group__c = role2divisionNames.get(p.owner.UserRole.Name);
                    howtos.add(p);
                }               
            }
            
            update howtos;
            
            for(id i : publishIds)  
                KbManagement.PublishingService.publishArticle(i,false);
            
            system.debug('=====Updated '+howtos.size()+' How To articles======');
            
            
        }catch(Exception ex){
            Database.rollback(s);
            throw ex;
        }                               
        
    }

}