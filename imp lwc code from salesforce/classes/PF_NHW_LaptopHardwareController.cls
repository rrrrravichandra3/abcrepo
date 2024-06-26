/**
 * Created by kmoseley on 12/28/20.
 */

public with sharing class PF_NHW_LaptopHardwareController {
    @AuraEnabled
    public static List<NH_Laptop_Hardware_Specifications__mdt> returnHardwareSpecs(){
        List<NH_Laptop_Hardware_Specifications__mdt> specs = new List<NH_Laptop_Hardware_Specifications__mdt>();
        try{
            return [SELECT id, MasterLabel, Memory__c, Processor__c, Screen__c, Sort_Order__c, Storage__c FROM NH_Laptop_Hardware_Specifications__mdt ORDER BY Sort_Order__c];
        }catch(QueryException qe){
            return specs;
        }
    }

}