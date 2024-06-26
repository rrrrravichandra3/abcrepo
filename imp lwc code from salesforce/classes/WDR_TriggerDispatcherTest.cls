/**
* @author Apuroop Gadde
* @date 06-28-2017
* @group Unit Test Classes
* @description Unit Test Class for WDR_TriggerDispatcher Class
*/

@isTest
private class WDR_TriggerDispatcherTest {
    /**
    * @description Method to setup test data and configurations for unit tests
    **/
    @testSetup 
    static void testSetup() {

    }

    /**
    * @description Method tests to see if constructor does not fail when a valid SObject is provided
    * as constructor input.
    **/
    @isTest
    static void testTriggerDispatcherConstructorWithValidSObject() {
        WDR_TriggerDispatcher testTriggerDispatcher = new WDR_TriggerDispatcher(WDR_Candidate__c.sObjectType);
        System.assertNotEquals(testTriggerDispatcher,null);
    }

    /**
    * @description Method tests before insert trigger event on the dispatcher when dispatcher is initialized with a valid 
    * sobject
    **/
    @isTest
    static void testTriggerDispatcherBeforeInsertWithValidSObject() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> handlerList = new List<String>();
        handlerList.add('WDR_TestTriggerHandler');
        testDispatcher.eventsAndHandlers.put('before insert', handlerList);
        try {
            testDispatcher.beforeInsert();
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
        System.assertEquals(testDispatcher.allHandlerClasses.size(),1,'the number of classes in allHandlerClasses is not as expected');
    }

    /**
    * @description Method tests before insert trigger event on the dispatcher when dispatcher is initialized with 
    * null
    **/
    @isTest
    static void testTriggerDispatcherBeforeInsertWithNullSObject() {
        WDR_TriggerDispatcher testTriggerDispatcher = new WDR_TriggerDispatcher(null);
        try {
            testTriggerDispatcher.beforeInsert();
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.NullPointerException','Expected exception is null pointer exception');
            return;
        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method tests after insert trigger event on the dispatcher when dispatcher is initialized with a valid 
    * sobject
    **/
    @isTest
    static void testTriggerDispatcherAfterInsertWithValidSObject() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> handlerList = new List<String>();
        handlerList.add('WDR_TestTriggerHandler');
        testDispatcher.eventsAndHandlers.put('after insert', handlerList);
        try {
            testDispatcher.afterInsert();
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
        System.assertEquals(testDispatcher.allHandlerClasses.size(),1,'the number of classes in allHandlerClasses is not as expected');
    }

    /**
    * @description Method tests after insert trigger event on the dispatcher when dispatcher is initialized with 
    * null
    **/
    @isTest
    static void testTriggerDispatcherAfterInsertWithNullSObject() {
        WDR_TriggerDispatcher testTriggerDispatcher = new WDR_TriggerDispatcher(null);
        Exception caughtException = null;
        try {
            testTriggerDispatcher.afterInsert();
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.NullPointerException','Expected exception is null pointer exception');
            return;

        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method tests before update trigger event on the dispatcher when dispatcher is initialized with a valid 
    * sobject
    **/
    @isTest
    static void testTriggerDispatcherBeforeUpdateWithValidSObject() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> handlerList = new List<String>();
        handlerList.add('WDR_TestTriggerHandler');
        testDispatcher.eventsAndHandlers.put('before update', handlerList);
        try {
            testDispatcher.beforeUpdate();
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
        System.assertEquals(testDispatcher.allHandlerClasses.size(),1,'the number of classes in allHandlerClasses is not as expected');        
    }

    /**
    * @description Method tests before update trigger event on the dispatcher when dispatcher is initialized with 
    * null
    **/
    @isTest
    static void testTriggerDispatcherBeforeUpdateWithNullSObject() {
        WDR_TriggerDispatcher testTriggerDispatcher = new WDR_TriggerDispatcher(null);
        try {
            testTriggerDispatcher.beforeUpdate();
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.NullPointerException','Expected exception is null pointer exception');
            return;            
        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method tests after update trigger event on the dispatcher when dispatcher is initialized with a valid 
    * sobject
    **/
    @isTest
    static void testTriggerDispatcherAfterUpdateWithValidSObject() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> handlerList = new List<String>();
        handlerList.add('WDR_TestTriggerHandler');
        testDispatcher.eventsAndHandlers.put('after update', handlerList);
        try {
            testDispatcher.afterUpdate();
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
        System.assertEquals(testDispatcher.allHandlerClasses.size(),1,'the number of classes in allHandlerClasses is not as expected');        
    }

    /**
    * @description Method tests after update trigger event on the dispatcher when dispatcher is initialized with 
    * null
    **/
    @isTest
    static void testTriggerDispatcherAfterUpdateWithNullSObject() {
        WDR_TriggerDispatcher testTriggerDispatcher = new WDR_TriggerDispatcher(null);
        try {
            testTriggerDispatcher.afterUpdate();
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.NullPointerException','Expected exception is null pointer exception');
            return;            
        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method tests before delete trigger event on the dispatcher when dispatcher is initialized with a valid 
    * sobject
    **/
    @isTest
    static void testTriggerDispatcherBeforeDeleteWithValidSObject() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> handlerList = new List<String>();
        handlerList.add('WDR_TestTriggerHandler');
        testDispatcher.eventsAndHandlers.put('before delete', handlerList);
        try {
            testDispatcher.beforeDelete();
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
        System.assertEquals(testDispatcher.allHandlerClasses.size(),1,'the number of classes in allHandlerClasses is not as expected');        
    }

    /**
    * @description Method tests before delete trigger event on the dispatcher when dispatcher is initialized with 
    * null
    **/
    @isTest
    static void testTriggerDispatcherBeforeDeleteWithNullSObject() {
        WDR_TriggerDispatcher testTriggerDispatcher = new WDR_TriggerDispatcher(null);
        try {
            testTriggerDispatcher.beforeDelete();
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.NullPointerException','Expected exception is null pointer exception');
            return;            
        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method tests after delete trigger event on the dispatcher when dispatcher is initialized with a valid 
    * sobject
    **/
    @isTest
    static void testTriggerDispatcherAfterDeleteWithValidSObject() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> handlerList = new List<String>();
        handlerList.add('WDR_TestTriggerHandler');
        testDispatcher.eventsAndHandlers.put('after delete', handlerList);
        try {
            testDispatcher.afterDelete();
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
        System.assertEquals(testDispatcher.allHandlerClasses.size(),1,'the number of classes in allHandlerClasses is not as expected');
    }

    /**
    * @description Method tests after delete trigger event on the dispatcher when dispatcher is initialized with 
    * null
    **/
    @isTest
    static void testTriggerDispatcherAfterDeleteWithNullSObject() {
        WDR_TriggerDispatcher testTriggerDispatcher = new WDR_TriggerDispatcher(null);
        try {
            testTriggerDispatcher.afterDelete();
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.NullPointerException','Expected exception is null pointer exception');
            return;            
        }
        System.assert(false,'Exception not thrown');
    }

    /**
    * @description Method tests after undelete trigger event on the dispatcher when dispatcher is initialized with a valid 
    * sobject
    **/
    @isTest
    static void testTriggerDispatcherAfterUnDeleteWithValidSObject() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> handlerList = new List<String>();
        handlerList.add('WDR_TestTriggerHandler');
        testDispatcher.eventsAndHandlers.put('after undelete', handlerList);
        try {
            testDispatcher.afterUnDelete();
        }
        catch(Exception e) {
            System.assert(false,'Assertion failed with Exception:'+e.getMessage());
        }
        System.assertEquals(testDispatcher.allHandlerClasses.size(),1,'the number of classes in allHandlerClasses is not as expected');        
    }

    /**
    * @description Method tests after undelete trigger event on the dispatcher when dispatcher is initialized with 
    * null
    **/
    @isTest
    static void testTriggerDispatcherAfterUnDeleteWithNullSObject() {
        WDR_TriggerDispatcher testTriggerDispatcher = new WDR_TriggerDispatcher(null);
        Exception caughtException = null;
        try {
            testTriggerDispatcher.afterUnDelete();
        }
        catch(Exception e) {
            System.assertEquals(e.getTypeName(),'System.NullPointerException','Expected exception is null pointer exception');
            return;            
        }
        System.assert(false,'Exception not thrown');
    }
    
    /**
    * @description Method tests InitializeHandlerClasses on an event that is invalid 
    **/
    @isTest
    static void testInitializeHandlerClassesForEventOnInvalidEvent() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();

        testDispatcher.initializeHandlerClassesForEvent('invalid event');
        System.assertEquals(testDispatcher.initializeHandlerClassesForEvent('invalid event').size(),0,'Returned Non-zero size for invalid event');
        System.assertEquals(testDispatcher.allHandlerClasses.size(),0,'Invalid size on allHandlerClasses');        
       
    }

    /**
    * @description Method tests InitializeHandlerClasses on an event that is valid but has an invalid class name
    **/
    @isTest
    static void testInitializeHandlerClassesForEventOnValidEventWithInvalidClassName() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> afterUpdateList = new List<String>();
        afterUpdateList.add('TestHandlerClass');
        testDispatcher.eventsAndHandlers.put('after update', afterUpdateList);
        testDispatcher.initializeHandlerClassesForEvent('after update');
        System.assertEquals(testDispatcher.initializeHandlerClassesForEvent('after update').size(),0,'Returned Non-zero size for event');
        System.assertEquals(testDispatcher.allHandlerClasses.size(),0,'Invalid size on allHandlerClasses');        
    }

    /**
    * @description Method tests InitializeHandlerClasses on an event that is valid and a valid class name
    **/
    @isTest
    static void testInitializeHandlerClassesForEventOnValidEventWithValidClassName() {
        WDR_TriggerDispatcher testDispatcher = new WDR_TriggerDispatcher(null);
        testDispatcher.wdrTriggerDataValidator = new WDR_CandidateTriggerDataValidator();  
        testDispatcher.wdrTriggerHandler = new WDR_CandidateTriggerHandler();
        testDispatcher.eventsAndHandlers = new Map<String,List<String>>();
        testDispatcher.allHandlerClasses = new Map<String,WDR_CommonTriggerHandler>();
        List<String> afterUpdateList = new List<String>();
        afterUpdateList.add('WDR_TestTriggerHandler');
        testDispatcher.eventsAndHandlers.put('after update', afterUpdateList);
        testDispatcher.initializeHandlerClassesForEvent('after update');
        System.assertEquals(testDispatcher.initializeHandlerClassesForEvent('after update').size(),1,'Returned different size from the expected size');
        System.assertEquals(testDispatcher.allHandlerClasses.size(),1,'Invalid size on allHandlerClasses');        
       
    }
}