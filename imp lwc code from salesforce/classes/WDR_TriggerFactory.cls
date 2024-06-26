/**
* @author Apuroop Gadde
* @date 06-21-2017
* @group General
* @description Trigger factory that initializes the dispatcher to trigger the activity of
* the object and calls the appropriate event method from the dispatcher.
*/
public with sharing class WDR_TriggerFactory {
    //This ensures that there is only dispatcher per object per transaction.
    @testVisible private static Map<Schema.sObjectType,WDR_TriggerDispatcher> objectDispatchers = new Map<Schema.sObjectType,WDR_TriggerDispatcher>();
    
    /**
    * @description Initializes the trigger dispatcher and calls the 
    * execute on the dispatcher.
    * @param soType SObject Type whose handler needs to be initialized
    */
    public static void initiateDispatcher(Schema.sObjectType soType) {
        if(soType == null) {
            return;
        }
        if(objectDispatchers.get(soType) == null) {
            WDR_TriggerDispatcher dispatcher = new WDR_TriggerDispatcher(soType);
            objectDispatchers.put(soType,dispatcher);
        }
        
        // Execute the dispatcher to fulfill the trigger
        if(Trigger.isExecuting) {        
            execute(objectDispatchers.get(soType));
        }
    }
    

    /**
    * @description Calls the appropriate dispatcher method for the trigger event.
    * @param dispatcher
    **/
    @testVisible    
    private static void execute(WDR_TriggerDispatcher dispatcher) {
    	if(Trigger.isBefore) {
    		if(Trigger.isDelete) {
    			dispatcher.beforeDelete();
    		}
    		else if(Trigger.isInsert) {
    			dispatcher.beforeInsert();
    		}
    		else if(Trigger.isUpdate) {
    			dispatcher.beforeUpdate();
    		}
    	}
    	if(Trigger.isAfter) {
    		if(Trigger.isDelete) {
    			dispatcher.afterDelete();
    		}
    		else if(Trigger.isInsert) {
    			dispatcher.afterInsert();
    		}
    		else if(Trigger.isUpdate) {
    			dispatcher.afterUpdate();
    		}
    		else if(Trigger.isUndelete) {
    			dispatcher.afterUndelete();
    		}
    	}
    }
}