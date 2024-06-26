public with sharing class DocuSignNetherlands  extends DocuSignBaseCountry{

  /*Method to format date
   @param date as a String
   return: formatted date
  */
  public override String getFormatedDate(String dateString){
        
    String formattedDate = DocuSignUtils.formatDateToDDMMYYYY(dateString);
    return formattedDate;        
  }
   
   /*Method to format currency
    *@param amount
    *return: formatted Currency
   */    
  public override String getFormatedCurrency(String amount){
       
    String formattedCurrency = DocuSignUtils.formatCurrencyDotSeperated(amount);
    return formattedCurrency;        
  } 
    
   /*Overriden method. This method collects all the template based on the template logic. This is called by the old SendToDocuSignController
    *@paran none
    *return: List of templateReference
   */
  public override List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates(){
              				
		           
    return templateList;
    }
  
  /**
  *Method to get template id based on the Varibale Type Pick List value
  **/   
  private String getVariableTypeTemplateId() {

    String templateId = null;
     
        
      return templateId;       
  }
  
  /**
  *Method to get commencement template id based on Continious Service Date and Employment Type
  **/
  private String getCommencementTemplateId(){
  	
  	String templateId=null;
  	

  	
  	return templateId;
  } 
  
  /**
  *Method to template id  specific to business site on offer
  **/  
  private String getLocationTemplateId(){
    	String templateId=null;


    	return templateId;
    }
    
  /**
  *Method to remaining clasue template id
  **/
  private String getRemaningClauseTemplateId(){
    	String templateId=null;
    	
    	
    	return templateId;
    }
      
}