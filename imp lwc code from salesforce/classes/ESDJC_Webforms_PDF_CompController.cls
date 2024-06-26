/** This Class is used to generate HTML content based of component input attributes
   	Retrieves fieldsetmember details based on input fieldset
	Queries relevant rec based on given recordid and objectname **/

public class ESDJC_Webforms_PDF_CompController {
    public string compFieldSetName{get;set;}
    public string compObjectName{get;set;}
    public string compRecordId{get;set;}
    public list<sobject> compSobjectList{get;set;}
    
    public list<sobject> sobjectList{get;set;}
    public list<string> fieldNames{get;set;}
    public list<schema.FieldSetMember> FSMList{set;}
    public sobject sobj{set;}
    //public  schema.DisplayType dateDT {set; get{ return schema.DisplayType.DATE; }} 
   

    public ESDJC_Webforms_PDF_CompController(){      
    }    
    
    /*public schema.DisplayType getdateDT(){
        return schema.DisplayType.DATE;
    }*/

    
    public list<schema.FieldSetMember> getFSMList(){
        system.debug(' inside getFSMList');         
        system.debug('compObjectName'+compObjectName);
        system.debug('compFieldSetName'+compFieldSetName);
        
        SObjectType compSobjectType = Schema.getGlobalDescribe().get(compObjectName);
        system.debug('compSobjectType'+compSobjectType);
        if(compSobjectType== null){
		  throw new ApplicationException('No sobject '+compObjectName+' found.');
        }  
        Schema.Fieldset fieldSetObj  = compSobjectType.getDescribe().FieldSets.getMap().get(compFieldSetName.toLowerCase());
         
        if(fieldSetObj == null){
 		  throw new ApplicationException('No fieldset '+compFieldSetName+' found.');           
        }
        return fieldSetObj.getFields();
    }
    
    public sobject getsobj(){
             
            system.debug(' inside getSobj');                
            system.debug('compRecordId:'+compRecordId);
            system.debug('compObjectName:'+compObjectName);
            system.debug('compRecordId:'+compRecordId);

            list<string> fieldNames = new list<string>();
            //Just in case if this getter gets invoked first.
            list<schema.FieldSetMember> fsmList = getFSMList();
             
 
            for(schema.FieldSetMember fsm:fsmList){
                fieldNames.add(fsm.getFieldPath());
            }
            string query =  'select '+String.join(fieldNames,',')+',createddate'
                          + ' from ' + compObjectName 
                          + ' where id = '+'\''+ compRecordId+'\'';
            
            system.debug('query:'+query);
            
            sobject sobj = database.query(query);
            system.debug('sobj:'+sobj); 
        
        return sobj;
       
    }
}