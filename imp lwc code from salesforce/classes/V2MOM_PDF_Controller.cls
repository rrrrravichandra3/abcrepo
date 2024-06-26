/*
 * RelEng Perforce/RCS Header - Do not remove!
 *
 * $Author:  $
 * $Change:  $
 * $DateTime:  $
 * $File:  $
 * $Id:  $
 * $Revision:  $
 */

/*
 * this class will take an account and assign it to a user.
 * @author Mike Fullmore - 4/2/2009
*/

public class V2MOM_PDF_Controller {
	
    private V2MOM__c v2mom = null;
    private Map<Id, Value__c> valuesMap = new Map<Id, Value__c>();
    private Value__c[] values = null;
    private MethodPrioritizationRow[] rows = null;

    public V2MOM_PDF_Controller() {
        this.reset();
    } 
    public V2MOM__c getV2MOM() {
        return this.v2mom;
    }
    public void setV2MOM(V2MOM__c v) {
        this.v2mom = v;
    }
    public Value__c[] getValues() {
        return this.values;
    }
    public void setValues(Value__c[] v) {
        this.values = v;
        this.valuesMap.clear();
        for (Value__c value : this.values) {
            this.valuesMap.put(value.Id, value);
        }
    }
    public PageReference addValue() {
        Value__c new_value = new Value__c();
        this.values.add(new_value);
        this.valuesMap.put(null, new_value);
        new_value.Priority__c = this.values.size();
        new_value.V2MOM__c = this.v2mom.Id;
        return null;
    }
    private Value__c getValue(Id id) {
        return this.valuesMap.get(id);
    }
    public PageReference addMethod() {
        Id value_id = System.currentPageReference().getParameters().get('Value');
        Value__c value = getValue(value_id);
        Method__c new_method = new Method__c();
        new_method.V2MOM__c = this.v2mom.id;
        new_method.Value__c = value.id;
        value.Methods__r.add(new_method);
        new_method.Priority__c = value.Methods__r.size();
        return null;
    }
    public PageReference reset() {
        Id v2mom_id = System.currentPageReference().getParameters().get('id');
        if (v2mom_id != null) {
            this.v2mom = [select Id, Name, Vision__c from V2MOM__c where Id = :v2mom_id];
            Value__c[] values = [select Id, Name, Tag_Line__c, (select Id, Name, Description__c, Priority__c, Accountable_Person__r.Name from Methods__r order by Priority__c), (select Id, Name, Description__c, Method__r.Name from Obstacles__r order by Priority__c), (select Id, Name, Description__c, Method__r.Name from Measures__r order by Priority__c) from Value__c where V2MOM__c = :v2mom_id order by Priority__c];
            this.setValues(values);
        }
        return null;
    }
}