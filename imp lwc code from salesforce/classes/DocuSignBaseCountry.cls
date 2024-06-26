public abstract with sharing class DocuSignBaseCountry {
	
	
	protected List<esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue> dataValueList = new List<esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue>();	
	protected List<esdsext.DocuSignAPI.TemplateReference> templateList = new List<esdsext.DocuSignAPI.TemplateReference>();

    /** 
     * If exists, returns the override value of the given Business Site value.
     * Otherwise, it will simply return the value provided.
	 */
	public static String getBusinessSiteValue(String originalValue) {
    	//By default, we return the original value.
        String returnValue = originalValue;
        
        //Check in custom settings if there is an override value.
        Business_Site_Overrides__c overrideValue;
        overrideValue = Business_Site_Overrides__c.getInstance(originalValue);
        if (overrideValue != null) {
            if (String.isEmpty(overrideValue.Override_Value__c) == false) {
                //Only if the override value exists, then it is returned.
                returnValue = overrideValue.Override_Value__c;
            }
        }
        return returnValue;
    }
  
  /*Method to to setup a template given the templateId. It also fills the tag with data values.If the template use a tag in the list that tag value is reflected in the template.     
   *When I wrote this only God and I understood what I was doing. Now only God does. 
   @paran templateId: templateId of the template 
   *return: TemplateRefernce
   */  
  public esdsext.DocuSignAPI.TemplateReference setUpTemplate(String templateId){
        esdsext.DocuSignAPI.TemplateReference ndaTemplate = new esdsext.DocuSignAPI.TemplateReference();
        ndaTemplate.Template = templateId;
        ndaTemplate.TemplateLocation = 'Server';
        
        esdsext.DocuSignAPI.TemplateReferenceRoleAssignment candiddteRoleAssignment = new esdsext.DocuSignAPI.TemplateReferenceRoleAssignment();

        esdsext.DocuSignAPI.TemplateReferenceRoleAssignment recruiterRoleAssignment = new esdsext.DocuSignAPI.TemplateReferenceRoleAssignment();


        esdsext.DocuSignAPI.TemplateReferenceRoleAssignment essRoleAssignment = new esdsext.DocuSignAPI.TemplateReferenceRoleAssignment();

        
        ndaTemplate.RoleAssignments = new esdsext.DocuSignAPI.ArrayOfTemplateReferenceRoleAssignment();
        ndaTemplate.RoleAssignments.RoleAssignment = new esdsext.DocuSignAPI.TemplateReferenceRoleAssignment[3];
        ndaTemplate.RoleAssignments.RoleAssignment[0] = candiddteRoleAssignment;
        ndaTemplate.RoleAssignments.RoleAssignment[1] = recruiterRoleAssignment;
        ndaTemplate.RoleAssignments.RoleAssignment[2] = essRoleAssignment;
        ndaTemplate.FieldData = new esdsext.DocuSignAPI.TemplateReferenceFieldData();
        ndaTemplate.FieldData.DataValues = new esdsext.DocuSignAPI.ArrayOfTemplateReferenceFieldDataDataValue();
       
        ndaTemplate.FieldData.DataValues.DataValue = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue[dataValueList.size()];       
        
        for(Integer i=0;i<dataValueList.size();i++){

            ndaTemplate.FieldData.DataValues.DataValue[i] = dataValueList.get(i);
        }
        return ndaTemplate;
   
  }    
    
  /*Method to return the recipient to which the template must go to. 
  *@param email: email of recipient
   @param firstName: first name of the recipient 
   @param lastName: last name of the recipient
  *return Recipient object
  */
  public esdsext.DocuSignAPI.Recipient getRecipient( String email, String firstName, String lastName,String roleType) {
        
        esdsext.DocuSignAPI.Recipient recipient = new esdsext.DocuSignAPI.Recipient();        
        recipient.ID = roleType=='Candidate'? 2:1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = roleType=='Candidate'? 2:1;
        recipient.Email = email;
        recipient.UserName = firstName + ' ' + lastName;
        recipient.RoleName = 'Signer';
        recipient.RequireIDLookup = false;      
        recipient.RoleName = roleType=='Candidate'? 'Docusign Candidate':'Docusign Recruiter';
        
        return recipient;
  }
		
	/*method create tags used in the templates and add them to the dataValueList
  *@param: typeStr: Is either Date of Currency
  @param: tagName: name of the tag to be used 
  @param: objectValue: value of date or currency
  *return void
  */
	public void addDataValueList(String typeStr, String tagName, Object objectValue){
		
		if(objectValue==null){
			return;
		}
		String valueString=objectValue+'';
		esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue dataValue = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue();
        dataValue.TabLabel = tagName;
        dataValue.Value = '';
        if(typeStr.contains('Date')){
        	dataValue.Value=getFormatedDate(valueString);
        }else if(typeStr.contains('Currency')) {
        	dataValue.Value=getFormatedCurrency(valueString);
        }else {
        	return;
        }
        
        dataValueList.add(dataValue);
         
	}
  
  /*method create tags used in the templates and add them to the dataValueList
  *@param: typeStr: Is either Date of Currency
  @param: tagName: name of the tag to be used 
  @param: objectValue: value of date or currency
  *return void
  */
  public void addRSUOptionToList(String tagName, Object objectValue){
    
    if(objectValue==null){
      return;
    }
    String valueString=objectValue+'';
    esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue dataValue = new esdsext.DocuSignAPI.TemplateReferenceFieldDataDataValue();
    dataValue.TabLabel = tagName;
    dataValue.Value = '';        
    dataValue.Value=DocusignUtils.formatCurrencyCommaSeperated(valueString);        
    dataValueList.add(dataValue);
         
  }	

	
	/**
  *Method sets up template given the templateId. It calls the setupTemplate method to setup the template.
  *@param templateId
  *return void 
  **/  
  protected void addTemplate(String templateId){
    if(templateId==null){
      return;
    }
    esdsext.DocuSignAPI.TemplateReference template = setUpTemplate(templateId);
        
    if(template != null){
        templateList.add(template);
    }
  }
  
  /*Override this method in the child class with the required currency format. Use the methods in DocuSign Utils for formatting
   *@paran amount
   *return: formatted curency
   */  
  public abstract String getFormatedCurrency(String ammount);
  
  /*Override this method in the child class with the required date format. Use the methods in DocuSign Utils for formatting
   *@paran date
   *return: formatted date
   */   
  public abstract String getFormatedDate(String dateString);
  
  /* Override this method in the child class. Look at the docusign Logic and add templates based on the logic
   *
   */
  public abstract List<esdsext.DocuSignAPI.TemplateReference> collectAllTemplates();

	
}