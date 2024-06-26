public class V2MOM_Prioritization_Controller {
	
    private V2MOM_Value_Wrapper[] values = new V2MOM_Value_Wrapper[0];

    public V2MOM_Prioritization_Controller() {
        Id v2mom_id = System.currentPageReference().getParameters().get('id');
        if (v2mom_id != null) {
            Value__c[] values = [select Id, Name, Tag_Line__c, (select Id, Name, Description__c, Priority__c, Accountable_Person__r.Name from Methods__r order by Priority__c), (select Id, Name, Description__c, Method__r.Name from Obstacles__r order by Priority__c), (select Id, Name, Description__c, Method__r.Name from Measures__r order by Priority__c) from Value__c where V2MOM__c = :v2mom_id order by Priority__c];
            for (Value__c value : values) {
                V2MOM_Value_Wrapper wrapper = new V2MOM_Value_Wrapper(value);
                this.values.add(wrapper);
            }
        }
    }

    public V2MOM_Value_Wrapper[] getValues() {
        return this.values;
    }
}