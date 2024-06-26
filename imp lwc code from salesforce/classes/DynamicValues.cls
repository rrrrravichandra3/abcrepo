/**
 * Reads records from the DynamicValues__c 
 * Custom Setting in an structured way.
 */
public class DynamicValues {
    
    // DynamicValues__c Custom Setting
    // can hold values of multiple types.
    // In APEX code, we reference those types
    // via an enum
    public enum DynamicValuesType{
        OFFER_AE_JOBCODE,
        OFFER_SD_JOBCODE,
        OFFER_SE_JOBCODE     
    }
    
	//Holds the singleton object.
    private static DynamicValues dv;
    
    // Holds the single string that contains
    // the comma separated values representation 
    // of all the Custom Setting records
    // associated with the same type.
    private Map<DynamicValuesType, String> dataByType;
      
    // Creates (or returns) the singleton object
    public static DynamicValues getInstance() {
        if (dv == null) {
            dv = new DynamicValues();
            dv.populate();
        }
        return dv;
    }
    
    // Private constructor. 
    // Single instance is created/returned
    // via the getInstance() method.
    private DynamicValues(){
        this.dataByType = new Map<DynamicValuesType, String>();
    }
    
    // Gets data from the DynamicValue__c
    // custom setting. Populates the comma 
    // separated value represention of the 
    // records by type.
    // Only the records which Type__c is one
    // of the DynamicValuesType string are 
    // considered.
    public void populate() {
        // Holds the "list" representation of the 
        // values by type.
        Map<DynamicValuesType, List<String>> datasetByType;
        datasetByType = new Map<DynamicValuesType, List<String>>();
        
       	datasetByType.put(DynamicValuesType.OFFER_AE_JOBCODE,
                          new List<String>());
        datasetByType.put(DynamicValuesType.OFFER_SD_JOBCODE,
                          new List<String>());
        datasetByType.put(DynamicValuesType.OFFER_SE_JOBCODE,
                          new List<String>());
        
    	for (DynamicValue__c v : DynamicValue__c.getAll().values()) {         
            if (String.isEmpty(v.Type__c) == false) {
   				if (v.Type__c == DynamicValuesType.OFFER_AE_JOBCODE.name()) {
                    datasetByType.get(DynamicValuesType.OFFER_AE_JOBCODE).add(v.Name);
                } else if (v.Type__c == DynamicValuesType.OFFER_SD_JOBCODE.name()) {
                    datasetByType.get(DynamicValuesType.OFFER_SD_JOBCODE).add(v.Name);
                } else if (v.Type__c == DynamicValuesType.OFFER_SE_JOBCODE.name()) {
                    datasetByType.get(DynamicValuesType.OFFER_SE_JOBCODE).add(v.Name);
                }
            }			
        }
        
        String data;
       	data = String.join(datasetByType.get(DynamicValuesType.OFFER_AE_JOBCODE), ',');
        this.dataByType.put(DynamicValuesType.OFFER_AE_JOBCODE, data);
        data = String.join(datasetByType.get(DynamicValuesType.OFFER_SD_JOBCODE), ',');
        this.dataByType.put(DynamicValuesType.OFFER_SD_JOBCODE, data);
        data = String.join(datasetByType.get(DynamicValuesType.OFFER_SE_JOBCODE), ',');
        this.dataByType.put(DynamicValuesType.OFFER_SE_JOBCODE, data);

    }
    
    //Get the comma separated string of all the values of that type
    public string getValues(DynamicValuesType t) {
        String returnString = '';
        if (this.dataByType.containsKey(t) == true) {        
            returnString = dataByType.get(t);
        }
        return returnString;
    }
    
}