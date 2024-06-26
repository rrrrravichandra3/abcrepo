/**
 * ******************************************** W-12535956 : API CALLOUT FRAMEWORK ********************************************
 * 
 * Implements Abstract Class for CalloutRequestParams to Serialize value of Params attribute of the API Request Payload to XML string.
 * 
 * Version      Date            Author                  Description
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * v1.0         23/02/2023      Chakshu Malhotra        W-12535956 - Adds an abstract class to serialize content of Params attribute of the request payload.
 * -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 */
public abstract without sharing class MA_DS_AbstractCalloutRequestParams implements MA_DS_CalloutFramework.CalloutRequestParams {
    
    private String rootElement;
    private Boolean serializeNulls;
    protected Object deserializedParams {get; set;}
    protected MA_DS_CalloutFramework.RequestParams requestParams {get; set;}

    /**
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to serialize the JSON formatted "deserializedParams" into an XML string for the Docusign acceptable payload format.
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    serializeNulls	    DESCRIPTION (Data Type Boolean, True if null values need to be serialized)
    * @param    rootElement	        DESCRIPTION (Data Type Boolean, Root node that gets added to the serialized XML formatted Params)
    * @return   String              DESCRIPTION (return Serialized string of Params in XML format)
    * ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual String serializeToXML(Boolean serializeNulls, String rootElement) {
        this.rootElement = rootElement;
        //this.serializeNulls = serializeNulls;
        this.serializeNulls = true;
        return String.isBlank(rootElement) ? serialize((Map<String, Object>)deserializedParams) : wrap(rootElement, serialize((Map<String, Object>)deserializedParams));
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to serialize JSON formatted "deserializedParams" into an XML format, by forming Key-Value pairs out of Param Name & Param value.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    objectMap	            DESCRIPTION (Data Type Map<String, Object>, JSON formatted deserialized requestParams)
    * @return   String                  DESCRIPTION (return Serialized XML string)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String serialize(Map<String, Object> objectMap) {
        String xmlString = '';

        for(String key : objectMap.keySet()) {
            Object objVal = objectMap.get(key);

            if(objVal == null && this.serializeNulls) {
                xmlString += wrap(key, null);
            }else if(objVal instanceof List<Object>) {
                xmlString += serialize((List<Object>)objVal, key);
            }else if(objVal instanceof Map<String, Object>) {
                xmlString += wrap(key, serialize((Map<String, Object>)objVal));
            }else {
                xmlString += wrap(key, String.valueOf(objVal)?.escapeXml());
            }
        }
        return xmlString;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to serialize JSON formatted "deserializedParams" into an XML format, by forming Key-Value pairs out of Param Name & Param value.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    objectList	            DESCRIPTION (Data Type List<Object>, JSON formatted deserialized requestParams)
    * @param    key	                    DESCRIPTION (Data Type String, Key node for the List of Key-Value pairs within that node)
    * @return   String                  DESCRIPTION (return Serialized XML string)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String serialize(List<Object> objectList, String key) {
        String xmlString = '';

        for(Object objVal : objectList) {
            if(objVal instanceof String) {
                xmlString += wrap(key, String.valueOf(objVal)?.escapeXml());
            }else if(objVal instanceof List<Object>) {
                xmlString += wrap(key, serialize((List<Object>)objVal, key));
            }else {
                xmlString += wrap(key, serialize((Map<String,Object>)objVal));
            }
        }
        return xmlString;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to create Key Node (start and end node in XML) and wrap value within it.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @param    key	                DESCRIPTION (Data Type String, XML node name)
    * @param    value	            DESCRIPTION (Data Type String, Value within the XML node)
    * @return   String              DESCRIPTION (return Serialized XML Node with value wrapped in it)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    private String wrap(String key, String value) {
        return (String.isNotBlank(value) || this.serializeNulls) ? ('<' + key + '>' + (String.isBlank(value) ? '' : value) + '</' + key + '>') : value;
    }

    /**
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to get the MA_DS_CalloutFramework.RequestParams instance to be used by CalloutFramework in ResponseCallback implementation.
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    * @return   MA_DS_CalloutFramework.RequestParams              DESCRIPTION (return MA_DS_CalloutFramework.RequestParams instance)
    * ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual MA_DS_CalloutFramework.RequestParams getRequestParams() {
        return this.requestParams;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to be overridden by the sub-class, to deserialize the requestParams of generic Object type.
    * ─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void deserializeParams(Object requestParams) {}

    /**
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    * Method to be overridden by the sub-class, to deserialize the requestParams of type MA_DS_CalloutFramework.RequestParams.
    * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public virtual void deserializeParams(MA_DS_CalloutFramework.RequestParams requestParams) {}
}