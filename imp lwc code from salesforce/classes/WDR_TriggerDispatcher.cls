/**
* @author Apuroop Gadde
* @date 06-21-2017
* @group General
* @description Trigger dispatcher that initializes the handlers for WDR,SIFT and NHW to trigger activity of
* the object and calls the appropriate events for the object
*/
public with sharing class WDR_TriggerDispatcher {
    @testVisible private WDR_CommonTriggerHandler wdrTriggerDataValidator;
    @testVisible private WDR_CommonTriggerHandler wdrTriggerHandler;
    @testVisible private Map<String,List<String>> eventsAndHandlers;
    
    //This ensures that the same handler classes do not get instantiated twice
    @testVisible private Map<String,WDR_CommonTriggerHandler> allHandlerClasses;
    @testVisible private Schema.sObjectType objectType;
     
    
    /**
    * @description Constructor that sets the object type and calls for retreival of custom metadata along with initialize handlers.
    * @param soType the object type whose custom metadata and handlers need to be initialized.
    **/
    public WDR_TriggerDispatcher(Schema.sObjectType soType) {
        if(soType == null) {
            return;
        }
        objectType = soType;
        eventsAndHandlers = new Map<String,List<String>>();
        allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();

        initializeHandlers();
    }

    /**
    * @description Calls all the handlers for the before insert event on the trigger of the object
    **/
    public void beforeInsert() {
        wdrTriggerDataValidator.beforeInsert();
        wdrTriggerHandler.beforeInsert();
        //if sift and nhw has before insert handler in custom mdt for this object call it
        List<WDR_CommonTriggerHandler> handlerClassesForBeforeInsert = initializeHandlerClassesForEvent('before insert');
        for(WDR_CommonTriggerHandler handlerClass : handlerClassesForBeforeInsert) {
            handlerClass.beforeInsert();
        }        
    }

    /**
    * @description Calls all the handlers for the after insert event on the trigger of the object
    **/
    public void afterInsert() {
        wdrTriggerDataValidator.afterInsert();
        wdrTriggerHandler.afterInsert();
        //if sift and nhw has after insert handler in custom mdt for this object call it
        List<WDR_CommonTriggerHandler> handlerClassesForAfterInsert = initializeHandlerClassesForEvent('after insert');
        for(WDR_CommonTriggerHandler handlerClass : handlerClassesForAfterInsert) {
            handlerClass.afterInsert();
        }        
    }

    /**
    * @description Calls all the handlers for the before update event on the trigger of the object
    **/
    public void beforeUpdate(){
        wdrTriggerDataValidator.beforeUpdate();
        wdrTriggerHandler.beforeUpdate();    
        //if sift and nhw has before update handler in custom mdt for this object call it
        List<WDR_CommonTriggerHandler> handlerClassesForBeforeUpdate = initializeHandlerClassesForEvent('before update');
        for(WDR_CommonTriggerHandler handlerClass : handlerClassesForBeforeUpdate) {
            handlerClass.beforeUpdate();
        }            
    }

    /**
    * @description Calls all the handlers for the after update event on the trigger of the object
    **/
    public void afterUpdate() {
        wdrTriggerDataValidator.afterUpdate();
        wdrTriggerHandler.afterUpdate();         
        //if sift and nhw has after update handler in custom mdt for this object call it
        List<WDR_CommonTriggerHandler> handlerClassesForAfterUpdate = initializeHandlerClassesForEvent('after update');
        for(WDR_CommonTriggerHandler handlerClass : handlerClassesForAfterUpdate) {
            handlerClass.afterUpdate();
        }          
    }

    /**
    * @description Calls all the handlers for the before delete event on the trigger of the object
    **/
    public void beforeDelete() {
        wdrTriggerDataValidator.beforeDelete();
        wdrTriggerHandler.beforeDelete();                 
        //if sift and nhw has before delete handler in custom mdt for this object call it
        List<WDR_CommonTriggerHandler> handlerClassesForBeforeDelete = initializeHandlerClassesForEvent('before delete');
        for(WDR_CommonTriggerHandler handlerClass : handlerClassesForBeforeDelete) {
            handlerClass.beforeDelete();
        }          
    }

    /**
    * @description Calls all the handlers for the after delete event on the trigger of the object
    **/
    public void afterDelete() {
        wdrTriggerDataValidator.afterDelete();
        wdrTriggerHandler.afterDelete();
        //if sift and nhw has after delete handler in custom mdt for this object call it
        List<WDR_CommonTriggerHandler> handlerClassesForAfterDelete = initializeHandlerClassesForEvent('after delete');
        for(WDR_CommonTriggerHandler handlerClass : handlerClassesForAfterDelete) {
            handlerClass.afterDelete();
        }          
    }

    /**
    * @description Calls all the handlers for the after undelete event on the trigger of the object
    **/
    public void afterUnDelete() {
        wdrTriggerDataValidator.afterUnDelete();
        wdrTriggerHandler.afterUnDelete();                        
        //if sift and nhw has after undelete handler in custom mdt for this object call it
        List<WDR_CommonTriggerHandler> handlerClassesForAfterUnDelete = initializeHandlerClassesForEvent('after undelete');
        for(WDR_CommonTriggerHandler handlerClass : handlerClassesForAfterUnDelete) {
            handlerClass.afterUnDelete();
        }              
    }

    /**
    * @description Initializes the handlers that pertain to the object in objectType . The handler names for SIFT and NHW are read from the 
    * custom metadata.
    **/
    @testVisible    
    private void initializeHandlers() {
        retrieveSIFTandNHWClassesMetadata();        
        if(objectType == WDR_Application__c.sObjectType) {
            wdrTriggerDataValidator = new WDR_ApplicationTriggerDataValidator();
            wdrTriggerHandler = new WDR_ApplicationTriggerHandler();

        }
        else if(objectType == WDR_Candidate__c.sObjectType) {
            wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();            
            wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        }
        else if(objectType == WDR_Job__c.sObjectType) {
            wdrTriggerDataValidator = new WDR_JobTriggerDataValidator();            
            wdrTriggerHandler = new WDR_JobTriggerHandler();
        }
    }

    /**
    * @description Reads the records from custom metadata WDR_Trigger_Handler__mdt that pertain to the object in 
    * objectType and populates the map with appropriate class names and order they need to be called in.
    **/
    @testVisible    
    private void retrieveSIFTandNHWClassesMetadata() {
        List<String> eventsForThisHandler = new List<String>();
        for(WDR_Trigger_Handler__mdt eventsAndHandler : [Select object__c, events__c, trigger_Handler_Class__c, trigger_Handler_Interface__c, order__c 
                                                                    from WDR_Trigger_Handler__mdt where disable__c = false and object__c = :objectType.getDescribe().getName()
                                                                    order by order__c]) {
            if(String.isBlank(eventsAndHandler.events__c)) {
                continue;
            }
            eventsForThisHandler = eventsAndHandler.events__c.split(',');
            for(String event:eventsForThisHandler) {
                event = event.trim();                
                if(eventsAndHandlers.get(event) == null) {
                    List<String> handlersForThisEvent = new List<String>();
                    handlersForThisEvent.add(eventsAndHandler.trigger_Handler_Class__c);
                    eventsAndHandlers.put(event,handlersForThisEvent);
                }
                else {
                    eventsAndHandlers.get(event).add(eventsAndHandler.trigger_Handler_Class__c);
                }
            }
        }
    }

    /**
    * @description Initializes the handler classes that pertain to the event that is passed to the method.
    * @param event Trigger event name whose classes need to be initialized.
    **/
    @testVisible
    private List<WDR_CommonTriggerHandler> initializeHandlerClassesForEvent(String event) {
        if(eventsAndHandlers.get(event) == null) {
            return new List<WDR_CommonTriggerHandler>();
        }
       
        List<WDR_CommonTriggerHandler> handlerClassesForEvent = new List<WDR_CommonTriggerHandler>();
       
        //this set is to make sure we instantiate and call every class only once for this event
        Set<String> uniqueClasses = new Set<String>();
       
        for(String handlerName : eventsAndHandlers.get(event)) {
            //The class has already been added to the stack of calls, so ignore it
            if(uniqueClasses.contains(handlerName) == true) {
                continue;
            }
            //if the handler class has already been initialized use that
            if(allHandlerClasses.get(handlerName) != null) {
                handlerClassesForEvent.add(allHandlerClasses.get(handlerName));
            }
            //else initialize the handler and add it to the allhandlerClasses map
            else {
                Type handlerType = Type.forName(handlerName);
                if(handlerType != null) {
                    WDR_CommonTriggerHandler eventHandler = (WDR_CommonTriggerHandler) handlerType.newInstance();
                    handlerClassesForEvent.add(eventHandler);
                    allHandlerClasses.put(handlerName,eventHandler);
                }
            }
            uniqueClasses.add(handlerName);
        }
        
        return handlerClassesForEvent;
    }
}