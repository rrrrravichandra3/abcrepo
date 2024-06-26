/**
 * @description       : 
 * @author            : Urvish Shah (ushah)
 * @group             : 
 * @last modified on  : 03-23-2023
 * @last modified by  : Urvish Shah (ushah)
**/
public abstract class CoreObject{
    public Object getX(String param_name){
            String json_instance = Json.serialize(this);
            Map<String, Object> untyped_instance;
            untyped_instance= (Map<String, Object>)JSON.deserializeUntyped(json_instance);
            return untyped_instance.get(param_name);
    }
}