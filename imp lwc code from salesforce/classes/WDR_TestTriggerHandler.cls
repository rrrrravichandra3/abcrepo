/**
* @author Apuroop Gadde
* @date 07-06-2017
* @group Unit Test Classes
* @description Test Trigger handler for unit testing.
*/
public with sharing class WDR_TestTriggerHandler implements WDR_CommonTriggerHandler {
    /**
    * @description Constructor to cast the trigger variables from generics to WDR_Candidate objects.
    **/
    public WDR_TestTriggerHandler() {
    }

    /**
    * @description method to handle the before insert event on the WDR_Candidate object for test cases
    **/
    public void beforeInsert() {
        if(Test.isRunningTest()){
            //do something
        }
    }

    /**
    * @description method to handle the after insert event on the WDR_Candidate object for test cases
    **/
    public void afterInsert() {
        if(Test.isRunningTest()){
            //do something
        }        
    }

    /**
    * @description method to handle the before update event on the WDR_Candidate object for test cases
    **/
    public void beforeUpdate(){
        if(Test.isRunningTest()){
            //do something
        }
    }

    /**
    * @description method to handle the after update event on the WDR_Candidate object for test cases
    **/
    public void afterUpdate() {
        if(Test.isRunningTest()){
            //do something
        }
    }

    /**
    * @description method to handle the before delete event on the WDR_Candidate object for test cases
    **/
    public void beforeDelete() {
        if(Test.isRunningTest()){
            //do something
        }    
    }

    /**
    * @description method to handle the after delete event on the WDR_Candidate object for test cases
    **/
    public void afterDelete() {
        if(Test.isRunningTest()){
            //do something
        }    
    }

    /**
    * @description method to handle the after undelete event on the WDR_Candidate object for test cases
    **/
    public void afterUnDelete() {
        if(Test.isRunningTest()){
            //do something
        }    
    }
}