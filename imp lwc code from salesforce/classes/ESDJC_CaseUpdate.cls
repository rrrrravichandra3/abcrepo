public with sharing class ESDJC_CaseUpdate
{
   private final List<Case> cases;
   public boolean isErrorOccured{get;set;} 
   public String filterId{
        get{
            return filterId;
        }
        set;
   }
           
   public ESDJC_CaseUpdate(ApexPages.StandardSetController standardController)
   {
      
     this.cases = [select Id,ES_DJC_Topic__c,RecordType.Name,ES_DJC_Sub_Topic__c,Type from case where id in : standardController.getSelected()];
     this.filterId = standardController.getFilterId();
    
   }
   
    public PageReference validateOnLoad(){
    
         if(cases == null || cases.size() == 0 ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one record.'));
            isErrorOccured = true;
            
            return null;
        }
        
       
      return null;  
   }
  
  
   }