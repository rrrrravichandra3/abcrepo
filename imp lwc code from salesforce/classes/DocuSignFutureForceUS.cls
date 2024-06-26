public with sharing class DocuSignFutureForceUS extends DocuSignBaseCountry{

    /*Method to format date
      @param date as a String
      return: formatted date
     */
    public override String getFormatedDate(String dateString){
        
        String formattedDate = DocuSignUtils.formatDateToMMMMDDYYYY(dateString);
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



    public override List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates(){
        
        return templateList;
    }
    
}