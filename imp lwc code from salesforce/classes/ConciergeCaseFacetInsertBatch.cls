public class ConciergeCaseFacetInsertBatch implements Database.Batchable<sObject>,Database.Stateful {
    public Datetime lowerDateCutoff;
    public Datetime upperDateCutoff;
    public list<string> bodyLines = new list<string>() ;
    public string subject='';
    public String csvContent ='';
    
    public ConciergeCaseFacetInsertBatch(Datetime lowerDateCutoff,Datetime upperDateCutoff){
        this.lowerDateCutoff= lowerDateCutoff;
        this.upperDateCutoff = upperDateCutoff;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id, (select id from concierge_case_facets__r) from case 
                                         where createdDate > :lowerDateCutoff and createdDate <= :upperDateCutoff 
                                         order by createdDate DESC
                                         ]);   			
    }
    public void execute(Database.BatchableContext BC, List<case> scope){
        List<Concierge_Case_Facet__c> ConciergeFacetList = new List<Concierge_Case_Facet__c>();
        for(Case c: scope){
            Concierge_Case_Facet__c facet = new Concierge_Case_Facet__c();
            if( c.concierge_case_facets__r == null || c.concierge_case_facets__r.size() == 0){
                facet.case__c = c.id;
                facet.name = 'Concierge Actions';
                ConciergeFacetList.add(facet);
            }
        }
        try{
            insert ConciergeFacetList;                  
        }catch(Exception ex){
            bodyLines.add('Batch failed with exception '+String.valueof(ex)+'\n');  		        	
            bodylines.add('Please find the attachment for the concierge facets in scope.\n'); 
            csvContent = string.join(new list<Concierge_Case_Facet__c>(ConciergeFacetList),',\n');   
            
        }
    }
    public void finish(Database.BatchableContext BC){
        ESDJC_Settings__c settings = ESDJC_Settings__c.getInstance();
        subject   = 'ConciergeCaseFacetInsertBatch';      	
        if(bodyLines.size()==0){//No Exceptions have occured.
            bodylines.add('ConciergeCaseFacetInsertBatch successful');
        }      
        sendStatusEmail(BC, subject, settings.DJC_Batchjob_Support_Email__c.split(','), bodyLines,csvContent);		
    }
    public String sendStatusEmail(Database.BatchableContext BC, String subject, String[] toAddresses, String[] bodyLines,String csvContent) {
        
        if(toAddresses == null || toAddresses.size() == 0 || toAddresses[0] == null || toAddresses[0] == ''){	
            return '';	
        }	
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, TotalJobItems, CreatedBy.Email  FROM AsyncApexJob WHERE Id =:BC.getJobId()];	
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();	
        mail.setToAddresses(toAddresses);		
        //Enable custom exception failure subject from  classes invoking the method.As typically handled exceptions give status as -Complete-
        if(subject.tolowercase().contains('fail')){
            mail.setSubject(subject);			
        }
        else{
            mail.setSubject(subject+ ' - '+a.Status);							
        }
        String body = '';	
        for(String line : bodyLines){	
            body += line + '\n';	
        }	
        mail.setPlainTextBody (body);
        if(!String.isBlank(csvContent)){
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            csvAttachment.setBody(Blob.valueOf(csvContent));
            csvAttachment.setFileName('conciergeFacetRecs.csv');		
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});		        	
        }			
        
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
        
        return mail.getPlainTextBody();
    }
}