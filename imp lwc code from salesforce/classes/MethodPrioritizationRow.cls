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

public class MethodPrioritizationRow {
 
    private Method__c method;
    private Boolean isFirstRow = false;
    private Boolean isLastRow = false;

    public MethodPrioritizationRow(Method__c method) {
        this.method = method;
    }

    public void setFirstRow(Boolean isFirstRow) {
        this.isFirstRow = isFirstRow;
    }

    public void setLastRow(Boolean isLastRow) {
        this.isLastRow = isLastRow ;
    } 

    public Method__c getMethod() {
        return this.method;
    }

    private void setMethod(Method__c m) {this.method = m; }

    public Integer getPriority() {
        return this.method.Priority__c.intValue();
    }

    public void setPriority(String i) { this.method.priority__c = Integer.valueOf(i); }

    public String getStyleClass() {
        if (this.isLastRow) {
            return Label.dataRow_odd_last_label;
        } else if (this.isFirstRow) {
            return Label.dataRow_odd_first_label;
        } else {
            return Label.dataRow_odd_label;
        }
    }
}