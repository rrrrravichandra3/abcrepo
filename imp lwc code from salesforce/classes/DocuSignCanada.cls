public with sharing class DocuSignCanada extends DocuSignBaseCountry{
    
        private String salesJobCommaSeperated = TF2Settings__c.getInstance().Docusign_Canada_Sales_Job_Catagory__c;
        
        private Set<String> jobCategorySet = new Set<String>();
    
    /*Method to format date
      @param date as a String
      return: formatted date
     */
    public override String getFormatedDate(String dateString){
        
        String formattedDate = DocuSignUtils.formatDateToDDMMMMYYYY(dateString);
        return formattedDate;
        
    }
        
        /*Method to format currency
     *@param amount
     *return: formatted Currency
     */ 
    public override String getFormatedCurrency(String ammount){
       
       String formattedCurrency = DocuSignUtils.formatCurrencyCommaSeperated(ammount);
       return formattedCurrency;
        
    }
    
    /*Overriden method. This method collects all the template based on the template logic. This is called by the old SendToDocuSignController
    *@paran none
    *return: List of templateReference
   */
  public override List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates(){
    String templateId=null;
    
           
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
  *Method to get reports to salesManager template
  **/
    private String getReportsToSalesManagerTemplate(){

      if(salesJobCommaSeperated==null){
        return null;
      }
      String templateId=null;
        


      return templateId;
    }

  // return true/false depends on the grade level
  private Boolean isGradeEQ11or12( Integer gradeLevel ){

    Boolean gradeflag = false;

    if ( gradeLevel == 11 || gradeLevel == 12 )
      gradeflag = true;
    else
      gradeflag = false;

    return gradeflag;
  }    

  private Boolean isGradeNEQ11or12 ( Integer gradeLevel ){

    Boolean gradeflag = false;

    if ( gradeLevel < 11 )
      gradeflag = true;
    else
      gradeflag = false;

    return gradeflag;

  }
 
   /**
  *Method to get remaining clause template id
  **/
  private String getRemaningClauseTemplateId(){

    String templateId=null;



    return templateId;
  }
    
  
}