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

public class V2MOM_Value_Wrapper {
	
    private Value__c value;
    private MethodPrioritizationRow[] methods = new MethodPrioritizationRow[0];

    public V2MOM_Value_Wrapper(Value__c value) {
        this.value = value;
        if (value.Methods__r.size() > 0) {
            for (Method__c m : value.Methods__r) {
                MethodPrioritizationRow row = new MethodPrioritizationRow(m);
                methods.add(row);
            }
            methods[0].setFirstRow(true);
            methods[methods.size() - 1].setLastRow(true);
        }
    }

    public Value__c getValue() {
        return this.value;
    }

    public MethodPrioritizationRow[] getMethods() {
        return this.methods;
    }

    public void setMethods(MethodPrioritizationRow[] rows) {
        this.methods = rows;
    }
}