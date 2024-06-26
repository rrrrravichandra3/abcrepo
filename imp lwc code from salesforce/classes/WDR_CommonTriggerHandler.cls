/**
* @author Apuroop Gadde
* @date 06-21-2017
* @group General
* @description This is the common trigger interface that needs to be implemented by object handlers
* to perform trigger events
*/
public interface WDR_CommonTriggerHandler {
    
    /**
    * @description Interface method for handling before insert method.
    *
    **/
    void beforeInsert();
    
    /**
    * @description Interface method for handling after insert method.
    *
    **/
    void afterInsert();
    
    /**
    * @description Interface method for handling before update method.
    *
    **/
    void beforeUpdate();
    
    /**
    * @description Interface method for handling after update method.
    *
    **/
    void afterUpdate();
    
    /**
    * @description Interface method for handling before delete method.
    *
    **/
    void beforeDelete();
    
    /**
    * @description Interface method for handling after delete method.
    *
    **/
    void afterDelete();

    /**
    * @description Interface method for handling after undelete method.
    *
    **/
    void afterUnDelete();
}