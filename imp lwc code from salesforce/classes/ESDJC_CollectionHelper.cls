public with sharing class ESDJC_CollectionHelper {

    /*
     * Method which takes a list of SObjects and a field name and returns a set
     * of ID's which corresponds to the field name.  If the field that the name
     * refers to is not of type Id then an exception is thrown.
     * @param objects the list of SObjects which holds the field to create the set from.
     * @param fieldName the name of the field that the set should be created from.
     */
    public static Set<Id> getIdFieldSet(List<SObject> objects, String fieldName)
    {
        
        Set<Id> values = new Set<Id>();
        
        if (objects != null && objects.size() != 0) 
        {
	        
	        for (SObject obj: objects)
	        {
	            values.add((Id) obj.get(fieldName));        
	        }
        }
        
        return values;

    }
    
    /*
     * Method which takes a list of SObjects and a field name and returns a list
     * of ID's which corresponds to the field name.  If the field that the name
     * refers to is not of type Id then an exception is thrown.
     * @param objects the list of SObjects which holds the field to create the list from.
     * @param fieldName the name of the field that the set should be created from.
     */
    public static List<Id> getIdFieldList(List<SObject> objects, String fieldName)
    {
        
        List<Id> values = new List<Id>();
        
        if (objects != null && objects.size() != 0) 
        {
	        
	        for (SObject obj: objects)
	        {
	            values.add((Id) obj.get(fieldName));        
	        }
        }
        
        return values;

    }
    
    /*
     * Method which takes a list of objects and a field name and returns a map containing the field
     * as the key and a list of objects which are related to the key.  If the field that the name
     * refers to is not of type Id then an exception is thrown.
     * NOTE - if the list contains two objects with the same key only one will be returned in the map
     *        if there are multiple objects with the same ID then use getIdMappedObjects() method.
     * @param objects the list of SObjects which holds the field to create the map from.
     * @param fieldName the name of the field that the map should use for its key.
     */
    public static Map<Id, SObject> getSimpleIdMappedObjects(List<Sobject> objects, String fieldName)
    {
        
        Map<Id, SObject> mappedObjs = new Map<Id, SObject>();
        
		if (objects != null && objects.size() != 0)
		{
	        
            for (SObject obj: objects)
            {
                mappedObjs.put((Id) obj.get(fieldName), obj);                
            }
            
        }
        
        return mappedObjs;
        
    }
    
    /*
     * Method which takes a list of objects and a field name and returns a map containing the field
     * as the key and a list of objects which are related to the key.  If the field that the name
     * refers to is not of type Id then an exception is thrown.
     * @param objects the list of SObjects which holds the field to create the map from.
     * @param fieldName the name of the field that the map should use for its key.
     */
    public static Map<Id, List<SObject>> getIdMappedObjects(List<Sobject> objects, String fieldName) {
        
        Map<Id, List<SObject>> mappedObjs = new Map<Id, List<SObject>>();
        
		if (objects != null && objects.size() != 0) {
	        
            for (SObject obj: objects) {
                
                if (mappedObjs.get((Id) obj.get(fieldName)) != null) {
                    ((List<SObject>) mappedObjs.get((Id) obj.get(fieldName))).add(obj);
                } else {
                    List<SObject> objs = new List<SObject>();
                    objs.add(obj);
                    mappedObjs.put((Id) obj.get(fieldName), objs);
                }
                
            }
            
        }
        
        return mappedObjs;
        
    }
    
}